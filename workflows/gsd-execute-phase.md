---
description: Execute all plans in a phase sequentially by wave order, with atomic commits and must_haves verification
---

## Purpose

Execute all PLAN.md files in a phase. Plans run in wave order (wave 1 first,
then wave 2, etc.). Each plan gets full execution with atomic commits per task.
After all waves: verify against must_haves. Update STATE.md and ROADMAP.md.

## Step 1: Initialize

Parse phase number from `$ARGUMENTS`. Supported flags:

- `--gaps-only` — execute only gap-closure plans (frontmatter has
  `gap_closure: true`)

Read `.planning/STATE.md`. Read `.planning/ROADMAP.md` — find the phase, extract
goal and requirement IDs. Read `.planning/config.json`.

Derive phase directory: `.planning/phases/{padded}-{slug}/`.

List all `*-PLAN.md` files in the phase directory. If none found, error:

> No plans found for Phase [N]. Run `/gsd:plan-phase [N]` first.

## Step 2: Discover and Group Plans

For each PLAN.md file, read the frontmatter and extract:

- `wave` number
- `depends_on` list
- `autonomous` flag
- `objective` (first line of `<objective>` block)
- `files_modified`
- whether a SUMMARY.md already exists (skip if yes — already executed)

If `--gaps-only`: filter to only plans with `gap_closure: true`.

Group plans by wave number. Sort waves ascending.

Report:

```
Phase [N]: [Name] — [total] plans across [W] waves

Wave | Plans        | What it builds
1    | 01-01, 01-02 | [objectives from plans]
2    | 01-03        | [objective]
```

If all plans already have SUMMARY.md: report "All plans already executed" and
skip to Step 5.

## Step 3: Execute Each Wave

For each wave (in order):

### Describe what's being built

Before executing, read each plan's `<objective>` block. Summarise what this wave
builds and why:

```
─── Wave [N] ──────────────────────────────────────────
Plan [ID]: [Name]
[2-3 sentences: what this builds, technical approach, why it matters for the project]

Executing...
─────────────────────────────────────────────────────
```

### Execute each plan in the wave

Read the plan file fully. Then for each `<task>` block:

**For `type="auto"` tasks:**

1. Read `<files>` — these are the files to modify
2. Execute `<action>` — implement exactly what's described
3. Run `<verify>` command to confirm it worked
4. Check `<done>` criteria are met
5. If `commit_docs: true`, commit:
   ```bash
   git add [files from <files>]
   git commit -m "feat({padded}-{plan}): [task name]"
   ```
6. Report: `✓ Task [N]: [name] — [done criteria met]`

**For `type="checkpoint:human-verify"` tasks:**

1. Claude completes any `type="auto"` tasks before the checkpoint first (dev
   server, build, etc.)
2. Stop and notify the user:
   > **Checkpoint: Visual Verification Required**
   >
   > [What was built from `<what-built>`]
   >
   > [How to verify from `<how-to-verify>`]
   >
   > Type "approved" to continue, or describe any issues.
3. Wait for user response. If "approved": continue. If issues described: note
   them, stop plan execution, flag for gap closure.
4. Set `autonomous: false` in plan frontmatter was already set — just handle it.

**For `type="checkpoint:decision"` tasks:**

1. Stop and notify the user with the decision and options:
   > **Checkpoint: Decision Required**
   >
   > [Decision from `<decision>`] [Context from `<context>`]
   >
   > Options:
   >
   > 1. [Option A name] — [pros/cons]
   > 2. [Option B name] — [pros/cons]
   >
   > [Resume signal from `<resume-signal>`]
2. Wait for selection. Continue with chosen option.

**For `type="checkpoint:human-action"` tasks:**

1. Stop completely — this requires the user to do something Claude cannot:
   > **Checkpoint: Action Required**
   >
   > [What the user needs to do]
   >
   > Type "done" when complete.

### After each plan: write SUMMARY.md

Write `{phase_dir}/{plan_id}-SUMMARY.md`:

```markdown
---
plan: {plan_id}
phase: {padded}-{slug}
status: complete
date: [date]
---

# Plan [ID] Summary: [Name]

## What Was Built

[2-3 sentences describing what was actually implemented]

## Tasks Completed

- [x] Task 1: [name] — [what was done]
- [x] Task 2: [name] — [what was done]

## Files Created/Modified

- `path/to/file.ts` — [what it does]

## Deviations from Plan

[Any] | None

## Self-Check

[Run the verification commands from <verification> block and report pass/fail]

## Self-Check: [PASSED/FAILED]
```

Report wave completion:

```
─── Wave [N] Complete ────────────────────────────────
[What was built — summarised from SUMMARYs]
[What the next wave can now do, if applicable]
─────────────────────────────────────────────────────
```

## Step 4: Aggregate Results

After all waves:

```
Phase [N]: [Name] — Execution Complete

Wave | Plans              | Status
1    | 01-01, 01-02       | ✓ Complete
2    | 01-03              | ✓ Complete

Plans: [M]/[total] complete
```

## Step 5: Verify Phase Goal (unless verifier disabled in config)

Check must_haves against the actual codebase for each plan:

**Check truths:** For each truth statement — can you confirm this is observable?
Does the code support it? **Check artifacts:** For each required file — does it
exist? Does it have the expected minimum lines / exports / content patterns?
**Check key_links:** For each required connection — does the pattern exist in
the from-file?

Write `{phase_dir}/{padded}-VERIFICATION.md`:

```markdown
---
phase: {padded}-{slug}
status: passed | gaps_found | human_needed
date: [date]
---

# Phase [N] Verification

## Must-Haves Check

### Truths

- ✓ [truth] — [evidence]
- ✗ [truth] — [what's missing]

### Artifacts

- ✓ `path/to/file.ts` — exists, [N] lines, exports [X]
- ✗ `path/to/missing.ts` — not found

### Key Links

- ✓ [from] → [to] via [mechanism] — pattern found
- ✗ [from] → [to] — pattern not found: [what was found instead]

## Gaps Found

[List of what's missing — specific and actionable]

## Human Verification Required

[Items that need a human to test manually, with instructions]
```

**Based on verification status:**

If `passed`:

> ✓ All must-haves verified. Phase [N] complete.

If `human_needed`:

> [N] items need human testing: [list items] Type "approved" to proceed, or
> describe issues.

If `gaps_found`:

> ⚠ Gaps found in Phase [N]: [gap summary]
>
> Run `/gsd:plan-phase [N] --gaps` to create fix plans. Then run
> `/gsd:execute-phase [N] --gaps-only` to apply them.

## Step 6: Update STATE.md and ROADMAP.md

Update `.planning/STATE.md`:

- Change phase status to "Complete" (or "Gaps found")
- Update Last activity line
- Advance Current focus to next phase
- Update Progress bar percentage

Update `.planning/ROADMAP.md`:

- Mark phase checkbox `[x]`
- Update Progress table (Status → Complete, add completion date)

If `commit_docs: true`:

```bash
git add ".planning/STATE.md" ".planning/ROADMAP.md" "{phase_dir}/{padded}-VERIFICATION.md"
git commit -m "docs({padded}): complete phase execution"
```

## Step 7: Final Output

If verification passed:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► PHASE [N] COMPLETE ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Plans: [M] complete | Verification: Passed

───────────────────────────────────────────────────────
▶ Next Up

Open a new chat, then run: /gsd:verify-work [N]
Or skip to: /gsd:discuss-phase [N+1]
───────────────────────────────────────────────────────
```
