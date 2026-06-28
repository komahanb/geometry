"""Parametric rotor components.

Geometry builders are object-oriented classes (see AGENTS.md) that re-script
the legacy ``.geo`` definitions through the gmsh Python OCC API.  Look up a
builder by name with :func:`create_part`, or import the class directly, e.g.
``from rotor.parts.hub4b import Hub4BGeometry``.
"""

from typing import Dict, List

from .hub4b import Hub4BGeometry
from .hub2b import DoubleBladeHubGeometry
from .baseplate import BasePlateGeometry
from .blade import (
    BladeGeometry,
    Blade90Geometry,
    Blade180Geometry,
    Blade270Geometry,
    BluntBladeGeometry,
)
from .bladecap import (
    BladeCap0Geometry,
    BladeCap90Geometry,
    BladeCap180Geometry,
    BladeCap270Geometry,
)
from .pitchlink import (
    PitchLinkGeometry,
    LowerPitchLink120Geometry,
    LowerPitchLink210Geometry,
    LowerPitchLink300Geometry,
    UpperPitchLinkGeometry,
    UpperPitchLink120Geometry,
    UpperPitchLink210Geometry,
    UpperPitchLink300Geometry,
)
from .pushrod import (
    PushRod90Geometry,
    PushRod180Geometry,
    PushRod270Geometry,
)
from .pushhorn import LowerPushHornGeometry, UpperPushHornGeometry
from .sphere import SphereGeometry
from .swashplate import (
    DoubleUpperSwashPlateGeometry,
    FourUpperSwashPlateGeometry,
    LowerSwashPlateGeometry,
)

PARTS_REGISTRY: Dict[str, type] = {
    "hub4b": Hub4BGeometry,
    "hub2b": DoubleBladeHubGeometry,
    "baseplate": BasePlateGeometry,
    "blade": BladeGeometry,
    "blade90": Blade90Geometry,
    "blade180": Blade180Geometry,
    "blade270": Blade270Geometry,
    "blade_blunt": BluntBladeGeometry,
    "bcap0": BladeCap0Geometry,
    "bcap90": BladeCap90Geometry,
    "bcap180": BladeCap180Geometry,
    "bcap270": BladeCap270Geometry,
    "pitchlink": PitchLinkGeometry,
    "lpl120": LowerPitchLink120Geometry,
    "lpl210": LowerPitchLink210Geometry,
    "lpl300": LowerPitchLink300Geometry,
    "upl30": UpperPitchLinkGeometry,
    "upl120": UpperPitchLink120Geometry,
    "upl210": UpperPitchLink210Geometry,
    "upl300": UpperPitchLink300Geometry,
    "prod90": PushRod90Geometry,
    "prod180": PushRod180Geometry,
    "prod270": PushRod270Geometry,
    "lph": LowerPushHornGeometry,
    "uph": UpperPushHornGeometry,
    "sphere": SphereGeometry,
    "usp2b": DoubleUpperSwashPlateGeometry,
    "usp4b": FourUpperSwashPlateGeometry,
    "lsp": LowerSwashPlateGeometry,
}
"""Mapping from part identifiers to their geometry classes."""

__all__ = [
    "PARTS_REGISTRY",
    "Hub4BGeometry",
    "DoubleBladeHubGeometry",
    "BasePlateGeometry",
    "BladeGeometry",
    "Blade90Geometry",
    "Blade180Geometry",
    "Blade270Geometry",
    "BluntBladeGeometry",
    "BladeCap0Geometry",
    "BladeCap90Geometry",
    "BladeCap180Geometry",
    "BladeCap270Geometry",
    "PitchLinkGeometry",
    "LowerPitchLink120Geometry",
    "LowerPitchLink210Geometry",
    "LowerPitchLink300Geometry",
    "UpperPitchLinkGeometry",
    "UpperPitchLink120Geometry",
    "UpperPitchLink210Geometry",
    "UpperPitchLink300Geometry",
    "PushRod90Geometry",
    "PushRod180Geometry",
    "PushRod270Geometry",
    "LowerPushHornGeometry",
    "UpperPushHornGeometry",
    "SphereGeometry",
    "DoubleUpperSwashPlateGeometry",
    "FourUpperSwashPlateGeometry",
    "LowerSwashPlateGeometry",
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
