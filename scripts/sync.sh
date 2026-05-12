#!/usr/bin/env bash
# Syncs the canonical skill/ source into the three harness-specific install layouts.
# Run from the repo root: ./scripts/sync.sh

set -euo pipefail

cd "$(dirname "$0")/.."

SRC="skill"
SKILL_NAME="system-design"

TARGETS=(
  ".claude/skills/$SKILL_NAME"     # Claude Code raw install
  ".agents/skills/$SKILL_NAME"     # Codex CLI raw install
  "plugin/skills/$SKILL_NAME"      # Claude Code plugin
)

if [[ ! -d "$SRC" ]]; then
  echo "error: canonical source $SRC/ not found" >&2
  exit 1
fi

for dest in "${TARGETS[@]}"; do
  echo "syncing $SRC/ -> $dest/"
  rm -rf "$dest"
  mkdir -p "$(dirname "$dest")"
  cp -R "$SRC" "$dest"
done

echo "done."
