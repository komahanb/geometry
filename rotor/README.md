# rotor

Parametric geometry for a helicopter **rotor hub assembly** — hub, blades,
swash plates, pitch links, push rods and connecting horns — built with gmsh and
meshed for structural / flexible-multibody analysis in TACS.

There are two layers: the original **legacy gmsh `.geo` scripts**, and an
**object-oriented Python port** (`rotor.parts`) that re-scripts the geometry
through the gmsh 4.15.2 Python API. New work should go in the Python port (see
[`AGENTS.md`](AGENTS.md)).

## Legacy `.geo` build

The legacy model is layered:

| File | Role |
|---|---|
| `Parameters.geo` | Global dimensions, expressed as ratios of `shaft_height` and `cutout_radius` |
| `Functions.geo` | Reusable primitives: `HollowCylinderX/Y/Z`, `PushRodX/Y/Z`, `AddPushRodHole`, `CutBlockFromBasePlate` |
| `naca.geo` | `NACA4` airfoil-section generator |
| `CreateComponents.geo` | One `Function Create<Part>` per component (hub, blade, swash plates, …) |
| `geo/<part>.geo` | Per-component driver: sets parameters, `Call`s the function, sets mesh options, outputs |
| `two_blade_assembly.geo`, `four_blade_assembly.geo` | Full multi-part assemblies |

> ⚠️ **gmsh 4.x compatibility.** The legacy `geo/*.geo` drivers set
> `Mesh.RemeshAlgorithm` / `Mesh.RemeshParametrization`, which were **removed in
> gmsh 4.x**. Opening them with gmsh 4.15.2 errors (`Unknown number option …`).
> Mesh a legacy component only with a matching older gmsh, or use the Python
> port below (which skips the dead options).

```bash
# Legacy command-line meshing (older gmsh):
gmsh geo/hub4b.geo -3 -o geo/hub4b.msh
```

## Python port — `rotor.parts`

`rotor/parts/` holds parametric **geometry classes** that rebuild each
component with `gmsh.model.occ.*`. Shared layers are ported once:

| Module | Ports |
|---|---|
| `parameters.py` | `Parameters.geo` — `rotor_parameters(overrides)` returns the full derived dimension dict |
| `primitives.py` | `Functions.geo` — `hollow_cylinder`, `add_push_rod_hole`, `cut_block_from_base_plate` |
| `airfoil.py` | `naca.geo` — `naca4_profile(occ, section)` |
| `cli.py` | Shared CLI / build / export / mesh lifecycle used by every part |

### Ported components

Every `CreateComponents.geo` component now has a parametric `rotor.parts`
class.  Azimuthal variants (the 90/180/270 blades and caps, the 120/210/300
pitch links, …) are subclasses of a base part that only override a placement
angle, so they reuse one build recipe.

| Part | Class(es) | Legacy source | Status |
|---|---|---|---|
| Four-blade hub | `Hub4BGeometry` | `CreateFourBladeHub` | ✅ ported |
| Two-blade hub | `DoubleBladeHubGeometry` | `CreateDoubleBladeHub` | ✅ ported |
| Base plate | `BasePlateGeometry` | `CreateBasePlate` | ✅ ported |
| Blade (+ 90/180/270, blunt) | `BladeGeometry`, `Blade90/180/270Geometry`, `BluntBladeGeometry` | `CreateBladeX/Y/NegativeX/NegativeY` | ✅ ported |
| Blade caps (0/90/180/270) | `BladeCap0/90/180/270Geometry` | `CreateBladeCapX/Y/NegativeX/NegativeY` | ✅ ported |
| Lower pitch link (+ 120/210/300) | `PitchLinkGeometry`, `LowerPitchLink120/210/300Geometry` | `CreateLowerPitchLink` | ✅ ported |
| Upper pitch link (+ 120/210/300) | `UpperPitchLinkGeometry`, `UpperPitchLink120/210/300Geometry` | `CreateUpperPitchLink` | ✅ ported |
| Push rods (90/180/270) | `PushRod90/180/270Geometry` | `CreatePushRod90/180/270` | ✅ ported |
| Push horns (lower/upper) | `LowerPushHornGeometry`, `UpperPushHornGeometry` | `CreateLower/UpperPushHorn` | ✅ ported |
| Centre sphere | `SphereGeometry` | `CreateSphere` | ✅ ported |
| Upper swash plate (2-arm) | `DoubleUpperSwashPlateGeometry` | `CreateDoubleUpperSwashPlate` | ✅ ported |
| Upper swash plate (4-arm) | `FourUpperSwashPlateGeometry` | `CreateFourUpperSwashPlate` | ✅ ported |
| Lower swash plate | `LowerSwashPlateGeometry` | `CreateLowerSwashPlate` | ✅ ported |

> **Notes.** The three swash plates share one `swashplate.py` recipe (a
> connector arm fused to the disc, copied to its azimuths, with a spherical
> recess scooped from the centre).  Push rods are built in a canonical frame
> and rotated into place to dodge a gmsh 4.x periodic-seam meshing bug on
> world-x-aligned cylinders.  The blunt blade reproduces the standalone
> `blunt_blade/` section because the rotor model's `geo/blade_blunt.geo`
> referenced an undefined `CreateBladeBluntEdge`.

### Command-line use

Each component has a CLI, both as a module and via its `pygeo/` bridge:

