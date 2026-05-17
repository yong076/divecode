# divecode

<p align="center">
  <img src="assets/banner.png" alt="Dive Coding — Guide the genie. Get the wish right." />
</p>

<p align="center">
  <strong>한국어</strong> ·
  <a href="README.en.md">English</a> ·
  <a href="README.ja.md">日本語</a>  ·
  <a href="README.zh-Hans.md">简体中文</a>
</p>

> divecoding은 방법론, divecode는 그걸 실행하는 도구.

알라딘이 지니한테 처음 빈 소원은 "공주랑 결혼하게 왕자로 만들어줘"였다. 지니는 글자 그대로 들어줬다. 알라딘은 왕자가 됐고, 코끼리 행렬을 거느렸고, 공주는 못 얻었다.

코딩 에이전트가 그 지니다. 소원이 글자 그대로 풀린다. "Redis 캐시랑 5분짜리 Vercel cron 붙은 admin dashboard 만들어줘" 던지면 정확히 그 문장만큼이 구현된다. TTL에 jitter는? cron 두 개가 겹쳐 돌면? 캐시가 아직 비어 있을 때 dashboard는 뭐를 보여주지? 소원에 없으니까 안 묻는다. 안 묻고 그냥 짠다.

3주 뒤 프로덕션이 탄다. 안 적힌 게 다 터진다.

divecoding이 끼어드는 자리가 그 사이다. 대충 쓴 소원 — PRD든, 한 줄 명령이든, 스케치든 — 던지면 divecode가 거기서 어떤 *pattern packs* 가 걸리는지 본다. redis-cache, admin-dashboard, vercel-serverless, postgres-saas, payments…. 걸린 pack이 명시 안 한 질문을 한 줄씩 던진다. Cache stampede, cron 겹침, auto-refresh 부하, replica lag, SCA 중도이탈. 진짜로 의도했던 게 뭐였는지 다시 묻는다.

나머지 부속물(AWS AI-DLC macro flow, agent-flow guardrail, TDD gate, PR watcher)은 그렇게 명확해진 소원이 실제 코드까지 살아남게 끌고 가는 장치다.

## 지니 원칙

소원을 들어주기 전, divecode가 세 가지를 짚는다.

1. 글자 그대로 푸는 소원은 X. 그게 맞는지 한 번 확인.
2. 명시 안 했지만 X를 받쳐줘야 하는 것들: A, B, C. (걸린 pack이 추출.)
3. 지금 A, B, C 안 정하면, X는 적힌 글자만큼만 풀린다. 그래도 갈지, 더 적을지.

이게 divecoding의 단 하나의 보편 규칙이다. inception → construction → operations로 이어지는 페이즈, light/standard/strict로 갈리는 프로파일, pack, gate. 다 이 멈춤을 어떤 입도로 깔지를 정하는 장치다. throwaway 스크립트엔 한 줄짜리 멈춤이면 되고, payments 통합엔 20문항짜리 멈춤이 든다.

이게 통하는 이유는 단순하다. 지니가 뭐든 들어준다. 요즘 에이전트는 거의 모든 코드를 짠다. 그러니 병목은 더 이상 능력이 아니라 *구체성*이다. divecoding은 그 구체성 자체를 작업으로 둔다.

## 원래 개발자가 하던 일

Vibe coding이 가르친 건 셋이다. 코드는 빠르게 흘러나온다. 누가 쓰든 비슷한 코드가 많다. typing은 에이전트가 대신한다.

가르치지 않은 건 또 셋이다. 왜 그렇게 짰는지, 어떤 트레이드오프를 골랐는지, 한 달 뒤 누가 이 코드를 다시 읽게 될지.

원래 개발자는 두 번째 셋을 하던 사람이다. 코드 한 줄 치기 전에 — 요구사항을 정확히 읽고, 엣지케이스를 그려보고, 데이터 모델을 스케치하고, 알고리즘을 고르고, 실패 가능성을 미리 보고, 트레이드오프를 결정하고, 그제서야 키보드를 댔다.

