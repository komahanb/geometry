#!/usr/bin/env python3
"""Rotor hub assembly parameters ported from the legacy ``Parameters.geo``.

The legacy build expressed every component dimension as a chain of ratios
anchored to two base inputs: the shaft height and the blade root cutout
radius.  This module reproduces that chain in Python so the object-oriented
part builders share a single, parametric source of truth instead of each
re-deriving the same quantities.

Use :func:`rotor_parameters` to obtain the full derived dictionary, optionally
overriding any base or derived entry.  The keys mirror the variable names used
in ``Parameters.geo`` so the port stays auditable against the original.
"""

import math
from typing import Dict, Iterable, Mapping

# Base inputs.  Everything else is derived from these (see Parameters.geo).
BASE_PARAMETERS: Dict[str, float] = {
    "shaft_height": 1.0,
    "cutout_radius": 0.44,  # root cutout radius of the blade
    # Origin of the coordinate system.
    "xo": 0.0,
    "yo": 0.0,
    "zo": 0.0,
    # Final rigid translation applied to each finished body.
    "xtrans": 0.0,
    "ytrans": 0.0,
    "ztrans": 0.0,
}


def rotor_parameters(overrides: Mapping[str, float] | None = None) -> Dict[str, float]:
    """Return the full derived parameter set, applying optional overrides.

    Overrides are applied to the base inputs *before* derivation so that, for
    example, changing ``cutout_radius`` propagates through every dependent
    dimension.  An override naming a derived key wins over its computed value,
    matching how the legacy ``.geo`` scripts let drivers reassign quantities.
    """
    params: Dict[str, float] = dict(BASE_PARAMETERS)
    if overrides:
        params.update(overrides)

    shaft_height = params["shaft_height"]
    cutout_radius = params["cutout_radius"]

    # Heights and primary radii (normalised on the shaft height / cutout).
    params.setdefault("sphere_radius", 0.2 * shaft_height)
    params.setdefault("base_height", 0.1 * shaft_height)
    params.setdefault("hub_height", 0.2 * shaft_height)

    sphere_radius = params["sphere_radius"]
    params.setdefault("upper_swash_radius", 1.4 * sphere_radius)
    params.setdefault("lower_swash_radius", 1.2 * sphere_radius)

    params.setdefault("shaft_radius", 0.15 * cutout_radius)
    params.setdefault("hub_radius", 0.50 * cutout_radius)
    params.setdefault("base_radius", 1.00 * cutout_radius)

    params.setdefault("lower_swash_height", 0.2 * sphere_radius)
    params.setdefault("upper_swash_height", 1.5 * params["lower_swash_height"])

    # Base plate centre and the z-levels of the stacked bodies.
    xo, yo, zo = params["xo"], params["yo"], params["zo"]
    params.setdefault("x_base", xo + 0.0)
    params.setdefault("y_base", yo + 0.0)
    params.setdefault("z_base", zo + 0.0)

    z_base = params["z_base"]
    params.setdefault("z_sphere", z_base + 0.4 * shaft_height)
    params.setdefault(
        "z_lower_swash", params["z_sphere"] - params["lower_swash_height"]
    )
    params.setdefault(
        "z_upper_swash", params["z_lower_swash"] + params["lower_swash_height"]
    )
    params.setdefault("z_hub", z_base)
    params.setdefault(
        "z_blade", z_base + shaft_height - params["hub_height"] / 2.0
    )

    # Co-located x/y centres for the stacked bodies.
    x_base, y_base = params["x_base"], params["y_base"]
    for name in ("lower_swash", "upper_swash", "sphere", "hub", "blade"):
        params.setdefault(f"x_{name}", x_base)
        params.setdefault(f"y_{name}", y_base)

    params.setdefault("inner_base_radius", params["shaft_radius"])
    params.setdefault("fillet_radius", 0.01)

    # Push rod dimensions (arbitrary but self-consistent choices in the legacy).
    params.setdefault("pushrod_inner_radius", 0.2 * params["shaft_radius"])
    params.setdefault(
        "pushrod_outer_radius", 2.0 * params["pushrod_inner_radius"]
    )
    params.setdefault("pushrod_base_radius", params["pushrod_inner_radius"])
    params.setdefault(
        "pushrod_sphere_radius", 1.75 * params["pushrod_inner_radius"]
    )
    params.setdefault(
        "pushrod_height",
        params["z_lower_swash"] + params["lower_swash_height"] / 2.0,
    )
    params.setdefault("pushrod_roffset", 0.91 * params["base_radius"])

    # Pitch link dimensions.
    params.setdefault(
        "pitchlink_sphere_radius", 1.75 * params["pushrod_inner_radius"]
    )
    params.setdefault(
        "pitchlink_length",
        params["z_blade"]
        - (params["z_upper_swash"] + params["upper_swash_height"] / 2.0),
    )

    # Connector links between the base plate and swash plates.
    params.setdefault("link_length", 6.0 * params["pushrod_inner_radius"])
    params.setdefault("link_radius", params["pushrod_inner_radius"])

    params.setdefault("upper_swash_angle", math.pi / 6.0)
    params.setdefault("uswash_outer_radius", params["base_radius"] - params["link_length"])
    params.setdefault("swash_connplate_length", 1.5 * params["link_length"])

    # Connector dimensions for the hub/blade interface.
    params.setdefault(
        "blade_conn_length", 0.1 * (cutout_radius - params["hub_radius"])
    )
    params.setdefault("blade_conn_radius", 0.65 * (0.5 * params["hub_height"]))
    params.setdefault(
        "hub_conn_length", 0.05 * (cutout_radius - params["hub_radius"])
    )
    params.setdefault("hub_conn_radius", params["blade_conn_radius"])

    # Push horn dimensions (used by lph/uph; included for completeness).
    params.setdefault("pushrod_angle", math.pi / 4.0)
    params.setdefault(
        "horn_length",
        0.5
        * (
            params["z_lower_swash"]
            + 0.5 * params["lower_swash_height"]
            - 0.5 * params["base_height"]
        )
        / math.cos(params["pushrod_angle"]),
    )
    params.setdefault("horn_bolt_radius", params["link_radius"] / 2.0)
    params.setdefault("horn_base_radius", params["pushrod_base_radius"])
    params.setdefault("horn_outer_radius", params["pushrod_outer_radius"])
    params.setdefault("horn_inner_radius", params["pushrod_sphere_radius"])

    return params


def require_positive(params: Mapping[str, float], keys: Iterable[str]) -> None:
    """Raise ``ValueError`` if any named dimension is non-positive."""
    for key in keys:
        if params[key] <= 0.0:
            raise ValueError(f"Parameter '{key}' must be positive")
