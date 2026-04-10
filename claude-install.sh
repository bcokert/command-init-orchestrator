#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS="$HOME/.claude/commands"

# Command file goes directly in ~/.claude/commands/
cp "$SCRIPT_DIR/init-orchestrator.md" "$COMMANDS/init-orchestrator.md"

# Defaults (skills, agents, config) go outside commands/ to avoid being picked up as commands
DEFAULTS_DEST="$HOME/.claude/init-orchestrator"
mkdir -p "$DEFAULTS_DEST"
cp -r "$SCRIPT_DIR/defaults" "$DEFAULTS_DEST/"

echo "Installed:"
echo "  $COMMANDS/init-orchestrator.md"
echo "  $DEFAULTS_DEST/defaults/"
