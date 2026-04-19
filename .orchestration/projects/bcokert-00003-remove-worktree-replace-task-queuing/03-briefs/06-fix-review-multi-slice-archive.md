---
type: brief
slice: 06
project: bcokert-00003-remove-worktree-replace-task-queuing
date: 2026-04-19
---

# Delegation brief — slice 06: fix /review — route by slice state, not project stage

**Type:** Task (AI agent)
**Date:** 2026-04-19

---

### 1. Intent

`/review` currently finds work by scanning `status.md` files for `stage: signoff_review`. That field is stale or wrong enough to be untrustworthy — we've been burned by it. The fix: route by scanning slice files for `status: signoff_review` instead. Archive only when every slice file is `status: done`. The `stage` field in `status.md` is never read for routing (it may still be written to the transitions log; cleanup is slice 07).

---

### 2. Observable outcomes

**Happy path — discovery:**
```
Given slice files in .orchestration/projects/*/02-slices/*.md
When one slice has status: signoff_review
Then /review uses that slice without reading status.md stage field
```

**Happy path — no signoff work:**
```
Given no slice files with status: signoff_review
When /review runs
Then output: "No slices awaiting signoff. Run /implement to execute tasks, or /plan-project to start a new project."
```

**Happy path — multiple signoff slices:**
```
Given two slices across any projects with status: signoff_review
When /review runs
Then lists both and prompts user to select one
```

**Happy path — with project ID arg:**
```
Given /review bcokert-00003-...
When the named project has one slice with status: signoff_review
Then /review uses that slice
```

**Happy path — more slices remaining after approval:**
```
Given a project with 7 slices where slice 06 is approved and slice 07 is status: draft
When slice 06 is approved
Then /review does NOT archive, outputs: "Slice 06 done — 1 slice remaining. Run /plan-project or /implement to continue."
```

**Happy path — all slices done after approval:**
```
Given a project where the approved slice is the last non-done slice
When slice is approved
Then archive proceeds as normal
```

**Edge — unreadable slice file:**
```
Given one slice file cannot be read after approval
Then log a warning, treat that slice as not-done, do not archive
```

**Edge — project ID arg, no signoff slice found:**
```
Given /review {id} where that project has no signoff_review slice
Then output: "No slices awaiting signoff in {id}. Run /implement to continue."
```

---

### 3. Constraints

**Must:**
- Replace the status.md `stage: signoff_review` scan in Phase 0 Step 1 with a slice file scan (`02-slices/*.md` frontmatter `status: signoff_review`).
- Remove Step 2 (wrong-command routing table) — it's predicated on reading status.md stage and has no equivalent in the new model. Replace with: if no matching slice found, print the appropriate "no work" message and stop.
- After approval (Phase 1), check archive eligibility by reading all slice files in the project and checking `status`. Archive only if all are `done`. If any are not `done`: output the "N slices remaining" message and stop before the archive step.
- When a project ID is passed as argument: find the `signoff_review` slice within that project's `02-slices/` directory, not from status.md.
- Bump `defaults/commands/review.md` version: 1.2.0 → 1.3.0.
- Sync `.claude/commands/review.md` from defaults after editing.
- Do not commit anything.

**Must not:**
- Read `status.md` `stage` field for any routing decision.
- Change the commit format, archive path structure, feedback path, or the transitions log write behavior.
- Remove writing to the transitions log in status.md — that stays until slice 07.

**Preferences:**
- The "N slices remaining" message counts only slices that are not `status: done`. Draft, spec_ready, in_progress, and signoff_review all count as remaining.
- Keep Phase 1 (approve path) and Phase 2 (feedback path) structurally intact — only the routing entry and archive eligibility check change.

**Escalation triggers:**
- If the archive eligibility check requires reading many files and the logic is non-trivial — write it as a clean sequential check (read each slice file, collect statuses, count non-done). Do not try to be clever.

---

### 4. Done definition

- `defaults/commands/review.md` Phase 0 Step 1 scans slice files, not status.md stage.
- Wrong-command routing table (old Step 2) is gone.
- Phase 1 archive step is gated on all-slices-done check.
- Project ID arg routes by slice files.
- Version is 1.3.0.
- `.claude/commands/review.md` matches defaults.

**Test vectors:**
```
grep "stage: signoff_review" defaults/commands/review.md
→ no output (the stage field must not be used for routing)

grep "status: signoff_review" defaults/commands/review.md
→ at least one match (the new routing mechanism)

grep "slices remaining" defaults/commands/review.md
→ one match (the partial-archive guard message)

grep "^version:" defaults/commands/review.md
→ version: 1.3.0

diff defaults/commands/review.md .claude/commands/review.md
→ no output
```

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Edit `defaults/commands/review.md` — Phase 0 Step 1 | Scan slice files for `status: signoff_review`; remove wrong-command routing table; add "no work" fallback | `grep "status: signoff_review" defaults/commands/review.md` → match; `grep "stage: signoff_review"` → no match |
| 2 | Edit Phase 1 approve path — archive eligibility | After approval, read all slice files, check `status`; archive only if all done; otherwise print "N slices remaining" message | `grep "slices remaining" defaults/commands/review.md` → match |
| 3 | Bump version and sync | `version: 1.3.0` in defaults; `.claude/commands/review.md` copied from defaults | `grep "^version:" defaults/commands/review.md` → 1.3.0; diff → no output |
