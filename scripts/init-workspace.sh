#!/usr/bin/env bash
# init-workspace.sh — Per-project setup tool for Antigravity GSD
# Creates the local .agents/workflows directory and symlinks the global files.

set -euo pipefail

INSTALL_DIR="$HOME/.gemini/antigravity-gsd"
LOCAL_AGENTS_DIR=".agents/workflows"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " GSD ► WORKSPACE INITIALIZATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ ! -d "$INSTALL_DIR/workflows" ]; then
  echo "Error: Global installation missing at $INSTALL_DIR"
  echo "Please run the global installer first."
  exit 1
fi

echo "Initializing GSD workflows in $(pwd)..."

# Ensure local .agents directory exists
mkdir -p "$LOCAL_AGENTS_DIR"

# Symlink all workflow files
# We use logic to only symlink missing ones and update existing ones, without breaking existing non-GSD workflows
for file in "$INSTALL_DIR"/workflows/gsd-*.md; do
  filename=$(basename "$file")
  ln -sf "$file" "$LOCAL_AGENTS_DIR/$filename"
  echo "  ✓ Linked $filename"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " INIT COMPLETE ✓"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Slash commands are now available in this workspace."
echo "You may need to reload your Antigravity chat window to see them."
