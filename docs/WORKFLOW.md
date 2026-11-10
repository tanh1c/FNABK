# Team workflow and collaboration

## Git and PR rules
- `docs/GDD.md` records the user-selected survival design; review and course approval are not implied. Source can lag behind the design and must be described by actual test evidence.
- Use branches such as `feat/ai-mimic-fsm`, `feat/combat-baton`, `feat/level-graybox`, `docs/gdd-change-cr-001`.
- One subsystem per PR; describe goal, changed paths, AC IDs, Studio test evidence, and rollback plan.
- Do not commit `build/`, `.rbxl` backups, temporary Studio files, tokens or local MCP configuration.
- Review ownership: gameplay/physics Vũ Hải Tuấn; AI/network Chu Nguyễn Tuấn Anh; level/UI/docs Lê Hoàng Chí Vĩ. These are planned workstreams, not automatic assignment or claims of actual contribution.
- GitHub branch-protection and repo collaborator permissions must be configured manually by the repo owner.

## Sync model
Git is the source of truth for **Luau code and documentation**. Rojo pushes the mapped folders into a Studio place; review its proposed changes before accepting them. The current campus and ServerStorage asset libraries are not tracked in this repo, and a source-only `rojo build` does not contain them.

For scene work, use a shared Roblox experience with Team Create or exchange explicit `.rbxl` snapshots. The owner must publish the chosen place and grant each collaborator Edit access; a Git push neither publishes the place nor grants Roblox permissions. Team Create scene edits do not automatically update Git. Keep a backup and use one designated script sync operator for the shared experience; developers should use personal local test copies while iterating. Coordinate map changes and record which place version matches a Git commit. See [setup](SETUP.md).

## Definition of Done
- AC links included, no silent GDD scope drift.
- Security-sensitive systems validated on the server.
- Solo and relevant 2- and 4-client tests run in Studio where relevant; record any untested configuration.
- Reviewer verifies change behavior; README/CHANGELOG/asset credits updated if affected.
- Any AI assistance acknowledged in PR and understood by student author.

## Scope change process
Record changes to the current GDD in `DECISIONS.md`, justify the tradeoff and link relevant test evidence. CR-014 records the transition from the archived A01 design; do not claim student-team or instructor approval without evidence. Optional features never count toward minimum acceptance.
