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

> divecoding is the methodology. divecode is the tool that does it.

Aladdin's first wish was to marry the princess, so he asked the Genie to make him a prince. The Genie granted it, literally. Aladdin got the title, the elephant, the parade. He did not get the princess.

Coding agents are that Genie. Your wish gets granted exactly as worded. "Build me an admin dashboard with Redis cache and a Vercel cron every five minutes" produces precisely that. The agent does not ask whether TTLs should be jittered, what happens when two cron runs overlap, or what the dashboard looks like before the cache is warm. None of that was in the wish, so none of that gets considered.

Three weeks later production lights up. Everything that was not in the wish breaks.

divecoding sits in that gap. Hand in a rough wish — a PRD, a one-line command, a sketch — and divecode reads it to figure out which *pattern packs* apply: redis-cache, admin-dashboard, vercel-serverless, postgres-saas, payments…. Each matched pack fires the questions you forgot to specify. Cache stampede. Cron overlap. Auto-refresh load. Replica lag. SCA dropoff. The wish you actually meant.

The rest of divecode (AWS AI-DLC macro flow, agent-flow guardrails, TDD gate, PR watcher) exists to drag that clarified wish all the way through to the code without losing it.

## The Genie principle

Before granting any wish, divecode raises three things:

1. The literal wish is X. Confirm.
2. Things you didn't specify that X depends on: A, B, C. (Drawn from the packs that triggered.)
3. If you don't pin A, B, C now, X gets granted strictly as worded. Specify them, or accept the outcome.

That is divecoding's only universal rule. The phases (inception → construction → operations), the profiles (light / standard / strict), the packs, the gates — every one of them is just this Genie pause delivered at a different granularity. A throwaway script gets a one-line pause. A payments integration gets a twenty-question pause. Same principle, different weight.

The reason this works is simple. The Genie can grant nearly anything; modern agents will write almost any code you describe. So capability is no longer the bottleneck. *Specificity* is. divecoding makes specificity itself the work.

## What developers used to do

Vibe coding taught us three things. Code can flow out fast. Most code is roughly the same regardless of who wrote it. Agents can do the typing.

What it did not teach us: why the code was written that way, which trade-offs were chosen, who has to read this code a month from now.

Developers used to be the people who handled that second list. Before typing a single line — read the requirement carefully, sketch the edge cases, draw the data model, pick the algorithm, anticipate the failure modes, decide the trade-offs, *then* hit the keyboard.

Vibe coding compressed those seven steps into one: "describe what you want, accept what comes." Time dropped. So did six of the seven steps. Every dropped step lays down one incident due a month out.

Dive coding puts those six steps back. The agent still does the typing. The *thinking* steps that used to come before the typing get handed back to the human, and the agent extracts that thinking through *questions* instead of guesses.

| | Vibe coding | Dive coding |
|---|---|---|
| Input | One-line wish | Specification (progressively sharpened) |
| Pace | Agent decides | Human decides |
| Output | Code, then rework | Decisions, then code that holds |
| Discovery point | In production (weeks later) | Before the keyboard (minutes later) |
| Developer's role | Typing supervisor | The one who specifies |
| Skill exercised | Accepting | Judgment · taste · knowledge |
| Documentation | "should write some" | Falls out of the workflow |
| Good for | Exploration, throwaways, demos | Anything you'd write a postmortem about |
| Analogy | Dictation | Conversation |

Dive coding does not give the agent better answers. It puts the human in a position to ask better questions.

## Why use it

Concrete things, drawn from the agent-cat work that produced divecode in the first place.

Bugs get caught before they ship. The agent-cat admin dashboard, three weeks before its incident, had a PRD that mentioned "Redis cache" and "Vercel cron every five minutes." divecode would have asked three things: what TTL, jittered or not, and what happens when the cron fires while the dashboard is also polling. Ten minutes of conversation. The actual incident took a Sunday afternoon to recover from.

The agent stops surprising you with structural choices. "Use the Repository pattern in the data layer" is not a rule you remember at 11pm. It becomes a question the agent asks before writing the next file. Same for "should this be eventually consistent or strongly consistent" — a thirty-second decision that costs three days to undo.

PRDs sharpen on their own. Drop in a three-paragraph spec and a twelve-question interrogation comes back. Answer the questions, and the answers become the body of design.md — formatted, decision-logged, ready to slice into TDD chunks. A half-baked PRD becomes a real spec without you writing more.

Documentation stops being a chore and starts being a side effect. Every divecode session leaves design.md + risk-map.md + decision lore behind. Six months later when someone asks "why did we pick X?", the answer sits in a file with the date and the trade-off. Nobody had to write it deliberately. The workflow dropped it on the floor.

Senior–junior pairing gets easier. "Did you think about replica lag?" used to come from the senior. Now divecode asks first, and the senior just reviews the answer. The senior does not have to dredge the same question up twice. The junior learns by watching the questions, not by being lectured.

Token costs come down. Vibe-coding cycles run write → wrong → rewrite → still wrong → rewrite. Every pass burns tokens. divecode front-loads the thinking, so the first generation is usually the last one.

Finally, the agent ends up "trained" on your team's actual decisions. Lore entries (`~/.divecode/lore/` + `.divecode/lore/`) persist across bolts and sessions. The Constraint you wrote last month ("integration tests hit a real database, not mocks") gets cited automatically in next month's design.md. Tribal knowledge turns into file knowledge.

## What divecoding is not

