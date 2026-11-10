# FNABK — Creator Store Asset Shortlist

Use this as a shopping list for finding **candidates**, not as a list of approved or already integrated assets. Search terms are examples; an exact search result is not guaranteed. Priorities describe when to shortlist assets, not a request to import everything now. Current visual direction: readable, low-poly university campus; moderate non-graphic horror; PC performance target on Intel Iris Xe. **30 FPS is a target, not a measured result.**

## Existing project before looking for more

- The local `Final_Version_HCMUT_MAP.rbxl` contains a detailed 23-building campus preview, roads, lawns, trees, gates and a sports field. Presence was observed in the open place; it does not prove the map is integrated into the survival runtime, nor that individual rooms, doors or furniture are complete. Inspect and reuse suitable content before acquiring replacement buildings, vegetation or furniture. Preserve the user's place and models.
- Existing source documents an earlier A01 prototype with a graybox, one Mimic state machine, baton, UV, scanner, some interactions and local campus assets. These are reuse candidates, not evidence that the five-day survival systems or four-player co-op work. Asset provenance for the old gameplay campus is recorded in [CAMPUS_ASSETS.md](CAMPUS_ASSETS.md); its runtime campus is not the same as proof of survival-map integration.
- Team-owned code and native Roblox Parts/UI are appropriate for simple prototypes. A visual prop does not need to come with scripts, and a Marketplace model does not automatically supply tested multiplayer behavior.

## Priority 1 — first playable slice

Target the documented first implementation milestone: one graybox route, one Mimic with traceable Chase/Search transitions, then validated baton combat. Shortlist a few candidates, not every pack.

| Candidate | Purpose / desired form | Marketplace search examples | Selection checks |
|---|---|---|---|
| Student / survivor character | Human-looking Roblox character that can represent an NPC or serve as a Mimic disguise; 1 neutral base and an optional variant | `student character r15`, `school npc r15`, `civilian npc` | Compatible rig and avatar proportions; clear silhouette; avoid a licensed real-person likeness. A player disguise may instead reuse the player's supported avatar appearance. |
| Mimic reveal appearance | One original, non-graphic altered appearance for the disguised enemy | `mutant humanoid low poly`, `horror creature r15`, `monster humanoid low poly` | Readable before attack, compatible rig/animations, removable or separately identifiable visual pieces; no need for packaged AI. |
| Character animation candidates | Neutral idle, walk, run and chase; simple stagger/stun and attack if appropriate | `r15 walk animation`, `r15 run animation`, `npc attack animation`, `npc stagger animation` | Check R15 compatibility and publishing/usage permissions; idle/walk can use platform options while testing. Do not assume an animation can be played in the published experience without verifying ownership and permissions. |
| Baton / improvised melee prop | One lightweight handheld visual for server-validated baton combat | `baton low poly`, `wooden stick tool`, `metal pipe prop` | Scale and grip match an avatar hand; ideally model/mesh only; damage and cooldown must come from project server code. |
| Door and prompt visuals | One door model with separate frame and panel; native interaction prompt can be used | `school door low poly`, `classroom door model`, `metal door prop` | Door panel can be separated and positioned for a hinge; passage fits player and NPC navigation; no need for built-in door scripts. |
| One test-route dressing set | A handful of school desks, chairs and storage props to distinguish rooms | `classroom furniture low poly`, `school desk chair`, `school cabinet` | Check existing map first; room layout remains navigable and sightlines clear; small selection rather than a whole new building. |
| Basic first-slice audio | Footsteps, an enemy cue, melee swing/hit and an interaction cue | `concrete footsteps sound`, `monster growl`, `baton swing sound`, `interaction click` | Check playable in this experience, rights, loudness and looping; separate warnings from impact sounds. Sound may be sourced or authored later if suitable Marketplace audio is unavailable. |

The first slice can use primitives and existing code while candidates are reviewed. Required validation: Chase → Search transition, navigation and later a server-validated baton hit; see [SURV-06 and SURV-08](ACCEPTANCE.md). No result is claimed as passed for the new design.

## Priority 2 — survival and base prototype

| Candidate | Search examples | Notes for shortlist |
|---|---|---|
| Food portion and water bottle | `canned food low poly`, `water bottle prop`, `survival food pack` | One readable model per type; no built-in inventory required. |
| Medical kit / bandage | `medkit low poly`, `bandage prop` | Distinguishable from food and ammunition; avoid branded markings. |
| Materials | `scrap metal prop`, `electronics parts low poly`, `cloth roll prop` | Three visually distinct pickups; can use native Parts as placeholders. |
| Storage containers | `metal locker low poly`, `storage crate low poly`, `school cabinet` | Match classroom/workshop settings; storage ownership and capacity are gameplay code. |
| Barricade / repair pieces | `wood barricade low poly`, `door barricade prop`, `plank pile` | Modular, legible at doorways; never obstruct every exit or required route. |
| Portable lamp / generator visuals | `portable work light low poly`, `small generator prop`, `electrical panel` | Separate lamp, panel and generator visuals as needed; power behavior is project code. |
| UV light and scanner | `uv flashlight prop`, `handheld scanner low poly` | Check A01 prototypes first; ensure easy distinction and appropriate hand grip. |
| Radio and mission parts | `radio transceiver low poly`, `fuse box prop`, `radio component` | Clearly distinguish frequency clue, power interaction and transmitter component; reuse is fine if visuals remain understandable. |
| NPC survivor variant | `student npc r15`, `civilian character r15` | Needs recognizable human silhouette and compatible rig; dialogue and Trust remain server-owned code. |

