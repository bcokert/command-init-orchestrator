---
spec: specs/briefs/project-sequencing-and-status/10-init-and-education-audit.md
slice: 10
step: 1
title: Audit and update init-orchestrator
status: todo
depends_on: []
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Read the current `init-orchestrator` script/command. Update it to install the 4-command structure:

**Commands to install:** `design.md`, `implement.md`, `review.md`, `status.md` → `.claude/commands/`

**Commands to detect and warn about (old 7-command surface):** `pipeline.md`, `qa.md`, `breakdown.md`, `slice.md`, `spec.md`, `commit.md`, `learn.md`, `migrate.md`

**Install behavior:**
- On fresh install: install all 4 commands, create `.orchestration/projects/`, add `.orchestration/worktrees/` to `.gitignore`
- On re-run: check each component; install only what's missing; never overwrite `status.md` or slice files; report what was added vs already present
- If old commands detected: list them and ask for confirmation before removing

**Idempotency check:** running twice must produce identical state.

## Done signal

Fresh install produces all 4 commands and correct folder structure. Re-run is safe and reports correctly. Old commands prompt before removal. `.orchestration/worktrees/` present in `.gitignore` after install.
