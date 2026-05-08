---
type: slice
slice: 04
order: 04
project: batch-slice-flow
design: .orchestration/projects/bcokert-00007-batch-slice-flow/01-design/design-01.md
status: done
status_updated_at: 2026-05-08T13:30:00-07:00
---

# Slice 04 — /plan-project rewrite (correctness + batch + shrinkage)

**Goal:** `/plan-project` becomes batch-aware, applies all correctness fixes, uses the shared reader and helpers, and shrinks ~35%. Phase 7 team gates removed. Mixed-response handling for slicing review. Diagram-first trigger inserted. `follow_up_of:` routing distinct.

## Happy path

- Phase 0 collapses to a `next-actions.md` call + filter to `/plan-project`'s scope. Dead routing rows deleted (`reviewed`, `specced`, the mutually-exclusive "no slice in {…}" row, the `feedback_pending project` reference at line 226).
- Slicing gate writes `status: review` AND `review_context: initial` to **every** generated slice (not just slice 01). All status writes use `status-write.md` helper and include `status_updated_at`.
- Phase 5 response classification gains a "Mixed" row: split approve/feedback per slice, advance approved subset to `speccing`, run `planIteration` on the rest, resurface only the affected.
- Phase 4 + Phase 5 design-approval commit blocks collapse to one location. Phase 5 entry guard remains for crash resume.
- Phase 7 team-confirmation gates (per-slice and end-of-batch) deleted entirely.
- Phase 7 prepends a "verify state-diagram.md current" task to the breakdown when any task touches state-machine behavior (diagram-first enforcement from CLAUDE.md becomes mechanical).
- `follow_up_of:` slices in Phase 0 surface distinctly from fresh drafts so the user sees what they're approving.
- Design doc template uses `status: in_progress` (not `status: ready`).
- `planIteration` step 2 auto-stages incidental code edits with a one-line summary, no block prompt.
- "Behavior rules" section trimmed to plan-project-specific deltas; shared rules link to `state-diagram.md` Principles.
- Bdonize block replaced with reference to `support/bdonize.md`.
- `defaults/commands/plan-project.md` ≤ ~290 lines (down from 448). `.claude/commands/plan-project.md` mirrors. Version bumped.

## Edge cases

- Mixed-response handling must correctly classify a response that mentions slice numbers vaguely; ambiguous → re-ask once, then default to feedback. Approval errs to the safe side.
- Diagram-first trigger inspects the brief's breakdown table — define a clear keyword or marker (e.g. brief tagged `state_machine: true`) so the trigger is deterministic.
- `follow_up_of:` slice may sit at `draft` immediately after `/review` feedback; Phase 0 must not delete it as "stale" via the Phase 5 crash-resume rule.
- Phase 5 crash resume: tighten "no slice gate previously shown" to "all slices `draft` AND no commit referencing `02-slices/` in git log".
- Behavior rule cuts must preserve the load-bearing root-context-conflict prompt verbatim.
