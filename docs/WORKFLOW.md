# Team workflow and collaboration

## Git and PR rules
- `main` contains the approved GDD baseline and reviewed working source.
- Use branches such as `feat/ai-mimic-fsm`, `feat/combat-baton`, `feat/level-graybox`, `docs/gdd-change-cr-001`.
- One subsystem per PR; describe goal, changed paths, AC IDs, Studio test evidence, and rollback plan.
- Do not commit `build/`, `.rbxl` backups, temporary Studio files, tokens or local MCP configuration.
- Review ownership: gameplay/physics Vũ Hải Tuấn; AI/network Chu Nguyễn Tuấn Anh; level/UI/docs Lê Hoàng Chí Vĩ. These are planned workstreams, not automatic assignment or claims of actual contribution.
- GitHub branch-protection and repo collaborator permissions must be configured manually by the repo owner.

## Sync model
Git is source of truth for **Luau code and documentation**. Rojo pushes mapped files into Studio. Keep Studio-only map edits in separate reviewed `.rbxm` models or a committed place snapshot with clear ownership; do not assume ordinary Studio edits automatically sync back to Git.

## Definition of Done
- AC links included, no silent GDD scope drift.
- Security-sensitive systems validated on the server.
- Solo + two-client tests run in Studio where relevant.
- Reviewer verifies change behavior; README/CHANGELOG/asset credits updated if affected.
- Any AI assistance acknowledged in PR and understood by student author.

## Scope change process
Before deviating from an A01 MVP item, create a design-change entry in `DECISIONS.md`, justify the tradeoff and link relevant test evidence. OPTIONAL features never count toward minimum acceptance.
