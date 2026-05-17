# humanize — Korean taxonomy

Patterns that mark text as AI-written. Used by `bin/divecode-humanize-scan`
and `skills/divecode-humanize`. Distilled from
[epoko77-ai/im-not-ai](https://github.com/epoko77-ai/im-not-ai) v2.0
quick-rules — see their `ai-tell-taxonomy.md` for the full 60+ pattern set
and academic citations. This file keeps the highest-leverage 20 patterns
for divecode's single-pass workflow.

Severity:
- **S1** — one occurrence is a confirmed AI tell. Always rewrite.
- **S2** — fine in moderation, problem when accumulated. Rewrite past threshold.

Do-NOT touch (any locale): proper nouns, product/model/agency names,
numbers, dates, units, direct quotes inside "…", code, file paths,
industry-standard abbreviations (LLM / GPU / API / etc.).

Change-rate hard guard: above 30% triggers warning, above 50% halts.

| ID | Pattern | Severity | Detection signal | Rewrite |
|---|---|---|---|---|
| A-1 | "~에 대해(서)" | S1 | substring `에 대해` | 목적격 직결 ("X에 대해 논의" → "X를 논의") |
| A-2 | "~를/을 통해" 남발 | S1 | `를 통해\|을 통해` count ≥ 3 | "~로 / ~해서 / ~함으로써" 로 분산 |
| A-3 | "~에 있어(서)" | S1 | substring `에 있어` | "~에서 / ~을 볼 때" |
| A-7 | "가지고 있다" / have+N 직역 | S1 | substring `가지고 있` | 형용사·동사 환원 ("회의를 가지다" → "회의를 했다") |
| A-8 | 이중 피동 "~되어진다" | S1 | substring `되어진` | 능동 또는 단일 피동 |
| A-10 | "~할 수 있다" 남발 | S2 | `할 수 있\|될 수 있` count ≥ 3 | 단언으로 ("높일 수 있다" → "높인다") |
| A-16 | "그/그녀/그것/그들" 영어 대명사 직역 | S1 | `그것\|그녀\|그들` per-paragraph count ≥ 3 | 영형(생략) 또는 호칭·명사구 |
| C-5 | 이모지 남발 | S1 | unicode emoji count ≥ 1 (장르: 칼럼/리포트) | 전부 삭제 |
| C-11 | 연결어미 뒤 쉼표 | S1 | `(고\|며\|지만\|아서\|어서),` count ≥ 6 | 쉼표 제거 |
| D-1 | 결산 피벗 lexicon | S1 | `결론적으로\|요약하면\|정리하면\|이를 통해\|이로써` count ≥ 1 | 삭제 또는 직설 결론으로 |
| D-2 | "시사하는 바가 크다" | S1 | substring `시사하는 바\|주목할 만하다` | 삭제 또는 구체 결론으로 |
| D-3 | "본질적으로 / 핵심적으로" | S1 | `본질적으로\|핵심적으로` | 삭제 |
| D-4 | hype 어휘 | S1 | `파격적\|압도적\|획기적\|치명적\|혁신적` count ≥ 3 | 구체 수치·사실로 환원 |
| E-2 | 종결어미 "~다" 4문장 연속 | S2 | 4+ 연속 라인 `다.$` | "~었다/~ㄴ다/~기 마련이다" 등 다양화 |
| F-5 | "~적 N" 추상 체인 | S2 | `[가-힣]적 [가-힣]+` count ≥ 5 | 명사+명사 또는 풀어쓰기 |
| G-1 | "~것이다 / ~할 것이다" 미래 단정 | S2 | `것이다.$\|것입니다.$` count ≥ 3 | 현재형·확정형으로 |
| H-1 | 문두 접속사 (또한/따라서/즉) | S1 | 줄 시작 `^(또한\|따라서\|즉\|나아가\|아울러\|게다가\|더욱이)` count ≥ 5 | 대량 제거 |
| I-1 | "~인 것이다 / ~한 것이다" 결말 | S1 | `인 것이다\|한 것이다` | 평서형으로 |
| J-1 | 헤딩·문장 `**` 과다 | S2 | `**` count ≥ 20 (per 1000 단어) | 한두 곳만 남기고 제거 |
| J-2 | 따옴표 강조 남발 | S1 | `"..."` count ≥ 5 (실제 인용 제외) | 평어로 |
| J-3 | 불릿 과다 (장르: 칼럼/리포트) | S2 | `^- ` count > 줄 수의 40% | 산문으로 통합 |

## Self-check after rewrite (run before declaring done)

1. 고유명사·수치·날짜·인용 100% 보존 — diff에서 한 글자도 안 바뀌었는지.
2. 변경률 ≤ 30%.
3. 장르 이탈 없음 — 칼럼이 문학이 되지 않았는지, 리포트가 블로그체로 떨어지지 않았는지.
4. register 보존 — 원문 격식체면 결과도 격식체.
5. S1 잔존 0건 — D-1~D-3, A-7, A-8, A-16, C-5, H-1, I-1, J-2 ID에서.
6. 임의 추가 표현 없음 — 원문에 없던 비유나 수사가 새로 들어가지 않았는지.

위반 시 edit 롤백 → 재시도. 1회 한.

## Quality grade

- **A**: S1 잔존 0, S2 잔존 ≤ 2, 변경률 10~25%, self-check 6항 통과
- **B**: S1 잔존 0, S2 잔존 ≤ 4, self-check 5항 이상
- **C**: S1 잔존 1~2 — 사용자에게 재실행 권고
- **D**: S1 잔존 3+ 또는 변경률 50% 초과 — 작업 중단

## Attribution

This taxonomy is a focused subset of [im-not-ai](https://github.com/epoko77-ai/im-not-ai)'s
`ai-tell-taxonomy.md` (Apache-2.0). The original includes 60+ patterns
with academic citations (김도훈 2009, 박옥수 2018, 김정우 2007, et al.).
divecode keeps the 20 highest-leverage ones for a single-pass workflow;
for deeper post-editese metrics use im-not-ai directly.
