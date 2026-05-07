---
type: slice
slice: 08
order: 08
project: batch-slice-flow
design: .orchestration/projects/bcokert-00007-batch-slice-flow/01-design/design-01.md
status: tasks_ready
status_updated_at: 2026-05-06T20:03:31-07:00
---

# Slice 08 — qa, slice, spec cleanup + drift fixes

**Goal:** `/qa` description matches its actual output path. `slice.md` and `spec.md` reference shared bdonize. `slice.md` no longer describes state-machine transitions inline. Stale references and Bdon mentions purged from shipped support files.

## Happy path

- `qa.md:1` description path corrected: writes go to `.orchestration/projects/{id}/05-qa/slice-{NN}-qa-report.md` (matches Phase 3 actual write).
- `qa.md:70` legacy `reviewed` reference replaced with `review`.
- `qa.md:121` "escalate to Bdon" replaced with "escalate to the user".
- `spec.md:139` stale `/delegate` reference deleted.
- `slice.md` inline state-machine prose at line 114 ("ask Bdon to approve. On approval, write `status: review`") removed; references `state-diagram.md` Slicing.Review section.
- `slice.md`, `spec.md` bdonize blocks replaced with reference to `support/bdonize.md`.
- "Bdon" replaced with "the user" across `slice.md`, `spec.md`, `qa.md`.
- All affected files version bumped.

## Edge cases

- The state-machine cut from slice.md must not lose load-bearing behavior — slice.md was the only place describing "draft → review on approval"; verify state-diagram.md covers this after slice 01.
- `qa.md` description-path fix is a one-character edit but ships to downstream users; their next install via `/init-orchestrator` picks it up.
- Bdonize reference must be a clear pointer ("see `support/bdonize.md`"), not a wishful link the agent has to interpret.
- "the user" replaces "Bdon" semantically; verify no sentences become awkward (e.g., possessives).
- Files in `defaults/commands/` AND `.orchestration/support/` must stay in sync (they're byte-identical pairs).
