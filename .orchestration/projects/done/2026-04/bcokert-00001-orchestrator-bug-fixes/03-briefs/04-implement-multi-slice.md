---
type: brief
slice: 04
project: bcokert-00001-orchestrator-bug-fixes
date: 2026-04-23
---

# Delegation brief — Slice 04: implement multi-slice behavior

**Type:** Task (AI agent)
**Date:** 2026-04-23

---

### 1. Intent

`defaults/commands/implement.md` has a behavioral mismatch between what it shows and what it does. Phase 1 displays ALL `tasks_ready` slices across all projects — total task count, full agent team roster — strongly implying everything will run. Phase 0 then selects only one slice. Phase 2 executes that one slice. Phase 3 QAs it, leaves it at `signoff_review`, and stops.

The fix: implement.md should process all `tasks_ready` slices in sequence, stopping only when every one reaches `signoff_review`. The user controls scope at plan-project time — if they want a single slice run, they only break down one slice before running `/implement`. If they broke down five slices, all five run.

The changes are to `defaults/commands/implement.md`. Sync to `.claude/commands/implement.md` afterward.

**What changes:**

**Phase 0 Step 1:** Currently ends with "Select the first unblocked candidate — this determines `{id}` and `{NN}`." Change to: collect ALL unblocked candidates into an ordered execution list. The first item in the list is the active slice for the current Phase 2–3 cycle. Step 3 routing applies to the active slice.

**Phase 3 (QA and signoff):** After QA passes and the slice reaches `signoff_review`, check whether there are more slices in the execution list that are still at `tasks_ready` (or `implementing` from a crash resume). If yes: advance to the next slice — go back to Phase 2 for it. If no: all slices are at `signoff_review`, output a summary and stop.

**Phase 1 display:** Already shows the full picture (all tasks_ready work). Adjust the gate text so it matches the new behavior: "begin" starts all slices in sequence, not just one. The display is already accurate; the summary line just needs to drop the implied "first" framing.

**Crash resume within a multi-slice run:**
- A slice at `implementing` on entry: resume it as the active slice (existing Step 3 logic — unchanged).
- A slice at `signoff_review` on entry: already done, skip it in the execution list.
- A slice at `tasks_ready`: in queue, not started.
- After the active slice finishes, the loop re-evaluates the execution list from disk (not from memory) to pick the next one.

All changes stay in `defaults/commands/implement.md`. No changes to `qa.md`, `plan-project.md`, or `review.md`.

---

### 2. Observable outcomes

**Multi-slice execution**

```
Given implement.md with 3 tasks_ready slices in scope
When Phase 0 runs queue selection
Then the execution list contains all 3 slices (not just slice 01)
```

```
Given implement.md after slice 01 reaches signoff_review
When Phase 3 completes
Then implementation continues to slice 02 (Phase 2 starts for slice 02)
  AND stops only after all 3 slices are at signoff_review
```

**Phase 1 display accuracy**

```
Given implement.md Phase 1 gate text
When reading it
Then it says all queued slices will run (not "the next slice")
  AND the "review more slices first" escape still works
```

**Crash resume — multi-slice**

```
Given a run where slices 01 and 02 are at signoff_review, slice 03 is at implementing
When implement.md starts
Then slices 01 and 02 are skipped
  AND slice 03 is resumed at Phase 2
```

```
Given a run where slice 01 is at signoff_review, slice 02 is at tasks_ready
When implement.md starts
Then slice 01 is skipped
  AND slice 02 is the active slice — Phase 2 starts for it
```

---

### 3. Constraints

**Must:**
- Process all tasks_ready slices in sequence, not just one.
- Respect per-project slice ordering (already enforced in Step 5 — unchanged).
- After each slice reaches signoff_review, re-read slice states from disk before selecting the next active slice. Never use in-memory state.
- Crash resume: a slice at `implementing` is resumed; a slice at `signoff_review` is skipped.
- Sync to `.claude/commands/implement.md` after changes.
- Bump `version:` in frontmatter (minor bump — behavior change).

**Must not:**
- Change QA behavior (`qa.md` is unchanged).
- Change Phase 2 task execution logic — only the loop wrapping it changes.
- Run slices in parallel — v1 is sequential only (existing rule, unchanged).
- Change the `signoff_review` stop point — each slice still stops at signoff_review, waiting for `/review`. The loop just picks up the next slice after that.

**Preferences:**
- Describe the multi-slice loop in Phase 3 as: "if more slices remain in the execution list, advance to the next — return to Phase 2." One short paragraph is enough.
- Keep the execution list derivation close to where Phase 0 Step 1 currently ends — don't restructure the phase.

**Escalation triggers:**
- The fix requires changing Phase 2 task execution logic (not just the loop around it) — stop and ask.
- The fix requires changing `qa.md` — stop and ask.

---

### 4. Done definition

1. Read Phase 0 Step 1 of `defaults/commands/implement.md` — it describes collecting ALL unblocked candidates into an execution list, not selecting a single one.
2. Read Phase 3 of `defaults/commands/implement.md` — after QA pass, it checks for remaining slices in the execution list and loops back to Phase 2 if any exist.
3. Read Phase 1 gate text — no longer implies "the next slice" runs alone.
4. Read Phase 0 Step 3 crash resume — `signoff_review` slices are explicitly skipped in the execution list.
5. `grep "^version:" defaults/commands/implement.md` — higher than `2.6.0`.
6. `diff defaults/commands/implement.md .claude/commands/implement.md` — no output.

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Update Phase 0 Step 1 — collect all unblocked candidates into an execution list instead of selecting one | Updated Step 1 text | Step 1 describes a list, not a single selection |
| 2 | Update Phase 0 Step 3 — add `signoff_review` to the "skip" routing; clarify routing applies to the active slice | Updated Step 3 routing table | `signoff_review` row skips to next slice in list |
| 3 | Update Phase 3 — after QA pass, loop to next slice in execution list or stop if list is exhausted | Updated Phase 3 QA pass handling | Phase 3 describes the loop; stops after all signoff_review |
| 4 | Update Phase 1 gate text — remove single-slice framing | Updated Phase 1 gate | No "first" or "the next slice" language implying single-run |
| 5 | Bump version and sync to .claude/commands/ | Bumped frontmatter; .claude copy identical | `grep "^version:"` > 2.6.0; diff clean |
