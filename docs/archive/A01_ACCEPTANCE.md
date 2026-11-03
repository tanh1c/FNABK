# A01-to-A02 acceptance matrix

> **Archived historical evidence:** These are A01-era criteria and reports, not results for the current survival game. See [current acceptance criteria](../ACCEPTANCE.md).

This file tracks **committed MVP tests**, not completed work. Record `PASS/FAIL/BLOCKED` and evidence URLs only after executing a test in Studio.

| ID | Requirement | Verification evidence | Current |
|---|---|---|---|
| AC-01 | Solo round reaches Good Ending without soft-lock | Video + solo playtest log | NOT TESTED |
| AC-02 | Two clients share timer, Keys, gate state | 2-client Studio log | NOT TESTED |
| AC-03 | Mimic transitions through Disguise, Suspicious, Chase, Attack, Search, Stunned, Defeated | FSM debug state trace | NOT TESTED |
| AC-04 | Baton deals server-validated Mimic damage; normal NPC not defeated; wrongful hit costs Trust | Hit/validation cases | NOT TESTED |
| AC-05 | Scanner and UV enforce range/LOS/cooldowns; UV stops enemy for 2.2s | User-reported Roblox Studio check (2026-10-28; detailed logs not attached) | PASS (user-reported) |
| AC-06 | A3 physical crate activates pressure plate; out-of-bounds crate resets | User-reported carry/body-push and Key 1 pass; reset and partial-placement checks pending | PARTIAL (user-reported) |
| AC-07 | Library Mimic investigation solo-completable, yields Key 2 | User-reported Studio result: Key 2 collected (2026-10-28; detailed cases not supplied) | PASS (user-reported) |
| AC-08 | B4 generator + 3 keys + gate hold, win and timeout/loss states | User-reported Key 3 and Gate escape pass; timeout and team-down checks pending | PARTIAL (user-reported escape; remaining cases pending) |
| AC-09 | Menu, HUD, accessible settings, audio, result screens | UI walkthrough | NOT TESTED |
| AC-10 | Blue Professor cameo dialogue works but never blocks progress | NPC interaction test | NOT TESTED |
| AC-11 | Playable place, setup README, source Git history, credits, and playtest report delivered | Submission audit | NOT TESTED |

**Security gates:** rejected spoofed attack/scan targets, distant attacks/scans, cooldown bypass, and client-supplied damage or scan classifications. **Performance gate:** FPS on specified hardware is a target to measure, not proof of success.

The combined human playtest queue is tracked in [MANUAL_CONFIRMATION.md](../MANUAL_CONFIRMATION.md).

## Campus environment pass (AC-01/AC-02/AC-03/AC-07/AC-08/AC-09; partial)

The runtime map retains its A3, Library, B4 and Gate mission anchors and adds a low-poly campus schematic around them. Spawn is near Gate 1 in line with A01. North and south academic passages now use the same source-built two-storey facade family as the A3, Library and B4 shells. The mismatched red Creator Store school model is no longer cloned into the map. Structural walls, floors, roofs, benches, lamp poles, planter stone edges, wayfinding board/post and tree trunks collide; signs' surface graphics, path markings and foliage remain decorative. Front window openings use collidable glass; the passage doors remain open. Automated movement and pathfinding checks were performed in one client; natural traversal and target-device performance remain for the team's review.

The 2026-10-31 campus identity and scale follow-up adds a framed Gate 1 portal, distinct objective-building roof markers, a distant non-collidable campus backdrop, and a corrected tree-mesh scaling formula. A Rojo build and Studio Play smoke check succeeded. Latest runtime count was 1,496 BaseParts (340 collidable); radius-2 pathfinding succeeded from spawn to the Gate interior and all three objective-building approaches. The 16-stud GateDoor retains over 20 studs of clear width between its portal posts. These are automated checks only. Natural keyboard collision at the exact user-reported object, full solo/co-op traversal, visual style and target-device performance remain pending under flows #8 and #9 in [MANUAL_CONFIRMATION](../MANUAL_CONFIRMATION.md).

1. Walk from Gate spawn to A3, complete Key 1, interview the Library suspects and obtain Key 2, collect the B4 fuse and restore the generator for Key 3, then hold E at Gate and enter the exit. Expected: routes and prompts remain usable without getting stuck; early E release does not open the Gate and a complete hold opens it.
2. Repeat with two players and an active Mimic. Check chase/search and hiding around the divider, crate carrying and body-pushing, both medkits, camera visibility, route clarity and visual quality. Observe performance on the target hardware; no FPS result is claimed.

Studio MCP 2026-10-31: after spawn relocation, radius-2 pathfinding returned Success for Gate spawn → A3, A3 → Library, Library → B4 fuse, fuse → generator and B4 → Gate. In a separate test session using E plus test-only character repositioning and disabling the Mimic, the assistant collected Key 1, interviewed/accused suspects for Key 2, and collected the fuse and Key 3. An initial Gate hold was rejected and a later hold succeeded; server event timings varied around the strict five-second threshold. The Gate prompt was then given a 0.25-second client-side duration buffer, while the server still requires five seconds. In a fresh session with keys set using test code, releasing E after two seconds kept Gate closed, a full hold opened it, and teleporting to the exit produced Won. These are partial manipulated checks; natural traversal, timing over poor network conditions, two-client behavior, chase, real audio and full gameplay remain unverified. The existing asset type warning `203785492` still appeared.

Final campus patch check in Studio MCP on 2026-10-31: the runtime map contained 844 BaseParts (402 collidable), including 20 trees. At scale 0.14, the inspected source geometry gives an estimated tree height of 2.79 studs; each tree uses a 3 x 1-stud trunk proxy. The imported south school clone measured 33.12 x 33.90 x 23.85 studs, with 142 BaseParts and no scripts. Radius-2 PathfindingService returned Success for Gate→A3, A3→Library, Library→B4 and B4→Gate. Controlled server-side Humanoid movement stopped at the school, tree trunk and north academic window. The character used `Default`, the only registered collision group, and `Default` collided with itself. These single-client checks do not establish natural keyboard movement or co-op. Screen capture still showed a black 3D viewport, so visual quality remains unverified. The `203785492` audio asset type warning still appears.

## A3 lab graybox visual slice (AC-01/AC-03/AC-06/AC-09; partial)

The runtime `A3Environment` adds short back-corner wall returns, an engineering lab sign, panel graphics, floor markings and a spawn-area destination board. The front of A3 remains open; markings and signs are non-collidable and non-queryable. Existing crate, pressure plate, Library, B4 and Gate objective objects retain their paths and starting positions. This is a layout and visual sample, not a finished campus map or proof of complete traversal.

1. In a fresh Play session, find the A3 lab from spawn and identify the plate, crate and medkit. Expected: signs and markings are readable and do not block interaction.
2. Pick up the crate with E, walk to the plate and place it without repositioning. Expected: the route is navigable, the crate stays collidable, and Key 1 is granted after settling. Repeat by body-pushing and while the Mimic pursues.
3. After Key 1, walk to Library, B4 and Gate. Expected: all objectives remain reachable and the added geometry does not prevent the Mimic navigating around the lab. Check scene readability in solo and two-client play.

