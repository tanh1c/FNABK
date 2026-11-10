# Phase A static review follow-up

Date: 2026-10-31  
Scope: local source and manifest review, followed by inspection of a detached Phase A preview in Roblox Studio Edit mode. No asset upload, place save or publication was performed.

## Disposition

The original review correctly identified contradictions in the first estimated layout. The user then explicitly requested a schematic spacing/circulation pass and said exact 1:1 dimensions are not required. CR-003 authorizes those adjustments in the detached Phase A model only. The revised layout remains **unverified, not ready for spatial sign-off or gameplay integration**, and must not be described as a 1:1 reconstruction.

## Source availability and safety audit

The review's H-04/M-06 “source not attached” limitation applies to its attachment set. The implementation is present in this repository under `src/server/CampusPhaseA/`, and `default.project.json` maps `src/server` into `ServerScriptService/FNABKServer`.

- `CampusBuilder.Build` checks whether the requested model name already exists as a direct child of the chosen parent. It does not delete or replace an existing instance.
- The new root model is parented to the requested parent only after its contents are generated. The builder is not called by `Bootstrap.server.luau` or any other `src` entry point, so the detached preview is not automatically inserted into the runtime map. This confirms source-level isolation, not runtime execution behavior.
- Site canvas, road/boundary, open-area, building-footprint and marker Part constructors set `Anchored = true`, `CanCollide = false`, `CanTouch = false` and `CanQuery = false`.
- The builder splits the site canvas, overlong road slabs and long parcel edges so no generated `BasePart.Size` dimension exceeds Roblox's documented 2,048-stud cap ([BasePart documentation](https://create.roblox.com/docs/reference/engine/classes/BasePart)).
- The original geometry-only source implied 64 BaseParts. The current source adds circulation slabs; its source-derived count and manifest geometry are recorded below. The 23 building footprints remain separate Models.

## Original geometry findings and current follow-up

The initial findings below describe the layout reviewed before CR-003 and are retained as history:

- Gate1, Spawn and Exit are outside the estimated parcel.
- B1 and C6 cross the estimated parcel boundary; C6's center is outside it.
- The five reported building pairs overlap: A1/Kiosk8, A2/A4, A2/A5, B8/C2 and C3/C4.
- The listed building/open-area and building/path intersections are present in the current estimates.

The original five building overlaps and path/area intersections have now been addressed by estimated center/size adjustments, explicit pedestrian paths and marker relocation. This is an intentional schematic exception to the prior recommendation to wait for survey data: the user approved logical spacing over 1:1 fidelity. The polygon's area matching the published approximate campus area does not establish the actual boundary; all adjusted dimensions remain estimates. See CR-003 and the static check results below.

### Spacing/circulation static check — 2026-10-31

- 23 building footprints; no positive-area building/building intersections.
- Closest building pair is C2/C3 at 6.0 m edge clearance; all other pairs meet or exceed the same nominal target.
- No positive-area building/pedestrian-path or building/open-area intersections.
- 33 pedestrian-path slabs form one connected schematic route network; their narrow dimensions range from 6 m to 12 m.
- All 16 markers fall inside their intended Phase A building/path bounds.
- The Studio preview contains 93 BaseParts; the largest measured axis is 1,673.57 studs, below the 2,048-stud engine limit.
- These are local geometric checks of manifest rectangles and source segmentation, not Studio gameplay, visual sign-off, survey validation, collision, NPC navigation or performance tests.

## Visualization correction

The review's M-02 finding is valid. The SVG generator previously painted the parcel over the roads. It now draws the parcel fill first, then roads and map features, and redraws the boundary stroke on top. The output uses the new filename `TopDownValidation.reviewed.svg` so the earlier `TopDownValidation.svg` remains untouched. `-SkipLuauModule` allows refreshing the SVG without rewriting generated Luau.

The Round 2 size finding is also valid. The canvas, To Hien Thanh street slab, and first parcel edge are split into contiguous, anchored segments. The original geometry-only source produced 64 BaseParts; the updated source produces 93 after adding circulation slabs. Studio Edit inspection confirmed the count and size limit. The new preview was added as `_v4_Walkable`; earlier previews remain intact.

## Remaining decisions

- Confirm which physical entrance is the main entrance and which one should be gameplay `Gate1`.
- Supply a dimensioned parcel/site plan or measured control points, plus verified building footprints and path widths.
- Add floor, elevation and facing metadata only when interiors and playable entrances are designed.
- Reserve the Blue Professor cameo marker during a later reviewed gameplay-integration phase; it is not required for this detached Phase A graybox.

## Review steps

1. Run `powershell -ExecutionPolicy Bypass -File tools/Generate-CampusPhaseA.ps1`.
2. Open `TopDownValidation.reviewed.svg` in a browser or SVG viewer. Expected result: internal roads remain visible over the gray parcel fill, and the amber parcel outline remains visible over roads and area blocks.
3. In Studio Edit mode, sync the updated Luau source and build a fresh preview named `FNABK_Campus_PhaseA_Graybox_v4_Walkable` at `(12000, 1000, 6000)`. Inspect the disconnected historical previews separately; do not overwrite or remove them.
4. Confirm all footprints remain visually separate, the major campus lanes connect to the access paths, each marker matches its revised footprint/route, every part axis is at most 2,048 studs, and all preview parts are anchored and non-collidable.
5. These checks apply only to the detached schematic. Avatar movement, collision clearance, Mimic pathfinding and performance remain untested; do not save or publish the place as part of this pass.
