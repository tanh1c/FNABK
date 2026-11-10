# Studio build record — pixel campus preview

## Authorization and scope

- Date: 2026-11-01.
- The user separately authorized generating the detached preview through Roblox Studio MCP.
- Target local place: `FNABK-AC06-A3-20261028-v2.rbxlx`.
- Studio mode: Edit. No Play session was started.
- Scene mutation: created only `Workspace/FNABK_Campus_PixelPreview_v1` at `CFrame.new(1200, 0, 1200)`.
- The place was not saved or published. No asset was uploaded, no cloud generation was used, and no reference image was sent to Roblox.
- The builder is not referenced by `Bootstrap.server.luau`; no gameplay source or existing model was edited by this operation.

## Source revision

- Canonical `CampusPixelGeometry.json` SHA-256: `149e7ecbc243138a413dcecc9dd82dbd80a14427944784075689a60bff63fa10`.
- `GeometryAdjustments.json` SHA-256: `c11ee3213525633302723ab2f48bbc23d4d5c65b76c936a95f62e16fde2e95f1`.
- Preview scale: 1.0 stud per pixel.

## Studio structural audit

| Check | Result |
|---|---:|
| Root | `Workspace.FNABK_Campus_PixelPreview_v1` |
| Feature Models | 57 |
| Building Models | 23 |
| Entrance marker Models | 3 |
| BaseParts | 270 |
| Missing expected building IDs | 0 |
| Unanchored BaseParts | 0 |
| Collidable / touchable / queryable BaseParts | 0 / 0 / 0 |
| Scripts under preview root | 0 |
| B8/B9 long-edge direction | Parallel; absolute direction dot product = 1 |
| Entrance1 pixel X | 178 |
| B4 and Canteen | Separate building Models |

The offline geometry report separately measured a 6.21-pixel B8/B9 boundary gap, 0.0001-degree long-edge angle difference, and an 8.30-pixel B4/Canteen boundary gap.

## Visual review status

Studio MCP screen capture returned a blank viewport. This is not evidence of a geometry failure: the DataModel audit found the expected models and parts, but it does mean the visual appearance has not been confirmed from the screenshot. The user-facing top-down visual review remains pending in flow #14 of `docs/MANUAL_CONFIRMATION.md`.

To inspect the generated model in Studio, select `Workspace/FNABK_Campus_PixelPreview_v1` in Explorer and press **F** to frame it, then switch to Top view. Confirm the B1 courtyard, B8/B9 separation, Entrance1 position, and separate B4/Canteen labels against `CampusPreviewTopDown.svg`. Leave the place unsaved and unpublished.

## Detached Phase C building port

- Date: 2026-11-01.
- Target local place: `FNABK-AC06-A3-20261028-v2.rbxlx`, Studio Edit mode.
- Scene mutation: created `Workspace/FNABK_Campus_PixelBuildings_PhaseC_v1`, aligned with the pixel preview origin `(1200, 0, 1200)`. The existing v6 source and `FNABK_Campus_PixelPreview_v1` outline remain present.
- Build source: `src/server/CampusPixelPreview/PixelBuildingPorter.luau`, using the live `WalkableFloor_01` position in each v6 source model as its local transform origin and `CampusPreviewManifest` pixel polygons for destination footprints.
- The port contains 23 logical building IDs: 17 exact-ID models and six distinct identities made from visual templates. B1 is one parent model with three wings (`B1_WestWing`, `B1_EastWing`, `B1_NorthLink`) following the U-shaped plan. Its courtyard remains an open region in the footprint decomposition.
- Studio root attributes report `BuildComplete=true`, 29,851 BaseParts, zero unanchored BaseParts, zero scripts, and `GameplayIntegrated=false`. The original v6 root still reports 23 building models and all 16 gameplay markers.
- A structural footprint audit of the corrected port found zero overlaps between B1 wings and other buildings; intentional adjoining B1 wings were treated as one complex. B8/B9 remain parallel with an approximately 6.07-stud gap. This is a geometric audit, not a player collision or traversal test.
- The place was not saved or published. No source gameplay code, runtime map, marker positions, or asset uploads were changed.

## Remaining manual confirmation

Flow #15 in `docs/MANUAL_CONFIRMATION.md` remains pending. Inspect the port from above and at player height, confirm that the new template-based names/signs are legible, B1's courtyard is open, routes remain usable, and representative doors, rooms, stairs, furniture, and collision allow traversal. The structural audit does not establish visual approval, traversal, or target-device performance.

