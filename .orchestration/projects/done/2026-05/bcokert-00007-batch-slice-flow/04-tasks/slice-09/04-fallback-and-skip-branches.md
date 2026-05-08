---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/09-init-orchestrator-and-config-cleanup.md
slice: 09
step: 4
title: review-per-file fallback + skip reporting + regression check
status: done
depends_on: [03-consolidated-update-gate.md]
agent_type: quality
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Implement "review per-file" branch as fallback to today's per-file flow (regression-tested behavior). Implement "skip" branch leaving the install untouched and reporting which files would have updated. Run a manual regression check on a sandbox checkout with three files at different states (missing / same version / drifted version).

**Done signal:** Both branches behave per spec; regression check passes.
