---
spec: specs/briefs/project-sequencing-and-status/08-status-v2-multi-project.md
slice: 08
step: 4
title: Write done-this-week recap (Phase 4)
status: done
depends_on: [03-summary-table-output.md]
agent_type: architect
assigned_at: 2026-04-12T00:00:00Z
completed_at: 2026-04-12T00:00:00Z
---

## Work

Write Phase 4 of `defaults/commands/status.md` — the done-this-week recap below the active table.

Steps:
1. Scan `.orchestration/projects/done/*/*/status.md` (YYYY-MM subdirs).
2. For each, find the `done` transition in the `transitions` log. If the timestamp is within the last 7 days: include it.
3. Group by username (first segment of the project ID before the sequence number, e.g. `bcokert` from `bcokert-00001-auth`).
4. Output below the active table:

```
Done this week:
  bcokert: auth-redesign (Apr 10), login-flow (Apr 11)
  jsmith: signup-page (Apr 9)
```

If nothing done in the last 7 days: omit this section entirely (no "Done this week: none").

## Done signal

Done-this-week section appears below the active table when projects completed in the last 7 days exist. Grouped by username. Missing if nothing done this week. Does not include projects done more than 7 days ago.
