---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/09-init-orchestrator-and-config-cleanup.md
slice: 09
step: 5
title: Annotate old-7-command list + version bump
status: todo
depends_on: [04-fallback-and-skip-branches.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

In `init-orchestrator.md` Phase 0 line 44, annotate the "old 7-command files" detection list to clarify the path/class distinction (some legacy names like `slice.md`, `spec.md`, `qa.md` overlap with current support file names). Add a comment noting this is checked against `.claude/commands/` only. Bump version (minor — UX change).

**Done signal:** Comment clarifies the distinction; version bumped.
