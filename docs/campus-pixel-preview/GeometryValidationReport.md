# Pixel geometry validation report

Status: **PASS**

## Scope and provenance

The geometry checks in this report run offline. No gameplay map/runtime scripts, asset uploads, cloud generation, or publishing were part of this operation. The separately approved Studio Edit build and structural audit are recorded in `StudioBuildRecord.md`. The source diagram is marked AI-generated and unverified; this is a relative pixel visualization, not surveyed geometry.

- Canonical JSON SHA-256: `149e7ecbc243138a413dcecc9dd82dbd80a14427944784075689a60bff63fa10`.
- Adjustment overlay SHA-256: `c11ee3213525633302723ab2f48bbc23d4d5c65b76c936a95f62e16fde2e95f1`.
- Source image canvas: 1448 × 1086px.
- Preview scale: 1.0 stud/px; metersPerPixel = null.
- Input vector-only SVG: PASS — all 57 source footprints match canonical JSON vertices.
- Generated top-down SVG vs adjusted preview geometry: PASS.
- Canonical pixel vertices retained unchanged in `sourcePolygonPixels`: PASS.
- Effective preview polygons match canonical source plus adjustment overlay: PASS.
- Pixel-to-stud formula, horizontal mirror and Y inversion: PASS.
- Preview orientation: left/right mirrored around the source-image vertical center; canonical pixel vertices remain unchanged.
- Applied explicit user adjustments: B9 separated and aligned parallel to B8; Entrance1 shifted right in source-pixel space before the mirror; Canteen rendered as a distinct building beside B4.

## Geometry checks

- Features: 57 total; buildings 23, areas 33, boundary 1.
- Pixel polygon vertices: 266; all polygons have ≥3 distinct points: PASS.
- Non-zero area: PASS.
- Simple/non-self-intersecting polygons: PASS.
- All vertices inside source image bounds: PASS.
- Building overlap candidates: 0.

- B1 U-courtyard sample at pixel (291, 650) is outside the B1 polygon: PASS.
- Other building polygons containing that sample point: none.
- Building polygon vertices outside CampusBoundary: none.
- Entrance markers outside CampusBoundary: none.
- Entrance1 moved right by 12px per request; adjusted point is inside CampusBoundary.
- B8/B9 spacing and orientation: PASS; overlap=no, edge gap=6.21px, long-edge angle difference=0.0001°.
- B4/Canteen: PASS as distinct neighboring building polygons; overlap=no, boundary gap=8.30px. Canteen source category is `area`; preview category is `building`.

## IDs and source cross-checks

- Pixel building IDs: 23; exact shared IDs with existing CampusManifest: 17 (A1, A2, A3, A4, A5, B1, B2, B4, B6, B8, B9, C1, C2, C3, C4, C5, C6).
- New pixel building identities retained: 6 (B11, B12, B3, Canteen, Facility7, KioskOISP).
- Existing unmatched building IDs retained as unresolved: 6 (B10, B1A, B7, Facility1, Facility2, Kiosk8).
- `Facility7` was not aliased to `B7`; `KioskOISP` was not aliased to `Kiosk8`.
- Existing gameplay marker IDs preserved separately: 16 (Gate1, Spawn, Exit, A3, Library, B4, CrateStart, PressurePlate, Generator, FuseSpawn, NPCSpawn01, NPCSpawn02, NPCSpawn03, MimicSpawn01, MimicSpawn02, MimicSpawn03); none receive pixel-preview coordinates.
- New digitized entrance IDs: Entrance1, Entrance2, Entrance3.
- Pixel center CSV IDs: expected 60, present 60; categories and vertex counts checked; centers checked against source-image bounds.

## Preview geometry and Part estimate

- Generation mode is polygon-edge ribbons. It preserves each polygon edge while leaving its interior empty, so it cannot fill B1's courtyard. It is an outline visualization, not walkable floors or solid building masses.
- Estimated edge Parts at this scale, including the campus boundary: 266; three entrance marker Parts and 1 canvas tile(s) bring the total estimate to 270.
- Longest source edge at this scale: 1299.400 studs; generator subdivides edges at 1800 studs, below Roblox's 2048-stud BasePart axis limit. Canvas tiles also stay within that limit.
- Every generated BasePart is configured Anchored=true, CanCollide=false, CanTouch=false, CanQuery=false. Builder creates no scripts and is not called by gameplay bootstrap.

## Spatial relationships (nearest building centers)

Distances use the supplied pixel-only CSV centers (with polygon-centroid fallback for a missing/invalid row), multiplied by the configured visualization scale. They are not real-world distances.

- `A1` nearest to `KioskOISP`: 94.64 preview studs.
- `A2` nearest to `A5`: 91.77 preview studs.
- `A3` nearest to `B9`: 147.57 preview studs.
- `A4` nearest to `A5`: 81.22 preview studs.
- `A5` nearest to `A4`: 81.22 preview studs.
- `B1` nearest to `B2`: 138.85 preview studs.
- `B11` nearest to `B12`: 59.54 preview studs.
- `B12` nearest to `B11`: 59.54 preview studs.
- `B2` nearest to `B1`: 138.85 preview studs.
- `B3` nearest to `B4`: 146.48 preview studs.
- `B4` nearest to `Canteen`: 49.81 preview studs.
- `B6` nearest to `A5`: 116.88 preview studs.
- `B8` nearest to `B9`: 37.78 preview studs.
- `B9` nearest to `B8`: 37.78 preview studs.
- `C1` nearest to `B12`: 184.53 preview studs.
- `C2` nearest to `C3`: 46.28 preview studs.
- `C3` nearest to `C2`: 46.28 preview studs.
- `C4` nearest to `C5`: 50.04 preview studs.
- `C5` nearest to `C6`: 43.68 preview studs.
- `C6` nearest to `C5`: 43.68 preview studs.
- `Canteen` nearest to `B4`: 49.81 preview studs.
- `Facility7` nearest to `C2`: 84.87 preview studs.
- `KioskOISP` nearest to `A1`: 94.64 preview studs.

## Findings requiring human review

- The generated source is not a verified campus plan; confidence for building footprints is rough/manual and requires tracing.
- B1's U-shape and the relationship of legacy B1A/B1B wing IDs still need source evidence.
- Review any remaining overlap candidates and estimated boundaries; no additional geometry has been moved.
- The 16 existing gameplay marker IDs have no pixel coordinates and remain unplaced.
