#!/usr/bin/env python3
"""Parametric rotor push horns built with the gmsh Python API.

Ported from ``CreateLowerPushHorn`` and ``CreateUpperPushHorn`` in
``CreateComponents.geo``.  Each horn is an inclined rod (tilted about the y-axis
by ``pushrod_angle``) carrying a clevis/eye joint at each end:

* The lower horn (``lph``) roots on the base plate, with a bored eye at the
  bottom and a slotted, bolted clevis tongue at the top.
* The upper horn (``uph``) hangs from the lower-swash plane, with a spherical
  socket at the top and a slotted, bored clevis at the bottom.

The two share their input location (on the ``base_radius`` circle at
``aoffset = 0``) and the final y-tilt; only the boolean recipe and the sign of
the tilt differ.
"""

import gmsh
import math
from typing import Dict, Iterable, Tuple

from . import cli
from .parameters import rotor_parameters, require_positive

FULL_CIRCLE = 2.0 * math.pi
PointRecords = Dict[str, Tuple[int, Tuple[float, float, float]]]


class _PushHornGeometry:
    """Shared base for the lower/upper push horns."""

    model_name = "horn"
    physical_name = "PushHorn"
    joint_tag = "PH"
    tilt_sign = 1.0  # +1 tilts up (lower horn), -1 tilts down (upper horn)

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
            self.parameters,
            [
                "base_radius",
                "horn_length",
                "horn_base_radius",
                "horn_outer_radius",
                "horn_inner_radius",
                "horn_bolt_radius",
                "pushrod_sphere_radius",
            ],
        )

    def horn_location(self, p) -> Tuple[float, float, float]:
        """Return the (xloc, yloc, zloc) root of the horn (overridden for z)."""
        xloc = p["base_radius"] - p["link_length"] / 2.0  # aoffset = 0
        return xloc, 0.0, self.root_z(p)

    def root_z(self, p) -> float:
        """Return the z-level of the horn root (subclass-specific)."""
        raise NotImplementedError

    def build_horn(self, occ, p, loc) -> int:
        """Build the untilted horn solid; return its volume tag."""
        raise NotImplementedError

    def hinge_offset(self) -> float:
        """Signed z-offset (in units of horn_length) of the free hinge end."""
        raise NotImplementedError

    def build(self, model_name: str | None = None) -> Tuple[int, PointRecords]:
        """Construct the push horn and return the solid and hinge point."""
        name = model_name or self.model_name
        gmsh.model.add(name)
        gmsh.model.setCurrent(name)
        occ = gmsh.model.occ
        p = self.parameters

        loc = self.horn_location(p)
        horn = self.build_horn(occ, p, loc)

        # Tilt the finished horn about the y-axis through its root.
        angle = self.tilt_sign * p["pushrod_angle"]
        occ.rotate([(3, horn)], loc[0], loc[1], loc[2], 0.0, 1.0, 0.0, angle)

        translation = (p["xtrans"], p["ytrans"], p["ztrans"])
        if any(abs(c) > 1.0e-12 for c in translation):
            occ.translate([(3, horn)], *translation)

        # Free-end hinge centre: a point on the horn axis, tilted then shifted.
        reach = self.hinge_offset() * p["horn_length"]
        hinge = (
            loc[0] + reach * math.sin(angle) + translation[0],
            loc[1] + translation[1],
            loc[2] + reach * math.cos(angle) + translation[2],
        )
        point_records: PointRecords = {
            f"P_{self.joint_tag}_HINGE": (occ.addPoint(*hinge), hinge)
        }

        occ.synchronize()
        for label, record in point_records.items():
            gmsh.model.setEntityName(0, record[0], label)

        physical_tag = gmsh.model.addPhysicalGroup(3, [horn])
        gmsh.model.setPhysicalName(3, physical_tag, self.physical_name)

        return horn, point_records


