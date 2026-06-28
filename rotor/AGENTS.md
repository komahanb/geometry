# Agent Notes

- Geometry builders now live under the `rotor.parts` package so they can be imported directly (for example `from rotor.parts.hub4b import Hub4BGeometry`).
- Object-oriented modules must expose a clean public API: avoid leading underscores in function or variable names, keep geometry fully parametric, and embed short high-signal comments near complex steps.
- When exposing command-line entry points, call back into the object-oriented implementation rather than duplicating logic; this keeps `setup.py` integrations simple.
- Code generators should accept parameter overrides so automated agents can tune models without editing source files.
