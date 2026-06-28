#!/usr/bin/env python3
"""Thin CLI bridge into rotor.parts.swashplate (lsp = lower swash plate).

Re-scripting of the legacy geo/lsp.geo now lives in the parametric
LowerSwashPlateGeometry class; this entry point simply forwards the CLI.
"""

import os
import sys

# Make the rotor package importable when run directly from pygeo/.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from rotor.parts.swashplate import main_lsp as main


if __name__ == "__main__":
    main()