## User-directed horizontal mirror correction

- Date: 2026-11-01. Studio remained in Edit mode.
- The user reported the pixel map appeared reversed and requested swapping left and right. The offline transform now maps `xStuds = (imageWidthPx - pixelX) * previewStudsPerPixel`; canonical pixel geometry and supplied source vector geometry remain unchanged. The generated preview SVG shows the same mirrored orientation.
- `PixelMapMirror.luau` reflected the two already-built detached roots in place across world `X=1924`, the horizontal center of the 1,448-stud preview at origin `(1200, 0, 1200)`. Its preflight passed before either root was changed.
- `FNABK_Campus_PixelPreview_v1`: 270 BaseParts transformed; Studio reports `HorizontalMirrorApplied=true` and `HorizontalMirrorAxisWorldX=1924`.
- `FNABK_Campus_PixelBuildings_PhaseC_v1`: 29,851 BaseParts transformed; Studio reports the same mirror attributes. Its building count and part count are unchanged.
- The v6 Phase C source and playable map were not transformed. The place was not saved or published; no assets were uploaded.
- Flow #16 in `docs/MANUAL_CONFIRMATION.md` remains pending for top-down side placement, outline/building alignment, B1 courtyard, B8/B9 spacing, B4/Canteen separation, and readable signs. The structural operation does not establish visual acceptance or traversal.

## B1 U-wing connection correction

- Date: 2026-11-01. Target local place: FNABK-AC06-A3-20261028-v2.rbxlx, Studio Edit mode.
- Scene mutation: only Workspace/FNABK_Campus_PixelBuildings_PhaseC_v1/Buildings/B1/B1_NorthLink was adjusted. Its geometry was rotated 90 degrees so the long crossbar follows X, then translated 2.25 studs toward both adjoining wings. The operation changed 1,197 BasePart CFrames and did not add or remove instances.
- Structural check: the crossbar bounds now overlap both side-wing bounds by about 1.04 studs. Each join ground-floor and four upper-floor seam samples are covered by a floor part from both adjoining wings. The courtyard sample remains outside all three wing bounds.
- Reproduction: PixelBuildingPorter.luau now checks actual fitted X/Z extents and corrects swapped axes; it calculates the crossbar shared-edge direction and applies the same 2.25-stud seam overlap during a fresh port.
- This is a geometry audit only; visual appearance, player traversal, and the correct real-world story count remain pending. The place was not saved or published; the v6 source and runtime map were not changed.
- Flow #17 in docs/MANUAL_CONFIRMATION.md is pending.

## Fresh-manifest rebuild with confirmed floors and workshops

- Date: 2026-11-01. Target local place: `FNABK-AC06-A3-20261028-v2.rbxlx`, Studio Edit mode.
- Diagnosis: `FNABK_Campus_PixelBuildings_PhaseC_v2` was built after Rojo had synced the current manifest source, but Studio's `require` cache returned the older pre-mirror table. Its root attribute reported `HorizontalMirrorApplied=false`; B1 and other buildings therefore did not match the mirrored outline. The v2 root was preserved and is not the current review target.
- Scene mutation: created a separate `Workspace/FNABK_Campus_PixelBuildings_PhaseC_v3` using a fresh cloned manifest ModuleScript passed through `manifestOverride`. The build used `CFrame.new(1200, 0, 1200)`, did not replace v1/v2, the outline, or the v6 source, and remains detached from `Bootstrap.server.luau`.
- Root attributes: `BuildComplete=true`, `HorizontalMirrorApplied=true`, 23 building Models, 19,055 BaseParts, zero unanchored BaseParts, zero scripts, six B1 seam connectors, `GameplayIntegrated=false`.
- B1 world-space part-corner bounds match the three rectangles produced from the current polygon after the generator's 1.8-pixel coordinate clustering: WestWing X `[2287.100, 2322.750]`, Z `[1569.125, 1689.700]`; EastWing X `[2391.000, 2427.150]`, Z `[1569.125, 1689.700]`; NorthLink X `[2287.100, 2427.150]`, Z `[1689.700, 1724.200]`. The shared crossbar edge aligns with both arms. Six anchored, collidable floor connectors bridge source-floor setbacks, two joins across levels 1–3. Point-in-part checks at courtyard center across five heights found no B1 part occupying the courtyard.
- All 23 building Models carry the user's confirmed `ConfirmedStories` value. Named/indexed walkable floor geometry matched the requested counts for the template-based buildings; C1 has a collidable partial upper inspection deck and stairs, C2 a single-level mechatronics floor, and C3 a single-level mechanical floor. Their architecture attributes are `heavy_mechanical_workshop_high_bay_with_partial_upper_service_floor`, `mechatronics_assembly_lab_blue_service_band`, and `single_story_mechanical_shop_red_steel_portals_and_crane_rail` respectively.
- The Edit-time screenshot endpoint returned a blank viewport, so human visual review and player traversal remain pending in flows #17 and #18. The place was not saved or published; no assets were uploaded and no runtime/gameplay source was changed.

