#!/usr/bin/env bash
# divecode uninstall — removes only symlinks pointing at this repo.

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$SOURCE_DIR/skills"
SKILLS_DST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

echo "▸ divecode uninstall"
echo ""

removed=0
for skill_path in "$SKILLS_SRC"/*/; do
  [ -d "$skill_path" ] || continue
  name=$(basename "$skill_path")
  target="$SKILLS_DST/$name"

  if [ -L "$target" ]; then
    existing=$(readlink "$target")
    if [ "$existing" = "$skill_path" ] || [ "$existing" = "${skill_path%/}" ]; then
      rm "$target"
      echo "  ✓ removed $name"
      removed=$((removed+1))
    else
      echo "  ⚠ $name points elsewhere — left alone"
    fi
  fi
done

echo ""
echo "▸ removed $removed symlink(s)"
echo "  (the repo at $SOURCE_DIR is untouched)"
