#!/usr/bin/env bash
# sync-gsd.sh — Check for GSD updates and show what changed since last sync
#
# Reads the installed GSD version, compares against what these workflows were
# built from, and diffs the key source files to show what changed.
# Does NOT auto-update anything — review the diff and update manually.
#
# Usage:
#   ./scripts/sync-gsd.sh          # check for updates
#   ./scripts/sync-gsd.sh --force  # show full diff even if version unchanged

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

GSD_DIR="$HOME/.gemini/get-shit-done"
GSD_VERSION_FILE="$GSD_DIR/VERSION"
SYNCED_VERSION_FILE="$HOME/.agents/.gsd-synced-version"
FORCE=false

# Parse arguments
for arg in "$@"; do
  case $arg in
    --force) FORCE=true ;;
    *) echo "Unknown argument: $arg"; exit 1 ;;
  esac
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " GSD ► SYNC CHECK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check GSD is installed
if [ ! -f "$GSD_VERSION_FILE" ]; then
  echo "GSD not found at $GSD_DIR"
  echo ""
  echo "Install GSD first: npx get-shit-done-cc@latest"
  exit 1
fi

CURRENT_VERSION=$(cat "$GSD_VERSION_FILE" | tr -d '[:space:]')
echo "GSD installed: v$CURRENT_VERSION"

# Check synced version
if [ -f "$SYNCED_VERSION_FILE" ]; then
  SYNCED_VERSION=$(cat "$SYNCED_VERSION_FILE" | tr -d '[:space:]')
  echo "Last synced:   v$SYNCED_VERSION"
else
  SYNCED_VERSION="(unknown)"
  echo "Last synced:   (not tracked)"
fi

echo ""

# Determine if we should show diffs
if [ "$FORCE" = true ]; then
  echo "Showing full diff (--force)"
  SHOW_DIFF=true
elif [ "$SYNCED_VERSION" = "(unknown)" ]; then
  echo "No sync history — showing full diff"
  SHOW_DIFF=true
elif [ "$CURRENT_VERSION" != "$SYNCED_VERSION" ]; then
  echo "New GSD version detected! (v$SYNCED_VERSION → v$CURRENT_VERSION)"
  SHOW_DIFF=true
else
  echo "Already up to date with v$CURRENT_VERSION"
  SHOW_DIFF=false
fi

if [ "$SHOW_DIFF" = false ]; then
  echo ""
  echo "Run with --force to show diffs anyway."
  exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " CHANGES IN KEY SOURCE FILES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Key GSD source files that our Antigravity workflows are based on
declare -a SOURCE_FILES=(
  "workflows/new-project.md"
  "workflows/plan-phase.md"
  "workflows/execute-phase.md"
  "workflows/quick.md"
  "workflows/discuss-phase.md"
  "workflows/verify-work.md"
  "templates/phase-prompt.md"
  "templates/state.md"
  "templates/roadmap.md"
  "references/planning-config.md"
)

# Store snapshots of source files for comparison
SNAPSHOT_DIR="$REPO_DIR/.gsd-snapshots"
DIFF_FOUND=false

for relative_path in "${SOURCE_FILES[@]}"; do
  source_file="$GSD_DIR/$relative_path"
  snapshot_file="$SNAPSHOT_DIR/$relative_path"

  if [ ! -f "$source_file" ]; then
    echo ""
    echo "⚠ Source file missing: $relative_path"
    continue
  fi

  if [ -f "$snapshot_file" ]; then
    # Compare snapshot to current
    if ! diff -q "$snapshot_file" "$source_file" > /dev/null 2>&1; then
      DIFF_FOUND=true
      echo ""
      echo "── $relative_path ─────────────────────────────────"
      diff --unified=3 "$snapshot_file" "$source_file" | head -80 || true
      LINES=$(diff "$snapshot_file" "$source_file" | grep -c "^[+-]" || true)
      echo ""
      echo "  ($LINES lines changed)"
      echo "────────────────────────────────────────────────────"
    else
      echo "  ✓ $relative_path — no change"
    fi
  else
    DIFF_FOUND=true
    echo ""
    echo "── $relative_path (NEW — no previous snapshot) ─────"
    echo "  This file exists in GSD but has no snapshot to compare against."
    echo "  Run --update-snapshots to record it."
    echo "───────────────────────────────────────────────────"
  fi
done

echo ""

if [ "$DIFF_FOUND" = false ]; then
  echo "No changes detected in key source files."
else
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo " REVIEW CHANGES ABOVE"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Review the diffs and manually update the Antigravity"
  echo "workflow files in workflows/ as appropriate."
  echo ""
  echo "Not all GSD changes will apply — Claude Code-specific"
  echo "features (Task() spawning, gsd-tools.cjs calls) should"
  echo "be adapted, not copied directly."
  echo ""
  echo "When you've incorporated the relevant changes, update"
  echo "snapshots and record the new version:"
  echo ""
  echo "  ./scripts/sync-gsd.sh --update-snapshots"
fi

# Handle --update-snapshots flag
for arg in "$@"; do
  if [ "$arg" = "--update-snapshots" ]; then
    echo ""
    echo "Updating snapshots..."
    for relative_path in "${SOURCE_FILES[@]}"; do
      source_file="$GSD_DIR/$relative_path"
      snapshot_file="$SNAPSHOT_DIR/$relative_path"
      if [ -f "$source_file" ]; then
        mkdir -p "$(dirname "$snapshot_file")"
        cp "$source_file" "$snapshot_file"
        echo "  ✓ Snapshot updated: $relative_path"
      fi
    done
    echo "$CURRENT_VERSION" > "$SYNCED_VERSION_FILE"
    echo "  ✓ Synced version recorded: v$CURRENT_VERSION"
    echo ""
    echo "Snapshots updated. Next sync will diff against these."
  fi
done
