# The Antigravity Adaptation

This document explains the technical decisions behind how GSD's methodology is
implemented in Antigravity workflows.

## Architecture Overview

Native GSD has a three-layer architecture:

```
TOML command → Workflow markdown → gsd-tools.cjs + Task() spawning
```

The Antigravity adaptation collapses this to:

```
Workflow markdown (in ~/.agents/workflows/) → direct file operations
```

Antigravity's workflow system uses `.md` files in `~/.agents/workflows/`. When
you type `/gsd:new-project`, Antigravity loads `gsd-new-project.md` and executes
its instructions using its tool set. No intermediate command layer, no CLI
binary.

## File Operations Replace gsd-tools.cjs

Every operation that `gsd-tools.cjs` performed is replaced with direct file
access:

| gsd-tools call                 | Antigravity equivalent                                          |
| ------------------------------ | --------------------------------------------------------------- |
| `init execute-phase "1"`       | Read `.planning/STATE.md` + `ROADMAP.md` + `config.json`        |
| `roadmap get-phase "1"`        | Parse ROADMAP.md to extract phase section                       |
| `phase-plan-index "1"`         | `list_dir` on phase directory, read frontmatter of each PLAN.md |
| `phase complete "1"`           | Write directly to ROADMAP.md, STATE.md, REQUIREMENTS.md         |
| `commit "message" --files ...` | `run_command git add && git commit` (if `commit_docs: true`)    |
| `config-get key`               | Read `.planning/config.json`                                    |

This makes workflows slightly more verbose but removes all Node.js dependencies.

## Inline Execution Replaces Subagents

Where native GSD spawns specialist subagents (`gsd-planner`,
`gsd-phase-researcher`, `gsd-plan-checker`), Antigravity executes those roles
inline within the same session.

The same cognitive steps happen — research, then plan, then check — just without
the isolation of a fresh context window. The workflow instructions guide
Antigravity through each role's perspective in sequence.

To compensate:

- Plans are kept small (2-3 tasks, ~50% context)
- Workflows prompt for a new chat between major steps
- STATE.md is the bridge that makes new-chat-as-clear viable

## notify_user Replaces AskUserQuestion + Checkpoints

Native GSD's `AskUserQuestion()` renders structured multiple-choice widgets.
Antigravity uses `notify_user` for all blocking user interaction.

Workflow files render options as numbered markdown lists:

```markdown
**How thorough should planning be?**

1. Quick — Ship fast (3-5 phases, 1-3 plans each)
2. Standard — Balanced scope and speed (5-8 phases, 3-5 plans each)
3. Comprehensive — Thorough coverage (8-12 phases, 5-10 plans each)

Reply with the number or the label.
```

Plan `checkpoint:human-verify` and `checkpoint:decision` tasks are handled the
same way: execution pauses, `notify_user` presents the checkpoint details, the
user responds, execution resumes.

## Context Hygiene Without Subagents

The adaptation preserves as much of GSD's context hygiene as possible:

**Lazy file loading:** Workflow instructions explicitly sequence file reads —
only load what's needed for the current step. Don't frontload the entire
`.planning/` directory at session start.

**Step sequencing:** Each major step (research → plan → execute → verify) is
designed to be a standalone session. Workflow banners tell you when to open a
new chat before the next step.

**STATE.md as the bridge:** Following GSD's ≤100 line constraint, STATE.md is a
compressed digest that any new session can read to instantly restore context.
`GEMINI.md` instructs Antigravity to auto-load it.

**Small plans:** Following GSD's 2-3 task / ~50% context guidance, each PLAN.md
execution stays contained. Phases with many tasks get multiple plans, not one
large one.

## Workflow File Structure

Each workflow file follows this pattern:

```markdown
---
description: [one-line description of what this command does]
---

[step-by-step instructions in plain English, using GSD's XML idiom for
structure]
```

The instructions tell Antigravity:

1. What files to read first
2. What to think/analyse
3. Whether to ask the user anything (via notify_user)
4. What files to write
5. What to do with git
6. What banner to show and what to recommend next

## Preserving GSD Compatibility

A key design goal: `.planning/` artifacts produced by the Antigravity workflows
are compatible with the native Gemini CLI GSD. If you use Gemini CLI on the same
project, it will read the same STATE.md, ROADMAP.md, and PLAN.md files without
any conversion.

This means you can switch between Gemini CLI GSD and Antigravity GSD within the
same project. They speak the same language.

## The Update Workflow

GSD is actively developed. The `/gsd:update` command addresses the maintenance
problem for users:

1. Runs `git pull` in the global `~/.gemini/antigravity-gsd` directory.
2. Refreshes the local project's `.agents/workflows/` symlinks.

This ensures your project always has the latest Antigravity translations of
upstream GSD improvements. You can trigger this by saying "Update GSD" or
running the command directly.

For details on how upstream changes are translated from the Claude Code source,
see the [Maintainer Guide](maintainer-guide.md).

## What Gets Skipped

Some GSD features have no meaningful Antigravity equivalent and are deliberately
omitted:

- **Model profiles** — Antigravity uses one model; no Opus/Sonnet/Haiku
  selection
- **Parallel wave execution** — Plans execute sequentially
- **`gsd-tools init` JSON bootstrap** — Replaced by direct file reads
- **`AskUserQuestion()` UI widget** — Replaced by notify_user + numbered lists
- **Auto-advance chain** (`plan-phase --auto` spawning `execute-phase`) — Each
  step is a separate session

These omissions are honest: trying to fake parallelism or auto-advance within a
single Antigravity session would create more context bloat than the features are
worth.
