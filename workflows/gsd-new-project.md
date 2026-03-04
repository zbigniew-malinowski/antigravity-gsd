---
description: Initialize a new GSD project — deep questioning, optional research, requirements scoping, and roadmap creation
---

## Purpose

Initialize a new project through a unified flow: questioning → research
(optional) → requirements → roadmap. Creates all `.planning/` foundation files.

## Step 1: Check Prerequisites

Read the current directory. If `.planning/PROJECT.md` exists, stop with:

> Error: Project already initialized. Run `/gsd:progress` to see current status.

If `.planning/` doesn't exist, create it:

```bash
mkdir -p .planning
```

Check if git is initialized. If not, ask the user if they want to initialize it
(recommended).

## Step 2: Check for Existing Codebase

If source files exist in the current directory (beyond just config/dot files),
ask:

> I detected existing code in this directory. Would you like to map the codebase
> first?
>
> 1. Map codebase first — run `/gsd:map-codebase` to understand existing
>    architecture (recommended)
> 2. Skip mapping — proceed with project initialization

If they choose mapping, stop and tell them to run `/gsd:map-codebase` first.

## Step 3: Deep Questioning

Check if `--auto` was provided in the user's prompt.

**If `--auto` IS provided:** Skip questioning. Read the user's prompt and any
attached documents (like a PRD). Treat the provided information as the project
goal and proceed immediately.

**If `--auto` IS NOT provided:** Ask openly (not a numbered list — genuine
conversation):

> **What do you want to build?**

Wait for their response. Then follow the thread. Each answer opens new threads
to explore. Use these techniques:

- **Challenge vagueness**: "When you say 'easy to use', what does that look like
  for your target user?"
- **Make abstract concrete**: "If I showed you a working version tomorrow, what
  would you click first?"
- **Surface assumptions**: "You mentioned [X] — is that a hard requirement or a
  preference?"
- **Find edges**: "What happens when [edge case]?"
- **Reveal motivation**: "What problem is this solving that you can't solve
  another way?"

Keep following threads until you could write a clear PROJECT.md. Then ask:

> I think I understand what you're after. Ready to create PROJECT.md?
>
> 1. Create PROJECT.md — let's move forward
> 2. Keep exploring — I want to share more

Loop until they choose option 1.

## Step 4: Workflow Preferences

**If `--auto` IS provided:** Skip asking questions. Use these default
preferences: Standard depth, commit_docs=true, research=true, plan_check=true,
verifier=true.

**If `--auto` IS NOT provided:** Ask (numbered list — user replies with number):

> **How thorough should planning be?**
>
> 1. Quick — 3-5 phases, 1-3 plans each; ship fast
> 2. Standard — 5-8 phases, 3-5 plans each; balanced
> 3. Comprehensive — 8-12 phases, 5-10 plans each; thorough coverage

> **Commit planning docs to git?**
>
> 1. Yes (recommended) — planning docs tracked in version control
> 2. No — keep .planning/ local only

> **Research the domain before planning each phase?**
>
> 1. Yes (recommended) — investigate domain, find patterns, surface gotchas
> 2. No — plan directly from requirements

> **Self-verify plans before execution?**
>
> 1. Yes (recommended) — catch gaps before execution starts
> 2. No — execute plans without verification

> **Verify work satisfies requirements after each phase?**
>
> 1. Yes (recommended) — confirm deliverables match phase goals
> 2. No — trust execution, skip verification

Write `.planning/config.json`:

```json
{
  "depth": "quick|standard|comprehensive",
  "commit_docs": true|false,
  "workflow": {
    "research": true|false,
    "plan_check": true|false,
    "verifier": true|false
  }
}
```

If `commit_docs: false`, add `.planning/` to `.gitignore` (create if needed).

## Step 5: Write PROJECT.md

Synthesize all context gathered. Use this structure:

