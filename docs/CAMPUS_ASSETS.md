# Campus environment and asset provenance

The gameplay campus uses the existing Gate, A3, Library and B4 mission anchors
over the 300 by 300 stud footprint specified by A01. Three source-built mission
shells frame the objective landmarks. Three placed Marketplace school models
use two inspected assets: the script-free 1,961-part Creator Store school
complex forms the West Academic Complex, and the one-MeshPart White Building 2
forms the South Academic Wing and North Academic Hall. The raised square-basin
fountain has collidable masonry and a non-collidable water surface. Ten low-poly
Oak tree reconstructions use two inspected Creator Store variants at about
2.64–2.78 studs tall; leaves are decorative, while each tree has a hidden
3.2 x 0.7 x 0.7 stud trunk collider. The A3 doorway is 16 studs wide to admit
the radius-2 Mimic pathfinding agent.
Benches, route lights, gardens, signage, the dressed route wall,
and capped/pilastered perimeter walls frame the paved courtyard. This remains
the A01 gameplay schematic, not a geographic recreation of the full HCMUT
campus. Campus changes support AC-01, AC-02, AC-03, AC-06, AC-07, AC-08 and
AC-09; natural traversal, visual approval and target-device performance remain
for human review.

## Marketplace assets

- [Park Bench, asset 2871491493](https://create.roblox.com/store/asset/2871491493),
  creator: Atarki. Creator Store search listed it as free and its description
  says it may be used freely. The source-controlled `MarketplaceBench.luau`
  reconstruction retains its 16 visible parts and colors, omits two Seats,
  and makes the bench solid. Confirm current asset terms before publishing.
- [Low-Poly Building, asset 13907146765](https://create.roblox.com/store/asset/13907146765),
  creator: Leonii_Dev. Creator Store search on 2026-10-31 listed it as free.
  Studio inspection found 239 anchored BaseParts and no scripts, meshes, unions,
  decals or UI; original bounds are about 46.49 x 43.18 x 28.57 studs. It was
  briefly trialed as a southwest annex, then removed from the runtime because
  its generic residential silhouette did not fit the school-campus architecture.
  The imported inspection copy remains in local `ServerStorage` and is not
  required by the map. Confirm current terms before any future use.
- [Low Polly Tree Realistic Forest Pack Trees Poly 3D, asset
  81110748228436](https://create.roblox.com/store/asset/81110748228436), creator:
  Witks0953. Creator Store search listed it as free; confirm its current terms
  before publishing. Local Studio inspection found 420 descendants, including
  ten MeshParts, a Script and a LocalScript, plus embedded UI/input components.
  The scripts were not run. This model was not selected for runtime use because
  each tree would need ten mesh pieces and its proportions remained too large
  for the requested small campus trees. The temporary imported model was
  removed after inspection; none of its scripts or UI were copied into the game.
- [Small Low Poly Tree, asset 13243800057](https://create.roblox.com/store/asset/13243800057),
  creator: DogenKaiser. Local Studio inspection found two MeshParts, no scripts,
  and source bounds of about 16.17 by 19.92 by 12.76 studs. An earlier source
  version reconstructed 20 of these trees at scale 0.14 using a separate
  collidable trunk proxy. The source was replaced because the trees looked too
  small in the campus overview; the import remains in local ServerStorage for
  reference but is no longer used at runtime.
- [Low-Poly Oak Trees Asset Pack, asset 8556375773](https://create.roblox.com/store/asset/8556375773),
  creator: Cliosow. The user authorized importing this free listing to local
  `ServerStorage` for inspection. Studio found 60 descendants: 53 MeshParts, six
  Models and one Camera, with no BaseScripts. Its five tree variants measure
  about 21.3 x 35.0 x 24.0, 19.8 x 35.2 x 34.2, 25.3 x 36.0 x 21.9,
  23.3 x 37.0 x 22.6, and 15 x 23 x 13 studs; individual variants use 7–14
  MeshParts. The source-controlled `MarketplaceTree.luau` reconstructs inspected
  Tree2 and Tree4 from whitelisted mesh IDs and measured offsets/rotations. The
  current runtime uses ten alternating variants at scale 0.075 (about
  2.64–2.78 studs tall). Muted campus-green leaves are decorative and passable;
  each trunk has a transparent 3.2 x 0.7 x 0.7-stud collidable proxy. Only the
  selected mesh IDs and measured transforms are copied into source; the
  imported pack and its scripts are not cloned. Confirm current asset terms
  before publication.
- [Low poly school, asset 9754216223](https://create.roblox.com/store/asset/9754216223),
  creator: Snazoid. Inspection found 95 Parts, two WedgeParts, 15 Models and no
  BaseScripts, with bounds about 156 x 57 x 151 studs. A 0.30-scale preview was
  about 46.8 x 17.1 x 45.4 studs, but its dark red, house-like facade did not
  match the campus style. It remains unused; the local inspection copy is in
  `ServerStorage`.
- [School, asset 10403432220](https://create.roblox.com/store/asset/10403432220),
  creator: LovesCake_09. Inspection found 1,961 collidable Parts and no scripts,
  with bounds about 230 x 78 x 251 studs. Its facade reads as a school, but the
  0.22-scale preview measured about 50.6 x 17.1 x 55.2 studs. The approved local
  import is cloned as `WestAcademicComplex` at (-185, 0, 90), with all 1,961
  BaseParts anchored and collidable after a BaseScript guard. It adds substantial
  geometry, so target-PC performance still needs measurement. The import is in
  local `ServerStorage`, outside the Rojo source tree; if it is absent, source
  builds a source-owned fallback. Keep the local
  import available when saving the place if the Marketplace complex should
  remain in it. Confirm current asset terms before publication.
- [White Building 2, asset 7932859944](https://create.roblox.com/store/asset/7932859944),
  creator: Karcist. Creator Store search on 2026-10-31 listed it as free. Local
  inspection found one MeshPart, no scripts, and source part dimensions of about
  1.16 x 0.80 x 2.50 studs. It is scaled by 30 for the runtime South Academic
  Wing and North Academic Hall (about 34.7 x 24.1 x 75 studs each after
  placement), anchored, queryable and collidable. This gives both wings a recognizable school silhouette without
  adding thousands of separate collision parts. Confirm current asset terms
  before publication.
- [Low Poly Tree, asset 12549617200](https://create.roblox.com/store/asset/12549617200),
  creator: Remadex Development. The user reported that this tree did not fit
  the map and remained too large, so it has been retired from source.
- [City High School Building, asset
  82816536715396](https://create.roblox.com/store/asset/82816536715396), creator:
  staticleelee. It was imported to local Studio for inspection and rejected:
  it contained 37,296 descendants and more than 100 Script nodes were visible
  in the first 100 inspection results. No part of it is used. The temporary
  imported model was removed without running its scripts.
- [School Building Desk Locker Classroom High Lockers, asset
  130337642742791](https://create.roblox.com/store/asset/130337642742791), creator:
  Ixfe1700. Local Studio inspection found 582 descendants in the imported pack;
  the outer pack includes `Runtime` and `ScreenBuilder` scripts. The nested
  `School.Building` model has 142 BaseParts, no scripts, and bounds of about
  33.1 by 33.9 by 23.8 studs. An earlier source pass cloned that nested model
  into the south academic area. Studio review showed a short red freestanding
  silhouette that did not match the other campus buildings, so the current
  runtime uses a matching source-built south wing instead. The imported pack
  remains under local ServerStorage for audit; its scripts were not run and its
  geometry is no longer cloned. Confirm current asset terms before publishing.
- [Modern Brick School Building, asset
  76558120171446](https://create.roblox.com/store/asset/76558120171446), creator:
  ROKE0. The listing describes an exterior-only school. Local inspection found
  3,226 descendants, including 3,136 BaseParts and no BaseScripts. It was
  rejected because the geometry count is too high for one decorative campus
  building on the target integrated GPU; it is not used at runtime.
- [School Model Low Poly Classroom Pack High Building, asset
  114248191903321](https://create.roblox.com/store/asset/114248191903321),
  creator: Ironbe4049. The listing described 90 parts, four meshes, four
  decals/textures, 22 lights and no scripts. Local Studio inspection instead
  found 592 descendants, including 90 BaseParts, four MeshParts, one enabled
  `Script`, one enabled `LocalScript`, a `RuntimeInput` context, classroom
  furniture and curtains. The sample was imported to local ServerStorage for
  inspection; its scripts were not run. It is a classroom
  pack rather than a campus exterior and is not used at runtime. The temporary
  inspection model remains in local ServerStorage for review. A temporary
  visual preview of its script-free 35-part `school` child showed a partial
  wall/corner with louvers and floor, not a complete exterior building; its
  script-free 22-part `Model` child was fully transparent. Both temporary
  Workspace previews were removed after capture.
- [Meepcity School Desk Chair Classroom Sign Door, asset
  74004694936337](https://create.roblox.com/store/asset/74004694936337),
  creator: Ironba6666. The Creator Store listing reported 155 parts, one mesh,
  11 unions, a roughly 24 by 34 by 33 stud footprint and no scripts. The
  user authorized importing it into local ServerStorage for inspection. The
  imported model has 578 descendants including 155 BaseParts, one enabled
  `Script`, one enabled `LocalScript`, UI and input-context objects. Its isolated `Building` child
  has no scripts, but contains 137 BaseParts and measures about 33.1 by 33.9 by
  23.8 studs. A temporary visual preview showed a narrow red school silhouette
  with a dark tiled roof and small shrubs; it does not fit the restrained
  navy/teal/amber campus. The preview was removed. The import remains in local
  ServerStorage for audit; no imported scripts were run and neither the pack
  nor its Building child is used at runtime. Confirm current asset terms before
  publishing.
- [Building 3, asset 7069505373](https://create.roblox.com/store/asset/7069505373),
  creator: Karcist. The imported asset is a single MeshPart named
  `Meshes/Мотель Абат`, a motel rather than a school building, so it is not
  used at runtime. No scripts were present.
- [Modern Brick School Building Low-Poly Modern House, asset
  88873534168303](https://create.roblox.com/store/asset/88873534168303), creator:
  Petercod7s7e. The free listing was imported to local ServerStorage for a
  safety and size check. It has 3,248 descendants, 3,136 BaseParts, six
  enabled server/client scripts, UI and a Camera, and bounds of about
  413.5 x 79.1 x 107.9 studs. The import was sandboxed by Studio; scripts were
  not run. It is too large and dense for this low-poly map and is not used.
- [Low Poly Sky RP Brookhaven Model School Building, asset
  116288795406528](https://create.roblox.com/store/asset/116288795406528), creator:
  XzV3nomIOPix3lcOT3ch. The free listing inserted as a `Sky` object rather than
  a school model; it contains nine descendants, including five scripts/modules,
  and no building geometry. It remains in local ServerStorage for inspection;
  scripts were not run, and it is not used.

The inspection-only tree 81110748228436 and school 82816536715396 imports were
removed from the local, unpublished place after inspection. Their contents are
not cloned into the running map and no imported scripts were run. The inspected
130337642742791 pack remains under local `ServerStorage` for audit, but its
geometry is no longer cloned.

## Source-built campus geometry

`CampusExpansion.luau` owns three source-built mission shells and a source-built
academic-wing fallback, front facade openings, side-window details, entrance
canopies and role-specific campus
silhouettes. The source-owned North Academic Wing fallback has a clock tower;
the South Academic Wing and North Academic Hall use the White Building 2 mesh;
the Library has a raised reading hall and paired
portico columns; A3 has lab ventilation grilles; and B4 has generator ventilation
grilles and exhaust stacks. The formerly optional residential-looking annex was
removed from runtime after visual review. `CampusGatePortal.luau` frames Gate 1,
and `CampusBackdrop.luau` adds non-collidable distant silhouettes outside the
playable boundary. Structural walls, floors, roofs, entrance supports, all
three placed Marketplace school models, benches, the fountain's square masonry
body/rim/column,
lamp poles, planter stone edges, and wayfinding posts/boards collide. Front
window glass is collidable and excluded from ray queries so gameplay sight rays
pass through the cutouts. Fountain water and plaque, Oak leaves, facade trim,
planter soil, shrubs, flowers, path marks, grass and backdrop remain
non-collidable. The original `SightlineDivider` remains the
collidable and queryable cover wall. Tree2 and Tree4 meshes from asset 8556375773
are reconstructed with `SpecialMesh` on source-owned Parts; no imported scripts,
UI or cameras are copied. Route lights use unshadowed point lights to limit
shadow cost. Night ambient was raised for visibility, and backdrop silhouettes
were shortened and lightened; visual feel and target-device performance remain
for human review.

The map and asset extraction were assisted by AI. The student team should
review the source code, asset terms, visual fit and performance before release.


## Small Oak trees (2026-10-31)

The runtime uses the free Creator Store [Low-Poly Oak Trees Asset Pack, asset
8556375773](https://create.roblox.com/store/asset/8556375773) by Cliosow. Studio
inspection found 53 MeshParts across five variants, no BaseScripts, and Tree2/Tree4
source heights of about 35.18 and 37 studs. `MarketplaceTree.luau` reconstructs
these two variants from whitelisted mesh IDs, part-to-mesh size ratios, and
measured local transforms. At scale 0.075, their visible heights are about
2.64 and 2.78 studs. Ten trees alternate the variants. Leaves remain
non-collidable; each tree has a transparent 3.2 x 0.7 x 0.7 stud anchored
trunk proxy in the Default collision group. The proxy is taller than the visible
tree so the avatar's rigid collision body meets it while foliage remains passable. The
inspected import remains in local `ServerStorage` for audit, but runtime
geometry is reconstructed from the whitelisted mesh IDs and does not require
the pack to be present for Rojo builds. Confirm Creator Store terms before
publication.
