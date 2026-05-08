# State diagram of orchestrator

On a per project basis. Order of transitions and guards is relevant — short circuit on the first matching transition.

## Principles

**Agent owns all transitions.** The user never edits status files. They respond to agent prompts; the agent writes all status updates. Users may edit content files (design docs, slice files, specs) for context or corrections, but should never need to.

**Commit only after user approval.** No automatic commits mid-phase. Commits happen when a user approves at a review gate (`approveAndCommit`). The user triggers git push manually; the agent never pushes.

**Staging for readability.** At the start of each `planIteration`, `git add` the previous iteration's unstaged changes so VS Code diff shows only the current iteration's new changes. Code files appearing unstaged during planning are unexpected — surface them and confirm before staging.

**Forward-reaching updates.** Changes to any artifact propagate to all existing unimplemented artifacts for cohesion. The target gets a detailed update first; then all existing unimplemented artifacts (design, slices, specs, tasks) get a cohesion pass.

**Per-slice state machines.** Each slice tracks its own state via `status:` frontmatter. Ordering constraint: slice N cannot be approved until slice N-1 is approved. Otherwise, slices progress independently.

**Batch is the default.** A command's full scope runs end-to-end without inter-item gates. Per-slice gates fire only when a slice's state genuinely needs user input — design review, slicing review, signoff review. Confirmations of work the user already authorized are not gates.

### Crash recovery

- On re-entry, every command re-reads state from disk. Never assume state from session context.
- Spec and breakdown are idempotent. If a brief file already exists when a slice is at `speccing`, skip the write and proceed to breakdown. If task files exist when a slice is at `breakdown`, delete and regenerate.
- If a brief and task files both exist for a slice still at `speccing` or `breakdown`, fast-forward the slice to `tasks_ready` and continue.
- If `git add` or `git commit` fails: surface to the user, wait for resolution, do not advance state.
- Missing slice file on resume: log warning, surface to user, stop before advancing.
- Missing `observability/` files: recreate empty headers, continue (observability data loss only).

---

## Vocabulary

Canonical terms — used everywhere, no synonyms.

| Term | Meaning |
|------|---------|
| **user** | The person operating the orchestrator. The only actor term — synonyms like "human", "operator", or a personal name are not used. |
| **active project** | A project under `.orchestration/projects/` not in `done/`. Excluded from globs by every command. |
| **queue** | The ordered list of slices ready for `/implement`, sorted by `status_updated_at` ascending with project-ID tiebreak. |
| **transition** | A state-machine edge — from one node to another, possibly guarded. |
| **action** | A legal verb the agent can take in a given state. The `next_actions` field on a `next-actions` tuple lists these. |
| **agent_type** | Frontmatter field on a task file (`architect`, `server-dev`, `client-dev`, `quality`). The user-facing label for the same is **agent team**. |
| **skip if clean** | Idiom for `git commit` — if the staged set is empty (`git diff --staged --quiet`), don't commit; otherwise commit normally. |

---

## Observability artifacts

Each project stores planning context in `observability/`:

- `.orchestration/projects/{id}/observability/questions.md` — running log of all open/answered questions, timestamped. Read by `interviewQuestions()` and `isPendingQuestions()`.
- `.orchestration/projects/{id}/observability/iterations.md` — replay log: timestamp, current state, what changed, why. Appended at the end of each `planIteration`.
- `.orchestration/projects/{id}/observability/decisions.md` — key decisions with reasoning and rejected alternatives. Appended by `updatePlanningContext`.

These exist for debugging and replay — users never need to read them to operate the system during regular use, but use them to validate output/operation and make targeted improvements.

> A richer replay mechanism that can fully reconstruct state is desirable but deferred. The above is the immediately feasible version.

---

## Types

```ts pseudo
type pendingIterations = {
    answeredQuestions      // raw answered questions from user
    rawFeedback            // raw feedback from user during any review step
    unreviewedManualEdits  // unstaged edits a user made directly to any planning artifacts
                           // graceful handling of an unexpected case — not an expected workflow
}
type openQuestions     // all questions not yet answered — persisted to observability/questions.md
type planningContext   // all planning artifacts + information from iterations

// Note: research agents are deferred to a future project and not modelled here.
```

---

## Methods

