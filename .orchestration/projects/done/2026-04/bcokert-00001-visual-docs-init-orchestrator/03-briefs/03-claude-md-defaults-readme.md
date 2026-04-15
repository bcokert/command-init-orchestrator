---
type: brief
slice: 03
project: bcokert-00001-visual-docs-init-orchestrator
spec: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/02-slices/03-claude-md-defaults-readme.md
design: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/01-design/design-01.md
date: 2026-04-14
---

# Delegation brief — Slice 03: CLAUDE.md + defaults/README.md

**Type:** Task (AI agent)
**Date:** 2026-04-14

---

## 1. Intent

This is one of several slices rewriting the docs for `command-init-orchestrator` — a 4-command Claude Code orchestration system (`/design`, `/implement`, `/review`, `/status`). Slices 01 and 02 rewrote the GitHub README and added diagrams. This slice creates two remaining files:

**CLAUDE.md** — repo-root context file for any agent working in this repo. Its job is to make sure agents working on command files know the diagram sync obligation and understand the two-set command architecture. Without it, someone ships a flow change to `defaults/commands/` without updating the diagrams, and the docs silently drift.

**defaults/README.md** — a short installed reference guide that gets copied into `.orchestration/README.md` when someone runs `/init-orchestrator`. Its audience is someone already running the system who wants a quick lookup. The current version is completely wrong — it references old commands (`/pipeline`, `/migrate`, `/breakdown`, agents in `.claude/agents/`, a `dashboard/` folder) that don't exist in the current system. It needs to be rewritten from scratch.

Neither file has any dependency on the other. Either can be implemented first.

---

## 2. Observable outcomes

**CLAUDE.md**
```
Given an agent is about to edit defaults/commands/design.md to add a new stage
When the agent reads CLAUDE.md
Then the agent knows: (a) that this change may affect the lifecycle diagram and artifacts diagram, (b) that .d2 files are source of truth and SVGs are derived, (c) that .claude/commands/ is the local install and defaults/commands/ is the source shipped to users, and (d) that changing defaults/ requires syncing .claude/ if the change should apply locally too
```

**defaults/README.md**
```
Given a developer has just run /init-orchestrator in a new repo
When they open .orchestration/README.md
Then they see: a commands table (/design, /implement, /review, /status), a stage reference list, and the .orchestration/ folder layout — all matching the current system, no references to old commands
```

```
Given the current .orchestration/ layout has: projects/{id}/{01-design,02-slices,03-briefs,04-tasks,05-qa}/, worktrees/, and projects/done/
When the file layout section is read
Then it accurately reflects this structure, not the old one with dashboard/, specs/, config.yaml, etc.
```

---

## 3. Constraints

**Must:**
- CLAUDE.md written at repo root (`/CLAUDE.md`)
- CLAUDE.md covers: two-set command architecture, diagram sync obligation, .d2 as source of truth, SVGs are derived (regenerate from source), syncing .claude/commands/ when defaults/commands/ changes
- CLAUDE.md is tight and actionable — max ~40 lines. Agents don't read long preambles
- `defaults/README.md` is a complete rewrite — do not attempt to salvage existing content
- `defaults/README.md` is ~50 lines, hard cap 60
- `defaults/README.md` contains: commands table, stage reference list, .orchestration/ folder layout
- `defaults/README.md` folder layout must reflect the current system — verify against the actual directory structure before writing (check what exists under `.orchestration/`)
- No motivation or pitch in `defaults/README.md` — that's the GitHub README's job
- No references to old command names: `/pipeline`, `/migrate`, `/breakdown`, `/commit`, `/learn`, `/qa` (as user command)

**Must not:**
- Duplicate the GitHub README — `defaults/README.md` is a reference, not a pitch
- Make CLAUDE.md so long that agents skip it — this is the primary risk
- Add any instructions to CLAUDE.md that belong in a per-project CLAUDE.md (e.g., project-specific conventions). Repo-level only.

**Preferences:**
- CLAUDE.md: sentence case headings, terse fragments, direct imperatives
- `defaults/README.md`: table for commands, brief bullets for stages, code block for folder layout
- Both files: Bdonizer register — direct, dry, no inflation

**Escalation triggers:**
- If the current `.orchestration/` layout doesn't match what the design doc describes — stop and report the discrepancy rather than guessing

---

## 4. Done definition

1. `/CLAUDE.md` exists at repo root
2. `/CLAUDE.md` mentions: two command file locations (`.claude/commands/` and `defaults/commands/`), diagram sync obligation, .d2 as source of truth, SVG regeneration
3. `/CLAUDE.md` is ≤ 40 lines
4. `defaults/README.md` exists and is ≤ 60 lines
5. `defaults/README.md` contains a commands table with `/design`, `/implement`, `/review`, `/status`
6. `defaults/README.md` contains a stage reference list covering at least: `design_in_progress`, `design_review`, `slicing_*`, `spec_*`, `tasks_ready`, `implementing`, `signoff_review`, `feedback_pending`, `done`
7. `defaults/README.md` contains a folder layout section that matches the actual current `.orchestration/` structure
8. `defaults/README.md` contains zero references to old command names (`/pipeline`, `/migrate`, `/breakdown`, `dashboard/`, `specs/`, `config.yaml`)
9. Both files pass a "would an agent actually read this" sniff test — nothing bloated, nothing vague

---

## 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Write CLAUDE.md | `/CLAUDE.md` at repo root | File exists, ≤ 40 lines, covers all 4 required topics |
| 2 | Rewrite defaults/README.md | `defaults/README.md` | File ≤ 60 lines, commands table present, stage list present, folder layout matches current .orchestration/ structure, no old command names |