## B1 centered entrance and connected U rebuild in v5

- Date: 2026-11-02. Target local place: FNABK-AC06-A3-20261028-v2.rbxlx, Studio Edit mode. Current detached review root: Workspace/FNABK_Campus_PixelBuildings_PhaseC_v5.
- Source correction: the three cloned B1 template entrance portals are removed. A single open 12-stud-wide, 8.9-stud-high portal is placed at the center of the open south edge. The north crossbar grows 2.25 studs toward the courtyard to overlap both side wings while its outer edge remains fixed to the traced polygon.
- Fresh build attributes: 23 building Models, 19,034 BaseParts, zero unanchored BaseParts, zero scripts, three B1 wing Models, six floor seam connectors and one main entrance. The detached root reports BuildComplete=true and GameplayIntegrated=false.
- Edit-time bounds audit against the B1 outline: outline stroke bounds X [2285.100, 2428.800], Z [1567.400, 1725.700]. West wing X [2287.100, 2322.750], Z [1569.125, 1689.700]. East wing X [2391.000, 2427.150], Z [1569.125, 1689.700]. North crossbar X [2287.100, 2427.150], Z [1687.450, 1724.200]. The two-stud outline stroke surrounds the footprint; the wings align to the traced edges, and the crossbar's outer edge stays within the top edge while its inner edge intentionally overlaps 2.25 studs.
- Entrance center is X 2356.875, Z 1569.825 at the open south edge, centered between both arms. The interior courtyard remains open. A map-south screenshot shows the U silhouette and central portal, but does not establish player traversal or user visual acceptance.
- Existing preview roots v1-v4 were kept under ServerStorage; no place save, publish, upload, gameplay edit or runtime-map change occurred.
- Flow #17 in docs/MANUAL_CONFIRMATION.md remains pending for direct visual and avatar-traversal confirmation.

## B1 single-body U and crossbar entrance rebuild in v6

- Date: 2026-11-02. Target local place: `FNABK-AC06-A3-20261028-v2.rbxlx`, Studio Edit mode.
- The initial v6 build attempt stopped at a source guard because the template facade's long axis is its local Z axis, rotated parallel to world X. No preview root was retained from that attempt. The doorway splitter was corrected to handle the observed facade orientation, and the new build completed.
- Scene mutation: created `Workspace/FNABK_Campus_PixelBuildings_PhaseC_v6` at origin `(4300, 0, 1200)`, beside and independent from v5. Created `Workspace/FNABK_Campus_PixelPreview_v1_B1Review_v6` as a +3100 X clone of the original outline. The original `FNABK_Campus_PixelPreview_v1` and v5 root remain in place and unchanged.
- Root attributes: `BuildComplete=true`, 23 logical building Models, 19,032 BaseParts, zero unanchored BaseParts, zero scripts, six B1 floor seam connectors, `B1ConnectedBodyCount=1`, and `GameplayIntegrated=false`.
- B1 now has one direct child body Model, `B1_ContinuousBuilding`. Its three temporary source geometry regions are flattened into the body; none remain as separate B1 region Models. The logical B1 model has `B1ConnectedBodyCount=1` and `B1AssemblyType=single_connected_U_shaped_building`.
- The single B1 entrance is centered on the outside face of the connecting crossbar, opposite the U's open end. The door center is `(5457.125, 0, 1723.500)` in world coordinates, with a 12-stud clear width and 8.9-stud clear height. The ground-floor exterior wall is split into three segments around that opening. A collision-volume audit found zero collidable BaseParts intersecting the 11.8 x 8.84 x 2.4-stud doorway clearance prism. A point-in-part audit at courtyard sample `(5457, 5, 1629)` found zero B1 parts.
- The Studio Edit viewport capture endpoint returned a black image. These checks confirm model hierarchy and geometry attributes, not visual acceptance or player traversal; Flow #17 remains pending. The place was not saved or published. No runtime gameplay, source map, markers, or asset uploads were changed.
