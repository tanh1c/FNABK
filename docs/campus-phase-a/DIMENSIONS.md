# Phase A dimensions and evidence

## Published or directly labeled

| Item | Value / evidence | Status |
|---|---|---|
| Campus 1 address | 268 Ly Thuong Kiet, Ho Chi Minh City | Published by HCMUT; address does not establish the parcel boundary. |
| Campus land area | Approximately 14.08 hectares in HCMUT's March 2026 facilities statement | Published approximate figure; not a survey or CAD boundary. |
| Roblox length conversion | 1 stud = 0.28 m (25/7 studs per meter) | Roblox Creator Hub unit convention. |
| Building labels and access names | A1–A5, B1/B1A, B2, B4, B6–B10, C1–C6, Entrance 1–3, Ly Thuong Kiet and To Hien Thanh | Read from supplied maps and the HCMUT campus plan PDF. |
| Campus 1 library building | A2 | Listed by the VNU Library system; exact room-level layout is not modeled. |

## Estimated in this graybox

| Item | Phase A estimate | Confidence / required confirmation |
|---|---:|---|
| Parcel envelope | 602.6 m east-west × 250 m north-south | Low. Derived from the image's aspect ratio and the published approximate area. |
| Parcel outline | 7-point polygon in `CampusManifest.json`; computed plan area normalized to 140,800 m² | Low. No cadastral boundary coordinates were supplied. |
| All building centers, widths, depths and rotations | Approximate values in `CampusManifest.json`; several were shifted/resized to remove schematic overlap | Low. Proportioned by eye and adjusted for a readable walkable layout; need dimensioned drawings, survey coordinates, or measured aerial references. |
| Road widths, campus paths and open-area extents | Approximate values in `CampusManifest.json`; campus paths use 6–12 m estimated widths | Low. Labels/relative sides are visible; widths are not specified. |
| Nominal building-to-building clearance | At least 6 m in the adjusted axis-aligned footprints | Schematic design target only; not a field measurement or a guarantee of avatar clearance. |
| Entrance 1 as `Gate1` | Provisional mapping | Needs the user/team to confirm which physical entrance should represent the A01 escape gate. |
| A3 crate/plate and B4 generator/fuse locations | Provisional gameplay markers | Not present as measured puzzle positions in the source maps; gameplay anchor placement is an estimate. |
| NPC and Mimic spawn positions | Provisional gameplay markers | Game-design positions, not real-campus measurements. |
| Building heights | Phase B uses 2–6 estimated stories. Typical floor height is estimated at 3.6 m for academic/mission buildings and 3.2 m for service buildings. | No elevation drawings or measured floor heights were supplied. These values are only for visual silhouette; they are not verified dimensions. |
| Phase C clear floor height | Academic/mission: 3.6 m between floor levels with an estimated 3.376 m (12.06 studs) clear height after the 0.8-stud slab; service: 3.2 m between floor levels with an estimated 2.976 m (10.63 studs) clear height. | Estimates from `CampusManifest.json`, not verified elevations. Both exceed a typical 5–6 stud Roblox avatar height; no claim of measured human-scale accuracy. |
| Phase C structural dimensions | Floor slab 0.8 studs; exterior walls 1.2 studs; interior partitions 0.6 studs; corridor up to 8 studs; stairs up to 7 studs wide with 0.82-stud target risers and treads up to 1.25 studs; ground-floor entrance 10 studs wide × 9 studs high. Room bays target about 26–38 studs along the corridor axis; the generator uses an odd bay count, clamped by each style profile. | Generic modeling estimates. Entrance sides, stair positions, room bays and balcony layout are not derived from measured building plans. |
| Phase C architectural style and room use | `CampusManifest.json` assigns a palette/archetype to each building ID; signs display the plan label (A2 reads “THƯ VIỆN A2”); most academic floors have 3–17 generated classroom Models per floor. A2, A3, B4 and service buildings get specialized room sets. | Visual design choices for the preview. Aside from A2 being the listed library, the colors, balconies, signage placement and room assignments are not evidence of verified real-world facade or interior detail. |

### Phase B story-count estimates

Every count below is an unverified modeling estimate chosen to give the campus a varied multi-storey silhouette. The reference plan maps identify building blocks, but do not establish these storey counts.

| Estimated stories | Buildings |
|---:|---|
| 2 | Kiosk 8, Facility 1, Facility 2 |
| 3 | B8, B9, B10, C6, B7 |
| 4 | B1A, B2, A1, A3, A4, A5, B6, C2, C3 |
| 5 | B1, A2 / Library, C1, C5 |
| 6 | B4, C4 |

Phase B v5 remains the exterior-only shell and has no interior or collision. Phase C adds estimated walkable floors, longitudinal corridors, partitioned classrooms/rooms, structural collision, stairs, selected balconies and room-type furnishings in a separate preview. The Phase C clear heights shown above are estimates; the 0.8-stud roof cap is separate from the storey count. No classroom or balcony geometry should be treated as a verified representation of the real building interior.

Do not describe this phase as 1:1 verified. The scale convention is real-world-sized, but the map's boundary, adjusted footprints, routes and gameplay anchors remain estimates until the team supplies measured control points or dimensioned plans. The paths are visual slabs; physical traversal has not been demonstrated.
