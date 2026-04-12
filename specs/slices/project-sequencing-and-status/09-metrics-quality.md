---
type: slice
slice: 09
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
status: specced
---

# Slice 09 — Metrics quality + gap surface

**Goal:** Run a fixture project through a complete cycle and verify every metric in the design doc traces to a specific field. Surface gaps and fix them before the system is considered done.

## Happy path

- Fixture project with known history (two slices: one clean, one with QA failure + feedback slice) created in `.orchestration/projects/fixture-00001-metrics-test/`
- Each metric in design doc's "metrics exposed" section mapped to a field + derivation — all pass
- Fixture committed alongside verification checklist

## Edge cases

- Metric can't be traced to any field: either remove from design doc or add the missing field, update fixture, re-verify
- Fixture with partial timestamps (simulating crash): metrics degrade gracefully ("elapsed: unknown"), no crash
- Metric requires cross-project aggregation not yet implemented: flagged as "future instrumentation", not removed
