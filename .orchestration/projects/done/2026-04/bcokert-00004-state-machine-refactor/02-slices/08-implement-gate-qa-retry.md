---
type: slice
slice: 08
order: 08
project: state-machine-refactor
design: .orchestration/projects/bcokert-00004-state-machine-refactor/01-design/design-01.md
status: done
status_updated_at: 2026-04-22T01:35:00-04:00
---

# Slice 08 — Implementation.Asking gate and QA auto-retry

**Goal:** /implement shows a confirmation gate before starting execution. QA retries indefinitely until the agent explicitly declares it cannot continue without human input.

## Happy path

- After all approved slices reach `tasks_ready`, /implement surfaces Implementation.Asking: total task count across ready slices, agent team, "ready to start?" prompt.
- "Let me review more slices first" → loops back to Slicing.Review for the next pending slice; after it reaches `tasks_ready` → returns to Implementation.Asking.
- Approval → execution starts; first implementing slice status set to `implementing`.
- QA failure with a fixable issue: agent tries a different approach and reruns QA. No fixed retry cap.
- Escalation to Signoff.Review happens only when agent explicitly states "I cannot fix this without human input" — and gives a reason.
- Human provides a fix after signoff QA failure → slice transitions back to `qa_in_progress`, QA reruns.
- Version bumped (minor) on `defaults/commands/implement.md` and `defaults/commands/qa.md`.

## Edge cases

- **Multiple slices in `tasks_ready`**: Implementation.Asking shows aggregate count across all of them.
- **"Review more slices" loop**: after reviewed slice reaches `tasks_ready`, return is to Implementation.Asking, not straight to Running.
- **Vague QA fix attempts that don't resolve the issue**: do not count as genuine attempts. Agent must try meaningfully different approaches before declaring stuck.
- **Human-provided fix is a new dot-notation slice (e.g., 5.1)**: new slice starts at `draft`, goes through full flow; does not bypass QA.