Studio MCP check on 2026-10-31: the new environment contained 16 parts, the crate/plate remained at their original coordinates and the plate was non-collidable. Pathfinding queries succeeded from spawn toward the crate, along an open route near the crate/plate with agent radii 2 and 3, and from the plate toward Library. A query starting at the crate's occupied position returned NoPath; it is not evidence of a blocked player route. The assistant picked up the crate with E, but automated character navigation did not reach the intended plate approach while carrying; the assistant then repositioned the carrier during Play and E placed the crate on the plate, granting Key 1. This verifies the plate interaction under manipulated conditions only, not natural carry traversal or Mimic navigation. Test-only changes were discarded on Stop. Human visual and movement confirmation remains pending.

## Movement and stamina slice (AC-01/AC-06/AC-09; partial)

The server combines sprint/crouch input, life state and crate restrictions into player WalkSpeed. Shift requests sprint, C toggles crouch; stamina starts at 100, drains at 22 per second while moving and sprinting, and regenerates at 18 per second after a one-second delay. At zero stamina, release Shift before sprinting again. Crouch takes precedence over sprint; carrying or actively pushing caps speed at 7 or 5.5 respectively. The HUD displays replicated stamina and crouch state. Crouch pose and quieter movement-noise detection have since been added; see the stealth slice below for its limits and outstanding tests.

1. Walk, hold Shift while moving, stop or release Shift, and toggle C. Expected speeds: walk 12, sprint 19, crouch 7 studs/s. Stamina drains only during actual sprint movement; it starts recovering one second after sprint ends and never exceeds 100.
2. Sprint until empty. Expected: speed drops to walking, stamina stays within 0–100, and after release of Shift it can regenerate and be used again.
3. Carry a crate while holding Shift, then place it. Expected: carry speed is at most 7; on release it immediately returns to the active movement mode. Actively body-push, stop or step away; expected speed cap 5.5 while pushing and immediate restoration afterward. Repeat while crouched and while downed/revived.
4. With two clients, verify each player's stamina and movement inputs are independent and a downed player cannot sprint or crouch.

Studio MCP solo check on 2026-10-31: with the Mimic disabled in the test session, server speed was 12 initially, 19 while Shift+W was held with stamina falling from 100 to 61 in approximately two seconds, 12 after release and 7 after C. Actual crate pickup produced speed 7; holding Shift retained 7 while carrying and placing the crate restored speed 19 while Shift remained held. Test-only character downed attribute produced speed 0, returning to 12 after it was cleared. No full stamina exhaustion, body-push regression, real revival, two-client or movement-feel check was completed. Test-only changes were discarded on Stop.

## Crouch and movement hearing (AC-03/AC-09; partial)

Client presentation poses supported R15/R6 hip joints and R15 waist while the replicated crouch attribute is active, and lowers the volume of an existing character Running sound when available. Both Motor6D and AnimationConstraint joints are supported. The server samples grounded movement every 0.8 seconds: provisional hearing radii are 4 studs crouched, 12 walking and 20 sprinting. Hearing can cause `Disguise → Suspicious → Search` toward the heard location; attacks still require the existing visible-target checks. Sound is not blocked by walls in this prototype. Search can re-enter Suspicious on seeing a player. These distances are provisional because A01 does not specify them.

1. In a fresh Play session, press C; expected: crouch pose, speed 7 and quieter existing footsteps. Press C again; expected: normal pose, speed and volume return. Check R15 and R6, other clients, crate carrying and revive.
2. Set up a Mimic out of view of a moving player. At the same distance between 4 and 12 studs, compare crouch and walk; expected: walking can trigger Suspicious then Search, while crouching does not trigger hearing. At a distance between 12 and 20 studs, compare walk and sprint. While stationary or airborne, no movement-noise detection is expected.
3. After hearing, verify Search follows the last heard position, no damage occurs through a wall, direct sight reacquires the player, and stun/defeat behavior still works.

Studio MCP solo check on 2026-10-31: an R15 player toggled crouch and the replicated attribute became true. A temporary cloned test Mimic with visual detection disabled and movement speed zero did not react to a crouched movement attempt outside 4 studs; with crouch off, player input at approximately 8 studs led to `Disguise → Suspicious → Search`, with a last-known position recorded. The test clone and repositioning were temporary and discarded on Stop. This did not verify audible playback, visual pose quality, R6, live chase, walls, sprint range, crouch within 4 studs or co-op. Studio Output also showed the pre-existing asset type mismatch for `rbxassetid://203785492`.

Follow-up Studio MCP check on 2026-10-31 identified an actual pose defect: this R15 avatar used AnimationConstraints and the original code only selected Motor6Ds. After updating both joint support and the animation timing, C set the observed LeftHip and Waist transforms to the intended crouch angles; pressing C again restored animation-driven transforms. The visual appearance, R6 and co-op remain pending. The asset type mismatch remains unresolved: MarketplaceService identified `203785492` as audio `Pop Close Sound`, but a search of game scripts and live Sound instances found no direct reference. This does not establish which Studio or Roblox component requested it; no asset was replaced.

## Objective inactivity hint (AC-01/AC-02/AC-09)

The server shows one shared hint after 90 seconds without tracked mission progress while the round is running. Key collection, Library interviews/clues, B4 fuse pickup and opening the gate reset the timer. The hint reflects the current phase and is displayed for five seconds. It does not award progress or alter puzzle state.

1. Start a fresh round and wait 90 seconds without progress. Expected: both clients see `HINT` with the A3 crate/plate instruction once. Keep waiting and confirm it does not repeat without progress.
2. Place the crate on the plate. Before 90 seconds of further inactivity no Library hint should be sent; after 90 seconds expect a Library instruction. Interview suspects or collect another key and confirm the countdown restarts and the next hint matches the new phase.
3. After the fuse is collected and again after opening Gate 1, wait 90 seconds without further progress. Expected: the hints refer to the generator and exit respectively. Finish or lose the round; no further hint should be sent.

The stronger 150-second hint is optional in A01 and is not implemented in this slice. Visual readability and co-op delivery remain queued for human confirmation.

Studio MCP check on 2026-10-31: the normal service initialized with the configured 90-second delay. A separate temporary service instance with a 3-second delay was run in Play while test code changed shared objective state: server Output reported the A3, Library, and B4 generator hints in sequence, and no new hint appeared during four seconds after the round was set to Lost. This check did not establish the actual 90-second timing, client display, one-shot behavior over a full idle interval, or two-client delivery. The first ordinary Play attempt ended in team loss before its 90-second hint could occur. Test-only state changes were discarded on Stop.

## Studio-only item range guide

During **Play** in Roblox Studio, press **V** to cycle `OFF → BATON (4.5 studs) → UV DEVICE (13 studs) → SCANNER (12 studs) → OFF`. A colored sphere shows the selected radius around the player's `HumanoidRootPart`. Aim directly at a Mimic or Student to see the measured 3D distance from the player root to the NPC `PrimaryPart`, plus `IN RANGE` or `TOO FAR`. The distances read from `GameConfig` and use the same endpoints as the server's Baton, UV and Scanner range checks. This helper runs only in Studio and does not alter gameplay requests or server validation.

## AC-03 first-slice Studio check (result not recorded)

The graybox Mimic controller covers `Disguise`, `Suspicious`, `Chase`, `Attack`, `Search`, and the UV-driven `Stunned` state; the baton slice can set `Defeated`. AC-03 remains incomplete until its full trace is run and recorded.

