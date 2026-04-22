---
type: slice
slice: 01
order: 01
project: state-diagram-driven-changes
design: .orchestration/projects/bcokert-00005-state-diagram-driven-changes/01-design/design-01.md
status: tasks_ready
status_updated_at: 2026-04-22T00:00:00-04:00
---

# Slice 01 — Diagram-first enforcement in CLAUDE.md

**Goal:** CLAUDE.md has a "Diagram-first enforcement" section that makes state-diagram and root-context updates automatic. Two enforcement points: plan-project always includes the diagram-update task first in any state-machine-touching slice's breakdown; any implementing agent that finds the task missing adds it before proceeding.

## Happy path

- CLAUDE.md has a new "Diagram-first enforcement" section with the rule stated precisely.
- Trigger conditions are named: adding, removing, or changing transitions, states, guards, or key behavioral principles. Non-triggers are explicit: renaming, docs-only changes, observability additions that don't affect transitions or states.
- First-task requirement applies at both spec-write time (plan-project breakdown) and implementation-start time (implementing agent, before the first non-diagram task).
- "No update needed" is not a silent skip — the task still runs, confirms no change was required, records that confirmation, and marks done.
- After any `.root-context/` file is updated during implementation, a cohesion pass runs over all unimplemented artifacts in the current project (design docs, slices, briefs, task files).
- Scope is current project only. Other projects reload root-context on their next plan-project entry.
- Ambiguity policy is stated: when unclear whether a change affects state machine behavior, include the diagram task. False positive beats false negative.

## Edge cases

- **Diagram already current:** diagram-update task runs, verifies no change needed, records the confirmation, marks done. Not a no-op — the confirmation is the artifact.
- **Brief missing the task:** implementing agent detects the gap on first task start, adds the diagram-update task before proceeding, then resumes normal flow.
- **Multiple slices touching state machine in one project:** each gets the diagram-update task independently. Later slices' tasks confirm or extend the first slice's update — they don't skip on the assumption it was already done.
- **Cohesion pass while tasks are in-flight:** only unimplemented artifacts are updated. Tasks at `done` or `in_progress` are not re-opened.
- **Root-context file updated but slice didn't trigger state machine rule:** cohesion pass runs anyway. The trigger is "root-context file changed," not "state machine behavior changed."
