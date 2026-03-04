---
description: Human-in-the-loop UAT walkthrough — test each deliverable and diagnose failures
---

## Purpose

Walk through testable deliverables one by one. User confirms what works and what
doesn't. Failures are diagnosed and fix plans are created automatically.

## Step 1: Initialize

Parse phase number from `$ARGUMENTS`.

Read `.planning/ROADMAP.md` — find the phase goal and success criteria. Read the
phase's `VERIFICATION.md` if it exists (from execute-phase) — this gives
automated check results. Read all `SUMMARY.md` files in the phase directory —
extract what was actually built.

## Step 2: Extract Testable Deliverables

From the phase goal, success criteria, and `must_haves.truths` across all plans,
compile a list of things the user should be able to do or observe.

Each deliverable should be:

- A single, unambiguous thing to test
- Testable by a non-technical user in ≤2 minutes
- Observable (not "the code is correct", but "you can click X and Y happens")

Present:

```
## Phase [N]: [Name] — User Acceptance Testing

I'll walk you through [N] tests. For each one, tell me:
- ✓ "yes" / "approved" / "works" — if it passes
- ✗ describe what's wrong — if it fails (be specific: what did you see vs what you expected?)
```

## Step 3: Walk Through Each Deliverable

For each deliverable, present one at a time:

```
─── Test [N] of [M] ─────────────────────────────────

[What to test]

[How to test it — clear steps for a non-technical user]

What do you see?
─────────────────────────────────────────────────────
```

Wait for user response before moving to next.

Track results:

- Pass: ✓ noted, move to next
- Fail: record exact failure description, continue through remaining tests

## Step 4: Diagnose Failures

If any tests failed:

For each failure, diagnose the root cause:

1. Read the relevant source files for that deliverable
2. Check if the verify/done criteria in the PLAN.md were actually met
3. Look for the gap between "what was built" and "what was expected"

Produce a clear diagnosis for each failure:

```
Failure [N]: [What failed]
Root cause: [Specific gap found — be precise about the file/function/behaviour]
Fix needed: [What change would fix it]
```

## Step 5: Create Fix Plans (if failures found)

For each diagnosed failure, create a gap-closure PLAN.md in the phase directory:

File naming: `{padded}-gap-{N}-PLAN.md`

```markdown
---
phase: {padded}-{slug}
plan: gap-{N}
type: execute
wave: 1
depends_on: []
files_modified: [list files the fix touches]
autonomous: true
gap_closure: true
requirements: [requirement IDs this fix addresses]
must_haves:
  truths:
    - "[The UAT test that failed should now pass]"
  artifacts:
    - path: "[file that needed fixing]"
      provides: "[what it should now provide]"
---

<objective>
Gap closure: [What failed in UAT]

Purpose: Fix the gap identified during user acceptance testing. Root cause:
[Diagnosed cause] Fix: [Specific change needed]
</objective>

<tasks>
<task type="auto">
  <name>Fix: [description]</name>
  <files>[files to modify]</files>
  <action>[Exact fix — specific about what to change and how]</action>
  <verify>[Command to confirm fix worked]</verify>
  <done>[The UAT test now passes]</done>
</task>
</tasks>

<verification>
- [ ] [Original UAT test now passes]
</verification>
```

## Step 6: Write UAT.md

Write `{phase_dir}/{padded}-UAT.md`:

```markdown
---
phase: {padded}-{slug}
status: passed | diagnosed
date: [date]
tests_total: [N]
tests_passed: [M]
tests_failed: [P]
---

# Phase [N] UAT: [Name]

**Date:** [date] **Result:** [PASSED / [P] issues diagnosed]

## Test Results

| # | Test          | Result | Notes                |
| - | ------------- | ------ | -------------------- |
| 1 | [deliverable] | ✓ Pass | —                    |
| 2 | [deliverable] | ✗ Fail | [what user reported] |

## Failures and Diagnosis

### Issue 1: [What failed]

**User reported:** [exact words] **Root cause:** [diagnosis] **Fix plan:**
{padded}-gap-01-PLAN.md
```

## Step 7: Commit and Report

If `commit_docs: true`:

```bash
git add "{phase_dir}/{padded}-UAT.md" "{phase_dir}/{padded}-gap-*.md"
git commit -m "docs({padded}): UAT results and gap closure plans"
```

If all passed:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► PHASE [N] UAT PASSED ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

All [N] tests passed.

▶ Next: /gsd:discuss-phase [N+1]
```

If failures found:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► UAT: [P] ISSUES FOUND
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[P] fix plans created.

▶ Open a new chat, then run: /gsd:execute-phase [N] --gaps-only
```
