---
type: brief
slice: 01
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
slice_doc: specs/slices/project-sequencing-and-status/01-project-creation-and-design-interview.md
status: ready
date: 2026-04-11
---

# Delegation brief — Slice 01: Project creation + design interview

## Intent

Rewrite `defaults/commands/design.md` so that running `/design` on a new project creates a collision-resistant project folder, writes `status.md` immediately (before the interview), runs the design interview, writes `design-01.md` on completion, commits everything, pushes, and stops at a `design_review` gate. Resume logic handles every partial state without losing work.

This is the foundational slice — it establishes the project folder structure, the `status.md` format, the ID scheme, and the commit-on-approval cadence that all subsequent slices depend on.

## Observable outcomes

**Fresh project creation:**
```
Given no .orchestration/projects/ folder exists for this project
When the user runs /design
Then .orchestration/projects/{github-username}-{5-digit-seq}-{slug}/ is created
And status.md is written with stage: design_in_progress and a transitions entry with ISO 8601 timestamp
And the design interview runs
And design-01.md is written on interview completion
And status.md advances to stage: design_review with a second transitions entry
And git commit contains design-01.md and status.md
And git push runs
And the review gate is shown with education copy
```

**Resume at design_review:**
```
Given status.md shows stage: design_review and design-01.md exists
When the user runs /design
Then the review gate is shown immediately
And no interview is re-run
And no files are modified
```

**Resume: interview crashed, no file:**
```
Given status.md shows stage: design_in_progress and design-01.md does not exist
When the user runs /design
Then the interview runs from the beginning
And on completion design-01.md is written and status advances to design_review
```

**Resume: crashed after file write, before status update:**
```
Given status.md shows stage: design_in_progress and design-01.md exists
When the user runs /design
Then no interview is run
And status advances to design_review
And the review gate is shown
```

**Wrong command:**
```
Given a project at stage design_in_progress or design_review
When the user runs /implement or /review
Then output is: "project is in {stage} — run /design to continue"
And no work is done
```

**No argument, multiple in-progress projects:**
```
Given multiple projects exist with non-complete stages
When the user runs /design with no argument
Then a numbered list of in-progress projects is shown
And the user is asked which to resume or offered the option to start a new one
```

**ID collision:**
```
Given a folder already exists at .orchestration/projects/{username}-{seq}-{slug}/
When /design attempts to create a new project with the same sequence number
Then the sequence number is incremented until no collision exists
```

## Constraints

**Must:**
- Write `status.md` as the very first file operation — before any interview interaction
- Status update to `design_review` is the last operation — after commit and push
- ID format: `{github-username}-{zero-padded-5-digit-seq}-{slug}`, e.g. `bcokert-00001-auth-redesign`
- `status.md` format:
  ```yaml
  stage: design_in_progress
  project_id: bcokert-00001-auth-redesign
  next_action: complete design interview
  transitions:
    - stage: design_in_progress
      timestamp: 2026-04-11T14:00:00-07:00
      note: project created
    - stage: design_review
      timestamp: 2026-04-11T14:32:00-07:00
      note: design interview complete
  ```
- Commit message: `"Design interview complete — {project_id}"`
- Commit includes `design-01.md` and `status.md` only — no other files
- Push to current branch after commit
- Read github username from `git config user.name` or fall back to `git config user.email` prefix
- Sequence number derived by scanning existing project folders for the highest current sequence and incrementing

**Must not:**
- Advance status before all artifacts for the stage are written
- Re-run the interview if `design-01.md` already exists (even if status hasn't advanced)
- Commit or push during the interview — only at the gate
- Create any folders or files outside `.orchestration/projects/{id}/`

**Preferences:**
- Slug derived from the project name given by the user: lowercase, kebab-case, max 5 words, strip stop words
- Review gate education copy: explain what just happened (design interview complete), why this is the highest-leverage review point, and that corrections here cost nothing vs after slicing
- Internal organisation of the design interview logic (whether it stays in design.md or is a separate file read by design.md) is an implementation detail — the agent decides what's cleanest

**Escalation triggers:**
- Git is not initialised in the current directory — stop and tell the user
- `.orchestration/` exists but has an unexpected structure (not from this system) — stop and ask before proceeding
- `git push` fails — report the error, do not retry silently; status remains at `design_review` (already committed locally)

## Done definition

1. Running `/design` with no prior state creates `.orchestration/projects/{id}/` with correct ID format, `status.md` with `design_in_progress` transition, runs the interview, writes `design-01.md`, commits both files, pushes, and shows the review gate
2. Running `/design` again on a `design_review` project shows the gate immediately — no re-interview, no file changes, no new commit
3. Running `/design` on a `design_in_progress` project where `design-01.md` exists (but status not advanced) skips the interview, advances status, and shows the gate
4. Running `/design` on a `design_in_progress` project where `design-01.md` does not exist restarts the interview
5. Running `/implement` on a project at any design stage outputs the correct error with stage name and "run /design to continue"
6. `status.md` at `design_review` contains exactly two transitions, both with valid ISO 8601 timestamps

## Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Rewrite design.md phase 0: project detection and resume logic | Phase 0 in design.md handles all four entry states (new, in_progress+no_file, in_progress+file, design_review) | Running /design in each state produces the correct behaviour per observable outcomes above |
| 2 | Implement project folder creation and ID generation | Folder created at correct path, ID format validated, sequence collision handled | Folder exists with correct name; re-running with same sequence increments correctly |
| 3 | Implement status.md write and format | status.md written with correct fields and first transition on project creation | File matches the required format; timestamp is valid ISO 8601 |
| 4 | Wire interview through to design-01.md write and status advance | design-01.md written on interview completion; status advances to design_review as last step | Both files exist; status shows design_review; timestamp on second transition is after the first |
| 5 | Implement gate commit and push | git commit with correct message and correct files; git push | `git log` shows commit with design-01.md and status.md; remote is updated |
| 6 | Implement review gate with education copy and wrong-command errors | Gate displayed after push; /implement and /review output correct errors at design stages | Gate shown correctly; error messages include stage name and correct next command |
