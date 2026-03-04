# antigravity-gsd

GSD (Get Shit Done) structured project planning, adapted for Antigravity.

GSD is a meta-prompting, context engineering, and spec-driven development system
originally built for Claude Code. This project ports its core methodology —
structured questioning, roadmap management, atomic XML task plans, and
goal-backward verification — into Antigravity's workflow system.

## What You Get

- `/gsd:new-project` — Deep questioning → PROJECT.md → REQUIREMENTS.md →
  ROADMAP.md → STATE.md
- `/gsd:discuss-phase [N]` — Capture design decisions before planning a phase
- `/gsd:plan-phase [N]` — Create atomic XML task plans from roadmap + research
- `/gsd:execute-phase [N]` — Execute all plans in a phase with verification
- `/gsd:verify-work [N]` — Human UAT walkthrough with gap diagnosis
- `/gsd:quick [task]` — Ad-hoc tasks with GSD guarantees (no full planning
  needed)
- `/gsd:progress` — Current project status dashboard
- `/gsd:map-codebase` — Analyse an existing codebase before initialising a
  project

All planning artifacts live in `.planning/` inside your project — the same
structure GSD uses in Gemini CLI and Claude Code, so files are compatible across
all three.

## Documentation

| Doc                                                                             | Description                               |
| ------------------------------------------------------------------------------- | ----------------------------------------- |
| [What is GSD](docs/gsd-overview.md)                                             | GSD's design philosophy and core concepts |
| [Gemini CLI / Claude Code implementation](docs/gemini-claude-implementation.md) | How GSD works in its native environments  |
| [How Antigravity differs](docs/antigravity-differences.md)                      | Architectural differences and tradeoffs   |
| [The Antigravity adaptation](docs/adaptation.md)                                | How this port works technically           |
| [User guide](docs/user-guide.md)                                                | How to use it — workflow, commands, tips  |

## Installation

Antigravity `/slash-commands` require workflow files to exist within **each
project's specific workspace** (`.agents/workflows/`). To keep this fully synced
and painless, we use a single global installation and a workspace setup tool.

### 1. Global Install

Run this one-liner in your terminal to clone the repo, install the workspace
helper, and update your global Antigravity instructions:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zbigniew-malinowski/antigravity-gsd/main/scripts/install-global.sh)"
```

_Note: This will install the repo to `~/.gemini/antigravity-gsd`, link an
executable to `~/.local/bin/antigravity-gsd-init`, and update your
`~/.gemini/GEMINI.md`._

### 2. Getting Started in a Project

In any project where you want to use GSD, just open Antigravity and say:

> **"Let's start a GSD project"**

Because of the global installation, Antigravity knows to automatically run
`antigravity-gsd-init` in the terminal to construct the `.agents/workflows/`
symlinks.

Then it will tell you to run `/gsd:new-project`.

_(Alternatively, you can just manually run `antigravity-gsd-init` in your
terminal and reload your Antigravity window to expose the `/gsd:*` commands)._

## Keeping Up with GSD Updates

When GSD ships a new version:

```bash
./scripts/sync-gsd.sh
```

This compares the installed GSD version against what these workflows were built
from, diffs the upstream workflow files, and shows you what changed so you can
decide what to adopt.

## Reverting

```bash
~/.gemini/antigravity-gsd/scripts/uninstall.sh
```

Removes the global repo, the `antigravity-gsd-init` tool, and clears the
GEMINI.md additions. Does not touch your existing Gemini CLI GSD commands or any
`.planning/` directories inside your projects. The local `.agents/workflows`
symlinks will remain but safely point nowhere.

## Project Structure

```
antigravity-gsd/
├── README.md
├── docs/
│   ├── gsd-overview.md               # What is GSD
│   ├── gemini-claude-implementation.md # Native GSD implementation
│   ├── antigravity-differences.md    # Architectural comparison
│   ├── adaptation.md                 # How this port works
│   └── user-guide.md                 # How to use it
├── workflows/                        # Antigravity workflow files (symlinked to local .agents/workflows/)
│   ├── gsd-new-project.md
│   ├── gsd-discuss-phase.md
│   ├── gsd-plan-phase.md
│   ├── gsd-execute-phase.md
│   ├── gsd-verify-work.md
│   ├── gsd-quick.md
│   ├── gsd-progress.md
│   └── gsd-map-codebase.md
└── scripts/
    ├── install-global.sh             # Global installer (curl target)
    ├── init-workspace.sh             # Workspace setup tool (symlinked to PATH)
    ├── uninstall.sh                  # Revert global installation
    └── sync-gsd.sh                   # Check for GSD updates and show diffs
```
