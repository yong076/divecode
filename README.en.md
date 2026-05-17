# divecode

<p align="center">
  <img src="assets/banner.png" alt="Dive Coding — Guide the genie. Get the wish right." />
</p>

<p align="center">
  <a href="README.md">한국어</a> ·
  <strong>English</strong> ·
  <a href="README.ja.md">日本語</a> ·
  <a href="README.zh-Hans.md">简体中文</a>
</p>

> **divecoding** is the methodology. **divecode** is the tool that does it.

Remember Aladdin's first wish? "Make me a prince so I can marry the princess." The Genie granted it — literally. Aladdin got the title, the elephant, the parade. He didn't get the princess.

**Coding agents are genies.** They take your wish literally. If your wish is *"build me an admin dashboard with Redis cache and a cron job that runs every five minutes,"* they'll grant it — exactly as worded. The Genie won't ask whether you want jittered TTLs. Whether the cron should be idempotent when runs overlap. What the dashboard should look like when the cache is cold. That's not in your wish.

Three weeks later production lights up because none of those things were in your wish.

**divecoding is the Genie that asks back before granting.** Drop in a rough wish — a PRD, a command, a sketch. divecode looks at it, recognizes which *pattern packs* apply (redis-cache, admin-dashboard, vercel-serverless, postgres-saas, payments), and walks you through the questions you didn't think to specify. Cache stampede. Cron overlap. Auto-refresh DDoS. Replica lag. SCA dropoff. The wish you *actually meant*.

That's the wedge. The rest of divecode — the AWS AI-DLC macro flow, the agent-flow guardrails, the TDD gate, the PR watcher — exists to make sure the wish-as-clarified survives all the way to the code.

## The Genie principle

Before granting any wish, divecode asks:

1. **What you literally asked for** is X. Confirm.
2. **Things you didn't specify but the wish depends on**: A, B, C. (Drawn from packs that triggered.)
3. **The Genie will grant X strictly as worded** unless you specify those now. Want to?

This is divecoding's only universal rule. The phases (inception → construction → operations), the profiles (light / standard / strict), the packs, the gates — all of those exist to operationalize the Genie pause at the right granularity. A throwaway script gets a one-line pause. A payments integration gets a 20-question pause. Same principle either way.

The reason this works: **the Genie can grant anything** (modern agents will write nearly any code you ask for). The bottleneck is no longer capability — it's specificity. divecoding makes the specificity itself the work.

## Why use it

A few concrete things you get, with examples from the agent-cat development that prompted divecode in the first place:

**You catch the bugs before they ship, not after.**
The agent-cat admin dashboard, three weeks pre-incident: PRD mentioned "Redis cache" and "Vercel cron every five minutes." divecode would have asked: "what's your TTL? Is it jittered? What happens when the cron fires while the dashboard is also polling?" Three questions, ten minutes. The actual incident took a Sunday afternoon to recover from.

**The agent stops surprising you with structural choices.**
"Use the Repository pattern in the data layer" isn't a rule you remember at 11pm. It's a question the agent asks before it writes the next file. Same for "should this be eventually consistent or strongly consistent?" — the kind of decision that's 30 seconds to make and 3 days to undo.

**Your PRDs get sharper without you writing more.**
Drop in a three-paragraph spec. Get back a 12-question interrogation. Answer the questions. The answers become the rest of design.md — formatted, decision-logged, ready to slice into TDD chunks. That's a real spec out of a half-baked one.

**Documentation becomes a side effect, not a chore.**
Every divecode session produces design.md + risk-map.md + decision lore. Six months later when "why did we pick X?" comes up, the answer is in a file with the date and the trade-off. You didn't write it deliberately — it fell out of the workflow.

**Junior and senior pair better.**
The senior used to be the source of "did you think about replica lag?" Now divecode asks first. The senior reviews answers instead of dredging them up. The junior learns by seeing the questions, not by being lectured.

**Token cost drops because the agent generates code once.**
Vibe-coding cycles: write → realize it's wrong → rewrite → realize it's still wrong → rewrite. Each pass burns tokens. divecode front-loads the thinking so the first generation is usually the last.

