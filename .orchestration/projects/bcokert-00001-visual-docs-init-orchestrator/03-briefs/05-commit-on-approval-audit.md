---
type: brief
slice: 05
project: bcokert-00001-visual-docs-init-orchestrator
spec: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/02-slices/05-commit-on-approval-audit.md
design: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/01-design/design-01.md
date: 2026-04-15
---

# Delegation brief — Slice 05: Commit-on-approval audit

**Type:** Task (AI agent)
**Date:** 2026-04-15

---

## 1. Intent

The orchestration system has a clear commit rule: commits happen only when a human approves at a gate. The four gates are: approve design, approve slices, approve spec, and `/review` approve. Between gates, nothing is committed — all changes sit uncommitted so the human can review a clean diff.

The commands (`design.md`, `implement.md`, `review.md`) were written iteratively and may not consistently enforce this. This slice audits all three, finds any commits that happen outside of gates, and fixes them. The test is simple: trace every `git commit` or `git push` instruction in each command and verify it sits inside an approval gate, not mid-stage logic.

The correct gates and their commit scope:

| Gate | What's committed |
|------|-----------------|
| Design approved (human re-runs /design after design_review) | design doc + status.md |
| Slices approved (human re-runs /design after slicing_review) | slice files + status.md |
| Spec approved (human re-runs /design after spec_review) | brief + slice frontmatter + status.md |
| Breakdown complete (end of /design pipeline) | task files + slice frontmatter + status.md |
| `/review` approve | everything uncommitted in worktree, then orchestration state files |

Nothing is committed during: design interview, slicing execution, spec writing, breakdown execution, task execution, QA.

---

## 2. Observable outcomes

**No mid-stage commits in design.md**
```
Given an agent runs through slicing_in_progress
When slicing completes and status advances to slicing_review
Then no git commit has run — changes are staged only if slicing_review is entered
     from a prior approval (i.e., the human just re-ran /design)
```

**No commits in implement.md**
```
Given an agent runs all tasks and QA passes
When signoff_review is written to status.md
Then git status in the worktree shows uncommitted changes — nothing was committed
     during task execution or QA
```

**Review.md commit is the single commit for the execution pipeline**
```
Given /review is run with approval
When the commit runs
Then it includes: implementation files, task status updates, QA report,
     slice status change, status.md — all in one commit
```

---

## 3. Constraints

**Must:**
- Audit `defaults/commands/design.md`, `defaults/commands/implement.md`, `defaults/commands/review.md`
- Identify every `git add`, `git commit`, `git push` instruction in each command
- Verify each one sits at the correct gate (or is part of a gate transition triggered by human re-run)
- Fix any that don't — remove mid-stage commits, move deferred ones to the right gate
- Apply the same fixes to the matching `.claude/commands/` local copies
- Document what was changed (or "no deviations found") in the QA report

**Must not:**
- Remove commits that belong at gates — only remove commits that happen mid-stage without human approval
- Change what gets committed at each gate, only when

**Preferences:**
- If a commit instruction is in the right place but the surrounding prose is misleading (e.g., says "commit now" when it should say "commit after human re-runs"), fix the prose too
- Keep the audit findings brief in the QA report — one line per command: "design.md: N issues found and fixed" or "implement.md: no deviations"

**Escalation triggers:**
- If a commit pattern is ambiguous (could be mid-stage or gate depending on flow) — document the ambiguity and ask before removing it

---

## 4. Done definition

1. `defaults/commands/design.md` has no `git commit` instructions outside of gate transition blocks
2. `defaults/commands/implement.md` has no `git commit` or `git push` instructions anywhere
3. `defaults/commands/review.md` commit instructions are only in the approve path, covering the full diff
4. `.claude/commands/` copies match
5. QA report documents findings for each of the 3 commands

---

## 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Audit `defaults/commands/design.md` for commit behavior | List of all git commit/push calls and their gate alignment | Documented in working notes |
| 2 | Fix any deviations in `design.md` + sync `.claude/commands/design.md` | Corrected files | No mid-stage commits remain |
| 3 | Audit and fix `defaults/commands/implement.md` + sync local copy | Zero git commit/push instructions | grep confirms 0 matches |
| 4 | Audit `defaults/commands/review.md` — verify commit covers full diff | Correct commit scope | No cherry-picking, full worktree included |
