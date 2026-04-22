# State diagram of orchestrator

On a per project basis. Order of transitions and guards is relevant — short circuit on the first matching transition.

## Principles

**Agent owns all transitions.** The human never edits status files. They respond to agent prompts; the agent writes all status updates. Humans may edit content files (design docs, slice files, specs) for context or corrections, but should never need to.

**Commit only after human approval.** No automatic commits mid-phase. Commits happen when a human approves at a review gate (`approveAndCommit`). The human triggers git push manually; the agent never pushes.

**Staging for readability.** At the start of each `planIteration`, `git add` the previous iteration's unstaged changes so VS Code diff shows only the current iteration's new changes. Code files appearing unstaged during planning are unexpected — surface them and confirm before staging.

**Forward-reaching updates.** Changes to any artifact propagate to all existing unimplemented artifacts for cohesion. The target gets a detailed update first; then all existing unimplemented artifacts (design, slices, specs, tasks) get a cohesion pass.

**Per-slice state machines.** Each slice tracks its own state via `status:` frontmatter. Ordering constraint: slice N cannot be approved until slice N-1 is approved. Otherwise, slices progress independently.

---

## Observability artifacts

Each project stores planning context in `observability/`:

- `.orchestration/projects/{id}/observability/questions.md` — running log of all open/answered questions, timestamped. Read by `interviewQuestions()` and `isPendingQuestions()`.
- `.orchestration/projects/{id}/observability/iterations.md` — replay log: timestamp, current state, what changed, why. Appended at the end of each `planIteration`.
- `.orchestration/projects/{id}/observability/decisions.md` — key decisions with reasoning and rejected alternatives. Appended by `updatePlanningContext`.

These exist for debugging and replay — humans never need to read them to operate the system during regular use, but use them to validate output/operation and make targeted improvements.

> A richer replay mechanism that can fully reconstruct state is desirable but deferred. The above is the immediately feasible version.

---

## Types

```ts pseudo
type pendingIterations = {
    answeredQuestions      // raw answered questions from human
    rawFeedback            // raw feedback from human during any review step
    unreviewedManualEdits  // unstaged edits a human made directly to any planning artifacts
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
    //    If code files appear unstaged: surface to human before staging — unexpected during planning

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
    // Ask human; record questions asked with timestamp in observability/questions.md
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
    // Push is never triggered by the agent — human does this manually
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
// All human-gate states in slicing are Slicing.Review.
// (Slicing.Asking from an earlier draft was a mistake — it's all Slicing.Review.)

Slicing.Generating: onSliceGenerated {slicesLeftToGenerate > 0} -> Slicing.Generating
    / generate next slice(s) based on planningContext
    / set new slices status: draft

Slicing.Generating: onSliceGenerated {slicesLeftToGenerate == 0} -> Slicing.Review
    / surface 1-N slices for human review
    / set pending slices status: review

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
// The agent's output clarifies what it's asking for. The transitions are the same regardless.
// Slicing.Review disambiguates via last prompt context — the agent tracks what it last asked.

// Note: Slicing.Iterating is only reachable via feedback from Slicing.Review, never from initial flow.
// Initial flow is Generating -> Review -> (approval) -> Speccing. This is intentional: iteration
// only happens when the human has seen the slices and responded with changes.

Slicing.Review: onAnswer {containsFeedback} -> Slicing.Iterating
    / planIteration for each affected slice
    / update affected slices status: review
    // agent output clarifies which slices the feedback applies to

Slicing.Review: onAnswer {containsApproval} -> Slicing.Speccing
    / approveAndCommit(specifiedSlices)
    / set approved slices status: speccing
    // ordering constraint enforced here: slice N blocked if slice N-1 not yet approved
    // agent output indicates which slices are being approved

// Spec and breakdown are atomic from the human's perspective — no review gate between them.
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
// Its purpose: give the human a chance to approve and batch more slices before execution starts.

Implementation.Asking: onAnswer {wantMoreSlicesBrokenDown} -> Slicing.Review
    / surface next pending slice(s) for review
    // after those slices reach tasks_ready -> return to Implementation.Asking

Implementation.Asking: onImplementationStarted -> Implementation.Running
    / confirm agent team
    / set first implementing slice status: implementing

Implementation.Running: onTaskDone {tasksPending > 0} -> Implementation.Running
    / implement next runnable task (step order, respecting depends_on)

Implementation.Running: onTaskDone {tasksPending == 0} -> Implementation.QA
    / begin QA for first un-QA'd implemented slice

// QA auto-retries without a fixed limit. The agent tries different approaches.
// Escalation to Signoff.Review happens only when the agent explicitly cannot continue.

Implementation.QA: onQAComplete {qaPass && morePending} -> Implementation.QA
    / run QA for next un-QA'd implemented slice

Implementation.QA: onQAComplete {qaPass && !morePending} -> Signoff.Review
    / set slice status: signoff_review, qaResult: pass

Implementation.QA: onQAComplete {qaFailure && fixable} -> Implementation.QA
    / apply fixes, rerun QA
    // no retry cap — agent tries multiple distinct approaches until fixed

Implementation.QA: onQAComplete {qaFailure && stuck} -> Signoff.Review
    / set slice status: signoff_review, qaResult: failure
    // agent surfaces exactly why it's stuck; human response unblocks
```

