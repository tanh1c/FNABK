# Codex / AI agent instructions — FNABK

Read `docs/GDD.md`, `docs/ACCEPTANCE.md`, `docs/ARCHITECTURE.md`, and the relevant source paths before editing.

1. **Source authority:** `docs/GDD.md` is the current user-selected survival design; `docs/archive/A01_GDD.md` preserves the prior A01 design. Do not quietly add/remove required gameplay. Record deviations in `docs/DECISIONS.md` with a CR ID, and do not claim student-team or course approval without evidence.
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

## Roblox Asset Upload Safety Policy

**Default policy: NO ASSET UPLOADS.** This policy applies to every agent, script, plugin, MCP integration, and automated workflow used for FNABK.

1. Never upload images, screenshots, reference maps, textures, decals, thumbnails, meshes, audio, or any other asset to Roblox without the user's explicit approval for that specific upload.
2. Never use Roblox Studio Assistant, Studio MCP tools, Asset Manager, Roblox Open Cloud APIs, HTTP requests, plugins, or another mechanism to upload reference materials automatically.
3. Never upload an image to Roblox so an AI model can inspect it, understand it, reconstruct it, or generate geometry from it.
4. Keep reference images local. They may be inspected and analyzed locally, but must not be transmitted to Roblox services or turned into Roblox asset IDs.
5. For the HCMUT campus, prefer native Roblox geometry: Parts, WedgeParts, Models, CFrames, and procedural Luau generation scripts. Generate geometry directly instead of uploading the reference image.
6. If a tool might upload files, generate cloud-hosted assets, create asset IDs, or publish content as a side effect, do not call it until the exact operation has been explained and the user has explicitly approved it.
7. Do not publish or update Roblox experiences, places, models, or assets without explicit approval.
8. Before any external asset import, inspect it for URLs, QR codes, social-media links, personal information, and potentially restricted content. Inspection does not grant upload permission.
9. Do not evade Roblox moderation or repeatedly reupload previously moderated content. A prior HCMUT campus reference-image upload was moderated for “Directing Users Off-Platform” (asset ID `99414320491769`); never reupload or attempt to work around that moderation result.
10. Preserve existing map geometry, gameplay scripts, and project files. Do not overwrite or delete existing assets without approval.
11. If a task cannot be completed without uploading to Roblox, stop that operation and ask the user for permission. Offer a local-only alternative whenever possible.
12. Unknown or ambiguous tool side effects must be treated as upload-capable: do not call the tool until its behavior is clear and, if needed, the user explicitly approves the exact operation.

### Safe local workflow

- Reference files stay on the local filesystem.
- Use local Luau source and native geometry in the local Studio place for previews.
- Do not use asset-upload, cloud-generation, or publishing tools as a substitute for local geometry generation.
- Do not delete an existing generated model as part of a rebuild. Use a new output name or ask the user before replacing it.
