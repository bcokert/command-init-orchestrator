---
type: brief
slice: 02
project: bcokert-00001-orchestrator-bug-fixes
date: 2026-04-23
---

# Delegation brief — Slice 02: Dead command removal

**Type:** Task (AI agent)
**Date:** 2026-04-23

---

### 1. Intent

`defaults/commands/` contains three files that were never wired into the orchestrator's install list and represent deferred or removed features: `learn.md`, `commit.md`, `migrate.md`. They're dead weight — anyone reading the codebase sees them and assumes they're active. Remove them.

`CLAUDE.md` (the project-level one in this repo) has no rule requiring a cohesion pass when agent or command defaults are modified. That gap is what caused the path drift this project is fixing. Add the rule now.

`TODO.md` at the project root is where Bdon's backlog of future orchestrator features lives. Create it with the definitive list.

None of these files are referenced by `init-orchestrator.md`'s install list. `init-orchestrator.md` does reference `learn.md`, `commit.md`, and `migrate.md` in its old-7-command detection list (Phase 2, step 3) — that reference is correct and must not be removed. It's the mechanism that warns users who have those files installed. Only delete the source files; leave the detection logic alone.

`.claude/commands/` (the local dogfood copy) does not contain these three files — confirm before deleting.

---

### 2. Observable outcomes

**Dead files removed**

```
Given a fresh clone of this repo
When you list defaults/commands/
Then learn.md, commit.md, and migrate.md are absent
```

**TODO.md exists at project root with the correct list**

```
Given the project root
When you read TODO.md
Then it contains all items from the list below (in any format):
  - Deep observability tracking
  - Observability dashboards (status and full-system monitoring)
  - System-wide expansion: multi-repo or cloud-based orchestrator state, org-wide SDLC (ACD)
  - Better agent team execution with inter-agent communication (Claude teams)
  - Research and dynamic context — dynamic research agents, compressed domain context
  - Learning via SME feedback
  - Learning via test feedback and human fixes
  - Test case evolution and hardening from feedback
  - Self-improving feedback loop
  - Root context discovery
```

**CLAUDE.md sync rule added**

```
Given the project CLAUDE.md
When you read it
Then it contains a rule stating that any change to defaults/ agent or command files
requires a cohesion pass over related artifacts
```

**Detection logic untouched**

```
Given init-orchestrator.md
When you grep for "learn.md" and "commit.md" and "migrate.md"
Then they appear exactly in the old-7-command detection list (Phase 2) — nowhere else
```

---

### 3. Constraints

**Must:**
- Delete `learn.md`, `commit.md`, `migrate.md` from `defaults/commands/` only.
- Verify these files are not in `.claude/commands/` before attempting deletion there.
- Create `TODO.md` at project root (not inside `.orchestration/`).
- Add the CLAUDE.md sync rule as a new section in the project's `CLAUDE.md` (not in `init-orchestrator.md` or any defaults file — this rule is for this repo's developers, not end users).

**Must not:**
- Remove `learn.md`, `commit.md`, `migrate.md` from the old-7-command detection list in `init-orchestrator.md`.
- Add these file names anywhere new in `init-orchestrator.md` or any other command.
- Modify any file in `.claude/commands/` unless the files are confirmed to be present there.

**Preferences:**
- TODO.md format: a simple markdown list with a short description per item. No headers beyond a title.
- CLAUDE.md sync rule: keep it terse — one short paragraph, consistent with the existing rule style in that file.

**Escalation triggers:**
- Any of the three files appear in `.claude/commands/` — surface before deleting.
- Any of the three files are referenced in `defaults/commands/plan-project.md`, `implement.md`, `review.md`, or `status.md` — stop and ask.

---

### 4. Done definition

1. `ls defaults/commands/` — does not include `learn.md`, `commit.md`, or `migrate.md`.
2. `ls .claude/commands/` — same (or confirm they were never there).
3. `cat TODO.md` — all 10 items from the list are present.
4. `grep -n "sync rule\|cohesion pass\|defaults/" CLAUDE.md` — returns at least one match in a new section.
5. `grep -n "learn\.md\|commit\.md\|migrate\.md" init-orchestrator.md` — all matches are inside the old-7-command detection block only.

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Verify learn.md, commit.md, migrate.md are absent from .claude/commands/ | Confirmed | No error from `ls .claude/commands/` showing those files |
| 2 | Delete learn.md, commit.md, migrate.md from defaults/commands/ | Files absent | `ls defaults/commands/` shows neither file |
| 3 | Create TODO.md at project root with the 10-item feature backlog | TODO.md exists | `cat TODO.md` shows all 10 items |
| 4 | Add cohesion-pass sync rule to project CLAUDE.md | New section in CLAUDE.md | `grep "cohesion\|defaults/" CLAUDE.md` returns a match in a new section |
