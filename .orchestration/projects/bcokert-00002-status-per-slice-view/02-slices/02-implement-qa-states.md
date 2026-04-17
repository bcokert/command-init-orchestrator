---
type: slice
slice: 02
order: 2
project: status-per-slice-view
design: .orchestration/projects/bcokert-00002-status-per-slice-view/01-design/design-01.md
status: reviewed
---

# Slice 02 — implement: write qa_in_progress/signoff_review slice states + timestamps

**Goal:** implement writes the two new slice states (`qa_in_progress`, `signoff_review`) to
slice frontmatter at the right points in the execution pipeline, with `status_updated_at`
timestamps. After this slice, the full extended state machine is live in slice files.

## Happy path

- When QA begins, implement sets `status: qa_in_progress` + `status_updated_at` on the slice.
- When QA passes (signoff gate reached), implement sets `status: signoff_review` + `status_updated_at`.
- When /review approves, implement (or review) sets `status: done` + `status_updated_at`.
- `status: implementing` + `status_updated_at` is also written when task execution starts (previously untracked).
- Both `.claude/commands/implement.md` and `defaults/commands/implement.md` updated identically.
- Version bumped (minor — new behaviour) in both files.

## Edge cases

- If the slice file can't be found when trying to write the state (e.g. path mismatch),
  log a warning and continue — don't block execution.
- On resume after crash, if slice is already in `qa_in_progress`, don't re-write it.
- `status_updated_at` is always overwritten, not skipped, when status changes.
