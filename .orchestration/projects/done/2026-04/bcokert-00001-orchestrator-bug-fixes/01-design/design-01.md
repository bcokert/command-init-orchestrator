---
type: design
date: 2026-04-23
feature: orchestrator-bug-fixes
project_id: bcokert-00001-orchestrator-bug-fixes
status: approved
---

# Orchestrator bug fixes — Design

## Intent

The orchestrator's `defaults/` files have drifted out of sync with the current system. Agent files reference paths from the old pre-`projects/` layout. Three obsolete commands remain in `defaults/commands/` but aren't installed and reference paths that don't exist. Several command files have behavioral bugs: a commit that fires before user confirmation, a crash-resume gap that silently drops a commit, a `git add -A` that can stage unrelated files, an `implement` that claims to run one slice but was intended to run all ready slices, and a feedback path that leaves users stuck with no guidance. This project fixes all of them, removes the dead files, and adds a CLAUDE.md rule to prevent future drift.

## Current state

- All 6 agent files reference paths from the old layout: `.orchestration/root-context/LINK.md`, `.orchestration/specs/briefs/`, `.orchestration/specs/tasks/{spec-id}/`, `.orchestration/dashboard/`, `.orchestration/config.yaml`.
- `lead.md` is the worst offender — its entire model (dashboard, config.yaml, kickoff prompts) describes a system that doesn't exist. The orchestrator now drives task execution directly via `implement.md`; lead.md is vestigial.
- `standards.md` references `.orchestration/root-context/lessons/` which doesn't exist.
- `learn.md`, `commit.md`, `migrate.md` remain in `defaults/commands/` but are not installed by `init-orchestrator.md`. They reference old paths and represent deferred/removed features.
- `plan-project.md` Phase 7: creates task files → commits → then asks for agent team confirmation. If the user changes agent types, the commit already captured wrong values.
- `plan-project.md` Phase 5 entry: when crash-resuming after the design review gate, the Phase 0 router goes directly to Phase 5 (design exists, no slices). Phase 5 doesn't contain the `approveAndCommit` logic — only Phase 4 does. The design doc stays at `review` forever and the approval commit is silently skipped.
- `implement.md`: Phase 0 selects one slice. Phase 1 shows all tasks_ready work before confirming start, implying all slices will run — but only one does. Behavior and display are misaligned. Intended behavior: run all tasks_ready slices in sequence, stop only after all are at signoff_review.
- `review.md`: approval commit uses `git add -A` from project root, which stages all untracked files — including `.env`, temp files, binaries, or unrelated in-progress work.
- `review.md` feedback path: after capturing feedback, the original slice stays at `signoff_review` and new draft slices are created. On the next `/plan-project` run, Phase 0 blocks on the signoff_review slice. The user has no guidance on what to do next.
- No CLAUDE.md rule requiring agent files to be updated alongside command changes.

## Desired end state

- All 6 agent files (in `defaults/agents/` and `.claude/agents/`) reference correct current paths.
- `lead.md` removed from `defaults/agents/` and `.claude/agents/`.
- `init-orchestrator.md` updated: lead.md removed from install list.
- `learn.md`, `commit.md`, `migrate.md` removed from `defaults/commands/`.
- `standards.md` no longer references `lessons/`.
- `TODO.md` created at the project root with deferred features documented.
- `plan-project.md` Phase 7: commit happens after agent team confirmation, not before.
- `plan-project.md` Phase 5: on entry, if design doc is at `status: review`, run `approveAndCommit` before proceeding to slicing.
- `implement.md`: collects all tasks_ready slices at Phase 0, executes them in sequence (one slice at a time, respecting ordering), QAs each after its tasks complete, stops only when all are at signoff_review. Phase 1 display aligns with this behavior.
- `review.md`: before staging, runs `git status`, auto-stages known orchestration and implementation paths (`.orchestration/projects/{id}/` + source and test files), surfaces any other changed files with a prompt before including them.
- `review.md` feedback path: output explicitly states the original slice is still at signoff_review, explains the required next steps (resolve the slice via `/review` before `/plan-project` will pick up the feedback slices), and shows the new slice paths.
- CLAUDE.md has a rule: any change to `defaults/` agent or command files requires a cohesion pass over all related artifacts.
- All modified files in `defaults/` have bumped version numbers. `.claude/` local copies are in sync.

