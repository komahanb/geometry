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
import shutil
import subprocess
import sys
import tempfile
from typing import Dict, Iterable, Optional, Protocol

DEFAULT_MESH_DIM = 3
_PARTS_DIR = os.path.dirname(os.path.abspath(__file__))

# Extensions a standalone gmsh GUI can open directly.
_VIEWABLE_EXTS = (".brep", ".step", ".stp", ".iges", ".igs", ".msh")


def find_gui_gmsh() -> Optional[str]:
    """Return the path to a GUI-capable standalone ``gmsh`` binary, if any.

    The pip ``gmsh`` wheel ships a GUI-less library (``gmsh.fltk.isAvailable()``
    is 0) and a tiny Python launcher script of the same name, so we look for a
    real compiled binary (ELF/Mach-O) on PATH and in the usual system
    locations, skipping that script.
    """
    seen = set()
    path_dirs = os.environ.get("PATH", "").split(os.pathsep)
    candidates = [shutil.which("gmsh")] + [
        os.path.join(d, "gmsh")
        for d in path_dirs + ["/usr/bin", "/usr/local/bin", "/opt/gmsh/bin"]
    ]
    for cand in candidates:
        if not cand or cand in seen:
            continue
        seen.add(cand)
        if not (os.path.isfile(cand) and os.access(cand, os.X_OK)):
            continue
        try:
            with open(cand, "rb") as handle:
                magic = handle.read(4)
        except OSError:
            continue
        # Real binaries start with ELF (Linux) or Mach-O magic; the pip
        # launcher starts with "#!" (a shebang) and is skipped.
        if magic[:4] == b"\x7fELF" or magic[:4] in (
            b"\xcf\xfa\xed\xfe", b"\xfe\xed\xfa\xcf", b"\xca\xfe\xba\xbe"
        ):
            return cand
    return None


def show_model(path_hint: Optional[str] = None) -> bool:
    """Display the current model, returning ``True`` if a viewer was opened.

    Prefers the in-process FLTK viewer; if this gmsh build lacks it, writes the
    model to a viewable file (reusing ``path_hint`` when it already is one) and
    launches a standalone GUI gmsh on it.  Warns and returns ``False`` if no
    viewer is available rather than failing silently.
    """
    if hasattr(gmsh, "fltk") and gmsh.fltk.isAvailable():
        gmsh.fltk.initialize()
        gmsh.fltk.run()
        return True

    binary = find_gui_gmsh()
    if binary is None:
        gmsh.logger.write(
            "Cannot --show: this gmsh Python build has no FLTK viewer and no "
            "standalone GUI gmsh was found on PATH. Export the geometry "
            "(--export/--out) and open it in a GUI gmsh or FreeCAD.",
            level="warning",
        )
        return False

    path = path_hint
    if not path or os.path.splitext(path)[1].lower() not in _VIEWABLE_EXTS:
        handle, path = tempfile.mkstemp(suffix=".brep", prefix="gmsh_show_")
        os.close(handle)
        gmsh.write(path)
    gmsh.logger.write(f"Opening {path} in {binary}")
    # Fire-and-forget: detach from our stdio and process group so the viewer
    # outlives this script without holding our pipes open.
    subprocess.Popen(
        [binary, path],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )
    return True


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

        if args.show:
            # Reuse an exported/meshed file for the viewer when one exists.
            hint = next(
                (p for p in args.export if os.path.splitext(p)[1].lower() in _VIEWABLE_EXTS),
                args.mesh_file if args.mesh else None,
            )
            show_model(hint)
    finally:
        gmsh.finalize()
