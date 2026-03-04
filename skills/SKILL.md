---
name: gsd-workspace-setup
description: Automatically run when the user wants to start, setup, or use a GSD (Get Shit Done) project.
---

# GSD Workspace Setup Skill

You are equipped with a global executable tool called `antigravity-gsd-init`.

## When to use this skill

- When the user says "Let's start a GSD project"
- When the user says "Set up GSD" or "Install GSD here"
- When the user tries to run `/gsd:new-project` but the command cannot be found.
- When the user asks to "update GSD" or "pull the latest GSD updates"

## Execution Steps

1. Check if the `.agents/workflows/gsd-new-project.md` file exists in the
   current workspace directory.
2. If it DOES NOT exist, you **MUST** run the `antigravity-gsd-init` command in
   the terminal to initialize the workspace with the necessary GSD slash
   commands.
3. Wait for the terminal command to complete.
4. Tell the user that the workspace is now initialized.
5. Instruct the user to type `/gsd:new-project` (or whichever `/gsd:*` command
   they requested).

## Execution Steps: Updating GSD

If the user explicitly asks to update their Antigravity GSD installation:

1. Run `cd ~/.gemini/antigravity-gsd && git pull` in the terminal to fetch the
   latest upstream translations.
2. Tell the user that the global installation has been updated.
3. If they are currently inside a project workspace, run `antigravity-gsd-init`
   to refresh the local symlinks, just to be safe.

## Background Context

If `.planning/STATE.md` exists in the local workspace, ALWAYS read it at the
start of every session without prompting. This is a GSD project — STATE.md
contains the current position, recent decisions, and what to do next.

Each major step in GSD requires a fresh chat for context hygiene:
`/gsd:plan-phase N` → new chat → `/gsd:execute-phase N` → new chat →
`/gsd:verify-work N`
