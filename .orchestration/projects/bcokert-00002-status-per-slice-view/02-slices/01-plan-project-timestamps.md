---
type: slice
slice: 01
order: 1
project: status-per-slice-view
design: .orchestration/projects/bcokert-00002-status-per-slice-view/01-design/design-01.md
status: tasks_ready
---

# Slice 01 — plan-project: write status_updated_at on slice status changes

**Goal:** plan-project writes a `status_updated_at` timestamp to slice frontmatter every time
it changes a slice's `status` field. After this slice, any slice file touched by plan-project
carries a machine-readable timestamp the status command can display.

## Happy path

- When plan-project creates slice files in Phase 5 (slicing), each file's frontmatter includes
  `status: draft` and `status_updated_at: {ISO 8601 with timezone offset}`.
- When plan-project updates a slice to `status: specced` in Phase 6 (spec), it also updates
  `status_updated_at` to the current timestamp.
- When plan-project updates a slice to `status: tasks_ready` in Phase 7 (breakdown), it also
  updates `status_updated_at` to the current timestamp.
- Both `.claude/commands/plan-project.md` and `defaults/commands/plan-project.md` are updated
  identically (dogfood + ship in sync).
- Version bumped (patch) in both files.

## Edge cases

- If `status_updated_at` is already present in a slice file being updated (e.g. on a resume
  after crash), it is overwritten with the current timestamp — not skipped.
- Timestamp format is ISO 8601 with timezone offset, matching existing transition timestamps
  throughout the system. No other format is acceptable.
- Slice files created before this change have no `status_updated_at`. The status command
  handles this by showing `—` — no backfill needed here.
