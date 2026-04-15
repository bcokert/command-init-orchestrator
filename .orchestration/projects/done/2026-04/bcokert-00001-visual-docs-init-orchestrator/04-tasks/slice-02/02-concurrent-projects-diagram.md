---
spec: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/03-briefs/02-common-patterns-gallery.md
slice: 02
step: 2
title: Write concurrent-projects diagram
status: done
depends_on: [01-pause-resume-diagram.md]
agent_type: architect
assigned_at: 2026-04-14T10:13:00-07:00
completed_at: 2026-04-14T10:15:00-07:00
qa_result: null
---

Write `docs/diagrams/concurrent-projects.d2` showing two projects running in parallel on separate worktree branches, both visible in /status, main branch untouched. Use the same `vars` block as `docs/diagrams/artifacts.d2`. Render to `docs/diagrams/concurrent-projects.svg` using `d2 docs/diagrams/concurrent-projects.d2 docs/diagrams/concurrent-projects.svg`.

Done signal: SVG exists and is > 500 bytes.
