# Phase A/B performance and collision checklist

## Implemented for the Phase A/B preview

- Geometry uses anchored Roblox `Part` instances only; no high-poly meshes or imported assets.
- Buildings remain separate Models. Phase B uses one main volume plus grouped facade parts: four window ribbons per story, four story bands per floor boundary, four corner piers, one base and one roof cap.
- Studio Edit inspection of v5 counted 781 building Parts and 851 total preview Parts. This is a geometry count, not a device-performance measurement.
- Storey counts and floor heights are estimates; the facade bands are visual only and do not create walkable floors or interiors.
- Roads, open areas, outline segments and markers use simple primitives.
- Site canvas, road slabs and parcel edges are split into contiguous segments so every individual `BasePart.Size` dimension stays within Roblox's 2,048-stud limit ([BasePart documentation](https://create.roblox.com/docs/reference/engine/classes/BasePart)).
- All preview parts are non-collidable, non-touchable and non-queryable so the prototype cannot block the current game.
- Preview is built at a configurable world offset and is not called from the gameplay bootstrap.
- The generator contains no scripts inside the generated model.
- The adjusted schematic targets at least 6 m between separate building footprints and uses 6–12 m visual pedestrian corridors to make routes legible.
- Campus roads/access paths are not collidable, touchable, queryable or connected to Roblox pathfinding; a drawing that shows a continuous route is not a traversal test.

## Phase C detached walkable interiors and differentiated buildings

- Phase C v6 is a separate local preview. Its in-place style refresh replaces only the 23 source-generated building children; it preserves the campus root, origin, canvas, paths, open areas, marker folder, Phase B v5 and the A01 runtime map.
- Each building has one unique massing profile and one unique gallery combination. Exterior gallery decks, rails, support piers, canopies and classroom entries use anchored native Parts; nameboards and lights remain per building.
- A long-axis interior corridor connects the ground entrance to multiple bounded rooms per estimated floor. Exterior galleries run on one or more sides; their collidable walls have passable classroom doors and separate classroom window openings. Classroom furniture differs from A2 library rooms, A3 lab/classrooms, B4 technical rooms and service storage.
- Floors, stairs, gallery decks, parapets/rails, supports, classroom walls/window sills/headers, room partitions and furniture are anchored and collidable. Structural parts use `CanQuery=true` and `CanTouch=false`.
- Door leaves, window panes, facade screens, signs, lamps, roof/massing projections, hall-light fixtures, room accents, roads, open-area visuals, parcel outline and gameplay markers remain passable. Door and window gaps plus their surrounding wall pieces are generated from the same classroom bay layout.
- Upper-floor slabs are cut around each stair flight. Stair flights use solid step blocks and collidable handrails; no doors or moving interior scripts are generated.
- Room assignments, walls, heights, gallery sides, entrances and stairs remain estimates; the reference maps do not contain dimensioned interior plans or elevations. Flow #13 requires checking traversal, headroom, collision and visual differentiation in Studio.
- Historical v5 Studio Edit audit: 27,140 BaseParts (16,907 collidable), 23 buildings, 89 estimated storeys, 66 stair flights, 700 classroom Models and 851 room/lobby Models total, plus 89 stair-hall Models. It includes 640 gallery doors, 640 classroom window openings, 124 long deck slabs plus 13 corner landings and 530 PointLights. One detached root and 16 marker Parts remained; all parts were anchored, with no scripts or parts over 2,048 studs.
- About 27,000 Parts and 530 PointLights are not yet performance-profiled on Intel Iris Xe; the 30 FPS goal remains unmeasured. Automated Studio capture returned a blank viewport and no avatar movement was tested. Visual approval, route traversal and collision confirmation remain pending in flow #13.

### Historical v5 distinct school blocks and exterior gallery openings — Studio Edit audit (2026-11-01)

