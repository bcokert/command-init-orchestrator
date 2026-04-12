---
type: slice
slice: 08
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
status: signoff_review
---

# Slice 08 — `/status` v2: multi-project + worktree-aware

**Goal:** `/status` with no argument shows all non-done projects across main and active worktrees — stage, slice progress, worktree if present, next action, time in current stage.

## Happy path

- No-arg `/status` → `git worktree list` run → all non-done projects read from correct paths → summary table: project ID, stage, slice progress, worktree, next action, elapsed time
- Projects in `*_review` stage: reminder below table of which command unblocks them
- Done projects excluded, except show a list of projects done this week grouped by user (the part of the slug) as a quick recap of recent changes.

## Edge cases

- Worktree registered in git but directory missing (manually deleted): warn "run `git worktree prune`", other projects still display correctly
- Worktree `status.md` diverged from main: worktree version is authoritative
- Zero active projects: "no active projects — run `/design` to start one"
