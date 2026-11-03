# Five Nights at Bách Khoa — Survival Direction Draft

> This brainstorm history is superseded by the [current consolidated GDD](GDD.md). It remains a record of the discussion, not a second deliverable.

**Status:** Discussion draft, 2026-11-02. The user chose multi-day survival followed by signaling for rescue and surviving until a helicopter lands at the campus sports field, a roughly 1–2-hour complete run playable across sessions, food and water that deplete at a moderate pace, moderate horror with Mimics that impersonate NPCs and players plus other enemy or creature types, light damage when a teammate is attacked, solo or co-op for up to four players, limited respawns including solo respawn at the refuge, co-op teammate revival, a host-owned saved world, and a university behavioral-simulation experiment that created the Mimics and caused the disaster. Players can choose any campus building as their refuge and later move to another by transporting supplies; each building has context-appropriate power, storage and defensive upgrades. Other specific mechanics, numbers and locations below are proposals for discussion, not approved requirements or implemented features. A01 and its acceptance criteria remain the current baseline; see [CR-014](DECISIONS.md).

## 1. Vision

Students trapped on a fictionalized university campus after a disaster must keep a small refuge supplied, explore familiar buildings, identify Mimics among possible survivors, and assemble an escape plan. A familiar classroom can become a shelter, a source of supplies or a dangerous hiding place.

Third-person low-poly survival and exploration, with moderate horror and optional co-op for 1–4 players. The game should be tense but readable, use the campus identity and avoid requiring knowledge of the real university. The working title remains *Five Nights at Bách Khoa*; whether to rename it is open.

**Design pillars**
- Exploration with purpose: each trip offers useful resources, information or a route toward escape.
- Risk and preparation: decide where to go, what to carry and when to return.
- Suspicion with fair evidence: a Mimic is dangerous, but players can investigate before acting.
- Cooperation without dependence: a solo player can complete every mandatory objective.
- Campus mystery: environmental details and optional hidden spaces reward curiosity.

## 2. Story and ending

**Premise selected by the user:** A university behavioral-simulation experiment created the Mimics and went wrong, causing the disaster. The campus is isolated, power is unreliable, survivors are scattered, and the Mimics imitate people. The experiment's original purpose, how the accident occurred, and the state of the outside world remain open.

**Selected objective:** Send a distress signal, survive the wait and reach a rescue helicopter landing at a campus sports field. Each player who boards is rescued; in co-op, the group chooses when to depart and can wait for teammates, subject to a limited waiting period. The decision mechanism, waiting duration, behavior when the limit expires, and treatment of disconnected or incapacitated players remain open. As a proposed sequence, restore power and find radio components, transmit a signal, then prepare for the landing. Which existing sports area becomes the landing site, the rescue team, exact requirements, minimum number of days and fail conditions need team decisions and playtesting. Essential progress must not depend on finding an optional secret or a unique consumable.

## 3. Main loop and passage of time

1. Prepare at a refuge: choose equipment, share supplies and select a destination.
2. Explore a building or outdoor area, observe threats, gather supplies and look for clues.
3. Decide whether to take a further risk or return with what has been found.
4. Use supplies, repair or prepare the refuge, and advance the escape plan.
5. Survive the night and repeat until the group can send a distress signal and survive until rescue arrives.

**Proposed rhythm:** Days offer better visibility and time to explore; nights reduce visibility and increase threat pressure. Players may venture out at either time. A complete run targets approximately 1–2 real hours and can be continued across sessions. A starting prototype might test three in-game days, with adjustable day/night lengths; this is a playtest hypothesis, not a fixed campaign duration. Threats must have readable audio/visual cues and give solo players meaningful ways to avoid them.

## 4. Survival and refuge

