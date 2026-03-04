---
description: Create atomic XML task plans for a roadmap phase with inline research and self-verification
---

## Purpose

Create executable PLAN.md files for a phase. Default flow: research → plan →
self-verify → done. Reads CONTEXT.md (from discuss-phase) so all decisions are
pre-loaded.

## Step 1: Initialize

Parse phase number from `$ARGUMENTS`. Supported flags:

- `--skip-research` — skip research, go straight to planning
- `--research` — force re-research even if RESEARCH.md already exists
- `--gaps` — gap-closure mode (reads VERIFICATION.md, skips research)
- `--skip-verify` — skip self-verification

Read `.planning/STATE.md`. Read `.planning/ROADMAP.md` — find the phase. If not
found, list available phases and stop.

Derive phase directory:

- Phase number → zero-padded (e.g., "1" → "01")
- Phase name → slugified from ROADMAP
- Path: `.planning/phases/{padded}-{slug}/`
- Create if it doesn't exist

Read `.planning/REQUIREMENTS.md`.

## Step 2: Load CONTEXT.md

Check if `{phase_dir}/{padded}-CONTEXT.md` exists.

If it exists: read it. Note all locked decisions — the planner must not
second-guess these.

If it doesn't exist:

> No CONTEXT.md found for Phase [N]. Plans will use research and requirements
> only — your design preferences won't be included.
>
> 1. Continue without context
> 2. Run /gsd:discuss-phase [N] first — capture design decisions before planning

If they choose option 2: stop.

## Step 3: Research Phase Domain

Skip if: `--skip-research`, `--gaps`, or `workflow.research: false` in config
AND no `--research` flag. Skip if: RESEARCH.md already exists and no
`--research` flag.

Read relevant source files from the codebase — files the phase will modify or
depend on.

Research questions to answer — read ROADMAP phase goal and think through:

- What does this phase need to implement?
- What APIs, libraries, or patterns apply?
- What are the gotchas for this specific task?
- What does the existing codebase already have that can be reused?
- What patterns are established in other phases (check for SUMMARY.md files)?

Optionally use `search_web` if the domain involves unfamiliar libraries or APIs.

Write `.planning/phases/{padded}-{slug}/{padded}-RESEARCH.md`:

```markdown
# Phase [N] Research: [Name]

**Date:** [date] **Phase Goal:** [from ROADMAP]

## Technical Approach

[How this phase should be implemented — specific, not generic]

## Key Decisions Pre-Answered

- [Decision the planner would have asked about]: [answer based on research]

## Existing Codebase Assets

- [File/pattern]: [how it's relevant]

## Implementation Notes

[Gotchas, patterns to follow, antipatterns to avoid]

## Validation Approach

[How to verify this phase worked — what tests, what commands, what observable
behaviours]
```

## Step 4: Check Existing Plans

List `{phase_dir}/*-PLAN.md` files.

If plans exist:

> Plans already exist for Phase [N]:
>
> - [list them]
>
> 1. Add more plans — create additional plans
> 2. View existing — show plan list with objectives
> 3. Replan from scratch — delete existing and recreate (confirm first)

## Step 5: Create PLAN.md Files

Based on requirements, CONTEXT.md decisions, and research, create 2-5 atomic
plans.

**Sizing rules:**

- 2-3 tasks per plan
- ~50% context maximum per plan execution
- Prefer vertical slices (User feature: model + API + UI) over horizontal layers
  (all models, then all APIs)
- Split if: different subsystems, >3 tasks, or risk of context overflow

**Dependency analysis:**

- Plans in the same wave are independent (no shared files, no import
  dependencies)
- Plans in later waves depend on earlier wave output
- Assign wave numbers based on actual dependencies

For each plan, write `{phase_dir}/{padded}-{plan_num:02d}-PLAN.md`:

```markdown
---
phase: {padded}-{slug}
plan: {plan_num:02d}
type: execute
wave: {N}
depends_on: []
files_modified: []
autonomous: true
requirements: [REQ-01, REQ-02]
must_haves:
  truths:
    - "[Observable user-facing behaviour 1]"
    - "[Observable user-facing behaviour 2]"
  artifacts:
    - path: "src/path/to/file.ts"
      provides: "[What this file delivers]"
      min_lines: 30
  key_links:
    - from: "src/component.tsx"
      to: "src/api/endpoint.ts"
      via: "fetch call in useEffect"
---

<objective>
[What this plan accomplishes]

Purpose: [Why this matters for the project] Output: [What artifacts will be
created]
</objective>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/STATE.md
@src/relevant/file.ts
</context>

<tasks>

<task type="auto">
  <name>Task 1: [Action-oriented name]</name>
  <files>path/to/file.ext</files>
  <action>[Specific implementation — what to do, how to do it, what to avoid and WHY]</action>
  <verify>[Command or check to prove it worked]</verify>
  <done>[Measurable acceptance criteria]</done>
</task>

<task type="auto">
  <name>Task 2: [Action-oriented name]</name>
  <files>path/to/file.ext</files>
  <action>[Specific implementation]</action>
  <verify>[Command or check]</verify>
  <done>[Acceptance criteria]</done>
</task>

</tasks>

<verification>
Before declaring plan complete:
- [ ] [Specific test command]
- [ ] [Build/type check passes]
- [ ] [Behaviour verification]
</verification>

<success_criteria>

- All tasks completed
- All verification checks pass
- No errors or warnings introduced </success_criteria>
```

**Task types:**

- `type="auto"` — Claude executes fully autonomously
- `type="checkpoint:human-verify"` — Pause, present to user for visual
  verification
- `type="checkpoint:decision"` — Pause, present options, user decides
- `type="checkpoint:human-action"` — Pause, user must do something Claude can't
  (e.g. configure external service)

**Requirements coverage:** Every requirement ID listed in the ROADMAP phase MUST
appear in at least one plan's `requirements` frontmatter field.

## Step 6: Self-Verify Plans (unless --skip-verify)

Review the plans against:

- [ ] All phase requirement IDs covered
- [ ] Each plan has valid frontmatter (wave, depends_on, files_modified,
      autonomous, requirements, must_haves)
- [ ] Tasks are specific (not vague like "add authentication")
- [ ] Dependencies correctly identified — no false dependencies
- [ ] Wave assignments make sense (no circular deps)
- [ ] must_haves are derived from phase goal, not just from tasks
- [ ] Files listed in `files_modified` don't conflict within same wave

If issues found: fix them inline (max 2 self-revision passes before presenting
to user).

## Step 7: Commit and Complete

If `commit_docs: true`:

```bash
git add ".planning/phases/{padded}-{slug}/"
git commit -m "docs({padded}): create phase plans"
```

Output:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► PHASE [N] PLANNED ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Phase [N]: [Name] — [M] plans in [W] waves

Wave | Plans     | What it builds
1    | 01, 02    | [objectives]
2    | 03        | [objective]

Research: [Completed / Used existing / Skipped]
Verification: [Passed / Skipped]

───────────────────────────────────────────────────────
▶ Next Up

Open a new chat, then run: /gsd:execute-phase [N]
───────────────────────────────────────────────────────
```
