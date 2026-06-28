#!/usr/bin/env python3
"""Symmetric NACA four-series airfoil profile ported from ``naca.geo``.

Computation method follows NASA TM 4741 (Ladson, Brooks, Hill and Sproles,
1996), exactly as the legacy ``Function NACA4``: lay points around the section
starting at the trailing edge, over the upper surface and back along the lower
surface, then connect them with a ring of splines closed into a plane surface.

The section is built in the chord (x) / thickness (z) plane at a fixed span
station (y); :class:`rotor.parts.blade.BladeGeometry` later extrudes it.
"""

import math
from typing import Dict, Tuple

# Thickness-distribution coefficients from NASA TM 4741.
A0 = 0.2969
A1 = -0.1260
A2 = -0.3516
A3 = 0.2843
A4 = -0.1015


def default_section() -> Dict[str, float]:
    """Default NACA section matching ``CreateBladeX``."""
    return {
        "nspl": 4,      # number of splines per surface
        "pps": 5,       # points per spline
        "th": 12.0,     # thickness, percent of chord
        "ch": 0.121,    # chord length
        "le_x": -0.121 / 2.0,  # leading-edge chordwise offset
        "le_y": 0.0,    # thickness-direction (z) offset
        "le_z": 2.0,    # span station (y), = blade tip radius R
        "z_blade": 0.0,  # base z-level of the section
        "cl": 0.01,     # characteristic mesh length at section points
    }


def _thickness(x: float) -> float:
    """NACA half-thickness distribution evaluated at chord fraction ``x``."""
    return A0 * math.sqrt(x) + x * (A1 + x * (A2 + x * (A3 + x * A4)))


# Blunt trailing-edge section, normalised to unit chord, taken from the
# standalone ``blunt_blade/blunt_blade.geo`` (a 12%-thick section with a finite
# trailing edge).  Points run from the upper trailing edge, over the leading
# edge, back to the lower trailing edge; the two TE points are later joined by a
# straight line rather than a closing spline.  The rotor model's
# ``geo/blade_blunt.geo`` referenced an undefined ``CreateBladeBluntEdge``, so
# this profile is the only concrete blunt definition in the tree.
_BLUNT_SECTION = (
    (1.000000, 0.017160),
    (0.933013, 0.022335),
    (0.750000, 0.036634),
    (0.500000, 0.053934),
    (0.250000, 0.059474),
    (0.066987, 0.040146),
    (0.000000, 0.000000),
    (0.066987, -0.040146),
    (0.250000, -0.059474),
    (0.500000, -0.053934),
    (0.750000, -0.036634),
    (0.933013, -0.022335),
    (1.000000, -0.017160),
)


def naca4_blunt_profile(occ, section: Dict[str, float]) -> Tuple[int, int]:
    """Build a blunt trailing-edge section and return ``(surface_tag, loop_tag)``.

    Uses the same chord/thickness frame as :func:`naca4_profile` (chord along
    x at span station ``le_z``, thickness along z) but lays the fixed
    :data:`_BLUNT_SECTION` shape and closes the trailing edge with a straight
    line, matching the legacy blunt blade.
    """
    ch = section["ch"]
    le_x = section["le_x"]
    le_y = section["le_y"]
    le_z = section["le_z"]
    z_blade = section["z_blade"]
    cl = section["cl"]

    points = [
        occ.addPoint(ch * xn + le_x, le_z, z_blade + zn * ch + le_y, cl)
        for xn, zn in _BLUNT_SECTION
    ]

    # Upper surface, leading-edge wrap, lower surface (matching the legacy
    # spline grouping), then a straight line closing the blunt trailing edge.
    upper = occ.addSpline(points[0:6])
    nose = occ.addSpline(points[5:8])
    lower = occ.addSpline(points[7:13])
    trailing = occ.addLine(points[12], points[0])

    loop = occ.addCurveLoop([upper, nose, lower, trailing])
    surface = occ.addPlaneSurface([loop])
    return surface, loop


def naca4_profile(occ, section: Dict[str, float]) -> Tuple[int, int]:
    """Build a closed NACA-4 section and return ``(surface_tag, loop_tag)``.

    The point layout, spline grouping and final closing spline reproduce the
    legacy ``NACA4`` block one-for-one so the resulting profile is identical.
    """
    nspl = int(section["nspl"])
    pps = int(section["pps"])
    th = section["th"]
    ch = section["ch"]
    le_x = section["le_x"]
    le_y = section["le_y"]
    le_z = section["le_z"]
    z_blade = section["z_blade"]
    cl = section["cl"]

    npts = nspl * pps
    points = []

    # Upper surface: indices 0 .. npts (inclusive).
    for i in range(0, npts + 1):
        x = 0.5 * (1.0 + math.cos(i / npts * math.pi))
        y = _thickness(x)
        z = z_blade + y * ch * th / 20.0 + le_y
        points.append(occ.addPoint(ch * x + le_x, le_z, z, cl))

    # Lower surface: indices npts+1 .. 2*npts-1.
    for i in range(npts + 1, 2 * npts):
        x = 0.5 * (1.0 + math.cos(i / npts * math.pi))
        y = _thickness(x)
        z = z_blade - y * ch * th / 20.0 + le_y
        points.append(occ.addPoint(ch * x + le_x, le_z, z, cl))

    # Splines over the section.  Legacy slices Points[{a:b}] inclusively.
    step = pps - 1
    spline_tags = []
    for i in range(0, 2 * nspl + 1):
        segment = points[i * step : (i + 1) * step + 1]
        spline_tags.append(occ.addSpline(segment))

    # Closing spline: remaining points back to the trailing-edge start point.
    i = 2 * nspl + 1
    closing = points[i * step : 2 * npts] + [points[0]]
    spline_tags.append(occ.addSpline(closing))

    loop = occ.addCurveLoop(spline_tags)
    surface = occ.addPlaneSurface([loop])
    return surface, loop
