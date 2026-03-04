# How Antigravity Differs from Claude Code / Gemini CLI

Antigravity is built on Google Gemini models and runs inside VS Code as an
agentic pair-programming assistant. Its tool set, session model, and
architectural primitives are meaningfully different from Claude Code and Gemini
CLI. This document covers the differences that matter for the GSD adaptation.

## 1. No Subagent Spawning

**Native GSD:** `Task()` API spawns independent AI instances in fresh context
windows. An orchestrator can run 4 parallel researchers, then a planner, then a
plan-checker — each with 200k tokens of clean context — while the orchestrator
itself stays at ~10-15% usage.

**Antigravity:** There is no equivalent API. All work happens within a single
session. The `browser_subagent` tool exists but it's specifically for browser
automation tasks, not general AI delegation.

**Impact:** Antigravity workflows execute phases sequentially. The
orchestrator's context does grow with each step. This is mitigated by keeping
plans small, recommending starting a new chat between major steps, and following
GSD's size constraints on all artifacts.

## 2. No Native CLI Binary

**Native GSD:** `gsd-tools.cjs` is called before every workflow step, returning
JSON with model selections, file paths, phase inventory, config values, and
more. It abstracts away all the "where am I?" logic.

**Antigravity:** No equivalent. Workflows read files directly using
Antigravity's file tools (`view_file`, `list_dir`, `grep_search`). State is
derived by reading `.planning/` files.

**Impact:** Workflow files are slightly more verbose (they include the
file-reading steps that `gsd-tools` would handle). Logic like "find the next
unplanned phase" or "list all PLAN.md files in this phase dir" is done inline.

## 3. No `/clear` Command

**Native GSD:** The `/clear` command clears the conversation context window,
recommended between phases. GSD outputs
`Sub: /clear first → fresh context window` in its step banners.

**Antigravity:** No `/clear`. The equivalent is opening a **new chat**.
Workflows output explicit next-step banners:

```
✓ Phase 1 planned.
→ Open a new chat, then run: /gsd:execute-phase 1
```

**Impact:** Same behaviour, different mechanic. The advice to start fresh
between major steps is preserved.

## 4. Model Selection

**Native GSD:** Users choose a model profile (Balanced/Quality/Budget), and
different agents use different models (Opus for research, Sonnet for planning,
Haiku for cheap steps).

**Antigravity:** Uses a single configured model for all operations. No
multi-model orchestration.

**Impact:** No model selection in `config.json`. All planning steps run on the
same model.

## 5. Git Integration

**Native GSD:** `gsd-tools commit` wraps git with automatic `commit_docs`
checking and gitignore awareness. Every task gets its own atomic commit with a
conventional commit message.

**Antigravity:** Can run `git commit` via `run_command`, but this requires user
approval for each shell command unless marked safe. Workflows include atomic
commits but flag them as optional (controlled by `commit_docs` in
`config.json`).

**Impact:** Same end result — atomic commits per task — but may require user
approval at each commit step depending on Antigravity's trust settings.

## 6. Session Persistence

**Native GSD:** Sessions are Claude Code or Gemini CLI sessions. STATE.md is the
bridge between sessions. The native `gsd-tools` can read config and state to
bootstrap any session.

**Antigravity:** Sessions are VS Code chat sessions. STATE.md plays the same
bridging role. `GEMINI.md` is used to instruct Antigravity to auto-load
`STATE.md` when it exists in the open project.

**Impact:** Same outcome. The `GEMINI.md` context-loading instruction replaces
the `gsd-tools init` bootstrap.

## 7. Structured Questions

**Native GSD:** Uses `AskUserQuestion()` — a Claude Code API for structured
multiple-choice prompts with labels, descriptions, and multi-select. Renders as
a formatted UI element.

**Antigravity:** Uses `notify_user` for blocking communication. Free-form or
numbered lists, no structured multi-select widget.

**Impact:** The same questions are asked; they just render as plain markdown
rather than interactive UI elements. Workflow files include numbered options for
the user to respond to.

## What's Identical

- The `.planning/` directory structure and file naming conventions
- All document templates (PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md)
- The XML task plan format (`<task type="auto">`, `<action>`, `<verify>`,
  `<done>`)
- `must_haves` frontmatter for goal-backward verification
- Wave-based dependency thinking in plan frontmatter
- The overall workflow sequence (new-project → discuss → plan → execute →
  verify)
- All size constraints on artifacts
- Checkpoint types (`checkpoint:human-verify`, `checkpoint:decision`,
  `checkpoint:human-action`)
