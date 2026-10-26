# Codex / AI agent instructions — FNABK

Read `docs/GDD.md`, `docs/ACCEPTANCE.md`, `docs/ARCHITECTURE.md`, and the relevant source paths before editing.

1. **Source authority:** A01 design baseline is authoritative. Do not quietly add/remove required gameplay. Put proposed deviations in `docs/DECISIONS.md` with CR ID.
2. **Small increments:** implement or review one testable subsystem at a time. Cite related AC IDs in descriptions/PRs.
3. **Roblox correctness:** server controls damage, Trust, NPC FSM, missions, Data Keys and timer. Client is input/UI/VFX only; validate RemoteEvent requests on server.
4. **Filesystem:** keep scripts under `src/`, synced by Rojo. Do not assume Studio scene edits auto-save to Git; ask before modifying shared place/models through MCP.
5. **Safe tool use:** no mass modifications, destructive cleanup, external asset imports, dependency installs, code execution in Studio or publication without explicit user direction.
6. **Performance:** target Intel Iris Xe and low-poly environments. Profile before optimizing; 30 FPS is a goal, not a measured claim.
7. **Testing:** include concrete manual Roblox Studio test steps and expected results for each change. Never assert tests passed unless executed.
8. **Academic integrity:** explain nontrivial Luau/algorithms and document AI help. The student team owns final work and must be able to defend it.
9. **Reviewability:** source changes, tests, expected behavior, limitations and Git history. Avoid huge generated monoliths.
10. **Design-language:** user-facing GDD and engineering docs in English. Game UI copy can be localized later with documented keys.

**First implementation milestone:** graybox area + one Mimic with a traceable Chase/Search state transition, then validated baton combat; don't build the entire game in one pass.
