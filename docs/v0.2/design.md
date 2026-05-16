# divecode v0.2 — design.md

> Unified design artifact produced by the divecode-spec phase against divecode itself (meta-dogfood). Six canonical sections (per agent-flow) plus UX section 7 (per divecode-original).

## 1. Interview (grill-me)

The spec interrogation was conducted in 4 rounds of 4 questions each (16+ decisions) on 2026-05-16/17, captured in the conversation transcript. Key strategic framing came from user clarification:

> "큰 틀(순서와 flow)는 AWS가 맞고, 세세한 가드레일/하네스는 AWS + agent-flow 합친 게 divecoding."

So divecode v0.2 = **AWS AI-DLC macro** (Inception → Construction → Operations) + **agent-flow phase-internal guardrails** + **divecode-original additions** (UX, niche-knowledge checklists, audit mode, usage awareness, profile/bolt adaptive depth).

No questions remain unanswered for the v0.2 scope. Items deferred to v0.3+ are noted in §2 out-of-scope.

## 2. Spec

### Goal
Codify the AI-DLC-rooted, agent-flow-rigorized, divecode-customized methodology as a Claude Code skill set that a developer can install in one curl line and use across greenfield, in-progress, and rigor-varying projects.

### In-scope
- Three profiles (`light` / `standard` / `strict`) with auto-detect on first run
- Bolt-size question (S/M/L) at `/divecode` entry, used by all phases for adaptive depth
- UX phase always asked ("UI 있어?") — never silently skipped
- Audit mode as Inception sub-phase, auto-invoked when project is in-progress
- Unified `design.md` for `standard`/`strict`; separate `requirements.md` / `design/` / `ARCHITECTURE.md` for `light`
- Lore cascade (user-global `~/.divecode/lore/` + project-local `.divecode/lore/`)
- Lore entry kinds: `Constraint` / `Rejected` / `Directive` (agent-flow compat)
- Decision log written BOTH to design.md §6 AND auto-mirrored to `.divecode/lore/decisions/`
- Slice-plan format profile-conditioned (light simple, standard+ full)
- TDD strict gate enforced via Bash refuse-write
- Multi-reviewer with architecture-design specialist mandatory + `profile.review_angles`
- `pr-watch` with agent-flow's full 6-status / 7-route routing
- Status (usage limit) observed in background, threshold-triggered interjection
- v0 → v0.2 migration prompt (only when upgrading from light to standard+)
- All in Claude Code SKILL.md format, distributed via existing `install.sh`

### Out-of-scope (v0.3+)
- Amazon Q Project Rules export
- Cross-agent skill format (Codex CLI / Gemini CLI / Cursor)
- Real-time pair-programming session (two humans + agent)
- KRW / locale-specific niche checklists
- Self-hosted lore sync (sharing lore across machines)
- IDE integration beyond Claude Code

### Acceptance criteria
1. `/divecode` on a fresh project runs auto-detect → recommends profile → asks bolt size → asks "UI 있어?" → routes to first phase
2. `/divecode` on an in-progress project (git history exists + `feature/*` branch or existing source) runs `divecode-audit` before spec automatically
3. `/divecode-implement` in `strict` refuses to write production code when no failing test exists in the slice
4. Lore entries cited in any phase are auto-injected into that phase's prompt envelope
5. `/divecode` on a project with existing v0 `requirements.md` works without breaking. If profile-detect recommends `standard`+, divecode asks before migrating
6. `pr-watch` correctly routes `green`/`has_comments`/`ci_failed`/`pending`/`closed`/`error`/`merged`/`skipped`
7. `divecode-status` interjects when usage crosses 70% threshold of any window
8. `install.sh` adds the 10 new skills idempotently alongside the existing 6

