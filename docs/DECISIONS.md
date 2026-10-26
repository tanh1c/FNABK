# Design decisions and change log

**A01 approved naming:** Five Nights at Bách Khoa. **Baseline:** one-night 900-second round, solo/2 player, three Data Keys, A3/Library/B4, one Mimic FSM, baton/UV/scanner, Trust, Blue Professor nonblocking dialogue. These are design commitments, not completed features.

| ID | Decision | Reason |
|---|---|---|
| D01 | Single night (900s) | Contain implementation scope |
| D02 | 1–2 players | Solo completeness + networking test |
| D03 | Baton + UV + scanner, no firearm | Evidence and defensive gameplay |
| D04 | A3 → Library → B4, then Gate 1 | Progressive tutorials/objectives |
| D05 | Innocent NPCs not defeatable; -20 Trust wrongful hit | Combat tradeoffs |
| D06 | Stylized low-poly non-graphic horror | Readable atmosphere on integrated GPU |
| D07 | Blue Professor dialogue cameo MVP, penalty minigame optional | Bounded humorous Easter egg |

## Change request template
```markdown
### CR-XXX: Short title
- Date / owner / reviewer:
- Current baseline and AC IDs:
- Proposed modification:
- Rationale and player experience impact:
- Development effort / risks:
- Validation evidence:
- Approval decision:
```
