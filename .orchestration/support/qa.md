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

When called from `/implement`, the project id and slice number are passed as context. When called standalone, read `.orchestration/projects/*/status.md` to find the project in `implementing` or `signoff_review`.

Read the brief at `.orchestration/projects/{id}/03-briefs/{NN}-{slug}.md` and all task files in `.orchestration/projects/{id}/04-tasks/slice-{NN}/`. Read the brief's Observable Outcomes section — this is the ground truth for what should work.

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

After verification (and after any fixes in Phase 1.5), write `qa_result` to each task file frontmatter:
- `pass` — passed on first check
- `fixed` — failed initially, fixed during QA, re-verified as passing
- `manual` — marked manual (requires human or running service)

---

## Phase 1.5 — Fix failures and re-verify

For each `fail`:

1. Determine if the fix is within scope — the agent team can resolve it without human input or an unavailable service.
2. If yes: fix it, then re-run the verification for that check. Repeat until it passes or you're stuck.
3. If stuck after a genuine fix attempt: mark `fail` with a clear description of what was tried.
4. If the fix requires human judgment, a running service, or information not available: mark `manual` with a note explaining what's needed.

Only write the QA report (Phase 3) when all fixable failures have been resolved. `manual` items do not block the report.

---

## Phase 2 — Design alignment

After all fixable failures are resolved, review the design doc and future slice files for anything that needs updating based on what was just implemented.

1. Read `.orchestration/projects/{id}/01-design/design-{NN}.md`.
2. Read all slice files in `.orchestration/projects/{id}/02-slices/` with `status: draft` or `status: reviewed` (future unimplemented slices).
3. For each, ask: does what was just implemented conflict with, clarify, or invalidate anything here?
4. If a future slice's scope significantly overlaps with what was just implemented: stop and ask before modifying.
5. Apply any updates directly. Leave all changes uncommitted.
6. Produce a summary for the signoff_review output:
   - If no changes: "no design or slice updates needed"
   - If changes: one bullet per changed file with one sentence explaining why

---

## Phase 3 — Write QA report

Path: `.orchestration/projects/{id}/05-qa/slice-{NN}-qa-report.md`

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

## Phase 4 — Advance to signoff_review

When QA passes (all non-manual checks green):

1. Write the QA report file.
2. Update the slice file frontmatter: `status: signoff_review`
3. Update `status.md` (no commit yet — commit happens in `/review` on approval):
```yaml
stage: signoff_review
next_action: run /review to approve or provide feedback
transitions:
  - stage: signoff_review
    timestamp: {ISO 8601}
    note: QA passed — {N} checks, {M} manual
```
4. Output:
```
QA passed — slice {NN}: {title}

Design alignment: {summary from Phase 2 — either "no design or slice updates needed"
or one bullet per changed file}

Review the output. When ready, run /review to approve (marks done)
or provide feedback (creates new slice in backlog).
```

**Stop here. The commit happens in `/review` when the human approves — not now.**

---

## Behavior rules

- Only verify what done signals specify. Don't invent test cases.
- Fix failures that are within scope before writing the report. Re-run verification after fixing. The report reflects the final state, not the initial state.
- If a check requires a running service that's not available, mark it `manual` — don't skip it.
- A spec is `passed` only if all non-manual checks pass. `manual` items do not count as failures.
- If there are unfixed failures: do not suggest marking the spec `done`. Flag for fix.
- QA runs automatically after all tasks complete — do not wait to be asked. When the last task is marked `done`, proceed to Phase 0 immediately.
- Never `git add` or `git commit` anything. The QA report, slice status update, and status.md changes all stay uncommitted. The human reviews the full uncommitted diff at signoff_review. The commit happens in `/review` on approval.
