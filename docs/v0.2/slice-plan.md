# divecode v0.2 — slice-plan.md

> Decomposition of design.md into TDD-ready slices. Each slice is ≤50% of a Claude Code context window and produces a reviewable artifact. **Chain pauses at end of this file for human review of both design.md + slice-plan.md before worktree phase.**

Bolt: `divecode-v0.2` · Profile: `standard` (self-applied) · Size: `L` (multi-day)

---

## Slice 1 — Profile foundation

**Goal**: `divecode` entry SKILL detects project signals, recommends profile, persists to `.divecode/profile.yml`.

**Layer scope**: domain (profile schema) + data (signal readers) + usecase (entry SKILL routing)

**Aggregates touched**: Profile

**Test cases (drive RED)**:
- `detect_recommends_light_on_fresh_solo_repo`
- `detect_recommends_standard_on_active_team_repo`
- `detect_recommends_strict_on_production_repo_with_ci_and_arch_md`
- `detect_persists_to_profile_yml_after_confirm`
- `existing_profile_yml_skips_detection`

**Files expected**:
- `skills/divecode/SKILL.md` (refactor entry)
- `bin/divecode-detect` (new)
- `templates/profile.yml.template` (new)
- `tests/fixtures/repo-fresh-solo/`, `repo-active-team/`, `repo-production/` (test fixtures)

**Verification command**: `bash tests/test-detect.sh`

---

## Slice 2 — Bolt-size mechanic + entry SKILL refactor

**Goal**: `/divecode` asks bolt size (S/M/L) once, persists to `~/.divecode/bolts/<id>/bolt.yml`, all downstream SKILLs read it.

**Layer scope**: domain (bolt lifecycle) + presentation (size question) + data (bolt directory)

**Aggregates**: Bolt

**Test cases**:
- `entry_creates_bolt_directory_with_id`
- `entry_records_profile_and_size_in_bolt_yml`
- `entry_resumes_existing_bolt_when_present`

**Files**:
- `skills/divecode/SKILL.md` (extend)
- `bin/divecode-bolt-new` (new)
- `bin/divecode-bolt-current` (new)

**Verification**: `bash tests/test-bolt.sh`

---

## Slice 3 — Lore cascade reader

**Goal**: Cascade-read `~/.divecode/lore/` + `<project>/.divecode/lore/`, relevance-rank against current phase context, inject into prompt envelope as "Relevant lore" block.

**Layer scope**: domain (lore entry schema) + data (cascade reader) + presentation (envelope inject format)

**Aggregates**: LoreEntry

**Test cases**:
- `cascade_reads_both_scopes`
- `project_local_overrides_user_global_on_same_name`
- `relevance_rank_filters_unrelated_entries`
- `cite_block_format_matches_agent_flow_convention`
- `missing_lore_dirs_degrade_gracefully`

**Files**:
- `bin/divecode-lore-cite` (new — bash, ranks + outputs envelope block)
- `templates/lore-entry.md.template` (new — Constraint/Rejected/Directive)
- All existing SKILL.md preambles updated to source `divecode-lore-cite`

**Verification**: `bash tests/test-lore.sh`

---

## Slice 4 — divecode-audit SKILL (Inception sub-phase)

**Goal**: For in-progress projects, audit source + .md + sibling repos + ecosystem OSS → produce `divecode/audit.md` (greenfield) or `divecode/audit-<feature>.md` (in-progress). Auto-invoked from entry SKILL when in-progress detected.

**Layer scope**: usecase (audit phase) + data (git history reader, sibling-repo discovery)

**Aggregates**: Bolt (annotated as `in-progress: true`)

**Test cases**:
- `audit_runs_when_branch_matches_feature_glob`
- `audit_runs_when_existing_source_detected_on_main`
- `audit_skipped_on_truly_empty_repo`
- `audit_discovers_sibling_repos_by_prefix`
- `audit_md_contains_silent_decisions_table_and_ecosystem_comparison`

**Files**:
- `skills/divecode-audit/SKILL.md` (new — formalize the agent-cat dogfood pattern)
- `bin/divecode-sibling-repos` (new — heuristic discovery)
- `templates/audit.md.template` (new)

**Verification**: `bash tests/test-audit.sh` + manual: re-run on agent-cat and verify same audit doc shape

---

## Slice 5 — Spec → unified design.md path

**Goal**: For `standard`/`strict` profiles, `divecode-spec` produces unified `divecode/design.md` with 7 sections (Interview / Spec / DDD / Clean / SOLID / Decision-log / UX). For `light`, preserves v0's `requirements.md` + `design/` + `ARCHITECTURE.md` separation. Migration prompt on upgrade from light.

**Layer scope**: usecase (spec phase, profile-dispatched)

**Aggregates**: Bolt