### Observable behavior
- 16 total SKILLs (existing 6 + 10 new: `divecode-audit`, `divecode-slice-plan`, `divecode-worktree`, `divecode-review`, `divecode-fix-loop`, `divecode-commit`, `divecode-push-pr`, `divecode-pr-watch`, `divecode-merge`, `divecode-cleanup`)
- Per-project `.divecode/profile.yml` (kind, gates, branching, review_angles, commit_convention, pr config)
- Cascading lore: `~/.divecode/lore/` and `.divecode/lore/` both read, project-local takes precedence on duplicate names
- Bolt directory: `~/.divecode/bolts/<bolt-id>/` with phase artifacts and status marker
- Phase artifacts under `<project>/divecode/`:
  - `light`: `requirements.md`, `design/`, `ARCHITECTURE.md` (preserved from v0)
  - `standard`/`strict`: `design.md`, `slice-plan.md`, `implement.md`, `final-review.md`, `pr-watch.md`, ...

### Dependencies
- **Hard**: Claude Code skill system, git, Bash
- **Soft (graceful degrade)**: `gh` CLI (push-pr/pr-watch), `llm-usage-cli` or `ccusage` (status), `open-design` (UX phase escalation)
- **Compatibility target**: agent-flow YAML chain format (so divecode lore + decision log can be cross-cited with awslabs/aidlc-workflows downstream)

### Open risks
- **R-OR1: UX-always-ask friction for backend devs.** Mitigation: cache the answer in `profile.yml` after first response; subsequent invocations skip the question silently.
- **R-OR2: Background status observation complexity.** Mitigation: v0.2 ships with explicit `/divecode-status` invocation; background watcher (threshold interjection) becomes a v0.3 stretch goal if poll-based hooks turn out unreliable.
- **R-OR3: Multi-reviewer spawning is Claude Code-only.** Acceptable for v0.2 (Claude Code is the launch surface). v0.3 abstracts to `codex review` / `gemini` adapters.
- **R-OR4: TDD bash gate may produce false refusals** (e.g., test file exists but assertion is wrong syntax). Mitigation: gate output includes the exact stderr so the user can override with explicit `--allow-no-red` flag in worst case.

## 3. DDD model

divecode is meta-tooling — but it does have a small genuine domain.

### Aggregates
- **Bolt** — a unit of focused work (AWS "bolt" terminology). Consistency boundary: one bolt = one branch = one PR = one merge. Has profile, size, phases, artifacts, status.
- **Profile** — `light` / `standard` / `strict`. Holds the phase set, gates, mandates, reviewer angles, branching/commit/PR conventions.
- **LoreEntry** — kind ∈ {Constraint, Rejected, Directive}, scope ∈ {user, project}, body markdown.
- **Slice** — sub-unit of a Bolt during Construction. Goal, layer scope, aggregates touched (in standard+), test cases, files expected, verification command.

### Bounded contexts (touched)
- **Divecode core** — profiles, bolts, slices, lifecycle orchestration
- **Lore** — citation/injection across phases (separate ubiquitous language for `kind` vs `scope`)
- **Adapter** — `gh` / `git` / `llm-usage-cli` integration; cross-context translation lives here

### Ubiquitous language (new or refined)
- **bolt** (NEW per AWS AI-DLC) — replaces "sprint"; hours-to-days scope
- **phase** (kept) — bolt sub-unit; the 12 named phases
- **slice** (kept) — implement-phase sub-unit
- **lore entry** (NEW) — Constraint / Rejected / Directive
- **gate** (NEW) — automated check that blocks phase exit (e.g., TDD-red-exists)
- **rigor profile** (NEW) — light / standard / strict
- **adaptive depth** (NEW, from AWS) — phase scope set by bolt size + profile

### Domain events (minimal payload, past tense)
- `BoltStarted(boltId, profile, size, projectPath)`
- `ProfileRecommended(boltId, profile, signals)`
- `ArtifactProduced(boltId, phaseId, artifactPath)`
- `SliceCompleted(boltId, sliceId, redGreenRefactor)`
- `ReviewBlocked(boltId, findings)`
- `BoltMerged(boltId, mergeCommitSha)`
- `LoreEntryAdded(scope, kind, name)`

### Repository contracts
- **ProfileRepo** — read `.divecode/profile.yml`, write on profile-recommend confirm
- **LoreRepo** — cascade read user + project; rank by relevance; inject
- **BoltRepo** — `~/.divecode/bolts/<id>/`; status marker, artifacts, completion timestamp
- **GhAdapter** — read PR status, push branch, open PR (graceful degrade if no `gh`)

