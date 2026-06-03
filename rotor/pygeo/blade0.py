#!/usr/bin/env python3
"""Thin CLI bridge into rotor.parts.blade (blade0 = blade at 0 degrees).

Re-scripting of the legacy geo/blade0.geo now lives in the parametric
BladeGeometry class; this entry point simply forwards the CLI to it.
"""

import os
import sys

# Make the rotor package importable when run directly from pygeo/.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from rotor.parts.blade import main


if __name__ == "__main__":
    main()
