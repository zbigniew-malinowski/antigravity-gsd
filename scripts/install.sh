#!/usr/bin/env bash
# install.sh — Install GSD workflows for Antigravity
# Copies workflow files to ~/.agents/workflows/ and updates ~/.gemini/GEMINI.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
WORKFLOWS_SRC="$REPO_DIR/workflows"
WORKFLOWS_DST="$HOME/.agents/workflows"
GEMINI_MD="$HOME/.gemini/GEMINI.md"
VERSION_FILE="$HOME/.gemini/get-shit-done/VERSION"
SYNCED_VERSION_FILE="$HOME/.agents/.gsd-synced-version"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " GSD ► ANTIGRAVITY INSTALL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check prerequisites
if [ ! -d "$WORKFLOWS_SRC" ]; then
  echo "Error: workflows/ directory not found at $WORKFLOWS_SRC"
  exit 1
fi

# Create target directory if needed
if [ ! -d "$WORKFLOWS_DST" ]; then
  echo "Creating $WORKFLOWS_DST..."
  mkdir -p "$WORKFLOWS_DST"
fi

# Check for existing GSD workflow files
EXISTING=$(ls "$WORKFLOWS_DST"/gsd-*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$EXISTING" -gt 0 ]; then
  echo "Found $EXISTING existing GSD workflow file(s) in $WORKFLOWS_DST"
  echo "These will be overwritten."
  echo ""
  read -r -p "Continue? [y/N] " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted."
    exit 0
  fi
fi

# Copy workflow files
echo "Installing workflow files..."
for file in "$WORKFLOWS_SRC"/gsd-*.md; do
  filename=$(basename "$file")
  cp "$file" "$WORKFLOWS_DST/$filename"
  echo "  ✓ $filename"
done

# Update GEMINI.md
GSD_SECTION_MARKER="<!-- antigravity-gsd -->"

if grep -q "$GSD_SECTION_MARKER" "$GEMINI_MD" 2>/dev/null; then
  echo ""
  echo "GEMINI.md already has GSD context (updating in place)..."
  # Remove existing block and re-add
  TEMP=$(mktemp)
  sed "/$GSD_SECTION_MARKER/,/$GSD_SECTION_MARKER/d" "$GEMINI_MD" > "$TEMP"
  mv "$TEMP" "$GEMINI_MD"
fi

cat >> "$GEMINI_MD" << 'EOF'

<!-- antigravity-gsd -->
# GSD Project Context

If `.planning/STATE.md` exists in the current project directory, read it at the
start of every session. This is a GSD project — STATE.md contains current
position, recent decisions, and what to do next.

## Available GSD Commands

- `/gsd:new-project` — Initialize a new project (questioning → research → requirements → roadmap)
- `/gsd:discuss-phase [N]` — Capture design decisions for a phase before planning
- `/gsd:plan-phase [N]` — Create atomic XML task plans for a phase
- `/gsd:execute-phase [N]` — Execute all plans in a phase with verification
- `/gsd:verify-work [N]` — Human UAT walkthrough; creates fix plans for failures
- `/gsd:quick [task]` — Small tasks with GSD guarantees (no full planning needed)
- `/gsd:progress` — Current project status and next recommended command
- `/gsd:map-codebase` — Analyse existing codebase before initializing GSD on brownfield project

## Session Model

Each major step should be a fresh chat for context hygiene:
  /gsd:plan-phase N → new chat → /gsd:execute-phase N → new chat → /gsd:verify-work N
<!-- antigravity-gsd -->
EOF

echo "  ✓ GEMINI.md updated"

# Record synced GSD version
if [ -f "$VERSION_FILE" ]; then
  GSD_VERSION=$(cat "$VERSION_FILE" | tr -d '[:space:]')
  echo "$GSD_VERSION" > "$SYNCED_VERSION_FILE"
  echo "  ✓ Recorded GSD version: $GSD_VERSION"
else
  echo "  ⚠ GSD not found at default location ($VERSION_FILE) — sync tracking disabled"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " INSTALL COMPLETE ✓"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "GSD workflows installed to: $WORKFLOWS_DST"
echo ""
echo "To get started, open Antigravity in your project directory and run:"
echo "  /gsd:new-project"
echo ""
echo "Or check status of an existing GSD project:"
echo "  /gsd:progress"
