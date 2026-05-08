---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/09-init-orchestrator-and-config-cleanup.md
slice: 09
step: 3
title: Add consolidated update gate
status: done
depends_on: [02-collapse-install-loops.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

On a re-run with N drifted files: surface one prompt — "{N} files would update — accept all / review per-file / skip". Default "accept all" on plain "yes". On a fresh checkout (zero existing files), skip the gate and just install with a one-line summary.

**Done signal:** Gate visible in init-orchestrator.md; three options documented; fresh-checkout path bypasses.
