---
spec: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/03-briefs/01-readme-core-diagrams.md
slice: 01
step: 3
title: Write and render lifecycle state machine
status: done
depends_on: [02-happy-path-diagram.md]
agent_type: architect
assigned_at: 2026-04-13T12:36:00-07:00
completed_at: 2026-04-13T12:39:00-07:00
qa_result: null
---

Write `docs/diagrams/lifecycle.d2` and render it to `docs/diagrams/lifecycle.svg`.

All stage values as states:
`design_in_progress`, `design_review`, `slicing_in_progress`, `slicing_review`, `spec_in_progress`, `spec_review`, `breakdown_in_progress`, `tasks_ready`, `implementing`, `signoff_review`, `feedback_pending`, `done`

Transitions labelled with the driving command:
- design_in_progress → design_review (`/design` completes interview)
- design_review → slicing_in_progress (`/design` re-run)
- slicing_in_progress → slicing_review (`/design` completes slicing)
- slicing_review → spec_in_progress (`/design` re-run)
- spec_in_progress → spec_review (`/design` completes spec)
- spec_review → breakdown_in_progress (`/design` re-run)
- breakdown_in_progress → tasks_ready (`/design` completes breakdown)
- tasks_ready → implementing (`/implement`)
- implementing → signoff_review (`/implement` QA passes)
- signoff_review → done (`/review` approve)
- signoff_review → feedback_pending (`/review` feedback)
- feedback_pending → design_in_progress (`/design` new slice)

Human gate states (visually distinct): `design_review`, `slicing_review`, `spec_review`, `signoff_review`

Use the same `vars` block as `happy-path.d2`. State machine layout — `direction: down` or circular, whichever makes the feedback loop most readable.

Render command: `d2 docs/diagrams/lifecycle.d2 docs/diagrams/lifecycle.svg`

Done signal: `docs/diagrams/lifecycle.svg` exists, is non-empty (>500 bytes), all 12 states present, `feedback_pending` loop visible, human gate states visually distinct.
