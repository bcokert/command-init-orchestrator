---
type: brief
slice: 06
project: bcokert-00001-visual-docs-init-orchestrator
spec: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/02-slices/06-plan-vs-design-rename.md
design: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/01-design/design-01.md
date: 2026-04-15
---

# Delegation brief — Slice 06: /plan-project vs /design rename

**Type:** Task (AI agent)
**Date:** 2026-04-15

---

## 1. Intent

The planning command is called `/design` but "design" is a phase within the pipeline, not the pipeline itself. The system refers to it as the "planning stage" throughout. `/plan-project` is the more accurate name.

Rename everything: command file, all internal references, README, diagrams, init-orchestrator. The rename touches a lot of files. The risk is missing a reference somewhere. A grep pass after rename is the primary safety check.

---

## 2. Observable outcomes

**Full rename**
```
Given the rename proceeds
When all files are updated
Then grep for "/design" across the repo returns zero matches in:
  defaults/commands/*.md, .claude/commands/*.md, README.md,
  docs/diagrams/*.d2, init-orchestrator.md
  (excluding this project's own orchestration files, which document the rename)
```

**Diagrams updated**
```
Given lifecycle.d2 previously showed "/design" labels on transitions
When the SVGs are regenerated
Then lifecycle.svg and artifacts.svg show "/plan-project", not "/design"
```

**Init-orchestrator updated**
```
Given /init-orchestrator is run after the rename
When installation completes
Then plan-project.md is installed to .claude/commands/, not design.md
And the done output shows "plan-project.md" not "design.md"
```

---

## 3. Constraints

**Must:**
- Rename `defaults/commands/design.md` → `defaults/commands/plan-project.md`
- Rename `.claude/commands/design.md` → `.claude/commands/plan-project.md`
- Update all internal `/design` references in: `plan-project.md` itself, `implement.md`, `review.md`, `status.md`, `init-orchestrator.md`
- Update `README.md` — every mention of `/design` → `/plan-project`
- Update `docs/diagrams/lifecycle.d2` and `docs/diagrams/artifacts.d2` — `/design` labels
- Update any common-patterns diagrams that mention `/design`
- Regenerate all affected SVGs
- Run a final grep pass to catch stragglers

**Must not:**
- Leave any user-facing reference to `/design` after the rename (internal orchestration project files are exempt — they document the history)

**Preferences:**
- Document the grep results explicitly in the QA report

**Escalation triggers:**
- If a diagram file has `/design` in a way that's hard to cleanly update (e.g., embedded in a node ID that other edges reference) — flag before changing

---

## 4. Done definition

1. `defaults/commands/plan-project.md` exists, `defaults/commands/design.md` does not
2. `.claude/commands/plan-project.md` exists, `.claude/commands/design.md` does not
3. `grep -r "/design" defaults/commands/ .claude/commands/ README.md docs/diagrams/ init-orchestrator.md` returns zero matches (excluding orchestration project files)
4. All `.d2` files with `/design` labels updated and SVGs regenerated
5. `init-orchestrator.md` installs `plan-project.md` not `design.md`

---

## 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Rename command files and update internal references | `plan-project.md` in both locations, no `design.md` | Files renamed, grep confirms no internal self-references to old name |
| 2 | Update `implement.md`, `review.md`, `status.md`, `init-orchestrator.md` | All `/design` → `/plan-project` in those files | grep confirms 0 `/design` in those files |
| 3 | Update README.md | All user-facing `/design` → `/plan-project` | grep confirms 0 `/design` in README |
| 4 | Update diagrams and regenerate SVGs | `.d2` files updated, SVGs re-rendered | `grep -r "/design" docs/diagrams/` returns 0; all SVGs > 500 bytes |
