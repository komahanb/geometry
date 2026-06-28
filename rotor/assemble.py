#!/usr/bin/env python3
"""Worked example: assemble the full four-blade rotor from ``rotor.parts``.

Every part builds in its own gmsh model (``build()`` calls ``model.add`` /
``setCurrent``), so the assembly is produced the same way as the legacy
``brep/assemble.geo``: export each component to BREP, then merge the BREPs into
one model.  The component list mirrors ``four_blade_assembly.geo``.

Run from the ``rotor/`` directory so the ``rotor`` package is importable::

    python assemble.py --out /tmp/rotor.brep         # merged geometry only
    python assemble.py --out /tmp/rotor.step         # STEP instead (by ext)
    python assemble.py --breps /tmp/rotor_parts/     # also keep per-part BREPs
    python assemble.py --param cutout_radius=0.5 ... # override any parameter
    python assemble.py --mesh --out /tmp/rotor.msh   # 3-D mesh (slow!)
    python assemble.py --show                        # FLTK viewer

Programmatic use::

    import gmsh
    from assemble import assemble, FOUR_BLADE_ROTOR
    gmsh.initialize()
    solids = assemble(FOUR_BLADE_ROTOR)   # -> list of (dim, tag) in "assembly"
    gmsh.write("rotor.brep")
    gmsh.finalize()
"""

import argparse
import os
import sys
import tempfile

import gmsh

# Make the rotor package importable when run directly from rotor/.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from rotor.parts import create_part
from rotor.parts.cli import (
    configure_mesh_options,
    parse_parameter_overrides,
)

# The 26 components of the four-blade rotor, in the order of
# four_blade_assembly.geo (structural bodies first, then blades and links).
FOUR_BLADE_ROTOR = [
    "baseplate", "hub4b", "sphere", "lsp", "usp4b",
    "prod90", "prod180", "prod270", "lph", "uph",
    "blade", "blade90", "blade180", "blade270",
    "bcap0", "bcap90", "bcap180", "bcap270",
    "pitchlink", "lpl120", "lpl210", "lpl300",
    "upl30", "upl120", "upl210", "upl300",
]


def export_breps(parts, out_dir, overrides=None):
    """Build each part in its own model and write ``out_dir/<part>.brep``.

    Returns the list of written BREP paths (one per part).
    """
    os.makedirs(out_dir, exist_ok=True)
    paths = []
    for name in parts:
        create_part(name, overrides).build()   # builds + sets its own model
        gmsh.model.occ.synchronize()
        path = os.path.join(out_dir, f"{name}.brep")
        gmsh.write(path)                        # writes the current (part) model
        paths.append(path)
    return paths


def assemble(parts=FOUR_BLADE_ROTOR, overrides=None, brep_dir=None):
    """Build all parts and merge them into a single ``assembly`` model.

    With ``brep_dir`` the per-part BREPs are kept there; otherwise a temporary
    directory is used and discarded.  Returns the assembly's solid dim-tags.
    """
    keep = brep_dir is not None
    work_dir = brep_dir or tempfile.mkdtemp(prefix="rotor_asm_")
    paths = []
    try:
        paths = export_breps(parts, work_dir, overrides)
        gmsh.model.add("assembly")
        gmsh.model.setCurrent("assembly")
        for path in paths:
            gmsh.merge(path)
        gmsh.model.occ.synchronize()
        return gmsh.model.getEntities(3)
    finally:
        if not keep:
            for path in paths:
                if os.path.exists(path):
                    os.remove(path)
            if os.path.isdir(work_dir):
                os.rmdir(work_dir)


def main(argv=None):
    """CLI entrypoint for the worked assembly example."""
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--out", metavar="PATH",
                        help="Write the merged assembly (format from the "
                             "extension: .brep/.step/.msh/.bdf).")
    parser.add_argument("--breps", metavar="DIR",
                        help="Keep the per-part BREPs in DIR.")
    parser.add_argument("--mesh", action="store_true",
                        help="3-D mesh the merged assembly (slow).")
    parser.add_argument("--param", action="append", default=[], metavar="NAME=VALUE",
                        help="Override a geometry parameter (repeatable).")
    parser.add_argument("--show", action="store_true",
                        help="Open the FLTK viewer on the assembly.")
    args = parser.parse_args(argv if argv is not None else sys.argv[1:])

    overrides = parse_parameter_overrides(args.param) or None

    gmsh.initialize()
    gmsh.option.setNumber("General.Terminal", 1)
    try:
        configure_mesh_options()
        solids = assemble(FOUR_BLADE_ROTOR, overrides, brep_dir=args.breps)
        gmsh.logger.write(
            f"Assembled {len(FOUR_BLADE_ROTOR)} parts -> {len(solids)} solids"
        )
        if args.mesh:
            gmsh.model.mesh.generate(3)
        if args.out:
            directory = os.path.dirname(args.out)
            if directory and not os.path.exists(directory):
                os.makedirs(directory, exist_ok=True)
            gmsh.write(args.out)
        if args.show and hasattr(gmsh, "fltk") and gmsh.fltk.isAvailable():
            gmsh.fltk.initialize()
            gmsh.fltk.run()
    finally:
        gmsh.finalize()


if __name__ == "__main__":
    main()
