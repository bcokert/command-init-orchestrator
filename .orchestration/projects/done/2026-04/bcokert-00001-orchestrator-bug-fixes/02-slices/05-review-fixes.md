---
type: slice
slice: 05
order: 05
project: orchestrator-bug-fixes
design: .orchestration/projects/bcokert-00001-orchestrator-bug-fixes/01-design/design-01.md
status: done
status_updated_at: "2026-04-23T00:04:00-07:00"
---

# Slice 05 — review.md fixes

**Goal:** Fix the git add -A footgun and the feedback path dead end.

## Happy path

- Approval commit: stages `.orchestration/projects/{id}/` and any source/test files that changed. Does not stage unrelated files.
- Any file outside known paths surfaces with a prompt before staging.
- Summary of what will be staged is shown before committing.
- Feedback path output: explicitly states the original slice remains at `signoff_review`, explains that `/review` must be run to resolve it before `/plan-project` will pick up the new feedback slices, and shows the paths of the new draft slices.

## Edge cases

- Planning-only slices (no source files changed): all changes under `.orchestration/` — auto-staging is safe, no prompt needed.
- Implementation slices with many source files: stage them all automatically; only prompt for files outside `.orchestration/` and the project source tree.
- User declines to stage an unexpected file: commit proceeds without it; surfaced files are listed in the output as excluded.
