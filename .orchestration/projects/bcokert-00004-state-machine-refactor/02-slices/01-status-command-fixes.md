---
type: slice
slice: 01
order: 01
project: state-machine-refactor
design: .orchestration/projects/bcokert-00004-state-machine-refactor/01-design/design-01.md
status: reviewed
status_updated_at: 2026-04-21T12:00:00-04:00
---

# Slice 01 — Status command fixes

**Goal:** Fix `/status` so all active projects appear and design-phase projects display a useful row instead of a blank or missing entry. Update all state tables to reflect current status values.

## Happy path

- Glob pattern changed from `projects/*/` to `projects/*` (no trailing slash). All project directories appear in the scan. Projects are filtered to directories (or those containing known subdirectories); `done/` paths excluded.
- A project with a design doc but no `02-slices/` directory renders a design-phase row:
  `**{id}** · {MMM D} · design: {design_status}  →  **\`/plan-project\`**`
  where `design_status` is the `status:` field from `design-01.md`. Absent field → `in_progress`.
- Design-phase projects sort by `date:` from the design doc. Consistent with slice-based sort order.
- State abbreviation table in `status.md` updated in full: includes `review`, `speccing`, `breakdown`, `tasks_ready`, and correct emoji assignments for each. Old `reviewed` value treated as alias for `review` in bucket and display logic.
- Bucket table updated: `👤` includes `draft`, `review`, `signoff_review`. `⏳` includes `speccing`, `breakdown`, `tasks_ready`.
- Command routing table updated: `speccing`, `breakdown` rows added (both route to `/plan-project`).
- Version bumped (minor) on `defaults/commands/status.md`.

## Edge cases

- **Design doc missing `status:` field** (old projects): display `in_progress`. Do not fail.
- **Old `reviewed` status in slice file**: treated identically to `review` in both bucket assignment and `prev→curr` display. No migration needed.
- **No active projects found**: "no active projects" message unchanged. Route to correct message even when all projects are design-phase only.
- **Project directory exists but no `01-design/` and no `02-slices/`**: exclude it from display. A project with no artifacts is either a leftover directory or mid-creation crash — not safe to show.
- **Project in `done/` subdirectory**: excluded by glob filter. Must not appear in output.
