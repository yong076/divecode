---
name: divecode-status
description: |
  Usage limit awareness for divecode sessions. Checks Claude/Codex/Gemini quota
  via llm-usage-cli (preferred) or ccusage (fallback), then advises whether to
  proceed with a planned operation, split it into chunks, or wait. The point:
  divecode sessions can be long (multi-phase interrogation, mockup generation,
  guided implementation) — getting cut off mid-phase is worse than splitting
  upfront. Use before starting a long divecode stage or when the user asks
  about quota.
triggers:
  - divecode status
  - dive status
  - check usage
  - check quota
  - am I going to hit the limit
allowed-tools:
  - Bash
  - AskUserQuestion
---

# divecode-status — Usage limit awareness

You are the **usage advisor**. Long divecode sessions risk hitting the 5-hour rolling quota or per-window token caps. Your job: check current usage, project what the next stage will consume, and advise the user on whether to start, split, or wait.

## Preamble — detect tools

```bash
HAS_LLM_USAGE=0
HAS_CCUSAGE=0

if command -v llm-usage >/dev/null 2>&1; then
  HAS_LLM_USAGE=1
  echo "llm-usage-cli: ✓ available"
fi

if command -v ccusage >/dev/null 2>&1; then
  HAS_CCUSAGE=1
  echo "ccusage: ✓ available"
fi

if [ $HAS_LLM_USAGE -eq 0 ] && [ $HAS_CCUSAGE -eq 0 ]; then
  echo "no usage tool found"
  echo ""
  echo "권장 설치:"
  echo "  llm-usage-cli (Codex/Claude/Gemini 통합):  https://github.com/yong076/llm-usage-cli"
  echo "    git clone https://github.com/yong076/llm-usage-cli && cd llm-usage-cli && pip install -e ."
  echo "  ccusage (Claude 전용):"
  echo "    npm i -g ccusage"
fi
```

## Flow

### Case 1 — `llm-usage` available (preferred)

```bash
llm-usage --json 2>/dev/null
```

Parse the JSON. Report per-provider:
- Current usage (tokens, cost)
- Latest activity timestamp
- Status (ok / no-local-usage / error)

Then estimate what the next stage will consume (rough heuristics):

| Stage | Typical token cost |
|---|---|
| `/divecode-spec` (one phase, ~7 phases total) | 15-40k per phase |
| `/divecode-design` (one screen, 5 states) | 20-60k per screen |
| `/divecode-arch` (one phase, ~6 phases total) | 20-50k per phase |
| `/divecode-implement` (one slice, ~150 lines) | 10-30k per slice |

Tell the user:
> "현재 Claude 사용량 X tokens / Y window. 다음 spec phase는 ~30k 예상. 여유 있음, 시작 OK."
> "현재 사용량 5h window의 70%. 지금 design 단계(5 screens × ~40k) 들어가면 도중에 컷 가능성. 2-3 screens씩 나누는 거 추천."

### Case 2 — only `ccusage` available

```bash
ccusage 2>/dev/null
```

Same advisory pattern, Claude only.

### Case 3 — neither available

Apply heuristics only:
- Ask user how long the current session has been running ("이번 세션 어느 정도 됐어요?")
- Ask roughly how many big operations they've run ("큰 작업 몇 개 돌렸어요?")
- Give a qualitative advisory: "이미 길게 가셨으면 다음 단계는 새 세션으로 가는 게 안전할 수도"

Then **strongly suggest installing a usage tool**:

> "정확한 사용량 추적을 위해 llm-usage-cli 설치 추천: git clone https://github.com/yong076/llm-usage-cli && cd llm-usage-cli && pip install -e ."

## When to recommend splitting a stage

Recommend splitting when:
- Current usage > 50% of any window
- Planned stage > 30% of remaining budget
- User has already had ≥1 quota-related interruption today

Suggest split points:
- **spec**: split by phase (do 1-3 in one session, 4-7 in the next)
- **design**: split by screen
- **arch**: split by phase
- **implement**: every N slices, suggest a session break

## Output format

Keep it short. The user invoked this to make a decision, not to read a report.

```
USAGE: claude opus-4-7  →  142k / 200k (71%) in current 5h window
NEXT:  /divecode-design × 5 screens  →  ~200k projected
       ⚠ likely to hit cap mid-stage

RECOMMENDATION:
  → split: do 2 screens now, 3 in a fresh session
  → or:    /divecode-design --screens=login,dashboard

OK to proceed with 2-screen chunk? (다음 명령 제안: 위 split 옵션 중 하나)
```
