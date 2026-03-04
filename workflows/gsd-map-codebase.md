---
description: Analyse an existing codebase before starting a GSD project — creates architecture and stack maps in .planning/codebase/
---

## Purpose

For brownfield projects. Reads the existing codebase and produces structured
maps that `new-project` can use to skip redundant discovery questions and focus
on what's being _added_.

## Step 1: Check

If `.planning/codebase/ARCHITECTURE.md` already exists, ask:

> Codebase map already exists. What would you like to do?
>
> 1. Re-map — analyse again (codebase may have changed)
> 2. View existing — show current maps
> 3. Skip — use existing maps

## Step 2: Discover Project Structure

Explore the codebase systematically:

1. Read root-level files: `package.json`, `pyproject.toml`, `go.mod`,
   `Cargo.toml`, `composer.json` — whatever applies. Extract language,
   framework, dependencies.
2. List top-level directories — understand overall structure
3. Read key config files: `tsconfig.json`, `.env.example`, `next.config.js`,
   `vite.config.ts`, etc.
4. Identify entry points: `src/main.*`, `src/index.*`, `src/app.*`,
   `pages/_app.*`, etc.
5. Sample 2-3 representative files from each major area (models, API routes,
   components, services, etc.)

## Step 3: Identify Architecture Patterns

Based on what you've read, identify:

- **Overall pattern**: MVC, layered, domain-driven, hexagonal, feature-sliced,
  etc.
- **Data layer**: ORM, raw SQL, NoSQL, no persistence, etc.
- **API layer**: REST, GraphQL, tRPC, RPC, none
- **UI layer**: React, Vue, server-rendered, CLI, none
- **Key boundaries**: What talks to what. What's coupled, what's isolated.
- **State management**: Redux, Zustand, server state only, none
- **Auth approach**: JWT, sessions, OAuth, none
- **Testing**: Jest, Vitest, pytest, none — what's already tested

## Step 4: Catalogue What's Already Built

List existing capabilities as potential "Validated" requirements for PROJECT.md:

- User can [do X] — [which file/route delivers this]
- System supports [Y] — [where it's implemented]

## Step 5: Identify Patterns and Conventions

Note the conventions established so future phases follow them:

- File naming conventions
- Component patterns (how components are structured)
- How imports are organized
- Error handling patterns
- How env vars are used
- Testing patterns

## Step 6: Write Maps

Create `.planning/codebase/` directory.

Write `.planning/codebase/STACK.md`:

```markdown
# Codebase Stack

**Language:** [language + version] **Runtime:** [Node 20 / Python 3.11 / etc.]
**Framework:** [Next.js 15 / FastAPI / etc.]

## Dependencies

### Core

- [library@version] — [what it does]
- [library@version] — [what it does]

### Dev

- [library@version] — [purpose]

## Configuration

- Build: [tool]
- Lint: [tool]
- Test: [tool]
- Deploy: [if known]
```

Write `.planning/codebase/ARCHITECTURE.md`:

```markdown
# Architecture

**Pattern:** [overall architectural pattern]

## Component Map

[ASCII or markdown diagram of main components and how they connect]

## Layers

### [Layer name (e.g., Data, API, UI)]

**Purpose:** [what it does] **Location:** `src/[path]/` **Key files:**

- `[file]` — [what it does]

## Existing Capabilities

(Future Validated requirements for PROJECT.md)

- ✓ [User can do X] — `[file]`
- ✓ [System supports Y] — `[file]`

## Conventions

- File naming: [pattern]
- Component structure: [pattern]
- Error handling: [approach]
- Testing: [approach]

## Patterns to Follow

[Code patterns established in the codebase that new phases should replicate]
```

## Step 7: Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 GSD ► CODEBASE MAPPED ✓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Stack: [language] / [framework]
Architecture: [pattern]
Existing capabilities: [N] identified

Files:
  .planning/codebase/STACK.md
  .planning/codebase/ARCHITECTURE.md

───────────────────────────────────────────────────────
▶ Next Up

Open a new chat, then run: /gsd:new-project
(The project initialization will read these maps automatically)
───────────────────────────────────────────────────────
```
