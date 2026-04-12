---
spec: specs/briefs/project-sequencing-and-status/01-project-creation-and-design-interview.md
slice: 01
step: 5
title: Implement gate commit and push
status: todo
depends_on: [04-interview-to-design-doc-and-status-advance.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

After status advances to `design_review`, commit and push before showing the review gate:

- `git add .orchestration/projects/{id}/design-01.md .orchestration/projects/{id}/status.md`
- `git commit -m "Design interview complete — {project_id}"`
- `git push`
- If push fails: report the error clearly. Do not retry silently. Status remains at `design_review` (already committed locally) — user can push manually.
- Commit contains exactly `design-01.md` and `status.md` — no other files

Escalation checks before any git operations:
- If git is not initialised: stop and tell the user
- If `.orchestration/` exists with unexpected structure: stop and ask before proceeding

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/01-project-creation-and-design-interview.md` — commit message format and escalation triggers

## Done signal

`git log --oneline -1` shows commit with message `Design interview complete — {project_id}`. `git show --stat HEAD` shows exactly two files changed: `design-01.md` and `status.md`. Remote is updated (or error is reported clearly if push fails).
