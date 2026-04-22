---
type: slice
slice: 06
order: 06
project: state-machine-refactor
design: .orchestration/projects/bcokert-00004-state-machine-refactor/01-design/design-01.md
status: done
status_updated_at: 2026-04-22T01:40:00-04:00
---

# Slice 06 — Slicing iteration loop

**Goal:** Slicing has the same feedback loop as design. Feedback on slices triggers planIteration rather than requiring manual file edits and re-runs.

## Happy path

- Slicing.Review onAnswer {containsFeedback} → planIteration(affected slices) → update slices → back to Slicing.Review with a summary.
- Answers that contain neither clear feedback nor approval trigger planIteration (treated as implied questions/concerns), not accidental approval.
- planIteration stages previous changes before updating, consistent with slice 03 behavior.
- Affected slices receive detailed updates; later unimplemented slices get a cohesion pass.
- Version bumped (minor) on `defaults/commands/plan-project.md`.

## Edge cases

- **Feedback applies to multiple slices**: all affected slices updated in order; summary names which changed.
- **Ambiguous response** (not clearly feedback or approval): planIteration runs; agent resurfaces a summary and asks again.
- **Feedback contradicts the design doc**: agent surfaces the conflict and resolves it before updating slices.
