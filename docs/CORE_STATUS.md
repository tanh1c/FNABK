# Core gameplay status (2026-10-31)

> **Historical A01 status:** The observations below describe the older prototype, not the current five-day survival design. See [GDD](GDD.md) and [survival acceptance](ACCEPTANCE.md); all new-design acceptance criteria are currently not tested.

The project has a playable graybox sequence and substantial prototype systems, but core gameplay is not yet complete or fully validated against A01. Earlier results in ACCEPTANCE include user-reported passes and partial Studio MCP checks; they are not a comprehensive regression run.

## Implemented prototype

- A3 crate and Key 1, Library investigation and Key 2, B4 fuse/generator and Key 3, Gate hold and exit.
- One main Mimic with vision, hearing and FSM; baton, Scanner, UV and Trust penalty.
- Shared timer and keys; round result; solo/co-op life states and revive; medkits.
- Sprint, stamina, crouch speed/pose and inactivity hints; placeholder HUD and feedback.
- Expanded 300 x 300 stud campus schematic with connected routes, two academic-wing passages, detailed A3/Library/B4 facades, lawns, Marketplace benches, and 14 source-rebuilt trees from an inspected Creator Store asset. Current Play movement probes stopped at A3/Library/B4 glass and a tree trunk, and passed all three building doorways and both wing passages. A Creator Store school model was rejected for 37,296 descendants and 1,302 enabled scripts. The screenshot tool did not produce a usable campus overview, so visual review, natural full-route traversal, co-op checks and target-device measurement remain pending.

## Core gaps and evidence still required

- A01 requires bounded server-managed Mimic knockback; the current baton damage path does not implement it. The current Mimic is moved with anchored graybox parts, so physical knockback needs an explicit compatible design and test.
- The design calls for tutorial pacing (no Mimic during tutorial, then up to two/three later); the graybox currently builds one active Mimic. NPC identification cues and nonblocking Blue Professor cameo also need completion/validation.
- AC-01/02 full solo/co-op rounds, shared timer/key/gate behavior, timeout/team-down, security cases, crate reset, body-push, stamina exhaustion, hearing/vision regression and medkit edge cases need the recorded tests. Existing partial tests do not close these criteria.
- Crouch pose now supports the current AnimationConstraint avatar and Motor6D rigs in code; human visual review, R6 and multiplayer remain pending. Audio warning `203785492` remains unresolved because the requester has not been identified. The game has not yet received its planned audio set.
- Full user flow (menu, host/join, briefing, result/retry), settings, HUD, sound/VFX, authored animations, map art, performance measurement and external playtests are not complete.

Visual and audio production can begin in parallel against the graybox, while gameplay integration and the above checks continue. Do not mark A01 complete until the full acceptance evidence is recorded. See [MANUAL_CONFIRMATION](MANUAL_CONFIRMATION.md) and [ACCEPTANCE](ACCEPTANCE.md).
