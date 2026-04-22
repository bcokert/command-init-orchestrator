---
type: slice
slice: 05
order: 05
project: state-machine-refactor
design: .orchestration/projects/bcokert-00004-state-machine-refactor/01-design/design-01.md
status: draft
status_updated_at: 2026-04-21T00:00:00-04:00
---

# Slice 05 — Observability artifacts

**Goal:** Each project gets an `observability/` directory with three files for questions, iteration replay, and decisions. Populated automatically during plan-project runs.

## Happy path

- New project creation writes `observability/questions.md`, `observability/iterations.md`, `observability/decisions.md` with empty template headers.
- `questions.md`: appended with timestamped question entries (open/answered state) during interviewQuestions().
- `iterations.md`: appended at the end of each planIteration with timestamp, current state, what changed, why.
- `decisions.md`: appended by updatePlanningContext when key decisions are made.
- Version bumped (minor) on `defaults/commands/plan-project.md`.

## Edge cases

- **Existing projects without observability/**: created on first plan-project run. Existing planning history is not reconstructed — files start empty from that point.
- **Observability files missing mid-project** (deleted accidentally): recreate with empty templates, continue. Observability loss only; project state unaffected.
- **observability/ committed separately from planning artifacts**: fine. These are append-only logs; partial history is better than none.
