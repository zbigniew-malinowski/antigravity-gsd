#!/usr/bin/env bash
# uninstall.sh — Remove GSD workflows for Antigravity
# Deletes workflow files from ~/.agents/workflows/ and clears GSD section from ~/.gemini/GEMINI.md

set -euo pipefail

WORKFLOWS_DST="$HOME/.agents/workflows"
GEMINI_MD="$HOME/.gemini/GEMINI.md"
SYNCED_VERSION_FILE="$HOME/.agents/.gsd-synced-version"
GSD_SECTION_MARKER="<!-- antigravity-gsd -->"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " GSD ► ANTIGRAVITY UNINSTALL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# List what will be removed
WORKFLOW_FILES=($(ls "$WORKFLOWS_DST"/gsd-*.md 2>/dev/null || true))
HAS_GEMINI_SECTION=false
if grep -q "$GSD_SECTION_MARKER" "$GEMINI_MD" 2>/dev/null; then
  HAS_GEMINI_SECTION=true
fi

if [ ${#WORKFLOW_FILES[@]} -eq 0 ] && [ "$HAS_GEMINI_SECTION" = false ] && [ ! -f "$SYNCED_VERSION_FILE" ]; then
  echo "Nothing to uninstall — no GSD Antigravity files found."
  exit 0
fi

echo "The following will be removed:"
echo ""
for file in "${WORKFLOW_FILES[@]}"; do
  echo "  $file"
done
if [ "$HAS_GEMINI_SECTION" = true ]; then
  echo "  GSD section from $GEMINI_MD"
fi
if [ -f "$SYNCED_VERSION_FILE" ]; then
  echo "  $SYNCED_VERSION_FILE"
fi
echo ""

read -r -p "Continue? [y/N] " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Aborted."
  exit 0
fi

echo ""

# Remove workflow files
for file in "${WORKFLOW_FILES[@]}"; do
  rm "$file"
  echo "  ✓ Removed $(basename "$file")"
done

# Remove GSD section from GEMINI.md
if [ "$HAS_GEMINI_SECTION" = true ]; then
  TEMP=$(mktemp)
  sed "/$GSD_SECTION_MARKER/,/$GSD_SECTION_MARKER/d" "$GEMINI_MD" > "$TEMP"
  mv "$TEMP" "$GEMINI_MD"
  echo "  ✓ Removed GSD section from GEMINI.md"
fi

# Remove version tracking file
if [ -f "$SYNCED_VERSION_FILE" ]; then
  rm "$SYNCED_VERSION_FILE"
  echo "  ✓ Removed version tracking file"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " UNINSTALL COMPLETE ✓"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Note: Existing Gemini CLI GSD commands (~/.gemini/commands/gsd/) are untouched."
echo "Note: Project .planning/ directories are untouched."
