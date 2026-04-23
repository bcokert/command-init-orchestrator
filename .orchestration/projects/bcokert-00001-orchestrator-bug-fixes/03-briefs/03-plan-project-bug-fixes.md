---
type: brief
slice: 03
project: bcokert-00001-orchestrator-bug-fixes
date: 2026-04-23
---

# Delegation brief — Slice 03: plan-project bug fixes

**Type:** Task (AI agent)
**Date:** 2026-04-23

---

### 1. Intent

`defaults/commands/plan-project.md` has three bugs that require targeted fixes. All changes apply to `defaults/commands/plan-project.md` and must be synced to `.claude/commands/plan-project.md` afterward.

**Bug 1 — Phase 5 crash-resume gap.** Phase 0 routes to Phase 5 when "design doc exists, no slices." Phase 5 runs slicing immediately, skipping `approveAndCommit(design)`. That only lives in Phase 4's approval transition — not in Phase 5. If the process dies after Phase 4 shows the gate but before the user re-runs, the design doc stays at `status: review` and the approval commit is silently skipped.

Fix: At Phase 5 "On entry", before the crash-resume check for slice files, add: if design doc `status` is `review`, run `approveAndCommit(design)` (same logic as Phase 4's approval transition). If design doc is already `approved`, skip it.

**Bug 2 — Phase 7 premature commit.** Current Phase 7 flow: create task files → update status → commit → surface agent team → wait for confirmation. The commit fires before the user can change `agent_type` values on task files. Any edits the user makes after confirmation are not reflected in the commit.

Fix: Reorder Phase 7's "After creating all task files" steps. New order: (1) update status to `tasks_ready`, (2) surface agent team and wait for confirmation, (3) commit after confirmation, (4) output.

**Bug 3 — Bulk slicing approval doesn't trigger bulk spec+breakdown.** Phase 5 "On approval" currently sets only the approved slices to `speccing` and proceeds to Phase 6 for the first slice only. If the user approves 5 slices at once, 4 of them stay in `draft` indefinitely.

Fix: Phase 5 "On approval" must loop Phase 6+7 for every approved slice in order. Slice N must reach `tasks_ready` before slice N+1 is specced — the loop naturally satisfies this since it runs sequentially. The "run /implement" footer in Phase 7 output must be suppressed during intermediate slices; show it only after the last slice in the bulk run completes.

**Crash resume for bulk runs.** The loop must handle stopping mid-run gracefully:

- Stopped mid-loop (some slices at `tasks_ready`, remaining at `review`): Phase 0 routing already picks up the first eligible slice in `review`/`speccing`. The bulk loop must also work on re-entry — when it detects approved slices still at `review`, it continues the loop without prompting.
- State-drift — brief exists but slice still at `review`/`speccing`: Phase 6 crash resume already handles this (brief exists → skip to Phase 7). The bulk loop must invoke the same crash resume check per slice.
- State-drift — task files exist but slice at `breakdown`: Phase 7 crash resume already handles this (delete and regenerate). Same — bulk loop must invoke it.
- State-drift — brief + task files exist but slice status never reached `tasks_ready`: on entry to the bulk loop for that slice, if `03-briefs/{NN}-*.md` exists and `04-tasks/slice-{NN}/` has task files, fast-forward status to `tasks_ready` instead of re-running breakdown.

---

### 2. Observable outcomes

**Bug 1 — Phase 5 crash resume**

```
Given defaults/commands/plan-project.md Phase 5 "On entry"
When design doc status is `review`
Then approveAndCommit(design) runs before slicing begins
  AND design doc status is set to `approved`
  AND if design doc is already `approved`, approveAndCommit is skipped
```

**Bug 2 — Phase 7 commit order**

```
Given defaults/commands/plan-project.md Phase 7 "After creating all task files"
When reading the steps in order
Then: surface agent team → wait for confirmation → git commit
  AND NOT: git commit → surface agent team → wait for confirmation
```

**Bug 3 — Bulk approval loop**

```
Given defaults/commands/plan-project.md Phase 5 "On approval"
When reading the approval handling
Then it describes a loop over all approved slices, not just "proceed to Phase 6 for the first slice"
  AND the loop runs Phase 6+7 for each slice in sequence
  AND the "run /implement" footer appears only after the last slice completes
```

**Bulk crash resume**

```
Given defaults/commands/plan-project.md Phase 5 "Crash resume" and Phase 6/7 entry
When reading the crash resume logic
Then: mid-loop resume (some slices tasks_ready, rest at review) continues without prompt
  AND state-drift (brief/task files exist, status not updated) is detected and fast-forwarded
```

---

### 3. Constraints

**Must:**
- Make the three targeted fixes to `defaults/commands/plan-project.md` and nothing else.
- Sync to `.claude/commands/plan-project.md` afterward (copy).
- Bump `version:` in frontmatter (minor bump — behavior change).
- For Bug 1: the approveAndCommit guard in Phase 5 must mirror Phase 4's existing logic exactly — same git commands, same status update.
- For Bug 2: the only change to Phase 7 is reordering the four steps. No other logic changes.
- For Bug 3: all crash-resume cases for the bulk loop must be explicitly described in the updated Phase 5 text.

**Must not:**
- Reorganize Phase 4 or Phase 5 beyond the targeted fixes.
- Change Phase 6 or Phase 7 logic beyond: (a) the commit-order fix in Phase 7, and (b) ensuring Phase 6/7 crash resume checks work when called from the bulk loop.
- Modify any other command file.

**Preferences:**
- For Bug 3's bulk loop: describe it as iterating over the approved slices list in order, calling Phase 6+7 per slice. Pseudocode-style prose is fine; no need for a formal loop syntax.
- Keep the crash resume cases as a bulleted list under the bulk loop description — consistent with how other crash resume cases are documented in the file.

**Escalation triggers:**
- The approveAndCommit logic in Phase 4 and Phase 5 would diverge — they must stay identical. Stop and ask if they don't match.
- Any fix requires touching Phase 1, 2, 3, or the planIteration step — those are out of scope.

---

### 4. Done definition

1. `grep -n "status.*review.*approveAndCommit\|approveAndCommit.*design" defaults/commands/plan-project.md` — matches appear in both Phase 4 and Phase 5 entry sections.
2. Phase 7 "After creating all task files" steps read in this order: (1) update `tasks_ready`, (2) surface agent team + wait, (3) git add + commit, (4) output. Verify by reading the section.
3. Phase 5 "On approval" describes a loop over all approved slices. `grep -n "loop\|each.*slice\|all.*slices" defaults/commands/plan-project.md` returns a match in Phase 5.
4. Bulk crash resume cases are documented: mid-loop stop, state-drift brief exists, state-drift task files exist, state-drift tasks_ready not set.
5. `grep "^version:" defaults/commands/plan-project.md` — value is higher than current (check current with `head -3 defaults/commands/plan-project.md`).
6. `diff defaults/commands/plan-project.md .claude/commands/plan-project.md` — no output.

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Fix Phase 5 "On entry" — add approveAndCommit guard for design doc at `review` | Updated Phase 5 On entry section | Guard appears in Phase 5; mirrors Phase 4 logic; `approved` skips it |
| 2 | Fix Phase 7 "After creating all task files" — reorder steps so commit follows agent team confirmation | Reordered Phase 7 steps | Reading the section: surface team → wait → commit → output |
| 3 | Fix Phase 5 "On approval" — replace single-slice proceed with loop over all approved slices including bulk crash resume cases | Updated Phase 5 On approval section | Loop described; all 4 crash resume cases documented; footer suppressed on intermediate slices |
| 4 | Bump version and sync to .claude/commands/ | Updated version in frontmatter; .claude copy identical | `grep "^version:" defaults/commands/plan-project.md` is higher; diff is clean |
