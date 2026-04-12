---
spec: specs/briefs/project-sequencing-and-status/05.1-post-qa-design-alignment.md
slice: 05.1
step: 1
title: Update all path references to numbered subfolders
status: todo
depends_on: []
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Update all path references in the five command files to use numbered subfolders:

| Old path | New path |
|----------|----------|
| `{id}/design-{NN}.md` | `{id}/01-design/design-{NN}.md` |
| `{id}/slices/` | `{id}/02-slices/` |
| `{id}/briefs/` | `{id}/03-briefs/` |
| `{id}/tasks/` | `{id}/04-tasks/` |
| (no qa folder yet) | `{id}/05-qa/` |

Files to update:
- `defaults/commands/design.md` — all phase artifact paths (Phase 4, 5, 6, 7)
- `defaults/commands/slice.md` — output path
- `defaults/commands/spec.md` — save path
- `defaults/commands/implement.md` — task file scan paths, worktree paths unchanged
- `defaults/commands/qa.md` — QA report output path

Logic unchanged — path strings only.

## Done signal

No unnumbered subfolder references (`/slices/`, `/briefs/`, `/tasks/`, `/design-`) remain in any of the five command files. All replaced with numbered equivalents.
