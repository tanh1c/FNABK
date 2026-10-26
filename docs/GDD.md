# Five Nights at Bách Khoa — Developer GDD
> **Design baseline:** Assignment 01 (26 Oct 2026) · CO3045 · CC02 · Group 07 · **Status:** specification, not implemented.
> **Source of truth:** final English A01 LaTeX design. Changes after design freeze: document a CR in [DECISIONS](DECISIONS.md).

## 1. Game vision
**High concept:** One or two students are trapped at midnight in a fictionalized HCMUT campus. Investigate ordinary students and hostile **Mimics**, collect three Data Keys, and unlock Gate 1 before 06:00. A baton and UV device enable self-defense; attacking innocent NPCs reduces shared Trust and increases Alert.

**Genre:** third-person 3D low-poly survival horror, stealth, NPC investigation, light melee combat, co-op. **Platforms:** Roblox PC (keyboard/mouse). **Players:** solo or 2-player co-op; no PvP. **Session:** 900 real seconds (15 minutes); game clock 00:00–06:00. **Art:** dark but readable, angular low-poly shapes, restrained effects, comedic Easter eggs. **Non-goals:** five distinct nights, 4-player sessions, bosses, firearms, full campus, photorealism, economy, ML AI.

### Design pillars
- Suspicion before aggression: observe and check clues before striking.
- Readable horror: silhouette, sound, selected light; usable routes and targets remain visible.
- Bách Khoa identity: recognizable landmarks, fictionalized interior layouts.
- Cooperation without dependency: every required puzzle is solo-solvable.

### Reference adaptation
Five Nights at Freddy's (time pressure), Phasmophobia (evidence sharing), That's Not My Neighbor (impostor cues), Roblox co-op horror (accessible short sessions). Do not reuse external characters or IP.

## 2. Narrative, NPCs, endings
**Night Protocol:** at 23:58 a student lab's behavioral simulation malfunctions. Campus gates lock at 00:00; unstable copies impersonate students. Three Data Keys can restore gate access.

| Character | Role | MVP |
|---|---|---|
| Student player | Investigate, move, attack, escape | Yes |
| Normal student | Clues/dialogue; flees if attacked; no defeat HP | Yes |
| Mimic | Disguise, chase, attack, search, stun, defeat | Yes |
| Blue Professor | Fictional football-loving lecturer; optional nonblocking dialogue | Yes (cameo only) |
| Night Warden | More advanced patrol AI | No |

**End states:** WIN after three shared Keys + gate hold 5s + at least one player enters exit before timeout. LOSE on timeout or whole team irrecoverably downed. Solo downed = lose; co-op downed window 20s, teammate hold E 5s to revive at 40 HP. Optional secret football ending is **not** MVP.

## 3. Core loop and controls
Explore → inspect NPC/evidence → choose evade/UV/melee → solve current objective → acquire Data Key → repeat for three Keys → unlock gate/escape.

| Control | Action | Rule |
|---|---|---|
| WASD | Move | Third-person |
| Shift | Sprint | Stamina drain |
| C | Crouch | Slower/quieter |
| E | Interact, pick up, revive | Within 6 studs; hold on extended actions |
| Q | Scan NPC | 12 studs, LOS, 1s scan, 8s cooldown |
| Left mouse | Baton | 4.5 studs, 0.85s cooldown |
| F | UV stun | Range 13 studs, 2.2s stun, 14s cooldown |
| R | Medkit | +40 HP if carried |
| Tab | Objectives/inventory | Does not pause network round |

**Feedback:** distinct hit/miss, scan status, UV glitch/stun, quest popups, audio cues; reduce-jumpscare option and mouse sensitivity in settings. No mandatory voice chat.

## 4. Balance baseline
These are **proposed** values, not playtest measurements.

| Parameter | Baseline |
|---|---|
| Player HP | 100 |
| Walk / sprint / crouch | 12 / 19 / 7 studs/s |
| Stamina | 100 max; sprint -22/s; regen +18/s after 1s delay |
| Baton | 25 damage; 4.5 studs; 0.85s cooldown |
| Mimic | 75 HP; move 14 studs/s; hit 20 damage; 1.6s cooldown |
| UV | stun 2.2s; 13 studs; 14s cooldown |
| Scanner | range 12 studs; LOS; 1s interaction; 8s cooldown |
| Trust | 100 initial; -20 for each wrongful hit; min 0 |
| Medkit | +40 HP; carry max 1; two map placements |
| Round clock | 900 real seconds = six in-game hours |
| Mimics alive concurrently | 0 in tutorial, 1 early, up to 2 middle, up to 3 final |

Damage: `HP_next = max(0, HP - validDamage)`. Stamina: `clamp(S + 18*dt*regenFlag - 22*dt*sprintFlag, 0,100)`. Trust: `max(0, Trust - 20*wrongfulHitFlag)`. Ideal baton DPS `25/0.85 ~= 29.4` (not real DPS). Attacking normal students reduces Trust and raises Alert, but cannot defeat them. No friendly fire.

## 5. Identification, stealth and enemy FSM
Mimics exhibit at least two observable cues (repeated/inconsistent dialogue, contradictory ID, unusual UV reaction, unnatural behavior). Scanner reads **ANOMALY SUSPECTED** or **NO ANOMALY FOUND** only within valid range/LOS; players can solve library encounter without it.

