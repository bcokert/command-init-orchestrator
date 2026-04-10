#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.claude/skills/init-orchestrator"

mkdir -p "$DEST"
cp -r "$SCRIPT_DIR/." "$DEST/"

echo "Installed to $DEST"