Vibe coding은 그 일곱 단계를 "describe what you want, accept what comes" 하나로 압축했다. 시간이 줄었다. 사라진 여섯 단계마다, 한 달 뒤 터지는 사고가 한 건씩 깔린다.

Dive coding은 그 여섯을 도로 깐다. 키보드 두드리는 자리는 에이전트한테 그대로 두지만, 그 앞에 있던 *생각하는* 자리는 사람한테 돌려준다. 에이전트는 코드 대신 *질문* 으로 그 사고를 끌어낸다.

| | Vibe coding | Dive coding |
|---|---|---|
| 입력 | 한 줄 소원 | 명세 (점점 정교해지는) |
| 페이스 | 에이전트가 결정 | 사람이 결정 |
| 출력 | 코드, 그다음 rework | 결정들, 그다음 한 번에 작동하는 코드 |
| 발견 시점 | 프로덕션에서 (몇 주 뒤) | 키보드 치기 전 (몇 분 뒤) |
| 개발자 역할 | typing 감독관 | 명세를 만드는 사람 |
| 발휘하는 기술 | 받아들이기 | 판단·취향·지식 |
| 문서화 | "써야지" | workflow에서 자연 산출 |
| 잘 맞는 경우 | 탐색, 일회용, 데모 | 포스트모템 쓸 만한 거 |
| 비유 | 받아쓰기 | 대화 |

요컨대 dive coding은 에이전트한테 더 좋은 답을 시키는 게 아니라, 사람이 더 좋은 질문을 던지게 만든다.

## 쓰면 뭐가 좋나

손에 잡히는 것만. 다 divecode를 만들게 된 agent-cat 개발에서 실제로 있었던 일이다.

ship 전에 버그가 잡힌다. agent-cat admin dashboard, 사고 3주 전 PRD에는 "Redis 캐시"랑 "Vercel cron 5분마다"가 있었다. divecode가 물었을 질문 세 개. TTL 얼마? jitter 줘? cron이 도는 동안 dashboard도 polling하면 어떻게 되지? 10분이면 끝낼 대화였다. 실제 사고 복구엔 일요일 오후 하나가 통째로 들어갔다.

에이전트가 구조 결정으로 사람을 놀래키지 않는다. "data layer엔 Repository pattern" 같은 건 밤 11시에 손가락에 떠오르는 규칙이 아니다. 에이전트가 다음 파일 짜기 전에 던지는 질문이 된다. "이건 eventually consistent야 strongly consistent야?"도 같은 맥락이다. 결정하는 데 30초, 되돌리는 데 3일 걸리는 부류.

PRD가 저절로 날카로워진다. 세 문단짜리 spec을 던지면 12개 질문이 돌아온다. 답하면 그 답이 그대로 design.md의 본문이 된다. 포맷도 잡혀 있고 결정 로그도 박혀 있고 TDD slice로 바로 쪼갤 준비도 되어 있는 상태로. 반쪽짜리에서 진짜 spec이 나온다.

문서화는 의무가 아니라 부산물이 된다. session 하나마다 design.md + risk-map.md + decision lore가 자동으로 떨어진다. 6개월 뒤 "이거 왜 이렇게 짰지?"가 나오면 답이 날짜랑 trade-off 박힌 파일에 있다. 의도해서 쓴 게 아니라 workflow가 떨궈놓은 거다.

시니어/주니어가 같이 일할 때 마찰이 준다. 예전엔 "replica lag 생각해봤어?" 같은 질문의 출처가 시니어였다. 이제 divecode가 먼저 묻고, 시니어는 답을 review만 한다. 매번 끄집어낼 필요가 없다. 주니어는 강의받는 대신 질문 자체를 보면서 배운다.

