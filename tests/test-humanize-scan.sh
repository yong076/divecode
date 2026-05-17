#!/usr/bin/env bash
# Tests for bin/divecode-humanize-scan.
set -uo pipefail
DIVECODE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCAN="$DIVECODE_ROOT/bin/divecode-humanize-scan"
PASS=0; FAIL=0
TMP=$(mktemp -d -t divecode-humanize.XXXXXX)
trap 'rm -rf "$TMP"' EXIT

contains() { local d="$1" h="$2" n="$3"; if [[ "$h" == *"$n"* ]]; then echo "  ✓ $d"; PASS=$((PASS+1)); else echo "  ✗ $d (need: $n)"; FAIL=$((FAIL+1)); fi; }
refute()   { local d="$1" h="$2" n="$3"; if [[ "$h" != *"$n"* ]]; then echo "  ✓ $d"; PASS=$((PASS+1)); else echo "  ✗ $d (unexpected: $n)"; FAIL=$((FAIL+1)); fi; }

# Fixture 1: Korean text heavy with AI tells
cat > "$TMP/ko-bad.md" <<'EOF'
# 결론적으로, AI에 대해 살펴보자

본질적으로 AI는 매우 혁신적인 기술이다. 우리는 이를 통해 효율을 높일 수 있다.
또한, AI에 의해 생성된 콘텐츠는 점점 늘어나고 있다.
따라서 이러한 변화에 대비해야 한다.
즉, 미래에 대비할 수 있는 전략적 접근이 필요한 것이다.
나아가 본질적으로 새로운 패러다임이 가지고 있는 의미는 시사하는 바가 크다.
EOF

# Fixture 2: Korean text mostly clean
cat > "$TMP/ko-clean.md" <<'EOF'
# divecode

코딩 에이전트가 지니다. 소원이 글자 그대로 풀린다.
TTL에 jitter는? cron 두 개가 겹쳐 돌면? 소원에 없으니까 안 묻는다.
3주 뒤 프로덕션이 탄다.
EOF

# Fixture 3: English text heavy with AI tells
cat > "$TMP/en-bad.md" <<'EOF'
# Let me delve into this revolutionary topic

In conclusion, it's worth noting that this leverages cutting-edge technology.
It's not just a tool — it's a paradigm shift powered by state-of-the-art AI.
First, you'll find that it's robust. Second, it's seamless. Finally, it's industry-leading.

Let me explain — this might possibly suggest that you can build world-class apps.
EOF

# Fixture 4: English text mostly clean
cat > "$TMP/en-clean.md" <<'EOF'
# divecode

Coding agents are genies. Your wish gets granted exactly as worded.
TTL jitter? Cron overlap? Not in the wish, so the agent does not consider it.
Three weeks later production lights up.
EOF

echo "▸ Test 1 — Korean dirty file flags multiple S1 patterns"
out=$(bash "$SCAN" --locale ko "$TMP/ko-bad.md" 2>&1) || true
contains "D-1 결산 피벗 detected" "$out" "D-1"
contains "D-3 본질적으로 detected" "$out" "D-3"
contains "A-1 에 대해 detected" "$out" "A-1"
contains "A-10 할 수 있다 (warn — 누적)" "$out" "A-10"
contains "I-1 ~인 것이다 detected" "$out" "I-1"
contains "H-1 문두 접속사 detected" "$out" "H-1"

echo "▸ Test 2 — Korean clean file has no S1 hits"
out=$(bash "$SCAN" --locale ko "$TMP/ko-clean.md" 2>&1) || true
refute "no D-1" "$out" "D-1"
refute "no D-3" "$out" "D-3"
refute "no A-1" "$out" "A-1"
refute "no I-1" "$out" "I-1"
contains "summary line present" "$out" "summary:"

echo "▸ Test 3 — English dirty file flags hype + closing pivot"
out=$(bash "$SCAN" --locale en "$TMP/en-bad.md" 2>&1) || true
contains "EN-3 hype vocab detected" "$out" "EN-3"
contains "EN-4 closing pivot detected" "$out" "EN-4"
contains "EN-2 not just X detected" "$out" "EN-2"
contains "EN-5 Let me self-narration detected" "$out" "EN-5"
contains "EN-12 marketing speak detected" "$out" "EN-12"
contains "EN-14 worth noting detected" "$out" "EN-14"

echo "▸ Test 4 — English clean file passes"
out=$(bash "$SCAN" --locale en "$TMP/en-clean.md" 2>&1) || true
refute "no EN-3" "$out" "EN-3"
refute "no EN-4" "$out" "EN-4"

echo "▸ Test 5 — auto-detect locale (KO file without --locale)"
out=$(bash "$SCAN" "$TMP/ko-bad.md" 2>&1) || true
contains "auto-detected ko" "$out" "locale: ko"

echo "▸ Test 6 — auto-detect locale (EN file without --locale)"
out=$(bash "$SCAN" "$TMP/en-bad.md" 2>&1) || true
contains "auto-detected en" "$out" "locale: en"

echo "▸ Test 7 — exit code reflects severity"
bash "$SCAN" --locale ko "$TMP/ko-clean.md" > /dev/null 2>&1
clean_exit=$?
bash "$SCAN" --locale ko "$TMP/ko-bad.md" > /dev/null 2>&1
dirty_exit=$?
if [ "$clean_exit" -eq 0 ] && [ "$dirty_exit" -ne 0 ]; then
  echo "  ✓ clean → exit 0, dirty → exit non-0"; PASS=$((PASS+1))
else
  echo "  ✗ exit semantics broken (clean=$clean_exit dirty=$dirty_exit)"; FAIL=$((FAIL+1))
fi

echo ""
echo " PASS: $PASS  FAIL: $FAIL"
[ "$FAIL" -eq 0 ]
