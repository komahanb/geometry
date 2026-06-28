#!/usr/bin/env python3
"""Parametric rotor blade caps built with the gmsh Python API.

Ported from ``CreateBladeCapX`` and its rotated siblings
(``CreateBladeCapNegativeX/Y/NegativeY``) in ``CreateComponents.geo``: a short
connector cylinder reaching inboard from the hub-radius blade root, placed at
one of four 90-degree azimuths.  The legacy variants just call the X cap and
rotate it, so they collapse to one class parameterised by ``azimuth``.
"""

import gmsh
import math
from typing import Dict, Iterable, Tuple

from . import cli
from .parameters import rotor_parameters, require_positive

FULL_CIRCLE = 2.0 * math.pi
PointRecords = Dict[str, Tuple[int, Tuple[float, float, float]]]


class BladeCapGeometry:
    """Build one blade-root connector cap at a given azimuth."""

    model_name = "bcap0"
    azimuth = 0.0  # placement angle about the z-axis (radians)

    def __init__(self, parameters: Dict[str, float] | None = None) -> None:
        self.parameters = rotor_parameters(parameters)
        self.parameters.setdefault("azimuth", self.azimuth)
        self.validate_parameters()

    @classmethod
    def default_parameters(cls) -> Dict[str, float]:
        """Return the baseline rotor parameter set plus this cap's azimuth."""
        params = rotor_parameters(None)
        params["azimuth"] = cls.azimuth
        return params

    def validate_parameters(self) -> None:
        """Guard against dimensions that would crash gmsh."""
        require_positive(
            self.parameters, ["cutout_radius", "blade_conn_length", "blade_conn_radius"]
        )

    def build(self, model_name: str | None = None) -> Tuple[int, PointRecords]:
        """Construct the blade cap and return the solid and key points."""
        name = model_name or self.model_name
        gmsh.model.add(name)
        gmsh.model.setCurrent(name)
        occ = gmsh.model.occ
        p = self.parameters

        # Connector cylinder reaching inboard (-x) from the blade root.
        cap = occ.addCylinder(
            p["x_blade"] + p["cutout_radius"],
            p["y_blade"],
            p["z_blade"],
            -p["blade_conn_length"],
            0.0,
            0.0,
            p["blade_conn_radius"],
            angle=FULL_CIRCLE,
        )

        # The legacy translates first, then rotates about the translated
        # origin, so the azimuth pivot is (xtrans, ytrans, ztrans).
        pivot = (p["xtrans"], p["ytrans"], p["ztrans"])
        if any(abs(c) > 1.0e-12 for c in pivot):
            occ.translate([(3, cap)], *pivot)
        if abs(p["azimuth"]) > 1.0e-12:
            occ.rotate([(3, cap)], pivot[0], pivot[1], pivot[2], 0.0, 0.0, 1.0, p["azimuth"])

        occ.synchronize()

        deg = int(round(math.degrees(p["azimuth"]))) % 360
        physical_tag = gmsh.model.addPhysicalGroup(3, [cap])
        gmsh.model.setPhysicalName(3, physical_tag, f"BladeCap{deg}")

        return cap, {}


class BladeCap0Geometry(BladeCapGeometry):
    """Blade cap at 0 degrees (``bcap0`` -> ``CreateBladeCapX``)."""

    model_name = "bcap0"
    azimuth = 0.0


class BladeCap90Geometry(BladeCapGeometry):
    """Blade cap at 90 degrees (``bcap90`` -> ``CreateBladeCapY``)."""

    model_name = "bcap90"
    azimuth = math.pi / 2.0


class BladeCap180Geometry(BladeCapGeometry):
    """Blade cap at 180 degrees (``bcap180`` -> ``CreateBladeCapNegativeX``)."""

    model_name = "bcap180"
    azimuth = math.pi


class BladeCap270Geometry(BladeCapGeometry):
    """Blade cap at 270 degrees (``bcap270`` -> ``CreateBladeCapNegativeY``)."""

    model_name = "bcap270"
    azimuth = -math.pi / 2.0


def _make_main(geometry_class, description: str):
    """Build a CLI ``main`` bound to one blade-cap class."""

    def main(argv: Iterable[str] | None = None) -> None:
        cli.run(
            geometry_class,
            description=description,
            default_mesh_name=f"{geometry_class.model_name}.msh",
            model_name=geometry_class.model_name,
            argv=argv,
        )

    return main


main_bcap0 = _make_main(BladeCap0Geometry, "Construct the 0-degree blade cap using gmsh.")
main_bcap90 = _make_main(BladeCap90Geometry, "Construct the 90-degree blade cap using gmsh.")
main_bcap180 = _make_main(BladeCap180Geometry, "Construct the 180-degree blade cap using gmsh.")
main_bcap270 = _make_main(BladeCap270Geometry, "Construct the 270-degree blade cap using gmsh.")


def main(argv: Iterable[str] | None = None) -> None:
    """Default CLI entrypoint builds the 0-degree blade cap."""
    main_bcap0(argv)


if __name__ == "__main__":
    main()
