# Brief 06 — /review batch rewrite

**Type:** Task (AI agent)
**Date:** 2026-05-06

## 1. Intent

`/review` (171 lines) handles one slice per run, prompts per-untracked-file during commit, and archives after every slice. The user reviews all implemented code per project at once. This slice rewrites /review to batch all signoff slices in a project, auto-stage with a summary line, archive only on full completion, and cut ~54% of the file.

state_machine: true

## 2. Observable outcomes

```
Given /review before this slice
When the user runs it with no arg and one project has multiple signoff slices
Then it auto-picks that project and iterates every signoff slice in order
```

```
Given /review before this slice
When the user runs it with no arg and multiple projects have signoff slices
Then it prompts at the project level (not slice level), then iterates the chosen project
```

```
Given /review before this slice
When approving a signoff slice
Then the commit auto-stages tracked-modified and untracked files outside .orchestration/ with a single summary line ("Staging: N orchestration, M source, K untracked")
```

```
Given /review before this slice
When the user types an ambiguous response on a signoff slice
Then /review re-asks once on the same slice; if still ambiguous, defaults to feedback (recoverable)
```

```
Given /review before this slice
When the user gives feedback on a slice mid-batch
Then dot-notation draft slices are written with follow_up_of: NN; the batch continues to the next signoff slice; no pause for /plan-project
```

```
Given /review before this slice
When the batch ends
Then archive runs only if all original slices reached done AND no draft slices were created from feedback
```

```
Given /review after this slice
When the file is counted
Then ≤ ~78 lines (from 171); per-file untracked prompt gone; archive eligibility check fires once at end-of-batch
```

## 3. Constraints

**Must:**
- One /review run = one project. Project-level prompt only when multiple projects have signoff slices.
- Status writes use status-write.md helper.
- Auto-stage modified-tracked (M / MM) and untracked (??) files outside .orchestration/{id}/ with a single summary line.
- Per-slice approve commit: "Slice {NN} complete — {project_id}". One commit per approved slice.
- Feedback creates dot-notation draft slices with follow_up_of: NN; batch continues.
- Ambiguous: re-ask once, default to feedback if still unclear.
- Archive eligibility check at end-of-batch only.
- Trim Behavior rules; link shared rules.
- Mirror to `.claude/commands/review.md`. Bump version (minor).

**Must not:**
- Approve as a default on ambiguity (feedback errs to safe side).
- Fail silently on archive target collision — stop with manual-resolve message.
- Lose the "approval means current implementation is accepted, not that everything is perfect" framing.

**Preferences:**
- Drop verbose quoted output templates.

**Escalation triggers:**
- Archive target collision; surprising untracked-file count in summary (user can abort commit).

## 4. Done definition

- `defaults/commands/review.md` line count ≤ 78.
- `.claude/commands/review.md` matches defaults.
- `grep -n 'Found untracked file' defaults/commands/review.md` returns no matches.
- Per-slice prompt accepts approve / feedback / ambiguous; ambiguous re-asks once.
- Archive logic fires only when count of remaining-non-done slices is 0 AND no follow_up_of: drafts exist from this batch.

## 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Confirm state-diagram alignment for review | If drift, update; record confirmation | Diagram matches slice contracts |
| 2 | Phase 0 rewrite | next-actions.md filtered to signoff_review; project-level prompt only | Phase 0 ≤ ~10 lines |
| 3 | Replace per-untracked-file prompt with auto-stage + summary | Single summary line; user can abort | grep clean |
| 4 | Mixed-response handling | Re-ask once on ambiguity; default to feedback | Verified by reading Phase 1 |
| 5 | Feedback continues batch | Dot-notation drafts; no pause; batch moves to next signoff slice | Verified by reading Phase 2 |
| 6 | Archive at end-of-batch | Single archive check; conditions: all original done AND no follow_up_of drafts created | Verified by reading post-loop logic |
| 7 | Status-write migration + Behavior rules trim + vocabulary + mirror + version bump + size verify | Helper used; rules trimmed; "user" canonical; ≤ 78 lines | All checks pass |
