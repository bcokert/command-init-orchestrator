---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/07-status-rewrite.md
slice: 07
step: 4
title: Behavior rules trim + mirror + version + verify
status: done
depends_on: [03-dedupe-formats.md]
agent_type: quality
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Trim Behavior rules to status-specific deltas. Mirror to `.claude/commands/status.md`. Bump version (patch — no behavior change for the user). Verify: line count ≤ 125; visual diff of `/status` output identical before/after.

**Done signal:** Both files match; ≤ 125 lines; visual diff identical.