토큰 비용도 떨어진다. vibe-coding 사이클은 짠다 → 어 이거 아니네 → 다시 → 또 아니네 → 다시. 매 사이클이 토큰을 태운다. divecode는 사고를 앞에 두니까 첫 생성이 보통 마지막 생성이 된다.

마지막으로 — 에이전트가 우리 팀 실제 결정으로 "학습"된다. Lore 항목(`~/.divecode/lore/` + `.divecode/lore/`)이 bolt 사이, 세션 사이에 이어진다. 지난달 박은 Constraint("integration test는 진짜 DB로, mock 금지")가 이번 달 design.md에 자동으로 인용된다. 부족 지식이 파일 지식이 되는 셈.

## divecoding이 아닌 것

- 기획 프레임워크가 아니다. 스토리포인트, 스프린트, 추정 포커 다 없다.
- 코드 생성기도 아니다. 의도적으로 코드를 안 짠다. 대신 질문을 짠다.
- 무거운 방법론도 아니다. 인증서, 의식, Sprint Zero 없다. "멈춰서, 실패 가능성 끄집어내고, 그다음에 만든다" 정도.
- RAG 래퍼도 아니다. Pattern pack은 능동적 질문 생성기이지 수동 검색이 아니다. PRD에 "redis"가 있다고 일반 Redis 문서를 던지는 게 아니라, Redis 사용자가 프로덕션에서 실제로 물리는 것들을 묻는다.

## 설치

```bash
curl -fsSL https://raw.githubusercontent.com/yong076/divecode/main/bootstrap.sh | bash
```

`~/.divecode/`에 clone되고 `~/.claude/skills/`로 심링크된다. 다음 Claude Code 세션에서 어느 프로젝트 디렉토리에서든 `/divecode` 호출.

첫 실행은 repo를 보고 profile을 추천한다. 확인하면 그 뒤로는 알아서 돈다.

제거: `bash ~/.divecode/uninstall.sh`

## 프로파일

divecode가 세 가지 깊이로 돈다. ceremony는 버그가 났을 때 얼마나 아플지에 맞춰 자동으로 조정된다.

- light — prototype, 솔로 작업용. 4 phase (spec / design / arch / implement). worktree, PR 자동화, TDD gate 다 없음. v0 호환.
- standard — 실제 프로덕션 작업용. PRD interrogation, slice-plan, multi-reviewer, fix-loop, 전체 lifecycle (commit → push-pr → pr-watch → merge → cleanup) 추가.
- strict — mission-critical 코드용. standard와 형태는 같은데 gate가 실제로 막는다. 실패 test 없으면 production code 못 짠다. Repository Pattern 어기는 data layer 코드 금지. 모든 아키텍처 결정은 `lore/`에서 인용 필수.

첫 실행에서 repo (commit history, test infra, CI config, ARCH/CONTRIBUTING 문서, README 크기) 보고 추천한다. 사용자가 확인하거나 override.

## 세션 흐름

```
INCEPTION
 ├─ prd         대충 PRD 던지기 → pattern-pack triggers 발동 → risk-map + open-questions 산출
 ├─ audit       이미 진행 중인 프로젝트일 때만
 ├─ ux          이 화면이 5가지 state에서 어떻게 보이지?
 ├─ spec        7 phase 인터로게이션, niche-knowledge 체크리스트 pull
 └─ slice-plan  TDD-ready 청크로 분해
                ⏸ 사람 검토를 위한 pause

CONSTRUCTION
 ├─ worktree    profile 기반 branch + worktree
 ├─ implement   실패 test 먼저, 그다음 코드
                (strict에선 실패 test 없이는 에이전트가 production code 작성을 거부)
 ├─ review      reviewer 에이전트 다중 병렬 spawn; architecture-design 전문가는 mandatory
 └─ fix-loop    must-fix 처리; 최대 3 round, 그 이후엔 사용자 에스컬레이션

OPERATIONS
 ├─ commit      convention 인식, profile 기반
 ├─ push-pr
 ├─ pr-watch    6-status routing, CI 실패 / PR 코멘트 자동 응답
 ├─ merge
 └─ cleanup     worktree 삭제, main 동기화, 남길 만한 결정은 lore로 기록 유도
```

