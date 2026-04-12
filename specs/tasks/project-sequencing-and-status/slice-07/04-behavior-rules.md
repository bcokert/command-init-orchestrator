---
spec: specs/briefs/project-sequencing-and-status/07-review-command.md
slice: 07
step: 4
title: Write behavior rules
status: done
depends_on: [03-feedback-path.md]
agent_type: architect
assigned_at: 2026-04-12T00:00:00Z
completed_at: 2026-04-12T00:00:00Z
---

## Work

Add a Behavior rules section to `defaults/commands/review.md`:

- Only run on `signoff_review` projects. Any other stage: output the routing error and stop.
- The approve commit includes everything uncommitted in the worktree — implementation files, task status files, QA report, slice status, status.md. This is the one commit for the entire execution pipeline.
- Never remove the worktree until the merge succeeds. Merge failure leaves the project at `signoff_review` with the worktree intact.
- Check for uncommitted changes before `git worktree remove`. If dirty, stop and warn — do not force-remove.
- Never overwrite an existing archive target. Fail with instructions.
- Feedback path: no commit. Feedback slices are reviewed via `/design` before anything is committed.
- Re-reading files from disk on resume: always re-read `status.md` and slice files — never use session-cached state.

## Done signal

Behavior rules section present in review.md, covering commit timing, worktree safety, archive collision, and feedback-no-commit invariants.
