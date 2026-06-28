#!/usr/bin/env python3
"""Thin CLI bridge into rotor.parts.swashplate (usp2b = double upper swash plate).

Re-scripting of the legacy geo/usp2b.geo now lives in the parametric
DoubleUpperSwashPlateGeometry class; this entry point simply forwards the CLI.
"""

import os
import sys

# Make the rotor package importable when run directly from pygeo/.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from rotor.parts.swashplate import main_usp2b as main


if __name__ == "__main__":
    main()
