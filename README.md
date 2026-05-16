# divecode

> **divecoding** is the methodology. **divecode** is the tool that does it.

You wrote a three-paragraph PRD. "Build an admin dashboard. Redis cache. Neon DB. Vercel cron every five minutes." You hand it to the AI. The AI builds it. It works. It ships.

Three weeks later production lights up because the cron job and the dashboard refresh hit Redis at the same second and the cache stampede takes the origin DB down. You would have known to ask about jittered TTLs if someone had asked you.

**divecode is the someone.**

Drop in that same rough PRD and divecode looks at it, figures out which *pattern packs* apply — redis-cache, postgres-saas, admin-dashboard, vercel-serverless — pulls the questions those packs are designed to ask, and walks you through them before any code is generated. Cache stampede. Stale fallback. Cron warm-up. Connection pool ceiling. Query fan-out. PII in telemetry. Rate-limit budget. The eight or twelve things you would have wished someone asked.

That's the wedge. The rest of divecode — the AWS AI-DLC macro flow, the agent-flow guardrails, the TDD gate, the PR watcher — exists to make sure those answers actually shape the code that follows.

## What divecoding is not

- **Not a planning framework.** No story points. No sprints. No estimation poker.
- **Not a code generator.** It deliberately doesn't start writing code. It starts writing *questions*.
- **Not a methodology in the heavy sense** — there's no certification, no ceremony, no Sprint Zero. It's "stop, surface the failure modes, then build."
- **Not a wrapper over RAG.** Pattern packs are active question generators, not passive retrieval. A pack triggered by "redis" in your PRD doesn't dump generic Redis docs — it asks you the specific things that bite Redis users in production.

## Install

```bash
# v0.2 (recommended — full PRD interrogation + lifecycle pipeline)
# Until v0.2 merges to main, install from the branch:
curl -fsSL https://raw.githubusercontent.com/yong076/divecode/feature/v0.2/bootstrap.sh | bash

# v0 (current main — 6 skills, no PRD interrogation engine yet)
curl -fsSL https://raw.githubusercontent.com/yong076/divecode/main/bootstrap.sh | bash
```

After v0.2 merges, both URLs land you in the same place. Until then, the `main` URL gives the simpler v0 pipeline (still useful for solo work).

To remove: `bash ~/.divecode/uninstall.sh`.

## Profiles

divecode runs at three depths. The ceremony scales with how much you'd hate to ship a bug.

- **light** — for prototypes and solo work. Four phases: spec, design (HTML mockups), arch, implement. No worktree, no PR automation, no TDD gate. This was v0.
- **standard** — for real production work. Adds PRD interrogation, slice-plan, multi-reviewer, fix-loop, and the full commit → push-pr → pr-watch → merge → cleanup lifecycle.
- **strict** — for mission-critical code. Same shape as standard, but the gates actually block you. No production code without a failing test. No data-layer code that violates the Repository Pattern. Every architectural decision must be cited from `lore/`.

First run looks at your repo (commit history, test infra, CI config, ARCH/CONTRIBUTING docs, README size) and recommends one. You confirm or override.

## What a session looks like

```
INCEPTION
 ├─ prd         drop in a rough PRD → pattern-pack triggers fire → risk-map + open-questions emerge
 ├─ audit       only if the project is already in progress
 ├─ ux          what does this screen look like in 5 states?
 ├─ spec        7 phases of interrogation, niche-knowledge checklists pulled in
 └─ slice-plan  break it into TDD-ready chunks
                ⏸ pause for human review

CONSTRUCTION
 ├─ worktree    branch + worktree per your profile
 ├─ implement   write the failing test first, then the code
                (in strict, the agent literally refuses to write production code without a failing test)
 ├─ review      multiple reviewer agents spawned in parallel; architecture-design specialist is mandatory
 └─ fix-loop    address must-fix findings; max 3 rounds, then escalate

OPERATIONS
 ├─ commit      convention-aware, profile-driven
 ├─ push-pr
 ├─ pr-watch    6-status routing, auto-responds to CI failures and PR comments
 ├─ merge
 └─ cleanup     deletes the worktree, syncs main, prompts you to record any lasting decisions as lore
```

In light, most of construction and operations is skipped — you spec, design, build, ship. In strict, everything's there with gates that actually block. The depth adapts to your profile and to the size of the bolt you declared.

## Pattern packs

The pack system is divecoding's question generator. A pack triggers when its keywords appear in your PRD, then fires the questions / failure modes / test ideas it carries. Five hand-written deep packs ship with v0.3; four more are scaffolded from the v0 checklists and ready for human polish:

