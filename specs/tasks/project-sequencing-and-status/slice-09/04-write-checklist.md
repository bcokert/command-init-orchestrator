---
spec: specs/briefs/project-sequencing-and-status/09-metrics-quality.md
slice: 09
step: 4
title: Write final metrics checklist
status: todo
depends_on: [03-resolve-gaps.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Write `.orchestration/projects/fixture-00001-metrics-test/metrics-checklist.md` with the final checklist.

Format:

```markdown
# Metrics checklist — fixture-00001-metrics-test

## Task-level

| Metric | Field(s) | Derivation | Expected (fixture) | Verdict | Notes |
|--------|----------|------------|--------------------|---------|-------|
| ...    | ...      | ...        | ...                | pass    |       |

## Slice-level

...

## Project-level

...

## Cross-project

...
```

Verdicts: `pass` | `gap-fixed` | `future`

Every metric from the design doc must appear. No TBDs.

## Done signal

`metrics-checklist.md` exists in the fixture folder. Every metric has a verdict. No metric is in an unresolved state.
