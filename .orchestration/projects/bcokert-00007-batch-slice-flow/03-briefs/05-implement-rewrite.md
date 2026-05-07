# Brief 05 — /implement rewrite

**Type:** Task (AI agent)
**Date:** 2026-05-06

## 1. Intent

`/implement` (134 lines) carries a rare-path "review more slices first" branch, a redundant duplicate routing row, a mid-batch re-read that contradicts "scope frozen at entry", and a re-entry team gate that re-fires unnecessarily. This slice cuts the cruft, leans on slices 01-02, and applies the design's contract clarifications.

state_machine: true

## 2. Observable outcomes

```
Given /implement before this slice
When the user runs it on a project with N tasks_ready slices
Then one team-confirmation gate fires at start; all N slices run end-to-end to signoff_review with no inter-slice prompt
```

```
Given /implement before this slice
When a new tasks_ready slice appears mid-run (e.g., from another /plan-project session)
Then /implement ignores it; scope was frozen at entry; the new slice is picked up on the next invocation
```

```
Given /implement before this slice
When the user re-runs after slice 1 reaches signoff_review with slice 2 at tasks_ready and the team mix is identical to the prior recorded run
Then the team gate is skipped; /implement proceeds directly
```

```
Given /implement after this slice
When the file is counted
Then ≤ ~95 lines (from 134); no "review more slices first" branch; no mid-batch re-read at lines 113-115
```

## 3. Constraints

**Must:**
- Phase 0 uses next-actions.md reader; sort and tiebreak move to the reader.
- Status writes use status-write.md helper.
- Cut the "review more slices first" branch from Phase 1.
- Cut the mid-batch re-read at lines 113-115 — execution list computed at Phase 0 is authoritative.
- Cut the duplicate "all tasks done → Phase 3" routing row.
- Re-entry team gate skips if team mix matches prior recorded run; record team mix in `observability/`.
- Trim Behavior rules to implement deltas; link shared rules.
- Mirror to `.claude/commands/implement.md`. Bump version (minor).
- Vocabulary "user" — replace "operator", "human".

**Must not:**
- Break crash recovery — every entry path must resume cleanly from disk state.
- Run tasks in parallel (sequential only per existing rule).
- Add new behavior beyond the design.

**Preferences:**
- Drop verbose quoted output templates; one-line summaries plus marker.

**Escalation triggers:**
- depends_on validation failures must stop the run with a clear message.

## 4. Done definition

- `defaults/commands/implement.md` line count ≤ 95.
- `.claude/commands/implement.md` matches defaults verbatim.
- `grep -n 'review more slices first' defaults/commands/implement.md` returns no matches.
- `grep -nw 'operator\|human' defaults/commands/implement.md` returns no matches as actor terms.
- Phase 1 surfaces aggregate team across all in-scope slices (one summary).
- Phase 3's post-QA loop uses the frozen scope, not a fresh re-read.

## 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Confirm state-diagram alignment for implement | If drift, update; record confirmation | Diagram matches slice contracts |
| 2 | Phase 0 rewrite | Use next-actions.md reader; cut duplicate routing row | Phase 0 ≤ ~15 lines |
| 3 | Cut "review more slices first" branch | Phase 1 ≤ ~10 lines | grep returns no matches |
| 4 | Cut mid-batch re-read | Lines 113-115 deleted; Phase 3 loop iterates frozen scope | grep returns no matches |
| 5 | Re-entry team gate logic | Team mix recorded in observability; skip if matches | Verified by reading Phase 1 |
| 6 | Status-write migration | All status writes use helper | Every site uses helper |
| 7 | Behavior rules trim + vocabulary + mirror + version bump + size verify | Cut shared rules; purge operator/human; mirror; ≤ 95 lines | All checks pass |
