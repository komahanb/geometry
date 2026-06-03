#!/usr/bin/env python3
"""Thin CLI bridge into rotor.parts.baseplate (bsp = base plate).

Re-scripting of the legacy geo/bsp.geo now lives in the parametric
BasePlateGeometry class; this entry point simply forwards the CLI to it.
"""

import os
import sys

# Make the rotor package importable when run directly from pygeo/.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from rotor.parts.baseplate import main


if __name__ == "__main__":
    main()