**Test cases**:
- `light_profile_produces_requirements_md_only`
- `standard_profile_produces_design_md_with_seven_sections`
- `strict_profile_enforces_lore_citation_in_design_md`
- `upgrade_from_light_prompts_before_merging_to_design_md`
- `existing_v0_requirements_md_preserved_when_light_stays_light`

**Files**:
- `skills/divecode-spec/SKILL.md` (refactor — profile-dispatch)
- `skills/divecode-design/SKILL.md` (refactor — UX-only for light; UX section for standard+)
- `skills/divecode-arch/SKILL.md` (light-only; standard+ folds into design.md)
- `templates/design.md.template` (new — 7-section)
- `bin/divecode-migrate` (new — light → standard converter)

**Verification**: `bash tests/test-spec-light.sh && bash tests/test-spec-standard.sh && bash tests/test-migrate.sh`

---

## Slice 6 — divecode-slice-plan SKILL

**Goal**: Decompose design.md into slices, profile-conditional fields. Light: goal + files + tests. Standard+: + layer + aggregates + verification. Pause at end of slice-plan output.

**Layer scope**: usecase (slice-plan phase)

**Aggregates**: Slice

**Test cases**:
- `light_slice_format_has_only_goal_files_tests`
- `standard_slice_format_includes_layer_and_aggregates`
- `strict_requires_test_case_names_drawn_from_acceptance_criteria`
- `slice_size_estimate_enforced_under_50pct_context`
- `pause_marker_written_at_end`

**Files**:
- `skills/divecode-slice-plan/SKILL.md` (new)
- `templates/slice-plan.md.template` (new — profile-conditional)

**Verification**: `bash tests/test-slice-plan.sh`

---

## Slice 7 — divecode-worktree SKILL

**Goal**: Create git worktree (if `profile.branching.worktree: required`) and branch per `profile.branching.naming`. Standard `agent-flow/<slug>` fallback when no profile naming.

**Layer scope**: usecase (worktree phase) + data (git adapter)

**Aggregates**: Bolt (annotated with branch and worktree-path)

**Test cases**:
- `branch_name_follows_profile_naming_prefix_and_slug_style`
- `worktree_created_when_profile_requires`
- `no_worktree_when_profile_optional_and_user_skips`
- `slug_strips_articles_and_lowercases`
- `aborts_on_branch_name_collision`

**Files**:
- `skills/divecode-worktree/SKILL.md` (new)
- `bin/divecode-branch-slug` (new — slug derivation)

**Verification**: `bash tests/test-worktree.sh`

---

## Slice 8 — divecode-implement TDD gate

**Goal**: For each slice in slice-plan, run RED → GREEN → REFACTOR. In `strict`, refuse to write production code unless a failing test exists in the slice's test files. In `standard`, warn but allow. Repository Pattern check: standard warn, strict must-fix.

**Layer scope**: usecase (implement phase) + data (TDD gate bash)

**Aggregates**: Slice

**Test cases**:
- `strict_blocks_production_write_when_no_failing_test`
- `strict_allows_production_write_when_red_assertion_failure_detected`
- `standard_warns_but_allows_no_red`
- `light_no_gate_at_all`
- `repository_pattern_violation_warns_in_standard_blocks_in_strict`

**Files**:
- `skills/divecode-implement/SKILL.md` (refactor — profile-dispatch)
- `bin/divecode-tdd-gate` (new — runs slice tests, asserts ≥1 failing assertion before allowing write)
- `bin/divecode-repo-pattern-check` (new — heuristic data-layer scan)

**Verification**: `bash tests/test-tdd-gate.sh && bash tests/test-repo-pattern.sh`

---

## Slice 9 — divecode-review + divecode-fix-loop

**Goal**: Multi-reviewer spawn via Claude Code Agent tool. architecture-design specialist mandatory. Plus `profile.review_angles`. Aggregate into `final-review.md` with severity. Then fix-loop max 3 rounds.

**Layer scope**: usecase (review + fix-loop phases) + adapter (Agent tool spawn)

**Aggregates**: Bolt

**Test cases**:
- `review_spawns_generalist_plus_architecture_design`
- `review_spawns_profile_angles_in_addition`
- `review_aggregates_with_severity_and_source_angle`
- `fix_loop_runs_max_3_rounds`
- `fix_loop_escalates_to_user_after_round_3_if_must_fix_remain`

**Files**:
- `skills/divecode-review/SKILL.md` (new)
- `skills/divecode-fix-loop/SKILL.md` (new)
- `templates/review/architecture-design.md` (new — mandatory reviewer template)
- `templates/final-review.md.template` (new)

**Verification**: `bash tests/test-review.sh && bash tests/test-fix-loop.sh`

---

## Slice 10 — divecode-commit + divecode-push-pr

