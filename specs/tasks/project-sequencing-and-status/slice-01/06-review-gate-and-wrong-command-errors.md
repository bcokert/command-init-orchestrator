---
spec: specs/briefs/project-sequencing-and-status/01-project-creation-and-design-interview.md
slice: 01
step: 6
title: Implement review gate with education copy and wrong-command errors
status: todo
depends_on: [05-gate-commit-and-push.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

After commit and push, display the review gate with contextual education:

```
Design interview complete — {project_id}

Saved to: .orchestration/projects/{id}/design-01.md

This is your highest-leverage review point. Corrections here cost
nothing. Corrections after slicing require updating slices and
potentially the spec. Corrections after implementation cost the most.

Review the design doc. Edit it directly if anything is wrong.
When ready, run /design to continue to slicing.
```

Add wrong-command handling at the top of `design.md` phase 0, covering all design stages:
- If project is at `design_in_progress` or `design_review` and the user runs `/implement`: output "project '{id}' is in {stage} — run /design to continue"
- Same message format for `/review`
- These checks run before any other work

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/01-project-creation-and-design-interview.md` — education copy intent and wrong-command observable outcomes

## Done signal

Review gate displays after commit with the education copy above (or equivalent). Running `/implement` on a project at `design_in_progress` or `design_review` outputs the correct error with stage name and "run /design to continue". Same for `/review`.
