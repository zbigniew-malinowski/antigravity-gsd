# GSD in Gemini CLI and Claude Code

GSD's implementation differs slightly between its supported runtimes, but the
core architecture is the same. This document covers how it works natively, which
is the foundation for understanding the Antigravity adaptation.

## Installation

GSD is installed via:

```bash
npx get-shit-done-cc@latest
```

The installer prompts for runtime (Claude Code, Gemini CLI, Codex, or all) and
location (global or per-project). For Gemini CLI, it installs:

- Command TOML files → `~/.gemini/commands/gsd/`
- Workflow markdown files → `~/.gemini/get-shit-done/workflows/`
- Template files → `~/.gemini/get-shit-done/templates/`
- Reference files → `~/.gemini/get-shit-done/references/`
- Agent definitions → `~/.gemini/agents/`
- A Node.js CLI binary → `~/.gemini/get-shit-done/bin/gsd-tools.cjs`

## The Command Layer (TOML files)

Each slash command (e.g. `/gsd:new-project`) is defined as a TOML file with
three fields:

```toml
description = "Initialize a new project with deep context gathering"
prompt = """
<context>...</context>
<objective>...</objective>
<execution_context>
@~/.gemini/get-shit-done/workflows/new-project.md
@~/.gemini/get-shit-done/references/questioning.md
</execution_context>
<process>
Execute the new-project workflow end-to-end.
</process>
"""
```

The TOML prompt is sent to the AI, which reads the referenced workflow files via
`@` includes and executes the instructions.

## The Workflow Layer (markdown files)

Workflow files contain detailed, multi-step instructions for the AI. They use:

- XML tags for structure (`<purpose>`, `<process>`, `<step>`,
  `<success_criteria>`)
- Bash code blocks for shell commands the AI should run
- `Task()` calls for spawning subagents
- `AskUserQuestion()` for structured multiple-choice prompts

Example flow for `plan-phase.md`:

1. Load context via `gsd-tools.cjs init plan-phase`
2. Parse arguments (phase number, flags)
3. Check for CONTEXT.md
4. Spawn `gsd-phase-researcher` agent
5. Spawn `gsd-planner` agent
6. Spawn `gsd-plan-checker` agent
7. Revision loop (max 3 iterations)
8. Present results or auto-advance

## The Node.js CLI (`gsd-tools.cjs`)

A critical piece of the native implementation. Called before almost every
workflow step:

```bash
INIT=$(node "$HOME/.claude/get-shit-done/bin/gsd-tools.cjs" init execute-phase "1")
```

Returns JSON containing: model selections, file paths, config values, phase
information, plan inventory, and more. Centralises all the "where am I in the
project?" logic so workflow files stay clean.

Other commands:

```bash
gsd-tools roadmap get-phase "1"     # Phase details
gsd-tools phase-plan-index "1"      # Plan inventory with wave grouping
gsd-tools phase complete "1"        # Mark phase complete (updates ROADMAP, STATE, REQUIREMENTS)
gsd-tools commit "docs: update"     # Git commit respecting commit_docs config
gsd-tools config-set key value      # Update config.json
```

## Subagent Spawning (`Task()` API)

The most powerful aspect of native GSD — and the one with no direct Antigravity
equivalent. The `Task()` API (Claude Code) / subagent spawning (Gemini CLI)
creates fresh AI instances with their own full context windows:

```
Task(
  prompt="Read gsd-planner.md for your role, then...",
  subagent_type="general-purpose",
  model="claude-sonnet-4-5",
  description="Plan Phase 1"
)
```

Key properties:

- Each subagent gets a fresh 200k token context window
- Subagents run in parallel within a wave (independent plans simultaneously)
- The orchestrator's context stays at ~10-15% (paths and summaries, not content)
- Subagents write results to disk, orchestrator reads the output files

This is how GSD achieves context hygiene at scale: heavy lifting happens in
isolated fresh contexts, while the main session stays clean.

## Agent Definitions

Agents like `gsd-planner`, `gsd-executor`, `gsd-phase-researcher` are defined as
markdown files in `~/.gemini/agents/`. Each one has:

- Role definition and responsibilities
- Specific output format requirements
- Quality gates and validation rules
- Return signals (`## PLANNING COMPLETE`, `## RESEARCH BLOCKED`, etc.)

## The `.planning/config.json`

Created during `new-project`, controls all workflow behaviour:

```json
{
    "mode": "yolo",
    "depth": "standard",
    "parallelization": true,
    "commit_docs": true,
    "model_profile": "balanced",
    "workflow": {
        "research": true,
        "plan_check": true,
        "verifier": true
    }
}
```

`mode: yolo` means auto-approve at every step (no confirmation prompts).
`mode: interactive` means the AI confirms before each major action.

## Git Integration

GSD commits automatically after every task completion:

```bash
gsd-tools commit "feat(01-02): implement user registration" --files src/...
```

Every task gets its own atomic commit with a conventional commit message
referencing the phase and plan. This gives a clean, bisectable git history that
maps exactly to what the AI built.

## What Makes It Work

1. **Structured context**: Every workflow reads exactly the files it needs,
   nothing more
2. **State externalised to disk**: STATE.md, not conversation history, carries
   context forward
3. **Subagent isolation**: Each heavy task runs in a fresh context window
4. **Validation loops**: Plan checker and verifier catch gaps before they
   compound
5. **Atomic commits**: Every task independently revertable