```
packs/
  redis-cache/        ✓ deep   — redis, upstash, ttl, cache stampede, eviction, lru
  postgres-saas/      ✓ deep   — postgres, neon, supabase, rds, prisma, pgbouncer
  admin-dashboard/    ✓ deep   — admin, dashboard, ops team, auto refresh, polling
  vercel-serverless/  ✓ deep   — vercel, edge function, cron, cold start, ISR
  payments/           ✓ deep   — stripe, paddle, billing, webhook, refund, SCA, 3DS

  nosql/              ⚠ stub   (migrated — triggers + failure-modes TODO)
  performance/        ⚠ stub   (migrated)
  security/           ⚠ stub   (migrated)
  ux-apple-hig/       ⚠ stub   (migrated)

  # Coming in v0.4:
  auth-rbac/          triggers: auth, oauth, jwt, rbac
  realtime-sync/      triggers: websocket, sse, pubsub
  telemetry-privacy/  triggers: telemetry, analytics, pii
  macos-app/          triggers: swiftui, menu bar, sparkle, notarization
  github-releases/    triggers: github actions, release, dmg, codesign
```

Each pack contains:
- `triggers` — keywords divecode-prd matches against PRD text
- `questions.md` — the actual interrogation prompts the pack fires
- `failure-modes.md` — the production incidents this pack exists to prevent
- `test-ideas.md` — test cases the answers should generate
- `example-patterns.md` — concrete examples (the "show, don't tell" reference)

PRs to `packs/` are the highest-leverage contribution. If you've been bitten by a class of bug that the agent should have asked you about — write a pack.

## Trying it (v0.3)

```bash
# in a project with a rough PRD
/divecode-prd path/to/PRD.md
```

The skill:
1. fires `bin/divecode-prd-triggers` against your PRD
2. confirms the matched packs with you (you can drop any false positives)
3. renders `divecode/risk-map.md` with the failure modes from each pack
4. walks you through the union of `questions.md` from those packs
5. populates `divecode/design.md` §1 + §2 + §6 with what you answered
6. hands off to `/divecode-spec` to fill the rest of design.md, or to `/divecode-slice-plan` if you want to jump to TDD

Try it on the included fixture:

```bash
divecode-prd-triggers --prd ~/.divecode/tests/fixtures/prd-admin-dashboard.md \
                     --packs-dir ~/.divecode/packs
```

That PRD fires all five deep packs — exactly the agent-cat admin incident this approach exists to prevent.

## When to use it, and when not

**Use it for**: anything where a wrong decision will cost a week to undo. Data shape. Money. Auth. Multi-platform sync. Performance under real load. Anything with a database migration. Anything you'd write a postmortem about.

**Don't use it for**: throwaway scripts, one-off explorations, code you'll delete in two days. Just vibe-code those.

**Sweet spot**: a senior engineer pairing with the agent on a real feature. Or two engineers — one asks the dumb questions, the other answers from experience, the agent surfaces the third thing neither of them would have thought to ask.

## Where divecoding sits

| Tool / methodology | Strength | What it doesn't try to do |
|---|---|---|
| AWS AI-DLC | Lifecycle macro flow (Inception → Construction → Operations) and the "bolt" unit | Domain-specific failure-mode surfacing |
| GitHub Spec Kit | Spec-driven development, structured spec format | Production risk interrogation per stack |
| Claude Skills | Distribution + execution format for agent capabilities | Methodology layer on top |
| **divecoding** | **PRD interrogation → human-in-loop decision extraction → niche failure-mode surface** | Owning the full SDLC, replacing your ticket system |

divecode steals freely: AWS for the macro shape, agent-flow for the phase-internal guardrails, Clean Code for the discipline-is-the-feature stance, Spec Kit for the artifact-first orientation. Its own contribution is the **PRD risk interrogation engine** and the **pattern pack** library that powers it.

## A note on tone

The skills speak a mix of Korean and English because that's how I work and how my teammates work. You can fork and re-tone for your team. The packs themselves are language-agnostic; only the agent's prompt phrasing has Korean in it.

## Layout

```
divecode/
├── bin/          small bash scripts the skills call (detect, bolt, lore, tdd-gate, pr-watch, ...)
├── skills/       SKILL.md files — what Claude Code reads
├── checklists/   v0 niche knowledge (redis, sql, nosql, perf, security, ux-hig).
│                 Becoming packs/ in v0.3.
├── packs/        (v0.3) pattern packs that drive PRD interrogation
├── templates/    profile.yml, design.md, slice-plan.md, lore-entry, review templates
├── tests/        bash test suites for the bin/ scripts
└── docs/         v0.2/ — divecode's own meta-spec
                  v0.3/ — PRD interrogation engine spec
```

## Contributing

The single most useful PR you can send is a new pack in `packs/` (or, until v0.3 lands, a new entry in `checklists/`). If you've been bitten by a class of bug that the agent should have asked you about — write it up as a pack with triggers, questions, failure modes, and one or two example patterns. That's where the leverage is.

For new skills or pipeline phases, open an issue first so we can talk about where it fits.

## License

MIT. Use it, fork it, change the tone, change the language, ship it inside your company's tooling. If it saves you from one production incident it's paid for itself.
