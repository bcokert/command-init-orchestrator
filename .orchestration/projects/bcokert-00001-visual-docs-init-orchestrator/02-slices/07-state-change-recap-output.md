---
type: slice
slice: 7
order: 7
project: bcokert-00001-visual-docs-init-orchestrator
design: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/01-design/design-01.md
status: draft
---

# Slice 7 — State change recap output

**Goal:** Every command outputs a one-line status recap after a state transition, so the user always knows where the project is, what just happened, and what to run next — without scrolling back.

## Happy path

- Format: `Slice {NN} ({title}) is at {stage}, {last event}. Run /{command} to {next action}.`
- Example: "Slice 03 (CLAUDE.md + defaults/README.md) is at signoff_review, QA passed. Run /review to approve and merge."
- Appears as the closing line after every gate or state change:
  - `/design` — after design_review gate, slicing_review gate, spec_review gate, tasks_ready
  - `/implement` — after QA passes (signoff_review)
  - `/review` — after approve (feedback_pending with backlog summary) or feedback recorded

## Edge cases

- When the project has no slice number yet (new project at design_in_progress) — omit the slice part, just stage + next action
- When feedback is recorded, the "next action" refers to the next unspecced slice, not the one just closed
- Format must be consistent across all three commands — same structure, same voice
