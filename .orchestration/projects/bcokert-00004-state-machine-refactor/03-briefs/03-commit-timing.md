**Type:** Task (AI agent)
**Date:** 2026-04-21

---

### 1. Intent

`plan-project` currently commits at the start of each phase, which means the commit for "design approved" lands silently on the next run — disconnected from the moment of approval. The fix is to commit at approval gates: when the operator approves and re-runs the command, the commit runs immediately as part of that gate transition. This slice also adds `planIteration` staging: at the start of each iteration pass, `git add .orchestration/` moves the previous pass's artifacts to the staging area, so the unstaged diff in VS Code shows only the current iteration's new changes.

Only `defaults/commands/plan-project.md` changes. Version `2.5.0 → 2.6.0` (this is after slice 02's bump from `2.4.0`).

---

### 2. Observable outcomes

**Commit at approval — design**
```
Given plan-project showing the design review gate
When the operator approves and re-runs /plan-project
Then approveAndCommit(design) runs immediately in that run: git add design doc, git commit "Design approved — {id}"
And the design doc status is set to approved in the same run
```

**Commit at approval — slices**
```
Given plan-project showing the slicing review gate
When the operator approves slices and re-runs /plan-project
Then approveAndCommit(slices) runs: git add slice files, git commit "Slices approved — {id}"
```

**Phase-entry commits removed**
```
Given plan-project at Phase 5 entry (post-design-approval)
When it enters Phase 5 to begin slicing
Then no git add or git commit runs at entry — the commit already happened at the gate
```

**planIteration staging**
```
Given plan-project running a second iteration pass on a design or slice
When planIteration starts
Then git add .orchestration/ runs first, staging the previous iteration's artifacts
And the current iteration's changes remain unstaged (visible in VS Code diff)
```

**Code file detection**
```
Given code files appearing unstaged during planIteration staging
When git add .orchestration/ is about to run
Then the agent surfaces the unexpected files and asks for confirmation before staging
```

**Crash resume**
```
Given plan-project re-entering after a crash mid-iteration (artifacts exist but status is mid-state)
When it re-enters
Then it reads status from disk and routes correctly without attempting a redundant commit
```

---

### 3. Constraints

**Must:**
- First task: read `.root-context/state-diagram.md` and confirm the commit-at-approval behavior described there matches what's being implemented. Note any discrepancy; update diagram if found.
- Remove `git add` / `git commit` blocks from Phase 5 "On entry", Phase 6 "On entry", and Phase 7 "On entry" sections. These commits now happen at the approval gate, not at the next entry.
- Add `approveAndCommit(design)` logic to Phase 4 (design review gate): when the operator approves and re-runs, run `git add .orchestration/projects/{id}/01-design/design-{NN}.md` and `git commit -m "Design approved — {id}"`, then set `design doc status: approved`.
- Add `approveAndCommit(slices)` logic to the slicing approval transition in Phase 5: when the operator approves reviewed slices and the command advances to speccing, commit the slice files first.
- Add planIteration staging: at the start of each `planIteration` call, run `git add .orchestration/` (and `.root-context/` and `CLAUDE.md` if changed). Stage previous iteration; leave current iteration's changes unstaged.
- Detect code files appearing unstaged during planIteration staging: if anything outside `.orchestration/` or known planning files appears in the unstaged list, surface it and ask before staging.
- Update description frontmatter: already updated in slice 02. Verify it still reads correctly.
- Bump version: `2.5.0 → 2.6.0`.

**Must not:**
- Add any `git push` — that was removed in slice 02 and must stay removed.
- Commit at phase entry (old behavior). All commits happen at gates.
- Touch any file outside `defaults/commands/plan-project.md`.

**Escalation triggers:**
- If the state-diagram.md check in task 1 reveals a discrepancy: report before making any changes.
- If the approval gate logic is ambiguous (e.g., the command can't distinguish "first run after approval" from "resuming after crash"): stop and report rather than guess.

---

### 4. Done definition

- Read plan-project.md: no `git add` or `git commit` in Phase 5, 6, or 7 "On entry" sections.
- Read plan-project.md: Phase 4 gate includes `approveAndCommit(design)` logic triggered on approval re-run.
- Read plan-project.md: slicing approval transition includes `approveAndCommit(slices)`.
- Read plan-project.md: planIteration description includes `git add .orchestration/` as first step, with unstaged-code-file detection.
- Version reads `2.6.0`.

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Verify state-diagram.md commit timing intent | Confirmation note (no file changes if diagram is current) | Report produced; diagram updated only if discrepancy found |
| 2 | Remove phase-entry commits from Phase 5, 6, 7 | On entry sections contain only crash-resume logic, no git operations | Read file: Phase 5/6/7 On entry has no git add or git commit |
| 3 | Add approveAndCommit to design review gate (Phase 4) | Gate logic commits design doc and sets status approved on approval re-run | Read file: Phase 4 includes approveAndCommit block with correct commit message |
| 4 | Add approveAndCommit to slicing approval transition | Slices committed before advancing to speccing | Read file: slicing approval branch includes git add slices + commit |
| 5 | Add planIteration staging + code-file detection | planIteration starts with git add; unstaged non-planning files trigger confirmation | Read file: planIteration section has staging block and detection logic |
| 6 | Version bump and coherence pass | Version `2.6.0`; full read-through for contradictions | Frontmatter reads `2.6.0`; no section still references old phase-entry commit behavior |
