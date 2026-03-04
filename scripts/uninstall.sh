#!/usr/bin/env bash
# uninstall.sh — Remove global GSD installation and commands
# Deletes ~/.gemini/antigravity-gsd, the global symlink, and clears GEMINI.md

set -euo pipefail

INSTALL_DIR="$HOME/.gemini/antigravity-gsd"
BIN_DIR="$HOME/.local/bin"
GEMINI_MD="$HOME/.gemini/GEMINI.md"
SYNCED_VERSION_FILE="$HOME/.agents/.gsd-synced-version"
GSD_SECTION_MARKER="<!-- antigravity-gsd-global-context -->"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " GSD ► ANTIGRAVITY GLOBAL UNINSTALL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

HAS_GEMINI_SECTION=false
if grep -q "$GSD_SECTION_MARKER" "$GEMINI_MD" 2>/dev/null; then
  HAS_GEMINI_SECTION=true
fi

if [ ! -d "$INSTALL_DIR" ] && [ "$HAS_GEMINI_SECTION" = false ] && [ ! -f "$BIN_DIR/antigravity-gsd-init" ]; then
  echo "Nothing to uninstall — no global GSD installation found."
  exit 0
fi

echo "The following will be removed:"
echo ""
if [ -d "$INSTALL_DIR" ]; then
  echo "  Directory $INSTALL_DIR"
fi
if [ -L "$BIN_DIR/antigravity-gsd-init" ] || [ -f "$BIN_DIR/antigravity-gsd-init" ]; then
  echo "  Executable $BIN_DIR/antigravity-gsd-init"
fi
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

if [ -d "$INSTALL_DIR" ]; then
  rm -rf "$INSTALL_DIR"
  echo "  ✓ Removed global installation directory"
fi

if [ -L "$BIN_DIR/antigravity-gsd-init" ] || [ -f "$BIN_DIR/antigravity-gsd-init" ]; then
  rm -f "$BIN_DIR/antigravity-gsd-init"
  echo "  ✓ Removed executable tool"
fi

# Remove GSD section from GEMINI.md
if [ "$HAS_GEMINI_SECTION" = true ]; then
  TEMP=$(mktemp)
  sed "/$GSD_SECTION_MARKER/,/$GSD_SECTION_MARKER/d" "$GEMINI_MD" > "$TEMP"
  mv "$TEMP" "$GEMINI_MD"
  echo "  ✓ Removed GSD section from GEMINI.md"
fi

if [ -f "$SYNCED_VERSION_FILE" ]; then
  rm -f "$SYNCED_VERSION_FILE"
  echo "  ✓ Removed version tracking file"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " UNINSTALL COMPLETE ✓"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Note: Per-project local symlinks in .agents/workflows are untouched."
echo "However, they will no longer function since the target files have been deleted."