- **Health and stamina:** Retain movement and injury as immediate concerns; medkits restore health.
- **Food and water:** Players must prepare and replenish both; their consumption should be gradual rather than a constant emergency. Exact rates, effects of depletion, availability and replenishment are not yet decided and require solo and group playtests.
- **Other supplies:** Prototype a small set such as medicine and components.
- **Refuge choice and relocation:** Players can choose any building in the campus as their base, and can later relocate to another building by transporting their supplies. Supplies do not automatically move with the active base. Fixed upgrades, such as restored electrical installations and reinforced doors, stay at the old building and can be used again upon return. Every building has predefined options for electricity, storage and defense, adapted to its actual layout and use; no building is assumed to be a universally secure refuge. The starting shelter, how the group agrees on a move, access to supplies left behind and the transition of respawn location remain open.
- **Base attacks:** Mimics attack the base only at night, as selected by the user. Attacks do not happen every night; danger increases over time and players receive advance signs. They can damage or break reinforced doors and defensive equipment, and players can repair those defenses. Daytime can be used to prepare and repair; this rule does not by itself make exploration or encounters outside the base safe during the day. Exact frequency, how escalation and warnings work, targeting of unoccupied previously upgraded buildings, damage and repair costs, treatment of stored supplies and recovery after a breach remain open.
- **Contextual upgrades:** As illustrative ideas, restore a library's existing lighting and organize its shelves as storage, secure classroom entrances in an academic building, or repair electrical equipment and use tool cabinets in a workshop. Exact upgrade points and available resources must be designed and checked for each building. Do not block essential escape routes, stairs or player exits with defenses.
- **Crafting and repairs:** Use a small number of clear recipes for essential supplies and defense repairs. The exact items, ingredients, workstations and building-specific options are still open. Repairs should be understandable and possible in solo play; materials required for mandatory progress need a recovery path.
- **Inventory:** Use a small, understandable carrying limit so the decision to return matters. Shared storage and item ownership need rules for disconnects and full inventories.
- **Failure recovery:** In solo play, a downed player can respawn at the refuge a limited number of times. In co-op, a downed player can be revived by a teammate; if not rescued in time, they can respawn a limited number of times. The limits, timing, cost, inventory treatment and what happens when respawns are exhausted remain open, as do group-wipe rules. The escape objective must not become impossible after a lost item, death or disconnect.

The existing baton, UV and scanner are candidates for reuse, subject to testing against the new loop. Their existing balance numbers do not automatically carry over.

## 5. Save and resume

The host owns the saved world and opens it for friends to join again in a later session. The host's availability is therefore needed to resume that world. Save slots, invitations, what is saved and how participants rejoin remain design decisions.

**Proposed minimum saved state:** world day and time, escape-objective progress, active base and relevant building upgrade states, the location and contents of storage and items being transported, explored or unlocked locations, and each participant's carried inventory and life state. Mimic and survivor state needs a deliberate rule rather than assuming every transient action is saved. Define what happens to a guest's items when absent, how an interrupted move or session resumes, and behavior for saving during danger, disconnecting, conflicting updates and a failed write before implementation. A save must not silently duplicate or lose items. Do not assume automatic persistence is already implemented.

## 6. Mimics and other survivors

Mimics can impersonate NPC survivors and player characters, and may become hostile when detected or provoked. Player impersonation is a selected design direction, not an implemented feature. Propose at least two observable clues per encounter, with clues distributed between appearance, behavior and the environment. Players can investigate, avoid or defend themselves; no encounter should require guessing without evidence. For example, a character resembling a teammate could display a visual anomaly and react incorrectly to a verification tool; exact clues and counterplay need playtesting.

Player impersonation must also have a solo-compatible form: a Mimic can copy the solo player's character or impersonate an NPC, with clues accessible to a solo player. An attack that hits an actual teammate causes light friendly-fire damage, as selected by the user. The server cannot know a player's intention; define the rule in terms of validated hits, not whether the attacker genuinely made a mistake. Damage amount, friendly-fire feedback, cooldown and protections against repeated deliberate attacks remain open. Decide how names, chat, voice and party indicators interact with impersonation; do not assume a Mimic can access a player's real communication. Provide enough information and time to respond, without relying on a real teammate being present.

Normal survivors can provide information or supplies. Whether Trust remains a shared resource, how false accusations work, the number of NPCs and the way encounters vary over days are open.

The user also wants mutated creatures and machines arising from university experiments alongside Mimics. Experimental machines patrol and detect players using light or sound, as selected by the user. Mutated creatures primarily hide, listen for noise and ambush players. For discussion, a player might hear movement before entering a hiding spot and avoid an ambush by moving quietly; the precise cues and counterplay are not yet selected. Exact creature identities, machine sensors, warning signals, responses, behavior after losing a target and the threats' specific origins need design and testing. Encounters should be legible and must not require simultaneous players to bypass them. Each enemy should present a distinct readable threat and counterplay rather than merely having different health. The first playable slice may use one Mimic to validate the core loop; this is an incremental test and does not remove the selected direction of additional enemy types.

## 7. Campus areas and secrets

The existing campus preview is a candidate environment and is not yet proven integrated into the runtime game. Keep existing building floor counts when adapting it.

| Place | Proposed use | Optional discovery |
|---|---|---|
| B1 | Classrooms, early supplies and an approachable route near the refuge | A blocked classroom with a survivor's stash or a clue to another building |
| A2 library | Documents, survivor accounts and investigation | A storage room behind shelving with background lore and useful supplies |
| A3 labs | Components and a power-restoration task | A restricted basement reached after a local power puzzle |
| Workshops | Tools, repair parts and environmental hazards | A locked equipment store with an alternate supply cache |
| Canteen and outdoor areas | Food, sightlines and routes between buildings | Small notes or supply caches with visible environmental hints |

