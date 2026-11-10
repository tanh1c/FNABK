# HCMUT Campus 1 — Phase A layout and Phase B/C building previews

This is an isolated, source-generated campus preview. Phase A establishes the top-down footprint layout; Phase B adds multi-storey low-poly exterior shells over those same footprints. Neither phase replaces the current FNABK gameplay map or connects to the gameplay bootstrap. The spacing, story counts and dimensions are estimates, not a verified 1:1 reconstruction.

## Coordinate system

- Units in the JSON manifests are meters.
- Origin: estimated southwest corner of the campus parcel outline.
- `+X`: east, `+Z`: north, `+Y`: up.
- The supplied plan-map north arrow establishes local north; the map has no verified geodetic bearing.
- Roblox conversion: `1 stud = 0.28 m`, so the builder uses `25/7` studs per meter. Source: [Roblox units](https://create.roblox.com/docs/physics/units).
- Reported campus land area is approximately `14.08 ha`; the parcel polygon and 602.6 m by 250 m envelope are estimated. Source: [HCMUT official campus facilities statement](https://fme.hcmut.edu.vn/thong-tin-chinh-thuc-ve-dinh-huong-phat-trien-co-so-vat-chat-va-ha-tang-dao-tao-nghien-cuu-cua-truong-dai-hoc-bach-khoa-dhqg-hcm.html).

## Source files

- `CampusManifest.json` is the canonical building-footprint, estimated-story, per-building architecture palette, open-area, road and site-outline manifest.
- `Markers.json` is the canonical gameplay-anchor manifest. It does not change or relocate any current gameplay object.
- `src/server/CampusPhaseA/CampusManifest.luau` is generated from those JSON files.
- `src/server/CampusPhaseA/CampusBuilder.luau` builds the detached preview. Building massing and facade detail, area, road/boundary and marker logic are kept in separate modules.
- `src/server/CampusPhaseA/BuildingStyleResolver.luau` maps each building ID to its palette, facade archetype, balcony pattern and room type.
- `src/server/CampusPhaseA/FacadeGenerator.luau` creates native-Part window bands, mullions and sunshades; `BuildingFacadeDetailGenerator.luau` adds signs, entrance lights, canopies, balconies and small roof details.
- `src/server/CampusPhaseA/WalkableInteriorGenerator.luau`, `ClassroomLayoutGenerator.luau` and `InteriorFurnitureGenerator.luau` create the floor slabs, long-axis corridor, separate rooms, stairs and room-specific furniture.
- `TopDownValidation.reviewed.svg` is the current generated plan-view comparison aid. The earlier `TopDownValidation.svg` is retained unchanged.

Regenerate the Luau data module and top-down SVG after editing either JSON file:

```powershell
powershell -ExecutionPolicy Bypass -File tools/Generate-CampusPhaseA.ps1
```

The generator writes the Luau manifest and the versioned `TopDownValidation.reviewed.svg`. To refresh only the SVG without rewriting Luau, add `-SkipLuauModule`.

## Build the latest Phase B preview in Roblox Studio

1. Keep Studio in **Edit** mode and connect the existing Rojo project. The project already maps `src/server` into `ServerScriptService/FNABKServer`.
2. Run the exporter above, then wait for Rojo to sync.
3. In the Studio command bar or the connected Studio MCP Luau executor, build a fresh detached Phase B preview away from the active map. Keep all earlier previews intact:

   ```lua
   local builder = require(game.ServerScriptService.FNABKServer.CampusPhaseA.CampusBuilder)
   builder.Build(workspace, CFrame.new(16000, 1000, 6000), "FNABK_Campus_PhaseB_Exterior_v5_MultiStory")
   ```

4. Inspect `Workspace/FNABK_Campus_PhaseB_Exterior_v5_MultiStory`. The offset keeps the prototype out of the current playable area. Every preview part is anchored and non-collidable. The builder does not run automatically and does not touch `Bootstrap`, `CampusLayout`, mission services, remotes, or the current map.
5. Select the model and press **F** to frame it. Orbit the camera to compare elevations; `TopDownValidation.reviewed.svg` remains the plan-view reference.

The builder never overwrites or deletes existing instances. If the requested output name already exists, it stops with an error; use a new versioned name for another preview.

### Phase B exterior scope

- All 23 campus buildings remain separate Models and retain their Phase A footprints and positions.
- Each building now has an estimated 2–6 storeys, one main volume, a roof cap, a base plinth, low-part-count corner piers, window ribbons on four sides, and horizontal bands between floors.
- Story counts and typical floor heights are explicit estimates in `CampusManifest.json`; no elevation drawings or surveyed building heights were supplied.
- The windows and bands communicate the floor rhythm. They are not openings, walkable floor slabs, interior rooms, stairs, or collision proxies.
- Geometry uses native Parts only. It is anchored, non-collidable, non-touchable and non-queryable, so it cannot affect the live game's movement or gameplay.
- The historical `_v1`/`_v2`/`_v3`/`_v4` previews remain untouched. The new `_v5_MultiStory` preview is separate.

### Recorded local checks

- Detached Phase A v4 Studio structure: 93 BaseParts, including 23 separate building Models and 16 gameplay-marker Parts; MCP Edit inspection confirmed these historical counts. Phase B v5 has a separate count below.
- Phase B v5 was built and inspected in Studio Edit on 2026-10-31: 851 BaseParts total, including 781 building Parts across 23 separate Models and 16 named markers. The 89 estimated stories are distributed across those Models; zero scripts, zero unanchored/collidable/touchable/queryable parts, and zero parts over 2,048 studs were found. The largest axis was 536.72 studs. This structural check does not measure FPS or establish human style acceptance; flow #12 remains pending.
- Pre-refresh Phase C v6 baseline (2026-11-01) was built at `(22000, 1000, 6000)` without saving the place. Its original generic layout contained 5,429 BaseParts, 4,425 collidable parts, 23 separate buildings, 89 estimated stories, 66 stair flights, 1,050 stair-step parts, 287 floor-slab parts, 1,392 furniture parts, 16 markers and zero scripts. This is a historical baseline; the current architecture refresh metrics are recorded below after the Studio Edit refresh. Neither count is a movement, visual-quality or FPS result.
- Every generated preview part is anchored and non-collidable by source. Static rectangle checks found no building overlap, building/path intersection or building/open-area intersection; all 33 pedestrian slabs are connected, with 6 m minimum building clearance. These are geometric consistency checks, not gameplay or survey validation.
- In Studio, inspect every descendant `BasePart.Size`; no axis may exceed 2,048 studs. Confirm the new preview appears separated from previous snapshots and the main north-south/east-west lanes connect to the campus access paths.
- Before gameplay integration, manually compare the schematic with available dimensioned sources, confirm which entrance is Gate 1, confirm orientation, and review every estimated footprint and gameplay marker. Gameplay movement, NPC pathfinding and performance are not tested by this Phase A preview.

## Reference comparison

The graybox follows the supplied maps' relative block arrangement and street labels: B1/B1A and the football field in the southwest; A1/A2/A3 along the south/central portion; B4 and B6 farther north; C blocks toward the northeast; entrances on Ly Thuong Kiet and To Hien Thanh. The official campus plan provides labels and access-road names but not surveyed coordinates or building dimensions: [HCMUT campus location PDF](https://cce.hcmut.edu.vn/image/catalog/doc/Sodo_Diadiemthi_C6.pdf). The library directory places the Campus 1 library in A2: [VNU Library system](https://www.vnulib.edu.vn/index.php/general/37-he-thong-tv-dh-qg/128-gioi-thieu-cac-thu-vien-httv).

## Static review follow-up — 2026-10-31

See [`STATIC_REVIEW_2026-10-31.md`](STATIC_REVIEW_2026-10-31.md) for the source audit and disposition of the external Phase A review. Its original overlap warnings led to this user-approved schematic spacing adjustment; the changes are estimates, not newly verified measurements.

## Phase boundary

Phase B v5 remains an exterior-only snapshot. Phase C v6 is a detached, walkable building review; neither preview changes lighting, audio, gameplay, or the A01 runtime map. Adopting the campus as the runtime map requires measured references, human review and a separate decision.

## Build the detached Phase C walkable interior preview

1. Keep Roblox Studio in **Edit** mode and let the existing Rojo connection sync the `src/server/CampusPhaseA` modules. Run `tools/Generate-CampusPhaseA.ps1` after editing the JSON manifest.
2. When the existing v6 preview is open, refresh its 23 building models in place. The refresh validates the exact preview name/phase, stages all replacement buildings in `ServerStorage`, then swaps only the children of `AcademicBuildings` and `MissionBuildings`. It preserves the campus root, canvas, paths, open areas, marker folder, origin and gameplay code. Example for a future local rebuild:

   ```lua
   local source = game.ServerScriptService.FNABKServer.CampusPhaseA
   local package = source:Clone() -- fresh ModuleScript require avoids an older cached builder
   package.Name = "__CampusPhaseCRefresh"
   package.Parent = game.ServerStorage
   local builder = require(package.CampusBuilder)
   local result = builder.RefreshWalkable(workspace.FNABK_Campus_PhaseC_Interiors_v6_Walkable)
   package:Destroy()
   print(result.BuildingCount, result.BasePartCount, result.ClassroomCount)
   ```

   If v6 does not exist, `builder.Build(workspace, CFrame.new(22000, 1000, 6000), "FNABK_Campus_PhaseC_Interiors_v6_Walkable", "walkable")` creates the detached preview and refuses to overwrite existing models.
3. Inspect `Workspace/FNABK_Campus_PhaseC_Interiors_v6_Walkable`; select a building and press **F** to frame it. Hide `WalkableStructure/WalkableRoofCap` temporarily for an interior view, then restore it.
4. Keep this local preview unsaved and unpublished unless the team chooses to make a separate reviewed place file. The generated campus contains no scripts and is not connected to the gameplay bootstrap.

Phase C preserves the v5 exterior build mode and ground-level footprint arrangement. Each building has a unique gallery and massing profile plus a projecting SurfaceGui name sign and entrance lights. Walkable exterior decks, rails, supports and canopies form the outer circulation; classroom doors and a separate window bay sit in the room wall behind each gallery. Tower cores, split porticoes, cantilevered plates, wrap galleries, roof lanterns, shed roofs and screened end faces provide larger per-building shape differences. All are native Roblox Parts/SurfaceGuis/Lights; no outside image, mesh, texture or audio is imported or uploaded.

The 23 estimated buildings have an interior corridor along the long footprint axis and a real exterior gallery deck on one or more sides. Each gallery leads to classroom/lab doors, with an individual window bay beside each room entrance. The south-facing ground entrance connects through an entry foyer when the interior corridor turns across a wide footprint. Partition walls divide the wings into separate room Models with open door gaps; academic rooms have student desks, benches, a teacher desk and whiteboard, A2 rooms use shelves and reading furniture, A3 mixes classrooms with lab rooms, B4 uses technical/equipment rooms, and service buildings get storage rooms. The manifest chooses an odd bay count so the central room bay can line up with the entry connector. These are fictionalized rooms, not copied from surveyed floor plans.

Estimated floor-to-floor heights remain 3.6 m for academic/mission buildings and 3.2 m for service buildings. After the slab, the estimated clear height is 12.06 studs / 3.376 m or 10.63 studs / 2.976 m. The 8-stud corridor and 7-stud stairs are modeling estimates; stair tread spacing can be shortened in narrow blocks so each flight fits the footprint. Entrances are south-facing by convention; all room, stair and balcony placement remains unverified.

The generator yields between building batches. Floors, walls, stairs, furniture, balcony decks/rails, stair rails and ground support are anchored; structural surfaces collide. Window glazing, facade decoration, name signs, lamps, hallway light fixtures, room accents, markers, roads and open-area details are passable. All generated buildings have zero scripts. Human movement and visual review is tracked in flow #13 of `docs/MANUAL_CONFIRMATION.md`.

### Historical Phase C v6 architecture refresh before gallery corridors (2026-11-01)

The refresh ran in place on the existing local v6 root. Studio reports one v6 root at `(22000, 1000, 6000)`, with 23 building Models and the original 16 marker IDs still present. Across the preview there are 16,138 BaseParts, of which 10,318 collide; all are anchored, none exceeds 2,048 studs, and no script was added. The buildings contain 700 separate classroom Models plus 151 other modeled rooms/lobbies; 89 stair-hall models are tracked separately. There are 40 balcony decks, 23 projecting name signs, 293 corridor PointLights and 46 entrance PointLights. The 23 generated buildings use 22 distinct wall colors and multiple facade archetypes. These are structural counts only; natural movement, visual quality and device frame rate remain untested. The screen-capture endpoint is still unavailable for visual approval, so complete flow #13 in Studio.

### 2026-11-01 facade composition and readable nameboard revision

The follow-up addresses the user's photo-based review of repeated facades and compressed lettering. Each of the 23 style records now selects a distinct facade/entry/roof combination and carries a concise `FacadeSignature` attribute for review, with native geometry for separated window bays, curtain-wall centers, vertical screens, sunshade bands, porticos, cantilever supports, colonnades, galleries, shopfronts, clerestories, parapets, roof monitors/towers and rooftop utility details. B4 is assigned a full-span stacked gallery profile and pale concrete/green-gray accent palette based on the supplied B4-labeled photograph. Other reference photos inform visual motifs only; none is mapped to an unverified building ID. These features remain estimates.

Nameboards now have a contrasting frame and navy face, a 3.6-stud board height, a 24-pixel-per-stud SurfaceGui and a fixed 64-pixel Gotham Bold text size with wrapping and scaling disabled. The structure is intended to keep short building labels clear; Studio player-height review must confirm actual legibility. The profile audit and local Rojo build have been completed; the refreshed Studio part/lamp/rail totals and remaining manual checks are recorded after the v6 Edit update below.

### Historical v6 preview before exterior-gallery architecture (superseded; 2026-11-01)

The same detached v6 model was refreshed again from the newest Rojo-synced source. Studio reports one root at `(22000, 1000, 6000)`, `ArchitectureStyleRevision=VN_Campus_v3`, 23 building Models and the 16 original gameplay marker IDs. The 23 facade/entry/roof combinations are distinct. Total geometry is 16,645 BaseParts, including 10,551 collidable parts; all are anchored, none has an axis above 2,048 studs, and no script was added. The profile has 700 classroom Models and 851 room/lobby Models in total. There are 44 balcony decks, 23 framed signs with 23 fixed-size text labels, 293 hall lights and 46 entrance lights (339 PointLights overall). The B4 gallery has five decks, each about 220.6 x 4.6 studs. Nameboards are 28–48 x 3.6 studs, with fixed 64-pixel text, scaling and wrapping disabled.

To retain separate window bays with fewer repeated parts, punched-window rows share one frame band and sill, then use one glass pane per bay. This snapshot is retained as history; its continuous-bar silhouettes were rejected in the subsequent user review. Structural inspection does not measure rendering performance or human readability. The local place remains unsaved and unpublished.

### Historical Phase C v5 distinct school blocks — superseded Studio Edit refresh (2026-11-01)

The user rejected the earlier repeated exterior-bar appearance and specified the HCMUT open-corridor arrangement: a walkable exterior gallery, classroom doors and classroom windows behind it, with each building receiving a recognizably different shape. The v5 generator now gives all 23 buildings a unique `BuildingForm`, gallery profile and `MassingFeature`. Profile-specific geometry includes split porticoes, cantilevered lecture volumes, tower cores, colonnaded/wrap galleries, stepped facade plates, screened end faces, library podium/lanterns, laboratory shed roof, low market awnings and service chimneys. Projecting plates and screens are placed on an end or non-gallery face so they do not cover the corridor path.

Each classroom bay now has a widened, passable gallery door and a separate framed window opening. Studio Edit audit reports 640 doors and 640 classroom windows, 31 gallery runs, 124 long gallery deck slabs plus 13 corner landings (137 deck/landing parts in the builder metric), and 23 distinct gallery profiles. Room walls remain behind the exterior gallery. The audit counted 27,140 BaseParts (16,907 collidable), 530 PointLights, 23 unique massing features, 700 classroom Models, 851 room/lobby Models total, 89 stair halls, one detached campus root and all 16 gameplay marker Parts. Every part is anchored; there are zero scripts and zero parts over 2,048 studs. The local Rojo build succeeded and the refresh ran in Studio Edit. Studio screen capture currently returns a blank viewport, so visual acceptance and avatar traversal are still pending in flow #13; these structural counts do not prove that the 23 silhouettes look distinct enough to a player or meet a device frame-rate target. The place remains unsaved and unpublished, and reference images stayed local.

### Phase C architecture revision v8 — solid school walls, outside galleries and differentiated roof forms (2026-11-01)

The user rejected v5–v7 because the buildings still read as similar glass-heavy bars. The current source retains the school arrangement explicitly: the collidable concrete classroom wall is on the inside edge, a passable classroom door and a separate window opening lead into each room, and a continuous collidable gallery deck with rail and configured cover runs outside that wall. The narrowest gallery setting is now 7.2 studs (about 2.0 m); generated door leaves occupy 78% of their clear opening so the entry reads as a door while remaining non-collidable in this static preview.

The non-gallery facades now use more, smaller individual punched windows rather than a continuous trim band with large panes. Each opening is capped at 9.2 studs wide (about 2.6 m), with a wall reveal between windows; the two central entry/lobby glazing profiles remain intentional accents. Per-building massing also gains visible rooftop assemblies: B2's three-sided roof courtyard wings, A1's projecting hall volume, A2's library lanterns and podium, A3/B10's sawtooth industrial roofs, A4's separated upper wings, A5's clustered pavilions, B4's offset roof hall, C2's L-shaped roof wing, B9's stepped pavilions, C1/C3's paired wings, and distinct stair/service towers and market awnings. These are visual volumes; room floorplates, gallery collision and gameplay remain separate.

The source change was built to `build/FNABK-PhaseC-SchoolBlockSilhouettes-20261101-v10.rbxlx` and refreshed in Studio Edit on the same detached root, now marked `ArchitectureStyleRevision=VN_Campus_v8_SchoolBlockSilhouettes`. Studio reports 23 buildings, 28,137 BaseParts (16,907 collidable), 640 gallery classroom doors, 137 gallery decks/landings, 700 classroom Models and 851 room/lobby Models. All parts are anchored and no scripts were added. The Studio screenshot endpoint still returns a black viewport; these geometry and instance counts do not prove the user's visual threshold is met. The place was not saved or published, no Play test was run, and all reference images remained local. Complete the latest flow #13 check at player height before accepting the architecture or profiling it on Intel Iris Xe.
