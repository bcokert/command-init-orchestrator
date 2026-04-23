---
type: brief
slice: 05
project: bcokert-00001-orchestrator-bug-fixes
date: 2026-04-23
---

# Delegation brief — Slice 05: review.md fixes

**Type:** Task (AI agent)
**Date:** 2026-04-23

---

### 1. Intent

`defaults/commands/review.md` has two bugs. Both are in `defaults/commands/review.md` and must be synced to `.claude/commands/review.md` afterward.

**Bug 1 — `git add -A` footgun.** Phase 1 "On approval" step 2 runs `git add -A` from the project root. This stages every untracked file in the working tree — `.env`, build artifacts, temp files, unrelated in-progress work. The commit is supposed to capture the execution pipeline's output: orchestration artifacts under `.orchestration/projects/{id}/` and implementation files changed during the slice. Everything else is noise at best and a data leak at worst.

Fix: Replace `git add -A` with a targeted staging approach:
1. Run `git status --porcelain` to get the list of changed and untracked files.
2. Always stage `.orchestration/projects/{id}/` with `git add .orchestration/projects/{id}/`.
3. Stage any tracked modified files outside `.orchestration/projects/{id}/` (status `M` in git porcelain output) automatically — these are implementation files changed during the slice.
4. For any untracked files (`?` status) outside `.orchestration/projects/{id}/`: prompt the user before staging. "Found untracked file outside orchestration path: {file}. Include in commit? (yes/no)". If no: skip. If yes: stage.
5. Show a one-line summary of what will be staged before running `git commit`. Format: "Staging: {N} orchestration files, {N} source files" (plus any user-confirmed untracked files).

For planning-only slices (no source files changed), step 3 produces nothing — auto-staging `.orchestration/projects/{id}/` is sufficient and safe.

**Bug 2 — Feedback path dead end.** Phase 2 "Feedback path" creates new draft slice files and outputs "Run /plan-project to review and spec the next slice." But the original slice stays at `signoff_review`. When the user runs `/plan-project`, Phase 0 routing finds the `signoff_review` slice and blocks: "Slice {NN} is awaiting signoff — run /review to approve or provide feedback." The user has no guidance on how to break out.

The correct sequence: after giving feedback, the user should run `/review` again on the same slice. This time they approve it — not because everything is perfect, but because the slice's implementation is accepted and the feedback has been captured in the new draft slices. Approving commits the current slice's work. Then `/plan-project` can pick up the feedback slices.

Fix: Update the Phase 2 output to explain this:
- State that the original slice ({NN}) is still at `signoff_review`.
- State that the feedback has been captured in new draft slices at [paths].
- State that the user must run `/review` again on slice {NN} to approve and commit its implementation. The feedback is carried forward in the new slices — approval means "implementation accepted, changes captured."
- After approval, run `/plan-project` to advance the feedback slices.

---

### 2. Observable outcomes

**Bug 1 — Smart staging**

```
Given defaults/commands/review.md Phase 1 approval step 2
When reading the commit instructions
Then: no `git add -A` present
  AND .orchestration/projects/{id}/ is always staged
  AND modified tracked files outside that path are staged automatically
  AND untracked files outside that path trigger a per-file prompt
  AND a staging summary is shown before git commit runs
```

```
Given a planning-only slice (no source files changed)
When the approval commit runs
Then only .orchestration/projects/{id}/ is staged — no prompt for unrelated files
```

**Bug 2 — Feedback path guidance**

```
Given defaults/commands/review.md Phase 2 output section
When reading the output template
Then: it states the original slice stays at signoff_review
  AND it states the user must run /review again to approve the slice
  AND it explains approval means "implementation accepted, feedback captured"
  AND it lists the new draft slice paths
  AND it ends with: after approval, run /plan-project to advance feedback slices
```

---

### 3. Constraints

**Must:**
- Replace `git add -A` with the 5-step targeted staging approach described above.
- Show a staging summary before committing.
- For untracked files outside known paths: prompt per-file, not as a batch.
- Update Phase 2 output to include all four guidance points.
- Sync to `.claude/commands/review.md` after changes.
- Bump `version:` in frontmatter (minor bump — behavior change).

**Must not:**
- Change the archive logic (Phase 1 steps 3–7).
- Change Phase 0 (slice detection).
- Change Phase 2 slice file creation logic — only the output text changes.
- Change the behavior rule "The approve commit includes everything uncommitted on main — implementation files, task status files, QA report, slice status." The rule remains accurate; the fix is how staging is done, not what's committed.

**Preferences:**
- Keep the staging summary terse: one line, counts only.
- For the feedback path output: plain, direct prose — no numbered steps. State the situation and the required actions clearly.

**Escalation triggers:**
- The fix requires distinguishing "implementation files for this slice" from "all other modified files" by something other than tracked-vs-untracked status — stop and ask how to handle it.

---

### 4. Done definition

1. Read Phase 1 approval step 2 of `defaults/commands/review.md` — `git add -A` is absent.
2. Read the same section — `.orchestration/projects/{id}/` is staged unconditionally, tracked modified files outside that path are staged automatically, untracked outside that path trigger a prompt, staging summary shown before commit.
3. Read Phase 2 output section — it contains: "still at signoff_review", "run /review again", "implementation accepted, feedback captured", new slice paths, "run /plan-project after approval."
4. `grep "add -A" defaults/commands/review.md` — no output.
5. `grep "^version:" defaults/commands/review.md` — higher than `1.4.1`.
6. `diff defaults/commands/review.md .claude/commands/review.md` — no output.

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Replace `git add -A` with targeted staging in Phase 1 approval step 2 | Updated Phase 1 commit block | No `git add -A`; staged paths and prompt logic present; staging summary before commit |
| 2 | Update Phase 2 feedback output to explain signoff_review state and required next steps | Updated Phase 2 output section | Output contains all four guidance points; new slice paths listed |
| 3 | Bump version and sync to .claude/commands/ | Bumped frontmatter; .claude copy identical | `grep "^version:"` > 1.4.1; diff clean |
