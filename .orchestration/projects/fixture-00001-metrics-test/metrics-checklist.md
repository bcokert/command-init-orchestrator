# Metrics checklist — fixture-00001-metrics-test

All metrics derived from `status.md` transitions and task file timestamps. No separate metrics store.

## Task-level

| Metric | Field(s) | Derivation | Expected (fixture) | Verdict | Notes |
|--------|----------|------------|--------------------|---------|-------|
| Agent processing time per task | `task.completed_at`, `task.assigned_at` | `completed_at - assigned_at` | slice-01/01: 1h 20m, slice-01/02: 1h 20m, slice-02/01: 1h 25m, slice-02/02: 1h 45m | pass | |
| Time per task by agent_type | `task.completed_at`, `task.assigned_at`, `task.agent_type` | group tasks by agent_type, avg duration | server-dev avg: 1h 32m; quality avg: 1h 20m | pass | |
| QA pass/fail on first attempt | `task.qa_result` | `qa_result == "pass"` → first pass; `qa_result == "fixed"` → failed first check | slice-01: 2 pass; slice-02: 1 pass, 1 fixed | gap-fixed | Added `qa_result` field to task file format. Written by QA phase. |

## Slice-level

| Metric | Field(s) | Derivation | Expected (fixture) | Verdict | Notes |
|--------|----------|------------|--------------------|---------|-------|
| Total time per slice | `status.md transitions`: `tasks_ready` → `signoff_review` | `signoff_review.timestamp - tasks_ready.timestamp` | slice-01: ~3h 15m; slice-02: ~1h 45m | pass | |
| Active time vs wait time | task `assigned_at`/`completed_at`, total slice time | active = Σ(task durations); wait = total - active | slice-01: active 2h 40m, wait 35m | pass | |
| QA pass rate per slice | `task.qa_result` | count(`qa_result == "pass"`) / count(tasks) | slice-01: 100%; slice-02: 50% first-pass, 100% after QA fix | gap-fixed | Depends on `qa_result` field (same fix as above) |
| Number of tasks per slice | task files in `04-tasks/slice-{NN}/` | count .md files | slice-01: 2, slice-02: 2 | pass | |
| Slice required follow-up | slice files with `follow_up_of` | any slice file with `follow_up_of: {NN}` exists | slice-02 → 02.1 exists with `follow_up_of: 02` | pass | |
| Time from spec done to first task started | `status.md transitions`: `tasks_ready` → `implementing` + `task.assigned_at` | `implementing.timestamp` or first `task.assigned_at - tasks_ready.timestamp` | slice-01: ~5m (11:15 → 11:20); slice-02: not separately tracked | gap-fixed | `tasks_ready` used as proxy for spec approved + breakdown done. Conflates spec review time with breakdown time, but sufficient for queue-wait measurement. |

## Project-level

| Metric | Field(s) | Derivation | Expected (fixture) | Verdict | Notes |
|--------|----------|------------|--------------------|---------|-------|
| Total wall-clock time | `status.md transitions`: `design_in_progress` → `done` | `done.timestamp - design_in_progress.timestamp` | ~1d 6h 45m | pass | |
| Total slice count (planned vs actual) | slice files in `02-slices/` | count all; count those with `follow_up_of` set | 3 total (01, 02, 02.1); 1 feedback slice | pass | |
| Number of feedback slices | slice files with `follow_up_of` field | count slices where `follow_up_of` is set | 1 (02.1) | pass | |
| Active processing vs human wait | task durations + transitions log | active = Σ(task durations) + QA phases; wait = total - active | derivable — not computed here | pass | Raw data present; computation on read |
| Slice count vs speed | cross-project | requires multiple projects | n/a | future | Single project can't answer this |

## Cross-project comparative

| Metric | Verdict | Notes |
|--------|---------|-------|
| Projects by slice count: avg completion time, QA iteration count, rework rate | future | Requires aggregating across multiple project status.md files |
| Slice size (tasks/slice) vs QA pass rate | future | Same — cross-project aggregation |
| Planning time vs execution time per project | future | Single project: derivable. Cross-project comparison: requires aggregation |

## Resilience

| Scenario | Expected | Actual | Result |
|----------|----------|--------|--------|
| Missing transition timestamp | elapsed: unknown (no crash) | status.md Phase 1 step 6 and Phase 2 scan both explicitly handle missing/unparseable timestamps with "unknown" fallback | pass |

---

**Summary:** 17 metrics checked. 3 gaps found and fixed (all related to `qa_result` field and spec-approval timestamp proxy). 4 future (cross-project aggregation). 10 pass on existing fields.
