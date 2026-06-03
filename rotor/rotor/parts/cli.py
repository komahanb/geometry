#!/usr/bin/env python3
"""Shared command-line lifecycle for the parametric rotor part builders.

Every part exposes the same CLI (``--mesh``, ``--mesh-dim``, ``--mesh-file``,
``--export``, ``--param NAME=VALUE``, ``--show``).  Centralising the gmsh
initialise/configure/build/export/mesh/finalize sequence here keeps each part
module focused on geometry and avoids duplicating the entry-point logic, as
required by AGENTS.md.
"""

import argparse
import gmsh
import os
import sys
from typing import Dict, Iterable, Protocol

DEFAULT_MESH_DIM = 3
_PARTS_DIR = os.path.dirname(os.path.abspath(__file__))


class GeometryBuilder(Protocol):
    """Protocol implemented by every part geometry class."""

    def build(self, model_name: str = ...): ...


def default_mesh_path(mesh_name: str) -> str:
    """Default mesh output: ``rotor/mesh/<mesh_name>`` next to the package."""
    return os.path.normpath(os.path.join(_PARTS_DIR, "..", "..", "mesh", mesh_name))


def set_mesh_option(name: str, value: float) -> None:
    """Apply a mesh option, ignoring keys removed in newer gmsh releases."""
    try:
        gmsh.option.setNumber(name, value)
    except Exception:
        gmsh.logger.write(f"Warning: unable to set {name}")


def configure_mesh_options() -> None:
    """Mirror the mesh controls shared by the legacy GEO drivers."""
    set_mesh_option("Mesh.CharacteristicLengthExtendFromBoundary", 1)
    set_mesh_option("Mesh.CharacteristicLengthFactor", 0.25)
    set_mesh_option("Mesh.CharacteristicLengthMin", 0.0)
    set_mesh_option("Mesh.CharacteristicLengthMax", 1.0)
    # In gmsh 4.x this option is the number of elements per 2*pi of curvature
    # (not the legacy on/off flag); a real count is needed to resolve small
    # curved features such as the pitch-link socket wall.
    set_mesh_option("Mesh.CharacteristicLengthFromCurvature", 12)
    set_mesh_option("Mesh.Optimize", 1)
    set_mesh_option("Mesh.SubdivisionAlgorithm", 1)
    set_mesh_option("Mesh.RecombinationAlgorithm", 1)
    set_mesh_option("Mesh.RecombineAll", 1)
    # The legacy GEO files also set Mesh.RemeshAlgorithm and
    # Mesh.RemeshParametrization; both were removed in gmsh 4.x (opening the
    # old .geo files outright errors on them), so they are intentionally
    # dropped here. set_mesh_option would otherwise still guard them.
    set_mesh_option("Mesh.RefineSteps", 10)
    set_mesh_option("Mesh.Smoothing", 5)
    set_mesh_option("Mesh.ElementOrder", 2)
    set_mesh_option("Mesh.BdfFieldFormat", 2)
    set_mesh_option("Mesh.Format", 31)
    set_mesh_option("Mesh.SaveElementTagType", 1)


def parse_parameter_overrides(raw_items: Iterable[str]) -> Dict[str, float]:
    """Parse ``NAME=VALUE`` overrides passed on the CLI."""
    overrides: Dict[str, float] = {}
    for item in raw_items:
        if "=" not in item:
            raise ValueError(f"Expected NAME=VALUE, got '{item}'")
        name, value = item.split("=", 1)
        name = name.strip()
        if not name:
            raise ValueError(f"Missing parameter name in '{item}'")
        try:
            overrides[name] = float(value)
        except ValueError as exc:
            raise ValueError(f"Non-numeric value in '{item}'") from exc
    return overrides


def build_parser(description: str, default_mesh_name: str) -> argparse.ArgumentParser:
    """Return the common argument parser used by every part's ``main``."""
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument(
        "--mesh", action="store_true",
        help="Generate a mesh after the geometry is built.",
    )
    parser.add_argument(
        "--mesh-dim", type=int, default=DEFAULT_MESH_DIM, choices=(1, 2, 3),
        help="Dimension of the mesh to generate (default: 3).",
    )
    parser.add_argument(
        "--mesh-file",
        help=f"Output path for the mesh; defaults to ../../mesh/{default_mesh_name}.",
    )
    parser.add_argument(
        "--export", action="append", default=[], metavar="PATH",
        help="Write geometry/mesh to PATH; format inferred from the extension "
        "(.brep, .iges, .step, .bdf, .msh). May be given multiple times.",
    )
    parser.add_argument(
        "--param", action="append", default=[], metavar="NAME=VALUE",
        help="Override a geometry parameter (may be specified multiple times).",
    )
    parser.add_argument(
        "--show", action="store_true",
        help="Display the geometry or mesh using the gmsh FLTK viewer.",
    )
    return parser


def _write(path: str) -> None:
    """Create the parent directory if needed and write the current model."""
    directory = os.path.dirname(path)
    if directory and not os.path.exists(directory):
        os.makedirs(directory, exist_ok=True)
    gmsh.write(path)


def run(
    geometry_class,
    description: str,
    default_mesh_name: str,
    model_name: str,
    argv: Iterable[str] | None = None,
) -> None:
    """Drive the full build lifecycle for a single part.

    Instantiates ``geometry_class`` with any CLI overrides, builds the
    geometry, then exports and/or meshes per the requested flags.
    """
    if argv is None:
        argv = sys.argv[1:]

    parser = build_parser(description, default_mesh_name)
    args = parser.parse_args(list(argv))

    try:
        overrides = parse_parameter_overrides(args.param)
    except ValueError as exc:
        raise SystemExit(str(exc)) from exc

    gmsh.initialize()
    gmsh.option.setNumber("General.Terminal", 1)
    try:
        configure_mesh_options()
        geometry = geometry_class(overrides)
        volume_tag, point_records = geometry.build(model_name=model_name)
        gmsh.logger.write(f"Created {model_name} volume tag: {volume_tag}")
        for name, record in point_records.items():
            coords = record[1]
            gmsh.logger.write(
                f"{name}: ({coords[0]:.6f}, {coords[1]:.6f}, {coords[2]:.6f})"
            )

        if args.mesh:
            gmsh.model.mesh.generate(args.mesh_dim)

        for path in args.export:
            _write(path)

        if args.mesh:
            _write(args.mesh_file or default_mesh_path(default_mesh_name))

        if args.show and hasattr(gmsh, "fltk") and gmsh.fltk.isAvailable():
            gmsh.fltk.initialize()
            gmsh.fltk.run()
    finally:
        gmsh.finalize()
