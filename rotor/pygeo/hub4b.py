#!/usr/bin/env python3
"""Wrapper that defers to rotor.parts.hub4b for backwards compatibility."""

import os
import sys

# Make the rotor package importable when run directly from pygeo/.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from rotor.parts.hub4b import main


if __name__ == "__main__":
    main()
