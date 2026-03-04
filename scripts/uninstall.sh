#!/usr/bin/env bash
# uninstall.sh — Remove global GSD installation and commands
# Deletes ~/.gemini/antigravity-gsd, the global symlink, and clears GEMINI.md

set -euo pipefail

INSTALL_DIR="$HOME/.gemini/antigravity-gsd"
BIN_DIR="$HOME/.local/bin"
SYNCED_VERSION_FILE="$HOME/.agents/.gsd-synced-version"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " GSD ► ANTIGRAVITY GLOBAL UNINSTALL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

SKILLS_DIR="$HOME/.agents/skills/gsd-setup"

HAS_SKILL=false
if [ -d "$SKILLS_DIR" ]; then
  HAS_SKILL=true
fi

if [ ! -d "$INSTALL_DIR" ] && [ "$HAS_SKILL" = false ] && [ ! -f "$BIN_DIR/antigravity-gsd-init" ]; then
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
if [ "$HAS_SKILL" = true ]; then
  echo "  Global Antigravity Skill at $SKILLS_DIR"
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

if [ -d "$HOME/.agents/skills/gsd-setup" ]; then
  rm -rf "$HOME/.agents/skills/gsd-setup"
  echo "  ✓ Removed global GSD Antigravity Skill"
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
