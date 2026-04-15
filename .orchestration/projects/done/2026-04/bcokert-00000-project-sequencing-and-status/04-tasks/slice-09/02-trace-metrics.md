---
spec: specs/briefs/project-sequencing-and-status/09-metrics-quality.md
slice: 09
step: 2
title: Trace each metric against fixture
status: done
depends_on: [01-build-fixture.md]
agent_type: architect
assigned_at: 2026-04-12T00:00:00Z
completed_at: 2026-04-12T00:00:00Z
---

## Work

Read the design doc's "Metrics exposed" section. For every metric listed (task-level, slice-level, project-level, cross-project), attempt to derive it from the fixture data.

For each metric produce a draft checklist row:
- **Metric name** — as named in the design doc
- **Field(s) used** — which field in which file (e.g. `task.completed_at - task.assigned_at`)
- **Derivation** — formula or description
- **Expected value against fixture** — what the derivation produces for the known fixture data
- **Verdict (draft)** — `pass`, `gap` (field missing), or `future` (requires cross-project data)

Don't resolve gaps yet — just identify them clearly. That's task 3.

## Done signal

Every metric from the design doc "Metrics exposed" section has a draft row. No metric is skipped. Gaps are identified but not yet resolved.
