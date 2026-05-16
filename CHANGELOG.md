# Changelog

## v0.3.1 — 2026-05-17

> Pack polish + Genie reframe. The 4 stubs created during v0.3 migration (nosql, performance, security, ux-apple-hig) become first-class deep packs with real triggers, failure-modes, test-ideas, and example-patterns. divecoding repositioned around the Aladdin Genie metaphor.

### Added

- **Genie principle** in MANIFESTO.md as the meta-rule that subsumes the 13 operational principles. Coding agents grant wishes literally; divecoding's only universal rule is *pause before granting and ask the user to specify*. Every existing phase/profile/gate is this principle at a different granularity.
- **`/divecode-wish`** — always-on lightweight Genie pause for ad-hoc commands (no PRD required). Same trigger matcher as `/divecode-prd`, fed the user's request. Three Genie questions: (1) literal grant confirmation, (2) unspecified dependencies (drawn from matched packs), (3) the choice (specify / grant literally / refine / abandon).
- **4 polished packs**:
  - `nosql` — DynamoDB / Mongo / Firestore / Cassandra; hot partition, eventual consistency, single-table access patterns, document size limits
  - `performance` — N+1, waterfall fetches, bundle bloat, cold start, offset pagination, Web Vitals
  - `security` — IDOR, authz gap on API endpoints, secrets in git, PII in logs, CSRF, password hashing, open redirect, rate limit, CORS
  - `ux-apple-hig` — Dynamic Type, Dark Mode, Safe Areas, 44pt touch targets, VoiceOver, Reduce Motion, sheet vs nav

  Each ships with triggers + failure-modes + test-ideas + example-patterns. The 4 v0.3 stubs are now fully replaced.

### Changed

- README hook completely reframed around the Aladdin Genie story (was: "you wrote a three-paragraph PRD"). Same content, but legible in one paragraph and emotionally memorable.
- README pack inventory now shows all 9 packs as ✓ — distinguishes shipped from "coming next" backlog (realtime-sync, telemetry-privacy, macos-app, github-releases).
- README "Try it" command corrected: was `divecode-prd-triggers ...` (not on PATH for end users); now `bash ~/.divecode/bin/divecode-prd-triggers ...` (works for anyone who installed via bootstrap).
- Agent-cat fixture demo now reports **6 packs / ~50 questions** (was 5 packs / ~40 questions) — security pack fires too via "SSO" keyword once triggers were filled.

### Compatibility

- All v0.3 skills + packs unchanged in behavior; only stub content was upgraded
- No new tests required (existing test-pack-read / test-prd-triggers still pass — the migrated stubs were always valid pack structure)

## v0.3 — 2026-05-17

> Product wedge. Sharpens divecoding to its actual differentiator: **PRD risk interrogation**. Drop a rough PRD in, get the failure modes back before any code is generated. AWS AI-DLC owns lifecycle; GitHub Spec Kit owns spec format; Claude Skills owns distribution — divecoding owns "what could break" given your stack.

### Added

**`/divecode-prd` skill** — Inception entry that ingests a PRD, fires pattern-pack triggers, surfaces failure modes as a `risk-map.md`, walks you through `open-questions.md` with provenance prefixes, and populates `design.md` §1 + §2 + §6.

**Pattern pack system** in `packs/`:
- 5 hand-written deep packs (~10-30 questions, 6-9 failure modes, 4-8 test ideas, 3-5 example patterns each):
  - `redis-cache` — TTL / stampede / eviction / connection pool
  - `postgres-saas` — connection management / migrations / N+1 / replica lag / drift
  - `admin-dashboard` — auth gaps / auto-refresh DDoS / destructive actions / PII
  - `vercel-serverless` — timeouts / cold starts / cron overlap / connection storms / 3DS
  - `payments` — idempotency / webhook replay / source-of-truth drift / dunning / SCA
- 4 stub packs migrated from v0 checklists (carry the questions; need human polish for triggers + failure-modes): `nosql`, `performance`, `security`, `ux-apple-hig`

**Trigger matcher** `bin/divecode-prd-triggers` — scans PRD against every pack's `pack.yml triggers` list. Word-boundary matching for single-word triggers (`ttl` won't match `throttle`); literal substring for multi-word (`cache stampede`). Case-insensitive. Output is one section per matched pack with which triggers fired.

**Pack reader** `bin/divecode-pack-read` — read mode flags (`--triggers / --meta / --questions / --failures / --tests / --examples / --all`). Used by `/divecode-prd` to compose risk-map and open-questions.

**Migration script** `bin/divecode-pack-migrate` — scaffold packs from existing `checklists/*.md`. Idempotent. Maps known checklist names (redis → redis-cache, sql → postgres-saas, etc.); preserves any pack that already exists. The 4 stub packs above were created by this script.

**Tests** — 3 new bash test suites (`test-pack-read`, `test-prd-triggers`, `test-pack-migrate`): 25 new assertions. End-to-end smoke: the included `tests/fixtures/prd-admin-dashboard.md` (the agent-cat war-story PRD) fires all 5 deep packs.

### Changed

- README now documents the pack system as live (`✓ deep` vs `⚠ stub`), shows a "Trying it" section with concrete command, and includes the agent-cat fixture as the canonical demo
- README's pack roadmap distinguishes shipped vs v0.4 backlog

### Compatibility

- `checklists/` directory preserved — packs scaffolded from it, but legacy paths still work
- `/divecode` entry SKILL routing unchanged; `/divecode-prd` is an alternative inception entry, not a replacement for `/divecode-spec`
- v0.2 lore + bolt + profile machinery unchanged

