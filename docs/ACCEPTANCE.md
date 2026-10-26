# A01-to-A02 acceptance matrix

This file tracks **committed MVP tests**, not completed work. Record `PASS/FAIL/BLOCKED` and evidence URLs only after executing a test in Studio.

| ID | Requirement | Verification evidence | Current |
|---|---|---|---|
| AC-01 | Solo round reaches Good Ending without soft-lock | Video + solo playtest log | NOT TESTED |
| AC-02 | Two clients share timer, Keys, gate state | 2-client Studio log | NOT TESTED |
| AC-03 | Mimic transitions through Disguise, Suspicious, Chase, Attack, Search, Stunned, Defeated | FSM debug state trace | NOT TESTED |
| AC-04 | Baton deals server-validated Mimic damage; normal NPC not defeated; wrongful hit costs Trust | Hit/validation cases | NOT TESTED |
| AC-05 | Scanner and UV enforce range/LOS/cooldowns; UV stops enemy for 2.2s | Negative and positive tests | NOT TESTED |
| AC-06 | A3 physical crate activates pressure plate; out-of-bounds crate resets | Physics playtest | NOT TESTED |
| AC-07 | Library Mimic investigation solo-completable, yields Key 2 | Mission playtest | NOT TESTED |
| AC-08 | B4 generator + 3 keys + gate hold, win and timeout/loss states | End-to-end test | NOT TESTED |
| AC-09 | Menu, HUD, accessible settings, audio, result screens | UI walkthrough | NOT TESTED |
| AC-10 | Blue Professor cameo dialogue works but never blocks progress | NPC interaction test | NOT TESTED |
| AC-11 | Playable place, setup README, source Git history, credits, and playtest report delivered | Submission audit | NOT TESTED |

**Security gates:** rejected spoofed attacks, distant targets, cooldown bypass and client-supplied damage. **Performance gate:** FPS on specified hardware is a target to measure, not proof of success.

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
