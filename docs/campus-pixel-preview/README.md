# FNABK campus pixel preview — Phase A offline workflow

This package builds a detached Roblox-native outline preview from the latest user-supplied pixel geometry. It is a provisional relative layout, not a surveyed or 1:1 campus reconstruction. It follows CR-002's detached-review boundary and supports AC-01/AC-11 documentation only; it does not change the playable A01 campus or gameplay systems.

## Source files

- `CampusPixelGeometry.json` is the canonical source, copied byte-for-byte from the supplied JSON. Keep its pixel polygon vertices unchanged.
- `CampusCenters_PIXEL_ONLY.csv` and `CampusTopDown_VECTOR_ONLY_source.svg` are local source companions used for ID, vertex-count, and vector-footprint cross-checks.
- `GeometryAdjustments.json` is the separate, source-guarded overlay for the three user-directed preview corrections. Do not edit canonical source geometry to make these changes.
- No reference image is uploaded, embedded into Roblox, sent to a cloud service, or used as a Roblox asset.

## Coordinate conversion

The preview scale is `previewStudsPerPixel = 1.0`. The current detached layout is intentionally mirrored left-to-right because the user reported that the Studio map appeared reversed. Canonical pixel vertices remain untouched; the mirror is applied only when transforming the preview. Image pixel `(imageWidthPx, imageHeightPx)` is the local Roblox origin `(X=0, Z=0)`. Local `+X` points to image left after the mirror, and local `+Z` points to image up. For every pixel point:

```text
xStuds = (imageWidthPx - pixelX) * previewStudsPerPixel
zStuds = (imageHeightPx - pixelY) * previewStudsPerPixel
```

`metersPerPixel` remains null. No geographic north alignment or real-world metric accuracy is claimed. The scale does not use v6/v7 coordinates. Transformed coordinates are rounded to six decimal places; the canonical pixel data remains unchanged. The generated top-down SVG and Studio preview both show the mirrored result so left/right can be compared consistently.

## Offline generation and validation

Python 3 with its standard library is sufficient; no packages are installed.

```powershell
python tools/Generate-CampusPixelPreview.py --scale 1.0
```

To preview another visualization scale, pass another positive value, for example `--scale 0.5`. This deterministically regenerates the transformed manifest, transform record, mapping, SVG, validation report, and Luau manifest module. The canonical geometry JSON and its source SVG/CSV companions are read-only inputs to the generator. Overlay entries include expected source values, so the build stops if the canonical map later changes and an adjustment needs review.

The generator checks polygon vertex counts, duplicate IDs, non-zero area, self-intersections, source-image bounds, pairwise building overlap candidates, B1's courtyard sample, campus-boundary containment, CSV IDs/categories/vertex counts, supplied vector-SVG footprints, generated SVG footprints, unresolved IDs, and estimated BasePart dimensions/counts. It also verifies B8/B9 spacing and parallel orientation, Entrance1's recorded rightward shift, and that B4/Canteen remain separate neighboring building polygons.

## Polygon representation

`CampusPreviewManifest.json` records each unchanged canonical ring in `sourcePolygonPixels`, the effective preview ring in `polygonPixels`, and its corresponding `polygonStuds` ring. For unadjusted features, the two pixel rings are identical. `CampusPreviewTopDown.svg` is generated from effective preview rings and validated vertex-for-vertex against the manifest; the supplied vector SVG is checked against the unchanged canonical JSON.

The current explicit preview adjustments are:

- B9 is moved down enough to leave about 6 source pixels between it and B8, and aligned parallel to B8's long edge.
- Entrance1 is shifted 12 source pixels to the right.
- Canteen remains a separate footprint beside B4. Its source category remains `area`, while the preview category override renders it as a building.

These are visualization-space corrections based on the user's latest direction; they do not claim surveyed campus geometry. Review them in `GeometryAdjustments.json` before changing the output.

The Studio builder represents each polygon as a closed set of thin horizontal edge ribbons. It does not replace a concave polygon with its bounding rectangle, and it does not fill any polygon interior. Therefore the U-shaped B1 remains an open U; its courtyard has no building ribbons across the recess. A separate non-collidable canvas board is only a background for viewing the plan and is not a building footprint or playable floor.

## ID reconciliation

See [`BuildingIDMapping.md`](BuildingIDMapping.md). The preview classifies 23 footprints as buildings, including new B3, B11, B12, Facility7, KioskOISP, and Canteen. The six existing IDs without exact pixel building counterparts remain unresolved. Facility7 is not B7; KioskOISP is not Kiosk8. B4 and Canteen are separate neighboring buildings, as confirmed by the user.

The existing 16 gameplay marker IDs remain in `CampusPreviewManifest.json` with null preview coordinates. The three pixel entrances—Entrance1, Entrance2 and Entrance3—are a separate marker set. Existing metric marker coordinates are excluded from this pixel map.

## Source modules

