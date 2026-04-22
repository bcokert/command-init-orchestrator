---
spec: 01-status-command-fixes
date: 2026-04-22
status: passed
---

# QA Report — Status command fixes

## Summary

4/4 tasks verified: 4 pass, 0 fail, 0 manual.

## Results

| # | Task | Done signal | Result | Notes |
|---|------|------------|--------|-------|
| 01 | Fix Phase 2 glob and add design-phase display | Glob is `projects/*`, design-phase branch present, `in_progress` fallback present | pass | Lines 49, 53-56, 88 |
| 02 | Rewrite state tables | All three tables match target exactly | pass | Bucket, abbreviation, routing all verified |
| 03 | Add alias handling for reviewed and specced | Alias note present; routing handles both legacy values | pass | Line 142 |
| 04 | Version bump and coherence pass | Frontmatter reads `version: 3.4.0`; no orphaned state references | pass | No stray `reviewed`/`specced` outside alias note |

## Failures

None.

## Manual checks needed

None.

## Design alignment

No design or slice updates needed. Future slices 02–08 touch different commands (remove-auto-push, commit-timing, agent-owned-transitions, observability, slicing-loop, spec-breakdown, implement-gate-qa-retry) — no overlap with status.md changes.

## Recommended next steps

Run `/review` to approve slice 01.