- Not a planning framework. No story points, no sprints, no estimation poker.
- Not a code generator. It deliberately does not write code. It writes questions.
- Not a heavy methodology. No certification, no ceremony, no Sprint Zero. "Stop, surface the failure modes, then build" is the whole shape.
- Not a wrapper over RAG. Pattern packs are active question generators, not passive retrieval. A pack triggered by "redis" in your PRD does not dump generic Redis documentation at you. It asks the specific things that bite Redis users in production.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/yong076/divecode/main/bootstrap.sh | bash
```

Clones into `~/.divecode/`, symlinks the skills into `~/.claude/skills/`. Next Claude Code session, type `/divecode` from any project directory.

First run looks at your repo and recommends a profile. After you confirm it once, the tool gets out of the way.

To remove: `bash ~/.divecode/uninstall.sh`.

## Profiles

divecode runs at three depths. Ceremony scales with how much a bug would actually hurt.

- light — for prototypes and solo work. Four phases (spec / design / arch / implement). No worktree, no PR automation, no TDD gate. This is v0.
- standard — for real production work. Adds PRD interrogation, slice-plan, multi-reviewer, fix-loop, and the full commit → push-pr → pr-watch → merge → cleanup lifecycle.
- strict — for mission-critical code. Same shape as standard, but the gates actually block. No production code without a failing test. No data-layer code that violates the Repository pattern. Every architectural decision must be cited from `lore/`.

First run looks at your repo (commit history, test infra, CI config, ARCH/CONTRIBUTING docs, README size) and recommends one. Confirm or override.

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

In light, most of construction and operations is skipped — you spec, design, build, ship. In strict, all of it runs and the gates actually block. Depth adapts to your profile and to the bolt size you declared.

## "Bolt" instead of "sprint"

A bolt is a single focused unit of work — hours to days, not weeks. The word comes from AWS's AI-DLC methodology and it earns its keep: when you start `/divecode`, it asks for the bolt size (small / medium / large), and that answer changes how deep each phase goes. A small bolt collapses the interview to a single confirmation. A large bolt expands every phase.

## When to use it, and when not

Use it for: anything where a wrong decision will cost a week to undo. Data shape. Money. Auth. Multi-platform sync. Performance under real load. Anything with a database migration. Anything you would write a postmortem about.

Do not use it for: throwaway scripts, one-off explorations, code you will delete in two days. Just vibe-code those.

Sweet spot is a senior engineer pairing with the agent on a real feature. Or two engineers — one asks the dumb questions, the other answers from experience, the agent surfaces the third thing neither of them would have thought to ask.

## Pattern packs

The pack system is divecoding's question generator. A pack triggers when its keywords show up in your PRD, then fires the questions / failure modes / test ideas it carries. v0.3 ships nine deep packs:

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
- `questions.md` — the interrogation prompts the pack fires
- `failure-modes.md` — production incidents this pack exists to prevent
- `test-ideas.md` — test cases the answers should generate
- `example-patterns.md` — concrete examples (the "show, don't tell" reference)

PRs to `packs/` are the highest-leverage contribution. If you have been bitten by a class of bug the agent should have asked about, that bug is one pack's worth of material.

## Trying it

```bash
# in a project with a rough PRD
/divecode-prd path/to/PRD.md
```

The skill does this:
1. Runs `bin/divecode-prd-triggers` against your PRD
2. Confirms the matched packs with you (drop any false positives)
3. Renders `divecode/risk-map.md` with the failure modes from each pack
4. Walks you through the union of `questions.md` from those packs
5. Populates `divecode/design.md` §1 + §2 + §6 with your answers
6. Hands off to `/divecode-spec` for the rest of design.md, or to `/divecode-slice-plan` if you want to jump to TDD

You can also run the matcher directly on the included fixture, without the skill:

```bash
bash ~/.divecode/bin/divecode-prd-triggers \
  --prd ~/.divecode/tests/fixtures/prd-admin-dashboard.md \
  --packs-dir ~/.divecode/packs
```

That PRD (the agent-cat admin incident written as a three-paragraph spec) fires six packs and surfaces about fifty questions. Redis stampede, cron overlap, auto-refresh DDoS, the IDOR / SSO risk, the partition-key trap you would have hit if you had moved to DynamoDB. All of these took the actual system down.

## Where divecoding sits

| Tool / methodology | Strength | What it doesn't try to do |
|---|---|---|
| AWS AI-DLC | Lifecycle macro flow (Inception → Construction → Operations) and the "bolt" unit | Domain-specific failure-mode surfacing |
| GitHub Spec Kit | Spec-driven development, structured spec format | Production risk interrogation per stack |
| Claude Skills | Distribution + execution format for agent capabilities | A methodology layer on top |
| **divecoding** | **PRD interrogation → human-in-loop decision extraction → niche failure-mode surface** | Owning the full SDLC, replacing your ticket system |

divecode steals freely: AWS for the macro shape, agent-flow for the phase-internal guardrails, Clean Code for the discipline-is-the-feature stance, Spec Kit for the artifact-first orientation. Its own contribution is the PRD risk interrogation engine and the pattern pack library that drives it.

## A note on tone

The skills speak a mix of Korean and English because that is how I work and how my teammates work. Fork it and re-tone it for your team. The packs themselves are language-agnostic; only the agent's prompt phrasing has Korean in it.

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

The single most useful PR is a new pack in `packs/`. If you have been bitten by a class of bug the agent should have asked you about, write it up as a pack: triggers, questions, failure modes, a couple of example patterns. That is where the leverage is.

For new skills or pipeline phases, open an issue first so we can talk about where it fits.

## License

MIT. Use it, fork it, change the tone, change the language, ship it inside your company's tooling. If it prevents one production incident it has paid for itself.
