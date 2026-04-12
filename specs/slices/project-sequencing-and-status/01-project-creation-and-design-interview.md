---
type: slice
slice: 01
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
status: tasks_ready
---

# Slice 01 — Project creation + design interview

**Goal:** Running `/design` on a new project creates the project folder with a collision-resistant ID, writes `status.md` immediately, runs the design interview, writes `design-01.md`, and stops at `design_review` with a commit + push.

## Happy path

- Fresh project: folder created at `.orchestration/projects/{github-username}-{seq}-{slug}/`, `status.md` initialized with `stage: design_in_progress` and first transition timestamp, interview runs, `design-01.md` written, status advances to `design_review`, commit + push, review gate shown with education
- Resume at `design_review`: re-run `/design` → shows review gate, no re-interview, no folder changes
- `/implement` or `/review` at `design_in_progress` or `design_review` → clear error: "project is in {stage} — run `/design` to continue"

## Edge cases

- Interview crashes, no file: status shows `design_in_progress`, `design-01.md` absent → re-run restarts interview from the beginning
- Interview crashes, file present: `design-01.md` exists but status not advanced → re-run uses existing file, advances status to `design_review`, shows review gate (no re-interview)
- No argument, multiple projects at non-complete stages: list them, ask which to resume or offer to start a new one
- ID sequence collision (folder already exists): increment sequence number and retry