### Known limitations

- 4 migrated packs (nosql / performance / security / ux-apple-hig) need human-written triggers before they'll fire — `triggers: TODO` placeholder by design (don't auto-pick keywords)
- Trigger matching is deterministic keyword-based; no LLM-driven expansion in v0.3 (deferred to v0.4 per design.md decision R1)
- False positive on payments pack for PRDs that mention "billing" in out-of-scope sections — `/divecode-prd` Step 3 user confirmation is the safety net

## v0.2 — 2026-05-17

> Methodology layer. divecode = AWS AI-DLC macro (Inception → Construction → Operations) + agent-flow phase-internal guardrails + divecode-original additions (UX, niche-knowledge checklists, audit, usage awareness, profile/bolt adaptive depth).

### Added

**Concepts**
- **Profile system** (`light` / `standard` / `strict`) with auto-detect on first run via 6 signals (multi-contributor / tests / CI / ARCH doc / CONTRIBUTING / substantial README)
- **Bolt** — unit of focused work (replaces "sprint", from AWS AI-DLC). Bolt size (S/M/L) asked once at `/divecode` entry; phases adapt accordingly
- **Lore cascade** — `~/.divecode/lore/` (user-global) + `<project>/.divecode/lore/` (project-local) with Constraint / Rejected / Directive entry kinds (agent-flow compatible)
- **Audit mode** — Inception sub-phase auto-invoked on in-progress projects (existing source or `feature/*` branch)

**Skills (10 new)**
- `divecode-audit` — formalizes the retroactive interrogation pattern (read source + MD + sibling repos + OSS comparison → surface silent decisions → evidence-cited interrogation questions)
- `divecode-slice-plan` — decompose into TDD-ready slices, profile-conditional fields
- `divecode-worktree` — branch + worktree per `profile.branching`
- `divecode-review` — multi-reviewer spawn via Agent tool; architecture-design specialist mandatory for standard/strict
- `divecode-fix-loop` — max 3 rounds, escalate-to-user gate
- `divecode-commit` — group changes per `profile.commit_convention`
- `divecode-push-pr` — push + open PR with structured body (degrades gracefully without `gh`)
- `divecode-pr-watch` — 6-status / 7-route routing per agent-flow exact contract
- `divecode-merge` — strategy-aware merge per `profile.pr.merge_strategy`
- `divecode-cleanup` — worktree removal, integration sync, lore prompt

**Scripts (`bin/`)**
- `divecode-detect` — profile auto-detection (6 signals → score → light/standard/strict)
- `divecode-bolt-new` / `divecode-bolt-current` — bolt lifecycle
- `divecode-lore-cite` — cascade reader + relevance-rank + envelope inject
- `divecode-sibling-repos` — heuristic discovery (dashed / collapsed / title-cased prefixes)
- `divecode-migrate` — v0 split files (req.md + design/ + ARCH.md) → v0.2 unified design.md, originals archived
- `divecode-branch-slug` — kebab-case slug derivation with article stripping
- `divecode-tdd-gate` — refuse production write before failing test exists (exit 0 RED / 1 no-RED / 2 missing / 3 broken)
- `divecode-repo-pattern-check` — heuristic Google Repository Pattern lint
- `divecode-pr-watch` — JSON-output PR status fetcher with fixture mode

**Templates**
- `profile.yml.template`, `design.md.template`, `slice-plan.md.template`, `audit.md.template`, `lore-entry.md.template`, `pr-body.md.template`, `final-review.md.template`
- `review/architecture-design.md` — mandatory reviewer template combining DDD + Clean Architecture + SOLID

**Tests**
- 9 bash test suites covering all `bin/` scripts (detect, bolt, lore, audit/sibling-repos, migrate, branch-slug, tdd-gate, pr-watch) — 70+ assertions

### Changed

- `skills/divecode/SKILL.md` — entry point now profile-aware. Detects profile state, recommends via `divecode-detect`, routes to v0 (light) or v0.2 (standard+) flow
- `skills/divecode-spec/SKILL.md` — profile-aware artifact target: `requirements.md` in light, unified `design.md` in standard+; auto-injects relevant lore on entry
- `skills/divecode-implement/SKILL.md` — profile-aware TDD gate (`refuse` in strict, `warn` in standard, `off` in light) and Repository Pattern check

### Compatibility

- v0 → v0.2 backward compat preserved for `light` profile (no migration needed)
- Upgrading from `light` to `standard`+ prompts user before merging req.md + design/ + ARCHITECTURE.md into unified design.md
- All v0 skill triggers still work
- `~/.claude/skills/divecode*` symlinks unchanged; `install.sh` is idempotent and picks up the 10 new skills

### Architecture roots

- **Macro flow**: [AWS AI-DLC](https://aws.amazon.com/blogs/devops/ai-driven-development-life-cycle/) (Inception → Construction → Operations)
- **Phase-internal guardrails**: agent-flow YAML chain pattern (interview / DDD / Clean / SOLID / TDD / pr-watch routing)
- **divecode-original**: UX phase, niche-knowledge checklists, usage limit awareness, audit mode, "is there UI?" forcing function

## v0 — 2026-05-16

Initial release. 6 Claude Code skills (`divecode`, `divecode-spec`, `divecode-design`, `divecode-arch`, `divecode-implement`, `divecode-status`). One-line install via `bootstrap.sh`. checklists/ for niche knowledge (Redis / SQL / NoSQL / perf / security / UX-HIG).
