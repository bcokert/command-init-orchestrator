---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/09-init-orchestrator-and-config-cleanup.md
slice: 09
step: 2
title: Collapse three install loops into one parameterised loop
status: todo
depends_on: [01-audit-and-delete-config-yaml.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

Refactor `init-orchestrator.md` Phase 2 — combine the three near-identical install loops (commands at lines 78-83, support at 85-94, agents at 96-105) into one parameterised loop driven by a file-class table. Each class entry: source dir, target dir, file list.

**Done signal:** One loop, three classes; behavior identical to before for fresh-checkout install.
