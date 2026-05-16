#!/usr/bin/env bash
# RED test for Slice 5 — divecode-migrate (v0 split files → unified design.md).
set -uo pipefail
DIVECODE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIG="$DIVECODE_ROOT/bin/divecode-migrate"
PASS=0; FAIL=0
TMP=$(mktemp -d -t divecode-test-migrate.XXXXXX)
trap 'rm -rf "$TMP"' EXIT

assert() { local d="$1" h="$2" n="$3"; if [[ "$h" == *"$n"* ]]; then echo "  ✓ $d"; PASS=$((PASS+1)); else echo "  ✗ $d (need: $n)"; FAIL=$((FAIL+1)); fi; }
afile() { local d="$1" p="$2"; if [ -f "$p" ]; then echo "  ✓ $d"; PASS=$((PASS+1)); else echo "  ✗ $d (missing: $p)"; FAIL=$((FAIL+1)); fi; }
nofile() { local d="$1" p="$2"; if [ ! -f "$p" ]; then echo "  ✓ $d"; PASS=$((PASS+1)); else echo "  ✗ $d (unexpectedly exists: $p)"; FAIL=$((FAIL+1)); fi; }

PROJ="$TMP/proj"
mkdir -p "$PROJ/divecode/design"
echo "# Requirements" > "$PROJ/divecode/requirements.md"
echo "test-req" >> "$PROJ/divecode/requirements.md"
echo "<html></html>" > "$PROJ/divecode/design/screen-a.html"
echo "# Architecture" > "$PROJ/divecode/ARCHITECTURE.md"
echo "test-arch" >> "$PROJ/divecode/ARCHITECTURE.md"

echo "▸ Test 1 — migrate creates unified design.md from 3 source files"
out=$(bash "$MIG" --project "$PROJ" 2>&1) || true
afile "design.md created" "$PROJ/divecode/design.md"
assert "migrate prints success" "$out" "migrated"

echo "▸ Test 2 — original files archived under v0/"
afile "requirements.md archived" "$PROJ/divecode/archive/v0/requirements.md"
afile "ARCHITECTURE.md archived" "$PROJ/divecode/archive/v0/ARCHITECTURE.md"
afile "design/ archived" "$PROJ/divecode/archive/v0/design/screen-a.html"
nofile "originals removed from divecode/" "$PROJ/divecode/requirements.md"

echo "▸ Test 3 — design.md content includes content from all 3 sources"
body=$(cat "$PROJ/divecode/design.md")
assert "contains req content" "$body" "test-req"
assert "contains arch content" "$body" "test-arch"
assert "contains 7 sections marker" "$body" "## 7."

echo "▸ Test 4 — refuses to run when design.md already exists"
out2=$(bash "$MIG" --project "$PROJ" 2>&1) || true
assert "refuse message" "$out2" "already migrated"

echo ""
echo " PASS: $PASS  FAIL: $FAIL"
[ "$FAIL" -eq 0 ]