## 4. Clean Architecture layer map

divecode is prompt-based, not code-based — but the layer discipline still applies to how SKILLs are structured.

### domain (in SKILL.md "concepts" sections and YAML schemas)
- profile types (yaml schema)
- bolt lifecycle (state machine description in entry SKILL)
- lore entry types
- slice format (profile-conditional)
- gate definitions (pass/fail conditions)

### usecase (SKILL flows — orchestration)
- entry: `divecode` (detect → route)
- inception: `divecode-audit`, `divecode-spec`, `divecode-design`, `divecode-arch` (light) or unified `divecode-design` (standard+)
- inception cont.: `divecode-slice-plan`
- construction: `divecode-worktree`, `divecode-implement`, `divecode-review`, `divecode-fix-loop`
- operations: `divecode-commit`, `divecode-push-pr`, `divecode-pr-watch`, `divecode-merge`, `divecode-cleanup`
- cross-cut: `divecode-status`

### data (Bash preambles inside SKILL.md)
- `profile.yml` reader (yq / awk)
- lore cascade reader (`bin/divecode-lore-cite`)
- bolt status reader/writer (`~/.divecode/bolts/<id>/status.json`)
- `gh` CLI adapter (`bin/divecode-pr-watch`)
- `git` adapter (worktree create/delete)
- usage CLI adapter (`llm-usage` / `ccusage` graceful detect)
- TDD gate (`bin/divecode-tdd-gate` — runs slice tests, asserts ≥1 failing assertion before allowing production write)

### presentation (SKILL output formatting + AskUserQuestion patterns)
- decision tables (consistent column format across SKILLs)
- per-phase artifact path announcement
- per-phase pause prompts
- threshold alert format for status

### Dependency direction
usecase (SKILLs) → data (bash adapters) → external (git/gh/usage CLI). Domain (yaml/concepts) has zero outward dependency. Verified: no SKILL imports another SKILL directly — routing is always through entry SKILL.

## 5. SOLID check

For each new abstraction:

| Principle | How divecode honors it | Risk |
|---|---|---|
| **S**RP | Each SKILL = one phase. No SKILL does two phases. | `divecode-design` (standard+) combines what was 3 SKILLs in v0 (spec/design/arch) — accepted because it matches agent-flow's single design phase, but tag as "phase combines six sub-sections, not three responsibilities" |
| **O**CP | New profiles extend by adding to `profile.yml` schema; SKILLs read profile and dispatch — no SKILL modification required | n/a |
| **L**SP | Any profile must satisfy contract: `{phases: list, gates: object, mandates: object}`. `strict` is `standard` with stricter gates only — no narrower contract | n/a |
| **I**SP | SKILLs read only the profile fields they need (e.g., `divecode-implement` reads `mandates.tdd` and `mandates.repository_pattern` only) | n/a |
| **D**IP | SKILLs depend on profile abstraction; bash adapters depend on tool-presence detection (graceful degrade) | n/a |

No violations identified. The one borderline case (`divecode-design` in standard+) is annotated as acceptable per agent-flow precedent.

## 6. Decision log

### Directives (always do this)

