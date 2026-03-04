---
description: Pull the latest Antigravity GSD workflow updates and refresh local workspace symlinks
---

## Purpose

Update the global Antigravity GSD installation to the latest version and refresh
the current project's local workflow symlinks.

## Step 1: Update Global Installation

Run the following command to pull the latest changes from the central
repository:

```bash
cd ~/.gemini/antigravity-gsd && git pull
```

## Step 2: Refresh Local Workspace

Ensure that the current project's `.agents/workflows/` directory is pointing to
the newly pulled files:

```bash
antigravity-gsd-init
```

## Step 3: Complete

Tell the user that their GSD installation is now up to date and all slash
commands in the current workspace have been refreshed.
