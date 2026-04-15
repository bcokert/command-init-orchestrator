---
type: brief
slice: 04
project: bcokert-00001-visual-docs-init-orchestrator
spec: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/02-slices/04-install-support-commands.md
design: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/01-design/design-01.md
date: 2026-04-15
---

# Delegation brief — Slice 04: Install support commands

**Type:** Task (AI agent)
**Date:** 2026-04-15

---

## 1. Intent

`command-init-orchestrator` is a 4-command orchestration system installed into any git repo via `/init-orchestrator`. The 4 user commands (`design.md`, `implement.md`, `review.md`, `status.md`) delegate to 3 support commands (`slice.md`, `spec.md`, `qa.md`) at runtime — they read and follow those files as sub-prompts.

The problem: `design.md` references `.claude/commands/slice.md` and `.claude/commands/spec.md`. `implement.md` references `defaults/commands/qa.md`. Neither path exists in a target project. A target project gets only the 4 user commands; it has no `defaults/` folder and the `.claude/commands/` references assume the support files were already there. So the system is broken for any project that runs `/init-orchestrator` — the first time an agent tries to read `slice.md` or `qa.md`, the file won't exist.

Fix: install `slice.md`, `spec.md`, `qa.md` to `.orchestration/support/` in the target project, and update all references to point there. `.orchestration/support/` keeps them clearly owned by the orchestrator without surfacing them as user-invokable slash commands (which `.claude/commands/` would do).

---

## 2. Observable outcomes

**Support files installed**
```
Given a user runs /init-orchestrator in a fresh repo
When installation completes
Then .orchestration/support/slice.md, .orchestration/support/spec.md,
     and .orchestration/support/qa.md all exist in the target repo
```

**References updated**
```
Given an agent runs /design in a target project
When the slicing phase executes "Read and follow .orchestration/support/slice.md"
Then the file exists and is readable — no file-not-found error
```

```
Given an agent runs /implement in a target project
When QA phase executes "Read and follow .orchestration/support/qa.md"
Then the file exists and is readable
```

**Safe re-run**
```
Given /init-orchestrator is run again in a repo where support files already exist
When the same version is present
Then they are skipped with "already current" — not overwritten
```

---

## 3. Constraints

**Must:**
- Install `slice.md`, `spec.md`, `qa.md` from `defaults/commands/` to `.orchestration/support/` in the target project
- Update `defaults/commands/design.md` — both references: `.claude/commands/slice.md` → `.orchestration/support/slice.md` and `.claude/commands/spec.md` → `.orchestration/support/spec.md`
- Update `defaults/commands/implement.md` — one reference: `defaults/commands/qa.md` → `.orchestration/support/qa.md`
- Update `defaults/commands/migrate.md` — same slice/spec references as design.md
- Update `init-orchestrator.md` — Phase 2 install list and Phase 5 output to include the 3 support files
- Apply the same version-check + drift-detection logic for support files as for the 4 main commands
- Also sync `.claude/commands/design.md`, `.claude/commands/implement.md`, `.claude/commands/migrate.md` with the same reference updates (local dogfooding)
- Create `.orchestration/support/` in `init-orchestrator.md`'s Phase 3 structure creation

**Must not:**
- Install support files to `.claude/commands/` — that would surface them as slash commands
- Change what the support commands themselves do — only their install location and the references to them

**Preferences:**
- `init-orchestrator.md` Phase 5 output should clearly distinguish "commands" from "support" in what was installed
- Reference updates: use the exact string `.orchestration/support/` not a relative path

**Escalation triggers:**
- If `defaults/commands/migrate.md` has additional support file references not covered above — update those too and note them in the QA report

---

## 4. Done definition

1. `.orchestration/support/slice.md`, `.orchestration/support/spec.md`, `.orchestration/support/qa.md` exist in the repo (installed into the main repo as part of this change, mirroring what `/init-orchestrator` will do for target projects)
2. `defaults/commands/design.md` contains `.orchestration/support/slice.md` and `.orchestration/support/spec.md` (zero occurrences of the old `.claude/commands/slice.md` or `.claude/commands/spec.md`)
3. `defaults/commands/implement.md` contains `.orchestration/support/qa.md` (zero occurrences of `defaults/commands/qa.md`)
4. `defaults/commands/migrate.md` has the same reference updates as design.md
5. `.claude/commands/design.md`, `.claude/commands/implement.md`, `.claude/commands/migrate.md` have the same updates (local copies in sync)
6. `init-orchestrator.md` installs `slice.md`, `spec.md`, `qa.md` to `.orchestration/support/` with the same version-check behavior as main commands
7. `init-orchestrator.md` Phase 3 creates `.orchestration/support/`

---

## 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Create `.orchestration/support/` and copy support files | `.orchestration/support/slice.md`, `spec.md`, `qa.md` | All 3 files exist |
| 2 | Update references in `defaults/commands/design.md` and `migrate.md` | No occurrences of `.claude/commands/slice.md` or `.claude/commands/spec.md` in either file | grep confirms 0 matches |
| 3 | Update reference in `defaults/commands/implement.md` | No occurrence of `defaults/commands/qa.md` | grep confirms 0 matches |
| 4 | Sync `.claude/commands/` local copies with same changes | `.claude/commands/design.md`, `implement.md`, `migrate.md` updated | grep confirms 0 old references |
| 5 | Update `init-orchestrator.md` to install support files and create `.orchestration/support/` | install list includes 3 support files, Phase 3 creates `.orchestration/support/` | both present in file |
