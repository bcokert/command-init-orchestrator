---
type: slice
slice: 01
order: 01
project: state-diagram-driven-changes
design: .orchestration/projects/bcokert-00005-state-diagram-driven-changes/01-design/design-01.md
status: draft
status_updated_at: 2026-04-21T00:00:00-04:00
---

# Slice 01 — Diagram-first rule in CLAUDE.md

**Goal:** Add a clear, enforceable rule to this project's CLAUDE.md that makes diagram-first updates automatic. Any spec brief for a slice that modifies state machine behavior must list "update state-diagram.md and affected root-context files" as its first breakdown task. After that task runs at implementation time, the agent performs a forward cohesion pass on all unimplemented current-project artifacts.

## Happy path

- CLAUDE.md has a new "Diagram-first enforcement" section with the rule stated precisely.
- The rule names the trigger: changes to transitions, states, guards, or key behavioral principles. Renaming, docs-only changes, and observability additions don't trigger it.
- The rule specifies the first-task requirement at both spec-write time (plan-project breakdown) and implementation time (implementing agent, before starting any state-machine-touching task).
- The rule specifies the cohesion pass: after updating any `.root-context/` file, review and update all unimplemented current-project artifacts (design docs, slices, briefs, task files) for consistency.
- The rule names scope: current project only. Other projects reload root-context on their next plan-project entry.
- The rule names the false-positive policy: when it's ambiguous whether a change is "state machine behavior," include the diagram task anyway.

## Edge cases

- **Diagram already current:** the first task runs, confirms no update needed, documents the confirmation, and marks done. Not a silent skip.
- **Brief written without the task (old behavior or oversight):** implementing agent detects the gap on first task start and adds the diagram task before proceeding.
- **Multiple slices in the same project all touch state machine behavior:** each slice gets the task independently. Second slice's task builds on or confirms the first slice's update.
- **Cohesion pass runs while other tasks are in-flight:** only unimplemented artifacts are updated. Tasks at `done` or `implementing` are not re-opened.
- **Root-context file updated but slice doesn't affect state machine:** cohesion pass still runs. The trigger is "root-context file changed," not "state machine behavior changed."
