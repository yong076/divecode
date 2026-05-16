#!/usr/bin/env bash
# RED test for Slice 8 — TDD gate (refuse-write before failing test exists).
set -uo pipefail
DIVECODE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GATE="$DIVECODE_ROOT/bin/divecode-tdd-gate"
PASS=0; FAIL=0
TMP=$(mktemp -d -t divecode-test-tdd.XXXXXX)
trap 'rm -rf "$TMP"' EXIT

exit_eq() { local d="$1" exp="$2" act="$3"; if [ "$exp" = "$act" ]; then echo "  ✓ $d (exit $exp)"; PASS=$((PASS+1)); else echo "  ✗ $d (expected exit $exp, got $act)"; FAIL=$((FAIL+1)); fi; }
contains() { local d="$1" h="$2" n="$3"; if [[ "$h" == *"$n"* ]]; then echo "  ✓ $d"; PASS=$((PASS+1)); else echo "  ✗ $d (need: $n)"; FAIL=$((FAIL+1)); fi; }

# Fixture 1 — a test that fails (RED satisfied)
cat > "$TMP/red.sh" <<'EOF'
#!/usr/bin/env bash
echo "assertion failed: expected 5, got 3" >&2
exit 1
EOF
chmod +x "$TMP/red.sh"

# Fixture 2 — a test that passes (no RED, must reject)
cat > "$TMP/green.sh" <<'EOF'
#!/usr/bin/env bash
echo "all assertions passed"
exit 0
EOF
chmod +x "$TMP/green.sh"

# Fixture 3 — missing test file (no path)

# Fixture 4 — broken syntax / can't run as test
cat > "$TMP/broken.sh" <<'EOF'
#!/usr/bin/env bash
this-is-not-a-command-syntax-error)(
EOF
chmod +x "$TMP/broken.sh"

echo "▸ Test 1 — failing test → gate allows production write (exit 0)"
bash "$GATE" "$TMP/red.sh" > "$TMP/out1" 2>&1
exit_eq "RED satisfied → exit 0" "0" "$?"
contains "output mentions RED satisfied" "$(cat "$TMP/out1")" "RED"

echo "▸ Test 2 — passing test → gate refuses production write (exit 1)"
bash "$GATE" "$TMP/green.sh" > "$TMP/out2" 2>&1
exit_eq "no RED → exit 1" "1" "$?"
contains "output explains why" "$(cat "$TMP/out2")" "passed"

echo "▸ Test 3 — missing test file → gate refuses (exit 2)"
bash "$GATE" "$TMP/nonexistent.sh" > "$TMP/out3" 2>&1
exit_eq "missing → exit 2" "2" "$?"

echo "▸ Test 4 — broken test (compile/syntax fail) → gate distinguishes (exit 3)"
bash "$GATE" "$TMP/broken.sh" > "$TMP/out4" 2>&1
exit_eq "broken → exit 3" "3" "$?"
contains "output flags broken not RED" "$(cat "$TMP/out4")" "broken"

echo ""
echo " PASS: $PASS  FAIL: $FAIL"
[ "$FAIL" -eq 0 ]
