---
spec: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/03-briefs/03-claude-md-defaults-readme.md
slice: 03
step: 2
title: Rewrite defaults/README.md
status: done
depends_on: [01-write-claude-md.md]
agent_type: architect
assigned_at: 2026-04-14T10:39:00-07:00
completed_at: 2026-04-14T10:41:00-07:00
qa_result: null
---

Rewrite `defaults/README.md` from scratch. The current content is entirely wrong — it references old commands (`/pipeline`, `/migrate`, `/breakdown`), old folder structure (`dashboard/`, `specs/`, `config.yaml`), and old agent files. Do not salvage any of it.

Before writing, verify the actual `.orchestration/` structure by reading the current directory layout. The folder layout section must match reality.

Required sections:
1. Commands table — `/design`, `/implement`, `/review`, `/status` with one-line descriptions
2. Stage reference list — all stages from `design_in_progress` through `done`
3. Folder layout — `.orchestration/` tree matching the current system

Max 60 lines. No motivation, no pitch — this is a reference for people already running the system.

Done signal: file ≤ 60 lines, commands table present with all 4 commands, stage list present, folder layout matches actual `.orchestration/` structure, zero references to old command names.
