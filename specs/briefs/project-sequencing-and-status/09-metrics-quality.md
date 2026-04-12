---
type: brief
slice: 09
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
slice_doc: specs/slices/project-sequencing-and-status/09-metrics-quality.md
status: ready
date: 2026-04-12
---

# Delegation brief — Slice 09: Metrics quality + gap surface

## Intent

The design doc lists a set of metrics the system should expose (task-level, slice-level, project-level, cross-project). All of them are derived from `status.md` transition timestamps and task file timestamps — no separate metrics store. This slice verifies that claim is true: every metric has a clear derivation path from actual fields that exist in the format. It does this by building a fixture project with known history and tracing each metric against it.

The fixture also serves as a regression reference — if the status format ever changes, running it against the checklist will catch what broke.

## Observable outcomes

**All metrics traceable:**
```
Given a fixture project with complete history exists
When the agent maps each metric from the design doc's "Metrics exposed" section
Then every metric has a named field and a derivation formula
And the derivation produces the expected value against the fixture data
```

**Metric has no derivation path:**
```
Given a metric in the design doc that can't be traced to any existing field
When the agent investigates
Then either: the field is added to the status.md or task file format and the fixture updated
Or: the metric is removed from the design doc (it's not actually supported)
In either case: no metric is left as "aspirational" without a real derivation
```

**Partial timestamps (crash simulation):**
```
Given a fixture project where some transition timestamps are missing
When a metric is derived that depends on those timestamps
Then the output degrades gracefully: "elapsed: unknown" or similar
And no crash occurs
```

**Cross-project metric not yet derivable:**
```
Given a metric that requires aggregating across multiple projects
When it can't be derived from a single project's data
Then it is flagged as "future instrumentation" in the checklist with a note
And it is not removed from the design doc
```

## Constraints

**Must:**
- Fixture path: `.orchestration/projects/fixture-00001-metrics-test/` — use this exact path
- Fixture must have two slices: one clean run (all tasks done, QA passed), one with a QA failure + feedback slice added
- Every metric from the design doc "Metrics exposed" section must appear in the checklist with a verdict: `pass`, `gap-fixed`, or `future`
- Gaps found during tracing must be resolved (field added or metric removed) before writing the final checklist
- Fixture and checklist both committed as part of this slice

**Must not:**
- Leave any metric in an unresolved state — no "TBD" or "unclear"
- Invent metrics not in the design doc
- Modify task or status format in ways that break earlier slices' assumptions

**Preferences:**
- Fixture data: hand-crafted YAML in status.md and task files — no need to run real commands to generate it
- Checklist format: one row per metric, columns: metric name | field(s) used | derivation | verdict | notes

**Escalation triggers:**
- A gap requires changing the status.md or task file schema in a breaking way: stop and ask before proceeding

## Done definition

1. Fixture project exists at `.orchestration/projects/fixture-00001-metrics-test/` with two-slice history
2. Verification checklist exists at `.orchestration/projects/fixture-00001-metrics-test/metrics-checklist.md`
3. Every metric from the design doc has a verdict in the checklist: `pass`, `gap-fixed`, or `future`
4. No `pass` verdicts rely on fields that don't exist in the actual format
5. Any gaps found were resolved (field added or metric removed) before checklist was written
6. Partial-timestamp fixture produces graceful degradation, not a crash (manual check)

## Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Build fixture project | `.orchestration/projects/fixture-00001-metrics-test/` with hand-crafted status.md and task files covering two slices (clean + QA failure + feedback) | Fixture folder exists with complete structure; all timestamps present |
| 2 | Trace each metric against fixture | Draft checklist mapping every design-doc metric to field + derivation + expected value | All metrics from "Metrics exposed" section have a derivation attempt |
| 3 | Resolve gaps | Fix any untraceable metrics: add missing fields or remove metric from design doc | No metric left unresolved; format changes are non-breaking |
| 4 | Write final checklist | `metrics-checklist.md` with verdict column filled | Every metric has pass/gap-fixed/future verdict; no TBDs |
| 5 | Add partial-timestamp variant to fixture | One transition missing its timestamp in the fixture | `/status` run against fixture shows "unknown" for that metric, no crash |
