---
spec: specs/briefs/project-sequencing-and-status/07-review-command.md
slice: 07
step: 2
title: Write approve path (Phase 1)
status: done
depends_on: [01-phase0-routing.md]
agent_type: architect
assigned_at: 2026-04-12T00:00:00Z
completed_at: 2026-04-12T00:00:00Z
---

## Work

Write Phase 1 of `defaults/commands/review.md` — the approve path.

Steps in order:
1. Present summary: QA result, slice title, number of uncommitted files changed. Ask for approval.
2. On approval:
   a. Commit: `git add` all files in the worktree, `git commit -m "Slice {NN} complete — {project_id}"`
   b. Push: `git push`. If push fails, report clearly and continue (don't block archive).
   c. Merge: `git merge project/{id}` from main. If merge fails (conflict): leave project at `signoff_review`, preserve worktree, output instructions to resolve manually and re-run `/review`. Stop.
   d. Remove worktree: check for uncommitted changes first (`git status` in worktree). If clean: `git worktree remove .orchestration/worktrees/{id}`. If dirty: warn and stop.
   e. Archive: move `.orchestration/projects/{id}/` to `.orchestration/projects/done/YYYY-MM/{id}/`. If target exists: error with instructions, no overwrite.
   f. Update `status.md` (now in archive path): `stage: done`, append transition with timestamp.

## Done signal

Approve path executes in the correct order. Merge conflict leaves project at `signoff_review` with worktree intact. Dirty worktree before removal produces a warning and stops. Archive collision fails with instructions.