1. Open the local place in Roblox Studio and press **Play**. In Explorer, inspect `Workspace/FNABKGraybox/Mimic` and its `MimicState` attribute; keep the Output window visible. The Studio-only label above the Mimic also shows its current state and HP.
2. Spawn within the Mimic's forward view and detection range. Expected: the attribute, overhead label, and server Output show `Disguise → Suspicious → Chase`; the Mimic moves toward the player.
3. Let the Mimic approach within 3.5 studs. Expected: `Chase → Attack`; the player loses 20 HP on each hit, no faster than once every 1.6 seconds. Move out of attack range while remaining visible. Expected: `Attack → Chase` and no further damage while outside range.
4. Move to the far side of `SightlineDivider` and stay behind it for more than 2 seconds. Expected: the Mimic enters `Search`, logs its last-known position, and follows a path toward that position.
5. After seeing `Search`, stay out of line of sight until its 6-second search window expires. Expected: Output shows `Search → Disguise`; if the player is still visible, a new `Suspicious` transition may follow. Re-enter its view to confirm the sequence can repeat.

The prototype uses a 3.5-stud Mimic attack range because A01 specifies damage/cooldown but not melee range; treat that value as provisional during playtesting. Record the actual result and evidence in the test record above only after running these steps in Studio. AC-03 remains `NOT TESTED` until then.

## AC-04 first-slice Studio check (result not recorded)

The baton prototype validates a server-granted Baton, player life, target identity, range, line of sight and server cooldown. The client sends only its aimed NPC model; damage, Mimic health, Trust, Alert and flee state remain server-owned.

1. Press **Play** and check Explorer for `ReplicatedStorage/FNABKRemotes`, `ReplicatedStorage/FNABKRoundState`, and `Workspace/FNABKGraybox/Student`. Above the NPCs, expect a red `MIMIC` label and teal `STUDENT` label; the Mimic label includes state/HP and the Student label shows its state. Confirm `Trust` starts at 100 and `Alert` at 0. Equip **Baton** from hotbar slot 1, then press **V** once to show the 4.5-stud range sphere and live distance readout.
2. Approach the Mimic until within 4.5 studs, aim at its visible body and click three times, waiting at least 0.85 seconds between clicks. Expected: `MimicHealth` changes 75 → 50 → 25 → 0; feedback reports each hit and then `MIMIC DEFEATED`; `MimicState` becomes `Defeated` and the Mimic darkens/stops moving.
3. Stop and start a fresh Play session to reset the prototype. Hit the Student once from within 4.5 studs. Expected: the Student remains present, changes to `StudentState=Fleeing` and runs away; shared Trust changes 100 → 80 and Alert 0 → 1. Feedback reports `WRONGFUL HIT`.
4. In a fresh Play session, aim at the Mimic from farther than 4.5 studs and click. Expected: `OUT OF RANGE`; `MimicHealth` does not change. Move within range but keep a wall between the player and Mimic; expected: no health change and blocked/miss feedback.
5. Click again before 0.85 seconds have elapsed. Expected: `BATON RECHARGING`; no additional damage. Click with no NPC under the aim point. Expected: `BATON MISS`.

Record actual results and evidence in the test record above only after running these steps in Studio. The Student flee route uses server PathfindingService and can report an unavailable path if the generated navigation mesh cannot find one. AC-04 remains `NOT TESTED` until the steps are run and recorded.

## AC-05 UV and Scanner first-slice Studio check

The AC-05 prototype now includes UV and Scanner. The server grants both tools, validates player/tool/target/range/line of sight/cooldown, owns the Mimic's timed `Stunned` state, and returns the scan classification only after the full scan duration. On 2026-10-28, the user reported that their Studio test passed. This is a user-reported result; detailed per-case Output logs, screenshots, and Studio mode were not supplied. The assistant did not run Play or execute Luau tests.

1. Press **Play**. Confirm a **UV Device** and **Scanner** appear in the hotbar and that `ReplicatedStorage/FNABKRemotes` contains `UVRequest`, `UVFeedback`, `ScannerRequest` and `ScannerFeedback`. Keep the Mimic overhead state label and server Output visible. Press **V** twice until the guide shows the 13-stud UV range.
2. Aim at the Mimic from within 13 studs with a clear view; use the guide's measured distance to position yourself, then press **F**. Expected: `MIMIC STUNNED | 2.2s`, `MimicState=Stunned`, and no Mimic movement or attacks for 2.2 seconds; then the state returns to `Chase`.
3. In a fresh Play session, aim at the Mimic from farther than 13 studs and press **F**. Expected: `UV OUT OF RANGE`; the Mimic does not enter `Stunned`. In another fresh session, try with a wall between you and the Mimic. Expected: no stun and miss/blocked feedback. The client may report `UV MISS` when the wall hides the target from its aim ray; the server still performs its own line-of-sight check whenever a target is nominated.
4. In a fresh session, stun the Mimic successfully, wait until the 2.2-second stun ends, then press **F** again before 14 seconds have elapsed. Expected: `UV RECHARGING`; the Mimic does not re-enter `Stunned`. After the cooldown expires, a new valid use should stun it again.
5. Press **V** until the guide shows the 12-stud Scanner range. Aim at the Mimic within 12 studs with clear line of sight and press **Q**. Expected: `SCANNING NPC`, followed after about 1 second by `ANOMALY SUSPECTED | MIMIC`. In another fresh session, scan the Student; expected result is `NO ANOMALY FOUND | STUDENT`.
6. In fresh sessions, try Q while aiming beyond 12 studs, aim at a wall that hides the NPC, or move beyond range during the 1-second scan. Expected: no classification result and an out-of-range, miss or interrupted message. A scan activation attempt starts the 8-second cooldown, so use a fresh Play session for each negative case.
7. After a valid scan, press **Q** again before 8 seconds elapse. Expected: `SCANNER RECHARGING` and no second classification. After cooldown, a new valid scan should work.

The server starts each tool's cooldown on an accepted activation attempt, so a miss, out-of-range attempt, or blocked attempt also requires a fresh Play session before another cooldown case. The user-reported PASS does not include individual outcomes for every case above; retain the detailed record below if more precise evidence is collected.

### AC-05 test record
```
Test ID: AC-05
Build commit: Working-tree build FNABK-AC05-Scanner-20261028.rbxlx (not committed)
Tester / date: User / 2026-10-28
Studio mode: Not reported
Steps: User reported completing the AC-05 Studio test; individual cases not enumerated.
Expected: UV and Scanner positive/negative checks described above.
Actual: User reported "pass" in chat.
Result: PASS (user-reported)
Evidence: Chat report; no screenshot or Output log attached.
Bug issue: None reported.
```

## AC-06 A3 FuseCrate and pressure plate first-slice Studio check (partial; user-reported)

The graybox generates a dynamic, collidable FuseCrate. A server-validated **E** prompt picks it up or places it down. While carried, a WeldConstraint holds it in front of the player, collision stays enabled, and the player's movement speed is reduced. The box is offset forward so it clears the character when placed; speed returns immediately on drop. Body-push speed is reduced only while the player is actively moving into the dropped crate, and returns immediately when they stop pushing or lose contact. A low-frequency server check activates A3 power and shared `DataKeys/Key1` only when the full crate footprint fits on the plate, it is not carried, and it settles there. A server monitor caps speed and rejects implausible in-bounds position jumps. If the crate leaves the graybox reset bounds, it returns to its A3 start position after 10 seconds. This carry option is recorded as CR-001 because A01 describes pushing the crate. This slice does not implement the rest of the A3 mission or the later Library/B4 objectives.

