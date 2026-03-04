#!/usr/bin/env bash
# fetch-upstream-diff.sh — Helper for the gsd-maintainer:sync workflow
# Clones upstream GSD, compares versions, and outputs a diff of what changed.

set -euo pipefail

UPSTREAM_REPO="https://github.com/gsd-build/get-shit-done.git"
WORK_DIR="$HOME/.gemini/gsd-sync-tmp"
LOCAL_VERSION_FILE="$HOME/.agents/.gsd-synced-version"

echo "Fetching upstream GSD repository..." >&2

if [ -d "$WORK_DIR" ]; then
  rm -rf "$WORK_DIR"
fi
git clone "$UPSTREAM_REPO" "$WORK_DIR" --depth 1 -q

UPSTREAM_VERSION=$(grep -o '"version": "[^"]*"' "$WORK_DIR/package.json" | cut -d'"' -f4)

LOCAL_VERSION="0.0.0"
if [ -f "$LOCAL_VERSION_FILE" ]; then
  LOCAL_VERSION=$(cat "$LOCAL_VERSION_FILE")
fi

echo "=== SYNC STATUS ==="
echo "Local version: $LOCAL_VERSION"
echo "Upstream version: $UPSTREAM_VERSION"
echo ""

if [ "$LOCAL_VERSION" = "$UPSTREAM_VERSION" ]; then
  echo "NO_CHANGES"
  rm -rf "$WORK_DIR"
  exit 0
fi

echo "=== UPSTREAM SOURCE FILES ==="
# Map the core upstream files we care about tracking
declare -a FILES=(
  "commands/gsd/new-project.toml"
  "workflows/new-project.md"
  "commands/gsd/discuss-phase.toml"
  "workflows/discuss-phase.md"
  "commands/gsd/plan-phase.toml"
  "workflows/plan-phase.md"
  "commands/gsd/execute-phase.toml"
  "workflows/execute-phase.md"
  "commands/gsd/verify-work.toml"
  "workflows/verify-work.md"
  "commands/gsd/quick.toml"
  "workflows/quick.md"
  "commands/gsd/progress.toml"
  "commands/gsd/map-codebase.toml"
  "workflows/map-codebase.md"
)

for file in "${FILES[@]}"; do
  if [ -f "$WORK_DIR/$file" ]; then
    echo "--- UPSTREAM FILE: $file ---"
    cat "$WORK_DIR/$file"
    echo ""
  fi
done

# Output the version so the workflow knows what to update it to
echo "--- NEW_VERSION: $UPSTREAM_VERSION ---"

rm -rf "$WORK_DIR"
