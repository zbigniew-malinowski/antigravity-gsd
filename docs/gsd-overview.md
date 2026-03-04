# What is GSD?

GSD ("Get Shit Done") is a lightweight meta-prompting, context engineering, and
spec-driven development system created by TÂCHES. It was originally built for
Claude Code (Anthropic's agentic CLI), and has since been ported to Gemini CLI
and Codex.

The core problem it solves is **context rot**: as an AI fills its context window
with accumulated conversation, its quality degrades. Long sessions produce
inconsistent code, forgotten constraints, and drift from the original spec. GSD
addresses this by engineering context carefully — giving the AI exactly what it
needs at each step, no more.

## Design Philosophy

GSD is explicitly _not_ enterprise project management. There are no sprint
ceremonies, story points, stakeholder syncs, or Jira workflows. It's designed
for a single developer (or small team) who wants to describe what they want and
have it built correctly.

The complexity is in the system, not in the workflow. Behind the scenes: context
engineering, XML prompt formatting, multi-agent orchestration, state management.
What you interact with: a handful of slash commands.

## Core Concepts

### The `.planning/` Directory

Every GSD project gets a `.planning/` directory in the project root. This is the
single source of truth for all planning state:

```
.planning/
├── PROJECT.md          # Goals, constraints, key decisions
├── REQUIREMENTS.md     # Scoped feature list with requirement IDs
├── ROADMAP.md          # Phase structure with success criteria
├── STATE.md            # Living memory (≤100 lines, updated after every action)
├── config.json         # Workflow preferences
├── research/           # Domain research artifacts
│   ├── STACK.md
│   ├── FEATURES.md
│   ├── ARCHITECTURE.md
│   ├── PITFALLS.md
│   └── SUMMARY.md
└── phases/
    └── 01-foundation/
        ├── 01-CONTEXT.md    # Design decisions from discuss-phase
        ├── 01-RESEARCH.md   # Technical research for this phase
        ├── 01-01-PLAN.md    # Executable task plan
        ├── 01-02-PLAN.md
        ├── 01-01-SUMMARY.md # Post-execution summary
        ├── 01-VERIFICATION.md
        └── 01-UAT.md
```

### STATE.md — Project Memory

The most important file for context hygiene. Kept under 100 lines, it's read at
the start of every session to instantly restore context. Contains:

- Current position (phase, plan, status)
- Recent key decisions (full log in PROJECT.md)
- Active blockers
- Session continuity (last action, resume point)

### XML Task Plans

Each PLAN.md file contains atomic tasks in a structured XML format designed to
be parsed precisely:

```xml
<task type="auto">
  <name>Create login endpoint</name>
  <files>src/app/api/auth/login/route.ts</files>
  <action>
    Use jose for JWT (not jsonwebtoken — CommonJS issues).
    Validate credentials against users table.
    Return httpOnly cookie on success.
  </action>
  <verify>curl -X POST localhost:3000/api/auth/login returns 200 + Set-Cookie</verify>
  <done>Valid credentials return cookie, invalid return 401</done>
</task>
```

This format eliminates vagueness. Every task has a specific action, a verifiable
outcome, and a measurable done condition.

### Goal-Backward Verification (`must_haves`)

Plans include `must_haves` frontmatter that defines what must be _true_ (not
just _done_) for the phase goal to be achieved:

```yaml
must_haves:
    truths:
        - "User can log in with email and password"
        - "Session persists across page refresh"
    artifacts:
        - path: "src/app/api/auth/login/route.ts"
          provides: "Login endpoint"
          min_lines: 30
    key_links:
        - from: "src/components/LoginForm.tsx"
          to: "/api/auth/login"
          via: "fetch in onSubmit handler"
```

After execution, a verifier checks these against the actual codebase — not just
that files were created, but that they actually connect and work.

### Wave-Based Execution

Plans within a phase are grouped into waves based on dependencies. Wave 1 plans
run in parallel (or sequence). Wave 2 plans run after Wave 1 completes, and so
on. This is specified in plan frontmatter:

```yaml
wave: 1
depends_on: []
files_modified: [src/models/user.ts]
autonomous: true
```

### Context Engineering

Each workflow step loads only what it needs:

- Orchestrators receive file paths, not file contents
- Subagents load their specific files fresh at execution start
- STATE.md provides a compressed digest rather than raw history

The result: even a fully automated phase execution (research → plan → execute →
verify) keeps the orchestrator's context at ~30-40%.

## The Workflow

```
/gsd:new-project
  → Questions → Research → Requirements → Roadmap

/gsd:discuss-phase 1
  → Gray area analysis → Design decisions → CONTEXT.md

/gsd:plan-phase 1
  → Research → PLAN.md files → Plan verification

/gsd:execute-phase 1
  → Wave execution → SUMMARY.md per plan → VERIFICATION.md

/gsd:verify-work 1
  → Human UAT walkthrough → Fix plans if needed

/gsd:discuss-phase 2 → /gsd:plan-phase 2 → ...
```

Each step hands context forward to the next through files, not conversation
history.