Secret locations are optional: they may provide supplies, shortcuts or story context, but must not contain the only item required to escape. Hints should make discoveries plausible, and an entrance must not trap a player. The basement concept is not proof that an existing building already has a usable basement.

## 8. Solo and 2–4 player co-op

Every mandatory interaction and escape path must work for one player. For groups, propose shared escape progress and refuge storage, with individual carried items; the final inventory model remains open. Players may split up, regroup and revive an incapacitated teammate. If a co-op revive fails, limited respawns remain available; specific limits and treatment of a player who exhausts them are open. Rescue outcomes are individual: a player who boards is rescued, and the group chooses when to take off within a limited waiting period. Define the choice mechanism, expiry and partial-rescue rules, joining, leaving, respawning, spectator behavior, resource contention and scaling before implementation. Test 1, 2 and 4 players explicitly; existing two-player behavior is not evidence of four-player support.

## 9. Presentation and accessibility

Use the existing low-poly Vietnamese university identity, with signs and landmarks that support navigation. Moderate horror should favor atmosphere, readable silhouettes and sound over frequent jump scares or graphic violence. Provide readable interaction prompts, objective status, sound controls and a reduced-jumpscare setting. Final UI language and localization keys remain open.

## 10. Technical boundaries

Server owns and validates inventory, item transfers, resources, survival state, world time, NPC decisions, damage including friendly fire, refuge upgrades, secret unlocks and escape progress. Clients send intent and handle input, UI and audiovisual feedback. Validate distance, line of sight where appropriate, state, capacity, permissions and rate limits; prevent duplicate item grants and unsafe concurrent transfers. Save ownership and recovery rules remain open.

Saved progress requires server-owned persistence and recovery from failed writes; the selected host-owned model is not implemented functionality. The current implementation remains the A01 prototype: one-night timer, three Keys, two-player-oriented life cycle and existing NPC/mission services. Reuse is to be evaluated rather than assumed. The detached campus preview requires integration, route testing and performance profiling before it becomes a playable map.

## 11. Proposed first playable slice

A narrow prototype tests the base-choice interaction and a representative set of power, storage and defense upgrades in one building, alongside one nearby building, one optional hidden room, one Mimic, a limited supply pickup, a simple day-to-night transition and one escape-preparation objective. Playable solo first, then test the same slice with 2–4 players. The hidden room supplies an advantage, never the only required item. This slice is a validation step toward supporting **every** campus building as a base, not a reduction of that selected direction; the remaining buildings and their upgrades require subsequent implementation and review. This is a proposal, not a claim of implementation.

**Proposed checks, all not yet run:**
1. Solo: leave refuge, collect supplies, locate the optional room, avoid or confront the Mimic, return and advance the objective.
2. Co-op: repeat with two and four players; confirm shared state, item contention, teammate recovery and progress after a disconnect.
3. Secret: complete the required objective without entering it; verify the clue leads to the room and neither entrance nor exit traps a player.
4. Server validation: reject distant, repeated, forged or concurrent item and unlock requests without item duplication or lost progress.
5. Campus: walk routes naturally, inspect sightlines and measure frame rate on target hardware. No performance target has yet been measured on this preview.

## 12. Decisions to brainstorm

1. What was the experiment trying to achieve, and what caused it to go wrong?
2. How many in-game days best fit the 1–2-hour target, and how should the host's saved world handle absent guests?
3. What are appropriate food and water rates and consequences for depletion?
4. How many respawns are available, and what happens when they are exhausted or the whole group is defeated?
5. Who answers the distress signal, which sports area is the landing site, how do players choose departure and what happens at the waiting limit, and do preparation steps change between runs?
6. When moving the active base, how are supplies left at the old building accessed and the new respawn point activated? Which small set of recipes and workstations fits each building?
7. Which visual and behavioral clues make player impersonation fair, and how do player names and party indicators work?
8. What friendly-fire damage and safeguards create tension without enabling harassment or accidental team wipes?
9. How are night attacks selected and escalated, what signals warn players, and what are the damage and repair rules for defenses and treatment of stored items?
10. What are the identities and origins of the mutated creatures, and what are the precise cues and counterplay for their ambushes and the machines' detection?

## 13. Scope and migration

The full multi-day, four-player concept has greater scope than A01's 15-minute, 1–2 player round. Supporting every campus building as a base requires building-specific upgrade placement, accessible routes, safe respawn and solo/co-op balance for each. Moving supplies and resuming an interrupted relocation require reliable item ownership and recovery. New objectives, day/night, inventory, death recovery, NPC behavior and four-player testing require design and implementation. Keep A01's physical interaction, server authority and other commitments until the team reviews the replacement; compare each AC explicitly before updating [ACCEPTANCE](ACCEPTANCE.md). Adoption requires the appropriate student-team/course review and an update to the authoritative design and machine-readable spec, rather than silently treating this draft as A01.
