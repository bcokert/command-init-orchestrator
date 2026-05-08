---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/10-readme-and-diagrams-refresh.md
slice: 10
step: 1
title: README.md update
status: done
depends_on: []
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

In `README.md`: drop "spec review" gate from line 40; replace "(one per specced slice)" at line 102 with "(one per spec)"; add `observability/` and `support/` to folder layout; align "interleaved" wording with oldest-first sort; list agents and support classes in the install description.

**Done signal:** `grep -n 'spec review\|specced slice' README.md` returns no matches; folder layout includes new dirs.
