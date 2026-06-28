#!/usr/bin/env python3
"""Parametric two-blade hub built with the gmsh Python API.

Ported from ``CreateDoubleBladeHub`` in ``CreateComponents.geo``: the shaft and
hub cylinders fused into one body, with a single x-aligned connector carrying
the two opposed (30/210-degree) blade attachment points.  Compare
:class:`rotor.parts.hub4b.Hub4BGeometry`, which adds a second connector for the
four-blade variant.
"""

import gmsh
from typing import Dict, Iterable, Tuple

from . import cli
from .parameters import rotor_parameters, require_positive

PointRecords = Dict[str, Tuple[int, Tuple[float, float, float]]]


class DoubleBladeHubGeometry:
    """Build the two-blade hub using OpenCASCADE primitives."""

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
                "shaft_height",
                "hub_height",
                "shaft_radius",
                "hub_radius",
                "hub_conn_length",
                "hub_conn_radius",
            ],
        )

    def build(self, model_name: str = "hub2b") -> Tuple[int, PointRecords]:
        """Construct the two-blade hub and return the solid and key points."""
        gmsh.model.add(model_name)
        gmsh.model.setCurrent(model_name)
        occ = gmsh.model.occ
        p = self.parameters

        x_hub, y_hub, z_hub = p["x_hub"], p["y_hub"], p["z_hub"]

        # Shaft cylinder up to the hub, then the hub cylinder on top.
        shaft_dz = p["shaft_height"] - p["hub_height"]
        shaft = occ.addCylinder(x_hub, y_hub, z_hub, 0.0, 0.0, shaft_dz, p["shaft_radius"])
        hub = occ.addCylinder(
            x_hub, y_hub, z_hub + shaft_dz, 0.0, 0.0, p["hub_height"], p["hub_radius"]
        )
        fused, _ = occ.fuse([(3, shaft)], [(3, hub)], removeObject=True, removeTool=True)
        body = fused[0][1]

        # Single x-aligned blade connector spanning the hub.
        reach = p["hub_conn_length"] + p["hub_radius"]
        conn_z = z_hub + p["shaft_height"] - p["hub_height"] / 2.0
        conn = occ.addCylinder(
            x_hub - reach, y_hub, conn_z, 2.0 * reach, 0.0, 0.0, p["hub_conn_radius"]
        )
        fused, _ = occ.fuse([(3, body)], [(3, conn)], removeObject=True, removeTool=True)
        body = fused[0][1]

        translation = (p["xtrans"], p["ytrans"], p["ztrans"])
        if any(abs(c) > 1.0e-12 for c in translation):
            occ.translate([(3, body)], *translation)

        # Constraint points: shaft origin and the two blade attachments.
        attach = p["hub_radius"] + p["hub_conn_length"]
        records = {
            "P_HUB_ORIG": (x_hub, y_hub, z_hub),
            "P_HUB_UPL30": (attach, y_hub, conn_z),
            "P_HUB_UPL210": (-attach, y_hub, conn_z),
        }
        point_records: PointRecords = {}
        for label, coords in records.items():
            coords = (
                coords[0] + translation[0],
                coords[1] + translation[1],
                coords[2] + translation[2],
            )
            point_records[label] = (occ.addPoint(*coords), coords)

        occ.synchronize()
        for label, record in point_records.items():
            gmsh.model.setEntityName(0, record[0], label)

        physical_tag = gmsh.model.addPhysicalGroup(3, [body])
        gmsh.model.setPhysicalName(3, physical_tag, "DoubleBladeHub")

        return body, point_records


def main(argv: Iterable[str] | None = None) -> None:
    """CLI entrypoint for generating, exporting or meshing the two-blade hub."""
    cli.run(
        DoubleBladeHubGeometry,
        description="Construct the two-blade hub using gmsh.",
        default_mesh_name="hub2b.msh",
        model_name="hub2b",
        argv=argv,
    )


if __name__ == "__main__":
    main()
