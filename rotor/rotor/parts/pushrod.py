#!/usr/bin/env python3
"""Parametric rotor push rods built with the gmsh Python API.

Ported from ``CreatePushRod90/180/270`` in ``CreateComponents.geo``: a vertical
body cylinder rising from the base plate, capped by a transverse head cylinder
with a spherical socket that seats on the lower swash plate.  The three legacy
functions differ only in azimuth (and, incidentally, in whether they wrote the
head along x or y -- always the direction transverse to the radius), so they
collapse to one class parameterised by ``aoffset``.
"""

import gmsh
import math
from typing import Dict, Iterable, Tuple

from . import cli
from .parameters import rotor_parameters, require_positive

FULL_CIRCLE = 2.0 * math.pi
PointRecords = Dict[str, Tuple[int, Tuple[float, float, float]]]


class PushRodGeometry:
    """Build one push rod at a given azimuth using OpenCASCADE primitives."""

    model_name = "prod"
    aoffset = math.pi / 2.0  # azimuth of this push rod (radians)

    def __init__(self, parameters: Dict[str, float] | None = None) -> None:
        self.parameters = rotor_parameters(parameters)
        self.parameters.setdefault("aoffset", self.aoffset)
        self.validate_parameters()

    @classmethod
    def default_parameters(cls) -> Dict[str, float]:
        """Return the baseline rotor parameter set plus this rod's azimuth."""
        params = rotor_parameters(None)
        params["aoffset"] = cls.aoffset
        return params

    def validate_parameters(self) -> None:
        """Guard against dimensions that would crash gmsh."""
        require_positive(
            self.parameters,
            [
                "pushrod_roffset",
                "pushrod_height",
                "pushrod_base_radius",
                "pushrod_inner_radius",
                "pushrod_outer_radius",
                "pushrod_sphere_radius",
            ],
        )

    def build(self, model_name: str | None = None) -> Tuple[int, PointRecords]:
        """Construct the push rod and return the solid and key points."""
        name = model_name or self.model_name
        gmsh.model.add(name)
        gmsh.model.setCurrent(name)
        occ = gmsh.model.occ
        p = self.parameters

        aoffset = p["aoffset"]
        roffset = p["pushrod_roffset"]
        deg = int(round(math.degrees(aoffset))) % 360
        x_base, y_base = p["x_base"], p["y_base"]
        head_z = p["z_lower_swash"] + p["lower_swash_height"] / 2.0

        # Build every rod in the canonical aoffset=0 frame (radius along +x,
        # head transverse along y) and rotate the finished solid to its azimuth.
        # gmsh 4.x cannot mesh the periodic seam of a head cylinder aligned with
        # the world x-axis; constructing along y and rotating keeps the OCC seam
        # in the mesh-friendly position it travels with.
        cx = x_base + roffset
        cy = y_base

        # Vertical body cylinder rising from the base plate.
        body = occ.addCylinder(
            cx, cy, p["z_base"], 0.0, 0.0, p["pushrod_height"],
            p["pushrod_base_radius"], angle=FULL_CIRCLE,
        )

        # Transverse (y-aligned) head cylinder at the swash-plate plane.
        half = p["pushrod_inner_radius"]  # half of the 2*r_inner head length
        head = occ.addCylinder(
            cx, cy - half, head_z, 0.0, 2.0 * half, 0.0,
            p["pushrod_outer_radius"], angle=FULL_CIRCLE,
        )
        fused, _ = occ.fuse([(3, head)], [(3, body)], removeObject=True, removeTool=True)
        rod = fused[0][1]

        # Spherical socket punched into the head.
        socket = occ.addSphere(cx, cy, head_z, p["pushrod_sphere_radius"])
        bored, _ = occ.cut([(3, rod)], [(3, socket)], removeObject=True, removeTool=True)
        rod = bored[0][1]

        if abs(aoffset) > 1.0e-12:
            occ.rotate([(3, rod)], x_base, y_base, 0.0, 0.0, 0.0, 1.0, aoffset)

        translation = (p["xtrans"], p["ytrans"], p["ztrans"])
        if any(abs(c) > 1.0e-12 for c in translation):
            occ.translate([(3, rod)], *translation)

        # Constraint points: base-plate foot and swash-plate socket centre,
        # rotated/translated to match the placed solid.
        def place(z: float) -> Tuple[float, float, float]:
            dx, dy = cx - x_base, cy - y_base
            rx = x_base + dx * math.cos(aoffset) - dy * math.sin(aoffset)
            ry = y_base + dx * math.sin(aoffset) + dy * math.cos(aoffset)
            return (rx + translation[0], ry + translation[1], z + translation[2])

        foot = place(p["z_base"])
        socket_centre = place(head_z)
        point_records: PointRecords = {
            f"P_PROD{deg}_BSP": (occ.addPoint(*foot), foot),
            f"P_PROD{deg}_LSP": (occ.addPoint(*socket_centre), socket_centre),
        }

        occ.synchronize()
        for label, record in point_records.items():
            gmsh.model.setEntityName(0, record[0], label)

        physical_tag = gmsh.model.addPhysicalGroup(3, [rod])
        gmsh.model.setPhysicalName(3, physical_tag, f"PushRod{deg}")

        return rod, point_records


class PushRod90Geometry(PushRodGeometry):
    """Push rod at 90 degrees (``prod90``)."""

    model_name = "prod90"
    aoffset = math.pi / 2.0


class PushRod180Geometry(PushRodGeometry):
    """Push rod at 180 degrees (``prod180``)."""

    model_name = "prod180"
    aoffset = math.pi


class PushRod270Geometry(PushRodGeometry):
    """Push rod at 270 degrees (``prod270``)."""

    model_name = "prod270"
    aoffset = 3.0 * math.pi / 2.0


def _make_main(geometry_class, description: str):
    """Build a CLI ``main`` bound to one push-rod class."""

    def main(argv: Iterable[str] | None = None) -> None:
        cli.run(
            geometry_class,
            description=description,
            default_mesh_name=f"{geometry_class.model_name}.msh",
            model_name=geometry_class.model_name,
            argv=argv,
        )

    return main


main_prod90 = _make_main(PushRod90Geometry, "Construct the 90-degree push rod using gmsh.")
main_prod180 = _make_main(PushRod180Geometry, "Construct the 180-degree push rod using gmsh.")
main_prod270 = _make_main(PushRod270Geometry, "Construct the 270-degree push rod using gmsh.")


def main(argv: Iterable[str] | None = None) -> None:
    """Default CLI entrypoint builds the 90-degree push rod."""
    main_prod90(argv)


if __name__ == "__main__":
    main()