1. Press **Play**. In Explorer, inspect `Workspace/FNABKGraybox/A3/FuseCrate` and `PressurePlate`. Expected: the dynamic, collidable FuseCrate has a **Pick Up** prompt within range; the thin non-collidable PressurePlate sits flush with the floor; `ReplicatedStorage/FNABKRoundState/DataKeys/Key1`, `Key2`, and `Key3` exist and start false.
2. Press **E** at the crate. Expected: the collidable crate is held in front of the character, blocks walls/obstacles, and movement slows. Press **E** again. Expected: the crate drops and normal movement speed returns immediately. Walk into the dropped crate without picking it up. Expected: it moves under body contact and player speed slows while actively walking into it; the character does not pass through. Stop pressing movement while still touching the crate. Expected: normal speed returns immediately. Move away. Expected: normal speed remains restored.
3. In a fresh Play session, use **E** to carry the crate fully onto the PressurePlate, then press **E** to place it down. Expected: after it settles, the plate changes from amber to teal, `FNABKRoundState/A3PowerRestored` and `DataKeys/Key1` become true, and Output logs that A3 power was restored and Key 1 collected. Also test body-pushing the dropped crate slowly onto the plate.
4. In a fresh Play session before activating the plate, select FuseCrate and set its Position Y to **-15** in Properties. Expected: it stays out of bounds for 10 seconds, then returns to its A3 starting position; Output logs the reset.
5. In another fresh Play session, put only part of the crate on the plate, without fitting its full footprint. Expected: A3PowerRestored and Key1 remain false.

### AC-06 test record

The user reported pushing the crate onto the plate and confirming Key 1 was collected. The user also reported that the raised plate obstructed the crate and that the character sometimes passed through it. The plate is now thin and non-collidable. CR-001 adds E pickup/place with collision while carried and slower body-pushing; the user reported the updated carry/body-push behavior passed on 2026-10-28. The out-of-bounds reset and partial-placement rejection have not been reported as tested, so AC-06 remains partial.

### Test record format
```
Test ID:
Build commit:
Tester / date:
Studio mode: Solo | Local Server + 2 Clients | Real clients
Steps:
Expected:
Actual:
Result: PASS | FAIL | BLOCKED
Evidence:
Bug issue:
```

## AC-07 Library Mimic investigation first-slice Studio check (user-reported PASS)

After A3 Key 1 is collected, three Library suspects can be interviewed with **E**. The two normal students give consistent ID/dialogue clues. The Mimic gives two inconsistent clues across two interviews. After all three suspects have been interviewed and both Mimic clues are recorded, use **E** on a suspect to accuse them. A wrong accusation does not award a key or penalize Trust; identifying the Mimic sets server-owned `DataKeys/Key2`. The state is shared, so one player can finish it solo or players can split interviews. Scanner can classify all three suspects, but it does not bypass interviews or the accusation.

1. Press **Play** and finish AC-06 until `ReplicatedStorage/FNABKRoundState/DataKeys/Key1` becomes true. Expected: **Interview** prompts become available at `Workspace/FNABKGraybox/Library/Suspects/LibraryStudentA`, `LibraryMimic`, and `LibraryStudentB`; Key 2 remains false.
2. Press **E** once at each of the three suspects. Expected: the feedback shows consistent student ID/dialogue notes for the two students and an ID mismatch for the Mimic. `ReplicatedStorage/FNABKRoundState/LibraryInvestigation` records the three interview flags.
3. Press **E** on the Mimic again. Expected: a second clue reports repeated/inconsistent dialogue. After all three interview flags are true and `MimicCluesFound` equals 2, each prompt changes to **Accuse**.
4. Accuse either normal student. Expected: feedback says the student's evidence is consistent and Key 2 stays false. Then accuse `LibraryMimic`. Expected: feedback says **MIMIC IDENTIFIED**, Output records the result, and `DataKeys/Key2` becomes true. Repeat this flow with one player to confirm solo completion.
5. Optional scanner check before accusing: use **Q** on a normal Library student and then the Library Mimic in separate cooldown windows. Expected: `NO ANOMALY FOUND | STUDENT` and `ANOMALY SUSPECTED | MIMIC`; Key 2 stays false until all evidence and the accusation are completed.

### AC-07 test record
```
Test ID: AC-07
Build commit: Working-tree build; not committed
Tester / date: User / 2026-10-28
Studio mode: Not reported
Steps: User reported passing the Library investigation and collecting Key 2.
Expected: Correct Mimic accusation after required evidence grants server-owned DataKeys/Key2.
Actual: User reported “pass” and confirmed Key 2 was collected.
Result: PASS (user-reported)
Evidence: Chat report; no screenshot or Output log attached.
Bug issue: None reported.
```

The user-reported PASS confirms Key 2 collection; wrong-accusation and two-client cases were not separately reported.

## AC-08 B4 and Gate escape user-reported PASS; co-op revive retest PASS (full round partial)

The user reported collecting Key 3 and then passing Gate 1 and escaping successfully on 2026-10-28. The game now has a shared 900-second timer, all-key Gate prerequisite, server-validated five-second hold, and exit-zone win. Timeout/team-down loss and two-client round sharing have not been separately reported. `PlayerLifeService` implements the A01 co-op downed/revive rule: solo down means immediate loss; in co-op, a teammate has 20 seconds to hold **E** for five seconds within six studs and clear line of sight, restoring the downed player to 40 HP. The first two-client revive attempt failed because Client 2 did not see the E prompt and Client 1 appeared to regain health while remaining immobile. After the source fix, the user reported passing the revive and bleed-out retests: the prompt works, a successful revive restores movement/health, and an unrecovered player becomes visibly eliminated instead of appearing healed. Timeout and team-down cases still need Studio validation. AC-08 remains partial and AC-01/AC-02 remain untested.

