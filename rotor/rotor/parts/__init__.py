"""Parametric rotor components.

Geometry builders are object-oriented classes (see AGENTS.md) that re-script
the legacy ``.geo`` definitions through the gmsh Python OCC API.  Look up a
builder by name with :func:`create_part`, or import the class directly, e.g.
``from rotor.parts.hub4b import Hub4BGeometry``.
"""

from typing import Dict, List

from .hub4b import Hub4BGeometry
from .baseplate import BasePlateGeometry
from .blade import BladeGeometry
from .pitchlink import PitchLinkGeometry

PARTS_REGISTRY: Dict[str, type] = {
    "hub4b": Hub4BGeometry,
    "baseplate": BasePlateGeometry,
    "blade": BladeGeometry,
    "pitchlink": PitchLinkGeometry,
}
"""Mapping from part identifiers to their geometry classes."""

__all__ = [
    "PARTS_REGISTRY",
    "Hub4BGeometry",
    "BasePlateGeometry",
    "BladeGeometry",
    "PitchLinkGeometry",
    "available_parts",
    "create_part",
]


def available_parts() -> List[str]:
    """Return the part identifiers currently registered."""
    return list(PARTS_REGISTRY.keys())


def create_part(name: str, parameters: Dict[str, float] | None = None):
    """Instantiate a geometry object by registry name."""
    try:
        part_class = PARTS_REGISTRY[name.lower()]
    except KeyError as exc:
        raise ValueError(f"Unknown part '{name}'") from exc
    return part_class(parameters)
