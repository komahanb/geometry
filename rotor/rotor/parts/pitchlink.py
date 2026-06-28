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

    model_name = "lpl30"
    azimuth = 0.0  # extra placement rotation about the z-axis (radians)

    def __init__(self, parameters: Dict[str, float] | None = None) -> None:
        self.parameters = rotor_parameters(parameters)
        # Angular placement (radians): aoffset positions the socket on the
        # swash plate; theta rotates the whole link into its bay; azimuth then
        # places the assembled link at its bay angle (the lpl120/210/300
        # variants just add 90/180/270 degrees here).
        self.parameters.setdefault("aoffset", 0.0)
        self.parameters.setdefault("theta", self.parameters["upper_swash_angle"])
        self.parameters.setdefault("azimuth", self.azimuth)
        self.validate_parameters()

    @classmethod
    def default_parameters(cls) -> Dict[str, float]:
        """Return the baseline parameter set (rotor defaults + placement)."""
        params = rotor_parameters(None)
        params["aoffset"] = 0.0
        params["theta"] = params["upper_swash_angle"]
        params["azimuth"] = cls.azimuth
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

        # Joint centre at the rod top.  It lies on the vertical axis of the
        # in-build upper_swash_angle rotation, so that rotation leaves it fixed;
        # only the final azimuth/translation (applied below) move it.
        joint_local = (xloc, yloc, zloc + hrod)

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

        # Place the assembled link at its bay azimuth (lpl120/210/300).
        if abs(p["azimuth"]) > 1.0e-12:
            occ.rotate([(3, link)], p["xo"], p["yo"], p["zo"], 0.0, 0.0, 1.0, p["azimuth"])

        translation = (p["xtrans"], p["ytrans"], p["ztrans"])
        if any(abs(c) > 1.0e-12 for c in translation):
            occ.translate([(3, link)], *translation)

        # Place the joint point to match the solid: azimuth then translation.
        jx, jy, jz = joint_local
        az = p["azimuth"]
        dx, dy = jx - p["xo"], jy - p["yo"]
        joint = (
            p["xo"] + dx * math.cos(az) - dy * math.sin(az) + translation[0],
            p["yo"] + dx * math.sin(az) + dy * math.cos(az) + translation[1],
            jz + translation[2],
        )
        point_records: Dict[str, Tuple[int, Tuple[float, float, float]]] = {
            "P_PL_JOINT": (occ.addPoint(*joint), joint)
        }

        occ.synchronize()
        for name, record in point_records.items():
            gmsh.model.setEntityName(0, record[0], name)

        physical_tag = gmsh.model.addPhysicalGroup(3, [link])
        gmsh.model.setPhysicalName(3, physical_tag, "LowerPitchLink")

        return link, point_records


class LowerPitchLink120Geometry(PitchLinkGeometry):
    """Lower pitch link at the 120-degree bay (``lpl120``)."""

    model_name = "lpl120"
    azimuth = math.pi / 2.0


class LowerPitchLink210Geometry(PitchLinkGeometry):
    """Lower pitch link at the 210-degree bay (``lpl210``)."""

    model_name = "lpl210"
    azimuth = math.pi


class LowerPitchLink300Geometry(PitchLinkGeometry):
    """Lower pitch link at the 300-degree bay (``lpl300``)."""

    model_name = "lpl300"
    azimuth = 1.5 * math.pi


