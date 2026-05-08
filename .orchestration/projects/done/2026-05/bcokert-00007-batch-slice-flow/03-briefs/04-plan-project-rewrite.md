# Brief 04 — /plan-project rewrite

**Type:** Task (AI agent)
**Date:** 2026-05-06

## 1. Intent

`/plan-project` is the largest command file (448 lines). It carries duplicated routing, broken status writes, both Phase 7 team gates, missing Mixed-response handling, design-template `status: ready` bug, and several stale references. This slice rewrites it to apply every correctness fix from the design and shrink ~35% by leaning on slice-01 anchors and slice-02 helpers.

state_machine: true

## 2. Observable outcomes

```
Given /plan-project before this slice
When the slicing gate fires after generating N slices
Then every slice gets status: review AND review_context: initial (not just slice 01)
```

```
Given /plan-project before this slice
When the user responds to the slicing gate with "approve 1, 2; feedback on 3"
Then slices 1, 2 advance to speccing; slice 3 stays at review and runs planIteration; only slice 3 resurfaces
```

```
Given /plan-project before this slice
When Phase 7 finishes a slice's breakdown
Then no team-confirmation gate fires (neither per-slice nor end-of-batch)
```

```
Given /plan-project before this slice
When the user runs /plan-project on a project with a follow_up_of: slice
Then the surfacing distinguishes "follow-up from prior signoff feedback" from "fresh draft"
```

```
Given /plan-project before this slice
When Phase 7 generates the breakdown table
Then if any task touches state-machine behavior, a "verify state-diagram.md" task is prepended
```

```
Given /plan-project after this slice
When the file is counted
Then it is ≤ ~290 lines (down from 448) and contains no "Bdon", "operator", or "human" as actor terms
```

## 3. Constraints

**Must:**
- Use shared next-actions.md reader for Phase 0 scope detection.
- Use shared status-write.md helper for every status write.
- Reference shared bdonize.md instead of inlining the voice block.
- Write status_updated_at on every status write — currently 4 sites are missing it.
- Design doc template uses `status: in_progress` (not `status: ready`).
- Write `status: review` AND `review_context: initial` to every slice on slicing gate.
- Add a "Mixed" row to Phase 5 response classification.
- Collapse Phase 4 + Phase 5 design-approval commit into one block.
- Cut both Phase 7 team-confirmation gates entirely.
- Add diagram-first trigger to Phase 7 breakdown.
- Surface follow_up_of: slices distinctly in Phase 0.
- Tighten Phase 5:278 crash-resume to "all slices `draft` AND no commit referencing `02-slices/` in git log".
- Trim Behavior rules to plan-project deltas; link shared rules to state-diagram.md.
- Mirror to `.claude/commands/plan-project.md`. Bump version (minor).

**Must not:**
- Lose any load-bearing behavior (root-context-conflicts prompt, crash-recovery semantics, ordering constraint).
- Skip the diagram-first verification (slice 01 should already cover it; if drift, surface).

**Preferences:**
- Replace verbose quoted prompt templates with one-sentence summaries plus the marker line.

**Escalation triggers:**
- If shrinking past ~290 lines requires cutting a load-bearing rule, stop and ask.

## 4. Done definition

- `defaults/commands/plan-project.md` line count ≤ 290.
- `.claude/commands/plan-project.md` matches defaults version verbatim.
- `grep -nw 'Bdon\|human\|operator\|reviewed\|specced\|feedback_pending\|status: ready' defaults/commands/plan-project.md` returns no matches in active text.
- Phase 7 has no "Wait for confirmation" prompt.
- Slicing gate writes `status: review` and `review_context: initial` to every slice.
- Mixed row exists in Phase 5 response classification.

## 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Confirm state-diagram alignment for plan-project | If state-diagram.md drifts from this slice's behavior, update it; record confirmation | Diagram matches slice contracts |
| 2 | Phase 0 rewrite | Use next-actions.md; cut dead routing rows (reviewed, specced, mutually-exclusive row, feedback_pending mention) | Phase 0 ≤ ~25 lines; dead rows gone |
| 3 | Status-write migration | All status writes use status-write.md; missing status_updated_at writes added | Every Phase 5/6/7 status write goes through helper |
| 4 | Slicing gate batch + Mixed row | Write status: review + review_context: initial to all slices; add Mixed response row | Verified by reading the rewritten Phase 5 |
| 5 | Design-approval consolidation | Phase 4 + Phase 5 merged into one approval block; entry guard for crash resume | Single commit point; idempotent on re-run |
| 6 | Cut Phase 7 team gates + add diagram-first trigger | Both gates gone; trigger inspects breakdown table and prepends state-diagram task when state-machine work present | Phase 7 has no waits; trigger logic present |
| 7 | follow_up_of routing + design template fix + Phase 5:278 tighten | follow_up_of: surfaces distinctly; status: in_progress in template; crash signal disk-readable | Verified by Phase 0 prose and template |
| 8 | Bdonize reference + Behavior rules trim + vocabulary purge | Reference support/bdonize.md; cut shared rules; purge Bdon/human/operator | grep clean |
| 9 | Mirror + version bump + verify size and vocabulary | .claude/commands/plan-project.md matches defaults; ≤ 290 lines; clean grep | Size + grep checks pass |
