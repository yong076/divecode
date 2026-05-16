# Changelog

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
