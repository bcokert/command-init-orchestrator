---
version: 1.0.0
description: |
  Runs after implement. Verifies done signals for each task in a spec, runs mechanical checks where possible, and outputs a QA report to .orchestration/dashboard/{spec-id}-qa.md.
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

## Phase 1.5 — Fix failures and re-verify

For each `fail`:

1. Determine if the fix is within scope — the agent team can resolve it without human input or an unavailable service.
2. If yes: fix it, then re-run the verification for that check. Repeat until it passes or you're stuck.
3. If stuck after a genuine fix attempt: mark `fail` with a clear description of what was tried.
4. If the fix requires human judgment, a running service, or information not available: mark `manual` with a note explaining what's needed.

Only write the QA report (Phase 2) when all fixable failures have been resolved. `manual` items do not block the report.

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

## Phase 3 — Advance to signoff_review

When QA passes (all non-manual checks green):

1. Update the slice file frontmatter: `status: signoff_review`
2. Update `status.md`:
```yaml
stage: signoff_review
next_action: run /review to approve or provide feedback
transitions:
  - stage: signoff_review
    timestamp: {ISO 8601}
    note: QA passed — {N} checks, {M} manual
```
3. Commit and push:
   - `git add` QA report + slice file + `status.md`
   - `git commit -m "QA passed — {project_id} slice {NN}"`
   - `git push`
4. Output:
```
QA passed — slice {NN}: {title}

Review the output. When ready, run /review to approve (marks done)
or provide feedback (creates new slice in backlog).

Do not proceed to the next slice until /review is complete.
```

**Stop here. Do not proceed to the next slice.**

---

## Behavior rules

- Only verify what done signals specify. Don't invent test cases.
- Fix failures that are within scope before writing the report. Re-run verification after fixing. The report reflects the final state, not the initial state.
- If a check requires a running service that's not available, mark it `manual` — don't skip it.
- A spec is `passed` only if all non-manual checks pass. `manual` items do not count as failures.
- If there are unfixed failures: do not suggest marking the spec `done`. Flag for fix.
- QA runs automatically after all tasks complete — do not wait to be asked. When the last task is marked `done`, proceed to Phase 0 immediately.
