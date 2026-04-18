---
version: 1.2.0
description: |
  Sets up the orchestration layer in the current project. Installs 4 commands to .claude/commands/, 6 agents to .claude/agents/, and 3 support files to .orchestration/support/, creates .orchestration/projects/. Safe to re-run: adds missing components without touching existing project data. Detects and warns about old 7-command installations.
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
    plan-project.md  — full planning pipeline: interview → slices → spec → breakdown → tasks_ready
    implement.md     — execution pipeline: queue scan → tasks → QA → signoff_review
    review.md        — signoff: approve (merge + archive) or feedback (new slices)
    status.md        — project status: active projects table + done-this-week recap
  agents/
    architect.md     — structural decisions and design review
    client-dev.md    — frontend implementation
    lead.md          — dev team orchestration
    quality.md       — testing, QA, and verification
    server-dev.md    — backend implementation
    standards.md     — code quality and convention enforcement

.orchestration/
  projects/          — one folder per project, all artifacts inside
  support/           — support commands read by the main commands at runtime
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

**Agent files** — source: `~/.claude/init-orchestrator/defaults/agents/` — target: `.claude/agents/`

Install: `architect.md`, `client-dev.md`, `lead.md`, `quality.md`, `server-dev.md`, `standards.md`

For each:
- **Missing:** copy it in, no prompt
- **Same version** (check `version:` frontmatter field): skip, note "already current"
- **Different version:** ask "Agent `{name}` is at v{old} locally, v{new} available. Update? (yes/no)"

Create `.claude/agents/` if it doesn't exist.

If a source file is missing from defaults: note it and skip — don't fail the whole init.

---

## Phase 3 — Create project structure

1. Create `.orchestration/projects/` if it doesn't exist. If it exists: leave it untouched — never delete or overwrite project data.

2. Create `.orchestration/support/` if it doesn't exist. (Support files are installed here in Phase 2.)

3. Check for `.orchestration/worktrees/`:
   - If it doesn't exist: nothing to do.
   - If it exists and is empty: delete it.
   - If it exists and has contents: leave it intact. Output: "Found .orchestration/worktrees/ with contents — inspect and remove manually."

---

## Phase 4 — CLAUDE.md tracking rule

Check `CLAUDE.md` at the project root for the line `<!-- installed by init-orchestrator -->`.

If found: skip this phase — note "CLAUDE.md tracking rule already present".

If not found, tell the user:

```
The orchestration system works best when all changes are tracked through projects and
slices. Without a tracking rule in CLAUDE.md, the agent can make ad-hoc commits that
bypass planning, spec, QA, and signoff — the exact gates the system is built to enforce.

A tracking rule tells the agent to always check for an active project before making
changes, and to ask you before proceeding without one.
```

Ask: "Add orchestration tracking rule to CLAUDE.md? (yes/no)"

If yes: append the following section to `CLAUDE.md`. If `CLAUDE.md` doesn't exist: create it with only this section.

```markdown
## IMPORTANT — Orchestration change tracking
<!-- installed by init-orchestrator -->

Before making any code, document, or artifact changes in this repository, verify the work
is covered by an active project and slice in `.orchestration/projects/`.

If there is no active project covering the change:
1. Ask the user whether to create a new project (`/plan-project`) or add it as a slice to an existing one.
2. Only proceed without a project if the user explicitly confirms this is a one-off change.

This rule exists to prevent commits from bypassing the planning and review process. Changes
made outside the orchestration system skip spec, breakdown, QA, and signoff — the exact
review gates the system was built to enforce.
```

If no: skip. Note:
```
Skipped. You can add it later by re-running /init-orchestrator, or paste the section
manually — look for "Orchestration change tracking" in the init-orchestrator docs.
```

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

Agents:
  .claude/agents/architect.md    v{N}
  .claude/agents/client-dev.md   v{N}
  .claude/agents/lead.md         v{N}
  .claude/agents/quality.md      v{N}
  .claude/agents/server-dev.md   v{N}
  .claude/agents/standards.md    v{N}

Structure:
  .orchestration/projects/   (project data)
  .orchestration/support/    (support files)

CLAUDE.md:
  tracking rule installed     (or "skipped — re-run /init-orchestrator to add")

Workflow: /plan-project → /implement → /review
Run /status at any time to see active projects.
```

---

## Behavior rules

- Never delete or overwrite files in `.orchestration/projects/` — that's live project data.
- Never remove old commands without explicit confirmation.
- Write files using absolute paths (resolve `~` via `echo $HOME`).
- If a source command file is missing from defaults: note it and skip. Don't fail the whole init.
- Idempotent: running twice produces the same state as running once.
- Never modify the CLAUDE.md tracking rule section once installed — if it exists, skip Phase 5.
- Detect the tracking rule by the comment marker `<!-- installed by init-orchestrator -->`, not by heading text (headings may be edited by the user).