## Priority 3 — full combat and enemy roster

| Candidate | Search examples | Notes for shortlist |
|---|---|---|
| Mutated listening creature | `mutant creature low poly`, `horror creature rigged`, `zombie creature r15` | Rig and animations must fit ambush and chase; readable and non-graphic; horde performance requires measurement. |
| Experimental patrol machine | `security robot low poly`, `patrol robot`, `small drone robot` | Visible sensor/spotlight; mobile parts optional; avoid animated imported behavior or scripts. |
| Pistol, shotgun, rifle visuals | `pistol low poly prop`, `shotgun low poly prop`, `rifle low poly prop` | Distinguishable silhouettes and grips; prefer models without working weapon systems. Verify geometry/appearance under moderate-horror direction. |
| Three ammunition box types | `pistol ammo box low poly`, `shotgun shell box`, `rifle ammo crate prop` | Three readable silhouettes or labels; one box per ammunition type; game rules supply rounds and quantities. |
| Firearm / enemy animations | `r15 pistol reload animation`, `r15 shotgun reload`, `r15 rifle animation`, `creature attack animation` | Must fit rig and support per-shell shotgun reload interruption; check permissions and account ownership. |
| Weapon / enemy audio | `pistol shot sound`, `shotgun blast sound`, `rifle shot sound`, `robot servo sound`, `creature rustle sound` | Distinct audible cues and controllable volume. Hearing ranges and damage are server mechanics, not Marketplace settings. |

## Priority 4 — rescue, secrets and atmosphere

| Candidate | Search examples | Notes for shortlist |
|---|---|---|
| Rescue helicopter | `rescue helicopter low poly`, `helicopter static model`, `helicopter interior low poly` | Recognizable silhouette, accessible entrance and usable boarding space; flight, timing, vote and immunity need project code. Check polygon count and room for player cameras. |
| Sports-field landing props | `helipad light low poly`, `landing beacon prop`, `emergency light` | Existing sports field is the target; use markers/lights without blocking routes. |
| Lab and experimental props | `laboratory equipment low poly`, `computer terminal prop`, `server rack` | Distinct from classrooms; prioritize modular, static props over a replacement building. |
| Hidden-room dressing | `archive shelf low poly`, `laboratory storage`, `school basement props` | Shelves, boxes and records support optional discovery; passages and exits require map review. |
| Audio ambience and music | `campus ambience`, `night wind ambience`, `suspense ambient loop`, `helicopter sound` | Independent volume controls; avoid copyrighted or unidentified tracks. Look for usable clean loops, not excessively loud jumpscares. |
| Icons / UI symbols | `inventory icons`, `survival ui icons`, `map icons` | Find a consistent, readable set for health, water, food, inventory and objectives; native UI shapes/text can be used instead. Verify reuse rights and resolution. |

## Suggested search order

1. A neutral R15 student NPC and one matching movement / attack animation set.
2. A restrained Mimic reveal appearance and one baton or pipe prop.
3. One separate-panel classroom door and a small set of classroom props, only where the existing campus is missing them.
4. A few essential sounds for footsteps, interaction, attack and enemy warning.
5. Food, water, medkit and storage / barricade visuals after the first AI and baton slices are verified.
6. Remaining creatures, firearms and the helicopter when their respective systems are scheduled.

## Candidate log

Duplicate this table while browsing. A shortlist entry is **not approval to import, execute, upload or publish**. Paste Marketplace links or asset IDs for review later.

| Category | Candidate / link / ID | Creator and current terms | Price | Rig / model details | Scripts or external links present? | Decision |
|---|---|---|---|---|---|---|
| Student NPC |  |  |  |  |  | Shortlist / reject / review |
| Mimic visual |  |  |  |  |  | Shortlist / reject / review |
| Animation |  |  |  |  |  | Shortlist / reject / review |
| Baton |  |  |  |  |  | Shortlist / reject / review |
| Door / furniture |  |  |  |  |  | Shortlist / reject / review |
| Audio |  |  |  |  |  | Shortlist / reject / review |

## Before adopting a shortlisted asset

Check the listing's creator, current usage rights, price and compatibility; note any attribution requirements. Inspect models before use for scripts, hidden components, URLs, QR codes, social links, personal information and restricted content. Prefer visual-only assets and separately implemented server-authoritative gameplay; do not execute bundled scripts just to evaluate a model. Profile part count, mesh complexity, draw calls and pathfinding in a representative scene before deciding it fits the target device. Keep references local and follow the repository's Roblox Asset Upload Safety Policy; importing an external asset, modifying the shared Studio place, publishing, and uploading are separate actions requiring the applicable explicit approval.