light에선 construction/operations 대부분이 skip된다. spec, design, build, ship 정도. strict에선 다 활성화되고 gate가 진짜로 막는다. profile + bolt 크기에 따라 깊이가 적응한다.

## "Sprint" 대신 "Bolt"

bolt는 집중된 작업의 한 단위. 주 단위가 아니라 시간 ~ 일 단위다. AWS AI-DLC에서 가져온 용어인데 쓸 만하다. `/divecode` 시작 때 bolt 크기 (small / medium / large)를 묻고, 그 답으로 각 phase 깊이가 바뀐다. small bolt는 인터뷰가 한 줄 확인으로 collapse, large bolt는 모든 phase가 확장.

## 언제 쓰고, 언제 안 쓰나

쓸 때: 결정 하나 잘못 내리면 일주일 되돌리는 작업. 데이터 모양, 돈, 인증, 멀티플랫폼 동기화, 실부하 성능, DB migration 들어가는 것, 포스트모템 쓸 만한 거.

안 쓸 때: 일회용 스크립트, one-off 탐색, 이틀 뒤 지울 코드. 그냥 vibe-code 해라.

스위트 스폿은 시니어 엔지니어가 에이전트랑 페어로 실제 feature를 작업하는 자리. 아니면 두 엔지니어가 같이 — 하나는 멍청한 질문을 던지고, 하나는 경험으로 답하고, 에이전트가 둘 다 생각 못 한 세 번째를 surface하는 구성.

## Pattern packs

pack 시스템이 divecoding의 질문 생성기다. PRD에 키워드가 나오면 pack이 트리거되고, 거기 담긴 questions / failure modes / test ideas가 발사된다. v0.3에서 deep pack 9개 출시.

```
packs/
  redis-cache/        ✓ — redis, upstash, ttl, cache stampede, eviction, lru
  postgres-saas/      ✓ — postgres, neon, supabase, rds, prisma, pgbouncer
  admin-dashboard/    ✓ — admin, dashboard, ops team, auto refresh, polling
  vercel-serverless/  ✓ — vercel, edge function, cron, cold start, ISR
  payments/           ✓ — stripe, paddle, billing, webhook, refund, SCA, 3DS
  nosql/              ✓ — dynamodb, mongo, firestore, cassandra, partition key, gsi
  performance/        ✓ — latency, p99, web vitals, lighthouse, n+1, bundle size
  security/           ✓ — oauth, jwt, csrf, xss, idor, pii, gdpr, rbac, secrets
  ux-apple-hig/       ✓ — swiftui, ios app, dynamic type, dark mode, voiceover

  # 다음:
  realtime-sync/      websocket, sse, pubsub
  telemetry-privacy/  telemetry, analytics, pii, opt-in
  macos-app/          menu bar, sparkle, notarization, dmg
  github-releases/    github actions, release, codesign
```

pack 안에 들어가는 파일:
- `triggers` — divecode-prd가 PRD 텍스트와 매칭할 키워드
- `questions.md` — pack이 발사하는 실제 인터로게이션 프롬프트
- `failure-modes.md` — pack이 막으려는 프로덕션 사고들
- `test-ideas.md` — 답이 만들어야 할 test case
- `example-patterns.md` — 구체적 예시 ("show, don't tell" 참고용)

`packs/`에 PR 보내는 게 가장 leverage 큰 기여다. 에이전트가 물었어야 할 부류의 버그에 물려본 적 있으면, 그게 pack 한 개의 재료.

## 써보기

```bash
# PRD 있는 프로젝트에서
/divecode-prd path/to/PRD.md
```

