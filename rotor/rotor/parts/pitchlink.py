#!/usr/bin/env python3
"""Parametric rotor pitch link built with the gmsh Python API.

Ported from ``Function CreateLowerPitchLink`` in ``CreateComponents.geo``: a
slender rod with a transverse cylindrical head carrying a spherical socket at
one end, and a bolted male clevis at the other.  The ``aoffset`` and ``theta``
angles place and orient the link, so the 30/120/210/300-degree variants
(``lpl30`` ... ``lpl300``) are obtained from this one class by override.
"""

import gmsh
import math
from typing import Dict, Iterable, Tuple

from . import cli
from .parameters import rotor_parameters, require_positive


class PitchLinkGeometry:
    """Build a lower pitch link using OpenCASCADE primitives."""

    def __init__(self, parameters: Dict[str, float] | None = None) -> None:
        self.parameters = rotor_parameters(parameters)
        # Angular placement (radians): aoffset positions the socket on the
        # swash plate; theta rotates the whole link into its bay.
        self.parameters.setdefault("aoffset", 0.0)
        self.parameters.setdefault("theta", self.parameters["upper_swash_angle"])
        self.validate_parameters()

    @staticmethod
    def default_parameters() -> Dict[str, float]:
        """Return the baseline parameter set (rotor defaults + placement)."""
        params = rotor_parameters(None)
        params["aoffset"] = 0.0
        params["theta"] = params["upper_swash_angle"]
        return params

    def validate_parameters(self) -> None:
        """Guard against dimensions that would crash gmsh."""
        require_positive(
            self.parameters,
            [
                "pitchlink_length",
                "horn_base_radius",
                "horn_outer_radius",
                "horn_bolt_radius",
                "pitchlink_sphere_radius",
            ],
        )

    def build(
        self, model_name: str = "lpl30"
    ) -> Tuple[int, Dict[str, Tuple[int, Tuple[float, float, float]]]]:
        """Construct the pitch link and return the solid and key points."""
        gmsh.model.add(model_name)
        gmsh.model.setCurrent(model_name)
        occ = gmsh.model.occ
        p = self.parameters

        aoffset = p["aoffset"]
        theta = p["theta"]
        full = 2.0 * math.pi

        # Socket centre on the upper swash plate, rotated into the link bay.
        x = p["uswash_outer_radius"] * math.cos(aoffset) - p["link_length"] / 2.0
        y = p["uswash_outer_radius"] * math.sin(aoffset)
        z = p["z_upper_swash"] + p["upper_swash_height"] / 2.0
        xloc = x * math.cos(theta) - y * math.sin(theta)
        yloc = x * math.sin(theta) + y * math.cos(theta)
        zloc = z

        hrod = p["pitchlink_length"]
        rrod = 0.99 * p["horn_base_radius"]

        point_records: Dict[str, Tuple[int, Tuple[float, float, float]]] = {}
        joint = (xloc, yloc, zloc + hrod)
        point_records["P_PL_JOINT"] = (occ.addPoint(*joint), joint)

        # Rod body (z-aligned) and transverse head cylinder (y-aligned).
        body = occ.addCylinder(xloc, yloc, zloc, 0.0, 0.0, hrod, rrod, angle=full)
        head = occ.addCylinder(
            xloc,
            yloc - p["horn_base_radius"],
            zloc,
            0.0,
            2.0 * p["horn_base_radius"],
            0.0,
            p["horn_outer_radius"],
            angle=full,
        )
        fused, _ = occ.fuse([(3, head)], [(3, body)], removeObject=True, removeTool=True)
        link = fused[0][1]

        # Punch the spherical socket through the head.
        socket = occ.addSphere(xloc, yloc, zloc, p["pitchlink_sphere_radius"])
        cut, _ = occ.cut([(3, link)], [(3, socket)], removeObject=True, removeTool=True)
        link = cut[0][1]

        # Align the link with the base.
        occ.rotate([(3, link)], xloc, yloc, zloc, 0.0, 0.0, 1.0, p["upper_swash_angle"])

        # Male clevis head (x-aligned) at the far end of the rod.  The legacy
        # cuts the cylinder out and immediately unites it back ((A-B) u B),
        # which is just a fuse but leaves a coincident internal face in OCC
        # that breaks 3D meshing; a single fuse gives the same solid cleanly.
        male = occ.addCylinder(
            xloc - p["horn_base_radius"],
            yloc,
            zloc + p["pitchlink_length"],
            2.0 * p["horn_base_radius"],
            0.0,
            0.0,
            p["horn_outer_radius"],
            angle=full,
        )
        welded, _ = occ.fuse([(3, link)], [(3, male)], removeObject=True, removeTool=True)
        link = welded[0][1]

        # Drill the clevis bolt hole.
        bolt = occ.addCylinder(
            xloc - 2.0 * p["horn_base_radius"],
            yloc,
            zloc + p["pitchlink_length"],
            2.0 * 2.0 * p["horn_base_radius"],
            0.0,
            0.0,
            p["horn_bolt_radius"],
            angle=full,
        )
        bored, _ = occ.cut([(3, link)], [(3, bolt)], removeObject=True, removeTool=True)
        link = bored[0][1]

        translation = (p["xtrans"], p["ytrans"], p["ztrans"])
        if any(abs(c) > 1.0e-12 for c in translation):
            occ.translate([(3, link)], *translation)

        occ.synchronize()
        for name, record in point_records.items():
            gmsh.model.setEntityName(0, record[0], name)

        physical_tag = gmsh.model.addPhysicalGroup(3, [link])
        gmsh.model.setPhysicalName(3, physical_tag, "LowerPitchLink")

        return link, point_records


def main(argv: Iterable[str] | None = None) -> None:
    """CLI entrypoint for generating, exporting or meshing the pitch link."""
    cli.run(
        PitchLinkGeometry,
        description="Construct a rotor pitch link using gmsh.",
        default_mesh_name="lpl30.msh",
        model_name="lpl30",
        argv=argv,
    )


if __name__ == "__main__":
    main()
