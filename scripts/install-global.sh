#!/usr/bin/env bash
# install-global.sh — Global installer for Antigravity GSD
# Can be downloaded and piped to bash, or run locally.

set -euo pipefail

INSTALL_DIR="$HOME/.gemini/antigravity-gsd"
BIN_DIR="$HOME/.local/bin"
GEMINI_MD="$HOME/.gemini/GEMINI.md"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " GSD ► GLOBAL ANTIGRAVITY INSTALL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Clone or update repository
if [ -d "$INSTALL_DIR" ]; then
  echo "Updating existing installation at $INSTALL_DIR..."
  cd "$INSTALL_DIR"
  git pull
else
  echo "Cloning repository to $INSTALL_DIR..."
  git clone https://github.com/zbigniew-malinowski/antigravity-gsd.git "$INSTALL_DIR"
fi

# 2. Setup the helper executable
echo "Setting up workspace init tool..."
mkdir -p "$BIN_DIR"
ln -sf "$INSTALL_DIR/scripts/init-workspace.sh" "$BIN_DIR/antigravity-gsd-init"
chmod +x "$INSTALL_DIR/scripts/init-workspace.sh"

export PATH="$BIN_DIR:$PATH"

# 3. Install the Global Antigravity Skill
echo "Installing global Antigravity Skill..."
SKILLS_DIR="$HOME/.agents/skills/gsd-setup"
mkdir -p "$SKILLS_DIR"
ln -sf "$INSTALL_DIR/skills/SKILL.md" "$SKILLS_DIR/SKILL.md"

echo "  ✓ Global GSD Skill installed"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " INSTALL COMPLETE ✓"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Make sure $BIN_DIR is in your shell's PATH."
echo "If not, add this to your ~/.zshrc or ~/.bash_profile:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
echo ""
echo "To set up GSD in any project, open Antigravity there and say:"
echo "  \"Let's start a GSD project\""