---

## Stage 4 — Signoff

```
Signoff.Review: onAnswer {qaFailure && humanFixProvided} -> Implementation.QA
    / apply human fix (direct code change, agent-guided fix, or new dot-notation slice e.g. 5.1)
    / set slice status: qa_in_progress

Signoff.Review: onAnswer {containsFeedback} -> Slicing.Generating
    / planIteration(slice)
    / generate new slice(s) for the feedback (dot notation: e.g. 5.1)
    // new slices start at draft, go through the full Slicing.Review -> Speccing -> Breakdown flow

Signoff.Review: onAnswer {containsApproval} -> Signoff.Approved
    / approveAndCommit(slice)
    / set slice status: done

Signoff.Approved: onCommitted {unfinishedSlicesRemaining > 0} -> Slicing.Review
    / surface next 1-N slices for review

Signoff.Approved: onCommitted {unfinishedSlicesRemaining == 0} -> End
    / summary of project
    / archive project
```

---

## Slice status values

Valid `status:` values in slice file frontmatter, in pipeline order.

> **Debugging heuristic:** when something's broken, start here. Does the file status match the state the orchestrator thinks it's in? If yes, the bug is in a transition. If no, the bug is in a status update.

| Status | State | Meaning |
|--------|-------|---------|
| `draft` | initial | Slice created, not yet reviewed |
| `review` | Slicing.Review | Agent waiting for human input (slice review, interview, or iteration summary) |
| `speccing` | Slicing.Speccing | Spec being written; stored for crash recovery |
| `breakdown` | Slicing.Breakdown | Task breakdown in progress; stored for crash recovery |
| `tasks_ready` | queued | Breakdown complete, ready to implement |
| `implementing` | Implementation.Running | Tasks executing |
| `qa_in_progress` | Implementation.QA | QA running, including auto-retries |
| `signoff_review` | Signoff.Review | QA complete (pass or stuck), waiting for human signoff |
| `done` | End | Approved, committed, archived |

## Design document status values

`status:` field in `01-design/design-{NN}.md` frontmatter:

| Status | Meaning |
|--------|---------|
| `in_progress` | Being written or iterated on |
| `review` | Agent asked for approval; waiting for human response |
| `approved` | Human approved; slicing in progress or complete |

---

## Error handling

### Git operations
- `git add` or `git commit` failure: surface to human, wait for resolution — do not advance state
- Push: human-triggered only; agent never pushes

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
- Missing slice file on resume: log warning, surface to human, stop before advancing state
- Missing `observability/` files: recreate empty, continue (observability data loss only)

### QA escalation
- No retry cap — agent tries multiple distinct approaches
- Escalate to Signoff.Review when agent cannot proceed without human input
- Human fix options: direct code edit, agent-guided fix, new dot-notation slice (e.g. 5.1)
- After human fix confirmed: transition slice back to `qa_in_progress`, rerun QA
