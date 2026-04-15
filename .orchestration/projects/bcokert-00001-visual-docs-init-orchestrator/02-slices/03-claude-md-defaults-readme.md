---
type: slice
slice: 03
order: 3
project: visual-docs-init-orchestrator
design: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/01-design/design-01.md
status: signoff_review
---

# Slice 03 — CLAUDE.md + defaults/README.md

**Goal:** CLAUDE.md exists at repo root with instructions for keeping diagrams and README in sync with command changes. defaults/README.md is a short (~50 line) installed reference guide — commands cheatsheet, stage list, file layout — that makes sense to someone who has already run /init-orchestrator.

## Happy path

- CLAUDE.md at repo root explains the two sets of command files (.claude/commands/ = local install, defaults/commands/ = source that ships to users), diagram sync obligation when modifying defaults, and that .d2 is source of truth for diagrams
- defaults/README.md is rewritten: commands table, stage reference list, .orchestration/ folder layout — no motivation, no pitch, no reference to old command names (/pipeline, /migrate, etc.)
- defaults/README.md is ~50 lines, no more

## Edge cases

- Independent of slices 01 and 02 — can be implemented in any order
- defaults/README.md file layout section must match the current system, not the old one — verify against actual .orchestration/ structure
- CLAUDE.md must not be so verbose that agents ignore it — keep it tight and actionable
