# divecode

> **Vibe coding의 반대편.** 에이전트가 코드를 흘려보내게 두지 말고, 디테일을 끝까지 파고들어 함께 만든다.

Clean Code가 *어떻게 쓸지*를 가르쳤다면, **divecode는 *무엇을, 왜* 만들지를 에이전트와 함께 끝까지 캐묻는 방법**이다. 5단계 파이프라인을 인간이 페이스메이커가 되어 ralph-loop처럼 함께 돈다.

## 1줄 설치

```bash
curl -fsSL https://raw.githubusercontent.com/yong076/divecode/main/bootstrap.sh | bash
```

이 한 줄이 하는 일:
1. `~/.divecode/`에 clone
2. `~/.claude/skills/divecode*` 로 심링크 (Claude Code가 인식)
3. 다음 세션부터 `/divecode`로 호출 가능

업데이트는 같은 명령 다시 실행. 제거는 `bash ~/.divecode/uninstall.sh`.

## 사용

프로젝트 디렉토리에서:

```
/divecode
```

divecode가 현재 단계를 자동으로 판단해서 다음 스킬로 분기한다. 직접 호출도 가능:

| Skill | 산출물 | 역할 |
|---|---|---|
| `/divecode-spec` | `divecode/requirements.md` | 도메인·성능·DB·edge case를 끝까지 캐묻는 심문 |
| `/divecode-design` | `divecode/design/*.html` | HTML 와이어프레임 + "이 케이스 봤어?" 질문 루프 |
| `/divecode-arch` | `divecode/ARCHITECTURE.md` | DTO·레이어·경계·트랜잭션 결정 |
| `/divecode-implement` | (소스 코드) | 산출물 보면서 구현 — 매 단계 인간 확인 |
| `/divecode-status` | (콘솔 출력) | 사용량 한도 추적, "지금 돌리면 한도 걸려" 사전 경고 |

## Iron Laws

1. **인간이 답하지 않은 질문은 가정으로 채우지 않는다.** 멈추고 묻는다.
2. **모든 단계의 산출물(.md/.html)을 인간이 검토해야 다음 단계로 넘어간다.**
3. **niche 지식은 체크리스트로 강제 노출한다.** Redis cache stampede, isolation level, N+1, eventual consistency, HIG 등.
4. **Ralph loop이 아니라 human-in-the-loop ralph.** 사람이 페이스메이커.

전체 원칙은 [MANIFESTO.md](MANIFESTO.md).

## Vibe coding과의 차이

| | Vibe coding | divecode |
|---|---|---|
| 코드 검토 | 안 함 (흘러가게 둠) | 매 단계 인간 검토 강제 |
| 요구사항 | "이거 만들어줘" 한 줄 | 도메인 전문가 수준 심문 |
| 디자인 | 에이전트가 알아서 | HTML mockup → 인간 확인 |
| 아키텍처 | 묻지 않음 | DTO/레이어/경계까지 합의 |
| 페이스 | 에이전트가 결정 | 인간이 결정 |
| 결과 | 빠른 prototype | 같이 만든 시스템 |

vibe coding이 빠른 prototype을 만든다면, divecode는 **잘못된 코드가 빨리 만들어지는 걸 막는** 도구다.

## 사용량 추적

`/divecode-status`는 다음 순서로 사용량 도구를 찾는다:
1. [`llm-usage-cli`](https://github.com/yong076/llm-usage-cli) (Codex/Claude/Gemini 통합)
2. [`ccusage`](https://github.com/ryoppippi/ccusage) (Claude 전용)
3. 둘 다 없으면 휴리스틱 안내 ("이 작업은 큰 변경이라 5시간 한도 절반 정도 쓸 것 같음")

큰 작업 시작 전 `/divecode-status`로 한 번 확인하는 게 좋다.

## 디자인 통합

`/divecode-design`은 다음 순서로 디자인 도구를 찾는다:
1. [`open-design`](https://github.com/nexu-io/open-design) — 본격 design system 작업이면 위임
2. 없으면 inline HTML mockup 생성 (외부 의존 없음, 브라우저에서 바로 확인 가능)

## 어떤 사람에게 맞나

- 백/프론트/앱/인프라를 다 아우르는 시니어 — divecode가 진가를 발휘함
- 또는 그런 동료와 페어로 앉아 같이 답하는 주니어 — 학습 도구로도 작동
- 혼자 처음부터 다 답할 자신이 없으면? 그래도 됨 — 모르는 질문이 나오면 거기가 학습 포인트

## 라이센스

MIT.

## 기여

PR 환영. 특히 `checklists/`에 새로운 niche 지식 항목 추가하는 PR이 가장 가치 있다.
