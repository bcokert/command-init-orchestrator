---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/08-support-files-cleanup.md
slice: 08
step: 3
title: spec.md — /delegate cut, Bdon→user, bdonize reference, version bump
status: done
depends_on: [02-qa-misc-fixes.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

In `defaults/commands/spec.md`: delete the `/delegate` reference at line 139. Replace "Bdon" with "the user". Replace the inline bdonize block with a reference to `support/bdonize.md`. Bump version (patch).

**Done signal:** `grep -n '/delegate\|Bdon' defaults/commands/spec.md` returns no matches; bdonize reference present.
