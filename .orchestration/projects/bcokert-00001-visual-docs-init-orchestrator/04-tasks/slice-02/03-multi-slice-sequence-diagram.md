---
spec: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/03-briefs/02-common-patterns-gallery.md
slice: 02
step: 3
title: Write multi-slice-sequence diagram
status: todo
depends_on: [02-concurrent-projects-diagram.md]
agent_type: architect
assigned_at: null
completed_at: null
qa_result: null
---

Write `docs/diagrams/multi-slice-sequence.d2` showing a project backlog with 3 slices: slice 01 complete and archived, slice 02 becoming "next" (detailed and specced), slice 03 staying rough until slice 02 is done. Use the same `vars` block as `docs/diagrams/artifacts.d2`. Render to `docs/diagrams/multi-slice-sequence.svg` using `d2 docs/diagrams/multi-slice-sequence.d2 docs/diagrams/multi-slice-sequence.svg`.

Done signal: SVG exists and is > 500 bytes.
