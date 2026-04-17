---
type: slice
slice: 04
order: 4
project: status-per-slice-view
design: .orchestration/projects/bcokert-00002-status-per-slice-view/01-design/design-01.md
status: tasks_ready
---

# Slice 04 — docs and diagrams: reflect extended slice state machine

**Goal:** diagrams and READMEs accurately describe the extended slice state machine
(`qa_in_progress`, `signoff_review`) and updated slice frontmatter fields.

## Happy path

- `lifecycle.d2` updated to show full slice state machine including new states; SVG re-rendered.
- `artifacts.d2` updated to show `status_updated_at` in slice frontmatter; SVG re-rendered.
- `README.md` and `defaults/README.md` prose updated wherever the slice state machine or
  implement flow is described.
- All other diagrams checked for impact; updated if needed.

## Edge cases

- If a README doesn't mention the slice state machine, no change needed — don't add prose just to add it.
- SVGs must be re-rendered from d2 source after any .d2 change; never edit SVGs directly.