1. Press **Play** and finish the Library objective until `DataKeys/Key2` is true. Expected: `DataKeys/Key3` is false, and `Workspace/FNABKGraybox/B4` contains `SpareFuse`, `Generator`, and `GeneratorIndicator`.
2. Before collecting Key 2, try the B4 prompts. Expected: both show **Locked** and no B4 state or key changes. After Key 2, use **E** on `SpareFuse`. Expected: feedback says **FUSE COLLECTED**, `B4FuseFound` becomes true, the fuse disappears, and Key 3 remains false.
3. In a fresh Play session after Key 2, use **E** on the Generator before collecting the fuse. Expected: feedback asks you to find the fuse; `B4PowerRestored` and Key 3 remain false.
4. Collect the fuse, then use **E** on the Generator. Expected: feedback says **B4 POWER RESTORED**, `B4PowerRestored` and `DataKeys/Key3` become true, the indicator turns teal, and Output records Key 3 collection.
5. In a fresh Play session, check the top HUD and `ReplicatedStorage/FNABKRoundState`. Expected: the HUD begins at **15:00 | KEYS 0/3 | WAITING/RUNNING**; the round enters Running when a player joins and the timer counts down. Before collecting all three keys, try Gate 1. Expected: it stays closed and reports that all keys are required.
6. Collect all three keys. Stand near `Workspace/FNABKGraybox/Gate1/ControlPanel` with clear line of sight and hold **E** for five seconds. Expected: an early release cancels without opening the gate; a complete hold sets `GateOpened=true`, makes `GateDoor` non-collidable/invisible, and changes the HUD objective to **ENTER THE EXIT**.
7. Walk through the opening onto `ExitWalkway` and into `ExitZone`. Expected: `RoundStatus` becomes `Won`, the HUD says **YOU ESCAPED**, and Output logs the result. A player entering the exit before the timer reaches zero is required. The user reported this escape step passed on 2026-10-28; the other checks below were not reported.
8. In a local test-only edit, temporarily set `GameConfig.roundDurationSeconds` to 8, press Play, and wait for expiry. Expected: `RoundStatus=Lost`, `RoundLossReason=Timeout`, and the HUD says **NIGHT FAILED**. Restore the A01 value of 900 seconds after this test.
9. In a fresh solo Play session, allow the Mimic to land the hit that would reduce HP to zero. Expected: the player is eliminated immediately, `RoundStatus=Lost`, and `RoundLossReason=TeamDowned`; no revive prompt appears.
10. In a Local Server session with two clients, let the Mimic down one player while the other stays alive. Expected: a **DOWNED** label and 20-second countdown appear; the player cannot move or use objectives while downed. Try to revive from beyond six studs or behind a wall, then release E before five seconds; expected: no revive occurs. Move within six studs with clear line of sight and hold **E** for five seconds. Expected: the teammate's revive restores 40 HP, removes the prompt/label, and movement returns.
11. Repeat in a fresh two-client session and do not revive within 20 seconds. Expected: the downed player becomes **ELIMINATED** and cannot interact; the other player can continue. If both players become downed with no active teammate able to revive, expected: `RoundStatus=Lost` and `RoundLossReason=TeamDowned`.

### AC-08 B4 test record
```
Test ID: AC-08 B4 slice
Build commit: Working-tree build; not committed
Tester / date: User / 2026-10-28
Studio mode: Not reported
Steps: User reported completing B4 and collecting Key 3.
Expected: After Key 2, collecting the Spare Fuse and using the Generator grants server-owned DataKeys/Key3.
Actual: User reported that Key 3 was collected successfully.
Result: PASS (user-reported)
Evidence: Chat report; no screenshot or Output log attached.
Bug issue: None reported.
```

### AC-08 Gate escape test record
```
Test ID: AC-08 Gate escape
Build commit: Working-tree build; not committed
Tester / date: User / 2026-10-28
Studio mode: Not reported
Steps: User reported passing Gate 1 and escaping after collecting the keys.
Expected: After all keys, hold E for five seconds at Gate 1, then enter ExitZone before timeout.
Actual: User reported that the escape succeeded.
Result: PASS (user-reported)
Evidence: Chat report; no screenshot or Output log attached.
Bug issue: None reported.
```

AC-08 remains `PARTIAL`; co-op revive is user-reported PASS, while timeout/team-down loss and two-client timer/key/gate sharing still need Studio testing. The Gate escape report does not specify Solo or Local Server mode, so it does not by itself close AC-01 or AC-02.

### AC-08 co-op revive test record (initial user-reported FAIL)
```
Test ID: AC-08 co-op revive
Build commit: Working-tree build; not committed
Tester / date: User / 2026-10-28
Studio mode: Server & Clients, 2 clients (user-reported)
Steps: Client 1 was downed by the Mimic. Client 2 approached to attempt rescue. The 20-second countdown elapsed.
Expected: Client 2 sees the E revive prompt and can hold E for five seconds within six studs and line of sight; otherwise Client 1 becomes eliminated at 1 HP.
Actual: Client 2 did not see the E prompt. After the countdown, Client 1 remained immobile and appeared to regain health.
Result: FAIL (user-reported; fixed and retested below)
Evidence: Chat report; no screenshot or Output log attached.
Bug issue: Revive prompt visibility and incapacitated health regeneration.
```

### AC-08 co-op revive retest (user-reported PASS)
```
Test ID: AC-08 co-op revive retest
Build commit: Working-tree build; not committed
Tester / date: User / 2026-10-28
Studio mode: Server & Clients, 2 clients (user-reported)
Steps: Retested the successful teammate revive and the 20-second bleed-out path after the prompt/health fix.
Expected: Holding E for five seconds within range and line of sight revives the downed player at 40 HP with movement restored; without rescue, the player stays incapacitated at 1 HP and is marked ELIMINATED after 20 seconds.
Actual: User reported that all revive checks passed.
Result: PASS (user-reported; detailed per-step logs not supplied)
Evidence: Chat report; no screenshot or Output log attached.
Bug issue: Initial prompt visibility and health regeneration report retested successfully.
```

## Medkit slice (AC-01, AC-02, AC-09; Studio test partial)

Two fixed pickups are available in A3 and B4. A living player may carry one; the server validates pickup distance and line of sight, and owns inventory and healing. Press **R** to consume a medkit and recover up to 40 HP. At full health or without a medkit, R reports the reason without consuming anything. Downed or eliminated players cannot use one. The HUD shows the local inventory count.

1. In a fresh Play session, find the MEDKIT marker in A3 and press E nearby. Expected: the pickup disappears and the HUD reads `MEDKIT: 1 | R`.
2. With full health, press R. Expected: `HEALTH ALREADY FULL`; the HUD still shows one medkit. Find the B4 medkit and attempt E. Expected: already-carrying feedback, and the second medkit remains in place.
3. Take damage and press R. Expected: health increases by up to 40 without exceeding maximum, the inventory reads zero, and a second R reports `NO MEDKIT`. Pick up the remaining B4 medkit and repeat near full health to confirm the cap.
4. In a two-client session, collect a medkit with Client 1. Expected: it disappears for both clients, but Client 2's inventory remains empty; each player can carry at most one. Check a blocked/distant pickup and a downed player's R request cannot grant or use a medkit.

Studio MCP solo check on 2026-10-31: both pickups appeared; an initial placement overlapped the crate prompt, so the A3 medkit was moved and the test restarted. With the Mimic disabled and the character repositioned during Play, E collected each pickup. At 50 HP, R consumed the item and observed health was approximately 91 (default regeneration also ran); at full health, R retained the item. Setting the downed attribute during Play and pressing R retained the item. An attempted near-full follow-up did not consume the item; its cause was not established. In a fresh session, setting health to 85 and pressing R consumed the item and produced 100 HP. These manipulated solo checks do not establish two-client behavior, normal Mimic damage, or visual feel. Studio Output also reported asset type mismatch for `rbxassetid://203785492`; its source was not established.

## Expanded campus and Marketplace props (AC-01, AC-02, AC-03, AC-06, AC-07, AC-08, AC-09; partial)

The runtime map keeps the 300 x 300 stud A01 schematic and the Gate/A3/Library/B4 mission anchors. Five source-built two-storey shells use classroom windows, story bands and entrance canopies; their role-specific silhouettes include the North Academic Wing clock tower, South Academic Wing Student Commons atrium, Library reading hall and portico, A3 lab vents, and B4 generator vents/stacks. Twenty reconstructions from inspected Creator Store Oak meshes are 3.3–3.4 studs tall and use one full-height block collision proxy each. Three Creator Store benches remain collidable. The raised square-basin fountain has collidable masonry, rim and center column; its water and plaque remain decorative. Tiled routes, gardens, night lighting, signage and 10-stud perimeter walls frame the playable area. The map remains the A01 gameplay schematic, not a geographic campus recreation. AC-01, AC-02, AC-03, AC-06, AC-07, AC-08 and AC-09 remain partial pending human traversal and style review.

