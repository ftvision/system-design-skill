#!/usr/bin/env bash
# Generates the three harness-specific install layouts from the canonical skill/ source.
#
#   ./scripts/sync.sh           regenerate the derived copies (default)
#   ./scripts/sync.sh --check    verify the derived copies match skill/ (no writes)
#
# skill/ is the ONLY source of truth — edit it, then run this. The three targets
# below are DERIVED COPIES; never edit them by hand. CI runs `--check` so any
# drift (a hand-edit, or a forgotten sync) fails the build.

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

mode="sync"
case "${1:-}" in
  --check) mode="check" ;;
  "")      mode="sync" ;;
  *) echo "usage: $0 [--check]" >&2; exit 2 ;;
esac

if [[ "$mode" == "check" ]]; then
  drift=0
  for dest in "${TARGETS[@]}"; do
    if [[ ! -d "$dest" ]]; then
      echo "DRIFT: $dest/ is missing — run ./scripts/sync.sh" >&2
      drift=1
      continue
    fi
    if ! diff -r "$SRC" "$dest" >/dev/null 2>&1; then
      echo "DRIFT: $dest/ differs from $SRC/ — run ./scripts/sync.sh" >&2
      diff -r "$SRC" "$dest" | sed 's/^/  /' >&2 || true
      drift=1
    fi
  done
  if [[ $drift -ne 0 ]]; then
    echo "error: derived copies are out of sync with $SRC/. Edit $SRC/ only, then run ./scripts/sync.sh." >&2
    exit 1
  fi
  echo "ok: all derived copies match $SRC/."
  exit 0
fi

for dest in "${TARGETS[@]}"; do
  echo "syncing $SRC/ -> $dest/"
  rm -rf "$dest"
  mkdir -p "$(dirname "$dest")"
  cp -R "$SRC" "$dest"
done

echo "done."
