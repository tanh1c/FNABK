# AI assistance record

## 2026-11-04 — SURV-06 Studio-only disguise appearance trial

AI assistance added `MimicAppearancePreview`, an optional Studio-only visual adapter for the existing graybox Mimic. It clones the already inspected `Student 1 / R6` gallery model, removes scripts, Humanoid, UI and the display stand, anchors the remaining visual parts, and parents them under the server-owned Mimic so `PivotTo` moves the appearance with its existing controller. It returns without changes if the gallery sample is absent and rejects duplicate attachment. This is a static appearance trial, not character animation, a new AI implementation or full SURV-06 acceptance. A runtime equivalent observed Chase and Search with the appearance following; the module body also passed a server Play-mode check for attach, duplicate rejection, script removal and movement. The actual Rojo-synced bootstrap, baton/UV/scanner interaction, visuals, animation and other roster models remain untested. A Rojo build succeeded; the student team must review the code and asset rights.

## 2026-10-31 — HCMUT Campus 1 Phase A graybox

AI assistance created a detached, source-generated campus footprint prototype from the user-provided HCMUT campus maps. `CampusManifest.json` and `Markers.json` are the editable coordinate sources; `tools/Generate-CampusPhaseA.ps1` exports the Rojo Luau manifest module and top-down SVG. `CampusBuilder` composes generic footprint, area, road/boundary, and marker generators. All preview parts are anchored and non-collidable, and the builder is not called by the gameplay bootstrap. The published campus area and Roblox stud conversion are documented as sourced values; the parcel outline, building dimensions/positions, map heading, and gameplay markers are explicitly estimated. The student team must compare the graybox against measured plans and review every estimate before any gameplay integration. This Phase A prototype does not establish a verified 1:1 reconstruction or measured target-device performance.

## 2026-10-31 — CR-004 detached multi-storey exterior shells

At the user's request, AI assistance extended the detached campus preview with native-Part exterior massing for all 23 building footprints. The manifest records explicit estimated story counts and typical floor heights; `BuildingFootprintGenerator` builds a separate Model for each shell, while `FacadeGenerator` adds grouped window ribbons, floor bands, and corner piers. These accents only communicate a multi-storey silhouette. There are no interior floors, walkable rooms, stairs, or collision, and the builder remains disconnected from runtime gameplay. Measurements were not supplied for elevations, so the story counts and heights are estimates for team visual review. Roblox Studio MCP Edit built v5 with 851 BaseParts (781 building Parts), 23 building Models and 16 markers; the structural check found no scripts, unanchored/collidable parts or oversized parts. Human visual acceptance remains pending in flow #12 of `MANUAL_CONFIRMATION.md`; the student team should inspect and explain the manifest-driven sizing and grouped Part generation before integrating anything into the playable map.

## 2026-10-27 — first gameplay prototype slices

AI assistance helped author and document the runtime graybox, Mimic Chase/Attack/Search controller, and the first AC-04 baton prototype. Mimic damage is applied by the server with a cooldown. The baton server module checks the server-granted Tool, living player, known NPC, range, line of sight, and cooldown before applying the A01 damage or wrongful-hit rules. The client raycasts from the camera and sends only a target model as intent. A normal Student model and a path-based flee reaction were added to make the wrongful-hit behavior observable. Studio-only overhead debug labels identify each NPC and show its state; they are guarded by `RunService:IsStudio()` so published servers do not reveal NPC identities.

The AC-05 UV prototype grants a server-marked UV Device and accepts only the known Mimic as target intent. The server checks player life, device possession, range, line of sight, and cooldown, then sets a server-timed `Stunned` state for the A01 2.2 seconds; the Mimic controller pauses movement/attacks until that timer expires and resumes Chase. The client maps **F** to UV intent and displays server feedback.

The follow-up AC-05 Scanner slice grants a server-marked Scanner and accepts server-map NPC models tagged as a Mimic or Student as target intent. The server validates player life, tool possession, 12-stud range, line of sight and 8-second cooldown, then checks those conditions during the 1-second scan before returning `ANOMALY SUSPECTED` or `NO ANOMALY FOUND`. The client maps **Q** to scan intent and displays server feedback; it does not choose the classification.

On 2026-10-28, the user reported that their AC-05 Studio test passed. The acceptance record marks this as user-reported; individual test logs and screenshots were not supplied. The assistant built the place and checked the serialized scripts but did not run Play or execute Luau gameplay tests.

The Studio-only range guide is a local client aid: **V** cycles Baton, UV and Scanner radius previews; a sphere is centered on the player root and the HUD compares the aimed NPC's `PrimaryPart` distance against the selected `GameConfig` range. The guide is guarded by `RunService:IsStudio()`, sends no gameplay requests and does not change authority or range rules. The Scanner's 12-stud preview matches its server-validated range.

The baton damage, range, cooldown, Mimic health/damage/cooldown, Trust baseline, and Trust penalty come from A01. A01 leaves Mimic attack range unspecified; this prototype uses `mimicAttackRangeStuds = 3.5`. A01 requires wrongful hits to increase Alert but does not set an amount; this prototype uses `wrongfulHitAlertIncrease = 1` as an explicitly marked provisional value. No new required gameplay was added to the baseline.

The owning student team must review the Luau, run and record the manual Studio checks in [ACCEPTANCE](ACCEPTANCE.md), and be able to explain why target selection is only client intent while damage, Trust, Alert, NPC state, and Scanner classification remain server-controlled. The `rojo build` command is used as a source/project build check; the assistant did not run Studio gameplay tests. AC-03 and AC-04 remain `NOT TESTED`; AC-05 has a user-reported PASS with no attached detailed evidence.

## 2026-10-28 — AC-06 A3 physical puzzle slice

AI assistance authored a graybox A3 `FuseCrate` and `PressurePlate`, plus the server-owned `A3PuzzleService` and `CrateInteractionService`. CR-001 adds an E prompt to pick up and place the crate, contrary to A01's push-only interaction. While held, a WeldConstraint attaches it in front of the character, collision stays enabled, and movement slows. The carry offset leaves a gap so normal speed can return immediately when the crate is dropped. Body-contact speed is reduced only while the player is actively moving into the crate; it restores immediately when the push input stops or contact ends. The server validates the prompt player's character, health, range, and line of sight before pickup; it also monitors crate speed and in-bounds position changes. The thin, non-collidable plate remains flush with the floor. A low-frequency server check confirms the crate is not carried, its full footprint fits on the plate, and position/velocity show it has settled there for at least 0.5 seconds. Successful placement sets replicated `A3PowerRestored` and shared `DataKeys/Key1`; Key 2 and Key 3 start false. A bounds check waits the A01 10 seconds before returning an inaccessible crate to its authored reset position. No client remote can grant power or keys. The Studio test still needs to confirm carry/drop, body-push feel, collision reliability, and reset behavior.

The student team should inspect the Luau and explain the plate-footprint check, server-validated carry prompt, WeldConstraint, temporary physics ownership and movement/speed guards, server-owned Key state, and delayed recovery. AC-06 remains partial until the updated manual cases in [ACCEPTANCE](ACCEPTANCE.md) are run and recorded by the team.

## 2026-10-28 — AC-07 Library investigation first-slice

AI assistance authored three graybox Library suspects and `LibraryInvestigationService`. The server enables interview prompts only after Key 1, validates the player is alive, within interaction range, and has line of sight, then records shared interview flags and two clues on the Library Mimic. A correct accusation after all three interviews and both Mimic clues sets shared `DataKeys/Key2`; wrong student accusations grant nothing and do not change Trust. The existing Scanner now validates any server-map model tagged as a Mimic or Student, so it can provide corroborating evidence without awarding Key 2. The client displays clue and outcome feedback; it does not decide identity or modify key state. On 2026-10-28, the user reported passing the Library investigation and collecting Key 2. This is a user-reported result; wrong-accusation and two-client cases were not separately reported.

## 2026-10-28 — AC-08 B4 and Gate/round first slices

AI assistance authored `B4GeneratorService`, the B4 graybox fuse/generator, `RoundService` with Gate 1 geometry, and `PlayerLifeService` for downed/revive behavior. B4 requires Key 2; the server validates living player, range and line of sight, records shared `B4FuseFound` / `B4PowerRestored`, and grants Key 3 only after the fuse is collected and the generator is activated. For Gate 1, the server checks all three keys, tracks hold start/end timestamps, rechecks range and line of sight, and enforces the configured five-second duration before opening the door. It owns the shared round countdown, timeout/team-down loss state and exit-zone win. The user reported collecting Key 3 and escaping through Gate 1 on 2026-10-28; timeout and team-down behavior have not been tested in Studio. At that time, medkit placement/use was unimplemented.

`PlayerLifeService` routes Mimic attacks through a server-owned damage function. Solo downing marks the player eliminated and ends the round; in co-op a target remains immobile at 1 HP for 20 seconds, while a living teammate can hold the target's ProximityPrompt for five seconds within six studs and clear line of sight to restore 40 HP. The server checks hold duration and interaction requirements again before reviving. Downed and eliminated attributes prevent use of combat tools, missions, the crate and the exit. The owning team should review the state flow and verify solo loss, co-op revive, bleed-out and both-player-down cases in Studio; medkit support remains a separate missing feature.

After the user's first two-client revive attempt failed, AI assistance updated `PlayerLifeService` so the prompt is not hidden by third-person line-of-sight occlusion; the server continues to enforce its own six-stud and raycast checks. A health-change guard now keeps downed/eliminated characters at 1 HP despite default regeneration, and bleed-out retains an `ELIMINATED` marker so the immobile state is clear. The user later reported that the revive and bleed-out retests passed; AC-08 retains both the initial failure and the follow-up PASS, with detailed logs/screenshots unavailable.

## 2026-10-31 — medkit slice

AI assistance authored `MedkitService`, two runtime graybox pickups, an R-key request and a local inventory indicator. The server validates life, round state, pickup distance and line of sight, prevents carrying more than one, and caps the 40-HP heal at MaxHealth. R at full health does not consume the item. The student team should review how the server resolves simultaneous pickup requests and why a client request cannot set health or inventory. A Rojo build succeeded. Studio MCP solo checks were partly successful using test-only state manipulation; a fresh near-full check reached 100 HP; two-client behavior still needs validation. See the medkit record in ACCEPTANCE.

AI assistance also implemented `ObjectiveHintService`, which monitors server-owned objective values and sends a phase-specific hint after 90 seconds without tracked progress. Changes to keys, interviews, clues, fuse or gate restart the timer; a hint is sent once per idle interval and never grants mission progress. A temporary three-second instance in Studio Play produced A3, Library and B4 hints after test-only state changes and did not produce a hint during a four-second Lost state; actual timing, client delivery and co-op remain to be checked. The student team should review the tracked milestones and explain how the timer resets. The optional 150-second stronger hint is not implemented. A combined manual confirmation backlog is maintained in `MANUAL_CONFIRMATION.md`.

