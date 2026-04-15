---
spec: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/03-briefs/03-claude-md-defaults-readme.md
slice: 03
step: 1
title: Write CLAUDE.md
status: done
depends_on: []
agent_type: architect
assigned_at: 2026-04-14T10:37:00-07:00
completed_at: 2026-04-14T10:39:00-07:00
qa_result: null
---

Write `/CLAUDE.md` at the repo root. It must cover all 4 required topics: (1) two command file locations — `.claude/commands/` is the local install, `defaults/commands/` is the source shipped to users; (2) diagram sync obligation when modifying defaults/ that affects flow, stages, or terminology; (3) .d2 files are source of truth for diagrams, SVGs are derived artifacts; (4) syncing `.claude/commands/` when defaults/commands/ changes so local dogfooding stays current.

Max 40 lines. Tight and actionable — agents read this before starting work.

Done signal: file exists at `/CLAUDE.md`, ≤ 40 lines, all 4 topics present.
