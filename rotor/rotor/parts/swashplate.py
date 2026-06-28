#!/usr/bin/env python3
"""Parametric rotor swash plates built with the gmsh Python API.

Ported from ``CreateDoubleUpperSwashPlate``, ``CreateFourUpperSwashPlate`` and
``CreateLowerSwashPlate`` in ``CreateComponents.geo``.  All three are the same
body: a central disc carrying one or more radial connector arms, each arm a
notched connecting plate fused to a y-aligned link cylinder capped with a
spherical ball joint, with a shallow spherical recess scooped out of the disc
centre.  The variants differ only in which radius/height parameters they use
and how many arms they carry (and at what azimuths), so they share a single
build recipe and override a handful of class attributes:

* ``DoubleUpperSwashPlateGeometry`` (``usp2b``) -- two arms 180 deg apart.
* ``FourUpperSwashPlateGeometry`` (``usp4b``) -- four arms 90 deg apart.
* ``LowerSwashPlateGeometry`` (``lsp``) -- four arms 90 deg apart, on the
  larger base radius.
"""

import gmsh
import math
from typing import Dict, Iterable, List, Tuple

from . import cli
from .parameters import rotor_parameters, require_positive

FULL_CIRCLE = 2.0 * math.pi
PointRecords = Dict[str, Tuple[int, Tuple[float, float, float]]]


class _SwashPlateGeometry:
    """Shared builder for the rotor swash plates.

    Subclasses set the geometry keys (arm radius, plate radius, height and the
    ``x_/y_/z_`` centre prefix), the azimuth of the reference arm and the
    additional copy azimuths.  Everything else -- the arm recipe, the spherical
    recess and the optional rigid translation -- is common.
    """

    # Overridden per concrete swash plate.
    model_name: str = "swash"
    physical_name: str = "SwashPlate"
    joint_tag: str = "SWASH"
    radial_key: str = "base_radius"
    plate_radius_key: str = "lower_swash_radius"
    height_key: str = "lower_swash_height"
    swash_prefix: str = "lower_swash"
    base_angle_key: str | None = None  # azimuth of the reference arm, if any
    copy_angle_factors: Tuple[float, ...] = ()  # extra arm azimuths, in units of pi

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
                self.radial_key,
                self.plate_radius_key,
                self.height_key,
                "swash_connplate_length",
                "link_length",
                "link_radius",
                "pushrod_sphere_radius",
                "sphere_radius",
            ],
        )

    def _build_unit(self, occ, p) -> Tuple[int, Tuple[float, float, float]]:
        """Build one arm fused to the central disc; return it and the ball joint.

        Mirrors the per-arm block of the legacy functions: a connecting plate
        with a square notch, a transverse link cylinder topped by a spherical
        ball, all fused onto the central cylindrical disc.
        """
        radial = p[self.radial_key]
        height = p[self.height_key]
        link_length = p["link_length"]
        x_swash = p[f"x_{self.swash_prefix}"]
        y_swash = p[f"y_{self.swash_prefix}"]
        z_swash = p[f"z_{self.swash_prefix}"]

        # Connecting plate block, centred on y about the disc centre.
        plate_dy = p["swash_connplate_length"]
        block = occ.addBox(
            x_swash, y_swash - plate_dy / 2.0, z_swash, radial, plate_dy, height
        )

        # Square notch cut from the plate where the link will seat.
        notch = occ.addBox(
            radial,
            link_length / 2.0,
            z_swash,
            -link_length,
            -link_length,
            height,
        )
        cut, _ = occ.cut([(3, block)], [(3, notch)], removeObject=True, removeTool=True)
        arm = cut[0][1]

        # Link cylinder (y-aligned) capped with a spherical ball joint.
        xlink = radial - link_length / 2.0
        ylink = -link_length / 2.0
        zlink = z_swash + height / 2.0
        link = occ.addCylinder(
            xlink, ylink, zlink, 0.0, link_length, 0.0, p["link_radius"], angle=FULL_CIRCLE
        )
        ball_centre = (xlink, ylink + link_length / 2.0, zlink)
        ball = occ.addSphere(*ball_centre, p["pushrod_sphere_radius"])
        link_fused, _ = occ.fuse(
            [(3, link)], [(3, ball)], removeObject=True, removeTool=True
        )
        arm_fused, _ = occ.fuse(
            [(3, arm)], [(3, link_fused[0][1])], removeObject=True, removeTool=True
        )
        arm = arm_fused[0][1]

        # Central cylindrical disc.  The legacy carves (arm - disc) then unites
        # it back onto the disc ((A-B) u B); that is just a fuse but leaves a
        # coincident internal face in OCC that breaks 3D meshing, so a single
        # fuse gives the same solid cleanly.
        disc = occ.addCylinder(
            x_swash,
            y_swash,
            z_swash,
            0.0,
            0.0,
            height,
            p[self.plate_radius_key],
            angle=FULL_CIRCLE,
        )
        unit_fused, _ = occ.fuse(
            [(3, arm)], [(3, disc)], removeObject=True, removeTool=True
        )
        return unit_fused[0][1], ball_centre

    def build(self, model_name: str | None = None) -> Tuple[int, PointRecords]:
        """Construct the swash plate and return the solid and key points."""
        name = model_name or self.model_name
        gmsh.model.add(name)
        gmsh.model.setCurrent(name)
        occ = gmsh.model.occ
        p = self.parameters

        xo, yo, zo = p["xo"], p["yo"], p["zo"]
        base_angle = p[self.base_angle_key] if self.base_angle_key else 0.0
        copy_angles = [factor * math.pi for factor in self.copy_angle_factors]

        # One arm fused to the disc, then orient the whole reference unit.
        unit, ball_centre = self._build_unit(occ, p)
        if abs(base_angle) > 1.0e-12:
            occ.rotate([(3, unit)], xo, yo, zo, 0.0, 0.0, 1.0, base_angle)

        # Duplicate the reference unit to the remaining arm azimuths and fuse
        # everything into a single solid plate.
        plate = unit
        for angle in copy_angles:
            copy = occ.copy([(3, unit)])
            occ.rotate(copy, xo, yo, zo, 0.0, 0.0, 1.0, angle)
            fused, _ = occ.fuse(
                [(3, plate)], [copy[0]], removeObject=True, removeTool=True
            )
            plate = fused[0][1]

        # Scoop the shallow spherical recess out of the disc centre.  The polar
        # span (-pi/4, pi/4) matches the legacy partial Sphere() that cuts only
        # a spherical band rather than a full ball.
        recess = occ.addSphere(
            p["x_sphere"],
            p["y_sphere"],
            p["z_sphere"],
            p["sphere_radius"],
            angle1=-math.pi / 4.0,
            angle2=math.pi / 4.0,
            angle3=FULL_CIRCLE,
        )
        bored, _ = occ.cut([(3, plate)], [(3, recess)], removeObject=True, removeTool=True)
        plate = bored[0][1]

        translation = (p["xtrans"], p["ytrans"], p["ztrans"])
        if any(abs(c) > 1.0e-12 for c in translation):
            occ.translate([(3, plate)], *translation)

        # Ball-joint constraint points: the reference arm plus each copy, with
        # the same rigid translation applied so they track the solid.
        point_records: PointRecords = {}
        for index, angle in enumerate([base_angle] + [base_angle + a for a in copy_angles]):
            joint = _rotate_z(ball_centre, (xo, yo, zo), angle)
            joint = (
                joint[0] + translation[0],
                joint[1] + translation[1],
                joint[2] + translation[2],
            )
            point_records[f"P_{self.joint_tag}_JOINT_{index}"] = (
                occ.addPoint(*joint),
                joint,
            )

        occ.synchronize()
        for name, record in point_records.items():
            gmsh.model.setEntityName(0, record[0], name)

        physical_tag = gmsh.model.addPhysicalGroup(3, [plate])
        gmsh.model.setPhysicalName(3, physical_tag, self.physical_name)

        return plate, point_records


