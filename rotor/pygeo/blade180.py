#!/usr/bin/env python3
"""Thin CLI bridge into rotor.parts.blade (blade180 = 180-degree blade).

The geometry now lives in the parametric rotor.parts classes; this entry point
forwards the CLI to it (replacing the old auto-generated .geo loader).
"""

import os
import sys

# Make the rotor package importable when run directly from pygeo/.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from rotor.parts.blade import main_blade180 as main


if __name__ == "__main__":
    main()
