# geometry

Parametric CAD geometries built with [gmsh](https://gmsh.info), meshed for
finite-element / multibody analysis (notably with
[TACS](https://github.com/smdogroup/tacs)). Each model is defined as a gmsh
geometry script and turned into a **mesh** (`.msh` / NASTRAN `.bdf`) and, where
needed, **BREP** and **IGES** CAD files.

The repository holds two generations of geometry definitions:

- **Legacy gmsh `.geo` scripts** — the original models, written for an older
  gmsh release. They use `SetFactory("OpenCASCADE")`, `Include`/`Call`,
  boolean primitives and `Coherence`.
- **Python ports** — re-scripted geometry that drives gmsh through its
  **Python API (gmsh 4.15.2)**. The largest port lives under
  [`rotor/`](rotor/README.md) as the object-oriented `rotor.parts` package.

> **Why the port?** The legacy `.geo` files set mesh options that were removed
> in gmsh 4.x (e.g. `Mesh.RemeshAlgorithm`, `Mesh.RemeshParametrization`).
> Opening them with gmsh 4.15.2 errors out. The Python ports rebuild the
> geometry directly through the API, skip the dead options, and expose
> parametric, importable builders. **For the rotor, the Python builders are
> the supported path** — see `rotor/README.md`.

## Prerequisites

- **gmsh 4.15.2** with the Python API: `pip install gmsh` (the `gmsh` module
  and the `gmsh` CLI). Check with `gmsh --version`.
- **numpy** (used by the helper scripts).
- *Optional:* **FreeCAD** (for solid inertial properties; the rotor's
  `setup.py` / `brep/inertial.py` add `/usr/lib/freecad/lib` to the path).

## The workflow: geo → mesh / BREP / IGES

A gmsh geometry (a `.geo` file or a Python script) is the single source; gmsh
emits the analysis artifacts.

### From the command line (legacy `.geo`)

```bash
gmsh model.geo -3 -o model.msh     # 3-D mesh (use -2 for surface meshes)
gmsh model.geo -0 -o model.brep    # geometry only -> BREP
gmsh model.geo -0 -o model.iges    # geometry only -> IGES
```

### From the Python API (gmsh 4.15.2)

```python
import gmsh
gmsh.initialize()
gmsh.open("model.geo")              # or build geometry via gmsh.model.occ.*
gmsh.model.mesh.generate(3)
gmsh.write("model.msh")             # format inferred from the extension:
gmsh.write("model.brep")            # .msh .bdf .brep .iges .step ...
gmsh.finalize()
```

`.brep` stores the full solid; `.iges` is a surface-exchange format and carries
the boundary surfaces (not solids).

## Shared tools (repository root)

| Script | Purpose | Invocation |
|---|---|---|
| `generate_mesh.py` | Mesh a `.geo` to a NASTRAN BDF, normalising component tags | `python generate_mesh.py --geometry=model.geo --mesh=model.bdf` |
| `generate_bc.py` | Extract boundary conditions (SPC) from a BDF | `python generate_bc.py --bdf_file=model.bdf --boundary_components=4` |
| `dat2gmsh.py` | Convert an airfoil coordinate `.dat` to a gmsh `.geo` | `python dat2gmsh.py airfoil.dat` |

## Subprojects

Each directory is a self-contained model: a `.geo` source (sometimes a Python
port) plus generated meshes.

| Directory | Model |
|---|---|
| [`rotor/`](rotor/README.md) | Helicopter rotor hub assembly (hub, blades, swash plates, pitch links, push rods) — **largest model; has the OO Python port** |
| `airfoil/` | NACA airfoil section + test geometry |
| `full-wing/` | Full wing with tagged components |
| `blunt_blade/` | Blade with a blunt NACA profile |
| `plate/` | Flat structural plate |
| `holed-shell/`, `3d-holed-shell/` | Plate / shell with cutouts |
| `box/` | Extruded / recombined structured box |
| `canadarm1/`, `canadarm-cylinder/` | Robotic-arm components |
| `tail-sitter/` | Tail-sitter aircraft |
| `tecnam/` | Tecnam aircraft geometry |
| `fourbar/` | Four-bar linkage |
| `tutorial/` | Educational examples |

## File types

| Extension | Meaning |
|---|---|
| `.geo` | gmsh geometry script (text) |
| `.msh` | gmsh mesh (here written in NASTRAN BDF format, `Mesh.Format=31`) |
| `.bdf` | NASTRAN bulk-data mesh (for TACS) |
| `.brep` | OpenCASCADE solid (BREP) |
| `.iges` | IGES surface CAD exchange |
| `.inp` / `.dat` | inertial properties / initial conditions for multibody analysis |
