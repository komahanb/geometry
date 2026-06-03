#!/usr/bin/env python3
"""Parametric rotor base plate built with the gmsh Python API.

Ported from ``Function CreateBasePlate`` in ``CreateComponents.geo``: a hollow
disc with three flanged push-rod bores (at 90/180/270 degrees) and a notched
rim carrying a capped connector link.  The reusable boolean recipes live in
:mod:`rotor.parts.primitives`.
"""

import gmsh
import math
from typing import Dict, Iterable, Tuple

from . import cli
from .primitives import (
    add_push_rod_hole,
    cut_block_from_base_plate,
    hollow_cylinder,
)
from .parameters import rotor_parameters, require_positive


class BasePlateGeometry:
    """Build the rotor base plate using OpenCASCADE primitives."""

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
                "inner_base_radius",
                "base_height",
                "pushrod_inner_radius",
                "pushrod_outer_radius",
                "link_length",
                "link_radius",
            ],
        )

    def build(
        self, model_name: str = "bsp"
    ) -> Tuple[int, Dict[str, Tuple[int, Tuple[float, float, float]]]]:
        """Construct the base plate and return the solid and key points."""
        gmsh.model.add(model_name)
        gmsh.model.setCurrent(model_name)
        occ = gmsh.model.occ
        p = self.parameters

        point_records: Dict[str, Tuple[int, Tuple[float, float, float]]] = {}

        # Main hollow disc.
        plate = hollow_cylinder(
            occ,
            p["x_base"],
            p["y_base"],
            p["z_base"],
            p["base_height"],
            p["inner_base_radius"],
            p["base_radius"],
            axis="z",
        )

        # Constraint point shared with the hub shaft.
        hub_point = (p["x_base"], p["y_base"], p["z_base"])
        point_records["P_BSP_HUB"] = (occ.addPoint(*hub_point), hub_point)

        # Flanged push-rod bores at 90, 180 and 270 degrees.
        roffset = p["pushrod_roffset"]
        for label, aoffset in (
            ("P_BSP_PROD90", math.pi / 2.0),
            ("P_BSP_PROD180", math.pi),
            ("P_BSP_PROD270", 3.0 * math.pi / 2.0),
        ):
            plate, bore_centre = add_push_rod_hole(occ, plate, p, aoffset, roffset)
            point_records[label] = (occ.addPoint(*bore_centre), bore_centre)

        # Notch the rim and fuse on the connector link at 0 degrees.
        plate = cut_block_from_base_plate(occ, plate, p, aoffset=0.0)

        translation = (p["xtrans"], p["ytrans"], p["ztrans"])
        if any(abs(c) > 1.0e-12 for c in translation):
            occ.translate([(3, plate)], *translation)

        occ.synchronize()
        for name, record in point_records.items():
            gmsh.model.setEntityName(0, record[0], name)

        physical_tag = gmsh.model.addPhysicalGroup(3, [plate])
        gmsh.model.setPhysicalName(3, physical_tag, "BasePlate")

        return plate, point_records


def main(argv: Iterable[str] | None = None) -> None:
    """CLI entrypoint for generating, exporting or meshing the base plate."""
    cli.run(
        BasePlateGeometry,
        description="Construct the rotor base plate using gmsh.",
        default_mesh_name="bsp.msh",
        model_name="bsp",
        argv=argv,
    )


if __name__ == "__main__":
    main()