```bash
# From the rotor/ directory (so the `rotor` package is importable):
python -m rotor.parts.baseplate --mesh --mesh-file /tmp/bsp.msh

# Or via the pygeo bridge (adds rotor/ to sys.path itself):
python pygeo/bsp.py    --mesh                 # 3-D mesh -> ../mesh/bsp.msh
python pygeo/blade0.py --export blade0.brep   # geometry only -> BREP
python pygeo/lpl30.py  --export lpl30.iges    # geometry only -> IGES
python pygeo/lpl30.py  --param pitchlink_length=0.3 --mesh   # override a parameter
```

CLI flags (shared by all parts): `--mesh`, `--mesh-dim {1,2,3}`, `--mesh-file PATH`,
`--export PATH` (repeatable; format from extension: `.brep`/`.iges`/`.step`/`.bdf`/`.msh`),
`--param NAME=VALUE` (repeatable), `--show` (open a viewer).

> **`--show` and the pip `gmsh` wheel.** The PyPI `gmsh` wheel is built
> *without* the FLTK GUI (`gmsh.fltk.isAvailable()` is 0), so `--show` cannot
> open a window in-process.  When that is the case it transparently writes the
> model to a temporary `.brep` and launches a standalone GUI `gmsh` binary on
> it (e.g. a system `/usr/bin/gmsh`, found on `PATH`).  If no GUI gmsh is
> installed it prints a warning instead of failing silently — export the
> geometry with `--export`/`--out` and open it in a GUI gmsh or FreeCAD.

### Programmatic use

```python
from rotor.parts import available_parts, create_part
from rotor.parts.blade import BladeGeometry

available_parts()                         # ['hub4b', 'hub2b', 'baseplate', 'blade', 'blade90', ..., 'usp2b', 'usp4b', 'lsp']
geom = create_part("blade", {"blade_tip_radius": 2.5})
# or: geom = BladeGeometry({"blade_tip_radius": 2.5})

import gmsh
gmsh.initialize()
volume_tag, named_points = geom.build()   # build geometry in the current model
gmsh.model.mesh.generate(3)
gmsh.write("blade.msh")
gmsh.finalize()
```

Overrides accept any base or derived key from `parameters.py` (e.g.
`cutout_radius`, which re-derives every dependent dimension) plus part-specific
keys (`aoffset`/`theta` for the pitch link; `blade_chord`, `blade_tip_radius`,
`azimuth`, … for the blade).

## Worked example — assembling the four-blade rotor

`assemble.py` builds the **complete four-blade rotor** from the parametric
parts and is the recommended starting point.  Each part builds in its own gmsh
model, so the assembly is produced exactly like the legacy `brep/assemble.geo`:
export every component to BREP, then merge the BREPs into one model.  The
component list (`FOUR_BLADE_ROTOR`, 26 bodies) mirrors `four_blade_assembly.geo`
— base plate, four-blade hub, sphere, both swash plates, three push rods, the
two push horns, four blades + caps, and the four lower/upper pitch links.

```bash
# From the rotor/ directory:
python assemble.py --out /tmp/rotor.brep            # merged geometry (26 solids)
python assemble.py --out /tmp/rotor.step            # STEP instead (format by ext)
python assemble.py --breps /tmp/rotor_parts/        # also keep the per-part BREPs
python assemble.py --param cutout_radius=0.5 \
                   --out /tmp/rotor_big.brep         # rescale the whole rotor
python assemble.py --mesh --out /tmp/rotor.msh       # 3-D mesh the assembly (slow)
python assemble.py --show                            # open a viewer (see note below)
```

The merged model holds 26 solids spanning `x,y ∈ [-2, 2]` (blade tips at the
2 m tip radius) and `z ∈ [0, 1]` (the shaft height).

Programmatic use mirrors the CLI:

```python
import gmsh
from assemble import assemble, FOUR_BLADE_ROTOR, export_breps

gmsh.initialize()
solids = assemble(FOUR_BLADE_ROTOR)          # -> [(3, tag), ...] in model "assembly"
# assemble(FOUR_BLADE_ROTOR, {"cutout_radius": 0.5})   # with parameter overrides
# export_breps(FOUR_BLADE_ROTOR, "parts/")             # just the per-part BREPs
gmsh.write("rotor.brep")
gmsh.finalize()
```

Build a different rotor by passing your own part list (any names from
`available_parts()`) — e.g. the two-blade rotor swaps `hub4b`→`hub2b`, `usp4b`→
`usp2b`, and drops the 90/270 blades, caps and their pitch links.

## Assembly and inertial properties

The downstream multibody workflow consumes per-component BREP/mesh:

- `brep/` — exported `*.brep` solids and `assemble.geo`, which `Merge`s the
  individual BREPs into one model.
- `brep/inertial.py` — opens each BREP in **FreeCAD** and writes mass / centre
  of mass / inertia tensor `.dat` files.
- `setup.py` — the GEO → ANALYSIS pipeline: generate BREP (`gmsh -0`), compute
  solid properties (FreeCAD), and generate BDF meshes (`gmsh -2`) for a list of
  bodies. *(Written for legacy gmsh / Python 2; kept for reference.)*

Helper scripts:

```bash
./grep.sh model.bdf         # count CQUAD / CTRIA / CBAR elements
./remove_cbar.sh model.bdf  # strip 1-D CBAR elements from a BDF (in place)
```

## Layout

```
rotor/
├── Parameters.geo Functions.geo naca.geo CreateComponents.geo  # legacy shared
├── *_blade_assembly.geo                                        # legacy assemblies
├── geo/      # legacy per-component .geo drivers (+ some generated meshes)
├── pygeo/    # thin CLI bridges into rotor.parts (and loaders for unported parts)
├── rotor/parts/   # the parametric OO Python port (the supported path)
├── brep/     # exported BREP solids, assemble.geo, inertial.py
└── mesh/     # generated meshes
```
