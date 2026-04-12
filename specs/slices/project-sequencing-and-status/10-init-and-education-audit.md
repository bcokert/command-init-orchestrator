---
type: slice
slice: 10
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
status: specced
---

# Slice 10 — Init-orchestrator + README + education audit

**Depends on:** Slice 09 QA feedback must be resolved before implementing this slice. Slice 09 runs e2e against the full system — any fixes it surfaces should be applied first so this audit reflects the final state.

**Goal:** `init-orchestrator` installs the new 4-command structure correctly. README is accurate. Every command has contextual education output, especially around worktrees and parallel execution.

## Happy path

- Fresh install: all 4 commands present, old 7 commands absent, `.orchestration/projects/` created, `.orchestration/worktrees/` in `.gitignore`
- Re-run: no data loss, only missing components added
- README accurately describes the 4-command surface, lifecycle, worktree model, and slice-at-a-time approach
- Education audit: every command has stage-transition output, correct error messages, worktree explanation in `/implement`

## Edge cases

- Re-run with existing projects: must not overwrite `status.md` or slice files
- Partial install (some commands missing): detects and repairs, reports what was added
- Old command structure detected: prompts before removing, installs new ones
