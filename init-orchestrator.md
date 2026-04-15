---
description: |
  Sets up the orchestration layer in the current project. Installs 4 commands to .claude/commands/ and 3 support files to .orchestration/support/, creates .orchestration/projects/, adds .orchestration/worktrees/ to .gitignore. Safe to re-run: adds missing components without touching existing project data. Detects and warns about old 7-command installations.
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - AskUserQuestion
---

# Init Orchestrator

Sets up the orchestration layer for a project. Safe to re-run — adds missing components, never overwrites project data, warns before removing old commands.

The structure it creates:

```
.claude/
  commands/
    plan-project.md       — full planning pipeline: interview → slices → spec → breakdown → tasks_ready
    implement.md    — execution pipeline: worktree creation → tasks → QA → signoff_review
    review.md       — signoff: approve (merge + archive) or feedback (new slices)
    status.md       — project status: active projects table + done-this-week recap

.orchestration/
  projects/         — one folder per project, all artifacts inside
  support/          — support commands read by the main commands at runtime
  worktrees/        — git worktrees for in-flight projects (gitignored)
```

---

## Phase 0 — Check what exists

1. Check if `.orchestration/projects/` exists.
2. Check `.claude/commands/` for existing command files.
3. Check `.claude/commands/` for old 7-command files: `pipeline.md`, `qa.md`, `breakdown.md`, `slice.md`, `spec.md`, `commit.md`, `learn.md`, `migrate.md`.

If this is a first run (nothing exists): proceed directly to Phase 1 with no prompting.

If re-run: apply the logic in Phase 1.

---

## Phase 1 — Handle old commands

If any old command files are found in `.claude/commands/`:

List them:
```
Old command files found:
  .claude/commands/pipeline.md
  .claude/commands/qa.md
  ...

These are from the previous 7-command system. Remove them? (yes/no)
```

If yes: delete them. If no: leave them and continue (new commands will coexist).

---

## Phase 2 — Install commands and support files

Source: `~/.claude/init-orchestrator/defaults/commands/`

**User commands** — target: `.claude/commands/`

Install: `plan-project.md`, `implement.md`, `review.md`, `status.md`

For each:
- **Missing:** copy it in, no prompt
- **Same version** (check `version:` frontmatter field): skip, note "already current"
- **Different version:** ask "Command `{name}` is at v{old} locally, v{new} available. Update? (yes/no)"

Create `.claude/commands/` if it doesn't exist.

**Support files** — target: `.orchestration/support/`

Install: `slice.md`, `spec.md`, `qa.md`

For each:
- **Missing:** copy it in, no prompt
- **Same version** (check `version:` frontmatter field): skip, note "already current"
- **Different version:** ask "Support file `{name}` is at v{old} locally, v{new} available. Update? (yes/no)"

Create `.orchestration/support/` if it doesn't exist.

If a source file is missing from defaults: note it and skip — don't fail the whole init.

---

## Phase 3 — Create project structure

1. Create `.orchestration/projects/` if it doesn't exist. If it exists: leave it untouched — never delete or overwrite project data.

2. Create `.orchestration/support/` if it doesn't exist. (Support files are installed here in Phase 2.)

3. Create `.orchestration/worktrees/` if it doesn't exist. This directory holds git worktrees for in-flight projects — it's local-only and should be gitignored.

---

## Phase 4 — Update .gitignore

Check `.gitignore` at the project root.

Add `.orchestration/worktrees/` if not already present. Append only — never rewrite or reorder existing entries:

```
# Orchestration worktrees (local only — git tracks the branches, not the directories)
.orchestration/worktrees/
```

If `.gitignore` doesn't exist: create it with that entry.

---

## Phase 5 — Done

Report what was created, updated, or skipped. Show the installed commands and their versions.

Output:
```
Orchestration ready.

Commands:
  .claude/commands/plan-project.md     v{N}
  .claude/commands/implement.md  v{N}
  .claude/commands/review.md     v{N}
  .claude/commands/status.md     v{N}

Support:
  .orchestration/support/slice.md  v{N}
  .orchestration/support/spec.md   v{N}
  .orchestration/support/qa.md     v{N}

Structure:
  .orchestration/projects/   (project data)
  .orchestration/support/    (support files)
  .orchestration/worktrees/  (gitignored)

Workflow: /plan-project → /implement → /review
Run /status at any time to see active projects.
```

---

## Behavior rules

- Never delete or overwrite files in `.orchestration/projects/` — that's live project data.
- Never remove old commands without explicit confirmation.
- Write files using absolute paths (resolve `~` via `echo $HOME`).
- When updating `.gitignore`, only append — never rewrite or reorder existing entries.
- If a source command file is missing from defaults: note it and skip. Don't fail the whole init.
- Idempotent: running twice produces the same state as running once.
