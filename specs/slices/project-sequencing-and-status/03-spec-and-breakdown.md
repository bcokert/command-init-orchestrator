---
type: slice
slice: 03
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
status: reviewed
---

# Slice 03 — Spec + breakdown → tasks ready

**Goal:** After slicing approval, `/design` writes a spec for the next reviewed slice and creates task files in `tasks/`, advancing to `tasks_ready`. `/implement` now shows the project as selectable.

## Happy path

- Approve slices, run `/design` → `spec-{slice-id}.md` written, task files created in `tasks/` with `slice_id`, `assigned_at: null`, `completed_at: null`, status advances to `tasks_ready`, commit + push
- `/breakdown` removed as standalone command — logic is internal to `/design`
- `/implement` shows project as selectable after this slice

## Edge cases

- Breakdown crashes mid-way: partial task files → re-run detects mismatch against spec table, regenerates all task files (idempotent)
- Spec surfaces ambiguity in slices: ask user to resolve before writing
- `tasks/` contains files from a previous slice: new slice tasks stored with slice prefix — no collision
