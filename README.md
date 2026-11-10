# Five Nights at Bách Khoa (FNABK)

> **CO3045 — Game Programming | CC02 | Group 07 | HK261**

A 3D low-poly survival horror project built with **Roblox Studio + Luau**. The current design is a five-day campus survival run for 1–4 players: choose and upgrade a campus building, gather supplies, face Mimics and other experimental threats, and signal a rescue helicopter.

**Project stage:** an unfinished survival prototype with an in-progress campus, inventory, combat, waves and rescue systems. The full five-day run, persistence and multiplayer are not verified. See the [implementation tracker](docs/IMPLEMENTATION_PLAN.md) for the current scope and evidence.

**Map required:** this repository contains source code, not the team's current Studio campus or its stored asset libraries. Obtain the place from the owner, then follow [setup](docs/SETUP.md). A place produced by `rojo build` contains scripts but does **not** contain the campus; it is not a playable replacement for the shared map.

## Read first

- **[Game Design Document](docs/GDD.md)** — current consolidated survival design; proposed values are marked.
- **[Acceptance criteria](docs/ACCEPTANCE.md)** — SURV-01 through SURV-13; all new-design tests pending.
- **[Old A01 GDD](docs/archive/A01_GDD.md)** and **[A01 test history](docs/archive/A01_ACCEPTANCE.md)** — previous design and evidence.
- **[Roblox architecture](docs/ARCHITECTURE.md)** — server authority, code/data ownership, sync boundaries.
- **[Windows + Studio setup](docs/SETUP.md)** — clone, Rokit/Rojo, local Studio connection, Codex MCP.
- **[Development workflow](docs/WORKFLOW.md)** — branches, PRs, team collaboration, scene ownership.
- **[AI coding rules](AGENTS.md)** — mandatory guidance for Codex and other coding agents.
- **[AI assistance record](docs/AI_ASSISTANCE.md)** — scope of this prototype assistance and review notes.
- **[Decisions / deviations](docs/DECISIONS.md)** — design baseline and change requests.

## Get started (Windows PowerShell)

```powershell
git clone https://github.com/tanh1c/FNABK.git
cd FNABK
rokit install
rojo plugin install
rojo serve default.project.json
```

Install [Git](https://git-scm.com/install/), [Rokit](https://github.com/rojo-rbx/rokit), and [Roblox Studio](https://create.roblox.com/docs/studio/setup) first. Open a **local copy** of the team's map, connect the Rojo Studio plugin to `localhost:34872`, review the proposed changes, and press Play. Follow [setup](docs/SETUP.md) for the exact safe sync workflow and optional Studio MCP connection. Do not run Rojo against the shared place without coordinating with the team.

Studio is not available in GitHub Actions. The current CI checks repository structure and GDD traceability; an actual Studio playtest is required for gameplay verification.

## Team

| Member | Student ID | Planned workstream |
|---|---|---|
| Vũ Hải Tuấn | 2353280 | Gameplay, combat/physics, integration |
| Chu Nguyễn Tuấn Anh | 2352022 | Mimic AI, multiplayer, server tests |
| Lê Hoàng Chí Vĩ | 2353336 | Level design, GDD, UI/audio, QA |

Instructor: **Phan Trần Minh Khuê**.

## Design / integrity notice

The game uses fictional NPCs and a fictionalized campus inspired by HCMUT. Concept art in the original A01 LaTeX document is AI-generated and **not a gameplay screenshot**. The team must understand and review AI assistance and credit external assets. New-design numbers and wave schedules are proposals, not measurements; student-team and course review of CR-014 remain pending.