Previous Studio checks on 2026-10-31 validated the earlier source version: its 14 trees had 28 SpecialMeshes, route pathfinding reached the mission areas, and the earlier walls blocked raycasts. Those checks do not verify the refreshed facade/tree source. On the current source, `rojo build` succeeded and a fresh Studio Play log showed the map builders starting without a map error. Humanoid MoveTo checks in Play physically stopped at A3, Library and B4 window walls, and the new tree trunk; they passed the A3, Library and B4 door openings and both academic-wing passages. The B4 shell now begins at z=-102 so its facade and door line up with the objective approach; the older B4 divider is inside the shell. These were controlled movement probes, not a natural round or visual approval. Studio's capture returned an obstructed close-up instead of a usable campus overview, so style and lighting still need human review. Natural traversal, multiplayer behavior and target-device performance remain pending. Studio Output still reports the pre-existing asset-type mismatch warning for `203785492` (requesting source not established). Keep the human checks in `docs/MANUAL_CONFIRMATION.md` pending.

Studio MCP validation after the campus facade pass on 2026-10-31, local place `FNABK-AC06-A3-20261028-v2.rbxlx`: `rojo build default.project.json` succeeded and Play Output showed the map services start without a map-generation error. The runtime campus contained 1,245 BaseParts (335 collidable). Direct server-side Humanoid MoveTo probes stopped at an A3 solid wall, its front glass pane, a Library wall and a B4 wall; the A3 door and south academic passage were traversable. Radius-2 PathfindingService returned `Success` for Gate→A3→Library→B4→Gate. The player's position was restored to the Gate spawn. Studio MCP screenshots showed the two matching academic wings, tiled courtyard and night lighting from ground level and overview; human review of style/readability and natural keyboard traversal remains pending. These controlled single-client checks do not establish co-op, target-device frame rate or a full escape run.

### AC-09 night-readability and campus set-dressing follow-up (automated partial)

Studio MCP on 2026-10-31: Rojo build and `git diff --check` succeeded. Play Output showed map startup with no new map-generation error; the pre-existing `rbxassetid://203785492` asset-type warning appeared three times. The current map generated 1,343 BaseParts (335 collidable), including five source-built shells, 20 trees, the raised entrance details, perimeter trim, dressed SightlineDivider and Campus Quad fountain. All four radius-2 PathfindingService legs returned `Success`. A direct Humanoid movement probe aimed through the north perimeter wall stopped at z=-148.39 before its target z=-165; the wall remained collidable at 10 studs high. The fountain and divider dress parts were non-collidable, while a raycast across the SightlineDivider hit the original collidable wall. Ground-level screenshots showed the gate, fountain, north-wing facade and dressed divider; an overview showed the runtime schematic campus. This is automated visual inspection, not human acceptance. Natural player navigation, co-op, style/readability judgment, asset terms before publication and performance on the target PC remain pending in `docs/MANUAL_CONFIRMATION.md`.

### AC-09 Oak asset and night readability follow-up (automated partial)

Studio MCP on 2026-10-31, local place `FNABK-AC06-A3-20261028-v2.rbxlx`: `rojo build default.project.json` and `git diff --check` succeeded. The fresh Play runtime generated 1,610 BaseParts, 340 collidable; 20 Oak trees were rebuilt from inspected Tree4 and Tree5 geometry (six and fourteen respectively) with non-collidable foliage and collidable trunk proxies. The client attributes report calculated mesh heights of about 6.44–6.66 studs. Radius-2 PathfindingService returned `Success` for Gate spawn→A3→Library→B4→Gate. Studio Output showed all map services starting without a new map error; the pre-existing `203785492` asset-type warning appeared three times. Ground-level A3 and campus overview captures confirm the revised lights, trees and shells render, but do not establish player movement, accepted style, co-op or target-device frame rate. AC-01/02/03/06/07/08/09 remain partial or untested as recorded in the table; see flow #8 in `docs/MANUAL_CONFIRMATION.md`.

## 2026-10-31 campus identity and collision update (automated partial; AC-01/AC-02/AC-03/AC-06/AC-07/AC-08/AC-09)

Fresh Studio MCP Play after the source update: 1,781 BaseParts, 347 collidable. Gate→A3→Library→B4→Gate radius-2 paths all returned `Success`. Controlled movement stopped at the full-height Oak tree proxy, square fountain body and Library wall; it passed through the A3, Library and B4 doorway approaches with both Library portico columns collidable. A3 front-glass movement stopped horizontally, though the character climbed vertically during `Humanoid:MoveTo`. Rojo build and `git diff --check` succeeded. Output contained no new map-start error; the pre-existing `rbxassetid://203785492` type-mismatch warning remained. MCP screen capture showed a black 3D viewport, leaving visual quality unreviewed. This is not a human acceptance PASS: natural keyboard traversal, A3 facade climbing, full solo/co-op route, visual style and target-PC performance remain pending in [MANUAL_CONFIRMATION](../MANUAL_CONFIRMATION.md). No place save or publication was performed.


### Campus tree size and natural collision (automated partial)

Studio MCP Play on 2026-10-31, local unpublished place FNABK-AC06-A3-20261028-v2.rbxlx: Rojo generated 1,667 map BaseParts, 347 collidable, and 20 source-rebuilt Small Low Poly Trees (asset 5981037621). Each tree has two SpecialMesh visuals and one 2.90 x 0.55 x 0.55 stud cylindrical collider. The natural keyboard probe into a tree stopped at x=-218.83 before its center at x=-218. The A3 front-glass probe stopped at z=-48.76 before the collidable pane at z=-49.43; the open center doorway remained passable and led inside to z=-58.19. A separate keyboard probe stopped at x=58.38 before the east perimeter wall at x=60. The avatar used collision group Default and CanCollide=true. Output showed all FNABK services starting without a new map error; the existing asset-type mismatch for 203785492 appeared three times. Rojo build and git diff --check succeeded. These are focused single-client tests, not a complete campus traverse or human style acceptance; AC-01/02/03/06/07/08/09 remain as shown in the matrix and flow #8. No place save or publication was performed.
### Optional Marketplace annex and southwest campus link (AC-01/AC-09; automated partial)

Studio MCP Play on 2026-10-31: the free Creator Store model Low-Poly Building (asset 13907146765, Leonii_Dev) passed the source guard as 239 anchored BaseParts with no scripts. At scale 0.9 it measures 41.8 x 38.9 x 25.7 studs and is placed at the southwest edge with a paved approach, entry court, sign, bench and garden bed. Runtime map generation produced 1,954 BaseParts (610 collidable), with zero scripts under the generated map. Radius-2 PathfindingService returned `Success` for the annex approach and all four Gate→A3→Library→B4→Gate legs. Studio character navigation reached the annex court to within 1.14 studs of its requested point. A 2 x 5 x 2 Blockcast from the approach hit an annex part at z=70.37 with `CanCollide=true`; the sign has matching Front and Back labels. This confirms source generation and one automated route in a single-client Play session; it is not human visual/style approval, natural walking around the façade, co-op validation or a performance measurement. The annex model remains a local `ServerStorage` import outside the Rojo project, so a fresh source-only place omits it. The pre-existing warning for asset 203785492 remained; no new map-start error appeared. No place save or publication was performed.

