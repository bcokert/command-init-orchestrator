---
type: brief
slice: 10
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
slice_doc: specs/slices/project-sequencing-and-status/10-init-and-education-audit.md
status: ready
date: 2026-04-12
---

# Delegation brief — Slice 10: Init-orchestrator + README + education audit

## Intent

The system is complete after slice 09. This slice makes it installable and documented. Three things:

1. `init-orchestrator` installs the new 4-command structure correctly — idempotent, non-destructive on re-run, detects and warns about the old 7-command surface.
2. README accurately describes the 4-command surface, lifecycle, worktree model, and slice-at-a-time approach.
3. Every command has correct contextual education output — stage transitions say what they are, errors say what to run next, worktrees get an explanation on first use.

**Depends on slice 09 QA being resolved first.** Slice 09 runs e2e and may surface fixes. This audit should reflect the final state of the system, not an intermediate one.

## Observable outcomes

**Fresh install:**
```
Given a repo with no .claude/commands/ directory
When init-orchestrator runs
Then all 4 commands are installed: design.md, implement.md, review.md, status.md
And no old commands (pipeline.md, qa.md, breakdown.md, slice.md, spec.md, commit.md, learn.md) are present
And .orchestration/projects/ is created
And .orchestration/worktrees/ is added to .gitignore
```

**Re-run (idempotent):**
```
Given init-orchestrator has already run and projects exist
When init-orchestrator runs again
Then existing .orchestration/projects/ data is untouched
And only missing components are added
And output says what was added vs already present
```

**Old command structure detected:**
```
Given .claude/commands/ contains old 7-command files
When init-orchestrator runs
Then output lists the old commands found and asks before removing
And does not remove them without confirmation
```

**Worktree explanation on first /implement:**
```
Given a repo that has never used git worktrees
When /implement creates the first worktree
Then output explains what worktrees are and why the system uses them
```

**Wrong-command error is informative:**
```
Given a project in spec_review
When the user runs /implement
Then output names the current stage and says exactly which command to run
```

## Constraints

**Must:**
- `init-orchestrator` must be idempotent — running it twice produces the same result as running it once
- Must not overwrite existing `status.md` or slice files on re-run
- Old command detection: check for the known old filenames (pipeline.md, qa.md, breakdown.md, slice.md, spec.md, commit.md, learn.md, migrate.md) and warn before removing
- README must accurately describe the 4-command surface as implemented (not aspirational)
- Education audit: read each command file and verify every stage-transition output, every error message, and every gate output has text that tells the user what to do next

**Must not:**
- Remove old commands without explicit confirmation
- Describe features in README that aren't yet implemented (e.g. cross-project metrics dashboard)

**Preferences:**
- README: ~100 lines, practical — covers "how do I start a project", "what does each command do", "what's a worktree and why"
- Education audit: produce a short checklist of what was found and fixed, not just a pass/fail

**Escalation triggers:**
- An education gap requires changing core logic (not just output text): stop and ask before proceeding

## Done definition

1. `init-orchestrator` installs all 4 commands; re-run is safe; old commands prompt before removal
2. `.orchestration/projects/` created on install; `.orchestration/worktrees/` in `.gitignore`
3. README describes the actual 4-command surface, lifecycle, and worktree model accurately
4. Every command's stage-transition and error outputs tell the user what to do next
5. Education audit checklist committed alongside the changes

## Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Audit and update init-orchestrator | `init-orchestrator` installs 4 commands, handles re-run safely, warns on old commands | Fresh install and re-run both work correctly; old command detection present |
| 2 | Update .gitignore step | `.orchestration/worktrees/` added to .gitignore by init-orchestrator | Field present in init-orchestrator install steps |
| 3 | Write README | README.md describes 4-command surface, lifecycle, worktree model | README accurate to implemented system; no aspirational features described |
| 4 | Education audit | Read all 4 command files; verify every transition/error output has a "what to do next" | Audit checklist committed; any gaps found are fixed |
