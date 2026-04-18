---
type: brief
slice: 01
project: bcokert-00003-remove-worktree-replace-task-queuing
date: 2026-04-18
---

# Delegation brief — slice 01: implement and review run on main

**Type:** Task (AI agent)
**Date:** 2026-04-18

---

### 1. Intent

The orchestrator currently creates a git worktree per project when `/implement` starts — an isolated branch (`project/{id}`) at `.orchestration/worktrees/{id}`. All task execution happens inside that worktree. At signoff, `/review` merges the worktree branch to main and removes the directory.

This slice removes the worktree from the execution path entirely. No worktrees are created, no branches are switched, no merge step happens. `/implement` and `/review` operate directly on main. All uncommitted changes accumulate there until `/review` commits them.

This is the first and most load-bearing slice in the worktree removal project. After this slice, the system works end-to-end without any worktree infrastructure.

---

### 2. Observable outcomes

**Happy path — implement:**
```
Given a project at stage tasks_ready
When /implement runs
Then no git worktree is created, no branch is switched,
  no .orchestration/worktrees/ directory appears,
  status.md has no worktree_path or branch fields,
  and task execution proceeds on main
```

**Happy path — review:**
```
Given a project at stage signoff_review with uncommitted changes on main
When /review approves
Then git log shows one commit from main with message "Slice {NN} complete — {id}",
  no merge commit exists,
  and the project is archived
```

**Edge — old status.md with worktree_path:**
```
Given a status.md that has worktree_path set from an old run
When /implement runs
Then implement ignores worktree_path silently and proceeds normally
```

**Edge — resume with implementing stage:**
```
Given a project at stage implementing (mid-execution crash-resume)
When /implement runs
Then it finds the first in_progress or todo task by reading task file statuses,
  not by checking a worktree directory
```

**Edge — old worktree_created transition in history:**
```
Given a status.md with a worktree_created transition note in its history
When /status or /implement reads it
Then no error — transition history is displayed only, not used for routing
```

---

### 3. Constraints

**Must:**
- Remove Phase 1 (worktree creation) from `implement.md` entirely. No partial removal, no conditional skip.
- Remove `worktree_path` and `branch` fields from every `status.md` write in `implement.md`.
- Fix all slice file path references in `implement.md` — they currently use `{worktree_path}/.orchestration/projects/{id}/02-slices/`. Change to `.orchestration/projects/{id}/02-slices/`.
- Remove the merge step and worktree-remove step from `review.md`. Commit directly from main using `git add -A && git commit`.
- Change `git push origin project/{id}` in `review.md` to `git push`.
- Fix the slice file path in `review.md` approve path — same change as implement.md.
- Renumber phases in `implement.md` after removing Phase 1: Phase 2 → Phase 1, Phase 3 → Phase 2, Phase 4 → Phase 3.
- Update routing error messages in both files that referenced `worktree_path` (e.g. "implementing in worktree {worktree_path}").
- Update `review.md` status.md note — remove "worktree removed" from it.
- Update frontmatter `description:` in both files to remove worktree references.
- Bump version: `implement.md` 2.1.0 → 2.2.0 (behaviour change), `review.md` 1.1.0 → 1.2.0.
- Sync `.claude/commands/implement.md` and `.claude/commands/review.md` from defaults after editing.

**Must not:**
- Add any conditional "use worktree if configured" logic. Worktrees are gone, not toggled.
- Add a `git stash` or branch-switching step as a replacement for worktrees.
- Commit anything during this task — all changes stay uncommitted for QA and signoff.
- Edit `.claude/commands/` directly; always edit `defaults/commands/` first and then copy.

**Preferences:**
- Keep phase structure and naming consistent — the plan-project pipeline references Phase numbers from implement.md in error messages.
- `git add -A` from the project root in review is fine — it captures everything uncommitted, which is the intended behavior.

**Escalation triggers:**
- If `review.md`'s archive or status-update steps reference worktree paths beyond what's documented in the slice — stop and flag. Don't guess at hidden dependencies.
- If any other command file (status.md, plan-project.md) references worktree_path in a way that would break after this change — stop and flag rather than silently fixing out of scope.

---

### 4. Done definition

- `defaults/commands/implement.md` has no mention of `git worktree`, `worktree_path`, `branch: project/`, or `.orchestration/worktrees/`.
- `defaults/commands/implement.md` has three phases: agent team (Phase 1), task execution (Phase 2), QA and signoff (Phase 3).
- `defaults/commands/review.md` has no mention of `git worktree`, `worktree_path`, `git merge`, or `.orchestration/worktrees/`.
- `defaults/commands/review.md` approve path contains `git add -A` and `git commit` but no merge or worktree-remove command.
- `defaults/commands/review.md` push step is `git push` with no branch argument.
- Both `.claude/commands/` files are byte-for-byte identical to their `defaults/commands/` counterparts.
- `implement.md` version is 2.2.0, `review.md` version is 1.2.0.

**Test vectors:**
```
grep -r "git worktree" defaults/commands/implement.md defaults/commands/review.md
→ no output

grep -r "worktree_path" defaults/commands/implement.md defaults/commands/review.md
→ no output

grep "git merge" defaults/commands/review.md
→ no output

grep "Phase 1" defaults/commands/implement.md
→ should match "## Phase 1 — Agent team"

diff defaults/commands/implement.md .claude/commands/implement.md
→ no output

diff defaults/commands/review.md .claude/commands/review.md
→ no output
```

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Rewrite `defaults/commands/implement.md` | Phase 1 removed, phases renumbered, worktree_path removed from status.md writes and slice file paths, routing error messages updated, description updated, version bumped to 2.2.0 | `grep "git worktree" defaults/commands/implement.md` → no output; Phase 1 heading is "Agent team" |
| 2 | Rewrite `defaults/commands/review.md` | Merge step removed, worktree-remove step removed, commit changed to `git add -A` from main, push changed to `git push`, slice file path fixed, routing message updated, status.md note updated, behavior rules updated, description updated, version bumped to 1.2.0 | `grep "git worktree\|git merge" defaults/commands/review.md` → no output |
| 3 | Sync `.claude/commands/` | `.claude/commands/implement.md` and `.claude/commands/review.md` copied from defaults | `diff defaults/commands/implement.md .claude/commands/implement.md` → no output; same for review.md |
