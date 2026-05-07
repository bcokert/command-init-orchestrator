---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/08-support-files-cleanup.md
slice: 08
step: 4
title: slice.md — state-machine prose cut, Bdon→user, bdonize reference, version bump
status: todo
depends_on: [03-spec-cleanup.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

In `defaults/commands/slice.md`: delete the inline state-machine prose at line 114 ("ask Bdon to approve. On approval, write status: review …") and replace with a reference to `state-diagram.md` Slicing.Review section. Replace "Bdon" with "the user". Replace bdonize block with reference to `support/bdonize.md`. Bump version (patch).

**Done signal:** `grep -n 'Bdon' defaults/commands/slice.md` returns no matches; references to state-diagram.md and bdonize.md present.
