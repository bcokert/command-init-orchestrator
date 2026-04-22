**Type:** Task (AI agent)
**Date:** 2026-04-21

---

### 1. Intent

Slicing currently has no feedback loop. If the operator provides feedback on slices, they have to edit the files manually and re-run. Design phase has a full iteration loop — feedback triggers planIteration, which updates artifacts and resurfaces for review. Slicing should work the same way. This slice adds `Slicing.Iterating` behavior to `plan-project.md`: when the operator provides feedback at the slicing gate, the agent runs planIteration on the affected slices, updates all unimplemented artifacts for cohesion, and resurfaces with a summary. Approval at the slicing gate advances to speccing.

Only `defaults/commands/plan-project.md` changes. Version `2.8.0 → 2.9.0`.

---

### 2. Observable outcomes

**Feedback triggers planIteration**
```
Given plan-project at the slicing gate showing slices for review
When the operator provides feedback ("slice 2 should also cover X")
Then plan-project runs planIteration on the affected slices
And resurfaces the updated slices with a summary of what changed
```

**Approval advances to speccing**
```
Given plan-project at the slicing gate
When the operator approves ("looks good", "approved", "LGTM")
Then plan-project advances to speccing (approveAndCommit + transition)
```

**Ambiguous answer → planIteration, not accidental approval**
```
Given the operator responds with a question or partial statement at the slicing gate
When the response contains no clear approval signal
Then plan-project treats it as implied feedback/question and runs planIteration
Not: accidentally advancing to spec
```

**Forward cohesion on iteration**
```
Given slices 03–08 are unimplemented when slice 02 is updated via planIteration
When planIteration runs for slice 02
Then slices 03–08 receive a cohesion pass and are updated if the change has implications for them
```

**Iteration staging**
```
Given a second planIteration pass during slicing
When it starts
Then previous pass's slice file changes are staged via git add .orchestration/
```

---

### 3. Constraints

**Must:**
- Add feedback detection to the slicing gate: distinguish between feedback (any non-approval answer), approval (explicit "approved", "looks good", "LGTM", or equivalent), and ambiguous (everything else treated as feedback/implied question).
- On feedback: call planIteration(affected slices). Update target slices in detail first; forward-pass remaining unimplemented slices for cohesion.
- On approval: call approveAndCommit(approved slices), set slice status to the next state (advance to speccing).
- On ambiguous: call planIteration, resurface with summary and re-ask.
- Slicing gate message updated: no longer tells operator to edit manually. Asks for approval or feedback.
- Staging applies: planIteration during slicing starts with git add .orchestration/ (consistent with slice 03 behavior).
- Bump version: `2.8.0 → 2.9.0`.

**Must not:**
- Touch any file outside `defaults/commands/plan-project.md`.
- Allow an ambiguous response to be treated as approval.
- Re-run planIteration on slices already at `tasks_ready` or beyond during cohesion pass.

**Escalation triggers:**
- If the existing plan-project.md has no section for the slicing gate response handling: identify where the gate message is shown, add the response-handling logic immediately after it, and report what was added.

---

### 4. Done definition

- Read plan-project.md: slicing gate message does not tell operator to edit files manually; it asks for approval or feedback.
- Read plan-project.md: feedback response path calls planIteration and resurfaces with summary.
- Read plan-project.md: approval response path calls approveAndCommit and advances to speccing.
- Read plan-project.md: ambiguous response treated as feedback (planIteration), not approval.
- Version reads `2.9.0`.

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Update slicing gate message | Gate no longer instructs manual editing; asks for approval or feedback | Read file: gate message asks in conversation, no "edit directly" instruction |
| 2 | Add feedback/approval/ambiguous detection and response handling | Three branches: planIteration, approveAndCommit, planIteration-with-resurface | Read file: all three branches present after slicing gate |
| 3 | Add forward cohesion pass to planIteration for slices | Unimplemented slices receive a cohesion pass after target slice is updated | Read file: planIteration section references cohesion pass on subsequent slices |
| 4 | Version bump and coherence pass | Version `2.9.0`; no contradictions | Frontmatter reads `2.9.0` |
