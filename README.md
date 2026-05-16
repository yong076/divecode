# divecode

If you've been letting AI write most of your code, shipping it without really reading it, and it's mostly fine — you've been **vibe coding**. It works great until it doesn't. The day it doesn't is usually production day.

divecode is a small set of Claude Code skills that does the opposite. Instead of the agent typing fast, the agent **asks you the questions you should have asked**. What's the cache invalidation strategy? Read committed or serializable? What does this screen look like with zero items in it? With ten thousand? You answer, the agent records, then code follows.

Think of it as Clean Code for the agent era. Clean Code told you how to write good code. divecode is about deciding what good code even means for the thing you're about to build — *before* it gets built.

## Why bother

The bugs you ship when vibe-coding are almost always things you would have known to avoid if someone had asked. The agent never asks because it doesn't know what it doesn't know — and neither, really, do you, until you see the question.

divecode makes the asking systematic.

It's not a planning tool. It's not a methodology framework. It's a forcing function that drops Redis, SQL isolation, N+1, eventual consistency, HIG, OWASP — the things that bite you in production — into the conversation at the moment a decision is being made.

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
- **standard** — for real production work. Adds slice-plan, multi-reviewer, fix-loop, and the full commit → push-pr → pr-watch → merge → cleanup lifecycle. Spec, design, and arch collapse into one `design.md` with DDD / Clean Architecture / SOLID sections.
- **strict** — for mission-critical code. Same shape as standard but the gates actually block you. No production code without a failing test. No data-layer code that violates the Repository Pattern. Every architectural decision must be cited from `lore/`.

divecode picks one for you on first run by looking at six signals (commit history, test infra, CI config, existence of ARCHITECTURE/CONTRIBUTING, README size). You can always override.

## What a session looks like

```
INCEPTION
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
 └─ cleanup     deletes the worktree, syncs main, prompts you to write down any lasting decisions as lore
```

In light, most of construction and operations is skipped — you spec, design, build, ship. In strict, everything's there with gates that actually block. The depth adapts to your profile and to the size of the bolt you declared.

## "Bolt" instead of "sprint"

A bolt is a single focused unit of work — hours to days, not weeks. The word comes from AWS's AI-DLC methodology and it's a useful one: when you start `/divecode`, it asks you for the bolt size (small / medium / large), and that answer changes how deep each phase goes. A small bolt collapses the interview to a single confirmation; a large bolt expands every phase.

## When to use it, and when not

**Use it for**: anything where a wrong decision will cost a week to undo. Data shape. Money. Auth. Multi-platform sync. Performance under real load. Anything with a database migration. Anything you'd write a postmortem about.

**Don't use it for**: throwaway scripts, one-off explorations, code you'll delete in two days. The ceremony will outweigh the value. Just vibe-code those.

**Sweet spot**: a senior engineer pairing with the agent on a real feature. Or two engineers — one asks the dumb questions, the other answers from experience, the agent surfaces the third thing neither of them would have thought to ask.

## A note on tone

The skills speak a mix of Korean and English because that's how I work, and how my teammates work. You can fork and re-tone for your team. The checklists themselves are language-agnostic; only the agent's prompt phrasing has Korean in it.

## Where the ideas come from

- [AWS AI-DLC](https://aws.amazon.com/blogs/devops/ai-driven-development-life-cycle/) — three-phase macro flow (Inception / Construction / Operations) and the bolt unit
- agent-flow — phase-internal guardrails (DDD lens, Clean Architecture layer map, SOLID check, TDD red → green → refactor, 6-status pr-watch routing)
- Clean Code (Robert Martin) — for the "discipline is the feature" stance
- hop's agent pair programming — for the human-in-the-loop ralph idea

divecode's own additions are the UX phase, the niche-knowledge checklists in `checklists/`, the audit mode for in-progress projects, the usage-limit awareness, and the Korean-first tone.

## Layout

```
divecode/
├── bin/          small bash scripts the skills call (detect, bolt, lore, tdd-gate, pr-watch, ...)
├── skills/       SKILL.md files — what Claude Code reads
├── checklists/   niche knowledge (redis, sql, nosql, perf, security, ux-hig). PRs welcome here especially.
├── templates/    profile.yml, design.md, slice-plan.md, lore-entry, review templates
├── tests/        bash test suites for the bin/ scripts
└── docs/v0.2/    design.md + slice-plan.md from when v0.2 was specced (meta-dogfood)
```

## Contributing

The single most useful PR you can send is a new entry in `checklists/`. If you've been bitten by a class of bug that the agent should have asked you about — write it up as a checklist item with the trigger keywords, the questions to ask, and one or two concrete sub-points. That's where the leverage is.

For new skills or pipeline phases, open an issue first so we can talk about where it fits.

## License

MIT. Use it, fork it, change the tone, change the language, ship it inside your company's tooling. If it saves you from one production incident it's paid for itself.