- `src/server/CampusPixelPreview/CampusPreviewManifest.luau` is generated from the transformed manifest.
- `src/server/CampusPixelPreview/PolygonFootprintGenerator.luau` builds one Model per polygon, then one anchored ribbon Part per edge segment.
- `src/server/CampusPixelPreview/CampusBuilder.luau` creates the unique detached root `FNABK_Campus_PixelPreview_v1`, its category Models, a tiled canvas board and the three entrance marker Models. It refuses to replace an existing output with the same name.

These modules are not required by `Bootstrap.server.luau`; they create no scripts, events, gameplay markers, missions, NPCs or runtime map changes. They create only anchored, non-collidable, non-touchable and non-queryable BaseParts. Each long edge and canvas tile is split so no generated BasePart dimension exceeds 1,800 studs.

## Studio MCP generation — built after separate approval

The user separately authorized a detached Studio scene build on 2026-11-01. In `FNABK-AC06-A3-20261028-v2.rbxlx`, Studio was in Edit mode, the Rojo-synced source modules were present, and the target root did not already exist. `CampusBuilder.Build` created `Workspace/FNABK_Campus_PixelPreview_v1` at `CFrame.new(1200, 0, 1200)`. The offset keeps the 1.0-scale preview away from the current roughly 300-stud runtime map; it is only a detached world placement, not a scale calibration. See [`StudioBuildRecord.md`](StudioBuildRecord.md) for the structural audit and visual-review status.

The executed Luau was:

```lua
local serverScripts = game:GetService("ServerScriptService")
local previewFolder = serverScripts:WaitForChild("FNABKServer"):WaitForChild("CampusPixelPreview")
local campusBuilder = require(previewFolder:WaitForChild("CampusBuilder"))
local preview, result = campusBuilder.Build(workspace, CFrame.new(1200, 0, 1200))
assert(preview, result)
print("Pixel preview built", preview:GetFullName(), result.basePartCount, "BaseParts")
```

The Studio-side structural audit confirmed 57 feature Models, 23 building Models, three entrance Models and 270 BaseParts. All are anchored and non-collidable, non-touchable and non-queryable; no scripts are under the root. B8/B9's long-edge directions match, Entrance1's pixel X is 178, and B4/Canteen are separate Models. The automated screen capture returned a blank viewport, so visual confirmation remains in flow #14 of `MANUAL_CONFIRMATION.md`.

The place remains unsaved and unpublished. The builder refuses to replace an existing root. For any later revision, preserve this root and use a new versioned output name after reviewing the source changes; do not delete or overwrite this preview automatically.

## Port the Phase C buildings to the pixel layout

`src/server/CampusPixelPreview/PixelBuildingPorter.luau` copies the detached v6 Phase C architecture to the pixel map without changing the source map or `Bootstrap.server.luau`. The current review root is `Workspace.FNABK_Campus_PixelBuildings_PhaseC_v6`, built at `(4300, 0, 1200)`. Its aligned outline comparison is `Workspace.FNABK_Campus_PixelPreview_v1_B1Review_v6`, offset +3100 studs on X from the original preview. The prior v5 root and original outline remain in Workspace, untouched and available for comparison; v1–v4 remain in ServerStorage.

The port contains 23 logical building Models: 17 exact ID matches and six separate models derived from visual templates. B3, B11, B12, Canteen, Facility7, and KioskOISP keep their own identities; B7, B10, Facility1, Facility2, and Kiosk8 remain unresolved in the source-ID mapping. B1 is represented by one `B1_ContinuousBuilding` Model. Three temporary rectangular generation regions are flattened into it; they do not remain as three child building Models. The connecting bar overlaps both arms by 2.25 studs while its outer edge remains pinned to the traced footprint. Six anchored, collidable floor connectors bridge source-floor setbacks across both joins on levels 1–3. The three cloned source entrances are removed, then one 12-stud-wide by 8.9-stud-high doorway is cut into the center of the connecting bar's outside edge, opposite the U opening. The courtyard remains open.

Before creating a root, the porter compares the chosen manifest's mirror state and scale with the existing `FNABK_Campus_PixelPreview_v1` outline and aborts on a mismatch. The optional `manifestOverride` parameter lets an Edit-mode build use a fresh manifest snapshot instead of Studio's possibly cached `require` result.

The user confirmed these floor counts for the detached preview. The ground floor counts as one floor; the measurements and elevations remain provisional.

| ID | Confirmed floors | Form or specialization |
| --- | ---: | --- |
| A1 | 3 | Academic building |
| A2 | 3 | Library |
| A3 | 2 | Academic building |
| A4 | 5 | Academic building |
| A5 | 4 | Academic building |
| B1 | 3 | U-shaped academic complex |
| B2 | 3 | Academic building |
| B3 | 2 | Academic building |
| B4 | 6 | Academic building |
| B6 | 3 | Academic building |
| B8 | 3 | Academic building |
| B9 | 3 | Academic building |
| B11 | 2 | Academic building |
| B12 | 2 | Academic building |
| C1 | 2 | Mechanical workshop with a partial upper inspection floor and stairs |
| C2 | 1 | Mechatronics assembly workshop |
| C3 | 1 | Mechanical workshop |
| C4 | 5 | Academic building |
| C5 | 5 | Academic building |
| C6 | 5 | Academic building |
| Canteen | 2 | Canteen |
| Facility7 | 3 | Auxiliary building |
| KioskOISP | 1 | Kiosk |

