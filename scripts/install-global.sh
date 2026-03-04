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

# 3. Update global GEMINI.md instructions
GSD_SECTION_MARKER="<!-- antigravity-gsd-global-context -->"

mkdir -p "$(dirname "$GEMINI_MD")"
touch "$GEMINI_MD"

if grep -q "$GSD_SECTION_MARKER" "$GEMINI_MD" 2>/dev/null; then
  echo "GEMINI.md already has GSD instructions (updating in place)..."
  TEMP=$(mktemp)
  sed "/$GSD_SECTION_MARKER/,/$GSD_SECTION_MARKER/d" "$GEMINI_MD" > "$TEMP"
  mv "$TEMP" "$GEMINI_MD"
fi

cat >> "$GEMINI_MD" << 'EOF'

<!-- antigravity-gsd-global-context -->
# GSD Project Context

If `.planning/STATE.md` exists in the local workspace, read it at the
start of every session. This is a GSD project — STATE.md contains current
position, recent decisions, and what to do next.

## Workspace Initialization

If the user wants to start a GSD project (or asks about GSD), check if `.agents/workflows/gsd-new-project.md` exists locally. 
If it DOES NOT exist, you MUST run the `antigravity-gsd-init` command in the terminal to initialize the workspace with the necessary slash commands, then instruct the user to type `/gsd:new-project`.

## Single-Session Model

Each major step should be a fresh chat for context hygiene:
  /gsd:plan-phase N → new chat → /gsd:execute-phase N → new chat → /gsd:verify-work N
<!-- antigravity-gsd-global-context -->
EOF

echo "  ✓ GEMINI.md updated"

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
