---
type: slice
slice: 07
order: 07
project: state-machine-refactor
design: .orchestration/projects/bcokert-00004-state-machine-refactor/01-design/design-01.md
status: done
status_updated_at: 2026-04-22T00:46:00-04:00
---

# Slice 07 — Atomic spec and breakdown

**Goal:** Spec and breakdown run sequentially without a gate. Slice approval → spec → breakdown → tasks_ready in one uninterrupted flow.

## Happy path

- Spec gate removed from plan-project. After slice approval, spec writes immediately, then breakdown runs immediately.
- Both crash-resumable via frontmatter: `speccing` status → re-run spec idempotently; `breakdown` status → delete partial tasks and regenerate.
- No "re-run /plan-project to continue to breakdown" message shown.
- Slice frontmatter transitions: `review → speccing → breakdown → tasks_ready` without any human gate between them.
- Version bumped (minor) on `defaults/commands/plan-project.md`.

## Edge cases

- **Crash mid-spec** (status `speccing`, no brief file): re-run spec from scratch, then continue to breakdown.
- **Crash mid-breakdown** (status `breakdown`, partial task files): delete all task files in the slice's task dir, regenerate from breakdown table.
- **Second crash in the same phase**: same idempotent behavior; state derived from disk.
