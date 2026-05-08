---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/04-plan-project-rewrite.md
slice: 04
step: 8
title: Bdonize reference + Behavior rules trim + vocabulary purge
status: done
depends_on: [07-followup-routing-and-fixes.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Replace inline bdonize block with reference to `support/bdonize.md`. Trim Behavior rules section to plan-project-specific deltas (link shared rules to `state-diagram.md` Principles). Replace "Bdon", "human", "operator" with "user" throughout. Preserve the load-bearing root-context-conflicts prompt verbatim.

**Done signal:** `grep -nw 'Bdon\|human\|operator' defaults/commands/plan-project.md` returns no matches as actor terms; reference to bdonize.md present; Behavior rules ≤ ~5 lines.