def _rotate_z(
    point: Tuple[float, float, float],
    origin: Tuple[float, float, float],
    angle: float,
) -> Tuple[float, float, float]:
    """Rotate ``point`` about the z-axis through ``origin`` by ``angle``."""
    dx = point[0] - origin[0]
    dy = point[1] - origin[1]
    cos_a, sin_a = math.cos(angle), math.sin(angle)
    return (
        origin[0] + dx * cos_a - dy * sin_a,
        origin[1] + dx * sin_a + dy * cos_a,
        point[2],
    )


class DoubleUpperSwashPlateGeometry(_SwashPlateGeometry):
    """Upper swash plate with two arms 180 degrees apart (``usp2b``)."""

    model_name = "usp2b"
    physical_name = "DoubleUpperSwashPlate"
    joint_tag = "USP"
    radial_key = "uswash_outer_radius"
    plate_radius_key = "upper_swash_radius"
    height_key = "upper_swash_height"
    swash_prefix = "upper_swash"
    base_angle_key = "upper_swash_angle"
    copy_angle_factors = (1.0,)  # +180 deg


class FourUpperSwashPlateGeometry(_SwashPlateGeometry):
    """Upper swash plate with four arms 90 degrees apart (``usp4b``)."""

    model_name = "usp4b"
    physical_name = "FourUpperSwashPlate"
    joint_tag = "USP"
    radial_key = "uswash_outer_radius"
    plate_radius_key = "upper_swash_radius"
    height_key = "upper_swash_height"
    swash_prefix = "upper_swash"
    base_angle_key = "upper_swash_angle"
    copy_angle_factors = (1.0, 0.5, -0.5)  # +180, +90, -90 deg


class LowerSwashPlateGeometry(_SwashPlateGeometry):
    """Lower swash plate with four arms 90 degrees apart (``lsp``)."""

    model_name = "lsp"
    physical_name = "LowerSwashPlate"
    joint_tag = "LSP"
    radial_key = "base_radius"
    plate_radius_key = "lower_swash_radius"
    height_key = "lower_swash_height"
    swash_prefix = "lower_swash"
    base_angle_key = None  # reference arm sits at 0 deg
    copy_angle_factors = (0.5, 1.0, 1.5)  # +90, +180, +270 deg


def _make_main(geometry_class, description: str):
    """Build a CLI ``main`` bound to one swash-plate class."""

    def main(argv: Iterable[str] | None = None) -> None:
        cli.run(
            geometry_class,
            description=description,
            default_mesh_name=f"{geometry_class.model_name}.msh",
            model_name=geometry_class.model_name,
            argv=argv,
        )

    return main


main_usp2b = _make_main(
    DoubleUpperSwashPlateGeometry, "Construct the double upper swash plate using gmsh."
)
main_usp4b = _make_main(
    FourUpperSwashPlateGeometry, "Construct the four-arm upper swash plate using gmsh."
)
main_lsp = _make_main(
    LowerSwashPlateGeometry, "Construct the lower swash plate using gmsh."
)


def main(argv: Iterable[str] | None = None) -> None:
    """Default CLI entrypoint builds the four-arm upper swash plate."""
    main_usp4b(argv)


if __name__ == "__main__":
    main()