- The Phase C source now builds 23 distinct `BuildingForm` values, 23 unique gallery profile combinations and 23 unique massing features. Gallery profiles vary the number/orientation of walkable exterior sides, deck width, rail, support, roof cover and room-door rhythm. Classroom doors and a separate window bay are cut into the wall directly behind each generated gallery; projectors/screens are placed on end or non-gallery facades.
- Studio Edit reports 27,140 BaseParts, 16,907 collidable parts, 640 passable gallery classroom doors, 640 classroom window openings, 124 long gallery deck slabs plus 13 gallery corner landings, and 530 PointLights. It retains one detached root and the original 16 marker Parts. The 23 building Models contain 700 classroom Models and 851 room/lobby Models in total, plus 89 stair-hall Models.
- The generator audit found zero unanchored parts, zero BaseScripts under the preview, and zero part axes above 2,048 studs. Floors, gallery decks, classroom walls/sills/headers, supports, stairs and rails carry collision; door leaves, window panes, facade screens and massing projections remain passable.
- The preview now has about 27,000 Parts and 530 lights. It has not been profiled on Intel Iris Xe; do not infer that it meets the 30 FPS goal. Studio MCP screen capture returned a blank viewport in this review, and no avatar movement test was run. Complete flow #13 before treating visual differentiation, route clearance or collision as accepted.

## Checks for the team before gameplay integration

- [ ] Confirm a top-down Studio view agrees with the supplied campus maps.
- [ ] Confirm north orientation and which entrance should map to Gate1.
- [ ] Replace estimated parcel outline with a surveyed or dimensioned boundary if available.
- [ ] Replace building footprint estimates with measured width/depth/rotation values.
- [ ] Confirm every Gameplay marker is intentionally placed and remains separate from the current gameplay map.
- [ ] In a fresh detached Studio preview, confirm every `BasePart.Size` axis is at most 2,048 studs and the segmented canvas, To Hien Thanh road and long parcel edge have no visible gaps.
- [ ] Confirm the east-west and north-south route slabs visibly connect to the building access paths, and report any remaining visual gaps or undesired crossings.
- [ ] Keep each building one separate Model; balance visible windows, room furniture, rails and lighting against a measured target-device frame budget.
- [ ] In Phase C, confirm floors, stairs, outer/inner walls, roof cap, balcony rails and furniture block movement where intended; confirm entrance and classroom doorway gaps remain clear.
- [ ] Check avatar head clearance at every floor, especially under stair openings, and walk stairs both up and down on the narrower buildings.
- [ ] Review all 23 facade/entry/roof combinations from the same player-height camera distance; check B4 galleries, vertical screens, central glazing, porticos, shopfronts and roof towers read as distinct compositions.
- [ ] Confirm each framed nameboard shows its complete single-line label from 15–25 studs away; current layout uses fixed 64-pixel text, no auto-scaling and no wrapping.
- [ ] Confirm window glazing, signs, lamps, sunshades and decorative trim stay passable; collision comes from structural walls and intentional railings.
- [ ] Measure target-device performance after any runtime integration; the 30 FPS goal is not measured by this detached preview.

### Historical v3 facade refresh — Studio Edit structural counts (2026-11-01)

The refreshed detached v6 preview has 16,645 BaseParts (10,551 collidable), 23 building Models and 16 markers. All parts are anchored; there are zero oversized parts and zero scripts. It contains 700 classroom Models, 851 room/lobby Models in total, 44 balcony decks, 23 framed signs, 23 fixed-size sign labels and 339 PointLights. All 23 facade/entry/roof profile triples are distinct. B4 has five stacked gallery decks, approximately 220.6 x 4.6 studs each. Punched-window rows share a frame band and sill to reduce repeated parts; the local Rojo build succeeded. These counts do not establish avatar movement, readability, visual acceptance or FPS; flow #13 remains the direct review.

### v8 school gallery, punched-window and roof-form refresh — Studio Edit audit (2026-11-01)

- Studio refreshed the existing detached v6 root to `ArchitectureStyleRevision=VN_Campus_v8_SchoolBlockSilhouettes`; it retains 23 building Models and 16 estimated gameplay markers. The audit reports 28,137 BaseParts, 16,907 collidable, 700 classroom Models, 851 room/lobby Models, 640 gallery classroom doors and 137 gallery decks/corner landings.
- Each generated classroom door is backed by a separate window opening in an opaque classroom wall; windows on non-gallery facades are now individually punched panes capped at 9.2 studs wide instead of a continuous trim band. Exterior gallery decks have a 7.2-stud minimum width. Roof shapes include courtyard wings, split pavilions, cantilever hall, L-shaped mass, sawtooth roof and low market/service profiles.
- All 28,137 parts are anchored; the refreshed model reports zero unanchored parts and zero scripts. No human visual or traversal pass is recorded. The Studio capture endpoint returned a black viewport, and approximately 28,000 parts have not been profiled on Intel Iris Xe. Flow #13 remains pending; do not claim the user's visual bar or the 30 FPS target has been met.
