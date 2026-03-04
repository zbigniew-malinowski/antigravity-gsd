#!/usr/bin/env bash
# maintainer-sync.sh — Script for the repo maintainer to sync upstream GSD updates.
# Uses the local gemini CLI to read the upstream diffs and translate them into Antigravity workflows.

set -euo pipefail

# Ensure we're in the repo root
cd "$(dirname "$0")/.."

echo "Fetching upstream GSD repository..."
# (fetch-upstream-diff.sh generates the text blob of all upstream source files)
UPSTREAM_OUTPUT=$(./scripts/fetch-upstream-diff.sh)

if [[ "$UPSTREAM_OUTPUT" == *"NO_CHANGES"* ]]; then
  echo "We are already synced with upstream."
  exit 0
fi

echo "Upstream changes detected. Invoking Gemini CLI to translate..."

PROMPT_FILE=$(mktemp)

cat << 'EOF' > "$PROMPT_FILE"
You are maintaining the Antigravity port of the GSD framework. 
Please read `docs/adaptation.md` to understand the strict rules and architecture of this port.

I have fetched the latest upstream GSD source code. Here are the raw files:

```
EOF

echo "$UPSTREAM_OUTPUT" >> "$PROMPT_FILE"

cat << 'EOF' >> "$PROMPT_FILE"
```

Your task:
1. Review the upstream source code above.
2. Check our local `workflows/*.md` files.
3. If there are new logical features or improvements, edit the corresponding `workflows/gsd-*.md` files to implement them. Remember: no Task() subagents, no gsd-tools CLI calls, just direct sequential Antigravity workflow steps.
4. Extract the NEW_VERSION from the output above, and write it to `.agents/.gsd-synced-version` in this repo.

Please modify the local files directly to apply the sync.
EOF

# Use the gemini CLI to process the prompt and make the file edits locally
gemini "$(cat "$PROMPT_FILE")"

rm "$PROMPT_FILE"
echo "Sync script completed. Please review the git diff before committing."
