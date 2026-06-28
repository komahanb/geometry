#!/usr/bin/env python3
"""gmsh python loader for blade180.geo (auto-generated)."""

import argparse
import gmsh
import os
import sys

_DEF_MESH_DIM = 3


def _default_mesh_path(script_dir: str) -> str:
    return os.path.normpath(os.path.join(script_dir, '..', 'mesh', 'blade180.msh'))


def main(argv=None) -> None:
    if argv is None:
        argv = sys.argv[1:]

    parser = argparse.ArgumentParser(
        description='Load geometry defined in blade180.geo using gmsh.')
    parser.add_argument('--mesh', action='store_true',
                        help='Generate a mesh after loading the geometry.')
    parser.add_argument('--mesh-dim', type=int, default=_DEF_MESH_DIM,
                        help='Mesh dimension to generate (default: 3).')
    parser.add_argument('--mesh-file',
                        help='Optional output path for the generated mesh; defaults to ../mesh/blade180.msh')
    parser.add_argument('--show', action='store_true',
                        help='Display the geometry/mesh in the gmsh GUI (requires FLTK).')
    args = parser.parse_args(argv)

    script_dir = os.path.dirname(os.path.abspath(__file__))
    geo_path = os.path.normpath(os.path.join(script_dir, '..', 'geo', 'blade180.geo'))

    if not os.path.exists(geo_path):
        raise FileNotFoundError('Cannot locate blade180.geo at %s' % geo_path)

    gmsh.initialize()
    gmsh.option.setNumber('General.Terminal', 1)
    try:
        gmsh.open(geo_path)
        if args.mesh:
            mesh_dim = args.mesh_dim if 0 < args.mesh_dim <= 3 else _DEF_MESH_DIM
            gmsh.model.mesh.generate(mesh_dim)
            mesh_path = args.mesh_file or _default_mesh_path(script_dir)
            mesh_dir = os.path.dirname(mesh_path)
            if mesh_dir and not os.path.exists(mesh_dir):
                os.makedirs(mesh_dir, exist_ok=True)
            gmsh.write(mesh_path)

        if args.show and hasattr(gmsh, 'fltk') and gmsh.fltk.isAvailable():
            gmsh.fltk.initialize()
            gmsh.fltk.run()
    finally:
        gmsh.finalize()


if __name__ == '__main__':
    main()
