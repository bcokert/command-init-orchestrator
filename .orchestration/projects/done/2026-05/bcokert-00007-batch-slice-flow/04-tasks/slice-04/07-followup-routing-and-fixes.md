---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/04-plan-project-rewrite.md
slice: 04
step: 7
title: follow_up_of routing + design template + Phase 5 crash signal
status: done
depends_on: [06-cut-team-gates-add-diagram-trigger.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

In Phase 0, surface `follow_up_of:` slices distinctly from fresh drafts so the user knows what they're approving. Update the design-doc template to use `status: in_progress` instead of `status: ready`. Tighten Phase 5:278 crash-resume signal to "all slices `draft` AND no commit referencing `02-slices/` in git log".

**Done signal:** Phase 0 distinguishes follow-ups; template uses in_progress; crash signal disk-readable.
