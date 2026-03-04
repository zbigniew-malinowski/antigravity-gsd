# User Guide

This guide covers everything you need to use GSD through Antigravity.

## Prerequisites

1. Run the global installer (see the main README `curl` command).
2. Open Antigravity in your project directory (with an existing git repo, or one
   you're happy to `git init`).
3. Say: **"Let's start a GSD project"** to initialize the workspace
   `slash-commands`.

---

## Starting a New Project

Open Antigravity in your project directory and run:

```
/gsd:new-project
```

Antigravity will:

1. Ask "What do you want to build?" — answer freely, then follow the thread
2. Ask about planning depth (Quick / Standard / Comprehensive) and whether to
   commit planning docs to git
3. Optionally research the domain (recommended for unfamiliar stacks)
4. Present features by category — you pick what's in scope for v1
5. Create a roadmap with phases, show it, and ask for approval
6. Write all files to `.planning/`

**Output:**

```
.planning/
├── PROJECT.md
├── REQUIREMENTS.md
├── ROADMAP.md
├── STATE.md
└── config.json
```

**Then:** Open a new chat, run `/gsd:progress` to see your roadmap.

### Skipping Interactive Setup (`--auto`)

If you already have a Product Requirements Document (PRD) or a very clear idea
of what you want to build, you can skip the interactive questioning:

1. Attach your document to the chat (using the `@` menu or drag-and-drop).
2. Run: `/gsd:new-project --auto Use the attached PRD to generate a roadmap`

Antigravity will skip questioning, use sensible default preferences (Standard
depth, commit docs, auto-verify), read your attached document, and immediately
generate the `PROJECT.md`, `REQUIREMENTS.md`, and `ROADMAP.md` files.

---

## The Phase Loop

For each phase, repeat this loop:

### Step 1 — Discuss (optional but recommended)

```
/gsd:discuss-phase 1
```

Captures your design preferences _before_ planning. Antigravity analyses the
phase, identifies ambiguous areas (layout decisions, API behaviour, output
format, etc.), and asks targeted questions. The output — `CONTEXT.md` — tells
the planner what decisions are already locked so it doesn't second-guess them.

Skip this if you're happy with the AI making sensible defaults.

### Step 2 — Plan

```
/gsd:plan-phase 1
```

Antigravity:

1. Reads ROADMAP + REQUIREMENTS + CONTEXT.md
2. Researches the technical domain (reads codebase, optionally searches web)
3. Creates 2-5 atomic PLAN.md files with XML tasks, dependencies, and
   `must_haves`
4. Self-checks plans against the phase goal

**Output:** `.planning/phases/01-name/01-01-PLAN.md`, `01-02-PLAN.md`, etc.

You'll see a table like:

```
Wave | Plans | What it builds
1    | 01-01, 01-02 | User model + auth endpoints
2    | 01-03        | Login UI (depends on 01-01, 01-02)
```

→ **Open a new chat**, then run `/gsd:execute-phase 1`

### Step 3 — Execute

```
/gsd:execute-phase 1
```

Antigravity executes each PLAN.md in wave order:

- Reads the plan fully
- Runs each `<task>` — writes code, runs commands, creates files
- Commits each task atomically (if `commit_docs: true`)
- Creates a SUMMARY.md for each plan
- After all waves: runs verification against `must_haves`

If a plan has a `checkpoint:human-verify` task, execution pauses and Antigravity
asks you to check something (e.g. visit a URL, confirm a UI). Type "approved" or
describe issues.

**Output:** `SUMMARY.md` per plan, `VERIFICATION.md` for the phase.

### Step 4 — Verify

```
/gsd:verify-work 1
```

Human-in-the-loop UAT. Antigravity extracts testable deliverables from the phase
goal and walks you through each one:

```
Can you log in with your email and password?
→ yes / no / [describe what's wrong]
```

If everything passes: phase complete. If something's broken: fix plans are
created automatically, run `/gsd:execute-phase 1` again.

**Output:** `UAT.md` for the phase.

### Advance to Next Phase

```
/gsd:discuss-phase 2
/gsd:plan-phase 2
...
```

---

## Ad-hoc Tasks

For small tasks that don't need full planning:

```
/gsd:quick Add a dark mode toggle to settings
```

Or just `/gsd:quick` and Antigravity will ask what you want to do.

Creates a plan with 1-3 tasks in `.planning/quick/001-*/`, executes it, and
updates STATE.md's quick tasks table.

---

## Checking Progress

```
/gsd:progress
```

Shows your current position, roadmap overview, and what to run next.

---

## Existing Codebases (Brownfield)

Before running `new-project` on an existing codebase:

```
/gsd:map-codebase
```

Analyses your stack, architecture, patterns, and conventions. Creates
`.planning/codebase/ARCHITECTURE.md` and `STACK.md`. The `new-project` workflow
then reads these so questions focus on what you're _adding_, not re-discovering
what already exists.

---

## Session Model

**Context hygiene rule:** Each major step should be a fresh Antigravity chat.

| After this             | Do this before the next step |
| ---------------------- | ---------------------------- |
| `/gsd:new-project`     | New chat                     |
| `/gsd:plan-phase N`    | New chat                     |
| `/gsd:execute-phase N` | New chat                     |

This keeps each step's context clean. STATE.md is read at the start of every
session to restore context instantly — you never lose your place.

---

## Configuration

`.planning/config.json` controls workflow behaviour. Set during `new-project`,
editable any time:

| Setting               | Values                                 | Effect                                                                     |
| --------------------- | -------------------------------------- | -------------------------------------------------------------------------- |
| `mode`                | `yolo` / `interactive`                 | `yolo`: no confirmation prompts. `interactive`: ask before each major step |
| `depth`               | `quick` / `standard` / `comprehensive` | Controls phase count and plan density                                      |
| `commit_docs`         | `true` / `false`                       | Whether to commit planning docs to git                                     |
| `workflow.research`   | `true` / `false`                       | Research domain before planning each phase                                 |
| `workflow.plan_check` | `true` / `false`                       | Self-verify plans before execution                                         |
| `workflow.verifier`   | `true` / `false`                       | Check `must_haves` after phase execution                                   |

---

## Tips

- **Keep answers focused during `new-project`** — the quality of your roadmap
  depends on the depth of the initial questioning. Don't rush it.

- **Use `discuss-phase` for UI-heavy work** — visual features benefit most from
  having layout, interactions, and empty states decided before planning starts.

- **Trust the XML plan format** — if something goes wrong during execution, the
  task's `<verify>` and `<done>` fields make it clear exactly what was supposed
  to happen.

- **`must_haves` fail ≠ disaster** — if verification finds gaps, it creates fix
  plans automatically. This is the system working, not breaking.

- **Quick tasks don't need a full project** — you can use `/gsd:quick` outside
  of a GSD project as long as `.planning/` exists with at least a `ROADMAP.md`.

---

## Keeping Up with GSD

When GSD ships updates:

```bash
~/.gemini/antigravity-gsd/scripts/sync-gsd.sh
```

Shows what changed in the upstream GSD workflows since this adaptation was
built. Review the diff and update the Antigravity workflow files as appropriate.
