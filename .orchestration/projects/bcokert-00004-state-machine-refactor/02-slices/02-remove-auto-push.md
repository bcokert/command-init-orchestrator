---
type: slice
slice: 02
order: 02
project: state-machine-refactor
design: .orchestration/projects/bcokert-00004-state-machine-refactor/01-design/design-01.md
status: reviewed
status_updated_at: 2026-04-21T12:00:00-04:00
---

# Slice 02 — Remove auto-push

**Goal:** Remove all automatic `git push` calls from command files. Operator controls when the remote is updated.

## Happy path

- All `git push` invocations removed from `plan-project.md`, `implement.md`, and `review.md`.
- Gate messages and phase-entry text that reference "pushed to remote" updated or removed.
- Commands commit locally and stop. No push, no mention of push.
- Version bumped (minor) on all three changed files.

## Edge cases

- **References to push failure handling**: remove or replace with a note that push is operator-triggered.
- **Review.md signoff flow**: currently may commit + push on approval. Push removed; commit stays.
- **Any "git push --set-upstream" or force-push variants**: remove entirely.
