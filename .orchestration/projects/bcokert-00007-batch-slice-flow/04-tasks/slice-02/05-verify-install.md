---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/02-shared-support-files.md
slice: 02
step: 5
title: Verify install of new support files
status: done
depends_on: [04-update-init-orchestrator.md]
agent_type: quality
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Run `/init-orchestrator` against a sandbox checkout (or simulate the install loop). Confirm the three new files land at `.orchestration/support/{next-actions,status-write,bdonize}.md`.

**Done signal:** All three files present at the expected paths.
