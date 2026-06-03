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