**Goal**: Commit per `profile.commit_convention`. `gh` push and PR open. Body references design.md sections + slice list + verification results.

**Layer scope**: usecase (commit + push-pr) + adapter (git + gh)

**Aggregates**: Bolt

**Test cases**:
- `commit_groups_changes_per_convention`
- `commit_omits_coauthor_when_profile_excludes`
- `push_pr_targets_profile_pr_target_branch`
- `pr_body_includes_design_section_and_slice_list`
- `degrades_gracefully_when_gh_missing`

**Files**:
- `skills/divecode-commit/SKILL.md` (new)
- `skills/divecode-push-pr/SKILL.md` (new)
- `templates/pr-body.md.template` (new)

**Verification**: `bash tests/test-commit.sh && bash tests/test-push-pr.sh`

---

## Slice 11 — divecode-pr-watch SKILL

**Goal**: Full 6-status / 7-route agent-flow routing. `green`→merge, `has_comments`→fix-loop, `ci_failed`→fix-loop, `pending`→block, `closed`→block, `error`→block, `merged`→cleanup, `skipped`→merge.

**Layer scope**: usecase (pr-watch phase) + adapter (gh poll)

**Aggregates**: Bolt

**Test cases**:
- `pr_watch_returns_green_routes_to_merge`
- `pr_watch_returns_has_comments_routes_to_fix_loop`
- `pr_watch_returns_ci_failed_routes_to_fix_loop`
- `pr_watch_returns_closed_blocks_with_user_prompt`
- `pr_watch_returns_error_surfaces_and_does_not_retry`
- `pr_watch_handles_pending_with_polling_backoff`

**Files**:
- `skills/divecode-pr-watch/SKILL.md` (new)
- `bin/divecode-pr-watch` (new — `gh api`-based poller, JSON status output matching agent-flow contract)

**Verification**: `bash tests/test-pr-watch.sh` (against mock gh responses)

---

## Slice 12 — divecode-merge + divecode-cleanup

**Goal**: Merge per `profile.pr.merge_strategy` (squash/rebase/merge). Cleanup deletes worktree + branch, syncs integration branch, archives bolt marker, prompts user for new lore entry if bolt produced architectural decisions.

**Layer scope**: usecase (merge + cleanup phases) + adapter (git + gh)

**Aggregates**: Bolt (terminal state: merged + archived)

**Test cases**:
- `merge_uses_profile_merge_strategy`
- `cleanup_deletes_worktree_if_created`
- `cleanup_syncs_integration_branch`
- `cleanup_moves_active_marker_so_next_run_does_not_resume`
- `cleanup_prompts_for_lore_entry_when_decision_log_nonempty`

**Files**:
- `skills/divecode-merge/SKILL.md` (new)
- `skills/divecode-cleanup/SKILL.md` (new)

**Verification**: `bash tests/test-merge.sh && bash tests/test-cleanup.sh`

---

## Slice 13 — Documentation + v0 migration

**Goal**: Update README + MANIFESTO with v0.2 concepts (bolts, profiles, AWS AI-DLC roots, agent-flow guardrails). Polish `bin/divecode-migrate` for the actual light → standard upgrade flow (built in Slice 5).

**Layer scope**: presentation (docs) + usecase (migration UX)

**Aggregates**: n/a (documentation slice)

**Test cases**:
- `readme_mentions_bolt_profile_aidlc_terms`
- `manifesto_distinguishes_v02_changes_from_v0`
- `migrate_dry_run_shows_planned_changes_before_apply`

**Files**:
- `README.md` (update)
- `MANIFESTO.md` (update)
- `CHANGELOG.md` (new)
- `bin/divecode-migrate` (polish)

**Verification**: `markdownlint *.md` + manual review

---

## Order rationale

- Slices 1–3 = foundation (profile / bolt / lore). Nothing else compiles conceptually without these.
- Slice 4 (audit) early because it's the **largest divecode-original value-add** and proven on agent-cat already — it should land before further refactors.
- Slices 5–6 (spec/design unification + slice-plan) before construction phases — Construction phases consume their outputs.
- Slices 7–9 (worktree, implement, review/fix-loop) = Construction.
- Slices 10–12 (commit, push-pr, pr-watch, merge, cleanup) = Operations.
- Slice 13 (docs + migration polish) last — it must reflect the actually-built behavior, not the planned behavior.

## Pause

⏸  **Chain pauses here.** Reviewer must read both `docs/v0.2/design.md` and `docs/v0.2/slice-plan.md` before invoking `divecode-worktree` for Slice 1.

Reviewer should answer:
1. Does design.md capture all 16 spec decisions accurately?
2. Are the 13 slices the right cut, or should some be split / merged?
3. Is the order right, or are there dependencies I missed?
4. Any slice that should be a NO-GO before Slice 1 starts?
