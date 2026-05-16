#!/usr/bin/env bash
# divecode bootstrap — curl one-liner installer
# Usage: curl -fsSL https://raw.githubusercontent.com/yong076/divecode/main/bootstrap.sh | bash

set -euo pipefail

REPO="${DIVECODE_REPO:-https://github.com/yong076/divecode.git}"
HOME_DIR="${DIVECODE_HOME:-$HOME/.divecode}"

echo "▸ divecode bootstrap"
echo "  repo:  $REPO"
echo "  dest:  $HOME_DIR"
echo ""

if ! command -v git >/dev/null 2>&1; then
  echo "✗ git is required but not found in PATH" >&2
  exit 1
fi

if [ -d "$HOME_DIR/.git" ]; then
  echo "▸ existing install found — pulling latest"
  git -C "$HOME_DIR" pull --ff-only
else
  echo "▸ cloning"
  git clone --depth=1 "$REPO" "$HOME_DIR"
fi

echo ""
bash "$HOME_DIR/install.sh"
