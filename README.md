# divecode

<p align="center">
  <img src="assets/banner.png" alt="Dive Coding — Guide the genie. Get the wish right." />
</p>

<p align="center">
  <strong>한국어</strong> ·
  <a href="README.en.md">English</a> ·
  <a href="README.ja.md">日本語</a> ·
  <a href="README.zh-Hans.md">简体中文</a>
</p>

> **divecoding** 은 방법론, **divecode** 는 그걸 실행하는 도구.

알라딘의 첫 번째 소원 기억나세요? "공주랑 결혼하게 왕자로 만들어줘." 지니는 그대로 들어줬어요 — 말 그대로. 알라딘은 왕자 칭호, 코끼리, 행렬을 다 얻었지만, 공주는 못 얻었죠.

**코딩 에이전트는 지니입니다.** 소원을 말 그대로 들어줘요. *"Redis 캐시와 5분마다 도는 cron job 있는 admin dashboard 만들어줘"* 라고 하면 — 그 문장 그대로 구현됩니다. 지니는 TTL에 jitter를 줄 건지 안 물어봐요. cron 실행이 겹칠 때 idempotent하게 처리할지 안 물어봐요. 캐시가 cold일 때 dashboard가 어떻게 보일지 안 물어봐요. 그건 소원에 안 적혀있었으니까.

3주 뒤 프로덕션에 불이 납니다. 적혀있지 않았던 것들이 다 터지면서.

**divecoding 은 소원을 들어주기 전에 되묻는 지니입니다.** 대충 쓴 소원 — PRD든, 한 줄 명령이든, 스케치든 — 던져 넣으면, divecode가 그 안에서 어떤 *pattern packs* 가 걸리는지 찾아내고 (redis-cache, admin-dashboard, vercel-serverless, postgres-saas, payments…), 당신이 미처 명시하지 못한 질문들을 하나씩 묻습니다. Cache stampede. Cron 겹침. Auto-refresh DDoS. Replica lag. SCA 중도이탈. *당신이 진짜로 원했던* 소원.

그게 핵심입니다. 나머지 — AWS AI-DLC macro flow, agent-flow guardrail, TDD gate, PR watcher — 는 명확해진 소원이 실제 코드까지 살아남도록 보호하는 장치들이에요.

## 지니 원칙 (The Genie principle)

어떤 소원이든 들어주기 전에 divecode는 묻습니다:

1. **당신이 말 그대로 빈 소원은** X. 맞아요?
2. **명시 안 했지만 X가 의존하는 것들**: A, B, C. (걸린 packs에서 추출.)
3. **지금 명시 안 하면 X는 글자 그대로** 들어집니다. 명시할래요?

이게 divecoding의 유일한 보편 규칙입니다. 페이즈 (inception → construction → operations), 프로파일 (light / standard / strict), packs, gates — 전부 이 지니의 멈춤을 적절한 입도로 구현하는 장치들이에요. throwaway script는 한 줄짜리 멈춤, payments 통합은 20문항짜리 멈춤. 원리는 같음.

이게 작동하는 이유: **지니는 뭐든 들어줄 수 있다** (요즘 에이전트는 거의 모든 코드를 작성합니다). 병목은 더 이상 능력이 아니라 **구체성**입니다. divecoding은 그 구체성 자체를 작업으로 만듭니다.

## divecoding이 아닌 것

- **기획 프레임워크 아님.** 스토리포인트도, 스프린트도, 추정 포커도 없어요.
- **코드 생성기 아님.** 의도적으로 코드를 안 씁니다. 대신 *질문* 을 씁니다.
- **무거운 방법론 아님.** 인증서도, 의식도, Sprint Zero도 없어요. "멈춰서, 실패 가능성을 끄집어내고, 그다음에 만든다" 정도.
- **RAG 래퍼 아님.** Pattern packs는 능동적 질문 생성기이지 수동적 검색이 아닙니다. PRD에 "redis"가 있다고 일반 Redis 문서를 던지는 게 아니라, Redis 사용자가 프로덕션에서 실제로 물리는 것들을 묻습니다.

## 설치

```bash
curl -fsSL https://raw.githubusercontent.com/yong076/divecode/main/bootstrap.sh | bash
```

