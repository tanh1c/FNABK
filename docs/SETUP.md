# Team setup — Windows, Roblox Studio and MCP

This is an incomplete survival prototype. Read the [implementation tracker](IMPLEMENTATION_PLAN.md) and [acceptance criteria](ACCEPTANCE.md) before claiming a feature works. The current campus and asset libraries live in a Studio place, not in this repository.

## 1. Get access and tools

1. Ask the GitHub repository owner for access to `https://github.com/tanh1c/FNABK` and the project owner for the current Studio place. Repository access alone does not give Roblox edit permission or the campus map.
2. Install [Git](https://git-scm.com/install/), [Roblox Studio](https://create.roblox.com/docs/studio/setup), and [Rokit](https://github.com/rojo-rbx/rokit). Sign in to Roblox Studio. VS Code and Codex are optional.
3. In PowerShell:

```powershell
git clone https://github.com/tanh1c/FNABK.git
cd FNABK
rokit install
rojo --version
rojo plugin install
```

`rokit.toml` pins Rojo 7.7.1. Restart the terminal if `rojo` is not found. The plugin and CLI should use matching versions; see [Rojo installation](https://rojo.space/docs/v7/getting-started/installation/).

## 2. Get the campus and run a local copy

The owner can either share the current `.rbxl` privately or grant edit access to a shared Roblox experience. Ask the owner to save the latest place in Studio first; this repository intentionally excludes `build/` and root `.rbxl`/`.rbxlx` files. The owner's last known local file is `build/Final_Version_HCMUT_MAP.rbxl`, but the owner must confirm that it contains their latest saved work. Never commit or publish the place without team approval.

1. Open the supplied `.rbxl` in Studio and immediately save a separate local copy. Alternatively, open the team's shared experience and create a separate local test copy. Keep the original intact.
2. In Explorer, verify `Workspace/FNABK_Campus_PixelBuildings_PhaseC_v6` exists. The place also needs the team's `ServerStorage` asset libraries and animation permissions for the intended visuals. A map without them can run with missing visuals, sounds or animations; ask the owner for the full current place and access.
3. From the repository root, start:

```powershell
rojo serve default.project.json
```

4. In Studio, open the Rojo plugin and connect to `localhost:34872`. **Review the proposed changes before accepting.** Rojo manages the mapped script folders in `default.project.json`; it can replace or remove instances inside mapped folders. Do not accept changes that remove the campus, asset libraries or other work. Disconnect and ask the team if the preview is unexpected. Only one developer should sync scripts to a shared place at a time; use personal test copies for development.
5. Press **Play**. Look in Studio Output for errors. The server expects the campus model above; an error saying `Selected campus v6 is missing from Workspace` means the wrong or incomplete place is open.

For a basic prototype check, try moving, opening inventory with **B**, opening the objective map with **M**, collecting supplies and approaching a Mimic. Full runs, co-op and persistence are not confirmed; follow the relevant manual scenarios in [plans/](plans/).

The current source includes an unfinished wave-participant eligibility change in `src/server/WaveService.luau` and `tests/WaveEligibility.check.luau`: it built locally but has not been synced to the owner's Studio place or playtested. Treat it as work in progress when syncing or demoing.

### Build is a source check, not the map

```powershell
rojo build default.project.json -o build/FNABK-scripts-only.rbxlx
```

This validates that Rojo can construct the mapped source tree. The generated place does not include the campus model or the Studio asset libraries; opening it and pressing Play is expected to fail the campus assertion. Do not use it to replace the team's map.

## 3. Sync code and scene as a team

- **Code:** edit files under `src/`, use Git branches and review, then pull the agreed commit and sync it into a local Studio copy with Rojo. Rojo is not a substitute for Git and Studio-only source edits do not automatically appear in the repository.
- **Campus and assets:** use a shared Roblox experience with [Team Create](https://create.roblox.com/docs/projects/collaboration), or exchange a named `.rbxl` snapshot privately. A local `.rbxl` is a copy: edits are not automatically shared. Team Create changes live in Roblox's cloud, not automatically in Git.
- For a shared experience, its owner must publish the chosen local place to the intended experience and grant **Edit** permission. Roblox may impose collaboration eligibility restrictions. Coordinate who edits scene objects and who syncs Rojo, keep backups, and use Studio/Creator Hub version history. Publishing and granting permissions require the owner's explicit action and authorization.
- Asset and animation access may depend on their creator/experience permissions. Check in a teammate's Studio session; an ID being visible in one user's inventory does not guarantee that it runs for another experience. Follow [AGENTS.md](../AGENTS.md) before importing or uploading anything.

## 4. Optional: connect Codex to Roblox Studio MCP

Each developer connects **their own running Studio** to their own trusted Codex client. MCP is for inspecting and editing Studio through an assistant; it does not transfer the map or replace Rojo/Git.

1. Install [Codex CLI](https://developers.openai.com/codex/cli/) or a supported Codex client and sign in. Open the intended place in Studio.
2. In Studio, open **Assistant → … → Manage MCP Servers** and enable **Studio as MCP server**. Under **Quick connect**, enable **Codex CLI**. If it is missing, install Codex and restart Studio. For other clients, follow the setup shown in Studio and the [official MCP guide](https://create.roblox.com/docs/studio/mcp).
3. Restart the Codex client, run `codex mcp list`, and verify that Roblox Studio is listed. The Studio MCP settings show a green connection indicator when a client is connected. Ask the assistant to list connected Studio instances and confirm the intended place before changes.
4. Start with a read-only request: “Inspect the open place and describe its hierarchy; do not edit, upload, publish or execute code.” Follow [AGENTS.md](../AGENTS.md): code execution, scene changes and asset operations require the appropriate explicit authorization. Never commit credentials or local MCP configuration.

## Troubleshooting

- **Missing campus assertion:** open the owner's current map; `rojo build` produces only the mapped source tree.
- **Rojo cannot connect:** start `rojo serve` in the project folder, check the plugin and local port 34872, and verify matching versions.
- **Unexpected Rojo deletions:** cancel the preview, disconnect, and inspect the map and mapped paths with the team. Do not accept a destructive sync to the shared place.
- **Missing model, sound or animation:** check the place's asset libraries and the experience's permissions with the owner; do not assume a Marketplace inventory entry grants every experience access.
- **MCP not listed:** enable Studio MCP, restart Studio and the client, and follow the [official troubleshooting](https://create.roblox.com/docs/studio/mcp). MCP access is local to each developer.
