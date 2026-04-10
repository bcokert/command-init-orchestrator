---
name: commit
version: 1.0.0
description: |
  Commits completed task work. Uses the task file for commit message context. Stages specific files, writes a task-scoped commit message, and updates the dashboard.
triggers:
  - /commit
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - AskUserQuestion
---

# Commit — Task-Scoped Commit

Your job is to commit work done for a specific task, using the task file as context for the message.

---

## Phase 0 — Load inputs

If a task file path was passed as argument, read it. If not, ask:

> "Which task are we committing? (path to task file, e.g. .orchestration/specs/tasks/m1-read-path/03-vault-layer.md)"

Read the task file: title, spec, step number, done signal.

---

## Phase 1 — Review what changed

Run `git status` and `git diff --stat HEAD` to see what changed.

Show the file list. Ask Bdon: "These are the changed files. Stage all of them, or just specific ones?"

---

## Phase 2 — Stage and commit

Stage only the files that belong to this task's work (based on its Work section and what's changed). Do not use `git add -A`.

Commit message format:
- First line: `{task title}` — max 72 chars, trim if needed
- Body: one sentence describing what now works that didn't before
- Co-author line

```bash
git commit -m "$(cat <<'EOF'
{task title}

{one sentence from done signal — what now works}

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

Never skip hooks (`--no-verify`).

---

## Phase 3 — Update task and dashboard

Update the task file frontmatter: `status: done` (if not already set).
Update `.orchestration/dashboard/{spec-id}.md` — set task status to `done`, note the date.
Update `.orchestration/dashboard/summary.md` — increment the `Done` count for this spec. If all tasks are done, update spec status to `done`.

Ask: "Push to remote?"

If yes: `git push`.

---

## Behavior rules

- Never `git add -A`. Stage specific files only.
- Never `--no-verify`.
- Commit message first line under 72 chars.
- Always update dashboard after commit, not before.