**The agent gets "trained" on your team's actual decisions.**
Lore entries (`~/.divecode/lore/` + `.divecode/lore/`) carry forward across bolts and across sessions. The Constraint you set last month — "integration tests hit a real database, not mocks" — gets cited automatically in next month's design.md. Tribal knowledge becomes file knowledge.

## What divecoding is not

- **Not a planning framework.** No story points. No sprints. No estimation poker.
- **Not a code generator.** It deliberately doesn't start writing code. It starts writing *questions*.
- **Not a methodology in the heavy sense** — there's no certification, no ceremony, no Sprint Zero. It's "stop, surface the failure modes, then build."
- **Not a wrapper over RAG.** Pattern packs are active question generators, not passive retrieval. A pack triggered by "redis" in your PRD doesn't dump generic Redis docs — it asks you the specific things that bite Redis users in production.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/yong076/divecode/main/bootstrap.sh | bash
```

Clones into `~/.divecode/`, symlinks the skills into `~/.claude/skills/`. Next Claude Code session, type `/divecode` from any project directory.

First run looks at your repo, recommends a profile, and asks you to confirm. After that it just works.

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

## "Bolt" instead of "sprint"

A bolt is a single focused unit of work — hours to days, not weeks. The word comes from AWS's AI-DLC methodology and it's a useful one: when you start `/divecode`, it asks you for the bolt size (small / medium / large), and that answer changes how deep each phase goes. A small bolt collapses the interview to a single confirmation; a large bolt expands every phase.

## When to use it, and when not

**Use it for**: anything where a wrong decision will cost a week to undo. Data shape. Money. Auth. Multi-platform sync. Performance under real load. Anything with a database migration. Anything you'd write a postmortem about.

**Don't use it for**: throwaway scripts, one-off explorations, code you'll delete in two days. Just vibe-code those.

**Sweet spot**: a senior engineer pairing with the agent on a real feature. Or two engineers — one asks the dumb questions, the other answers from experience, the agent surfaces the third thing neither of them would have thought to ask.

## Pattern packs

The pack system is divecoding's question generator. A pack triggers when its keywords appear in your PRD, then fires the questions / failure modes / test ideas it carries. v0.3 ships nine deep packs:

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

  # Coming next:
  realtime-sync/      websocket, sse, pubsub
  telemetry-privacy/  telemetry, analytics, pii, opt-in
  macos-app/          menu bar, sparkle, notarization, dmg
  github-releases/    github actions, release, codesign
```

Each pack contains:
- `triggers` — keywords divecode-prd matches against PRD text
- `questions.md` — the actual interrogation prompts the pack fires
- `failure-modes.md` — the production incidents this pack exists to prevent
- `test-ideas.md` — test cases the answers should generate
- `example-patterns.md` — concrete examples (the "show, don't tell" reference)

PRs to `packs/` are the highest-leverage contribution. If you've been bitten by a class of bug that the agent should have asked you about — write a pack.

## Trying it

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

Try it on the included fixture (no `/divecode-prd` invocation needed — just the matcher):

```bash
bash ~/.divecode/bin/divecode-prd-triggers \
  --prd ~/.divecode/tests/fixtures/prd-admin-dashboard.md \
  --packs-dir ~/.divecode/packs
```

That PRD (the agent-cat admin incident as a three-paragraph spec) fires six packs and surfaces ~50 questions — the Redis stampede, the cron overlap, the auto-refresh DDoS, the IDOR / SSO risk, the partition-key trap if you were going to swap in DynamoDB. The ones that actually took the system down.

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
│                 Absorbed into packs/ in v0.3.
├── packs/        Pattern packs — the heart of PRD interrogation
├── templates/    profile.yml, design.md, slice-plan.md, lore-entry, review templates
├── tests/        bash test suites for the bin/ scripts
└── docs/         v0.2/ — divecode's own meta-spec
                  v0.3/ — PRD interrogation engine spec
```

## Contributing

The single most useful PR you can send is a new pack in `packs/`. If you've been bitten by a class of bug that the agent should have asked you about — write it up as a pack with triggers, questions, failure modes, and one or two example patterns. That's where the leverage is.

For new skills or pipeline phases, open an issue first so we can talk about where it fits.

## License

MIT. Use it, fork it, change the tone, change the language, ship it inside your company's tooling. If it saves you from one production incident it's paid for itself.
