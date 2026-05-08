---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/06-review-batch-rewrite.md
slice: 06
step: 3
title: Auto-stage with summary line, no per-file prompt
status: done
depends_on: [02-phase-0-rewrite.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Replace per-untracked-file prompt at Phase 1 step 2.d with auto-stage logic: stage all tracked-modified (`M` / `MM` in `git status --porcelain`) and untracked (`??`) files outside `.orchestration/{id}/`. Surface a single summary line: "Staging: N orchestration, M source, K untracked." User can abort the commit if the summary looks wrong.

**Done signal:** `grep -n 'Found untracked file' defaults/commands/review.md` returns no matches; summary line present.