AI assistance added `MovementService` with server-owned stamina, sprint/crouch requests and a single calculation for life and crate speed restrictions. Crate interactions now signal carrying/pushing instead of saving and restoring an old speed. The team should explain stamina integration over frame time, one-second recovery delay and restriction precedence, and review the manual backlog. Studio MCP solo checks exercised sprint, crouch, crate carry/drop and test-only downed attributes; exhaustion, body-pushing, real revive and co-op remain unverified.

AI assistance added a client-side joint pose and Running sound volume adjustment for crouch, plus server-side movement hearing in `MimicController`. A temporary test Mimic with vision disabled entered Suspicious then Search after walking nearby; a crouched movement attempt outside the provisional four-stud range did not trigger it. The team should explain how server-observed speed, grounded state and stance select a provisional hearing radius and why hearing does not authorize attacks. R6, audible/visual quality, actual chase, wall behavior and two-client presentation need validation; see ACCEPTANCE and the manual backlog.

Follow-up debugging found the Studio avatar uses AnimationConstraints, which the original Motor6D-only crouch implementation skipped. AI assistance updated the joint selection and moved transform application to PreSimulation, after Animator evaluation. Studio MCP observed the intended hip/waist transforms during crouch and animation-driven transforms after release. It did not establish visual quality or R6/co-op coverage. The asset mismatch was investigated but its requester was not identified; no asset was changed.

AI assistance created an A3 lab graybox visual sample and destination board as source-generated primitive parts in `A3Graybox`, preserving existing mission paths and object positions. Most details are non-collidable and non-queryable; two short corner returns are solid. Pathfinding probes and a test-only repositioned carrier confirmed selected path queries and Key 1 activation, but automated carry traversal did not finish and is not marked as a pass. The student team should review the new spatial layout, wall collision, readable signage and carry/Mimic routes in a full Studio playtest. No third-party assets were imported.

AI assistance added `CampusEnvironment` and moved the spawn to the Gate courtyard, with source-generated low-poly facades, signage and Library/B4/Gate details. The follow-up expanded the schematic to 300 x 300 studs, added connected paths, building fronts and nighttime lighting, and moved the large divider away from the Gate sightline. Its first Marketplace pass reconstructed Park Bench 2871491493 by Atarki and Low Poly Tree 12549617200 by Remadex Development. The bench remains in source; the Remadex tree was retired after the user said it did not fit the map. Earlier no-script inspection applied only to those two first-pass models. Route pathfinding and gameplay interaction still need natural solo/co-op review. The earlier pathfinding probes and manipulated gate checks found an intermittent Gate hold rejection; a 0.25-second prompt buffer was added while the server still requires five seconds. The team should review the Luau, asset terms and target-device visual/performance.

On 2026-10-31, AI assistance replaced the non-collidable building-front props with collidable room shells for A3, Library and B4, and two academic wings with open passages aligned to the mission paths. Existing placeholder blockers were hidden where they overlapped the new doors; the B4 access wall was split to keep the generator approach clear. This is the earlier source version, where the Remadex tree scale was reduced from 0.1 to 0.01. Rojo build succeeded, and prior Studio checks recorded route pathfinding and interior navigation; the screen capture was black, so those checks never established visual quality.

An earlier 2026-10-31 patch rebuilt the facades with real glass openings, distinct accent bands, entry canopies, parapets, rooftop vents and green boundary strips. The facade builder cuts wall bays at door and window edges; transparent collidable glass blocks movement while line-of-sight ray queries ignore it. It moved the B4 shell forward to z=-102, aligning the entrance with the mission approach. The user approved two local Creator Store imports for inspection. The replacement tree asset 81110748228436 contained ten MeshParts plus a Script, LocalScript and embedded UI/input objects; the school asset 82816536715396 contained 37,296 descendants, including 1,302 enabled Scripts, so it was rejected. Neither asset's scripts were run; temporary inspection models were removed. An intermediate source version whitelisted the first tree's ten mesh IDs and built 14 trees; that version was superseded by the follow-up below. A new Rojo build succeeded. Controlled Humanoid MoveTo probes stopped at the A3, Library and B4 windows and the earlier tree trunk, while reaching the building entrances. Studio's screenshot did not produce a usable overview, so human style review, natural solo/co-op traversal and target-device performance remain pending. The student team should review the Luau, explain the mesh whitelist/scale and collision design, verify asset terms, and record the manual map flow in `MANUAL_CONFIRMATION.md`.

## Earlier 2026-10-31 campus asset and collision iteration (superseded)

This iteration initially retained the 142-part script-free child from Creator Store asset 130337642742791 and used the two-mesh tree asset 13243800057 at scale 0.14. It was superseded after visual review and further marketplace checks. Its counts and route probes describe that older source version only; the current school assets, tree scale and collision evidence are recorded below and in `ACCEPTANCE.md`.

The 2026-10-31 campus identity patch added `CampusGatePortal.luau` and role-specific roof details in `CampusExpansion.luau`. Intermediate tree implementations used asset 5981037621 and then asset 8556375773 at scale 0.078; the current 0.085 scale and collision proxy are documented below. `CampusBackdrop.luau` adds distant non-collidable campus silhouettes outside the playable boundary. The current Play check and its limits are recorded in `ACCEPTANCE.md` and `MANUAL_CONFIRMATION.md`.

## 2026-10-31 — campus visual readability follow-up

AI assistance brightened the midnight ambient fill and path lights, gave a subset of windows an emissive material, raised the building entry masses, lowered the collidable perimeter walls from 12 to 10 studs, added non-collidable wall accents and a source-built fountain in the quad, and dressed the existing SightlineDivider as a campus route monument. The five mission shells and routes remain anchored in `CampusLayout`; the fountain and divider dress have no prompts or gameplay state, and the original divider remains collidable/queryable. Studio MCP measured 1,343 map BaseParts (335 collidable), found all four radius-2 route legs successful, and confirmed the north wall blocks a direct Humanoid move and the divider blocks a raycast. The student team should inspect these changes at normal player height, explain why visual trim/fountain/divider panels are non-collidable, and perform the remaining natural route and co-op checks listed in `MANUAL_CONFIRMATION.md`.

### Campus side facade details — 2026-10-31

AI assistance added a base plinth, floor-height accent band, roof cornice and centered vertical pier to each side of all five school shells. The `detail()` helper marks these Parts non-collidable, non-touchable and non-queryable, so the change alters the broad side elevations without changing collision or line-of-sight geometry. Studio MCP verified eight such pieces per building (40 total), all passable; runtime count rose from 1,343 to 1,383 BaseParts while collidable count stayed at 335. Radius-2 pathfinding succeeded along Gate→A3→Library→B4→Gate, and a ground-level capture showed the details. The student team should explain how `sideCenterZ` places details between the side-window stations and why the new Parts remain decorative, then record human visual feedback in `MANUAL_CONFIRMATION.md`.

## 2026-10-31 — campus role silhouettes and collision revision

AI assistance added role-specific architectural parts in `CampusExpansion.luau`: academic tower details, a raised Library reading hall with portico columns, A3 lab grilles and B4 generator grilles. These details preserve the A01 mission anchors and doorway locations. The Oak pack's raw geometry is reconstructed from whitelisted mesh IDs and measured transforms. The current scale is 0.085, producing roughly 2.99–3.15-stud variants; a transparent 0.45-stud-wide trunk proxy spans each tree's height and only the foliage meshes remain non-collidable. The generic residential-looking annex was removed from runtime to keep the campus style cohesive. The fountain has visible square masonry, a rim and water surface; masonry collides and water/plaque do not.

The student team should be able to explain how measured mesh offsets/rotations and the mesh-size ratio reproduce Creator Store geometry, why one invisible trunk proxy replaces per-leaf collision, how transparent gameplay glass remains collidable while sight rays ignore it, and why fountain water/visual trim remain passable. Earlier automated checks used an older 3.3–3.4-stud tree version; see the current Play evidence added below and the outstanding human flows in `MANUAL_CONFIRMATION.md`.


### Oak asset reconstruction and collision (2026-10-31 follow-up)

The current tree module uses only measured mesh IDs, sizes, offsets and rotations
from Tree2 and Tree4 in the free Oak pack 8556375773 by Cliosow. It does not clone
the imported model or run/copy scripts. For each visual, `SpecialMesh.Scale`
applies the measured `MeshPart.Size / MeshSize` ratio and the 0.085 campus scale.
Eight trees alternate the two shapes. A full-height, 0.45-stud transparent
trunk proxy blocks movement through the trunk; leaf meshes remain decorative.
The student team should explain how the mesh-size ratio preserves source
proportions, why one proxy replaces per-leaf collision, and why an open mission
doorway correctly allows movement.

### Marketplace school model selection (2026-10-31 follow-up)

The script-free asset 10403432220 has a recognizable school silhouette and is
now used for the West Academic Complex despite its 1,961 collidable parts; its
target-PC performance remains unmeasured. Asset 9754216223 was rejected for its
dark red house-like silhouette. The optional residential-looking asset
13907146765 was removed from the runtime after visual review. The team should be
able to explain how script count, part count, silhouette and A01 style informed
selection; no imported script was run.

## 2026-10-31 — campus school mesh and small-tree revision

