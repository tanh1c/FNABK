# Performance and collision checklist

This is a static estimate for the detached pixel preview at 1.0 stud/pixel plus the Studio DataModel audit recorded in `StudioBuildRecord.md`. It is not a measured Studio frame-rate result. See `GeometryValidationReport.md` for geometry findings.

## Geometry budget

- [x] Roblox-native Parts and Models only; no uploaded meshes, textures, images or other assets.
- [x] At 1.0 stud/pixel: 266 polygon-edge Parts + 3 entrance markers + 1 canvas tile = approximately 270 BaseParts. The requested polygon adjustment keeps the vertex/Part count unchanged.
- [x] Each polygon edge longer than 1,800 studs is subdivided; canvas boards are tiled at 1,800 studs maximum per axis. This leaves margin below Roblox's 2,048-stud BasePart axis limit.
- [x] Entrance markers cap at 24 studs per axis. Building ribbons are 3 studs wide and 2.4 studs high; area and boundary ribbons are smaller.
- [x] One Model per source polygon, grouped under separate Buildings, Areas and CampusBoundary Models. The three entrances and canvas have their own Models.
- [x] Canonical source polygons remain unchanged in JSON. The overlay adjusts B9's preview ring, Entrance1's preview point, and Canteen's preview category; outline parts still follow polygon edges rather than filling polygon area.
- [x] Studio structural audit found 270 BaseParts: 266 outline edges, three entrance markers and one canvas tile. Scale changes can increase edge segments and canvas tiles.
- [ ] Profile on the target Intel Iris Xe machine only if the preview is kept open alongside the gameplay place. No FPS claim is made.

## Collision and content safety

- [x] Every generated BasePart sets `Anchored = true`.
- [x] Every generated BasePart sets `CanCollide = false`, `CanTouch = false`, and `CanQuery = false`.
- [x] The canvas is a viewing background, not a walkable floor. It is also non-collidable, non-touchable and non-queryable.
- [x] B1 is a concave U-shaped outline; no part crosses its central courtyard. Polygon interiors are not filled.
- [x] B8/B9 preview polygons are separated by a small documented gap and aligned parallel; the original B9 ring remains in `sourcePolygonPixels`.
- [x] Entrance1's preview marker is shifted 12 source pixels right; the source marker coordinate is retained in the manifest.
- [x] B4 and Canteen are two separate neighboring building footprints; Canteen's source category is preserved and its preview category is overridden to `building`.
- [x] Builder creates no Scripts, LocalScripts, ModuleScripts, RemoteEvents, NPCs or gameplay markers.
- [x] The builder is detached from server bootstrap and refuses to replace an existing output model.
- [x] Studio DataModel audit confirmed all generated parts are anchored and have collision, touch and query disabled; B1's courtyard remains open in the source polygon validation.
- [x] The Studio place was not saved or published during the preview build.
- [ ] Direct visual review of B1, B8/B9, Entrance1, and B4/Canteen remains pending in flow #14; Studio MCP screen capture returned a blank viewport.

## Visual limitations to review

- Ribbon widths can extend slightly to either side of an exact source polygon edge; the manifest and SVG retain the exact source topology and coordinates.
- Adjacent ribbons may overlap at polygon corners. They are intentionally non-collidable and do not fill the polygon interior.
- The geometry adjustments are preview-only and record the user's requested B8/B9 spacing/orientation, Entrance1 rightward shift, and distinct B4/Canteen identities.
- The source diagram is AI-generated, unverified and uncalibrated. No geographic north or 1:1 scale is claimed.
