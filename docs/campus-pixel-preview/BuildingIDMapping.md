# Building ID mapping — pixel preview

This mapping separates the new uncalibrated pixel preview from the existing v6 Phase A coordinate manifest. It is an identity crosswalk only; it does not transfer old metric positions into the preview.

## Pixel building IDs

| Pixel geometry ID | Existing CampusManifest ID | Status | Notes |
|---|---|---|---|
| A1 | A1 | Exact ID match | Pixel geometry is provisional and remains independent of v6 metric coordinates. |
| A2 | A2 | Exact ID match | Pixel geometry is provisional and remains independent of v6 metric coordinates. |
| A3 | A3 | Exact ID match | Pixel geometry is provisional and remains independent of v6 metric coordinates. |
| A4 | A4 | Exact ID match | Pixel geometry is provisional and remains independent of v6 metric coordinates. |
| A5 | A5 | Exact ID match | Pixel geometry is provisional and remains independent of v6 metric coordinates. |
| B1 | B1 | Exact ID; complex parent footprint | Pixel geometry keeps the U-shaped B1 complex as one polygon. B1A/B1B are treated as wings by the user's rule; this source does not provide separately traced wing polygons, and B1B is absent from the current CampusManifest. No wing geometry is inferred. |
| B11 | — | New pixel identity; retained | Do not alias to another existing ID. |
| B12 | — | New pixel identity; retained | Do not alias to another existing ID. |
| B2 | B2 | Exact ID match | Pixel geometry is provisional and remains independent of v6 metric coordinates. |
| B3 | — | New pixel identity; retained | Do not alias to another existing ID. |
| B4 | B4 | Exact ID; distinct from Canteen | The user confirmed B4 and Canteen are separate neighboring buildings. B4 retains its own source polygon and label. |
| B6 | B6 | Exact ID match | Pixel geometry is provisional and remains independent of v6 metric coordinates. |
| B8 | B8 | Exact ID match | Pixel geometry is provisional and remains independent of v6 metric coordinates. |
| B9 | B9 | Exact ID match | Pixel geometry is provisional and remains independent of v6 metric coordinates. |
| C1 | C1 | Exact ID match | Pixel geometry is provisional and remains independent of v6 metric coordinates. |
| C2 | C2 | Exact ID match | Pixel geometry is provisional and remains independent of v6 metric coordinates. |
| C3 | C3 | Exact ID match | Pixel geometry is provisional and remains independent of v6 metric coordinates. |
| C4 | C4 | Exact ID match | Pixel geometry is provisional and remains independent of v6 metric coordinates. |
| C5 | C5 | Exact ID match | Pixel geometry is provisional and remains independent of v6 metric coordinates. |
| C6 | C6 | Exact ID match | Pixel geometry is provisional and remains independent of v6 metric coordinates. |
| Canteen | — | New pixel building identity; retained | The canonical source categorizes this polygon as an area. A separate preview-only category override renders it as a building; the user confirmed it is a distinct building beside B4. Its polygon is not merged with B4. |
| Facility7 | — | New pixel identity; retained | Do not alias to another existing ID. |
| KioskOISP | — | New pixel identity; retained | Do not alias to another existing ID. |

## Existing CampusManifest IDs without an exact pixel building ID

| Existing ID | Mapping status | Handling |
|---|---|---|
| B10 | Unresolved | Unresolved; kept in the existing manifest and not deleted or positioned in this preview. |
| B1A | Unresolved | Unresolved independent footprint; retained as a possible B1 wing identity, with no separate pixel polygon. |
| B7 | Unresolved | Unresolved; Facility7 is not treated as B7. |
| Facility1 | Unresolved | Unresolved; kept in the existing manifest and not deleted or positioned in this preview. |
| Facility2 | Unresolved | Unresolved; kept in the existing manifest and not deleted or positioned in this preview. |
| Kiosk8 | Unresolved | Unresolved; KioskOISP is not treated as Kiosk8. |
| B1B | User-mentioned wing identity; absent from both current ID sets | No standalone polygon is created; its relationship within B1 needs source evidence. |

## Canteen, facilities, and kiosk ambiguities

- `B4` and `Canteen` are distinct neighboring buildings, confirmed by the user. `Canteen` keeps its canonical area category in the source JSON but is rendered as a building in this preview by an explicit category override.
- `Facility7` remains `Facility7`; it is not an alias for legacy `B7`.
- `KioskOISP` remains `KioskOISP`; it is not an alias for legacy `Kiosk8`.
- New `B3`, `B11`, and `B12` identities are retained unchanged.

## Gameplay markers are separate from entrances

The existing 16 gameplay marker IDs are preserved in `CampusPreviewManifest.json` as inventory-only entries with null preview coordinates. Their v6 metric coordinates are deliberately excluded from this transformation. `Entrance1`, `Entrance2`, and `Entrance3` are a separate set of three pixel-digitized entrance markers and are the only markers positioned by this pixel preview.

Existing gameplay marker IDs: `Gate1`, `Spawn`, `Exit`, `A3`, `Library`, `B4`, `CrateStart`, `PressurePlate`, `Generator`, `FuseSpawn`, `NPCSpawn01`, `NPCSpawn02`, `NPCSpawn03`, `MimicSpawn01`, `MimicSpawn02`, `MimicSpawn03`.

## Summary

- Exact ID matches: 17 (A1, A2, A3, A4, A5, B1, B2, B4, B6, B8, B9, C1, C2, C3, C4, C5, C6).
- New pixel building IDs retained: 6 (B11, B12, B3, Canteen, Facility7, KioskOISP).
- Existing IDs unresolved: 6 (B10, B1A, B7, Facility1, Facility2, Kiosk8).
- No old metric coordinate is used to set pixel scale, building location, or entrance position.

## Phase C model templates used for the detached port

These are visual templates only; each left-hand ID remains its own identity, and the legacy source ID remains in v6.

| Pixel identity | Visual template |
|---|---|
| B3 | B6 |
| B11 | B7 |
| B12 | Facility1 |
| Canteen | B10 |
| Facility7 | B8 |
| KioskOISP | Kiosk8 |

The U-shaped B1 polygon is decomposed into three touching wings under one B1 parent, with its courtyard left open. No wing is renamed B1A or B1B without source evidence.
