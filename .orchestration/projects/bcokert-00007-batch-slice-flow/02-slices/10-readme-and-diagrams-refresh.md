---
type: slice
slice: 10
order: 10
project: batch-slice-flow
design: .orchestration/projects/bcokert-00007-batch-slice-flow/01-design/design-01.md
status: draft
---

# Slice 10 — README + defaults/README + diagram refresh

**Goal:** `README.md`, `defaults/README.md`, and the d2 diagrams reflect post-batch behavior. Tables become links to `state-diagram.md` rather than re-lists. SVGs re-rendered. No prose drift remains.

## Happy path

- `README.md`: drop "spec review" gate from line 40; replace "(one per specced slice)" at line 102 with "(one per spec)"; add `observability/` and `support/` to folder layout; align "interleaved" wording with actual oldest-first sort; add agents + support classes to the install description.
- `defaults/README.md`: stage table replaced with a link to `state-diagram.md`'s schema/state tables; folder layout becomes a link; `feedback_pending` mention purged; agents and support files described or linked.
- Diagrams updated:
  - `lifecycle.d2`: spec_review diamond removed; spec → breakdown becomes one auto stage.
  - `state-machine.d2`: `wantMoreSlicesBrokenDown` edge removed; `Signoff.Approved → Slicing.Review` retargeted; `Implementation.QA → Running` added; `Slicing.Generating` self-loop collapsed.
  - `multi-slice-sequence.d2`: corrected to archive only on full completion, not after each slice.
  - `feedback-loop.d2`: note added that batched `/review` continues through all signoff slices, doesn't pause on first feedback.
- All affected `.svg` files re-rendered from `.d2` sources via `d2 docs/diagrams/{name}.d2 docs/diagrams/{name}.svg`.
- A read-through of README + defaults/README from a new user's perspective produces no contradictions with the actual command behavior.

## Edge cases

- Links from READMEs to `state-diagram.md` must use stable anchors (e.g. `state-diagram.md#vocabulary`, `#slice-states`); confirm anchor names exist after slice 01.
- SVG re-render must use the `d2` CLI (per `CLAUDE.md`); manual SVG edits prohibited.
- `feedback-loop.d2` note must not contradict slice 06's actual behavior.
- Folder-layout updates in README must match what `/init-orchestrator` actually installs after slice 09.
- A reader following any README link must land on a section that exists. Run a check after the slice lands.
