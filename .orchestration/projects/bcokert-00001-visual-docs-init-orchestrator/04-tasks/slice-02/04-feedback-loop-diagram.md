---
spec: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/03-briefs/02-common-patterns-gallery.md
slice: 02
step: 4
title: Write feedback-loop diagram
status: todo
depends_on: [03-multi-slice-sequence-diagram.md]
agent_type: architect
assigned_at: null
completed_at: null
qa_result: null
---

Write `docs/diagrams/feedback-loop.d2` showing the feedback path: /review receives feedback → feedback slice written to backlog → /design specs it → /implement runs it → back to /review. Use the same `vars` block as `docs/diagrams/artifacts.d2`. Render to `docs/diagrams/feedback-loop.svg` using `d2 docs/diagrams/feedback-loop.d2 docs/diagrams/feedback-loop.svg`.

Done signal: SVG exists and is > 500 bytes.
