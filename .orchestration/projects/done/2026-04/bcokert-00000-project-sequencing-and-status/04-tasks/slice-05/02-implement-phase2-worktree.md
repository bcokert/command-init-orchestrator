---
spec: specs/briefs/project-sequencing-and-status/05-implement-v1-single-project.md
slice: 05
step: 2
title: Phase 2 — worktree creation and first-time education
status: done
depends_on: [01-implement-phase0-routing-and-selection.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Add Phase 2 to `defaults/commands/implement.md`:

1. Create `.orchestration/worktrees/` if it doesn't exist.
2. Run `git worktree list` to detect first-time use: if output has only one line (the main worktree), this is first-time.
3. Run `git worktree add .orchestration/worktrees/{id} -b project/{id}`.
4. On failure (non-zero exit): output a clear error describing what failed. Do NOT update `status.md`. Project stays at `tasks_ready`. Stop.
5. On success:
   - Update `status.md` — append transition and add fields:
     ```yaml
     stage: tasks_ready  # unchanged until Phase 4 starts
     worktree_path: .orchestration/worktrees/{id}
     branch: project/{id}
     transitions:
       - stage: worktree_created
         timestamp: {ISO 8601}
         note: worktree created at .orchestration/worktrees/{id}
     ```
   - If first-time: show full education explaining what worktrees are, why they're used (isolation, parallel-ready, main branch stays clean), and what happens next.
   - Otherwise: "worktree created — working on branch project/{id}"

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/05-implement-v1-single-project.md` — worktree failure constraint and first-time detection

## Done signal

Worktree exists at `.orchestration/worktrees/{id}`. `status.md` has `worktree_path` and `branch`. Simulated failure (bad branch name) leaves project at `tasks_ready` with no `status.md` change. Single-line `git worktree list` triggers full education.
