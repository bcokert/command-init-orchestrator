---
type: slice
slice: 06
order: 06
project: remove-worktrees-queue-model
design: .orchestration/projects/bcokert-00003-remove-worktree-replace-task-queuing/01-design/design-01.md
status: done
status_updated_at: 2026-04-19T09:15:00-07:00
---

# Slice 06 — Fix /review: route by slice state, not project stage

**Goal:** `/review` currently finds projects by scanning for `stage: signoff_review` in status.md. This is brittle — status.md `stage` can be stale or wrong, as we've seen. Route instead by scanning for slice files with `status: signoff_review`. Archive only when all slice files are `status: done`.

## Happy path

- `/review` with no argument scans all `.orchestration/projects/*/02-slices/*.md` for `status: signoff_review`. If one match: use it. If multiple: list and prompt. If none: "No slices awaiting signoff."
- After approval, check remaining slice statuses directly from slice files. If any slice is not `done`: do not archive. Output: "Slice {NN} done — {N} slices remaining. Run /plan-project or /implement to continue."
- If all slices are `done` after approval: archive as today.
- The `stage` field in status.md is never read for routing. It may still be written as part of the transitions log for now (cleaned up in slice 07).

## Edge cases

- Multiple slices in `signoff_review` simultaneously: list all and ask which to approve first.
- Slice file for the approved slice can't be found: log warning, proceed with commit and archive check using remaining readable slices. Treat unreadable slice as not-done (conservative — don't archive if uncertain).
- All slice files readable and `done` after approval: archive proceeds as normal.
- `/review` called with a project ID arg: find the slice in `signoff_review` within that project, not from status.md stage.