The South Academic Wing uses the one-MeshPart [White Building 2 asset
7932859944](https://create.roblox.com/store/asset/7932859944) by Karcist at
scale 30. The southwest West Academic Complex uses [School asset
10403432220](https://create.roblox.com/store/asset/10403432220) by LovesCake_09
at scale 0.22. `MarketplaceSchool.luau` and `MarketplaceCampusComplex.luau`
check the imported models for any BaseScript before cloning, then align their
bounding boxes, anchor their parts and enable collision/query. If an import is
absent, `CampusExpansion.luau` builds a source-owned fallback. These imports are
local ServerStorage dependencies outside Rojo source. The team should be able
to explain the guard, scale, placement, collision cost and fallback behavior.

The eight Oak reconstructions from asset 8556375773 use scale 0.085 (about
2.99–3.15 studs high). A transparent 0.45-stud-wide full-height trunk proxy is
collidable; foliage is passable. The client `TraversalGuard.client.luau`
disables the Humanoid Climbing state because the GDD has no climbing mechanic
and controlled movement showed avatars scaling collidable window panes. This
keeps intended solid wall collision while preserving open doorways. The team
should explain that this is client-side movement setup rather than server-side
damage, mission or NPC authority.

The latest automated campus run produced 3,177 BaseParts (2,198 collidable)
and zero scripts under the generated map. The West school clone had 1,961/1,961
BaseParts anchored and collidable, no scripts, and bounds about 50.63 x 17.14 x
55.19 studs. All four radius-2 route queries succeeded; direct client movement
stopped at the A3 window, West school surface and Oak trunk while the A3 center
door remained open. A valid Blockcast also hit the West school. Captures show
the placed complex and source-built objective buildings, but visual approval,
natural traversal, co-op and target-device performance remain pending in
`MANUAL_CONFIRMATION.md`. No place save or publication occurred.

## 2026-10-31 — campus asset and Mimic entrance follow-up

AI assistance revised the current campus source to place a third Marketplace
school model, reuse the one-MeshPart White Building 2 for the North Academic
Hall, set ten Oak reconstructions to scale 0.075, add A3/Library/B4 interior
dressing, and make the SpawnLocation invisible/non-collidable. The Oak trunk
proxy is a 3.2 x 0.7 x 0.7 stud cylinder because a shorter proxy let the R15
collision body pass above it. The A3 facade entrance was widened from 10 to 16
studs after tests showed that a player could walk through the old opening but
the Mimic's radius-2 path agent got `NoPath`; after the update, all four
Gate→A3→Library→B4→Gate path legs succeeded with the Mimic's agent settings.
The change preserves all A01 mission anchors and gameplay state.

Studio inspection found the approved Oak source has no BaseScripts. Two
approved classroom pack imports (114248191903321 and 74004694936337) each
contain one enabled `Script` and one enabled `LocalScript`, contrary to their
listing summaries; neither imported script was run and those packs are not used
at runtime. Studio captures show the campus overview and current room dressing,
but the interiors still have graybox materials and need human style approval.
The student team should review the source, explain the path-agent/door-width
relationship, tree mesh-scale/collider choices and asset rejection criteria,
and complete flows #8–#10 in `MANUAL_CONFIRMATION.md`. No place save or
publication occurred.

## 2026-10-31 — HCMUT Campus Phase A graybox

AI assistance added a local JSON campus manifest and marker manifest, a
PowerShell exporter for Luau data and an SVG plan view, plus modular Roblox
Luau generators under `src/server/CampusPhaseA/`. The proposed coordinate
frame uses meters, an estimated southwest origin, `+X` east, `+Z` north and
`+Y` up. The approximate 14.08 ha published area and Roblox's 0.28 m/stud
conversion inform the scale; parcel outline, building dimensions, paths and
gameplay anchors remain estimates. This detached graybox does not alter the
A01 runtime map, mission anchors or gameplay services.

Rojo built successfully to a new review output. In the local Studio Edit
DataModel, Luau execution created two versioned detached previews (`_v1` and
`_v2`) at the same remote offset; each contains 61 BaseParts, 23 building
models and 16 named marker parts, with zero unanchored parts, collidable parts
or scripts. The second preview's markers were raised and enlarged after the
top-down review showed the original marker height was hidden by building
footprints. The live Edit session has not been saved or published. After
explicit user approval, the exact duplicate `_v1` preview was removed (61
BaseParts); `_v2` remains in the Edit session.
Human confirmation of gate identity, orientation against a surveyed plan,
footprints, marker locations and whether this should replace the fictionalized
A01 map remains pending.

During an earlier attempt in this session, a user-provided campus reference
image was passed to the Roblox Studio MCP image-store/procedural-model flow.
Roblox moderation rejected that cloud operation; no Roblox asset ID was
returned by that attempt. This violated the user's asset-upload restriction.
The repository now records the mandatory local-only policy in `AGENTS.md`;
future campus work must use local references and native Luau geometry only.

## 2026-10-31 — Phase A spacing and circulation follow-up

At the user's direction, AI assistance adjusted estimated Phase A building and
open-area footprints to remove overlaps, added a connected schematic network of
6–12 m pedestrian paths, and relocated detached gameplay markers to the new
footprints/routes. The source remains separate from the A01 gameplay map and
all generated geometry stays anchored and non-collidable. A simple rectangle
intersection/separation and path-connectivity check found zero footprint
overlaps, zero building/path intersections, 6 m minimum building clearance,
and one connected network of 33 pedestrian slabs; all 16 anchors match their
intended bounds. This check cannot establish survey accuracy, avatar clearance,
NPC pathfinding or target-device performance. The student team should compare
the new top-down preview to the reference maps, identify intentional spacing
departures, and explain how rectangle bounds and touching path endpoints were
checked. No reference image is uploaded, and no place save or publication is
part of this work.

## 2026-11-01 — Phase C generic building interiors

At the user's direction, AI assistance added a separate Phase C Luau build mode for the detached HCMUT campus preview. It generates walkable floor slabs, a south-facing ground-floor opening in each building shell, collidable exterior walls and room partitions, a repeatable block-step stair flight with upper-floor shaft openings, roof caps, and low-part-count collision-enabled furniture. The library, A3 laboratory, B4 ground floor, academic buildings and service buildings use different simple furniture layouts. The Phase B v5 path remains the default and the A01 gameplay bootstrap is unchanged.

The manifest documents estimated 3.6 m academic/mission floor-to-floor height and 3.2 m service height; clear height after the slab is about 12.06 and 10.63 studs. Room dimensions, stair locations, entrance sides and furniture are generic estimates because no building elevation or interior plan was supplied. The student team should inspect `WalkableInteriorGenerator.luau` and `InteriorFurnitureGenerator.luau`, explain how the slab opening aligns with a stair flight and how wall/furniture collision differs from decorative window/trim parts, then complete flow #13 in `MANUAL_CONFIRMATION.md`. Studio Edit structure counts are recorded in the Phase C README; Studio MCP screen capture returned a black viewport, so visual approval remains pending. No asset upload, save or publication is performed.

## 2026-11-01 — Differentiated campus architecture and multi-room floors

At the user's direction, AI assistance added CR-006, 23 data-driven building styles, native name signs, entry canopies/lights, facade colors and bands, selected accessible balconies, railings, sunshades, rooftop details, and room-specific furniture to the detached Phase C preview. `ClassroomLayoutGenerator.luau` chooses the longer footprint axis for the main corridor, divides each wing into odd-numbered bays, leaves an entry foyer where the south door crosses the perpendicular corridor, and creates doorway gaps in the corridor wall. Side walls at bay boundaries make separate room volumes. The odd bay count keeps a central bay aligned with that entry connector. `WalkableInteriorGenerator.luau` positions the stair opening and steps using the same interior frame, and reserves a room bay for the stair hall. These are modeling rules for a fictionalized preview; they do not reproduce measured HCMUT interiors.

The in-place Studio Edit audit counted 16,138 BaseParts (10,318 collidable), 851 room/lobby Models in total (including 700 classroom Models), 89 separate stair halls, 40 balcony decks, 23 building-name signs and 339 PointLights. All parts are anchored, no part exceeds 2,048 studs, and zero scripts were added; all 16 gameplay marker IDs remain present. This audit validates instance structure, not collision traversal, visual acceptance or frame rate. The student team should explain how bay widths and door openings are computed, then perform flow #13 in `MANUAL_CONFIRMATION.md`. The place was not saved or published and no asset was uploaded.

## 2026-11-01 — Building-specific facade and readable nameboard revision

Following review against five user-provided local photographs, AI assistance replaced the repeated facade ribbon treatment with data-driven facade compositions, entry forms and roof forms. All 23 building profiles now have distinct three-part style combinations. The generator composes punched windows, stacked balconies, vertical fins, central glazed bays, concrete piers/colonnades, deep sunshades, entry canopies or porticos, and varied parapets/roof towers/clerestories/utility features from Roblox-native Parts. B4 receives a full-span stacked gallery cue from the B4-labeled photograph; other photo motifs are not assigned to buildings without evidence. Nameboards now use a framed dark-blue board and fixed 64-pixel Gotham Bold text without auto-scaling or wrapping.

The profile data and generator code are local; the reference photographs were not uploaded or imported. The local Rojo build succeeded. The current in-place Studio Edit structural audit counted 16,645 BaseParts (10,551 collidable), 23 building Models, 16 gameplay markers, 700 classroom Models, 851 room/lobby Models, 44 balcony decks, 23 signs and 339 PointLights. All parts are anchored; there are no scripts or parts over 2,048 studs. All 23 facade/entry/roof profile triples are distinct. B4 has five 220.6 x 4.6-stud gallery decks. Punched-window rows share their frame band and sill to reduce repeated parts. These are instance checks, not a readability, traversal, visual-acceptance or FPS test; Studio's screen capture still returns a black viewport and flow #13 remains pending. No place save, publication or asset upload occurred.

## 2026-11-01 — Exterior-gallery architecture rework after visual rejection

At the user's direction, AI assistance revised the detached Phase C school architecture after the earlier glass-heavy bars were rejected. `ExteriorGalleryGenerator.luau` uses the classroom-bay centers to align passable doors and adjacent classroom window openings with each gallery wall. The door gaps remain traversable; glass and window trim are passable; a collidable sill separates the elevated window opening from the floor. The same style record controls gallery count/orientation, width, rail, support and canopy. `BuildingMassingGenerator.luau` maps each of the 23 unique `buildingForm` values to a distinct combination of portals, cantilevered plates, screens, tower cores, laboratory/market shed roofs, library podium and roof lanterns. Projections are routed to a non-gallery side/end for wide footprints so they do not cover the exterior circulation path. The generation is local Luau; no reference photo, cloud generation, upload, place save or publication was involved.

The current Studio Edit audit counts 27,140 BaseParts, 16,907 collidable parts, 530 PointLights, 640 gallery doors/windows, 23 unique massing outputs and 23 gallery profiles. `rojo build` succeeded and the in-place detached preview refresh completed. This does not prove that players will perceive the silhouettes as distinct, that stairs/doors are traversable, or that Intel Iris Xe reaches 30 FPS; the automated Studio capture was blank, so the student team should inspect these profiles at player height using flow #13. To defend the implementation, explain how room-bay centers determine door/window placement, how the local interior frame rotates on long footprints, and why facade screens/projections avoid gallery walkways. The place remains unsaved and unpublished.

## 2026-11-01 — Solid school facades and stronger roof silhouettes

After the user rejected another glass-heavy, repeated result, AI assistance changed `FacadeGenerator.luau` so long facades use more, narrower punched panes (spacing target 24 studs; maximum 16 bays; pane width capped at 9.2 studs) without a continuous frame band or continuous sill. The intent is to leave visible opaque wall between windows. The static school-gallery door leaf now fills 78% of its clear opening; gallery width has a 7.2-stud minimum. `BuildingMassingGenerator.luau` adds separated roof pavilions, three-sided courtyard masses, a cantilevered lecture volume, split/twin wings and an L-shaped roof mass; redundant sawtooth roofs were removed from the low market and service forms. These additions are non-colliding visual geometry, so existing walkable floors, rooms and paths stay as generated.

Local `rojo build` succeeded and the existing detached root refreshed in Studio Edit. Structural audit: 28,137 BaseParts, 16,907 collidable, 640 gallery doors, 137 gallery deck/landing parts, 700 classroom Models and 851 total room/lobby Models. The root reports all parts anchored, zero scripts, 23 buildings and the original 16 markers. Studio screen capture remains blank, so students must compare building silhouettes from a common player-height viewpoint, verify corridor and stair traversal, and report which IDs still resemble one another. Visual approval and Iris Xe performance remain unverified; no place save, publication, Play test, asset import or image upload occurred.

## 2026-11-01 — provisional pixel-to-studs campus preview (AC-01/AC-11; offline only)

AI assistance added an offline pipeline for the user's newer, uncalibrated pixel geometry. The canonical `CampusPixelGeometry.json` and supporting centers CSV/vector-only SVG were copied locally without editing their source geometry. `tools/Generate-CampusPixelPreview.py` transforms pixel `(x,y)` to local `(x * previewStudsPerPixel, (imageHeightPx - y) * previewStudsPerPixel)`, defaults to 1.0 stud/pixel, keeps `metersPerPixel` null and does not borrow v6/v7 positions. The generated manifest keeps original pixel rings beside transformed coordinates, preserves the 16 old gameplay marker IDs without positions, and stores the three pixel entrances separately. `BuildingIDMapping.md` retains exact ID matches and documents unresolved IDs and the B1/B4/Canteen ambiguities.

`PolygonFootprintGenerator.luau` and `CampusBuilder.luau` create a detached `FNABK_Campus_PixelPreview_v1` made of polygon-edge Part ribbons, separate Models, a non-collidable canvas backing, and three entrance markers. The preview leaves polygon interiors empty; B1 remains a U-shaped outline with an open courtyard. During the initial offline milestone the builder was not yet executed in Studio. That initial geometry report found a B8/B9 overlap candidate and Entrance1 outside the source boundary; the later user-directed overlay below corrects those preview positions while keeping canonical source JSON unchanged. The 1.0-scale output is estimated at 270 BaseParts. The source is AI-generated and unverified; this is not a real-world measured or north-aligned map. Students should explain the y-axis inversion, polygon edge decomposition, ID reconciliation, and why this detached preview cannot alter gameplay. No asset upload or publication occurred.

## 2026-11-01 — user-directed pixel preview corrections

The user requested a small gap and parallel alignment between B8/B9, a slight rightward shift for Entrance1, and confirmed that B4 and Canteen are distinct neighboring buildings. AI assistance implemented these only in `GeometryAdjustments.json`; the canonical pixel JSON, source CSV and supplied SVG remain unchanged. B9's effective preview ring is spaced approximately six source pixels from B8 and aligned to its long-edge angle. Entrance1 shifts +12 source pixels along X. Canteen retains its source `area` category in provenance but is rendered as a separate `building` in the preview. The generator refuses to apply an overlay if its expected source values no longer match, records both source and effective geometry, and validates the requested spacing, angle, category, adjacency and entrance shift. The students should explain the difference between canonical source geometry and the user-approved preview adjustment overlay.

## 2026-11-01 — detached pixel preview created in Studio Edit

After the user separately authorized the scene operation, AI assistance used the Rojo-synced `CampusBuilder` in local Studio Edit for `FNABK-AC06-A3-20261028-v2.rbxlx`. It created only `Workspace.FNABK_Campus_PixelPreview_v1` at the documented detached offset `(1200, 0, 1200)`. MCP's DataModel audit found 57 feature Models, 23 building Models, three entrance Models and 270 BaseParts; all parts were anchored with collision, touch and query disabled, and the root contained no scripts. The audit found B8/B9 long-edge direction dot product 1, Entrance1 pixel X 178 and separate B4/Canteen Models. The Studio screenshot endpoint returned a blank viewport, so direct visual review remains pending in flow #14 of `MANUAL_CONFIRMATION.md`. No gameplay source or existing model was edited by the builder; the place was not saved or published and no asset was uploaded.

## 2026-11-01 — Phase C buildings ported to detached pixel layout

At the user's request, AI assistance added `PixelBuildingPorter.luau` and CR-010. The module copies the detailed building models from detached Phase C v6 to a new root aligned to the pixel outline, fits their horizontal geometry to the pixel footprints, and retains their vertical/floor content. It uses 17 same-ID sources and six visual templates for separate new identities. It decomposes B1's U-shaped pixel ring into three wing models under one B1 parent. The Edit-mode output contains 23 logical building IDs and 29,851 BaseParts; Studio reports zero unanchored parts and scripts. A corrected structural footprint audit found no overlaps between separate building identities and measured an approximately 6.07-stud B8/B9 gap. The old v6 root, outline preview, gameplay IDs, gameplay scripts and runtime map are preserved. The team should explain the non-uniform transform, the B1 wing decomposition and the difference between a model template and an identity mapping, then complete flow #15. Pixel scale and building footprints remain provisional; room/stair traversal, visual acceptance and target-device performance require review. The local place is not saved or published; no asset upload or cloud generation is involved.

## 2026-11-01 — Detached pixel map mirrored left-to-right

The user reported that the detached pixel map appeared reversed and asked to swap its left and right sides. AI assistance changed the generated preview transform to `xStuds = (imageWidthPx - pixelX) * previewStudsPerPixel`, leaving canonical `CampusPixelGeometry.json` vertices and the source vector map unchanged. The generated preview SVG, pixel outline, entrances and building footprints all use the same horizontal reflection about the source-image center. `PixelMapMirror.luau` reflected the two already-open detached Studio roots in Edit mode around world X=1924: 270 outline parts and 29,851 building parts. Studio reports the mirror flag on both roots; the v6 source remains unchanged. The module preflights anchored native geometry and refuses unsupported mesh/union geometry, dynamic parts, scripts, joints or repeat use. The team should explain how reflecting CFrames preserves native block geometry, why the local X axis now points to image left, and how the source pixel vertices remain canonical. The v6 source and playable A01 map are out of scope. Manual orientation and readable-nameboard review remains flow #16; do not claim visual acceptance, traversal, or performance until reviewed. No asset upload, save, publication, or cloud generation occurred.

## 2026-11-01 — B1 U-shaped wing connection

AI assistance corrected the detached B1 port after the user reported that its three sides did not join. The source generator compares each wing fitted bounds with its target rectangle and rotates the geometry if its X/Z axes were swapped. It finds the crossbar shared edge with both side wings and overlaps it 2.25 studs toward them to close the source floor setback while leaving the central courtyard open. In Studio Edit, the existing B1_NorthLink geometry was corrected in place with BasePart CFrame transforms; five floor levels at each seam were structurally inspected. The student team should explain why the AABB axis check is needed, how shared-edge direction is derived from the rectangles, and why this is a provisional geometry fit. Story counts remain estimates until confirmed by the user. The detached preview was not saved or published; gameplay code, runtime map, v6 source, and reference assets were not changed or uploaded.

## 2026-11-01 — Fresh-manifest pixel port, confirmed floors, and workshop forms

AI assistance traced a remaining B1 placement error to Studio's cached `require` result: Rojo had synchronized the mirrored `CampusPreviewManifest` source, but the v2 build still consumed its older pre-mirror table. The source porter now accepts an explicit manifest snapshot and refuses to build if its mirror state or scale conflicts with the existing outline. In Edit mode it created the separate `FNABK_Campus_PixelBuildings_PhaseC_v3` root from a fresh cloned manifest ModuleScript, preserving v1, v2, the v6 source, the outline, and the runtime map. Studio's structural audit measured each B1 wing from transformed BasePart corners and confirmed the crossbar and side-wing seams match the polygon; six collidable floor connectors cover both joins across the user's three confirmed floors, and the courtyard remains unoccupied. The 23 model story-count attributes match the user table. AI assistance also added native-Part workshop forms for C1/C2/C3; C1's upper level is a partial service deck with stairs. Students should explain the ModuleScript cache issue, explicit manifest dependency, polygon decomposition, seam floors, and why pixel/story geometry remains provisional. The screenshot endpoint returned a blank viewport, so visual review and traversal remain pending in flows #17–#18. The place was not saved or published; no gameplay code, runtime map, assets, or cloud generation were changed.

## Campus follow-up

AI assisted with the Canteen opening, room-label matching, A3/B2 door-width repair and sampled hinge clearance pass documented in `campus-pixel-preview/park-library-and-canteen.md`. The student team should review the retained backups, hinge transform, sampling limitations and manual test results.

AI assisted with the seven duplicate main-entry leaf removals, 53 sampled short door swings and 20 workshop roll-up shutters. The former leaves and server script are retained locally. See the campus preview follow-up for incomplete checks and manual tests.

The remaining 15 obstructed gallery doors use a simple sideways compression within the doorway, with prior poses retained. The team should explain and visually assess the approximation before accepting it as a finished folding-door model.

AI assisted with boundary-shaped provisional ground, gate landings, B12 door-height and corridor-runner fixes, facade height correction, stair headroom and three added flights. The student team should review the retained original attributes, simple thin-tread representation, tested samples and remaining manual traversal and performance checks in the campus preview notes.

AI assisted with a tested Canteen stair replacement and a set of controlled first-flight traversal samples. The replacement and preserved original geometry, limitations and manual checks are recorded in the campus preview notes.

AI added a small native planting and bench pass in narrow grass regions, with polygon and collision sampling and one natural Seat approach test. The reference image remained local.

AI assisted with C1's guarded upper bridge, four numbered workshop rooms, furniture and server-controlled door configuration. Original partitions are retained, and students should review the hinge transform and recorded sample-versus-full-route test limitations.

AI assisted with a bounded native classroom-furniture pass. One additional desk and bench were placed per modeled classroom after floor, wall, doorway and overlap sampling; placement and traversal limitations are in the campus preview notes.

AI assisted with a local geometry plan review and a reversible Canteen seat/furniture correction after detecting unsupported upper-floor furniture. Sampled support, collision and Play-seat checks are documented in the campus preview notes.

AI assisted with A2 reading-table details and replacing compressed chair blocks with native seats. The team should review the retained originals, floor-support sampling and the single natural-seat Play test described in the campus preview notes.

AI added a sampled support audit for B1 desks and chairs and C1–C3 machine bases. The checks are geometric samples and do not replace the documented manual walkthrough or visual review.

AI darkened the raised ID and A2 library letter strokes after sampled pale backgrounds indicated poor contrast. Original colors are retained on each changed part. The sample, its limits and remaining visual checks are documented in the campus preview notes.

AI added secondary native raised Canteen lettering after ray samples found the original entrance sign faced a nearby wall. The student team should review the physical wall placement, sampled sightlines and limitations of the local reconstruction in the campus preview notes.

AI proportionally fitted the secondary Canteen lettering to the available rear viewing distance and stored prior transforms and sizes. A grounded eye-height ray sample and its limits are documented in the campus preview notes.

AI widened the compressed Canteen upper gallery and moved its guards after detecting seven outer door approaches without floor at the sampled points. AI also moved eight B6 desk-and-bench pairs that intersected sampled hinge swings. Original transforms are retained; controlled Play and geometric checks, limitations and manual tests are in the campus preview notes.

AI replaced direct CFrame interpolation with pivot-based motion on 655 doors while preserving endpoints. For 70 B1 doors, the pivot is derived by solving the two-dimensional system `(I - R)h = t`; the team should explain the transform, review sampled collision limits and perform the manual door tests in the campus preview notes.

AI added 16 small native trees with varied crowns to the large perimeter lawn. Candidate sampling, one bench Play test and remaining visual and performance checks are documented in the campus preview notes.

AI corrected a stale B1 corridor check that sampled a classroom divider and verified a continuous wing-to-wing humanoid route on each of three floors. The start repositioning and remaining manual inspection are documented in the campus preview notes.

AI sampled standing areas at 19 workshop machines, tested one approach each in C2 and C3, and added a static native Canteen serving counter. The team should review the recorded incomplete long-route test, collision sampling and manual checks in the campus preview notes.

AI sampled the central Canteen aisle after a prior path triggered a dining Seat, and ran a controlled doorway-to-counter route without sitting. Controlled crossings of the other two school gates were also tested; the team should review the route and gate test limitations in the campus preview notes.

AI added visible native vertical pickets to the existing perimeter spans without changing their collision barriers. The team should inspect the three-per-span simplification, gate crossings and the performance impact of 885 added parts as documented in the campus preview notes.

AI added checks for distinct named walkable-floor elevations and boundary interval continuity. The student team should understand the grouping tolerance, the distinction between intentional gate intervals and fence spans, and the limits of sampled geometry checks.

AI corrected room signs found embedded in wall headers or a roof curb. It exposed existing physical plate faces without enabling `AlwaysOnTop`, retained original sizes or frames, and recorded the ray-sampling and visual-review limitations in the campus preview notes.

AI added seven canopy-edge entrance-direction labels after player-height ray samples identified occlusion by canopies. The team should inspect their legibility, distinguish them from building IDs and review the sampling limits in the campus preview notes.

AI added a central-side C6 main entrance after inspecting a locally plotted bounds-and-direction diagnostic. The old entrance and original wall are retained. Controlled door and traversal tests, remaining visual review and diagnostic limitations are recorded in the campus preview notes.

AI added larger native trees, grass tufts and shallow wedge-based lawn relief after the user requested more natural grass areas. The team should review the polygon and collision sampling, the mound walking test, the additive-relief simplification and the remaining visual and performance checks in the campus preview notes.

- 2026-11-02: Codex assisted with native primitive tree placement and refinement for the detached campus preview (AC-01/AC-11), and ran structural Studio checks and a Rojo build. The team must review visual quality, traversal and performance and save the intended place; see campus-pixel-preview/park-library-and-canteen.md.
- 2026-11-02: Codex assisted with native tree height/crown variation and grass placement in the detached campus preview, with Studio geometry checks (AC-01/AC-11). Human review of appearance, traversal and performance is pending.
- 2026-11-02: Codex generated the campus preview asphalt overlay locally from traced polygons and assisted with Studio structural checks (AC-01/AC-11). The team must review layout, appearance and performance and confirm the use of reserved areas.
- 2026-11-02: Codex assisted with native geometry for nine reserved campus areas, and performed sampled Studio checks and a Rojo build (AC-01/AC-11). The team must review layout, appearance, traversal and performance; the sports props do not implement gameplay.
- 2026-11-02: Codex hid the detached preview plot outlines while retaining reversible transparency attributes (AC-01/AC-11). Studio visual review remains pending.
- 2026-11-02: Codex assisted with native park ecosystem geometry and sampled Studio placement and clearance checks (AC-01/AC-11). The team must review appearance, natural traversal and performance.
- 2026-11-02: Codex assisted with the native campus gate architecture revision, preserving hidden original parts and labels, and ran sampled Studio geometry checks (AC-01/AC-11). One automated humanoid crossing attempt did not reach its target; human visual and traversal review remains necessary.
- 2026-11-02: Codex assisted in brainstorming and drafting the proposed multi-day survival GDD and CR-014. Student-team review of mechanics, scope and baseline adoption remains pending; no gameplay was implemented or tested.
- 2026-11-04: Codex added R6/R15 movement, baton and hit-reaction presentation, R6 downed/revive/interaction, and R15 elimination presentation using user-supplied IDs (SURV-06/08). Server state still owns movement, damage and outcomes. One R15 Studio client played the run, crouch-walk, first baton and elimination tracks with nonzero lengths; elimination was frozen at its last pose. Rojo build passed. R6 actions, visual quality, other transitions and multiplayer replication need testing. Firearm animation integration awaits firearm gameplay.
- 2026-11-04: Codex connected the user-published R15 downed, revive, repair and interact IDs to the existing player presentation (SURV-08). Studio checked that the R15 downed track loads, freezes at its final pose, and stops when its state clears; the other four published IDs loaded on a temporary R15 rig. Co-op revive, interaction prompts, visual quality and replication still need manual testing. The R15 stun ID is not connected because the prototype has no player stun state; the existing Mimic stun is server-owned and uses a non-animated preview.
- 2026-11-04: Codex archived old campus and animation preview models in Studio ServerStorage and placed the A01 gameplay anchors on the user-selected campus v6 (SURV-06/08). In Studio, one player spawned at the new gate; a server-simulated crate placement activated A3; a radius-1 path probe from spawn to B4 succeeded; and the Mimic entered Chase and attacked a nearby test player. The A3 test used a scripted placement, not a natural pickup. Full routes, all missions, multiplayer and performance remain unverified; Studio place changes require saving. The campus model is not in the Rojo source build.
- 2026-11-04: Codex added a low-detail city street outside Gate 1 using native anchored Parts (SURV-12). An edit-mode structural check confirmed twelve buildings, two sidewalks and a continuous road at sampled points. Visual review, natural traversal and performance remain untested; save the Studio place to retain the scene.
- 2026-11-04: At the user's correction, Codex archived the Gate 1-only street and added a perimeter street with simple buildings on all four sides of campus, plus approaches to three gates (SURV-12). Structural checks found no bounding-box overlaps between the new houses and campus buildings; radius-1 Studio path probes succeeded along the three approaches and around all four road corners. Natural traversal, visual quality and performance remain unverified; save the Studio place to retain the scene.
- 2026-11-04: Codex expanded the exterior city with additional streets, an underlay and 104 varied low-poly buildings distributed around the campus and in exterior gaps (SURV-12). A Studio structural check passed for coverage and clearance; radius-1 probes passed along eight connectors and from the campus spawn to B4. The underlay is non-colliding to avoid changing campus gameplay; visual review, natural traversal and performance remain unverified. The earlier expansion draft is retained in ServerStorage; save the place to keep the scene.
- 2026-11-04: Codex rebuilt Gate 1 as native geometry inspired by the user's photograph, including the blue monument, text signs, flags and guardhouse (SURV-12). The previous Gate 1 portal is retained in ServerStorage; Gate 2 and Gate 3 were not changed. An edit-mode clearance check passed, and a radius-1 path crossed the gate after the prototype door was opened in a controlled Studio test. Visual review, normal play and performance remain unverified; save the place to retain the change.
- 2026-11-04: Codex stored 37 user-provided asset packages and 16 StarterPack Tools in separate Studio ServerStorage libraries, then placed script-free visual copies of selected food, water, medical, laboratory, weapon, light and vending assets in campus v6 (SURV-12). Originals, including imported scripts, remain intact; the new props are visual-only. Structural checks passed; a Play Test spawned successfully and a radius-1 path from spawn to B4 remained available. Imported sound IDs emitted missing/unauthorized/archived warnings; visual review, gameplay integration, multiplayer and performance remain unverified. The libraries and campus are part of the Studio place and must be saved separately from Rojo.
- 2026-11-04: Codex connected the placed B4 medical kit to the existing server-validated medkit pickup and healing service (SURV-05). A single-player Studio test picked it up and healed 50 to 90 HP, consuming the held medkit. The source uses the existing range and line-of-sight checks; full inventory, rejection, multiplayer and the eight-slot survival system remain unverified or unimplemented. The student team should review the service and run tests/CuratedMedkit.check.luau in a client Play session.
- 2026-11-04: Codex connected the user's archived Police Baton geometry to the existing server-granted baton, without importing its scripts or sounds (SURV-08). A single-player Studio test confirmed four parts, dealt 25 damage to a nearby test target, and left a target 40 studs away undamaged. Students should check the grip, R6/R15 animations, gameplay and multiplayer; test setup and expected results are in tests/UserBaton.check.luau and docs/ARCHITECTURE.md. Full survival combat remains incomplete.
- 2026-11-04: At the user's request, Codex replaced that baton appearance with the archived StunStick geometry, extended server range to seven studs, hid the misleading cooldown message, selected blocky avatar body proportions, and retained the Mimic preview Humanoid for classic clothing (SURV-06/08; CR-015). Studio tests confirmed six-stud damage, eight-stud rejection, sanitized baton parts and standard R15 body IDs. Visual appearance, R6, multiplayer and asset loading need human review.
- 2026-11-04: Codex added server-side forward-arc fallback targeting when a baton click does not aim directly at an NPC (SURV-08; CR-015). A controlled Studio test checked a target ahead, behind, beyond range and behind a wall. Students should review the selection rule and run tests/BatonAim.check.luau against the live Mimic; multiplayer remains untested.
- 2026-11-04: Codex separated walk and sprint presentation by playing the user-supplied walk track at Action priority while walking, overriding Roblox's default walk/run blend (SURV-05). A Studio R15 client test observed the walk track at normal speed and the run track while sprinting; students should visually review transitions and test R6 and multiplayer replication.
- 2026-11-08: Codex drafted the survival implementation sequence and a server-only inventory value object with an assert-based Studio check (SURV-05/08). Stacks retain individual item IDs and ammunition rounds. The assertions passed using the same source inside an isolated Studio Edit function, and a Rojo build succeeded. The synced module and Play session were not tested. The student team should review the limits and test cases; this value object is not yet integrated with pickups, user interface, saving or global item ownership.
- 2026-11-08: Codex created the master checklist and five survival sub-plans and connected the prototype medkit to the server inventory (SURV-05). After adding assertions before implementation, the extended inventory check passed in isolated Studio Edit. One Studio Play client collected two medkits, healed 50 to 90 with one, and kept the other at full health. Full inventory, concurrency, reconnect and save behavior remain untested or unimplemented; the temporary inventory is discarded on disconnect. Student review and the manual steps in plans/01-inventory-needs.md remain necessary.
- 2026-11-08: Codex added a read-only eight-slot UI and per-player server inventory summaries with rate-limited sync (SURV-05). A summary assertion failed before implementation and passed in an isolated Studio server context. Studio Play showed eight slots, one acquired medkit and working Inventory-button open/close; Rojo build succeeded. Automated Tab injection did not open the UI despite a high-priority binding. Real keyboard, two-player privacy and adversarial networking remain untested; reconnect persistence is not implemented.
- 2026-11-08: Codex changed inventory input to B, added server-authoritative food/water needs and connected four placed supply props (SURV-05). Deterministic Needs assertions and Rojo build passed. Single-client Studio tests confirmed B toggle, decay, collecting canned food/water, consumption capped at 100, and invalid consume types ignored. One apple prompt failed to activate in a controlled attempt. Live deprivation, clicking slots, co-op, save/reconnect, respawn and helicopter immunity remain unverified or unimplemented; the team should follow plans/01-inventory-needs.md.
- 2026-11-08: Codex retested the apple from both sides of a canteen wall: the server blocked the outside attempt and allowed pickup from inside. Single-client Studio mouse tests consumed food and water from their inventory slots. Codex added per-user in-memory session supplies and tested the value object and Play server module (SURV-05/10). Actual reconnect, downed changes, multiple clients and saved-world persistence remain untested or incomplete; Rojo build passed.
- 2026-11-08: Codex added text-based low-food and low-water warnings at a provisional 20-point threshold (SURV-05). Studio client checks using local test attributes confirmed each label, and a controlled server Play check passed zero-needs damage through Needs and PlayerLifeService: 50 to 49 HP after five simulated seconds, unchanged with a ForceField. Heartbeat-driven starvation, helicopter immunity, downed/revive and multiplayer remain untested.
- 2026-11-08: Codex implemented a deterministic survival schedule and assert-based checks (SURV-01/02/11), including five day/night durations, grace-wave events, signal timing and rescue/boarding timers. Assertions passed in the Studio Play server and Rojo build succeeded. The module is not yet connected to the active A01 round; live enemies, event consumers, pause, persistence and multiplayer are not validated. Students should inspect the transition logic and run tests/SurvivalClock.check.luau.
- 2026-11-08: Codex added server inventory transfer as a non-yielding operation (SURV-05/08), tested in Studio Play with a partially used ammo box and rejection when the target inventory is full or the same inventory. No player-facing transfer, world ownership ledger, dropped bag or multiplayer race test is implemented.
- 2026-11-08: Codex connected inventory sharing to the nearest nearby visible teammate with server validation (SURV-05). One-client Studio Play tested the Give Item UI, no-teammate rejection and malformed requests while retaining the item. Two-client success and adversarial/race cases are untested; the student team should review the code and run the sharing scenarios in plans/01-inventory-needs.md.
- 2026-11-08: Codex extended the deterministic survival clock with normal night wave warnings, starts and the selected 1–4-player scaling/caps (SURV-02). Assertions passed in a Studio Play server and Rojo build succeeded. Evenly spaced start times and 30-second warnings are provisional; live enemy spawning, retreat, UI/audio warnings and multiplayer remain unimplemented or untested. The student team should review and playtest these timing choices.
- 2026-11-08: Codex added server-validated preliminary solo base selection at 23 generated floor-center points (SURV-03/04). Studio Play selected B4 and A2, and a B4 assertion passed. Points need entrance placement and route review; co-op selection is disabled pending host confirmation. Respawns, storage, upgrades and persistence remain incomplete. The student team should run tests/BaseClaim.check.luau and test every building.
- 2026-11-08: Codex added a timed co-op base proposal and server-validated host confirmation (SURV-03/04). Studio Play passed isolated assertions for timing, actor and stale IDs plus a solo B4 regression. Host assignment is not yet implemented: HostUserId defaults to zero, preventing co-op confirmation until a future host lobby sets it. The actual co-op announcement, disconnect, permission and route cases require multiplayer testing and student review.
- 2026-11-08: Codex enabled a Studio-only first-test-player host assignment for co-op base testing and added HostIdentity assertions (SURV-03/10). Studio Play confirmed the test host; production remains fail-closed until a server-owned lobby provisions the world host. Two-client announcements, confirmation and disconnect remain unverified; see plans/03-time-base-waves.md.
- 2026-11-08: Codex corrected a base-selection authorization bug: one remaining player may use the solo shortcut only if they are the established host (SURV-03/10). A failing assertion preceded the fix; Studio Play rejected a deliberately mismatched host and accepted the restored test host. This does not implement or test the actual host disconnect pause/save flow.
- 2026-11-08: Codex added server-owned snapshot revisions to prevent stale inventory sharing from transferring an unintended item (SURV-05). Single-client Studio Play rejected a stale revision without losing the medkit and confirmed normal no-teammate feedback; Rojo build passed. Actual co-op concurrency, successful sharing and recipient-capacity tests remain open.
- 2026-11-08: Codex implemented and tested deterministic daily supply allocation (SURV-05) with selected party quotas, scarcity priority, rotating ammunition and the base-share limit. Studio Play server assertions and a Rojo build passed. The algorithm only plans against aggregate capacity and is not yet connected to selected world points, individual stock caps, item spawning, the day clock or persistence. Students should review tests/DailySupply.check.luau and test those integrations.
- 2026-11-08: Codex extended daily allocation with point-specific stock checks and non-mutating distribution under the 10-item cap (SURV-05). Studio Play assertions covered existing stock, invalid or duplicate points and the base share; Rojo build passed. No world item spawning, random point selection, daily idempotency or save integration exists yet.
- 2026-11-08: Codex added an in-memory stock snapshot and processed-day result for daily supplies (SURV-05/10). Studio Play assertions confirmed old stock remains, repeated/older days return no allocation and a full day still advances; Rojo build passed. World items, unique identities, durable atomic saves and integration remain unimplemented. Students should review the representation and test it with the actual persistence and world systems.
- 2026-11-08: Codex replaced Roblox default character health regeneration to prevent it cancelling hunger/thirst damage (SURV-05). Studio Play observed 50 HP remain unchanged for six seconds and the existing medkit restore 90 HP; Rojo build passed. The student team should run tests/HealthRegeneration.check.luau and test prolonged live starvation, co-op and recovery behavior.
- 2026-11-08: Codex added server-validated baton targeting for teammates and routes the selected 5 HP through the existing life service (SURV-08). Studio single-player regression tested NPC damage, self-target rejection and round-end rejection; Rojo build passed. Actual friendly hits, downing, line of sight, force fields, co-op and the GDD recovery flow remain untested or incomplete; the team should run tests/BatonFriendlyFire.check.luau and review target validation.
- 2026-11-08: Codex added a standalone server firearm state module and assert-based tests for ammunition, reload and fire timing, box identity, shotgun interruption and falloff (SURV-08). Studio Play assertions and Rojo build passed. It is not connected to actual guns or gameplay; the student team should review the logic and implement/test ownership, hit validation, inventory, audio and persistence.
- 2026-11-08: Codex corrected the firearm value module to account for completed shotgun shell intervals after a delayed server update and added reload cancellation (SURV-08). A pre-change assertion failed and Studio Play assertions plus a Rojo build passed after the change. This does not implement or test equipped weapons; the team should review the timing code and complete live integration.
- 2026-11-08: Codex added temporary native pistol/shotgun/rifle ammunition pickups to the existing server inventory (SURV-05/08). A Studio Play client picked up a pistol box and saw it in inventory; Rojo build passed. Pistol rounds are assigned server-side; actual reload, other pickups, multiplayer and supply integration remain untested. The team should run tests/AmmoPickup.check.luau and review placement.
- 2026-11-08: Codex connected a temporary sanitized Handgun-geometry pistol to the server firearm and inventory logic (SURV-08). Studio Play picked up pistol/ammo, loaded 12, shot a controlled target from 75 to 50 HP, and saw one of two simultaneous fire requests consume a round; malformed direction was ignored. Rojo build passed. Gunshot noise, sound, innocent-NPC handling, co-op, persistence, death/drop and shotgun/rifle remain incomplete or untested. Students should review the source and run the pistol scenarios in plans/02-life-combat.md.
- 2026-11-08: Codex connected server-side pistol hearing to the prototype Mimic and added a 10-point Trust penalty for an innocent student hit, correcting the baton prototype penalty from 20 to the GDD's 10 (SURV-07/08/13). Studio Play observed one test student hit reduce Trust 100→90 and a Mimic 40 studs away hear the shot through a wall. Exact boundary, NPC health/recovery, co-op, other enemies and sound playback remain untested or unimplemented; students should review and run tests/PistolHearing.check.luau.
- 2026-11-02: Codex consolidated the proposed survival direction into GDD_SURVIVAL_COMPLETE.md, consulted the three user-provided GDD references, and proposed numeric balance and test plans. All assumptions, team roles, scope, art concepts and test results require student review; no new gameplay was implemented or tested.
- 2026-11-02: At the user's request, Codex made the five-day survival GDD the current repository design, archived the earlier A01 GDD and acceptance evidence, updated documentation and CI traceability, and ran repository checks and a Rojo build. No new survival gameplay or Roblox playtest was performed. Student-team and course review remain pending.
# Survivor health slice

AI assisted with the server-owned survivor health module, its combat integration and the isolated check. The student team should review the 25-HP provisional damage, anchored-model fall pose and the delayed recovery callback. SURV-13 is incomplete: session pause/save, self-defense, survivor activities and multiplayer scenarios require implementation or validation.

AI assisted with the 30-second revive setting and server-side hold interruption. The team should review the distinction between attack and deprivation damage and the 0.1-second range sampling; co-op tests are still required.

AI assisted with the provisional rifle pickup, automatic input and server firearm integration. Review the sanitized M16A4 handle, server fire cadence and ammunition ownership; full gameplay and multiplayer testing remain outstanding.

AI assisted with the shotgun's six raycasts, per-target aggregation and interruptible shell reload. Review the provisional spread and reload generation counter; live and co-op tests remain outstanding.

AI assisted with connecting the five-day schedule to the running server and HUD while disabling the A01 gate ending. The team should review clock events and reconnect/resume behavior once waves and rescue are integrated.

AI assisted with mapping the server day/night schedule to Lighting.ClockTime. The team should review outdoor and indoor readability throughout each phase and test pause/resume once implemented.

AI assisted with provisional rescue station assignment, server prompts and the temporary M-key map. The team must verify building suitability and reachability, replace placeholder station tasks, review the map and test the full signal and rescue path.

AI assisted with provisional position-based boarding and group results. The team must replace the landing pad, review server damage immunity, and test timeout, co-op, disconnect and early-vote behavior.

AI assisted with early-departure warning and server-side voting. The team must review roster and deadline races and run the listed multiplayer and reconnect tests.

AI assisted with a provisional wave event consumer and simple block attackers. The team must replace placeholder movement and enemy appearance, complete capped scheduling and retreat, and validate multi-client damage, base accessibility and performance.

AI assisted with cloning existing creature visuals and a fallback pathfinding attempt. The team must review these models' licenses and appearance, inspect their movement and animations, and profile and validate navigation and combat under load.

AI assisted with provisional saturated-wave retirement and gunshot investigation. Review the selected 20-second interval and target priority; test overlapping waves, actual navigation and multiplayer.

AI assisted with provisional respawn, needs reset and inventory recovery bags. The team must review item ownership, weapon drops, five-second immunity, co-op and disconnect behavior, and execute the documented tests.

AI assisted with transferring firearm tools and loaded ammunition into recovery bags. The team must test reload interruption and single ownership during retrieval, disconnect and save/resume.

AI assisted with connecting day events and provisional world supply points. The team must review point suitability and implement durable processed-day and world item ownership, then test the listed multiplayer and recovery cases.

AI assisted with the provisional free survivor help interaction and daily Trust deduplication. The team must replace the abstract hold with a visible task and verify server validation, co-op and save/resume.

AI assisted with native debris placeholders and repeated server validation during the hold. The team should review placement and execute actual co-op and save/resume checks.

AI assisted with provisional survivor self-defense and disengage timing. The team should review retaliation balance, multi-attacker handling and line of sight, and execute the documented real-hit tests.

AI assisted with a provisional survivor scrap-for-water exchange and Trust-tier calculation. The team must review the exchange balance and test transaction atomicity, multiplayer and persistence.

AI assisted with explicit survival-clock boundary detection and fractional-step regression checks. The team should review event ordering and validate the full real-time loop.

AI assisted with provisional per-building storage and revision-checked transfers. The team must verify ownership, simultaneous access, physical relocation and save/resume before relying on it.

AI assisted with in-memory life-state records for same-server reconnects. The team must implement and validate offline downed/revive handling, weapon ownership, host pause and durable saving before claiming SURV-10.

AI assisted with temporary same-server firearm retention. The team must test disconnect while equipped/reloading, rejoin ownership and ammunition, and implement durable saves.

AI assisted with separate recovery-bag item and weapon controls and the inventory snapshot step. The team must verify actual bag transfers and failure cases in multiplayer.

# Departure boundary

AI assisted with rechecking boarding membership at departure and synchronizing early departure with the clock. The team must verify concurrent voting, deadline and multiplayer cases.

# Wave composition

AI assisted with grace-wave composition and reuse of gallery visuals. The team must implement distinct enemy behaviors and verify model appearance, complete spawn counts, co-op and performance.

AI assisted with shared server-side enemy health for melee and firearms. The team must verify real combat against each enemy type and explain the separate health/state attributes.

AI assisted with retreat state handling and the temporary dissolve in CR-016. The team must replace it with physical withdrawal and verify visibility-dependent recovery.

AI assisted with routing grace-wave cancellation into the player notice. The team must verify the actual signal interaction and multiplayer delivery.

AI assisted with provisional straight-line wave withdrawal. The team must implement obstacle navigation and visibility-aware recovery and verify real map routes.

AI assisted with a bounded pathfinding attempt for withdrawal. The team must explain waypoint handling and test real map paths and visibility-aware recovery.

AI assisted with the no-overlap grace-wave transition and its temporary straggler effect. The team must verify real timing, player visibility and multiplayer presentation.

AI assisted with separating rescue station input from nearby E prompts. The team must check natural access, control discoverability and multiplayer.

AI assisted with the bandage inventory transaction. The team must connect and test collection, crafting and timed use before treating the recipe as implemented.

AI assisted with provisional cloth pickups and timed bandage use. The team must validate interruption, transfer, UI and multiplayer behavior.

AI assisted with the per-building storage upgrade and capacity handling. The team must verify full storage, stale and concurrent requests, layout and persistence.

AI assisted with provisional early Scrap placement. The team must review routes, prompt overlap and supply balance.

AI assisted with one-time per-session starter supplies. The team must verify actual reconnect, save/resume and multiplayer balance.

AI assisted with provisional early food and water pickups. The team must verify route accessibility, pickup interactions and supply balance.

AI assisted with gap-aware replenishment placement. The team must review slot tracking and verify natural daily progression and save/resume.

AI assisted with canceling firearm reloads when the selected ammo box is transferred. The team must test shotgun and multiplayer handoff cases.

AI assisted with the barricade state and resource checks. The team must connect marked entrances and wave attacks, and test escape routes and persistence.

AI assisted with invalidating bandage use on transfer, disconnect and respawn. The team must verify co-op and reconnect cases.

AI assisted with projecting rotated building bounds onto the objective map. The team must verify real marker positions and floor labels visually.

AI assisted with survival-specific inactivity hints replacing old A01 key instructions. The team must verify timing, context and accessibility in complete runs.

AI assisted with survivor rescue-information prompts. The team must check other objective states, accessibility and multiplayer.

AI assisted with a provisional eliminated-player spectator camera. The team must verify actual elimination and multiple-client camera behavior.

AI assisted with validating the host's life state at base confirmation. The team must test a pending proposal with a downed host and after revival in multiplayer.

AI assisted with survival objective HUD text and its replicated-state updates. The team must verify the full rescue flow, multiplayer and screen readability.

AI assisted with displaying individual rescue outcomes separately from the group result. The team must verify the actual multi-client departure and disconnected-player results.

AI assisted with the server-owned departure roster and provisional group results panel. The team must verify real co-op, disconnection, save/resume and presentation.

AI assisted with a controlled respawn immunity check. The team must verify expiry, actual combat, all attack types and co-op without the test service.

AI assisted with a shared Trust HUD indicator and boundary checks. The team must verify multiplayer updates, actual NPC interactions and screen readability.

AI assisted with additional shared starter supplies and in-memory per-participant deduplication. The team must verify join/rejoin, pickup placement and durable persistence.

AI assisted with stopping wave spawns and withdrawing attackers after a terminal round result. The team must verify actual rescue/defeat transitions and multiplayer.

AI assisted with a temporary wave-warning sound using a built-in Roblox sound already present in the place. The team must review sound quality, settings, timing and multiplayer.

AI assisted with the provisional one-time survivor food quest and its server-side checks. The team must verify real interactions, multiplayer and persistence.

AI assisted with selecting a recoverable bag item that fits available inventory space. The team must verify actual bag prompts and multiplayer races.

AI assisted with a controlled helicopter damage-protection check. The team must verify actual damage sources, timing at the boarding boundary and co-op.

AI assisted with refreshing boarding membership before damage validation. The team must verify real movement, attack sources and voting races in multiplayer.

AI assisted with a provisional native-part helicopter shell. The team must review its appearance, scale, boarding access and animation.

AI assisted with validating the player damage amount at the server life-service boundary. The team must test real attacks and multiplayer remote validation.

AI assisted with showing inventory action feedback while its panel is closed. The team must review timing, readability and real multiplayer interactions.

AI assisted with close-range blocked-target wave pursuit. The isolated pathfinding test failed to observe movement; the team must diagnose and verify the navigation change.

AI assisted with a Roblox pathfinding probe and temporary runtime instrumentation; results were inconsistent and the pursuit test remains unresolved.

AI assisted with stabilizing the close-range pursuit test using an anchored player and a prebuilt test floor. The team must verify complete routes and real campus navigation.

AI assisted with extending the pursuit test to require a clear route. Subsequent runs failed before reaching that assertion; navigation remains unresolved.

AI assisted with fixing a wave attack obstruction ray that could hit a protruding character limb before detecting a wall. The team must verify real campus geometry and multiplayer.

AI assisted with applying proposed wave enemy speed, damage and cooldown values. The team must validate timing, distinct behavior and balance through playtesting.

AI assisted with elapsed-time wave movement and a capped step after delays. The team must profile under load and validate the cap and actual enemy speeds.

AI assisted with a synthetic wave-hearing boundary check. The team must verify actual gunfire, investigation, non-wave enemies and multiplayer.

AI assisted with a rescue-map signal-ready marker and handling delayed objective attributes. The team must verify actual mission flow, map readability and multiplayer.

AI evaluated line-of-sight target selection for waves; a trial failed the path regression and was reverted. Wave sensing remains unfinished.

AI assisted with a local player marker on the provisional objective map. The team must review map orientation, edge indication and accessibility.

AI assisted with closing inventory/storage together and mutually exclusive give/deposit modes. The team must test real interactions, delayed responses and multiplayer.

AI assisted with distinguishing storage opens from updates to prevent a late update reopening a closed panel. The team must test real transfers, ordering and multiplayer.

AI assisted with sending storage updates to nearby eligible players. The team must verify real co-op synchronization, stale requests and storage privacy.

AI assisted with provisional per-building power points and transaction logic. The team must verify placement, actual interaction, lighting integration, multiplayer and persistence.

AI assisted with binding initially enabled building lights to the power flag. The team must review lighting, initially disabled fixtures, other scripts and persistence.

AI assisted with a recovery-bag fallback near the world destruction plane. The team must verify integrated recovery, reachable locations and multiplayer.

AI assisted with needs recovery boundary checks. The team must verify live heartbeat damage, actual consumption and co-op.

AI assisted with a limited clock snapshot codec and validation checks. The team must review the state reconstruction and implement wave restart and complete atomic world persistence before enabling saves.

AI assisted with validation of saved inventory containers and duplicate item IDs. The team must integrate all world and weapon owners and verify atomic save/recovery before enabling persistence.

AI assisted with additional quiet-night and rescue-countdown clock snapshot checks; the team must account for all active enemies and helicopter state before integrating them into saves.

AI assisted with wave sight checks and temporary pursuit of the last seen position. The team must review per-enemy behavior, pathfinding, performance and multiplayer.

AI assisted with server-side campus-door life-state checks; the team must verify actual downed and multiplayer interactions.

AI assisted with tracking cautious survivor trade quota on Trust tier transitions. The team must review the stock interpretation and test co-op, tier oscillation and persistence.

AI assisted with removing an ammunition box after its final round is loaded. The team must verify mixed stacks, interruptions, transfers and durable item ownership.

The empty-box removal above was reverted after rechecking SURV-08; AI assisted with restoring the retained empty-box behavior. The team must test inventory usability and persistence.

AI assisted with short-lived supply pickup race feedback. The team must test actual multiplayer requests and replace the temporary prompt lifetime with durable item-ID handling where needed.

AI assisted with provisional wave-machine sight and running detection. The team must test cone boundaries, running, cues, multiplayer and performance, and implement distinct search and patrol behavior.

AI assisted with the wave-machine detection warning and throttling. The team must review its sound, legibility, repeated alerts and co-op behavior.

AI assisted with a native machine sensor spotlight. The team must review its appearance, alignment, shadows and performance.

AI assisted with moving the sensor light forward after a controlled visual preview. The team must recheck the updated light on the actual campus.

AI assisted with excluding claimed supply pickups from point stock during the short race-notification window. The team must test natural day transitions and multiplayer.

AI assisted with retaining last observed player health as a disconnect fallback. The team must test actual disconnect timing, reconnect and offline downed states.

AI assisted with reevaluating the team-down condition when respawn counts change. The team must test the real co-op downed and respawn flow.

AI assisted with the provisional atomic session lease transition and fake-store tests. The team must review clock and lease failure semantics, validate complete snapshots and test real concurrent servers before enabling saves.

AI assisted with returning the committed snapshot from a lease transition. The team must validate its complete schema and test real storage outcomes before integrating it.

AI assisted with firearm snapshot validation and restoration. The team must integrate it with atomic weapon and ammunition ownership and test interrupted reloads across actual save and resume.

AI assisted with explicit empty ammunition-box disposal and revision validation. The team must test UI interactions, mixed boxes and multiplayer.

# Reload feedback

AI assisted with server-replicated reload status and a controlled Studio test (SURV-08). The server remains authoritative; the student team should review cancellation and repeat the manual tests in the life/combat plan.

AI assisted with invalidating old rifle input loops on a new press, release or focus loss; the student team should run the input regression in the life/combat plan.

AI assisted with the wave creature strike wind-up and its controlled server check. The student team should inspect the timing and verify its warning and counterplay in a natural encounter.

AI assisted with preserving the wave Mimic loop during UV stun and a controlled server regression. The student team should verify live UV, retreat and multiplayer races.

AI assisted with excluding incapacitated characters from wave targeting and a controlled attribute check. The student team should verify real damage and multiple targets.

AI assisted with feedback for failed storage transfers. The student team should verify full-inventory and full-storage interactions in Studio.

AI assisted with projecting Mimic path endpoints onto nearby floors. The student team should verify multi-floor routes and explain the projection and fallback.

AI assisted with vertical waypoint following for Mimic navigation. The student team should verify real campus routes and explain the fixed root-to-floor offset.

AI assisted with changing Mimic attack distance to three dimensions and using half the root height as waypoint clearance. The student team should verify other routes and geometry.

AI assisted with enabling the existing sanitized gallery disguise outside Studio and disabling its Humanoid state machine. The student team should review visuals, asset permissions and behavior before release.

AI assisted with a temporary head-movement clue for the disguised Mimic. The student team should review the visual timing, fairness and performance before release.

AI assisted with server-validated Power objective hold timing. The student team should verify interruption, concurrent users and natural access.

AI assisted with native placeholder geometry for rescue station identification. The student team should review appearance and accessibility in the campus.

AI assisted with private-server host identity selection and isolated checks. The student team should verify it in a real private server and finish trusted lobby and persistence integration.

AI assisted with the temporary no-base wave fallback (CR-017). The student team should review placement, safety and balance in real play.

AI assisted with sampling clear ground for wave spawns. The student team should validate navigation, fallback behavior and performance at every base.

AI assisted with avoiding nearby characters and wave enemies during spawn sampling. The student team should test dense waves and fallback behavior.

AI assisted with additional wave spawn sampling radii and a controlled obstruction check. The student team should validate performance and inaccessible geometry in actual sessions.

AI assisted with retrying blocked wave spawns and a controlled check. The student team should verify wave schedules and performance when geometry remains blocked.

AI assisted with trying the initial spawn when both a bag drop and the active base are below the safe vertical boundary. The student team should test actual respawn and retrieval.

AI assisted with a provisional four-player admission guard. The student team should set place capacity, implement the lobby and test simultaneous joins and host return.

AI assisted with reserving a private-server owner's admission place and isolated checks. The student team should test real connections and finish host-session management.

AI assisted with checking character life-state flags at rescue stations and a controlled solo interaction. The student team should verify actual downing, elimination and multiplayer transitions.

AI assisted with the equivalent server-side life-state check for base selection and a controlled solo claim test. The student team should verify co-op host confirmation and real life transitions.

AI assisted with life-state validation for survivor information and daily help, and a controlled solo help interaction. The student team should test real life transitions and co-op.

AI assisted with rescue-objective snapshot validation and restoration. The student team should review its candidate-layout checks and integrate it atomically with the world and clock save.

AI assisted with building-power snapshot validation and synchronizing its point presentation. The student team should integrate it with the complete world save and verify co-op.

AI assisted with the survivor equipment repair interaction and its shared daily Trust limit. The student team should review the placeholder prop, input and co-op behavior.

AI assisted with repeatable survivor water delivery and its shared daily Trust limit. The student team should verify normal interaction and co-op.

AI assisted with the powered base-wave warning beacon and synthetic-event tests. The student team should review placement, readability and performance on the actual campus.

AI assisted with a Mimic stun/hearing race fix and synthetic hearing checks. A separate temporary-floor movement test failed with NoPath; the student team should investigate natural navigation and real gunfire.

AI identified the test-root collision mismatch and checked a cloned live Mimic investigating synthetic noise on a temporary floor and B1 stairs. The student team should test real gunfire and other routes.

AI tested a validated pistol request and the live Mimic's response through a temporary wall. The student team should repeat with natural gameplay and other guns.

AI tested shotgun and rifle pickup, reload, mouse firing and live Mimic hearing behind a temporary wall. The student team should repeat at exact boundaries and in co-op.

AI assisted with a provisional ambient listening creature and controlled hearing/wind-up test. The student team should review encounter placement, model rights, navigation and balance.

AI assisted with per-target attack warnings and visual collision handling for the listening creature. The student team should verify target switching with two clients.

AI assisted with round-state handling for the listening creature and a controlled loss-during-wind-up test. The student team should verify actual round endings and future host-pause integration.

AI tested crouch, walk and sprint input against an isolated listening creature. The student team should verify exact hearing boundaries and natural gameplay.

AI assisted with a provisional B1 barricade installation and an exit path probe. The student team should verify the route manually and complete wave damage, repair and other buildings.

AI assisted with server-validated B1 barricade strikes and controlled damage/repair tests. The student team should verify zero-health behavior, natural wave routes and co-op.

AI assisted with a non-blocking damaged barricade frame and a controlled destruction/repair test. The student team should verify natural wave routes and co-op.

AI checked a B1 exit with a real door prompt and Humanoid movement under controlled conditions. The student team should walk the route with an installed barricade and test co-op.

AI tested an expanded storage transfer through the live server with controlled client requests. The student team should verify the UI, all slots and multi-player ownership.

AI assisted with a provisional ambient patrol robot and controlled sensing checks. The student team should review its model rights, path, warnings and gameplay balance.

AI assisted with bounded pathfinding for the patrol robot and a controlled obstacle test. The student team should verify real campus navigation and moving targets.

AI assisted with a sanitized player-character Mimic visual and a temporary co-op selection rule. The student team should verify avatar rendering, identity cues and fairness in multiplayer.

AI assisted with provisional state-driven Mimic reveal and a controlled avatar-copy test. The student team should review the reveal presentation, UV gameplay and multiplayer fairness.

AI tested the live Mimic reveal with a client UV request and an immediate ray check. The student team should verify natural aiming and co-op rendering.

AI added a temporary built-in spatial firearm cue and tested one pistol shot. The student team should replace or approve the sound and verify mixing and multiplayer.

AI assisted with helicopter life-state validation and controlled solo tests. The student team should investigate the intermittent boarding test and verify real co-op transitions.

AI investigated the intermittent helicopter life-result check and added bounded waiting and diagnostics. The cause remains unresolved; the student team should reproduce it before acceptance.

AI adjusted the helicopter life-result test to query its own service instance and ran two controlled solo checks. The student team should verify actual downing, timing and co-op before acceptance.

AI assisted with a validated player-supplies snapshot and isolated Studio checks. The student team should integrate it with the complete ownership ledger and verify save/resume in multiplayer.

AI extended the supplies restore check to include caller-provided containers and tested duplicate item IDs in Studio. The student team should validate all ownership locations and test complete saves before release.

AI connected a server-only partial snapshot to live building storage and added validation across building and player inventories. The student team should review and integrate the complete world save and verify multiplayer recovery.

AI added recovery-bag state to the partial snapshot and validated it with a controlled callback and malformed-data checks. The student team should test live weapon recovery, multiplayer and full save/resume.

AI added carried firearm state to the partial snapshot and tested one loaded pistol in controlled solo Play. The student team should test disconnects and complete item identity and save/resume handling.

AI added server-generated firearm identities and tested a pickup-to-player transfer in controlled solo Play. The student team should test bag transfers, multiplayer races and complete save/resume.

AI added server-generated world-supply identities and partial snapshot validation, tested with one ammo pickup and a simulated daily event. The student team should test actual save/resume and multiplayer races.

AI added curated pickup model identity to the partial snapshot and tested an apple pickup in controlled solo Play. The student team should integrate visual restoration and verify full save/resume.

AI implemented the daily-supply restore callback and tested repeat-day handling in separate controlled Studio services. The student team should integrate complete world restoration and test a real host save and multiplayer.

AI added partial player-life snapshot validation and tested a controlled health/respawn capture. The student team should implement offline downed state and verify complete save/resume in multiplayer.

AI connected validated life records to player registration and tested a controlled living-player restore in Studio. The student team should integrate and verify complete world recovery and downed states.

AI connected supported clock snapshots to a temporary round and checked a day-3 restore in Studio. The student team should implement complete world loading and test night waves, host pause and helicopter recovery.

AI added boarding-roster restoration and tested an absent member's result in controlled solo Studio Play. The student team should test actual reconnect, downed players and full host save/resume.

AI implemented partial survivor Trust and reward-state restoration and tested controlled live and malformed-data cases. The student team should integrate complete NPC state and verify multiplayer save/resume.

AI added B1 barricade snapshot/restoration and tested damaged and occupied-doorway cases in controlled Studio Play. The student team should complete all buildings and verify integrated saves and co-op.

AI added active-base snapshot initialization and tested invalid/missing buildings in a temporary Studio scene. The student team should verify respawn, wave targeting and full save/resume.

AI added remaining incapacitation time to survivor snapshots and tested timed recovery in Studio. The student team should integrate host pause and complete save/resume.

AI moved survivor trade quota into snapshot-compatible server attributes and synchronized the food quest prompt. The student team should test actual trades after a complete save/resume.

AI tested survivor trade prompts after a controlled state restore in Studio. The student team should verify a real reopened save and multiplayer.