```ts pseudo
function isPendingProcessing()
    // any pendingIterations entry is non-empty / not yet applied to planningContext

function isPendingQuestions()
    // openQuestions > 0 (read from observability/questions.md)

function planIteration(targetArtifact) {
    // 1. Stage previous iteration's changes for VS Code diff readability
    //    git add .orchestration/ and related root-context/ or CLAUDE.md changes
    //    If code files appear unstaged: surface to user before staging — unexpected during planning

    // 2. Apply pending inputs
    if (rawFeedback || answeredQuestions || unreviewedManualEdits) {
        updatePlanningContext(rawFeedback)
        updateArtifacts(targetArtifact)
    }

    // 3. Append to replay log
    appendToIterationLog(timestamp, targetArtifact, whatChanged, why)
}

function interviewQuestions() {
    // Read observability/questions.md
    // Select up to 5 open questions by importance and impact on remaining questions
    // Ask user; record questions asked with timestamp in observability/questions.md
}

function summarizeAndAskForApproval() {
    // Summarize changes since last commit:
    //   staged = previous iteration's changes
    //   unstaged = current iteration's new changes
    // Ask for approval or feedback
}

function approveAndCommit(artifacts) {
    // git add all unstaged .orchestration/ + related files (confirm code files if any appear)
    // git commit -m "{appropriate message}"
    // Update slice/design status to reflect approval
    // Push is never triggered by the agent — user does this manually
}

function updatePlanningContext(newContext) {
    // Apply changes from input to planningContext
    // Record key decisions in observability/decisions.md
    // Mark answered questions as resolved in observability/questions.md
}

function updateArtifacts(targetArtifacts) {
    // Primary: update target artifacts in detail with latest planningContext
    targetArtifacts.forEach(create/update artifact)

    // Forward pass: all unimplemented artifacts get a cohesion review and update
    allUnimplementedArtifacts.forEach(deep review in order, update if needed)

    // Surface new interview questions from changes or remaining ambiguities
    // Append to observability/questions.md
}
```

---

## Stage 1 — Design

```
Start: plan-project -> Design.Iterating
    / create project directory
    / load context from CLAUDE.md, .root-context/, architecture files
    / generate initial open questions in observability/questions.md
    / set design doc status: in_progress

Design.Iterating: onDoneIteration {isPendingProcessing()} -> Design.Iterating
    / planIteration(design)

Design.Iterating: onDoneIteration {isPendingQuestions()} -> Design.Asking
    / interviewQuestions()

Design.Iterating: onDoneIteration -> Design.Review
    / summarizeAndAskForApproval()
    / set design doc status: review

Design.Iterating: onAnswer -> Design.Iterating
    / planIteration(design)
    // answer arriving mid-processing is treated the same as waiting for one

Design.Asking: onAnswer -> Design.Iterating
    / planIteration(design)
    // any answer triggers an iteration pass — question answers have design implications

Design.Review: onAnswer {containsFeedback} -> Design.Iterating
    / planIteration(design)
    / set design doc status: in_progress

Design.Review: onAnswer {containsApproval} -> Slicing.Generating
    / approveAndCommit(design)
    / set design doc status: approved
```

---

## Stage 2 — Slicing

```
// Each slice is an independent state machine tracked via slice file frontmatter.
// Ordering constraint: slice N cannot be approved before slice N-1.
// All review-gate states in slicing are Slicing.Review.

Slicing.Generating: onSlicesGenerated -> Slicing.Review
    / generate slice files based on planningContext, status: draft
    / on slicing-gate surface, set every generated slice status: review and review_context: initial

Slicing.Iterating: onDoneIteration {isPendingProcessing()} -> Slicing.Iterating
    / planIteration(sliceN)

Slicing.Iterating: onDoneIteration {isPendingQuestions()} -> Slicing.Review
    / interviewQuestions()
    / set relevant slice status: review

Slicing.Iterating: onDoneIteration -> Slicing.Review
    / summarizeAndAskForApproval()
    / set relevant slice status: review

Slicing.Iterating: onAnswer -> Slicing.Iterating
    / planIteration(slice(s))
    // answer arriving mid-processing is treated the same as waiting for one

// Slicing.Review handles: initial slice reviews, post-iteration summaries, and interview questions.
// Disambiguation is persisted via the review_context: frontmatter field on the slice
// (initial | post_iteration | question) so it survives crashes.

// Note: Slicing.Iterating is only reachable via feedback from Slicing.Review, never from initial flow.
// Initial flow is Generating -> Review -> (approval) -> Speccing. This is intentional: iteration
// only happens when the user has seen the slices and responded with changes.

Slicing.Review: onAnswer {containsFeedback} -> Slicing.Iterating
    / planIteration for each affected slice
    / update affected slices status: review
    // agent output clarifies which slices the feedback applies to

Slicing.Review: onAnswer {containsApproval} -> Slicing.Speccing
    / approveAndCommit(specifiedSlices)
    / set approved slices status: speccing
    // ordering constraint enforced here: slice N blocked if slice N-1 not yet approved
    // agent output indicates which slices are being approved

// Spec and breakdown are atomic from the user's perspective — no review gate between them.
// But each is tracked in frontmatter for crash recovery and observability.

Slicing.Speccing: onAllApprovedSlicesSpecced -> Slicing.Breakdown
    / begin breakdown immediately
    // each slice transitions speccing -> breakdown -> tasks_ready independently
    // "all" means all currently approved slices in this batch

Slicing.Breakdown: onAllSpeccedBrokenDown -> Implementation.Asking
    / all approved slices now tasks_ready
    / surface implementation start prompt
```

