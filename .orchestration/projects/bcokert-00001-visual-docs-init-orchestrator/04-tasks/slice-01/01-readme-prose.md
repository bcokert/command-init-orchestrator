---
spec: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/03-briefs/01-readme-core-diagrams.md
slice: 01
step: 1
title: Write README.md prose
status: done
depends_on: []
agent_type: architect
assigned_at: 2026-04-13T12:31:00-07:00
completed_at: 2026-04-13T12:33:00-07:00
qa_result: null
---

Rewrite `README.md` in full. Replace the existing file entirely.

Structure (in order):
1. Value props section — 8 props in `**Anchor.** Sentence. Sentence.` format, exact order from the brief
2. Core concepts — slices, worktrees, human gates; brief with analogies where helpful
3. Quick start — numbered steps
4. Diagrams section — embed `docs/diagrams/happy-path.svg` and `docs/diagrams/lifecycle.svg` using markdown image syntax with descriptive alt text; SVGs don't exist yet so use the correct paths as placeholders
5. Customization note — explain `.claude/commands/` (local only) vs `defaults/commands/` (ships to users on install)

Bdonizer pass before saving: no AI vocabulary, no warmup sentences, sentence case headings, short declarative payoffs. See brief section 3 for full constraint list.

Done signal: file exists, structure matches spec order, no old command names (`/pipeline`, `/migrate`, `/breakdown`), customization section names both command directories explicitly.