The workshop generator uses Roblox-native Parts. C1 is a high-bay mechanical hall with machinery and an upper service deck; C2 is a low mechatronics lab with guarded test cells; C3 is a low mechanical shop with red portal frames, crane rail, and a sawtooth roof. These are visual prototypes, not surveyed interiors.

### Generate in Studio Edit

The v6 root has been created in Edit mode. For a future versioned rebuild, keep the place `FNABK-AC06-A3-20261028-v2.rbxlx` in Edit mode and sync the Rojo source first. Clone the manifest ModuleScript before requiring it so Studio cannot reuse an older required table; pass the snapshot explicitly to `Build`:

   ```lua
   local folder = game.ServerScriptService.FNABKServer.CampusPixelPreview
   local manifestModule = folder.CampusPreviewManifest:Clone()
   manifestModule.Name = "_CampusPreviewManifest_Snapshot"
   manifestModule.Parent = folder
   local manifest = require(manifestModule)
   manifestModule:Destroy()

   local porterModule = folder.PixelBuildingPorter:Clone()
   porterModule.Name = "_PixelBuildingPorter_Snapshot"
   porterModule.Parent = folder
   local porter = require(porterModule)
   porterModule:Destroy()

    local outlineSource = workspace:WaitForChild("FNABK_Campus_PixelPreview_v1")
    assert(workspace:FindFirstChild("FNABK_Campus_PixelBuildings_PhaseC_v6") == nil)
    assert(workspace:FindFirstChild("FNABK_Campus_PixelPreview_v1_B1Review_v6") == nil)
    local root, result = porter.Build(
       workspace,
        CFrame.new(4300, 0, 1200),
       workspace.FNABK_Campus_PhaseC_Interiors_v6_Walkable,
       "FNABK_Campus_PixelBuildings_PhaseC_v6",
       manifest
   )
   assert(root, result)
   print(result.BuildingModelCount, result.ExactIDModelCount, result.TemplateDerivedModelCount, result.BasePartCount)

    local outline = outlineSource:Clone()
    outline.Name = "FNABK_Campus_PixelPreview_v1_B1Review_v6"
    outline:PivotTo(outline:GetPivot() + Vector3.new(3100, 0, 0))
    outline.Parent = workspace
   ```

The v6 root reports 23 logical buildings, 19,032 BaseParts, zero unanchored parts, zero scripts and one B1 body Model. Its B1 entrance center is `(5457.125, 0, 1723.500)` in the detached preview, with a 12 by 8.9 stud opening. The original v5 root remains beside the original outline; the comparison copy is offset so the two versions do not overlap. The builder refuses to replace an existing root. Horizontal dimensions are fitted to pixel footprints while source-based vertical geometry and interiors are retained or adjusted to the confirmed floor counts. This can distort proportions and does not establish player traversal. Leave the place unsaved and unpublished pending the reviews in `docs/MANUAL_CONFIRMATION.md`.

### Mirror the existing Studio roots after changing orientation

On 2026-11-01, the existing Edit-session roots were mirrored in place across the canvas center (`world X = 1924` for the 1.0 scale and origin `(1200, 0, 1200)`). `PixelMapMirror.luau` preflights both roots, requires anchored native geometry, refuses repeat application, and does not include v6 or runtime gameplay geometry. The Studio roots now report `HorizontalMirrorApplied=true`. The command below is for an older unmirrored copy only; it will refuse to mirror these current roots again.

```lua
local folder = game.ServerScriptService.FNABKServer.CampusPixelPreview
local mirror = require(folder.PixelMapMirror)
local counts = mirror.MirrorDetachedPixelMap(workspace, 1924)
print(counts.FNABK_Campus_PixelPreview_v1, counts.FNABK_Campus_PixelBuildings_PhaseC_v1)
```

The two current roots retain their names and instance counts; the operation reflects part positions/orientations, attachment offsets, and left/right-facing surface details. Future roots built from the regenerated manifest are already mirrored and must not run this migration module.

The Studio build results are recorded in `StudioBuildRecord.md`. Flow #15 in `docs/MANUAL_CONFIRMATION.md` covers visual identity, courtyard, path clearance, collision and manual traversal. No reference assets are uploaded or imported.

## Validation record

See [`GeometryValidationReport.md`](GeometryValidationReport.md), [`PerformanceAndCollisionChecklist.md`](PerformanceAndCollisionChecklist.md), and [`StudioBuildRecord.md`](StudioBuildRecord.md). The report records the exact canonical source hash and adjustment overlay hash, and distinguishes source-vector validation from the corrected preview SVG. The detached preview was created in Studio Edit; the runtime map remains untouched.