```markdown
# [Project Name]

## Core Value

[One sentence: the ONE thing that must work]

## Problem

[What problem is this solving and for whom]

## Vision

[What success looks like — concrete, observable]

## Constraints

[Tech limitations, timeline, budget, non-negotiables]

## Non-Goals

[What this deliberately won't do — with rationale]

## Requirements

### Validated

(None yet — to be validated by shipping)

### Active

- [ ] [Requirement 1]
- [ ] [Requirement 2] ...

### Out of Scope

- [Exclusion] — [why]

## Key Decisions

| Decision                  | Rationale | Outcome   |
| ------------------------- | --------- | --------- |
| [Choice from questioning] | [Why]     | — Pending |

---

_Last updated: [date] after initialization_
```

For brownfield projects (codebase map exists): read
`.planning/codebase/ARCHITECTURE.md` and infer Validated requirements from
existing code before listing Active requirements.

## Step 6: Domain Research (if enabled)

If `workflow.research: true` in config, ask:

> Research the domain ecosystem before defining requirements?
>
> 1. Research first (recommended) — discover standard stacks, expected features,
>    architecture patterns
> 2. Skip — I know this domain well

If research: search the web for the project's domain. Focus on:

- Standard 2025 tech stack for this type of project
- Table stakes features (what users expect) vs differentiators
- Common architecture patterns
- Known pitfalls and gotchas

Write research findings to:

- `.planning/research/STACK.md`
- `.planning/research/FEATURES.md`
- `.planning/research/ARCHITECTURE.md`
- `.planning/research/PITFALLS.md`

Read these back, then write a `.planning/research/SUMMARY.md` synthesizing key
findings.

Report key findings before moving on.

## Step 7: Define REQUIREMENTS.md

Load PROJECT.md. If research exists, load FEATURES.md.

Present features by category (table stakes vs differentiators). For each
category, ask which features are in scope for v1. User can reply with numbers,
"all", or "none".

If no research: gather requirements through conversation instead — "What must
exist for this to be useful?"

Write `.planning/REQUIREMENTS.md`:

```markdown
# Requirements: [Project Name]

## Req IDs

REQ-01 through REQ-NN, each with:

- ID, description, category, priority (must/should/nice), phase assignment

## Table Stakes

- [ ] REQ-01: [Feature] — [why table stakes] ...

## Differentiators

- [ ] REQ-05: [Feature] — [competitive rationale] ...

## Out of Scope

- REQ-08 (deferred): [Feature] — [why not v1] ...
```

## Step 8: Create ROADMAP.md

Based on requirements and depth setting, create phases. Each phase should:

- Deliver something coherent and testable
- Have 2-5 observable success criteria
- Map to specific requirement IDs
- Specify estimated plan count (or TBD)

Write `.planning/ROADMAP.md` using GSD's roadmap template format (checkboxes,
Phase Details section, Progress table).

Show the roadmap and ask for approval:

> Here's the proposed roadmap. Does this look right?
>
> 1. Approve — let's build this
> 2. Adjust — [what to change]

Loop until approved.

## Step 9: Create STATE.md

Write `.planning/STATE.md` (keep under 100 lines):

```markdown
# Project State

## Project Reference

See: .planning/PROJECT.md (updated [date]) **Core value:** [one-liner from
PROJECT.md] **Current focus:** Phase 1 — [name]

## Current Position

Phase: 1 of [N] ([Phase name]) Status: Ready to plan Last activity: [date] —
Project initialized

Progress: [░░░░░░░░░░] 0%

## Accumulated Context

### Decisions

- Initialization: [key decisions from questioning]

### Pending Todos

None yet.

### Blockers/Concerns

None yet.

## Session Continuity

Last session: [date] Stopped at: Project initialization complete Resume file:
None
```

## Step 10: Commit and Complete

If `commit_docs: true`:

```bash
git add .planning/
git commit -m "chore: initialize GSD project"
```

Output this banner:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► PROJECT INITIALIZED ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[N] phases | [M] requirements | Research: [Yes/Skipped]

Files created:
  .planning/PROJECT.md
  .planning/REQUIREMENTS.md
  .planning/ROADMAP.md
  .planning/STATE.md
  .planning/config.json

───────────────────────────────────────────────────────
▶ Next Up

Open a new chat, then run: /gsd:plan-phase 1
Or first run: /gsd:discuss-phase 1 (recommended)
───────────────────────────────────────────────────────
```
