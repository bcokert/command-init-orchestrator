---
spec: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/03-briefs/01-readme-core-diagrams.md
slice: 01
step: 2
title: Write and render happy-path diagram
status: done
depends_on: [01-readme-prose.md]
agent_type: architect
assigned_at: 2026-04-13T12:33:00-07:00
completed_at: 2026-04-13T12:36:00-07:00
qa_result: null
---

Write `docs/diagrams/happy-path.d2` and render it to `docs/diagrams/happy-path.svg`.

The diagram shows the end-to-end flow for a single project:
- `/design` internal stages: interview → design doc → slicing → spec → breakdown
- Human gates (visually distinct — different shape or colour): design_review, slicing_review, spec_review
- `tasks_ready` → `/implement`
- `/implement` stages: worktree created → tasks execute (sequential) → QA auto-runs → signoff_review
- `/review` human gate: approve path (merge + archive → done) and feedback path (feedback_pending → new slice → back to /design)

Use a shared `vars` block for font and colour. Try `direction: right` first; fall back to `direction: down` if the diagram overflows ~900px width. Human gates must be visually distinct from automated steps.

Render command: `d2 docs/diagrams/happy-path.d2 docs/diagrams/happy-path.svg`

Done signal: `docs/diagrams/happy-path.svg` exists, is non-empty (>500 bytes), renders without error, human gates are visually distinct, feedback loop is present.
