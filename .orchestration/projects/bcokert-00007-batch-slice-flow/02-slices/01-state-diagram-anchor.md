---
type: slice
slice: 01
order: 01
project: batch-slice-flow
design: .orchestration/projects/bcokert-00007-batch-slice-flow/01-design/design-01.md
status: tasks_ready
status_updated_at: 2026-05-06T20:03:31-07:00
---

# Slice 01 — state-diagram canonical anchor

**Goal:** `.root-context/state-diagram.md` becomes the single source of truth for principles (incl. crash recovery), frontmatter schemas as typed tables, vocabulary glossary, the "skip if clean" idiom, the batch-default principle, and the corrected state-machine transitions. Later slices link rather than restate.

## Happy path

- Principles section gains "Batch is the default" and a consolidated "Crash recovery" subsection covering re-read-from-disk, idempotent spec/breakdown, and brief+tasks fast-forward.
- Vocabulary section locks: `user`, `active project`, `queue`, `transition`, `action`. Each term has one definition and is the only term used elsewhere.
- Frontmatter schemas for slice / design / task written as typed tables (`field | type | values | required`). `review_context` enum (`initial | post_iteration | question`) and `follow_up_of` field included in slice schema.
- State-machine transitions corrected: `Implementation.Asking onAnswer wantMoreSlicesBrokenDown` deleted; `Signoff.Approved` split into three batch-aware transitions; `Signoff.Review.containsFeedback` retargeted to match `/review` Phase 2 behavior; `Implementation.QA → Running` transition added; `Slicing.Generating` self-loop collapsed; `Slicing.Asking from an earlier draft` comment deleted; "agent tracks last prompt context" replaced with "persisted via `review_context:` frontmatter".
- Reading state-diagram.md alone gives a complete picture of how batch flow works.

## Edge cases

- Schemas must reflect what `/plan-project` actually writes today, with one allowed exception: `status: ready` in the design template — this is a known bug fixed in slice 04, so the schema lists `in_progress | review | approved` as the canonical set and notes the discrepancy.
- Existing commands and READMEs still restate principles/schemas after this slice; those become redundant references until later slices cut them. State after this slice: state-diagram.md is correct; commands still duplicate. Cohesion pass on later slices addresses.
- New principles must not contradict existing ones. Run a full cohesion read of the file after each section update before saving.
- "Active project" definition must align with the implicit `excluding done/` filter every command uses. State the rule once here, drop everywhere else later.
