# Team setup — Windows / Roblox Studio / Codex CLI

## Prerequisites
Install Git, Roblox Studio, VS Code (optional), and [Rokit](https://github.com/rojo-rbx/rokit). Codex CLI is optional for human contributors but supported for assistance. Each team member should have GitHub access to `tanh1c/FNABK` and Roblox experience edit permission supplied by the experience owner.

## Clone and pin tooling
```powershell
git clone https://github.com/tanh1c/FNABK.git
cd FNABK
rokit install
rojo --version
rojo plugin install
rojo build default.project.json -o build/FNABK.rbxlx
rojo serve default.project.json
```
Use the Rojo plugin in Studio to connect to the running server (typically http://localhost:34872), not GitHub itself. Plugin and CLI versions should match. If a Rojo plugin installation/CLI command differs for a new release, follow the official [Rojo docs](https://rojo.space/docs/v7/getting-started/installation/) rather than guessing flags.

## Open place
Open `build/FNABK.rbxlx` in Roblox Studio. Check `ReplicatedStorage/FNABKShared`, `ServerScriptService/FNABKServer`, and `StarterPlayer/StarterPlayerScripts/FNABKClient`. Press Play to see the default starter place; no actual horror gameplay is implemented yet.

## Share with team
The Roblox experience **owner** must create/publish a collaborative experience and grant group members Studio edit access through Roblox's collaboration controls. Publish/place IDs are not embedded in the repo; never commit authentication cookies, keys or personal tokens. Agree on scene/model ownership to prevent simultaneous editing conflicts. Script changes flow through Git PRs and Rojo.

## Codex CLI + Studio MCP
```powershell
npm install -g @openai/codex
codex
```
In Studio open **Assistant → … → Manage MCP Servers**, enable Studio MCP and use **Quick connect → Codex CLI**. Confirm `codex mcp list` and check tools in the Codex session. This connection is per developer machine; do not commit local MCP credentials. See [Roblox MCP documentation](https://create.roblox.com/docs/studio/mcp).

First safe prompt: “Inspect the open Studio hierarchy and the repository design docs. Do not modify anything. Recommend one testable MVP subsystem with acceptance criteria and review steps.”

## Troubleshooting
- `rojo` not found: run `rokit install` and reopen terminal; verify PATH and Rokit setup.
- Port in use: close previous `rojo serve` or select supported port per Rojo CLI.
- Plugin cannot connect: check `rojo serve` is running, then reconnect inside Studio.
- Client sees no changes: check `default.project.json` mappings and Rojo sync direction.
- MCP tools missing: enable Studio MCP and reconnect Codex on the same OS user session.
- Graphics slow on Iris Xe: avoid full map/expensive dynamic shadows; benchmark FPS in Studio before broadening scope.
