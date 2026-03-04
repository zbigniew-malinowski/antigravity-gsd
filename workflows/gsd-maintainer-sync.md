---
description: Maintainer tool — Syncs upstream GSD updates into the Antigravity workflow files using local AI translation
---

## Purpose

This is an internal maintainer workflow. It automates keeping the
`antigravity-gsd` adapter repository up to date with the upstream native GSD
project. It fetches the upstream code, and asks you (the Antigravity agent) to
translate the Claude-specific CLI logic into our native Antigravity file-based
paradigm.

## Step 1: Ensure Correct Directory

Check the current working directory. You must be inside the `antigravity-gsd`
adapter repository to run this workflow. If you are not, tell the user to `cd`
into the repository and try again.

## Step 2: Fetch Upstream Data

Make the helper script executable and run it:

```bash
chmod +x scripts/fetch-upstream-diff.sh
./scripts/fetch-upstream-diff.sh
```

Read the output. If it says `NO_CHANGES`, tell the user we are already fully
synced with upstream and stop the workflow.

## Step 3: Analyze and Translate

The output from Step 2 contains the raw `.toml` and `.md` source files from the
latest upstream GSD release.

1. Read `docs/adaptation.md` to remind yourself of the translation rules (no
   `gsd-tools`, no `Task()` subagents, use `notify_user` for checkpoints).
2. Look at the upstream source files dumped in Step 2. Identify what new
   features, concepts, or XML XML structures have been added since our last
   sync.
3. For each workflow file in our local `workflows/` directory that has
   corresponding upstream changes, use your file editing tools to update the
   local `.md` file. **Apply the upstream logic improvements, but translate them
   to use Antigravity's paradigms.**

## Step 4: Finalize

Once you have finished updating the local workflow files:

1. Look for the `NEW_VERSION` string in the output from Step 2.
2. Update the local synced version file `~/.agents/.gsd-synced-version` to this
   new version string.
3. Tell the user what changes you translated and made to the repository.
4. Instruct the user to review the Git diff locally, and if they are happy, to
   `git commit` and `git push` the updates.
