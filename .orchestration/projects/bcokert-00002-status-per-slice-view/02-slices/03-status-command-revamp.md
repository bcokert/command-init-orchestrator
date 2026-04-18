---
type: slice
slice: 03
order: 3
project: status-per-slice-view
design: .orchestration/projects/bcokert-00002-status-per-slice-view/01-design/design-01.md
status: done
status_updated_at: 2026-04-17T12:30:00-07:00
---

# Slice 03 — status command: per-slice grouped view

**Goal:** `/status` with no args shows a grouped view — one section per active project,
with every slice listed underneath in its current state.

## Happy path

- Running `/status` with no args shows projects grouped by header + slice rows.
- Project header: `{id}  started {date}  {N}/{N} slices  {N}/{N} tasks`
- Active slice row: `{title}  {previous} → {current}  since {date} {time}  →  {next action}`
- Done slice row: `✓ {title}  done {date} {time}` (no state line)
- Projects sorted most-recently-updated first.
- Projects with no slices show header with `0/0` placeholders and no slice rows.
- Done projects excluded entirely.
- Done-this-week section removed.
- Both `.claude/commands/status.md` and `defaults/commands/status.md` updated identically.
- Version bumped (major — breaking change to output format) in both files.

## Edge cases

- `status_updated_at` missing: show `—` for datetime, still render the row.
- Slice `status` missing or unrecognised: show `⚠ unknown state`, no transition line.
- Task directory missing for a slice: count as 0/0.
- Slice in `signoff_review`: active row, next action shows "run `/review`".
- All projects done: "no active projects — run `/plan-project` to start one".
