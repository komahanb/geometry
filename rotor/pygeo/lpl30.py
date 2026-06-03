#!/usr/bin/env python3
"""Thin CLI bridge into rotor.parts.pitchlink (lpl30 = lower pitch link).

Re-scripting of the legacy geo/lpl30.geo now lives in the parametric
PitchLinkGeometry class; this entry point simply forwards the CLI to it.
"""

import os
import sys

# Make the rotor package importable when run directly from pygeo/.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from rotor.parts.pitchlink import main


if __name__ == "__main__":
    main()