| ID | Decision | Source |
|---|---|---|
| D1 | AWS AI-DLC macro flow (Inception → Construction → Operations) is canonical | user clarification 2026-05-17 |
| D2 | Three profiles: `light`, `standard`, `strict` | spec round 1 Q1 |
| D3 | Auto-detect profile on first run via 5-6 signals (git, tests, CI, structure, docs); user confirms | spec round 1 Q2 |
| D4 | Bolt size asked once at `/divecode` entry (S/M/L) | spec round 2 Q1 |
| D5 | UX phase always asked "UI 있어?" — never auto-skipped | spec round 4 Q1 |
| D6 | Lore cascade — user-global + project-local both read | spec round 1 Q3 |
| D7 | Lore entry kinds — `Constraint`, `Rejected`, `Directive` (agent-flow compat) | spec round 4 Q2 |
| D8 | Decision log written BOTH to design.md §6 AND auto-mirrored to `.divecode/lore/decisions/` | spec round 3 Q2 |
| D9 | `light` keeps separate `requirements.md` / `design/` / `ARCHITECTURE.md`; `standard`+ unified `design.md` | spec round 2 Q3 |
| D10 | Slice-plan format — `light` simple (goal+files+tests), `standard`+ full (agent-flow exact) | spec round 3 Q3 |
| D11 | TDD strict gate via Bash refuse-write | spec round 3 Q4 |
| D12 | `pr-watch` — 6 statuses / 7 routes (agent-flow exact) | spec round 1 Q4 |
| D13 | Status observation — background threshold-triggered | spec round 4 Q4 |
| D14 | Audit = Inception sub-phase (auto when in-progress detected) | spec round 2 Q2 |
| D15 | v0 → v0.2 backward compat preserved for `light`; upgrade prompts migration | spec round 4 Q3 |
| D16 | divecode v0.2 is Claude Code SKILL-only (other agent runtimes → v0.3) | scope decision |

### Rejected (considered, not chosen — record so we don't relitigate)

| ID | Rejected approach | Why rejected | Date |
|---|---|---|---|
| R1 | Wholesale agent-flow adoption replacing v0 phases | Too rigid for prototypes; loses UX-first divecode-original value | 2026-05-17 |
| R2 | Audit as separate top-level skill (not in Inception) | Loses automatic pipeline connection on in-progress projects | 2026-05-17 |
| R3 | Auto-detect UI presence and skip UX phase silently | False negatives for projects with weird UI surfaces (TUI, CLI with rich output); explicit ask is more reliable | 2026-05-17 |
| R4 | Ask profile every run | Violates divecode iron law against repeating the same decision; loses persistence value | 2026-05-17 |
| R5 | TDD trust-based prompt-only enforcement | Verification gap; agents drift without external gate | 2026-05-17 |
| R6 | pr-watch single-status simplification (green vs not) | Loses recoverable states (ci_failed, has_comments) that automation can handle | 2026-05-17 |

### Constraints (we are bound by)

| ID | Constraint | Source |
|---|---|---|
| C1 | Must work entirely within Claude Code SKILL.md format (no external runtime) | distribution model |
| C2 | Must not break v0 users' existing projects | D15 |
| C3 | Must remain "1-line install via README" | divecode origin promise |
| C4 | Cannot require `ccusage` / `llm-usage-cli` — graceful degrade | adoption friction |
| C5 | Cannot block on absent `gh` / `git` — operations phases skip with warning | non-GitHub users |
| C6 | Lore schema compatible with awslabs/aidlc-workflows so artifacts can interop | strategic distribution |

(All entries are also mirrored to `.divecode/lore/decisions/v0.2-*.md` per D8.)

## 7. UX

UX phase decisions for **divecode itself** (the tool we're building):

- **"UI 있어?"** → Yes. divecode's UI surface is Claude Code's chat interface: `AskUserQuestion` panels + SKILL preamble output + artifact-path announcements. There is no graphical surface.
- **5-state coverage**:
  - **Ideal**: clean flow, profile detected, all questions answered concisely, artifacts produced
  - **Empty**: brand-new project, no signals → divecode falls back to asking profile explicitly
  - **Loading**: long phases (multi-screen UX mockup gen, multi-reviewer spawning) — SKILL preamble announces "this phase may take ~N min"
  - **Error**: bash gate failures, missing `gh`, missing `git` worktree perm — surfaced with specific remediation, not stack trace
  - **Edge**: multi-repo bolts (agent-cat-style work spanning multiple repos) → audit phase explicitly enumerates sibling repos; subsequent phases scope per repo
- **Interaction patterns**:
  - Decision questions → `AskUserQuestion` (≤4 options, recommendation marked)
  - Artifact preview → file path + brief content summary (let user open the file)
  - Pause points → explicit prompt; never silent
  - Threshold alerts (D13) → orange-flag console line, with "split now?" option

(Since divecode itself is a CLI/chat tool, no HTML mockups are produced for the divecode tool itself. The HTML-mockup machinery exists for **projects that USE divecode** with a UI surface.)
