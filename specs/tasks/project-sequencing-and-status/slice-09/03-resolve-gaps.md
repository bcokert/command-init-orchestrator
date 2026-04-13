---
spec: specs/briefs/project-sequencing-and-status/09-metrics-quality.md
slice: 09
step: 3
title: Resolve gaps
status: done
depends_on: [02-trace-metrics.md]
agent_type: architect
assigned_at: 2026-04-12T00:00:00Z
completed_at: 2026-04-12T00:00:00Z
---

## Work

For each `gap` verdict from task 2:

1. Determine the fix: either add the missing field to the status.md or task file format, or remove the metric from the design doc if it's not worth supporting.
2. If adding a field: update the format definitions in the relevant command files (design.md Phase 7 task template, status.md format, etc.) and update the fixture to include the new field.
3. If removing a metric: remove it from the design doc's "Metrics exposed" section with a brief note on why.
4. Escalation: if a fix requires a breaking schema change — stop and ask before proceeding.

Changes must be non-breaking with respect to earlier slices' assumptions.

Update the draft checklist rows: `gap` → `gap-fixed` with a note describing what was changed.

## Done signal

No `gap` verdicts remain in the checklist. All gaps either fixed (field added, fixture updated, command files updated) or escalated. Design doc reflects any metric removals.