`~/.divecode/` 에 clone하고 `~/.claude/skills/` 로 심링크합니다. 다음 Claude Code 세션에서 어느 프로젝트 디렉토리든 `/divecode` 호출 가능.

첫 실행 시 repo를 보고 profile을 추천 → 사용자 확인. 그 후로는 알아서.

제거: `bash ~/.divecode/uninstall.sh`

## 프로파일

divecode는 세 가지 깊이로 동작합니다. ceremony 수준이 버그 위험도에 맞춰 조정돼요.

- **light** — prototype, 솔로 작업용. 4 phase (spec / design / arch / implement). worktree 없음, PR 자동화 없음, TDD gate 없음. v0 호환.
- **standard** — 실제 프로덕션 작업용. PRD interrogation, slice-plan, multi-reviewer, fix-loop, 전체 lifecycle (commit → push-pr → pr-watch → merge → cleanup) 추가.
- **strict** — mission-critical 코드용. standard와 같은 형태인데 gate가 실제로 막아요. 실패 test 없으면 production code 못 씀. Repository Pattern 위반하는 data layer 코드 금지. 모든 아키텍처 결정은 `lore/` 에서 인용 필수.

첫 실행 시 repo (commit history, test infra, CI config, ARCH/CONTRIBUTING 문서, README 크기)를 보고 추천합니다. 사용자가 확인하거나 override.

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
                (strict에서는 실패 test 없이는 에이전트가 production code 작성을 거부합니다)
 ├─ review      reviewer 에이전트 다중 병렬 spawn; architecture-design 전문가는 mandatory
 └─ fix-loop    must-fix 처리; 최대 3 round, 그 이후엔 사용자 에스컬레이션

OPERATIONS
 ├─ commit      convention 인식, profile 기반
 ├─ push-pr
 ├─ pr-watch    6-status routing, CI 실패 / PR 코멘트 자동 응답
 ├─ merge
 └─ cleanup     worktree 삭제, main 동기화, 남길 만한 결정은 lore로 기록 유도
```

light에서는 construction/operations 대부분이 skip — spec, design, build, ship. strict에서는 전부 활성화되고 gate가 진짜로 막음. profile + bolt 크기에 따라 깊이가 적응합니다.

## "Sprint" 대신 "Bolt"

bolt는 집중된 작업의 한 단위 — 주 단위가 아니라 시간 ~ 일 단위. AWS AI-DLC 용어에서 가져온 거고 쓸모 있음: `/divecode` 시작할 때 bolt 크기 (small / medium / large)를 묻고, 그 답이 각 phase 깊이를 바꿉니다. small bolt는 인터뷰가 한 줄 확인으로 collapse, large bolt는 모든 phase가 확장.

## 언제 쓰고, 언제 안 쓰나

**쓸 때**: 잘못된 결정 하나가 일주일 되돌리는 비용을 만드는 작업 전부. 데이터 모양. 돈. 인증. 멀티플랫폼 동기화. 실부하 성능. DB migration 포함. 포스트모템 쓸 만한 거.

**안 쓸 때**: 일회용 스크립트, one-off 탐색, 이틀 뒤 지울 코드. 그냥 vibe-code 하세요.

**스위트 스폿**: 시니어 엔지니어가 에이전트랑 페어로 실제 feature 작업. 또는 두 엔지니어 — 한 명이 멍청한 질문 던지고, 다른 한 명이 경험으로 답하고, 에이전트가 둘 다 생각 못 한 세 번째 걸 surface.

## Pattern packs

pack 시스템이 divecoding의 질문 생성기입니다. PRD에 키워드가 등장하면 그 pack이 트리거되고, 거기 담긴 questions / failure modes / test ideas 를 발사합니다. v0.3에서 deep pack 9개 출시:

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

각 pack 구성:
- `triggers` — divecode-prd가 PRD 텍스트와 매칭할 키워드
- `questions.md` — pack이 발사하는 실제 인터로게이션 프롬프트
- `failure-modes.md` — 이 pack이 막으려는 프로덕션 사고들
- `test-ideas.md` — 답이 만들어야 할 test case
- `example-patterns.md` — 구체적 예시 ("show, don't tell" 참고용)

`packs/` 에 PR 보내는 게 가장 leverage 큰 기여입니다. 에이전트가 물었어야 했던 부류의 버그에 물려본 적 있으면 — pack을 쓰세요.

## 써보기

```bash
# PRD 있는 프로젝트에서
/divecode-prd path/to/PRD.md
```

이 skill이 하는 일:
1. PRD에 대해 `bin/divecode-prd-triggers` 실행
2. 매칭된 pack을 사용자에게 확인 (false positive는 빼면 됨)
3. `divecode/risk-map.md` 에 각 pack의 failure modes 렌더
4. 매칭된 pack의 `questions.md` 합집합을 walk-through
5. 답한 내용으로 `divecode/design.md` §1 + §2 + §6 채움
6. design.md 나머지는 `/divecode-spec` 으로, TDD slice로 바로 점프하려면 `/divecode-slice-plan` 으로

번들된 fixture로 바로 테스트 (`/divecode-prd` 호출 없이 matcher만):

```bash
bash ~/.divecode/bin/divecode-prd-triggers \
  --prd ~/.divecode/tests/fixtures/prd-admin-dashboard.md \
  --packs-dir ~/.divecode/packs
