#!/usr/bin/env bash
# Install the quality-loop + quality-agent skills for ZCode.
#
#   ./install.sh                     → user-level (~/.agents/skills/) — every project
#   ./install.sh --project <dir>     → project-level (<dir>/.agents/skills/)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_ROOT="$HOME/.agents/skills"
MODE="user"

if [[ "${1:-}" == "--project" ]]; then
  [[ -n "${2:-}" ]] || { echo "usage: $0 [--project <project-dir>]"; exit 1; }
  DEST_ROOT="$(cd "$2" && pwd)/.agents/skills"
  MODE="project"
fi

echo "Installing skills (${MODE}-level) → $DEST_ROOT"
for skill in quality-loop quality-agent; do
  src="$SCRIPT_DIR/skills/$skill"
  dest="$DEST_ROOT/$skill"
  [[ -d "$src" ]] || { echo "missing: $src"; exit 1; }
  if [[ -d "$dest" ]]; then
    echo "  updating existing: $dest"
    rm -rf "$dest"
  fi
  mkdir -p "$(dirname "$dest")"
  cp -R "$src" "$dest"
  echo "  installed: $dest"
done

echo
echo "Done. Restart ZCode (or start a new session), then check /skills."
echo "Try:  \"quality-agent: add CSV export to the question bank\""