### Current campus assets and collision retest (AC-01/AC-02/AC-03/AC-06/AC-07/AC-08/AC-09; automated partial)

Studio MCP Play on 2026-10-31, local place `FNABK-AC06-A3-20261028-v2.rbxlx`: Rojo generated 1,787 BaseParts (347 collidable), zero scripts under the runtime map, and 20 reconstructed Oak trees from asset 8556375773 using alternating Tree2/Tree4 geometry. Their calculated heights are 2.74 and 2.89 studs; all 140 leaf clusters are non-collidable and all 20 transparent 0.62-stud trunk proxies are collidable. The former southwest residential-looking annex is not cloned (`CampusAnnexIncluded=false`). Radius-2 PathfindingService returned `Success` for spawn→A3→Library→B4→Gate.

Client-side Humanoid `MoveTo` collision probes stopped at the opaque A3 front wall (z=-48.84), Library front wall (z=116.12), B4 front wall (z=-100.70), and Oak trunk proxy (x=-218.92). The same probes passed through the open A3, Library and B4 doorways to z=-54.79, z=108.20 and z=-111.80. The avatar used collision group `Default`, `CanCollide=true`, and had 100 HP. An earlier server-side `MoveTo` probe did not move the client-owned avatar; the recorded movement results above are the repeated Client-side probes. One initial Studio diagnostics snippet also emitted `AssistantCommand:9: attempt to perform arithmetic (add) on table and number`; it was a test-local counter initialization error, not a source/game script, and subsequent map statistics and movement probes succeeded. Startup logs showed all FNABK services; the known `203785492` asset-type warning appeared three times. Ground-level A3, Oak and overview captures show current runtime geometry, but do not establish human visual acceptance. These checks do not cover natural keyboard traversal, full solo/co-op gameplay or FPS. Flow #8/#9 and target-device style review remain pending. No place save or publication was performed.

### AC-09 campus school asset and collision follow-up (automated partial; AC-01/AC-02/AC-03/AC-06/AC-07/AC-08/AC-09)

