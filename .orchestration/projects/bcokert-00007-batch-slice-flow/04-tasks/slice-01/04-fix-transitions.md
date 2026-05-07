---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/01-state-diagram-anchor.md
slice: 01
step: 4
title: Fix state-machine transitions
status: todo
depends_on: [03-write-schema-tables.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Apply transition fixes in `.root-context/state-diagram.md`:
- Delete `Implementation.Asking: onAnswer {wantMoreSlicesBrokenDown} -> Slicing.Review`.
- Split `Signoff.Approved` into three batch-aware transitions (more signoff slices in project / no more signoff but unfinished / all done).
- Retarget `Signoff.Review.containsFeedback` to match `/review` Phase 2 behavior (write draft, return).
- Add `Implementation.QA -> Implementation.Running` for the next slice's tasks.
- Collapse `Slicing.Generating` self-loop into a single `Slicing.Generating -> Slicing.Review`.
- Delete the "Slicing.Asking from an earlier draft was a mistake" comment.
- Replace "agent tracks last prompt context" with `review_context:` frontmatter persistence.

**Done signal:** Grep verifies all six changes; deletions removed; additions present.
