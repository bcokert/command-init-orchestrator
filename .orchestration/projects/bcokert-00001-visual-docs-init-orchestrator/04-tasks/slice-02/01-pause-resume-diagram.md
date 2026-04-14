---
spec: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/03-briefs/02-common-patterns-gallery.md
slice: 02
step: 1
title: Write pause-resume diagram
status: todo
depends_on: []
agent_type: architect
assigned_at: null
completed_at: null
qa_result: null
---

Write `docs/diagrams/pause-resume.d2` showing an in-progress /implement execution getting interrupted mid-run, then re-run picks up from the last completed task. Use the same `vars` block as `docs/diagrams/artifacts.d2`. Render to `docs/diagrams/pause-resume.svg` using `d2 docs/diagrams/pause-resume.d2 docs/diagrams/pause-resume.svg`.

Done signal: SVG exists and is > 500 bytes.