Studio MCP Play on 2026-10-31 after Rojo sync: the runtime map contained 1,439 BaseParts, 279 collidable, zero scripts, eight Oak tree models at scale 0.06 (about 2.11–2.22 studs tall), and zero tree collision proxies. The South Academic Wing uses the free [White Building 2 asset 7932859944](https://create.roblox.com/store/asset/7932859944) by Karcist: one collidable MeshPart at scale 30, with runtime bounds about 34.7 x 24.1 x 75 studs, centered near (-75, 12.1, 70). Radius-2 PathfindingService returned `Success` for Gate→A3, A3→Library, Library→B4 and B4→Gate. Client Humanoid `MoveTo` probes with AutoJump disabled stopped at opaque A3, Library, B4 and school surfaces; the A3, Library and B4 door approaches remained traversable. The small Oak tree was passable as intended. A first B4 probe at x=-20 hit a collidable window and the avatar rose to y=8.3; the corrected opaque-wall probe at x=3 stopped at z=-100.5. This calls for a human check for climbing/vaulting around windows, recorded in [MANUAL_CONFIRMATION](../MANUAL_CONFIRMATION.md). Overview and player-height captures show the school mesh rendering. Studio Output showed no map-generation error; the existing `203785492` asset-type warning appeared three times. This remains automated partial evidence, not natural keyboard/co-op traversal, human style acceptance or target-device performance. No place save or publication was performed.

### Current campus school and traversal-guard follow-up (automated partial; AC-01/AC-02/AC-03/AC-06/AC-07/AC-08/AC-09)

Studio MCP Play on 2026-10-31 in local unpublished place `FNABK-AC06-A3-20261028-v2.rbxlx`, after the current Rojo sync: build output was 276,195 bytes and `git diff --check` passed. Runtime generation produced 3,177 map BaseParts (2,198 collidable) and zero scripts under the generated map. The West Academic Complex cloned the script-free local import of [School asset 10403432220](https://create.roblox.com/store/asset/10403432220) by LovesCake_09 at scale 0.22, centered at (-185, about 8.57, 90), with bounds about 50.63 x 17.14 x 55.19 studs; all 1,961 BaseParts were anchored and collidable. The South Academic Wing used the collidable one-MeshPart [White Building 2 asset 7932859944](https://create.roblox.com/store/asset/7932859944) at scale 30. Eight trees from Oak asset 8556375773 used scale 0.085 (about 2.99–3.15 studs) and each had a 0.45-stud-wide full-height transparent trunk collider; foliage was non-collidable.

Radius-2 `PathfindingService` returned `Success` on Gate→A3→Library→B4→Gate. Client movement probes stopped at the A3 window pane (around z=-48.71), the Oak trunk (around z=-137.09 before tree center z=-138) and the West school wall (around x=-195.96). Movement passed through the A3 center doorway (to around z=-53.20). A server 2 x 5 x 2 Blockcast from the west approach hit a collidable West school part at distance about 3.53 studs. `TraversalGuard` disabled the client's default `HumanoidStateType.Climbing`; the client probe did not scale the window pane. The overview capture showed the southwest school complex alongside the campus paths and mission buildings. These are controlled single-client checks, not natural keyboard play, a two-client round, human visual approval or a target-PC performance measurement. The older tree and school observations above are historical; current direct user checks remain pending in flows #8–#10 of [MANUAL_CONFIRMATION](../MANUAL_CONFIRMATION.md). Studio was returned to Edit; the place was not saved or published.

### Current campus map and Mimic route retest (automated partial; AC-01/AC-02/AC-03/AC-06/AC-07/AC-08/AC-09)

Studio MCP Play on 2026-10-31, local unpublished place `FNABK-AC06-A3-20261028-v2.rbxlx`, after Rojo sync: the generated map contained 3,255 BaseParts (2,219 collidable) and zero BaseScripts. The SpawnLocation was transparent and non-collidable. The map contains ten Oak reconstructions from asset 8556375773 at scale 0.075 (about 2.64–2.78 studs visible height), each with a 3.2 x 0.7 x 0.7 stud transparent collidable trunk proxy. Three Marketplace school models use two source assets: School 10403432220 for the West Academic Complex, and White Building 2 asset 7932859944 for both the South Academic Wing and North Academic Hall.

PathfindingService with `AgentRadius=2`, `AgentHeight=5`, and jumping disabled returned `Success` for Gate spawn→A3 interior, A3→Library, Library→B4, and B4→Gate. Before the A3 doorway update, the same radius-2 agent returned `NoPath` to the lab interior while a 1.5-radius query succeeded; the A3 entrance was widened from 10 to 16 studs without moving mission anchors. A client keyboard probe on the earlier 10-stud opening walked from z=-47 to z=-66.53, confirming player clearance. A3, Library and B4 interior captures show current graybox furnishing and room shells; they do not establish accepted visual quality.

Studio inspection found 53 MeshParts and no BaseScripts in the approved Oak import. The inspected classroom packs 114248191903321 and 74004694936337 each contain one enabled `Script` and one enabled `LocalScript` despite their listing descriptions; none were run, and neither pack is used at runtime. Startup logs showed all FNABK services ready and only the existing `rbxassetid://203785492` asset-type mismatch warning (three occurrences). `rojo build` and `git diff --check` succeeded. Human review of style, natural walking, Mimic Chase/Search in A3, crate interaction, full solo/co-op route and target-device performance remains pending in flows #8–#10 of [MANUAL_CONFIRMATION](../MANUAL_CONFIRMATION.md). No place save or publication was performed.

## 2026-11-01 detached Phase C architecture refresh (structural review only; AC-01/AC-11)

The source-generated refresh updated the existing `Workspace/FNABK_Campus_PhaseC_Interiors_v6_Walkable` in Studio Edit. The v6 root remained at world origin `(22000, 1000, 6000)` and retained the same 16 gameplay-marker IDs. Its 23 building models now have per-building architecture profiles, 23 name signs, 40 balcony decks, 700 classroom models, and room-specific library/lab/technical/storage variants. Studio Edit audit counted 16,138 BaseParts overall (10,318 collidable), with zero unanchored parts, zero dimensions over 2,048 studs, and zero scripts. The corridor generator adds 293 hall lights and 46 entrance lights. These instance/attribute checks confirm generated structure only; no avatar traversal, human visual acceptance, co-op or FPS test was performed. Flow #13 remains pending, and the local place was not saved or published.

### Phase C architecture revision v8 — structure recorded, visual acceptance pending (AC-01/AC-11)

The v8 source changes the detached campus preview to opaque classroom walls behind walkable exterior galleries, smaller individually punched non-gallery windows and larger per-building roof forms. Studio Edit refreshed the existing v6 root with 23 building Models, 28,137 BaseParts (16,907 collidable), 640 gallery doors, 137 gallery decks/landings, 700 classroom Models, 851 room/lobby Models, zero unanchored parts and zero scripts. The studio screen-capture endpoint returned a black viewport, so do not mark the architecture visually accepted; the user has not confirmed that all buildings now read as different. Complete flow #13 and record player-height observations before changing any acceptance status. No Play test, place save or publication was performed.

### Detached Phase C facade revision (AC-01/AC-11; structural review only)

After the source refinement, Studio Edit reports one v6 root at `(22000, 1000, 6000)`, 23 distinct facade/entry/roof profiles, 16 gameplay markers, 16,645 BaseParts (10,551 collidable), 700 classroom Models, 851 room/lobby Models, 44 balcony decks, 23 fixed-text nameboards and 339 PointLights. All parts are anchored, no script was added and no part exceeds 2,048 studs. B4 has five stacked gallery decks, approximately 220.6 x 4.6 studs each. The latest Rojo build succeeded. This does not establish text readability at normal camera distance, visual approval, avatar traversal, co-op or device frame rate; flow #13 remains for the user/team. The place was not saved or published, and no reference image or asset was uploaded.

### Detached Phase C v5 exterior galleries and distinct school blocks (structural audit only; AC-01/AC-11)

After the user rejected the preceding repetitive glass-bar appearance, the Phase C generator was revised to give all 23 buildings unique structural massing and gallery profiles. Studio Edit reports 27,140 BaseParts (16,907 collidable), 23 unique BuildingForm values, 23 unique MassingFeature values, 23 unique gallery profiles, 640 passable classroom gallery doors, 640 window openings, 124 long gallery decks plus 13 corner landings, 530 PointLights, 700 classroom Models, 851 room/lobby Models and 89 stair-hall Models. The detached preview retains one root and 16 marker Parts; all parts are anchored, with no scripts or oversized parts. `rojo build` succeeded. These are structural checks only. Studio capture returned a blank viewport, so visual acceptance and avatar traversal remain pending in flow #13; no FPS result is claimed. The place was not saved or published.

### B1 U-shaped wing connection correction (structural Edit check; AC-01/AC-11)

In Studio Edit on 2026-11-01, the detached pixel port B1_NorthLink was rotated 90 degrees to align its long axis with the crossbar footprint, then moved 2.25 studs toward the two side wings. No instances were added or removed. The corrected link bounds overlap each wing by about 1.04 studs. At both joins, floor parts from the crossbar and side wing cover the seam sample at all five generated elevations; the central courtyard sample remains outside all three wing bounds. The corresponding source correction is in PixelBuildingPorter.luau. This does not establish visual acceptance or avatar traversal; flow #17 remains pending. Real story counts are not verified and await user input. Studio remained unsaved and unpublished; the runtime map and v6 source were not modified.

## Pixel campus B1 U rebuild v5 (structural Edit audit; AC-01/AC-11)

On 2026-11-02, a fresh detached root, Workspace/FNABK_Campus_PixelBuildings_PhaseC_v5, was built from the current manifest and porter. It contains 23 building Models and 19,034 BaseParts; all parts are anchored, no scripts are included, and GameplayIntegrated=false. B1 contains the WestWing, EastWing and NorthLink, six collidable floor seam connectors and one centered open entrance portal.

The Studio bounds audit compared the actual B1 parts to the traced B1 footprint: WestWing X [2287.100, 2322.750], Z [1569.125, 1689.700]; EastWing X [2391.000, 2427.150], Z [1569.125, 1689.700]; NorthLink X [2287.100, 2427.150], Z [1687.450, 1724.200]. The north crossbar extends inward 2.25 studs to bridge both joins; its outer max-Z edge remains pinned to the footprint. The traced-outline stroke bounds are X [2285.100, 2428.800], Z [1567.400, 1725.700]. The centered entrance is at X 2356.875, Z 1569.825 with a 12-stud clear width and 8.9-stud clear height. A map-south Edit capture shows the U silhouette and the portal at the center of the open edge; user review and avatar traversal remain pending in flow #17.

Detached roots v1-v4 remain preserved in ServerStorage. The place was not saved or published; no assets were uploaded, and the runtime map and gameplay source were not changed.

## B1 single-body U and centered crossbar entrance v6 (structural Edit audit; AC-01/AC-11)

On 2026-11-02, Studio Edit created a new detached review root `Workspace/FNABK_Campus_PixelBuildings_PhaseC_v6` at `(4300, 0, 1200)`, plus an aligned +3100 X outline clone named `Workspace/FNABK_Campus_PixelPreview_v1_B1Review_v6`. The existing v5 root and original outline remain in Workspace and were not moved or replaced. The v6 root contains 23 logical buildings, 19,032 BaseParts, zero unanchored parts, zero scripts, six B1 floor seam connectors, and `GameplayIntegrated=false`.

B1 has one direct child body, `B1_ContinuousBuilding`. The three temporary footprint regions are flattened into that model and no `B1_BuildRegion_*` models remain. The single main entrance is at `(5457.125, 0, 1723.500)`, centered on the connected crossbar's outer edge opposite the U opening. Its clear opening is 12 by 8.9 studs. Three wall segments define the cutout; the 11.8 x 8.84 x 2.4 stud tested doorway prism had no intersecting collidable parts. The courtyard point `(5457, 5, 1629)` lies outside every B1 part.

The viewport capture returned black, so these are hierarchy and geometry checks only. They do not establish visual acceptance or avatar traversal; Flow #17 remains pending. The place was not saved or published. No runtime map or gameplay source was changed and no assets were uploaded.
