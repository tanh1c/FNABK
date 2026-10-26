# Five Nights at Bách Khoa (FNABK)

> **CO3045 — Game Programming | CC02 | Group 07 | HK261**

A 3D low-poly cooperative survival horror project built with **Roblox Studio + Luau**. Players explore a fictionalized HCMUT campus at night, identify hostile Mimics, solve three objectives, and escape before 06:00.

**Project stage:** pre-production / A01 design baseline. The repository contains a Rojo-compatible **development scaffold**, not a finished playable game.

## Read first

- **[Game Design Document](docs/GDD.md)** — authoritative, implementation-oriented A01 specification.
- **[Acceptance criteria](docs/ACCEPTANCE.md)** — AC-01 through AC-11 and test evidence.
- **[Roblox architecture](docs/ARCHITECTURE.md)** — server authority, code/data ownership, sync boundaries.
- **[Windows + Studio setup](docs/SETUP.md)** — clone, Rokit/Rojo, local Studio connection, Codex MCP.
- **[Development workflow](docs/WORKFLOW.md)** — branches, PRs, team collaboration, scene ownership.
- **[AI coding rules](AGENTS.md)** — mandatory guidance for Codex and other coding agents.
- **[Decisions / deviations](docs/DECISIONS.md)** — design baseline and change requests.

## Local bootstrap (Windows PowerShell)

```powershell
git clone https://github.com/tanh1c/FNABK.git
cd FNABK
rokit install
rojo plugin install
rojo build default.project.json -o build/FNABK.rbxlx
rojo serve default.project.json
```

Open `build/FNABK.rbxlx` in Roblox Studio, launch the **Rojo Studio plugin**, then connect to the local Rojo server. You must install [Rokit](https://github.com/rojo-rbx/rokit), [Roblox Studio](https://create.roblox.com/docs/studio/setup), and git first.

Studio is not available in GitHub Actions. The current CI checks repository structure and GDD traceability; an actual Studio playtest is required for gameplay verification.

## Team

| Member | Student ID | Planned workstream |
|---|---|---|
| Vũ Hải Tuấn | 2353280 | Gameplay, combat/physics, integration |
| Chu Nguyễn Tuấn Anh | 2352022 | Mimic AI, multiplayer, server tests |
| Lê Hoàng Chí Vĩ | 2353336 | Level design, GDD, UI/audio, QA |

Instructor: **Phan Trần Minh Khuê**.

## Design / integrity notice

The game uses fictional NPCs and a fictionalized campus inspired by HCMUT. Concept art in the original A01 LaTeX document is AI-generated and **not a gameplay screenshot**. This Git repository is a student development workspace. Developers must understand and review any AI-assisted contributions, disclose their actual use, and credit external assets. A01 numbers are proposed, not measured.
