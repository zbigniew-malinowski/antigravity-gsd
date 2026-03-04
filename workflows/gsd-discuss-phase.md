---
description: Capture design decisions for a phase through adaptive questioning before planning starts
---

## Purpose

Extract implementation decisions the planner needs — so it knows what to
investigate and what choices are already locked. Output is a CONTEXT.md file
that feeds directly into plan-phase.

## Step 1: Validate

Parse the phase number from `$ARGUMENTS` (required). If missing, error:

> Please provide a phase number. Usage: `/gsd:discuss-phase 1`

Read `.planning/ROADMAP.md`. Find the phase. If not found, list available phases
and stop.

If a CONTEXT.md already exists for this phase, ask:

> CONTEXT.md already exists for Phase [N]. What would you like to do?
>
> 1. Update it — add or change decisions
> 2. View it — show current context
> 3. Skip — use existing context as-is

## Step 2: Scout the Codebase

Before asking questions, read the codebase to find:

- Existing components / patterns relevant to this phase
- Libraries already in use that might be leveraged
- Conventions established in earlier phases (check `.planning/phases/` for any
  SUMMARY.md files)

This grounds the questions in concrete options rather than abstract choices.

## Step 3: Analyse the Phase

Read the phase goal from ROADMAP.md. Determine what kind of thing is being
built:

| Phase type                              | Gray areas to surface                                       |
| --------------------------------------- | ----------------------------------------------------------- |
| Something users **see**                 | Layout, density, interactions, empty states, loading states |
| Something users **call** (API/CLI)      | Response format, error handling, auth approach, versioning  |
| Something users **run** (script/tool)   | Output format, verbosity flags, failure modes               |
| Something users **read** (content/docs) | Structure, tone, depth, flow                                |
| Something being **organised**           | Grouping criteria, naming conventions, exception handling   |

Generate 3-4 phase-specific gray areas. These should be specific to _this_
phase, not generic categories.

## Step 4: Present Gray Areas

Show the gray areas found and ask which to discuss:

> For Phase [N]: [Name], I've identified these areas that could go different
> ways:
>
> 1. [Gray area 1] — [one-line description of the ambiguity]
> 2. [Gray area 2] — ...
> 3. [Gray area 3] — ...
> 4. [Gray area 4] — ...
>
> Which would you like to discuss? (Reply with numbers, "all", or "none" to
> skip)

**Do not offer a "skip all" option** — at minimum one area should be discussed.

## Step 5: Deep-Dive Each Selected Area

For each selected area, ask 4 targeted questions before checking in. Questions
should:

- Reference specific code/patterns you found in Step 2 ("You're already using X
  — should this follow that pattern?")
- Offer concrete options, not open-ended choices
- Probe the edge cases, not just the happy path

After 4 questions:

> Anything else about [area], or move to next?
>
> 1. More questions
> 2. Move on

If more: ask 4 more, then check again.

**Scope guardrail:** If the user suggests capabilities outside the phase
boundary, redirect:

> That's outside Phase [N]'s scope — I'll note it so we don't lose it. Capture
> in a "Deferred Ideas" list.

**Do NOT ask about:**

- Specific technical implementation details
- Architecture choices (Claude decides these)
- Performance optimizations
- Scope expansion

## Step 6: Write CONTEXT.md

Determine the phase directory:

- Phase number → zero-padded (e.g., "1" → "01")
- Phase name from ROADMAP → slugified (lowercase, hyphens)
- Full dir: `.planning/phases/{padded}-{slug}/`
- Create this directory if it doesn't exist

Write `.planning/phases/{padded}-{slug}/{padded}-CONTEXT.md`:

```markdown
# Phase [N]: [Name] — Context

**Gathered:** [date] **Status:** Ready for planning

## Phase Boundary

[What this phase delivers — from ROADMAP.md]

## Implementation Decisions

### [Gray Area 1 Name]

- [Decision locked]: [what was decided]
- [Preference]: [how the user wants it]

### [Gray Area 2 Name]

-

### Claude's Discretion

[Areas not discussed — implementation details the AI should decide]

## Code Context

[Patterns/libraries found in codebase relevant to this phase]

- [Component]: [how it's relevant]

## Deferred Ideas

[Ideas that came up but are out of scope for this phase]

- [Idea] — noted for later

---

_Phase: [padded]-[slug]_ _Context gathered: [date]_
```

## Step 7: Commit and Complete

If `commit_docs: true` in `.planning/config.json`:

```bash
git add ".planning/phases/{padded}-{slug}/{padded}-CONTEXT.md"
git commit -m "docs({padded}): capture phase context"
```

Output:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► PHASE [N] CONTEXT CAPTURED ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Areas discussed: [N]
Decisions locked: [list key ones]

───────────────────────────────────────────────────────
▶ Next Up

Open a new chat, then run: /gsd:plan-phase [N]
───────────────────────────────────────────────────────
```
