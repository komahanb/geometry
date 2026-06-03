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
from .airfoil import naca4_profile
from .parameters import rotor_parameters, require_positive


class BladeGeometry:
    """Build a rotor blade using an extruded NACA-4 section."""

    def __init__(self, parameters: Dict[str, float] | None = None) -> None:
        self.parameters = rotor_parameters(parameters)
        for key, value in self.blade_defaults().items():
            self.parameters.setdefault(key, value)
        self.validate_parameters()

    @staticmethod
    def blade_defaults() -> Dict[str, float]:
        """Blade-specific defaults hard-coded in ``CreateBladeX``."""
        return {
            "blade_chord": 0.121,
            "blade_r_cutout": 0.44,
            "blade_tip_radius": 2.0,
            "blade_cl": 0.01,
            "blade_thickness": 12.0,  # percent of chord
            "blade_nspl": 4,
            "blade_pps": 5,
            "azimuth": 0.0,  # blade azimuthal placement (radians)
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
        surface, _loop = naca4_profile(occ, section)

        # Lay the section flat about the coordinate-system origin.
        occ.rotate(
            [(2, surface)],
            p["xo"],
            p["yo"],
            p["zo"],
            0.0,
            0.0,
            1.0,
            -math.pi / 2.0,
        )

        # Extrude spanwise from tip toward the root cutout (negative x).
        num_layers = max(int(round((tip_radius - r_cutout) / cl)), 1)
        extruded = occ.extrude(
            [(2, surface)],
            r_cutout - tip_radius,
            0.0,
            0.0,
            numElements=[num_layers],
            recombine=True,
        )
        blade = next(tag for dim, tag in extruded if dim == 3)

        # Optional azimuthal placement (blade90/180/270 reuse this class).
        if abs(p["azimuth"]) > 1.0e-12:
            occ.rotate(
                [(3, blade)], p["xo"], p["yo"], p["zo"], 0.0, 0.0, 1.0, p["azimuth"]
            )

        translation = (p["xtrans"], p["ytrans"], p["ztrans"])
        if any(abs(c) > 1.0e-12 for c in translation):
            occ.translate([(3, blade)], *translation)

        occ.synchronize()

        physical_tag = gmsh.model.addPhysicalGroup(3, [blade])
        gmsh.model.setPhysicalName(3, physical_tag, "Blade")

        return blade, {}


def main(argv: Iterable[str] | None = None) -> None:
    """CLI entrypoint for generating, exporting or meshing the blade."""
    cli.run(
        BladeGeometry,
        description="Construct a rotor blade using gmsh.",
        default_mesh_name="blade0.msh",
        model_name="blade0",
        argv=argv,
    )


if __name__ == "__main__":
    main()
