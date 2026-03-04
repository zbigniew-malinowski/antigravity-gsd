# Maintainer Guide: Syncing with Upstream GSD

This guide is for developers maintaining the `antigravity-gsd` repository. It
explains the technical process of porting updates from the
[official GSD repository](https://github.com/gsd-build/get-shit-done).

## The Sync Architecture

Because Antigravity and Claude Code have different internal toolsets
(Antigravity is file-based and sequential; Claude Code is CLI-based and supports
parallel subagents), we cannot simply copy upstream code. Every update must be
"translated."

We use a local bash script that leverages the `gemini` CLI to perform this
translation.

## How to Sync Upstream Changes

1. **Open Antigravity** in your local `antigravity-gsd` repository directory.
2. **Execute the sync script**:
   ```bash
   ./scripts/maintainer-sync.sh
   ```

### What the script does:

- Clones the latest upstream GSD into a temporary directory.
- Compares the upstream version against our `.gsd-synced-version`.
- If a new version is detected, it constructs a prompt containing the upstream
  source code and our `docs/adaptation.md` rules.
- Invokes the `gemini` CLI to read the diff and intelligently rewrite our local
  `workflows/gsd-*.md` files.
- Updates the `.gsd-synced-version` file.

## Review and Publish

1. **Review the Diff**: The AI translation is excellent but not perfect. Use
   `git diff` to review the changes to the workflow files.
2. **Test Locally**: Initialize a test project using your local version to
   ensure the new logic works as expected.
3. **Commit and Push**:
   ```bash
   git add .
   git commit -m "chore: sync upstream GSD vX.Y.Z"
   git push origin main
   ```

Once pushed, all global users will receive the update when they next run
`/gsd:update` or ask Antigravity to update their installation.
