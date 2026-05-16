# divecode v0.3 — PRD interrogation engine

> Sharpens divecoding's product wedge. Adds `/divecode-prd` as a first-class Inception entry that takes a rough PRD, fires pattern-pack triggers, and produces `design.md` + `risk-map.md` + `open-questions.md` before any code is generated.

## 1. Why this exists (user's diagnosis)

v0.2 has the full divecoding workflow — AWS AI-DLC macro flow, agent-flow guardrails, TDD gate, PR watch. But the **product wedge** — "throw a rough PRD in, get the failure modes back" — isn't surfaced as a top-level capability. The current `/divecode` entry routes by stage; it doesn't ingest a PRD.

User's direct quote (2026-05-17):
> "대충 쓴 PRD를 넣으면, AI가 바로 코딩하지 않고 '이거 만들다 터질 니치 케이스'를 먼저 끌어내는 개발 워크플로우. 즉, AI-DLC의 큰 흐름을 가져오되, 진짜 차별점은 PRD risk interrogation engine."

Concrete trigger: an agent-cat admin incident where Redis stampede + cron warm-up + dashboard auto-refresh combined to take Redis down. Every single risk in that incident is a pack-detectable pattern from a 3-paragraph PRD.

## 2. Spec

### Goal
Make divecode's first-touch experience be: "paste PRD → get risk-mapped questions" instead of "answer my phase-by-phase interview".

### In-scope (v0.3)
- New skill `/divecode-prd` — takes a PRD (path or pasted text) and runs the interrogation
- New directory `packs/` with the structure detailed in §4
- `bin/divecode-prd-triggers` — Bash trigger-matching engine (scans PRD for pack triggers)
- Output artifacts: `divecode/design.md` (populated §2 Spec from PRD), `divecode/risk-map.md` (per-pack failure modes that apply), `divecode/open-questions.md` (questions to interrogate)
- 10 seed packs: redis-cache, postgres-saas, admin-dashboard, vercel-serverless, payments, auth-rbac, realtime-sync, telemetry-privacy, macos-app, github-releases
- Migration: `checklists/` → `packs/<topic>/questions.md` (preserving v0 entries as the seed)
- README hook example uses the agent-cat admin incident as the canonical war-story

### Out-of-scope (v0.4+)
- LLM-driven trigger expansion (using the PRD itself to generate new triggers)
- Pack version pinning / dependency between packs
- Web UI for browsing packs
- Auto-discovery of community pack repos
- Multi-language pack support (English-only triggers v0.3)

### Acceptance criteria
1. `/divecode-prd path/to/PRD.md` produces 3 artifacts in `divecode/`
2. `risk-map.md` lists every pack whose triggers matched the PRD, with the pack's failure-modes
3. `open-questions.md` contains the merged question set (with provenance — which pack each question came from)
4. The agent-cat admin PRD test case fires at least 4 packs (redis-cache, postgres-saas, admin-dashboard, vercel-serverless) and surfaces ≥10 questions
5. PRs to `packs/<name>/` only require the four files (triggers / questions / failure-modes / test-ideas) — no skill code changes
6. Skipping `/divecode-prd` and going directly to `/divecode-spec` still works (backward compat)

### Observable behavior
- `/divecode-prd` exists as a Claude Code skill
- Pattern matching is keyword-substring + word-boundary (no regex DSL for v0.3)
- Trigger files use simple YAML-front-matter: `triggers: [redis, ttl, upstash]`
- Questions render with a `[pack-name]` provenance prefix so the user sees where each question came from

### Dependencies
- Bash (trigger matcher)
- Claude Code skill system (carries the interactive interrogation)
- Optional: `divecode-lore-cite` (v0.2) to merge in cross-bolt directives during PRD ingest

