**Type:** Task (AI agent)
**Date:** 2026-04-21

---

### 1. Intent

Two problems in the execution pipeline. First: `/implement` starts immediately after breakdown with no gate — the operator has no moment to confirm they're ready, review the agent team, or decide to batch more slices before execution. Second: QA escalates to signoff_review after a fixed number of retries, even when more approaches exist. An agent that gives up after three attempts wastes human review time on things it could have fixed. This slice adds an `Implementation.Asking` gate before execution and changes QA to retry indefinitely until the agent explicitly declares it cannot continue.

Files: `defaults/commands/implement.md`, `defaults/commands/qa.md`.

---

### 2. Observable outcomes

**Implementation.Asking gate**
```
Given all approved slices at tasks_ready
When /implement is run
Then it shows: total task count across ready slices, proposed agent team, "Ready to start?"
And waits for operator confirmation before executing any tasks
```

**"Review more slices" loop**
```
Given the operator responding "let me review more slices first" at Implementation.Asking
When that response is received
Then /implement surfaces the next pending slice(s) for review
And after those slices reach tasks_ready, returns to Implementation.Asking (not straight to Running)
```

**Multiple slices aggregate count**
```
Given slices 01 and 02 both at tasks_ready with 4 tasks each
When Implementation.Asking runs
Then it shows "8 tasks across 2 slices" — aggregate, not per-slice
```

**QA retries without escalating**
```
Given QA failing on a fixable issue
When the fix attempt runs
Then QA retries with a different approach — no escalation to signoff_review
And this repeats as many times as needed until fixed or the agent is genuinely stuck
```

**QA escalation requires explicit stuck declaration**
```
Given QA failing after multiple attempts
When the agent cannot fix it without human input
Then the agent explicitly states: "I cannot fix this without human input" plus a reason
And only then transitions to signoff_review
```

**Human fix returns to qa_in_progress**
```
Given a slice at signoff_review with QA failed
When the human provides a fix (code edit, guided fix, or new dot-notation slice)
Then the slice transitions back to qa_in_progress and QA reruns
```

---

### 3. Constraints

**Must:**
- Add Implementation.Asking gate to implement.md: before Phase 2 (task execution), show task count, agent team, and ask "Ready to start?". Wait for confirmation.
- Add "review more slices" path: if operator says they want more slices reviewed first, surface next pending slice; after it reaches tasks_ready, return to Implementation.Asking.
- Task count at Implementation.Asking is aggregate across all tasks_ready slices.
- Update qa.md: remove any fixed retry cap. The agent retries with meaningfully different approaches until fixed or stuck.
- Update qa.md: escalation to signoff_review requires the agent to explicitly write "I cannot fix this without human input" and give a reason. Vague or partial attempts do not count.
- Add to implement.md or qa.md: when a human provides a fix at signoff_review for a QA failure, slice transitions back to `qa_in_progress` and QA reruns.
- Bump implement.md version: `2.5.0 → 2.6.0` (this is after slice 02's bump from the original `2.5.0`; verify the current version before bumping).
- Bump qa.md version: `1.1.0 → 1.2.0`.

**Must not:**
- Add a retry cap to QA — the agent decides when it's stuck, not a counter.
- Allow vague fix attempts to count as genuine escalation-qualifying attempts.
- Touch any file outside `defaults/commands/implement.md` and `defaults/commands/qa.md`.

**Preferences:**
- Implementation.Asking gate integrates naturally with the existing Phase 1 (Agent team) — extend that section rather than adding a new phase.

**Escalation triggers:**
- If the current implement.md version is not `2.5.0` (slice 02 may have changed it): read the current version before bumping, and bump one minor from whatever it is.
- If the "review more slices" path requires knowing what slices are pending in plan-project: note how implement.md will communicate this to the operator (it cannot call plan-project directly) and surface it in the output prompt.

---

### 4. Done definition

- Read implement.md: Phase 1 or equivalent section includes a confirmation gate before task execution. Shows task count (aggregate), agent team, and waits for confirmation. Version is current + 1 minor.
- Read implement.md: "review more slices" path described; returns to Implementation.Asking after next slice is ready.
- Read qa.md: no fixed retry cap. Escalation requires explicit "I cannot fix this without human input" statement. Version `1.2.0`.
- Read implement.md or qa.md: human-fix → qa_in_progress transition described.

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Add Implementation.Asking gate to implement.md | Gate shows aggregate task count + agent team + confirmation; "more slices" path described; correct version | Read file: gate present before execution; "more slices" path present; version bumped |
| 2 | Update qa.md: remove retry cap, add explicit stuck declaration requirement | No retry cap; escalation requires explicit statement; human-fix → qa_in_progress; version `1.2.0` | Read file: no cap, explicit stuck requirement, human-fix transition, version `1.2.0` |
