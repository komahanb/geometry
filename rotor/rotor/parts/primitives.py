#!/usr/bin/env python3
"""Reusable OpenCASCADE geometry helpers ported from ``Functions.geo``.

Each helper builds geometry through the gmsh OCC kernel (``gmsh.model.occ``)
and returns the tag of the resulting 3-D volume.  They are the Python
equivalents of the legacy ``Function`` blocks (``HollowCylinderX/Y/Z``,
``AddPushRodHole``, ``CutBlockFromBasePlate``) and intentionally mirror those
boolean recipes so the port can be checked line-for-line against the original.

The legacy DSL paired every boolean with ``Coherence`` to weld coincident
boundaries; the OCC kernel does this as part of ``fuse``/``cut`` plus the
final ``synchronize`` issued by the calling part builder, so no explicit
coherence step is needed here.
"""

import math
from typing import Tuple

FULL_CIRCLE = 2.0 * math.pi

# Axis selector -> unit direction used to extrude a cylinder's height.
_AXIS_VECTORS = {
    "x": (1.0, 0.0, 0.0),
    "y": (0.0, 1.0, 0.0),
    "z": (0.0, 0.0, 1.0),
}


def hollow_cylinder(
    occ,
    x: float,
    y: float,
    z: float,
    height: float,
    inner_radius: float,
    outer_radius: float,
    axis: str = "z",
    angle: float = FULL_CIRCLE,
) -> int:
    """Return a hollow cylinder (outer minus inner) about the given axis.

    Mirrors ``HollowCylinderX/Y/Z``: build the outer and inner solid
    cylinders, then cut the inner from the outer.
    """
    try:
        ux, uy, uz = _AXIS_VECTORS[axis]
    except KeyError as exc:
        raise ValueError(f"axis must be one of x/y/z, got '{axis}'") from exc

    dx, dy, dz = ux * height, uy * height, uz * height
    outer = occ.addCylinder(x, y, z, dx, dy, dz, outer_radius, angle=angle)
    inner = occ.addCylinder(x, y, z, dx, dy, dz, inner_radius, angle=angle)
    result, _ = occ.cut([(3, outer)], [(3, inner)], removeObject=True, removeTool=True)
    return result[0][1]


def add_push_rod_hole(
    occ,
    base_volume: int,
    params,
    aoffset: float,
    roffset: float,
) -> Tuple[int, Tuple[float, float, float]]:
    """Punch a flanged push-rod hole into the base plate.

    Ported from ``AddPushRodHole``: a solid outer cylinder is fused onto the
    plate (forming the flange boss) and the inner cylinder is then cut out to
    open the bore.  Returns the new plate volume tag and the bore-centre point.
    """
    x = params["x_base"] + roffset * math.cos(aoffset)
    y = params["y_base"] + roffset * math.sin(aoffset)
    z = params["z_base"]
    height = params["pushrod_height"] / 3.0
    inner_r = params["pushrod_inner_radius"]
    outer_r = params["pushrod_outer_radius"]

    boss = occ.addCylinder(x, y, z, 0.0, 0.0, height, outer_r)
    fused, _ = occ.fuse(
        [(3, base_volume)], [(3, boss)], removeObject=True, removeTool=True
    )
    plate = fused[0][1]

    bore = occ.addCylinder(x, y, z, 0.0, 0.0, height, inner_r)
    cut, _ = occ.cut([(3, plate)], [(3, bore)], removeObject=True, removeTool=True)
    return cut[0][1], (x, y, z)


def cut_block_from_base_plate(
    occ,
    base_volume: int,
    params,
    aoffset: float,
) -> int:
    """Notch a block out of the plate rim and fuse on a capped link cylinder.

    Ported from ``CutBlockFromBasePlate``: subtract a rectangular block at the
    rim, then fuse a y-aligned link cylinder topped with a spherical-radius cap.
    """
    link_length = params["link_length"]
    base_radius = params["base_radius"]
    base_height = params["base_height"]
    z_base = params["z_base"]

    # Rectangular notch at the rim.
    bx = base_radius * math.cos(aoffset)
    by = base_radius * math.sin(aoffset) + link_length / 2.0
    block = occ.addBox(bx, by, z_base, -link_length, -link_length, base_height)
    notched, _ = occ.cut(
        [(3, base_volume)], [(3, block)], removeObject=True, removeTool=True
    )
    plate = notched[0][1]

    # Connector link cylinder (y-aligned) with a fatter cylindrical cap.
    sphere_r = params["pushrod_sphere_radius"]
    xlink = base_radius * math.cos(aoffset) - link_length / 2.0
    ylink = base_radius * math.sin(aoffset) - link_length / 2.0
    zlink = z_base + base_height / 2.0

    link = occ.addCylinder(
        xlink, ylink, zlink, 0.0, link_length, 0.0, params["link_radius"]
    )
    cap = occ.addCylinder(
        xlink,
        ylink + link_length / 2.0 - sphere_r,
        zlink,
        0.0,
        2.0 * sphere_r,
        0.0,
        sphere_r,
    )
    link_fused, _ = occ.fuse(
        [(3, link)], [(3, cap)], removeObject=True, removeTool=True
    )
    full, _ = occ.fuse(
        [(3, plate)], [(3, link_fused[0][1])], removeObject=True, removeTool=True
    )
    return full[0][1]
