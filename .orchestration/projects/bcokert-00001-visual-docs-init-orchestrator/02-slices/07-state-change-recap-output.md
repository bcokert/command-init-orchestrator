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

- Format: `※ Slice {NN} · stage {N}/10 {stage_name} · {last event} → {next action} {emoji}`
- Trailing emoji is one of two: 📄 = human must review something before proceeding, ▶️ = just run the next command
- Stage numbering (1–10): design_in_progress(1), design_review(2), slicing_in_progress(3), slicing_review(4), spec_in_progress(5), spec_review(6), breakdown_in_progress(7), tasks_ready(8), implementing(9), signoff_review(10)
- Examples:
  - `※ Slice 03 · stage 10/10 signoff_review · QA passed → /review to approve 📄`
  - `※ Slice 03 · stage 9/10 implementing · task execution started → QA running ▶️`
  - `※ Slice 03 · stage 8/10 tasks_ready · breakdown complete → /implement to start 📄`
  - `※ Slice 03 · feedback_pending · 1 new slice → /design to spec next 📄`
- Appears as the closing line after every stage transition:
  - `/design` — after design_review gate, slicing_review gate, spec_review gate, tasks_ready
  - `/implement` — after QA passes (signoff_review)
  - `/review` — after approve or feedback recorded

## Edge cases

- New project before first slice is assigned — omit slice number: `※ stage 1/10 design_in_progress · interview started → answer questions ▶️`
- feedback_pending sits outside 1–10 — render without stage number as shown above
- done is terminal — no recap needed
- Format must be identical across all three commands — same structure, same voice