이 skill이 하는 일:
1. PRD를 입력으로 `bin/divecode-prd-triggers` 실행
2. 매칭된 pack을 사용자에게 확인 (false positive는 빼면 됨)
3. `divecode/risk-map.md`에 각 pack의 failure modes 렌더
4. 매칭된 pack의 `questions.md` 합집합을 walk-through
5. 답한 내용으로 `divecode/design.md` §1 + §2 + §6 채움
6. design.md 나머지는 `/divecode-spec`으로, TDD slice로 바로 점프하려면 `/divecode-slice-plan`으로

번들된 fixture로 한번 돌려봐도 된다 (`/divecode-prd` 호출 없이 matcher만):

```bash
bash ~/.divecode/bin/divecode-prd-triggers \
  --prd ~/.divecode/tests/fixtures/prd-admin-dashboard.md \
  --packs-dir ~/.divecode/packs
```

이 PRD(agent-cat admin 사고를 세 문단짜리 spec으로 정리한 거)는 6개 pack을 트리거하고 ~50개 질문을 surface한다. Redis stampede, cron 겹침, auto-refresh DDoS, IDOR / SSO 리스크, DynamoDB로 갈아탔다면 만났을 partition-key trap. 실제로 시스템 내렸던 것들.

## divecoding의 자리

| 도구 / 방법론 | 강점 | 시도하지 않는 것 |
|---|---|---|
| AWS AI-DLC | Lifecycle macro flow (Inception → Construction → Operations) 와 "bolt" 단위 | 도메인 특정 failure-mode surface |
| GitHub Spec Kit | Spec-driven development, 구조화된 spec 포맷 | stack별 프로덕션 risk 인터로게이션 |
| Claude Skills | 에이전트 capability의 배포 + 실행 포맷 | 위에 올라가는 방법론 레이어 |
| **divecoding** | **PRD 인터로게이션 → human-in-loop 결정 추출 → niche failure-mode surface** | 전체 SDLC 소유, 티켓 시스템 대체 |

divecode는 자유롭게 훔쳐온다. AWS에서 macro shape, agent-flow에서 phase-internal guardrail, Clean Code에서 "discipline-is-the-feature" 자세, Spec Kit에서 artifact-first orientation. 자기 기여는 PRD risk interrogation engine과 그걸 동작시키는 pattern pack 라이브러리.

## 톤 안내

skill들이 한국어/영어 혼용으로 말한다. 내가 그렇게 일하고 동료들도 그렇게 일하니까. fork해서 본인 팀에 맞게 다시 톤 잡아도 된다. pack 자체는 언어 독립적이고, 에이전트 prompt 문구에만 한국어가 섞여 있다.

## 레이아웃

```
divecode/
├── bin/          skill들이 호출하는 작은 bash 스크립트 (detect, bolt, lore, tdd-gate, pr-watch, ...)
├── skills/       SKILL.md 파일들 — Claude Code가 읽는 것
├── checklists/   v0 niche knowledge (redis, sql, nosql, perf, security, ux-hig).
│                 v0.3에서 packs/로 흡수.
├── packs/        Pattern packs (PRD interrogation의 핵심)
├── templates/    profile.yml, design.md, slice-plan.md, lore-entry, review templates
├── tests/        bin/ 스크립트용 bash test 묶음
└── docs/         v0.2/ — divecode 자신의 meta-spec
                  v0.3/ — PRD interrogation engine spec
```

## 기여

가장 도움 되는 PR은 `packs/`에 새 pack 추가다. 에이전트가 물었어야 할 부류의 버그에 물려본 적 있으면, triggers + questions + failure-modes + example-patterns 갖춰서 pack으로 보내라. 거기가 leverage가 가장 큰 자리.

새 skill이나 pipeline phase는 issue부터 열어주면 어디 위치할지 같이 얘기.

## 라이센스

MIT. 쓰고, fork하고, 톤 바꾸고, 언어 바꾸고, 회사 내부 도구에 박아라. 프로덕션 사고 하나만 막아줘도 본전.