```

이 PRD (agent-cat admin 사고를 세 문단짜리 spec으로 정리)는 6개 pack을 트리거하고 ~50개 질문을 surface합니다 — Redis stampede, cron 겹침, auto-refresh DDoS, IDOR / SSO 리스크, DynamoDB로 갈아탔다면 만날 partition-key trap. 실제로 시스템 내렸던 것들.

## divecoding의 자리

| 도구 / 방법론 | 강점 | 시도하지 않는 것 |
|---|---|---|
| AWS AI-DLC | Lifecycle macro flow (Inception → Construction → Operations) 와 "bolt" 단위 | 도메인 특정 failure-mode surface |
| GitHub Spec Kit | Spec-driven development, 구조화된 spec 포맷 | stack별 프로덕션 risk 인터로게이션 |
| Claude Skills | 에이전트 capability의 배포 + 실행 포맷 | 위에 올라가는 방법론 레이어 |
| **divecoding** | **PRD 인터로게이션 → human-in-loop 결정 추출 → niche failure-mode surface** | 전체 SDLC 소유, 티켓 시스템 대체 |

divecode는 자유롭게 훔쳐옵니다: AWS에서 macro shape, agent-flow에서 phase-internal guardrail, Clean Code에서 "discipline-is-the-feature" 자세, Spec Kit에서 artifact-first orientation. 자기 기여는 **PRD risk interrogation engine** 과 그걸 동작시키는 **pattern pack** 라이브러리.

## 톤 안내

skill들이 한국어/영어 혼용으로 말합니다 — 제가 그렇게 일하고, 동료들도 그렇게 일하니까. fork해서 본인 팀에 맞게 다시 톤 잡으셔도 됩니다. pack 자체는 언어 독립적이고, 에이전트 prompt 문구만 한국어가 섞여있어요.

## 레이아웃

```
divecode/
├── bin/          skill들이 호출하는 작은 bash 스크립트 (detect, bolt, lore, tdd-gate, pr-watch, ...)
├── skills/       SKILL.md 파일들 — Claude Code가 읽는 것
├── checklists/   v0 niche knowledge (redis, sql, nosql, perf, security, ux-hig).
│                 v0.3에서 packs/ 로 흡수됨.
├── packs/        Pattern packs (PRD interrogation의 핵심)
├── templates/    profile.yml, design.md, slice-plan.md, lore-entry, review templates
├── tests/        bin/ 스크립트용 bash test 묶음
└── docs/         v0.2/ — divecode 자신의 meta-spec
                  v0.3/ — PRD interrogation engine spec
```

## 기여

가장 도움 되는 PR은 `packs/` 에 새 pack 추가입니다. 에이전트가 물었어야 할 부류의 버그에 물려본 적 있으면 — triggers + questions + failure-modes + example-patterns 갖춰서 pack으로 쓰세요. 거기가 leverage 큰 자리.

새 skill이나 pipeline phase는 issue 먼저 열어주시면 어디 위치할지 같이 얘기.

## 라이센스

MIT. 쓰시고, fork하시고, 톤 바꾸시고, 언어 바꾸시고, 회사 내부 도구에 박으세요. 프로덕션 사고 하나만 막아줘도 본전.