## Patterns to follow

- Fix the smallest thing that resolves each bug. No refactoring beyond what the fix requires.
- When removing a file from `defaults/`, also remove it from the local `.claude/` copy if present.
- When modifying `defaults/`, bump the `version:` field in that file's frontmatter (patch for fixes, minor for behavior changes).
- Sync `defaults/` changes to `.claude/` immediately for local dogfooding.
- CLAUDE.md and the project's `init-orchestrator.md` describe the same sync rule — keep them consistent.

## Key edge cases

- `init-orchestrator.md` currently lists all 6 agents including `lead.md` — removing lead.md from the install list without updating `init-orchestrator.md` would leave the install description wrong.
- Old installs already have `lead.md` in `.claude/agents/`. The fix only covers the defaults — existing installs keep the old file until the user re-runs `/init-orchestrator`. The init's old-file detection currently only covers commands, not agents. Note this gap; don't attempt to auto-delete from existing installs.
- `implement.md` behavior change: crash resume of a partially-completed multi-slice run must still work. Phase 0 reads all slice states from disk — a slice at `implementing` is resumed, one at `signoff_review` is skipped (already done for this run).
- `review.md` smart staging: for planning-only slices (no implementation files), all changes will be under `.orchestration/` and auto-staging is safe. For implementation slices, source files will be staged automatically. Anything outside `.orchestration/` and the project's source tree needs a prompt.
- Moving the `plan-project` Phase 7 commit: the agent team confirmation step currently waits for a response — the commit happens after that response, so the task files at the time of commit will already reflect any agent_type adjustments the user made.

## Resolved design decisions

- **Remove lead.md entirely rather than update it.** The current system drives execution through `implement.md` without a lead agent. Rewriting lead.md to match the current system would be speculative — it would need to describe a workflow that doesn't actually exist yet. Removing it is cleaner. Deferred features go in TODO.md. Rejected: update lead.md to describe the current implement.md flow (too speculative, no actual use case yet).
- **Remove commit.md, learn.md, migrate.md from defaults, not just leave them unused.** Dead files in defaults are noise and mislead anyone reading the codebase. They're documented in TODO.md where relevant. Rejected: leave them with a `status: deferred` comment (harder to find, still gets copied by init-orchestrator if someone edits the install list by mistake).
- **implement.md runs ALL tasks_ready slices.** The user controls scope by deciding how many slices to break down before running `/implement`. If they want one-at-a-time review, they break down one slice. If they break down three, all three run. This aligns Phase 1's "show everything" display with actual behavior. Rejected: keep one-slice-per-run (misaligned with what Phase 1 implies; forces unnecessary /implement calls).
- **review.md smart staging: auto-stage known paths, prompt for everything else.** Known paths: `.orchestration/projects/{id}/`, and any source/test files that changed (detected via `git status`). Prompt for anything outside those. Always show a summary of what will be staged before committing. Rejected: always require explicit confirmation for every file (too slow for normal use); continue using `git add -A` (footgun remains).
- **Plan-project Phase 5 crash resume: check design doc status on entry.** If status is `review`, run approveAndCommit before proceeding. This is the minimal fix — it doesn't reorganize Phase 4/5, just adds a guard at Phase 5 entry. Rejected: move approveAndCommit into Phase 0 routing (larger refactor, higher risk of introducing new bugs).

## Agent decisions

- **migrate.md removed from defaults** alongside learn.md and commit.md. Context: it's v1.0.0, not installed, and represents a feature that hasn't been validated. Alternative: retain it in defaults but mark as experimental. Removing it is cleaner — it can be reinstated when it's ready.
- **TODO.md created at project root, not inside `.orchestration/`.** It's for Bdon as the repo owner, not for the orchestration system's runtime. Placing it at root makes it visible as a project file. Alternative: `.orchestration/TODO.md`.
- **CLAUDE.md sync rule added as a new section in the project's CLAUDE.md.** It's a development rule for this repo (the orchestrator itself), not a rule that should ship to users. Alternative: add it to `init-orchestrator.md` behavior rules (wrong audience — that's a user-facing file).
