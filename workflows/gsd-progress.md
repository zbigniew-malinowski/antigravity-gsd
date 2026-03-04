---
description: Show current project status — phase, position, recent activity, and what to run next
---

## Purpose

Quick status overview for a GSD project. Reads STATE.md and ROADMAP.md and
renders a compact dashboard.

## Step 1: Check for Project

If `.planning/STATE.md` doesn't exist:

> No GSD project found in this directory. Run `/gsd:new-project` to initialize
> one.

## Step 2: Read State Files

Read `.planning/STATE.md`. Read `.planning/ROADMAP.md`. Read
`.planning/config.json` (if exists).

## Step 3: Render Dashboard

Present this output:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► PROJECT PROGRESS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Project name from PROJECT.md or ROADMAP.md header]
[Core value — one liner]

## Current Position

Phase [X] of [Y]: [Phase name]
Status: [Ready to plan / Planning / Ready to execute / In progress / Phase complete]
Last activity: [from STATE.md]

Progress: [████░░░░░░] [N]%

## Roadmap

[For each phase, one line:]
  ✓ Phase 1: [Name] — Complete
  ► Phase 2: [Name] — In progress
  ○ Phase 3: [Name] — Not started
  ○ Phase 4: [Name] — Not started

## Quick Tasks
[N] completed — see .planning/quick/

## Blockers
[From STATE.md, or "None"]

───────────────────────────────────────────────────────
▶ Next Up

[Based on current position, suggest the most logical next command]

Examples:
  /gsd:discuss-phase 2     ← if current phase complete, no context for next
  /gsd:plan-phase 2        ← if context exists, ready to plan
  /gsd:execute-phase 2     ← if plans exist, ready to execute
  /gsd:verify-work 2       ← if execution done, needs UAT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Determine "Next Up" by checking what files exist for the current/next phase:

- If no CONTEXT.md for next phase → suggest `discuss-phase N`
- If CONTEXT.md but no PLAN.md → suggest `plan-phase N`
- If PLAN.md but no SUMMARY.md → suggest `execute-phase N` (in new chat)
- If all plans have SUMMARY.md but no UAT.md → suggest `verify-work N`
- If UAT passed → suggest `discuss-phase N+1`
