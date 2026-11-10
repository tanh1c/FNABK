# FNABK survival implementation tracker

Baseline: [GDD](GDD.md), [acceptance criteria](ACCEPTANCE.md), [architecture](ARCHITECTURE.md). The campus and existing A01 implementation are a prototype; the 15-minute round, three keys, and older life rules do not satisfy the survival GDD. This is an engineering plan, not student-team or course approval.

## Workflow and definition of done

For each checklist item: write an executable check or a concrete multiplayer Studio scenario first; observe the failure when feasible; implement the smallest slice; run the check and relevant regression; record date, environment, expected and observed results. Mark `[x]` only when the described behavior and its stated tests actually pass. A core-only test does not complete a gameplay criterion. Record GDD deviations under a CR ID in DECISIONS. Server owns state and validates client intent. Never publish or upload assets without specific authorization.

| Sub-plan | Dependencies | Status | Criteria |
|---|---|---|---|
| [01 Inventory and needs](plans/01-inventory-needs.md) | none | In progress | SURV-05, SURV-08, SURV-10 |
| [02 Life and combat](plans/02-life-combat.md) | inventory | In progress | SURV-06–09 |
| [03 Time, base and waves](plans/03-time-base-waves.md) | inventory, life | In progress | SURV-02–05, SURV-07 |
| [04 Rescue and NPCs](plans/04-rescue-npcs.md) | time, base, life | In progress | SURV-01, SURV-06–07, SURV-11, SURV-13 |
| [05 Sessions and release](plans/05-sessions-release.md) | all gameplay slices | In progress | SURV-01, SURV-09–12 |

## Release checklist

- [ ] Complete solo rescue and defeat runs.
- [ ] Complete 2- and 4-player runs, concurrency and reconnect cases.
- [ ] Record evidence and unresolved failures for every SURV criterion.
- [ ] Review cues, UI legibility, audio permissions and accessibility.
- [ ] Measure representative target-hardware performance; 30 FPS is a goal until measured.
- [ ] Student team reviews code, AI assistance, GDD deviations, assets and deliverable.

Studio campus geometry and asset libraries are not in a Rojo source build; save the place separately. Preserve unrelated changes.
