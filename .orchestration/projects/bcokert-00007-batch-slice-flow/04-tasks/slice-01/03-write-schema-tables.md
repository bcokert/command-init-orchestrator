---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/01-state-diagram-anchor.md
slice: 01
step: 3
title: Write typed schema tables
status: todo
depends_on: [02-add-vocabulary.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Add typed schema tables to `.root-context/state-diagram.md` for slice / design / task frontmatter. Columns: `field | type | values | required`. Slice schema includes `review_context` enum (`initial | post_iteration | question`) and `follow_up_of`. Note the design-template `status: ready` discrepancy as a known bug fixed in slice 04.

**Done signal:** Three schema tables present and complete.
