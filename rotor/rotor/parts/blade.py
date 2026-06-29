#!/usr/bin/env python3
"""Parametric rotor blade built with the gmsh Python API.

Ported from ``Function CreateBladeX`` in ``CreateComponents.geo``: a NACA-4
airfoil section (see :mod:`rotor.parts.airfoil`) laid in the chord/thickness
plane, rotated flat and extruded spanwise from the tip to the root cutout to
form the blade solid.  ``CreateBladeX`` applies no aerodynamic twist (a
straight extrusion), and this port keeps that behaviour.

The 90/180/270-degree blades differ only by an azimuthal rotation, so they can
be produced from this class via the ``azimuth`` parameter.
"""

import gmsh
import math
from typing import Dict, Iterable, Tuple

from . import cli
from .airfoil import naca4_profile, naca4_blunt_profile
from .parameters import rotor_parameters, require_positive


class BladeGeometry:
    """Build a rotor blade using an extruded NACA-4 section."""

    model_name = "blade0"
    azimuth = 0.0  # blade azimuthal placement (radians)
    profile_builder = staticmethod(naca4_profile)
    physical_name = "Blade"

    def __init__(self, parameters: Dict[str, float] | None = None) -> None:
        self.parameters = rotor_parameters(parameters)
        for key, value in self.blade_defaults().items():
            self.parameters.setdefault(key, value)
        self.validate_parameters()

    @classmethod
    def blade_defaults(cls) -> Dict[str, float]:
        """Blade-specific defaults hard-coded in ``CreateBladeX``."""
        return {
            "blade_chord": 0.121,
            "blade_r_cutout": 0.44,
            "blade_tip_radius": 2.0,
            "blade_cl": 0.01,
            "blade_thickness": 12.0,  # percent of chord
            "blade_nspl": 4,
            "blade_pps": 5,
            "azimuth": cls.azimuth,  # blade azimuthal placement (radians)
        }

    @classmethod
    def default_parameters(cls) -> Dict[str, float]:
        """Return the baseline rotor + blade parameter set."""
        params = rotor_parameters(None)
        params.update(cls.blade_defaults())
        return params

    def validate_parameters(self) -> None:
        """Guard against dimensions that would crash gmsh."""
        require_positive(
            self.parameters,
            ["blade_chord", "blade_tip_radius", "blade_cl"],
        )
        if self.parameters["blade_tip_radius"] <= self.parameters["blade_r_cutout"]:
            raise ValueError("blade_tip_radius must exceed blade_r_cutout")

    def build(
        self, model_name: str = "blade0"
    ) -> Tuple[int, Dict[str, Tuple[int, Tuple[float, float, float]]]]:
        """Construct the blade and return the solid and key points."""
        gmsh.model.add(model_name)
        gmsh.model.setCurrent(model_name)
        occ = gmsh.model.occ
        p = self.parameters

        chord = p["blade_chord"]
        r_cutout = p["blade_r_cutout"]
        tip_radius = p["blade_tip_radius"]
        cl = p["blade_cl"]

        section = {
            "nspl": p["blade_nspl"],
            "pps": p["blade_pps"],
            "th": p["blade_thickness"],
            "ch": chord,
            "le_x": -chord / 2.0,
            "le_y": 0.0,
            "le_z": tip_radius,  # span station at the tip
            "z_blade": p["z_blade"],
            "cl": cl,
        }

        # Airfoil section in the chord/thickness plane at the tip station.
        surface, _loop = self.profile_builder(occ, section)

        # Fold the azimuthal placement into the pre-extrude orientation: lay the
        # section flat (-90 deg) AND rotate it to its bay angle in one step, then
        # extrude along the matching (azimuth-rotated) span vector.  Rotating the
        # *extruded* volume afterwards instead drops gmsh's structured-extrude
        # mesh and explodes the rotated blades to millions of tets; building the
        # structured extrude directly in the final orientation is geometrically
        # identical (a rotated extrusion = extruding the rotated section along
        # the rotated vector) but keeps the clean recombined mesh.
        azimuth = p["azimuth"]
        occ.rotate(
            [(2, surface)],
            p["xo"],
            p["yo"],
            p["zo"],
            0.0,
            0.0,
            1.0,
            -math.pi / 2.0 + azimuth,
        )

        # Extrude spanwise from tip toward the root cutout (the -x span vector
        # rotated by the azimuth).
        num_layers = max(int(round((tip_radius - r_cutout) / cl)), 1)
        span = r_cutout - tip_radius
        extruded = occ.extrude(
            [(2, surface)],
            span * math.cos(azimuth),
            span * math.sin(azimuth),
            0.0,
            numElements=[num_layers],
            recombine=True,
        )
        blade = next(tag for dim, tag in extruded if dim == 3)

        translation = (p["xtrans"], p["ytrans"], p["ztrans"])
        if any(abs(c) > 1.0e-12 for c in translation):
            occ.translate([(3, blade)], *translation)

        occ.synchronize()

        physical_tag = gmsh.model.addPhysicalGroup(3, [blade])
        gmsh.model.setPhysicalName(3, physical_tag, self.physical_name)

        return blade, {}


class Blade90Geometry(BladeGeometry):
    """Blade at 90 degrees (``blade90`` -> ``CreateBladeY``)."""

    model_name = "blade90"
    azimuth = math.pi / 2.0
    physical_name = "Blade90"


class Blade180Geometry(BladeGeometry):
    """Blade at 180 degrees (``blade180`` -> ``CreateBladeNegativeX``)."""

    model_name = "blade180"
    azimuth = math.pi
    physical_name = "Blade180"


class Blade270Geometry(BladeGeometry):
    """Blade at 270 degrees (``blade270`` -> ``CreateBladeNegativeY``)."""

    model_name = "blade270"
    azimuth = -math.pi / 2.0
    physical_name = "Blade270"


class BluntBladeGeometry(BladeGeometry):
    """Blade with a blunt trailing edge (``blade_blunt``).

    The rotor model's ``geo/blade_blunt.geo`` called an undefined
    ``CreateBladeBluntEdge``; this reuses the blade build with the blunt
    trailing-edge section from :func:`rotor.parts.airfoil.naca4_blunt_profile`
    (see the standalone ``blunt_blade/`` design).
    """

    model_name = "blade_blunt"
    profile_builder = staticmethod(naca4_blunt_profile)
    physical_name = "BluntBlade"


def _make_main(geometry_class, description: str):
    """Build a CLI ``main`` bound to one blade class."""

    def main(argv: Iterable[str] | None = None) -> None:
        cli.run(
            geometry_class,
            description=description,
            default_mesh_name=f"{geometry_class.model_name}.msh",
            model_name=geometry_class.model_name,
            argv=argv,
        )

    return main


main_blade0 = _make_main(BladeGeometry, "Construct a rotor blade using gmsh.")
main_blade90 = _make_main(Blade90Geometry, "Construct the 90-degree blade using gmsh.")
main_blade180 = _make_main(Blade180Geometry, "Construct the 180-degree blade using gmsh.")
main_blade270 = _make_main(Blade270Geometry, "Construct the 270-degree blade using gmsh.")
main_blade_blunt = _make_main(BluntBladeGeometry, "Construct the blunt-edge blade using gmsh.")


def main(argv: Iterable[str] | None = None) -> None:
    """Default CLI entrypoint builds the base (0-degree) blade."""
    main_blade0(argv)


if __name__ == "__main__":
    main()
