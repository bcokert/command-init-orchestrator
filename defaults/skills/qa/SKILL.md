---
name: qa
version: 1.0.0
description: |
  Runs after implement. Verifies done signals for each task in a spec, runs mechanical checks where possible, and outputs a QA report to .orchestration/dashboard/{spec-id}-qa.md.
triggers:
  - /qa
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
---

# QA — Verification and Report

Your job is to verify that a spec's done signals are met and produce a report.

---

## Phase 0 — Load inputs

If a spec-id was passed as argument, use it. If not, ask:

> "Which spec are we QA-ing? (spec-id, e.g. m1-read-path)"

Read the spec file at `.orchestration/specs/briefs/` and all task files in `.orchestration/specs/tasks/{spec-id}/`. Read the spec's Observable Outcomes section — this is the ground truth for what should work.

---

## Phase 1 — Run verification

For each task file with `status: done`, check its done signal.

**Run mechanical checks where possible:**
- `go build ./...` and `go test ./...` — if Go project
- `make test` — if Makefile has a test target
- `npm test` / `npx tsc --noEmit` — if TypeScript project
- File existence: check that files the task said it would create actually exist
- HTTP endpoints: if a running service is accessible, hit the endpoint

Only check what the done signal specifies. Don't invent tests.

Mark each check: `pass`, `fail`, or `manual` (requires human or running service).

---

## Phase 2 — Write QA report

Path: `.orchestration/dashboard/{spec-id}-qa.md`

```markdown
---
spec: {spec-id}
date: YYYY-MM-DD
status: {passed|failed|partial|pending-manual}
---

# QA Report — {Spec Title}

## Summary

{N}/{total} tasks verified: {N} pass, {N} fail, {N} manual.

## Results

| # | Task | Done signal | Result | Notes |
|---|------|------------|--------|-------|
| 00 | {title} | {done signal brief} | pass | |
| 01 | {title} | {done signal brief} | fail | {what failed} |
| 02 | {title} | {done signal brief} | manual | needs running service |

## Failures

{For each failed check:}

### Task {N} — {title}

**Expected:** {what the done signal said}
**Actual:** {what happened or what's missing}
**Suggested fix:** {if obvious}

## Manual checks needed

{List any checks that require human review or a running service.}

## Recommended next steps

{What to fix, re-run /qa after, or escalate to Bdon.}
```

---

## Phase 3 — Update dashboard

Update `.orchestration/dashboard/{spec-id}.md` — add a QA row below the task table.
Update `.orchestration/dashboard/summary.md` — set the QA column for this spec: `passed`, `failed`, `partial`, or `pending-manual`.

---

## Behavior rules

- Only verify what done signals specify. Don't invent test cases.
- If a check requires a running service that's not available, mark it `manual` — don't skip it.
- A spec is `passed` only if all checks pass. Anything else is `partial` or `failed`.
- If there are failures: do not suggest marking the spec `done`. Flag for fix.