---

## Stage 3 — Implementation

```
// Implementation.Asking is a start gate, not a selection gate.
// Implementation always runs all tasks_ready work.
// Its purpose: give the user a chance to approve and batch more slices before execution starts.

Implementation.Asking: onImplementationStarted -> Implementation.Running
    / confirm agent team
    / set first implementing slice status: implementing

Implementation.Running: onTaskDone {tasksPending > 0} -> Implementation.Running
    / implement next runnable task (step order, respecting depends_on)

Implementation.Running: onTaskDone {tasksPending == 0} -> Implementation.QA
    / begin QA for first un-QA'd implemented slice

// QA auto-retries without a fixed limit. The agent tries different approaches.
// Escalation to Signoff.Review happens only when the agent explicitly cannot continue.

Implementation.QA: onQAComplete {qaPass && morePending} -> Implementation.Running
    / advance to next slice in execution list
    / set next slice status: implementing

Implementation.QA: onQAComplete {qaPass && !morePending} -> Signoff.Review
    / set slice status: signoff_review, qaResult: pass

Implementation.QA: onQAComplete {qaFailure && fixable} -> Implementation.QA
    / apply fixes, rerun QA
    // no retry cap — agent tries multiple distinct approaches until fixed

Implementation.QA: onQAComplete {qaFailure && stuck} -> Signoff.Review
    / set slice status: signoff_review, qaResult: failure
    // agent surfaces exactly why it's stuck; user response unblocks
```

---

## Stage 4 — Signoff

```
Signoff.Review: onAnswer {qaFailure && userFixProvided} -> Implementation.QA
    / apply user fix (direct code change, agent-guided fix, or new dot-notation slice e.g. 5.1)
    / set slice status: qa_in_progress

Signoff.Review: onAnswer {containsFeedback} -> Signoff.Review
    / write draft follow-up slice(s) with follow_up_of: NN, dot-notation order (e.g. 5.1)
    / continue the batch — no pause for /plan-project handoff
    // /plan-project picks up draft follow-ups via follow_up_of: in a later run

Signoff.Review: onAnswer {containsApproval} -> Signoff.Approved
    / approveAndCommit(slice)
    / set slice status: done

Signoff.Approved: onCommitted {moreSignoffSlicesInProject > 0} -> Signoff.Review
    / continue the signoff batch with the next slice in slice-number order

Signoff.Approved: onCommitted {moreSignoffSlicesInProject == 0 && unfinishedSlicesRemaining > 0} -> End
    / project not yet complete — user runs /plan-project or /implement to advance other slices

Signoff.Approved: onCommitted {unfinishedSlicesRemaining == 0} -> End
    / summary of project
    / archive project
```

---

## Frontmatter schemas

Single source of truth. Every artifact's frontmatter is defined here. Commands and agents reference this section instead of restating fields.

### Design doc (`01-design/design-{NN}.md`)

| field | type | values | required |
|-------|------|--------|----------|
| type | string | `"design"` | yes |
| date | string (ISO 8601 date) | — | yes |
| feature | string (kebab-case) | — | yes |
| project_id | string | matches project folder name | yes |
| status | enum | `in_progress` \| `review` \| `approved` | yes |

