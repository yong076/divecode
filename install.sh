#!/usr/bin/env bash
# divecode install — symlinks skills/ into ~/.claude/skills/
# Safe to re-run (idempotent).

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$SOURCE_DIR/skills"
SKILLS_DST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

if [ ! -d "$SKILLS_SRC" ]; then
  echo "✗ skills/ not found at $SKILLS_SRC" >&2
  exit 1
fi

mkdir -p "$SKILLS_DST"

echo "▸ installing divecode skills"
echo "  from: $SKILLS_SRC"
echo "  to:   $SKILLS_DST"
echo ""

linked=0
for skill_path in "$SKILLS_SRC"/*/; do
  [ -d "$skill_path" ] || continue
  name=$(basename "$skill_path")
  target="$SKILLS_DST/$name"

  if [ -L "$target" ]; then
    existing=$(readlink "$target")
    if [ "$existing" = "$skill_path" ] || [ "$existing" = "${skill_path%/}" ]; then
      echo "  ✓ $name (already linked)"
      linked=$((linked+1))
      continue
    fi
    echo "  ⚠ $name exists pointing elsewhere — replacing"
    rm "$target"
  elif [ -e "$target" ]; then
    echo "  ⚠ $name exists as a real file/dir — skipping (move it aside first)"
    continue
  fi

  ln -s "${skill_path%/}" "$target"
  echo "  ✓ $name"
  linked=$((linked+1))
done

echo ""
echo "▸ installed $linked skill(s)"
echo ""
echo "Try it:"
echo "  cd <your project>"
echo "  /divecode"
