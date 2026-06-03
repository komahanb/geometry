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

| Part | Class | Legacy source | Status |
|---|---|---|---|
| Four-blade hub | `Hub4BGeometry` | `CreateFourBladeHub` | ✅ ported |
| Base plate | `BasePlateGeometry` | `CreateBasePlate` | ✅ ported |
| Pitch link | `PitchLinkGeometry` | `CreateLowerPitchLink` | ✅ ported |
| Blade | `BladeGeometry` | `CreateBladeX` | ✅ ported |
| Swash plates, push rods, horns, caps, sphere, … | — | `CreateComponents.geo` | ⏳ pending |

The remaining `geo/*.geo` components still have only thin `pygeo/*.py` loaders;
port them to `rotor.parts` classes following the four above.

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
`--param NAME=VALUE` (repeatable), `--show` (FLTK viewer).

### Programmatic use

```python
from rotor.parts import available_parts, create_part
from rotor.parts.blade import BladeGeometry

available_parts()                         # ['hub4b', 'baseplate', 'blade', 'pitchlink']
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