### Open risks
- **R-OR1**: Trigger collisions — same keyword in multiple packs (e.g., "auth" hits both auth-rbac and payments). Mitigation: dedupe questions across packs by hash of question text.
- **R-OR2**: PRD is too short to fire anything — divecode falls back to asking the user which domain facets apply (manual pack selection).
- **R-OR3**: 10 seed packs is a curation bottleneck. Mitigation: ship 5 high-quality packs (redis, postgres, admin, vercel, payments) first; community adds the rest.

## 3. DDD model

### Aggregates (new in v0.3)
- **PRD** — the input artifact; raw text, optional metadata (project name, stack hints)
- **Pack** — a domain-specific question generator with triggers, questions, failure modes, examples
- **TriggerMatch** — the join: which packs fired against which PRD, with confidence
- **InterrogationSession** — the running state of a PRD-driven session: which questions asked, which answered, which deferred

### Bounded contexts
- **PRD interrogation** (new): PRDs, Packs, TriggerMatches, Questions
- **Lifecycle** (existing v0.2): Bolts, Slices, lifecycle phases

### Ubiquitous language (new)
- **pack** — replaces "checklist" as the unit of niche-knowledge
- **trigger** — keyword/phrase that, when present in PRD, fires a pack
- **risk-map** — the rendered union of failure-modes from fired packs
- **open-questions** — the queued interrogation set

### Domain events
- `PRDIngested(prdPath, length)`
- `PackTriggered(packName, matchedTriggers, snippet)`
- `QuestionGenerated(packName, questionId, severity)`
- `QuestionAnswered(questionId, answer)`
- `QuestionDeferred(questionId, reason)`

### Repository contracts
- `PackRepo` — read `$DIVECODE_HOME/packs/*` + `<project>/.divecode/packs/*` (cascade like lore)
- `PRDRepo` — read PRD from path; persist normalized form to bolt directory
- `InterrogationStateRepo` — `~/.divecode/state/bolts/<id>/interrogation.json`

## 4. Clean Architecture layer map

### domain (concepts in SKILL.md + YAML schemas)
- Pack schema (triggers/questions/failure-modes/test-ideas/example-patterns)
- Risk-map schema (per-pack failure summary)
- Open-questions schema (with provenance)

### usecase (SKILL flows)
- `divecode-prd` — the orchestrator: ingest → match → render risk-map → drive interrogation → write design.md + risk-map.md + open-questions.md

### data (Bash adapters)
- `bin/divecode-prd-triggers` — scan PRD against pack triggers, output matched packs
- `bin/divecode-pack-render` — given a pack, output its questions / failure modes as merged markdown
- Pack file readers (YAML front-matter + markdown body)

### presentation
- Risk-map markdown render
- Open-questions markdown render (grouped by pack, with provenance)
- Interactive question asking via `AskUserQuestion`

## 5. SOLID check

| Principle | How v0.3 honors it |
|---|---|
| SRP | `divecode-prd` only orchestrates PRD interrogation. Match/render/ask are separate scripts. |
| OCP | New packs added by dropping a directory in `packs/` — no code change |
| LSP | Every pack must satisfy `{triggers: list, questions.md, failure-modes.md, test-ideas.md}` minimum contract |
| ISP | The skill reads only the pack files it needs to render the current phase (lazy load per-pack) |
| DIP | `divecode-prd` depends on pack abstraction, not specific packs (no hard-coded "if redis then..." logic) |

## 6. Decision log

### Directives
| ID | Decision | Why |
|---|---|---|
| D1 | `divecode-prd` is a new skill, not a flag on `divecode-spec` | Different entry experience — PRD ingest vs cold interview |
| D2 | Packs live in a separate top-level `packs/` directory, not under `checklists/` | Semantic break: checklists are static lists, packs are active question generators |
| D3 | Trigger matching is keyword-substring + word-boundary; no regex DSL for v0.3 | Simpler, faster, lower contributor barrier |
| D4 | Question provenance prefix `[pack-name]` is visible to user | Trust + debuggability — user sees why a question was asked |
| D5 | Packs cascade (user-global `~/.divecode/packs/` + project-local `.divecode/packs/`) like lore | Same mental model the user already knows |
| D6 | `/divecode-prd` produces 3 artifacts; design.md is shared with v0.2 spec phase | Existing pipeline (slice-plan → worktree → implement) just works |
| D7 | 10 seed packs in v0.3, with quality > quantity bias (ship 5 deep before adding 5 shallow) | RAG-style breadth without depth = useless |
| D8 | Existing `checklists/` files are migrated, not deleted — they become each pack's `questions.md` seed | Backward compat + smooth migration |

