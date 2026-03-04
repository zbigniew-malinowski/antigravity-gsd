---
description: Ad-hoc tasks with GSD guarantees — plan, execute, and commit without full phase ceremony
---

## Purpose

For small tasks that don't need full planning. Creates a plan with 1-3 tasks,
executes it, commits atomically, and updates STATE.md. Runs inside any project
that has `.planning/ROADMAP.md`.

## Step 1: Parse Arguments

Check if a task description was provided in `$ARGUMENTS` (after stripping any
flags).

Supported flags:

- `--full` — enable plan checking and post-execution verification

If no description found, ask:

> **Quick Task**
>
> What do you want to do?

Store response as the task description.

If still no description provided, prompt again.

## Step 2: Initialize

Read `.planning/ROADMAP.md` — confirm it exists (quick tasks require an active
project). Read `.planning/STATE.md`. Read `.planning/config.json`.

Generate task number:

- List `.planning/quick/` — count existing directories
- Next num = count + 1, zero-padded to 3 digits (e.g., "001")

Generate slug from description:

- Lowercase, replace spaces/special chars with hyphens, max 40 chars

Task directory: `.planning/quick/{num}-{slug}/`

Create the directory.

Report:

```
Creating quick task {num}: {description}
Directory: .planning/quick/{num}-{slug}/
```

## Step 3: Create Plan

Create a single PLAN.md with 1-3 focused tasks.

Read relevant source files first — understand the codebase context before
planning.

Write `.planning/quick/{num}-{slug}/{num}-PLAN.md`:

```markdown
---
phase: quick
plan: { num }
type: execute
wave: 1
depends_on: []
files_modified: []
autonomous: true
must_haves:
    truths:
        - "[What should be true after this task completes]"
    artifacts:
        - path: "[key file created or modified]"
          provides: "[what it does]"
---

<objective>
{description}

Purpose: Ad-hoc quick task. Output: [What this produces]
</objective>

<tasks>
<task type="auto">
  <name>Task 1: [name]</name>
  <files>[files]</files>
  <action>[specific implementation]</action>
  <verify>[command or check]</verify>
  <done>[measurable criteria]</done>
</task>
</tasks>

<verification>
- [ ] [verify criteria]
</verification>
```

**Constraints:**

- 1-3 tasks maximum
- Self-contained — no cross-dependencies with phase plans
- Do NOT modify ROADMAP.md (quick tasks are tracked separately)

## Step 4: Plan Check (--full mode only)

If `--full` flag provided and (`workflow.plan_check: true` in config or `--full`
explicit):

Review the plan:

- Does it address the task description?
- Are tasks specific enough?
- Are files listed?
- Is the must_haves derivable from the description?

If gaps found: fix inline (max 1 revision).

## Step 5: Execute

Read the plan fully. For each task:

1. Implement `<action>` on `<files>`
2. Run `<verify>` command
3. Check `<done>` criteria
4. Commit if `commit_docs: true`:
   ```bash
   git add [files]
   git commit -m "feat(quick-{num}): {task name}"
   ```

## Step 6: Post-Execution Verification (--full mode only)

If `--full`: check `must_haves` against actual codebase. Write
`{task_dir}/{num}-VERIFICATION.md` with status and findings.

## Step 7: Write SUMMARY.md

Write `.planning/quick/{num}-{slug}/{num}-SUMMARY.md`:

```markdown
# Quick Task {num}: {description}

**Date:** [date] **Status:** Complete

## What Was Done

[2-3 sentences]

## Files Modified

- `path/to/file` — [what changed]

## Verification

[Verification results, or "Skipped"]
```

## Step 8: Update STATE.md

Read STATE.md. Find or create a `### Quick Tasks Completed` table.

Add row:

```
| {num} | {description} | [date] | [commit hash] | [.planning/quick/{num}-{slug}/](.planning/quick/{num}-{slug}/) |
```

Update "Last activity" line.

## Step 9: Final Commit and Report

If `commit_docs: true`:

```bash
git add ".planning/quick/{num}-{slug}/" ".planning/STATE.md"
git commit -m "docs(quick-{num}): {description}"
```

Output:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► QUICK TASK COMPLETE ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Quick Task {num}: {description}
Summary: .planning/quick/{num}-{slug}/{num}-SUMMARY.md

Ready for next task: /gsd:quick
```