### Slice (`02-slices/{NN}-{slug}.md`)

| field | type | values | required |
|-------|------|--------|----------|
| type | string | `"slice"` | yes |
| slice | string \| integer | `NN` or `NN.N` (dot-notation follow-ups) | yes |
| order | string \| integer | matches `slice` (canonical sort key) | yes |
| project | string | feature kebab-case | yes |
| design | string | path to design doc | yes |
| status | enum | `draft` \| `review` \| `speccing` \| `breakdown` \| `tasks_ready` \| `implementing` \| `qa_in_progress` \| `signoff_review` \| `done` | yes |
| status_updated_at | string (ISO 8601 with tz) | — | yes after any status write |
| review_context | enum | `initial` \| `post_iteration` \| `question` | when `status: review` |
| follow_up_of | string \| integer | parent slice number | only for follow-ups |

### Task (`04-tasks/slice-{NN}/{NN}-{slug}.md`)

| field | type | values | required |
|-------|------|--------|----------|
| spec | string | path to brief | yes |
| slice | integer | parent slice number | yes |
| step | integer | step order within slice | yes |
| title | string | — | yes |
| status | enum | `todo` \| `in_progress` \| `done` | yes |
| depends_on | array of filenames | empty for first or independent | yes |
| agent_type | enum | `architect` \| `server-dev` \| `client-dev` \| `quality` | yes |
| model | string | `sonnet` \| `opus` \| `haiku` | yes |
| effort | string | `default` \| `max` | yes |
| assigned_at | string (ISO 8601) \| null | — | yes |
| completed_at | string (ISO 8601) \| null | — | yes |
| qa_result | enum \| null | `pass` \| `fixed` \| `manual` | set by QA |

---

## Slice status values

Valid `status:` values in slice file frontmatter, in pipeline order.

> **Debugging heuristic:** when something's broken, start here. Does the file status match the state the orchestrator thinks it's in? If yes, the bug is in a transition. If no, the bug is in a status update.

| Status | State | Meaning |
|--------|-------|---------|
| `draft` | initial | Slice created, not yet reviewed |
| `review` | Slicing.Review | Agent waiting for user input (slice review, interview, or iteration summary) |
| `speccing` | Slicing.Speccing | Spec being written; stored for crash recovery |
| `breakdown` | Slicing.Breakdown | Task breakdown in progress; stored for crash recovery |
| `tasks_ready` | queued | Breakdown complete, ready to implement |
| `implementing` | Implementation.Running | Tasks executing |
| `qa_in_progress` | Implementation.QA | QA running, including auto-retries |
| `signoff_review` | Signoff.Review | QA complete (pass or stuck), waiting for user signoff |
| `done` | End | Approved, committed, archived |

## Design document status values

`status:` field in `01-design/design-{NN}.md` frontmatter:

| Status | Meaning |
|--------|---------|
| `in_progress` | Being written or iterated on |
| `review` | Agent asked for approval; waiting for user response |
| `approved` | Human approved; slicing in progress or complete |

---

## Error handling

### Git operations
- `git add` or `git commit` failure: surface to user, wait for resolution — do not advance state
- Push: user-triggered only; agent never pushes

### Crash and resume
- On re-entry: read all slice files and design doc from disk — never assume state from session context
- `speccing` or `breakdown` status: re-run the operation; it is idempotent
  - Spec file already exists → skip write, continue to breakdown
  - Task file count mismatches breakdown table → delete all and regenerate
- Design doc `status: review`: resurface the approval prompt
- Slice `status: review`: check `observability/questions.md` for what was last asked; resurface it

### Unexpected code file changes during planIteration staging
- Detect via `git status` before `git add`
- If code files appear unstaged: "These code files changed during planning: [list]. Stage them too?"
- Wait for confirmation — code changes during planning are unexpected

### Missing or corrupted artifacts
- Missing slice file on resume: log warning, surface to user, stop before advancing state
- Missing `observability/` files: recreate empty, continue (observability data loss only)

### QA escalation
- No retry cap — agent tries multiple distinct approaches
- Escalate to Signoff.Review when agent cannot proceed without user input
- Human fix options: direct code edit, agent-guided fix, new dot-notation slice (e.g. 5.1)
- After user fix confirmed: transition slice back to `qa_in_progress`, rerun QA
