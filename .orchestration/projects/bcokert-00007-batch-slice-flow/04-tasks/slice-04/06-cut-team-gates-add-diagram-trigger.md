---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/04-plan-project-rewrite.md
slice: 04
step: 6
title: Cut Phase 7 team gates and add diagram-first trigger
status: todo
depends_on: [05-design-approval-collapse.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Delete both Phase 7 team-confirmation gates (per-slice during loop and end-of-batch). Add a diagram-first trigger in Phase 7: when the brief's breakdown table contains `state_machine: true` or any task description mentions state-machine work, prepend a "verify state-diagram.md current" task to the breakdown.

**Done signal:** Phase 7 has no waits; diagram-first trigger logic visible.
