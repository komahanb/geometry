#!/usr/bin/env python3
"""Parametric four-blade hub constructed with the gmsh Python API."""

import gmsh
from typing import Dict, Iterable, Tuple

from . import cli


class Hub4BGeometry:
    """Build the four-blade hub using OpenCASCADE primitives."""

    def __init__(self, parameters: Dict[str, float] | None = None) -> None:
        self.parameters = self.default_parameters()
        if parameters:
            self.parameters.update(parameters)
        self.ensure_dependent_parameters()
        self.validate_parameters()

    @staticmethod
    def default_parameters() -> Dict[str, float]:
        """Return baseline values derived from Parameters.geo."""
        return {
            "cutout_radius": 0.44,
            "shaft_height": 1.0,
            "hub_height_ratio": 0.2,
            "hub_radius_ratio": 0.50,
            "shaft_radius_ratio": 0.15,
            "connection_length_ratio": 0.05,
            "connection_radius_ratio": 0.65,
            "x_hub": 0.0,
            "y_hub": 0.0,
            "z_hub": 0.0,
            "xtrans": 0.0,
            "ytrans": 0.0,
            "ztrans": 0.0,
        }

    def ensure_dependent_parameters(self) -> None:
        """Populate derived parameters that depend on the base ratios."""
        params = self.parameters
        params.setdefault(
            "hub_height", params["hub_height_ratio"] * params["shaft_height"]
        )
        params.setdefault(
            "hub_radius", params["hub_radius_ratio"] * params["cutout_radius"]
        )
        params.setdefault(
            "shaft_radius", params["shaft_radius_ratio"] * params["cutout_radius"]
        )
        radius_margin = max(params["cutout_radius"] - params["hub_radius"], 0.0)
        params.setdefault(
            "hub_conn_length",
            params["connection_length_ratio"] * radius_margin,
        )
        params.setdefault(
            "hub_conn_radius",
            params["connection_radius_ratio"] * (0.5 * params["hub_height"]),
        )
        params.setdefault(
            "blade_plane_z",
            params["z_hub"] + params["shaft_height"] - 0.5 * params["hub_height"],
        )

    def validate_parameters(self) -> None:
        """Guard against invalid dimensions that would crash gmsh."""
        params = self.parameters
        positive_keys = [
            "cutout_radius",
            "shaft_height",
            "hub_height",
            "hub_radius",
            "shaft_radius",
            "hub_conn_length",
            "hub_conn_radius",
        ]
        for key in positive_keys:
            if params[key] <= 0.0:
                raise ValueError(f"Parameter '{key}' must be positive")

    def build(
        self, model_name: str = "hub4b"
    ) -> Tuple[int, Dict[str, Tuple[int, Tuple[float, float, float]]]]:
        """Construct the hub geometry and return the solid and key points."""
        gmsh.model.add(model_name)
        gmsh.model.setCurrent(model_name)
        occ = gmsh.model.occ
        params = self.parameters

        point_records: Dict[str, Tuple[int, Tuple[float, float, float]]] = {}

        # Seed the origin constraint point at the shaft centerline.
        origin_tag = occ.addPoint(params["x_hub"], params["y_hub"], params["z_hub"])
        point_records["P_HUB_ORIG"] = (
            origin_tag,
            (params["x_hub"], params["y_hub"], params["z_hub"]),
        )

        # Create the shaft and hub cylinders before union operations.
        shaft_height_delta = params["shaft_height"] - params["hub_height"]
        shaft_tag = occ.addCylinder(
            params["x_hub"],
            params["y_hub"],
            params["z_hub"],
            0.0,
            0.0,
            shaft_height_delta,
            params["shaft_radius"],
        )

        hub_tag = occ.addCylinder(
            params["x_hub"],
            params["y_hub"],
            params["z_hub"] + shaft_height_delta,
            0.0,
            0.0,
            params["hub_height"],
            params["hub_radius"],
        )

        merged_entities, fuse_map = occ.fuse(
            [(3, shaft_tag)], [(3, hub_tag)], removeObject=True, removeTool=True
        )
        del fuse_map
        hub_volume_tag = merged_entities[0][1]

        # Attach the first connector aligned with the X-axis.
        connector_span = params["hub_conn_length"] + params["hub_radius"]
        connector_x = params["x_hub"] - connector_span
        connector_y = params["y_hub"]
        connector_z = params["blade_plane_z"]
        connector_x_tag = occ.addCylinder(
            connector_x,
            connector_y,
            connector_z,
            2.0 * connector_span,
            0.0,
            0.0,
            params["hub_conn_radius"],
        )
        merged_entities, fuse_map = occ.fuse(
            [(3, hub_volume_tag)],
            [(3, connector_x_tag)],
            removeObject=True,
            removeTool=True,
        )
        del fuse_map
        hub_volume_tag = merged_entities[0][1]

        point_records["P_HUB_UPL30"] = (
            occ.addPoint(
                params["hub_radius"] + params["hub_conn_length"],
                connector_y,
                connector_z,
            ),
            (
                params["hub_radius"] + params["hub_conn_length"],
                connector_y,
                connector_z,
            ),
        )
        point_records["P_HUB_UPL210"] = (
            occ.addPoint(
                -(params["hub_radius"] + params["hub_conn_length"]),
                connector_y,
                connector_z,
            ),
            (
                -(params["hub_radius"] + params["hub_conn_length"]),
                connector_y,
                connector_z,
            ),
        )

        # Attach the second connector aligned with the Y-axis.
        connector_span_y = params["hub_conn_length"] + params["hub_radius"]
        connector_x_y = params["x_hub"]
        connector_y_shifted = params["y_hub"] - connector_span_y
        connector_y_tag = occ.addCylinder(
            connector_x_y,
            connector_y_shifted,
            connector_z,
            0.0,
            2.0 * connector_span_y,
            0.0,
            params["hub_conn_radius"],
        )
        merged_entities, fuse_map = occ.fuse(
            [(3, hub_volume_tag)],
            [(3, connector_y_tag)],
            removeObject=True,
            removeTool=True,
        )
        del fuse_map
        hub_volume_tag = merged_entities[0][1]

        point_records["P_HUB_UPL120"] = (
            occ.addPoint(
                connector_x_y,
                params["hub_radius"] + params["hub_conn_length"],
                connector_z,
            ),
            (
                connector_x_y,
                params["hub_radius"] + params["hub_conn_length"],
                connector_z,
            ),
        )
        point_records["P_HUB_UPL300"] = (
            occ.addPoint(
                connector_x_y,
                -(params["hub_radius"] + params["hub_conn_length"]),
                connector_z,
            ),
            (
                connector_x_y,
                -(params["hub_radius"] + params["hub_conn_length"]),
                connector_z,
            ),
        )

        translation_vector = (
            params["xtrans"],
            params["ytrans"],
            params["ztrans"],
        )
        if any(abs(component) > 1.0e-12 for component in translation_vector):
            occ.translate([(3, hub_volume_tag)], *translation_vector)

        occ.synchronize()

        for name, record in point_records.items():
            gmsh.model.setEntityName(0, record[0], name)

        physical_tag = gmsh.model.addPhysicalGroup(3, [hub_volume_tag])
        gmsh.model.setPhysicalName(3, physical_tag, "Hub4B")

        return hub_volume_tag, point_records


def main(argv: Iterable[str] | None = None) -> None:
    """CLI entrypoint for generating, exporting or meshing the hub."""
    cli.run(
        Hub4BGeometry,
        description="Construct the four-blade hub using gmsh.",
        default_mesh_name="hub4b.msh",
        model_name="hub4b",
        argv=argv,
    )


if __name__ == "__main__":
    main()