FSM: **Disguise → Suspicious → Chase ↔ Attack**, **Chase → Search → Disguise**, **any active living state → Stunned → Chase**, **any living state → Defeated on HP 0**. Detection: approx 90° FOV, range/LOS raycast, simple movement-noise events. Lose sight >2s: search last-known position for 6s. Server owns transitions; explicit FSM, not ML. PathfindingService computes waypoints. Enemy stuck recovery required.

## 6. Map and mission sequence
Campus layout is *gameplay schematic*, not a geographically faithful reconstruction.

| Zone | Function / puzzle | Reward |
|---|---|---|
| Gate 1 / courtyard hub | Spawn, radio tutorial, locked gate, escape | Final win trigger |
| A3 | Push physics-enabled FuseCrate onto pressure plate; restore power | Key 1 |
| Library | Observe three NPCs and identify Mimic using clues | Key 2 |
| B4 / generator | Find fuse, restore power; medkit placement | Key 3 |

Mission order is sequential: A3 → Library → B4 → Gate. At 90s without progress show hint; 150s optional stronger hint. Keys are **server-owned booleans**, not droppable items. Crate/fuse props reset safely 10s after becoming inaccessible. Every mandatory objective works solo. Main gate requires a 5-second hold. Approximate time beats: 00:00–01:00 tutorial; 01:00–03:00 A3 threat; 03:00–04:30 library; 04:30–06:00 return and escape.

## 7. Art, audio, UX
- **Palette:** Night Navy #132437; Teal #1D907F; Paper Blue #F1F5F7; Mint #DCEFEA; Amber #C6954B.
- Readable darkness; no aggressive screen flashing; low-poly architecture and NPC silhouettes; limit shadowed lights, large textures and particles.
- HUD: HP/stamina, 00:00–06:00 timer, 0/3 Keys, current objective, hotbar (Baton/UV/Scanner/Medkit), team Trust, interaction prompts.
- UI flow: Menu → Solo/Host/Join → Briefing → Gameplay → Victory or Defeat → Retry/Menu.
- SFX: campus ambience, footsteps per material, Mimic reveal/chase cue, baton hit/miss, scanner/UV feedback, power activation, win/lose. Blue Professor cameo is non-blocking.
- Art shown in A01 is AI-generated concept imagery, **not implemented gameplay**.

## 8. Networking / ownership
**Server authoritative:** Clients send only `AttackRequest`, `ScanRequest`, `UVRequest`, `InteractRequest` with minimally necessary intent parameters. Server validates player alive, distance, LOS, cooldown, target class, tool possession and objective prerequisites. Only server mutates HP, Trust, Data Keys, round clock, NPC states and results. Clients render input, camera, HUD and local VFX; no client-selected damage. Testing: solo and two simulated clients, repeated/forged requests, disconnect safety.

## 9. Physics commitments
- FuseCrate is a real physics-enabled movable object; pressure plate reacts to overlap/contact and correct positioning.
- Mimic knockback uses bounded server-managed vector impulse.
- Detection and attack validation use raycasts and line of sight.
All three must be visible in demo/test evidence.

## 10. Team and delivery
**Instructor:** Phan Trần Minh Khuê · **Course:** CO3045 CC02 · **Group:** 07 · **Semester:** HK261.

Planned workstreams: Vũ Hải Tuấn (2353280): gameplay/physics/integration; Chu Nguyễn Tuấn Anh (2352022): AI/network/server tests; Lê Hoàng Chí Vĩ (2353336): GDD/level/UI/audio/QA. These are *plans*, not actual contribution claims.

Milestones: M1 GDD freeze; M2 graybox; M3 AI/combat; M4 network/missions; M5 art/playtest; M6 implementation handoff. Target >=30 FPS on i7-1165G7 / 16GB / Iris Xe (not yet measured). External playtests: >=3 participants; record time, wrongful hits, deaths, FPS and confusion points. See [acceptance matrix](ACCEPTANCE.md).

## 11. MVP / optional guardrail
**MVP**: one playable night, solo+2-player networking, gate/courtyard/A3/library/B4, one Mimic archetype, baton/UV/scanner, three Keys/two puzzles and generator/final escape, HUD/audio/menu/results, Blue Professor dialogue cameo. **Optional**: 5 nights, 4 players, Night Warden, guns, penalty mini-game, bosses, persistent progression and full-campus exploration.

## 12. Change control and academic integrity
For any baseline change record a CR in [DECISIONS.md](DECISIONS.md): scope, rationale, impacted IDs, reviewer approval, test evidence. Never silently downgrade the A01 commitment. Each AI-assisted change requires human review and must be explainable by the owning developer. Third-party assets need author/license/link; avoid using real lecturers' likenesses or club marks without permission.

## Traceability
- Test criteria: [ACCEPTANCE.md](ACCEPTANCE.md) (AC-01–AC-11)
- Machine-readable baseline: [game-spec.json](game-spec.json)
- Architecture: [ARCHITECTURE.md](ARCHITECTURE.md)
- Team workflow: [WORKFLOW.md](WORKFLOW.md)
- Source: final A01 English LaTeX/PDF design (original authoritative document).