class LowerPushHornGeometry(_PushHornGeometry):
    """Lower push horn rooted on the base plate (``lph``)."""

    model_name = "lph"
    physical_name = "LowerPushHorn"
    joint_tag = "LPH"
    tilt_sign = 1.0

    def root_z(self, p) -> float:
        return p["z_base"] + p["base_height"] / 2.0

    def hinge_offset(self) -> float:
        return 1.0  # free end at +horn_length (top)

    def build_horn(self, occ, p, loc) -> int:
        xloc, yloc, zloc = loc
        hbr = p["horn_base_radius"]
        ro = p["horn_outer_radius"]
        length = p["horn_length"]
        full = FULL_CIRCLE

        # Vertical body rod.
        body = occ.addCylinder(xloc, yloc, zloc, 0.0, 0.0, length, 0.99 * hbr, angle=full)

        # Bottom eye: a transverse (y) cylinder bored through with the inner bore.
        tail = occ.addCylinder(xloc, yloc - hbr, zloc, 0.0, 2.0 * hbr, 0.0, ro, angle=full)
        fused, _ = occ.fuse([(3, tail)], [(3, body)], removeObject=True, removeTool=True)
        horn = fused[0][1]
        bore = occ.addCylinder(
            xloc, yloc - hbr, zloc, 0.0, 2.0 * hbr, 0.0, p["horn_inner_radius"], angle=full
        )
        cut, _ = occ.cut([(3, horn)], [(3, bore)], removeObject=True, removeTool=True)
        horn = cut[0][1]

        # Top head: transverse cylinder, then trim its outer quarters to leave a
        # central clevis tongue, and add a bolt pin across it.
        ztop = zloc + length
        head = occ.addCylinder(xloc, yloc - hbr, ztop, 0.0, 2.0 * hbr, 0.0, ro, angle=full)
        fused, _ = occ.fuse([(3, head)], [(3, horn)], removeObject=True, removeTool=True)
        horn = fused[0][1]

        near = occ.addCylinder(xloc, yloc - hbr, ztop, 0.0, hbr / 2.0, 0.0, ro, angle=full)
        cut, _ = occ.cut([(3, horn)], [(3, near)], removeObject=True, removeTool=True)
        horn = cut[0][1]
        far = occ.addCylinder(xloc, yloc + hbr, ztop, 0.0, -hbr / 2.0, 0.0, ro, angle=full)
        cut, _ = occ.cut([(3, horn)], [(3, far)], removeObject=True, removeTool=True)
        horn = cut[0][1]

        bolt = occ.addCylinder(
            xloc, yloc + hbr, ztop, 0.0, -2.0 * hbr, 0.0, p["horn_bolt_radius"], angle=full
        )
        fused, _ = occ.fuse([(3, horn)], [(3, bolt)], removeObject=True, removeTool=True)
        return fused[0][1]


class UpperPushHornGeometry(_PushHornGeometry):
    """Upper push horn hanging from the lower-swash plane (``uph``)."""

    model_name = "uph"
    physical_name = "UpperPushHorn"
    joint_tag = "UPH"
    tilt_sign = -1.0

    def root_z(self, p) -> float:
        return p["z_lower_swash"] + p["lower_swash_height"] / 2.0

    def hinge_offset(self) -> float:
        return -1.0  # free end at -horn_length (bottom)

    def build_horn(self, occ, p, loc) -> int:
        xloc, yloc, zloc = loc
        hbr = p["horn_base_radius"]
        ro = p["horn_outer_radius"]
        length = p["horn_length"]
        full = FULL_CIRCLE

        # Body rod hanging downward, with a spherical socket head at the top.
        body = occ.addCylinder(xloc, yloc, zloc, 0.0, 0.0, -length, 0.99 * hbr, angle=full)
        head = occ.addCylinder(xloc, yloc - hbr, zloc, 0.0, 2.0 * hbr, 0.0, ro, angle=full)
        fused, _ = occ.fuse([(3, head)], [(3, body)], removeObject=True, removeTool=True)
        horn = fused[0][1]
        socket = occ.addSphere(xloc, yloc, zloc, p["pushrod_sphere_radius"])
        cut, _ = occ.cut([(3, horn)], [(3, socket)], removeObject=True, removeTool=True)
        horn = cut[0][1]

        # Bottom clevis: transverse cylinder with the central slot and bolt bore.
        zbot = zloc - length
        tail = occ.addCylinder(xloc, yloc - hbr, zbot, 0.0, 2.0 * hbr, 0.0, ro, angle=full)
        fused, _ = occ.fuse([(3, horn)], [(3, tail)], removeObject=True, removeTool=True)
        horn = fused[0][1]
        slot = occ.addCylinder(xloc, yloc - hbr / 2.0, zbot, 0.0, hbr, 0.0, ro, angle=full)
        cut, _ = occ.cut([(3, horn)], [(3, slot)], removeObject=True, removeTool=True)
        horn = cut[0][1]
        bore = occ.addCylinder(
            xloc, yloc - hbr, zbot, 0.0, 2.0 * hbr, 0.0, p["horn_bolt_radius"], angle=full
        )
        cut, _ = occ.cut([(3, horn)], [(3, bore)], removeObject=True, removeTool=True)
        return cut[0][1]


def _make_main(geometry_class, description: str):
    """Build a CLI ``main`` bound to one push-horn class."""

    def main(argv: Iterable[str] | None = None) -> None:
        cli.run(
            geometry_class,
            description=description,
            default_mesh_name=f"{geometry_class.model_name}.msh",
            model_name=geometry_class.model_name,
            argv=argv,
        )

    return main


main_lph = _make_main(LowerPushHornGeometry, "Construct the lower push horn using gmsh.")
main_uph = _make_main(UpperPushHornGeometry, "Construct the upper push horn using gmsh.")


def main(argv: Iterable[str] | None = None) -> None:
    """Default CLI entrypoint builds the lower push horn."""
    main_lph(argv)


if __name__ == "__main__":
    main()
