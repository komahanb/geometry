#!/usr/bin/env python3
"""Parametric rotor centre sphere built with the gmsh Python API.

Ported from ``CreateSphere`` in ``CreateComponents.geo``: the spherical bearing
ball at the shaft centre, with the shaft bore drilled out of it.  Only the
polar band (-pi/4, pi/4) of the sphere is generated, matching the legacy
partial ``Sphere()``.
"""

import gmsh
import math
from typing import Dict, Iterable, Tuple

from . import cli
from .parameters import rotor_parameters, require_positive

FULL_CIRCLE = 2.0 * math.pi
PointRecords = Dict[str, Tuple[int, Tuple[float, float, float]]]


class SphereGeometry:
    """Build the centre sphere (minus the shaft bore)."""

    model_name = "sphere"

    def __init__(self, parameters: Dict[str, float] | None = None) -> None:
        self.parameters = rotor_parameters(parameters)
        self.validate_parameters()

    @staticmethod
    def default_parameters() -> Dict[str, float]:
        """Return the baseline rotor parameter set."""
        return rotor_parameters(None)

    def validate_parameters(self) -> None:
        """Guard against dimensions that would crash gmsh."""
        require_positive(
            self.parameters, ["sphere_radius", "shaft_radius", "shaft_height"]
        )
        if self.parameters["shaft_radius"] >= self.parameters["sphere_radius"]:
            raise ValueError("shaft_radius must be smaller than sphere_radius")

    def build(self, model_name: str | None = None) -> Tuple[int, PointRecords]:
        """Construct the sphere and return the solid and key points."""
        name = model_name or self.model_name
        gmsh.model.add(name)
        gmsh.model.setCurrent(name)
        occ = gmsh.model.occ
        p = self.parameters

        cx = p["xo"] + p["x_sphere"]
        cy = p["yo"] + p["y_sphere"]
        cz = p["zo"] + p["z_sphere"]

        # Partial sphere band, then drill the shaft bore through it.
        ball = occ.addSphere(
            cx, cy, cz, p["sphere_radius"],
            angle1=-math.pi / 4.0, angle2=math.pi / 4.0, angle3=FULL_CIRCLE,
        )
        shaft = occ.addCylinder(
            p["xo"], p["yo"], p["zo"], 0.0, 0.0, p["shaft_height"],
            p["shaft_radius"], angle=FULL_CIRCLE,
        )
        bored, _ = occ.cut([(3, ball)], [(3, shaft)], removeObject=True, removeTool=True)
        sphere = bored[0][1]

        translation = (p["xtrans"], p["ytrans"], p["ztrans"])
        if any(abs(c) > 1.0e-12 for c in translation):
            occ.translate([(3, sphere)], *translation)

        occ.synchronize()

        physical_tag = gmsh.model.addPhysicalGroup(3, [sphere])
        gmsh.model.setPhysicalName(3, physical_tag, "Sphere")

        return sphere, {}


def main(argv: Iterable[str] | None = None) -> None:
    """CLI entrypoint for generating, exporting or meshing the sphere."""
    cli.run(
        SphereGeometry,
        description="Construct the rotor centre sphere using gmsh.",
        default_mesh_name="sphere.msh",
        model_name="sphere",
        argv=argv,
    )


if __name__ == "__main__":
    main()