class UpperPitchLinkGeometry:
    """Build an upper pitch link using OpenCASCADE primitives.

    Ported from ``Function CreateUpperPitchLink``: a clevis socket on the upper
    swash plate joined by a slotted, bolted yoke to an x-aligned connector that
    bridges the hub and blade attachments.  The 30/120/210/300-degree bays
    (``upl30`` ... ``upl300``) come from the ``azimuth`` placement.
    """

    model_name = "upl30"
    azimuth = 0.0

    def __init__(self, parameters: Dict[str, float] | None = None) -> None:
        self.parameters = rotor_parameters(parameters)
        self.parameters.setdefault("theta", self.parameters["upper_swash_angle"])
        self.parameters.setdefault("azimuth", self.azimuth)
        self.validate_parameters()

    @classmethod
    def default_parameters(cls) -> Dict[str, float]:
        """Return the baseline parameter set plus this link's placement."""
        params = rotor_parameters(None)
        params["theta"] = params["upper_swash_angle"]
        params["azimuth"] = cls.azimuth
        return params

    def validate_parameters(self) -> None:
        """Guard against dimensions that would crash gmsh."""
        require_positive(
            self.parameters,
            [
                "uswash_outer_radius",
                "horn_base_radius",
                "horn_outer_radius",
                "horn_bolt_radius",
                "hub_blade_conn_length",
            ],
        )

    def build(self, model_name: str | None = None) -> Tuple[
        int, Dict[str, Tuple[int, Tuple[float, float, float]]]
    ]:
        """Construct the upper pitch link and return the solid and key point."""
        name = model_name or self.model_name
        gmsh.model.add(name)
        gmsh.model.setCurrent(name)
        occ = gmsh.model.occ
        p = self.parameters
        full = 2.0 * math.pi
        hbr = p["horn_base_radius"]
        rad = 3.0 * hbr

        # Clevis socket centre on the upper swash plate, rotated into its bay.
        theta = p["theta"]
        x = p["uswash_outer_radius"] - p["link_length"] / 2.0  # aoffset = 0
        xloc = x * math.cos(theta)
        yloc = x * math.sin(theta) + p["horn_outer_radius"]
        zloc = p["z_blade"]

        # Yoke cylinder reaching down toward the blade plane.
        dy = yloc - p["y_blade"]
        yoke = occ.addCylinder(xloc, yloc, zloc, 0.0, -dy, 0.0, rad, angle=full)

        # Cut the hinge slot, then add the transverse bolt pin.
        slot = occ.addBox(
            xloc - 2.0 * hbr, yloc, zloc - 3.0 * hbr,
            4.0 * hbr, -5.0 * hbr, 6.0 * hbr,
        )
        cut, _ = occ.cut([(3, yoke)], [(3, slot)], removeObject=True, removeTool=True)
        link = cut[0][1]
        bolt = occ.addCylinder(
            xloc - 2.0 * hbr, yloc - 2.0 * hbr, zloc,
            4.0 * hbr, 0.0, 0.0, p["horn_bolt_radius"], angle=full,
        )
        fused, _ = occ.fuse([(3, link)], [(3, bolt)], removeObject=True, removeTool=True)
        link = fused[0][1]

        # x-aligned hub-to-blade connector welded on (legacy (A-B) u B = fuse).
        conn = occ.addCylinder(
            p["hub_radius"] + p["hub_conn_length"], p["y_blade"], p["z_blade"],
            p["hub_blade_conn_length"], 0.0, 0.0, rad, angle=full,
        )
        fused, _ = occ.fuse([(3, link)], [(3, conn)], removeObject=True, removeTool=True)
        link = fused[0][1]

        if abs(p["azimuth"]) > 1.0e-12:
            occ.rotate([(3, link)], p["xo"], p["yo"], p["zo"], 0.0, 0.0, 1.0, p["azimuth"])

        translation = (p["xtrans"], p["ytrans"], p["ztrans"])
        if any(abs(c) > 1.0e-12 for c in translation):
            occ.translate([(3, link)], *translation)

        # Swash-side joint point, placed to match the solid.
        az = p["azimuth"]
        dx, dyj = xloc - p["xo"], yloc - p["yo"]
        joint = (
            p["xo"] + dx * math.cos(az) - dyj * math.sin(az) + translation[0],
            p["yo"] + dx * math.sin(az) + dyj * math.cos(az) + translation[1],
            zloc + translation[2],
        )
        point_records = {"P_UPL_JOINT": (occ.addPoint(*joint), joint)}

        occ.synchronize()
        for label, record in point_records.items():
            gmsh.model.setEntityName(0, record[0], label)

        physical_tag = gmsh.model.addPhysicalGroup(3, [link])
        gmsh.model.setPhysicalName(3, physical_tag, "UpperPitchLink")

        return link, point_records


class UpperPitchLink120Geometry(UpperPitchLinkGeometry):
    """Upper pitch link at the 120-degree bay (``upl120``)."""

    model_name = "upl120"
    azimuth = math.pi / 2.0


class UpperPitchLink210Geometry(UpperPitchLinkGeometry):
    """Upper pitch link at the 210-degree bay (``upl210``)."""

    model_name = "upl210"
    azimuth = math.pi


class UpperPitchLink300Geometry(UpperPitchLinkGeometry):
    """Upper pitch link at the 300-degree bay (``upl300``)."""

    model_name = "upl300"
    azimuth = 1.5 * math.pi


def _make_main(geometry_class, description: str):
    """Build a CLI ``main`` bound to one pitch-link class."""

    def main(argv: Iterable[str] | None = None) -> None:
        cli.run(
            geometry_class,
            description=description,
            default_mesh_name=f"{geometry_class.model_name}.msh",
            model_name=geometry_class.model_name,
            argv=argv,
        )

    return main


main_lpl30 = _make_main(PitchLinkGeometry, "Construct the lower pitch link using gmsh.")
main_lpl120 = _make_main(LowerPitchLink120Geometry, "Construct the 120-degree lower pitch link.")
main_lpl210 = _make_main(LowerPitchLink210Geometry, "Construct the 210-degree lower pitch link.")
main_lpl300 = _make_main(LowerPitchLink300Geometry, "Construct the 300-degree lower pitch link.")
main_upl30 = _make_main(UpperPitchLinkGeometry, "Construct the upper pitch link using gmsh.")
main_upl120 = _make_main(UpperPitchLink120Geometry, "Construct the 120-degree upper pitch link.")
main_upl210 = _make_main(UpperPitchLink210Geometry, "Construct the 210-degree upper pitch link.")
main_upl300 = _make_main(UpperPitchLink300Geometry, "Construct the 300-degree upper pitch link.")


def main(argv: Iterable[str] | None = None) -> None:
    """Default CLI entrypoint builds the lower pitch link."""
    main_lpl30(argv)


if __name__ == "__main__":
    main()