### Rejected
| ID | Approach | Why |
|---|---|---|
| R1 | LLM-driven trigger expansion (use the agent to invent triggers from PRD) | v0.3 wants the trigger logic deterministic and debuggable. v0.4 can layer this on. |
| R2 | RAG over all packs as a single knowledge base | Loses the active-question-generator distinction. User's diagnosis was explicit on this. |
| R3 | Pack inheritance / pack dependencies | Premature; ship the flat model first |
| R4 | Force `/divecode-prd` as the only inception entry | Backward compat — projects without a written PRD should still flow through `/divecode-spec` |

### Constraints
| ID | Constraint |
|---|---|
| C1 | Pack contributors should not need to write Bash or know divecode internals — just markdown files |
| C2 | A pack with zero triggers is invalid (must be detectable from PRD text) |
| C3 | Trigger keywords are case-insensitive but must respect word boundaries (don't match "ttl" inside "throttle") |
| C4 | Risk-map output must distinguish "this WILL bite you" (severity: high) from "watch for this" (severity: medium) from "good practice" (severity: info) — same severity model as findings in v0.2 |

## 7. UX

- "UI 있어?" → divecode itself, no. divecode-prd's interaction surface is chat (`AskUserQuestion` + markdown artifact previews + file path announcements).
- 5-state coverage:
  - **Ideal**: PRD is rich, ≥3 packs trigger, ≥8 questions queued, user answers all → design.md populated end-to-end
  - **Empty**: PRD too short or too generic → divecode falls back to asking which domain facets apply (manual pack selection)
  - **Loading**: large PRD (≥5kb) — trigger matching runs in foreground, target < 1s
  - **Error**: PRD path missing or unreadable → specific message, not stack trace
  - **Edge**: PRD mentions a brand-new technology with no pack — divecode flags as `pack_missing` finding and suggests writing a pack

## Slice plan preview (for the bolt that builds this)

1. **Pack schema + 1 seed pack** (redis-cache) + reader script + tests
2. **Trigger matcher** `bin/divecode-prd-triggers` with tests on the agent-cat admin PRD fixture
3. **divecode-prd SKILL** orchestrating ingest → match → ask
4. **9 more seed packs** (postgres-saas, admin-dashboard, vercel-serverless, payments, auth-rbac, realtime-sync, telemetry-privacy, macos-app, github-releases)
5. **Migration**: existing `checklists/{redis,sql,nosql,perf,security,ux-hig}.md` → `packs/<corresponding>/questions.md` plus a stub `triggers`/`failure-modes`/`test-ideas`/`example-patterns`
6. **README + CHANGELOG update** showing the new entry experience
7. **Backward compat verification** — `/divecode-spec` direct invocation still works for cold-start cases

Each slice TDD'd (trigger matching gets a real test suite; markdown packs get structural validation).

## Open questions for the user (for the next divecoding session that builds this)

1. Should `/divecode-prd` and `/divecode-spec` coexist as separate entries, or should the entry SKILL auto-detect "is there a PRD" and route accordingly?
2. For pack provenance display, do you want the prefix `[redis-cache]` always visible, or only on first question per pack?
3. For multi-PRD projects (PRD has been iterated), should divecode-prd diff against the previous PRD and only ask about new/changed sections? Or always ingest fresh?
4. Pack severity (high/medium/info) — declared per-question in the pack, or computed from how many packs flagged the same failure mode?
