---
type: design
date: 2026-05-06
feature: batch-slice-flow
project_id: bcokert-00007-batch-slice-flow
status: approved
---

# Batch slice flow — Design

## Intent

The orchestrator stops too often. Tell it to "approve all slices" and it approves one and waits for next steps. Tell it to "implement all ready slices" and it preps one and asks which team to use. Tell it to plan multiple slices and it pauses for team confirmation between every spec/breakdown. The mental model is "do everything you can without bothering me until something needs my eyes." The implementation is "fire one gate per slice, regardless of intent."

Fix this by making every command compute its full scope on entry, run the entire batch end-to-end, and stop only at gates that genuinely require a human (design review, slicing review, signoff review). Confirmations of work the human already authorized are not gates — they get cut. A shared next-actions reader replaces ad-hoc state detection scattered across commands. Free-form natural language handles subset directives.

State stays where it is — slice frontmatter, design doc frontmatter. Project 00006 (api-first orchestrator) replaces the storage layer entirely; introducing a state.json bridge here would be discarded. The shared reader globs and aggregates frontmatter on entry — every command, same source.

## Current state

- `/review` handles one slice per run. With multiple at `signoff_review`, it lists and prompts for selection. Approving one slice does not advance to the next — the user re-runs `/review`.
- `/plan-project` Phase 7 fires team-confirmation gates twice — per slice during the speccing/breakdown loop, and a final batched confirmation at end of breakdown. Both drain batched runs.
- `/implement` Phase 1 has a "review more slices first" branch that detours back to `/plan-project`. Used rarely; adds branching to the start gate.
- `/implement` Phase 1 fires its team-confirmation gate every time it's invoked, including re-entry after slice 1 reaches `signoff_review` and slice 2 is queued.
- Each command has its own state-detection logic that globs and reads frontmatter. No shared reader. Four different glob patterns for the same intent across plan/implement/review/status.
- `/review` Phase 1 step 2.d prompts per untracked file outside `.orchestration/` during the approve commit. Drains the batch into per-file confirmations.
- `/plan-project` planIteration prompts whenever code files appear unstaged. Fires every iteration on incidental edits.
- `init-orchestrator` prompts per file on version mismatch — up to 12 prompts on a re-run.
- State diagram includes `Implementation.Asking: onAnswer {wantMoreSlicesBrokenDown}` matching the legacy /implement branch.
- State diagram's `Signoff.Approved -> Slicing.Review` transition fires on any unfinished work, conflating signoff continuation with slicing review.
- State diagram has additional drift: `Signoff.Review.containsFeedback -> Slicing.Generating` doesn't match `/review` Phase 2 (writes draft, returns). `Implementation.QA -> Implementation.QA` "morePending" should route via `Implementation.Running`. `Slicing.Generating` self-loop has no command behavior. `Slicing.Review` is overloaded for initial-review / post-iteration / interview-questions with no persisted disambiguation.
- Legacy/dead state values still referenced: `specced` (plan-project Phase 0), `reviewed` (status.md aliases), `feedback_pending` (defaults/README, plan-project) — none in active use.
- Duplicate routing rows: `plan-project.md:43` "no slice in {…}" row is mutually exclusive with Step 1's selection. `implement.md:54` "all tasks done → Phase 3" duplicates Phase 2 step 5.
- The bdonize block (sentence case headings, AI-vocabulary list, voice notes) is copy-pasted across `slice.md`, `spec.md`, and `plan-project.md`.
- Stale references: `spec.md:139` mentions `/delegate` which doesn't exist. `state-diagram.md:158` carries a "Slicing.Asking from an earlier draft" comment for a never-shipped state.
- README and diagrams drift: `README.md:40` lists "spec review" as a gate that doesn't exist. `defaults/README.md:9-31` stage table includes `spec_in_progress`, `spec_review`, `feedback_pending` — none of which are real states. `docs/diagrams/lifecycle.d2:79-99` shows a `spec_review` diamond gate. `docs/diagrams/multi-slice-sequence.d2:51-90` archives every slice instead of only on full completion.
- Subset directives ("approve 1, kickoff 2") have no command-level affordance — agents wing it without explicit support.
- `/status` reads frontmatter directly and produces output, but its scoping logic is not reused by other commands.

## Desired end state

- `/review`: one run = one project. Auto-pick if only one project has signoff slices; prompt if multiple. Iterate the project's signoff slices in order. Per-slice prompt accepts approve, feedback, or ambiguous. Ambiguous re-asks once, then defaults to feedback. Archive only if all original slices got approved AND no new draft slices were created from feedback. Untracked files outside `.orchestration/` get staged automatically with a single summary line — no per-file prompt.
- `/implement`: one team-confirmation gate at start, batched across all `tasks_ready` slices in scope. After approval, run every slice through implementation and QA to `signoff_review` without stopping. On re-entry, the gate fires again only if the team mix changed; otherwise proceed.
- `/plan-project`: zero team-confirmation gates. Both the per-slice gate and the end-of-batch gate are cut. The breakdown loop runs spec/breakdown for every approved slice with no inter-slice prompt. Slicing review accepts per-slice approve/feedback in one response. planIteration's "code files appear unstaged" check stages with a one-line summary, no block prompt.
- `/status`: uses the shared reader (read-only, no behavior change for the user).
- `init-orchestrator`: one consolidated update gate ("N files would update — accept all / review per-file / skip") instead of N per-file prompts.
- A shared next-actions reader (`.orchestration/support/next-actions.md`) returns, for every active project, tuples of `(project_id, artifact_kind, artifact_id, status, status_updated_at, next_actions)` where `artifact_kind ∈ {project_root, design, slice}` and `next_actions` is a list of legal verbs (mirrors 00006's planned `GET /graph/state`). Each command calls it on entry, filters to its scope, executes the batch.
- A shared status-write helper (`.orchestration/support/write-slice-status.md`) replaces the 8 inline "Write status: X and status_updated_at" blocks across plan-project, implement, review, qa.
- A shared agent preamble (`defaults/agents/_common-preamble.md`) holds the canonical read-order, escalation triggers, and task-completion protocol. The five agent files list role-specific deltas only.
- A consolidated bdonize voice block at `.orchestration/support/bdonize.md`, referenced by slice.md, spec.md, and plan-project.md.
- state-diagram.md becomes the single anchor: principles (incl. crash recovery), frontmatter schemas (slice, design, task) as typed tables (`field | type | values | required`) for 00006 portability, vocabulary glossary including "transition" and "action" terms, "skip if clean" idiom. Per-command "Behavior rules" sections cut to deltas only.
- Vocabulary unified across shipped defaults: "user" canonical, "active project" canonical, "queue" canonical. "Bdon", "human", and "operator" removed from defaults that ship to other users.
- Command files shrunk while keeping accuracy: plan-project.md -35%, implement.md -29%, review.md -54%, status.md -27% — ~36% combined, ~333 lines.
- Free-form subset directives parse: agent picks intent from natural language ("approve 1 and 2, feedback on 3"). Slice IDs may be passed as args for explicitness.
- Bdonize voice block consolidated into a single support file (`.orchestration/support/bdonize.md`), referenced by `slice.md`, `spec.md`, and `plan-project.md`.
- Slicing.Review disambiguation persisted via `review_context:` frontmatter on slice files (values: `initial`, `post_iteration`, `question`) — replaces the brittle "agent tracks last prompt" model.
- Legacy/dead state values purged: `specced` row in plan-project Phase 0 deleted, `reviewed` aliases in status.md deleted, `feedback_pending` terminology replaced with `follow_up_of:` reality across defaults/README.md and plan-project.md.
- Duplicate routing rows deleted: plan-project Phase 0 dead row (line 43), implement.md "all tasks done" duplicate (line 54).
- Stale references purged: `/delegate` mention in spec.md, "Slicing.Asking" comment in state-diagram.md.
- README and diagrams refreshed: README.md "spec review" gate dropped, defaults/README.md stage table rebuilt from canonical state set (anchored in state-diagram.md), lifecycle.d2 spec_review diamond removed, multi-slice-sequence.d2 corrected to archive only on full completion.
- State diagram: `wantMoreSlicesBrokenDown` transition removed. `Signoff.Approved` split into batch-aware transitions. `Signoff.Review.containsFeedback` retargeted to match command flow. `Implementation.QA -> Running` transition added. `Slicing.Generating` self-loop collapsed. New principle near the top stating batch is the default.

## Patterns to follow

- **Batch is the default.** A command with scope larger than one item operates over its whole scope without inter-item gates. The agent stops only for genuine human input.
- **Stop only at real review gates.** Design review, slicing review, signoff review. Confirmations of authorized work are not gates.
- **Compute scope on entry.** Each command reads state once at start and builds its execution list. New work appearing mid-run is picked up on the next invocation.
- **Per-slice independence.** Each slice has its own state machine. Cross-slice ordering (slice N requires slice N-1 approved) is the only dependency.
- **No state.json yet.** Slice and design frontmatter remain authoritative. Shared reader aggregates in-process.
- **Plan-project stays per-project.** Cross-project planning is not batched; each project's design and slicing is human-driven enough that fan-out doesn't help.
- **Re-entry tolerance.** Every command can be invoked from any state mid-batch. The shared reader determines what's possible; the command does it.
- **Defaults cohesion.** `defaults/commands/` and `.claude/commands/` stay in sync. Version bumps required on every defaults file touched.

## Key edge cases

- **Mixed batch in /review:** 5 signoff slices, user approves 3, gives feedback on 1, approves 1 more. Each handled as it arrives. Feedback creates dot-notation slices and continues the loop. Final summary: "Approved {N}, feedback on {M}." Archive only if all original slices approved AND no new draft slices created.
- **Subset directives during slicing review:** "approve 1 and 2, feedback on 3-5". Agent splits the response — slices 1, 2 advance to `speccing`; slices 3, 4, 5 get planIteration treatment and stay at `review`. Re-surface 3-5 only.
- **Re-entry to /implement mid-batch:** slice 1 done, slice 2 implementing (crash), slice 3 tasks_ready. /implement reads state, resumes slice 2 from its last task, continues to slice 3. Team gate re-fires (team mix may have shifted on crash); user reconfirms once for the remaining batch.
- **Re-entry to /review with one signoff left:** previous run handled slices 1-3, fed back on 4, approved 5. After /plan-project advances the new draft, user runs /review. Picks slice 4 (the only signoff in this project), single-slice batch, archives if all done.
- **Empty action menu:** all commands report "nothing to do" with the proper next-step hint.
- **Cross-project /implement:** queue ordered by `status_updated_at` ascending, project-ID tiebreak. One team gate at start. Runs all queued slices across all projects to `signoff_review`.
- **Ambiguous response in /review batch:** agent re-asks once on the same slice; if still ambiguous, treats as feedback and continues the batch. Approval errs to the safe side because feedback is recoverable; an accidental approve commits.
- **Multi-project signoff /review with no arg:** more than one project has signoff slices. Agent prompts which project to review (project-level prompt, not slice-level). After picking, batches that project's slices.
- **Crash during shared-reader call:** if the read fails (filesystem error mid-glob), command surfaces the error and stops. No partial scope execution.
- **State drift mid-run:** a /plan-project commits a new tasks_ready slice while /implement is running. /implement ignores it (scope was computed on entry). Picked up next /implement run.
- **/review with surprising untracked files:** if the staging summary at approve-commit time shows files the user doesn't expect (e.g. unrelated edits in the workspace), the user can abort the commit before it runs. The summary line is the safety check that replaces per-file prompts.
- **planIteration with surprising code edits:** same as above — staging summary surfaces the count and paths, user aborts if needed.
- **init-orchestrator partial accept:** "review per-file" branch falls back to the old per-file flow for explicit review. "skip" leaves the install untouched and reports which files would have changed.
- **plan-project picks up a follow_up_of: slice:** Phase 0 routes it as draft for review, but the surfacing distinguishes "follow-up from prior signoff feedback" from "fresh draft" so the user knows what they're approving.
- **Mixed slicing-review response in plan-project:** "approve 1, 2; feedback on 3-5" splits — approved subset advances to `speccing` (with `status_updated_at` written); 3-5 stay at `review` and run planIteration; only 3-5 resurface.
- **Slice-batch status writes:** when surfacing the slicing gate, plan-project writes `status: review` AND `review_context: initial` to every generated slice in one pass — not just slice 01.

## Resolved design decisions

- **Decision:** Cut Phase 7 team-confirmation gate from /plan-project. Team is implicit from per-task `agent_type`. /implement's Phase 1 gate is the single team-confirmation point.
  **Why:** Per-slice gates during a batched plan-project run drain the speccing/breakdown loop into single-slice work, the exact failure this project fixes.
  **Rejected:** Keeping a single batched team gate at end of plan-project. Rejected because /implement already has one — dual confirmation is redundant.

- **Decision:** /review = one project at a time. No-arg auto-picks the only project with signoff slices, or prompts at project level if multiple. Iterates all signoff slices for the chosen project as a batch.
  **Why:** Humans review the whole implemented surface for a project, not one slice at a time. The unit of review is "all implemented code for the project."
  **Rejected:** System-wide /review iteration. Rejected because review is per-project semantically.
  **Rejected:** Slice-level prompt when multiple signoff slices exist in one project. Rejected because that's the per-slice gate this project removes.

- **Decision:** Keep four commands (/plan-project, /implement, /review, /status). Each becomes a thin wrapper over the shared next-actions reader, and batches its whole scope.
  **Why:** Smallest surface change. Aligns with the api-first server (each command corresponds to a verb on the server later). /status stays read-only.
  **Rejected:** New /do command surfacing all next-actions and dispatching. Rejected because it adds surface.
  **Rejected:** Fold next-actions into /status. Rejected because /status is read-only by design.

- **Decision:** No state.json. Slice and design frontmatter remain authoritative. Shared next-actions reader aggregates on read.
  **Why:** Project 00006 (api-first orchestrator) replaces storage entirely. A local state.json bridge would be thrown away.
  **Rejected:** Top-level state.json as the source of truth. Rejected per above.

- **Decision:** Free-form natural language for subset directives. Agent parses intent. Slice IDs may be passed as args for explicit invocation.
  **Why:** Matches how the harness gets used. The api-first server later provides a stricter contract.
  **Rejected:** Formal numbered-menu syntax (`1, 3-5`). Rejected as premature.

- **Decision:** Cut "review more slices first" branch from /implement Phase 1 and the matching state-diagram transition.
  **Why:** The branch detours /implement into /plan-project. The user can run /plan-project directly. Cutting simplifies Phase 1 to "one team gate, then run."
  **Rejected:** Keeping the branch for convenience. Rejected because the branching cost outweighs the rare convenience.

- **Decision:** Mixed-response handling in /review batch — re-ask once on ambiguity, default to feedback if still ambiguous.
  **Why:** Strikes the balance between "never stop unnecessarily" and "don't approve something the user didn't approve." Feedback is recoverable; accidental approval commits.
  **Rejected:** Default-to-approval on ambiguity. Rejected because accidental commit is the worse failure.

- **Decision:** Shared next-actions reader lives at `.orchestration/support/next-actions.md`, called inline by each command.
  **Why:** Matches the existing support-file pattern (slice.md, spec.md, qa.md).
  **Rejected:** Inlining the logic per-command. Rejected as duplication.

- **Decision:** Cut both /plan-project Phase 7 team gates — per-slice and end-of-batch. /implement Phase 1 is the only team-confirmation point.
  **Why:** User confirmed never reviews the end-of-batch gate either. Two gates for the same confirmation are redundant.
  **Rejected:** Keep end-of-batch as a single batched gate. Rejected per user.

- **Decision:** /review auto-stages untracked files outside `.orchestration/` during the approve commit. Surfaces a single summary line ("Staging: N orchestration files, M source files, K untracked"). No per-file prompt. The user can opt to abort the commit if the summary looks wrong.
  **Why:** Per-file prompts drain a batch into per-file work. Untracked files in implementation directories during a slice's signoff are expected — they're the new files the agents wrote.
  **Rejected:** Keep per-file prompts. Rejected because they fight the batch principle.

- **Decision:** /plan-project planIteration auto-stages incidental code edits with a summary line, no block prompt. If the staging summary surprises the user, they can abort the iteration.
  **Why:** Same logic as /review. The prompt was a confirmation-of-confirmation pattern.
  **Rejected:** Keep prompt for safety. Rejected because the staging summary already provides the safety check.

- **Decision:** init-orchestrator presents one consolidated update gate when version mismatches are detected — "N files would update — accept all / review per-file / skip". Defaults to "accept all" on a plain "yes".
  **Why:** Matches the batch principle. Per-file prompts on install are the same pattern this project removes from /review.
  **Rejected:** Keep per-file prompts. Rejected per above.

- **Decision:** Consolidate the bdonize voice block into `.orchestration/support/bdonize.md`. slice.md, spec.md, and plan-project.md reference it instead of repeating the text.
  **Why:** Three near-identical copies drift independently. Single source = one update.
  **Rejected:** Inline duplication. Rejected as bloat.

- **Decision:** Persist Slicing.Review disambiguation via `review_context:` frontmatter on slice files. Values: `initial`, `post_iteration`, `question`.
  **Why:** "Agent tracks last prompt context" is brittle across crashes. Persisting in frontmatter survives.
  **Rejected:** Split Slicing.Review into three states. Rejected because the state machine doesn't need three nodes when one field disambiguates.

- **Decision:** Purge legacy/dead state values and stale references in one pass. Specifically: `specced` row in plan-project, `reviewed` aliases in status.md, `feedback_pending` terminology in defaults/README.md and plan-project.md, `/delegate` reference in spec.md, "Slicing.Asking" comment in state-diagram.md, dead `plan-project.md:43` route row, duplicate `implement.md:54` route row.
  **Why:** Dead code/text is bloat that confuses future readers and AI. The audit confirmed none of it is in use.
  **Rejected:** Per-item evaluation. Rejected — bundling reduces commit churn.

- **Decision:** Refresh README.md, defaults/README.md, and the affected diagrams (lifecycle.d2, multi-slice-sequence.d2) to match the post-batch state. Anchor the canonical state list in state-diagram.md; READMEs link to it instead of redefining.
  **Why:** Drift between docs and behavior is the second thing the user explicitly flagged in the original ask.
  **Rejected:** Defer doc updates. Rejected because the user called this out explicitly.

- **Decision:** Extract a shared status-write helper at `.orchestration/support/write-slice-status.md`. Eight sites (plan-project, implement, review, qa) currently restate "Write status: X and status_updated_at: ISO8601 to the slice file (Glob by slice frontmatter); warn-and-continue if not found."
  **Why:** Single most-repeated logic block in the system. One change point for the most common write pattern.
  **Rejected:** Inline references via fenced reuse. Rejected because the helper is the natural unit.

- **Decision:** Extract a shared agent preamble at `defaults/agents/_common-preamble.md` (installed alongside agent files). Covers the canonical read-order (`.root-context/architecture.md`, `DECISIONS.md`, `CONSTRAINTS.md`, then task file/spec), the shared "What you don't do" baseline, common escalation triggers, and the task-completion protocol (`status: done` write). Each agent file lists role-specific deltas only.
  **Why:** ~30 lines of near-verbatim duplication across 5 agent files. Centralization cuts the per-invocation read tax for every agent run.
  **Rejected:** Leave per-agent. Rejected because the duplication is structural, not stylistic.

- **Decision:** Centralize in `.root-context/state-diagram.md`: (a) the principles section gains a "Crash recovery" subsection consolidating the 6+ inline crash-resume blocks; (b) frontmatter schemas — slice, design, task — anchored alongside the existing status table; (c) a small vocabulary block ("active project", "queue", "stage" vs "state", "agent_type" vs "agent team"); (d) the "Skip if clean" git-commit idiom defined once.
  **Why:** state-diagram.md is already the documented source of truth for principles. Pulling the rest in makes it the single anchor every command links to.
  **Rejected:** Separate support files for schemas/vocabulary. Rejected because state-diagram.md is the natural home and avoids new file proliferation.

- **Decision:** Vocabulary unification across shipped defaults — "user" canonical (not "operator", "human", or "Bdon"), "active project" canonical, "queue" canonical (drop "execution list"/"global queue"). "Bdon" specifically removed from `slice.md`, `spec.md`, `plan-project.md`, `qa.md` since these ship to other users.
  **Why:** Vocabulary drift confuses both readers and the agent. "Bdon" in shipped defaults is a real bug for downstream users.
  **Rejected:** Leave terms as-is. Rejected because "Bdon" in shipped files is broken on its face. "human" rejected as canonical because "user" reads more naturally for downstream users.

- **Decision:** Per-command "Behavior rules" sections cut to command-specific deltas only. Shared rules ("never commit mid-phase", "re-read from disk on resume", "wait on git failure") live in state-diagram.md's Principles section; command files add a one-line link plus any command-specific rule.
  **Why:** Currently 4 commands restate ~10 overlapping rules. Total cut ~25 lines without losing accuracy.
  **Rejected:** Keep per-command for readability. Rejected because the duplicate rules drift independently and confuse readers about which is canonical.

- **Decision:** Shrinkage targets folded in concretely — adopt the proposed line cuts as scope for the command-update slices. Targets: `plan-project.md` -35%, `implement.md` -29%, `review.md` -54%, `status.md` -27%. Combined ~36% reduction, ~333 lines. Specific cuts include collapsing Phase 0 to a shared-reader call, pruning verbose quoted prompt templates, consolidating the design-doc skeleton block, removing belt-and-suspenders crash-resume blocks, and merging duplicate tables in status.md.
  **Why:** Smaller commands = faster reads on every invocation = faster for the user. The cuts replace verbose prose with tighter prose, not omitted accuracy.
  **Rejected:** Leave for a follow-up project. Rejected because the audit findings tightly couple to the consolidation work — splitting them creates churn.

- **Decision:** Resolve the slice.md vs plan-project.md state-machine drift. slice.md describes per-slice state transitions inline; state-diagram.md is authoritative. Cut the inline state-machine prose from slice.md and reference state-diagram.md.
  **Why:** Two sources for the same transitions create inconsistencies (currently slice.md says "approval writes status: review", plan-project.md sets status earlier).
  **Rejected:** Leave slice.md as a secondary source. Rejected because the inconsistency is a real bug surface.

- **Decision:** Fix plan-project correctness gaps surfaced by the consistency audit:
  (a) design doc template `status: ready` → `status: in_progress` (state-diagram.md only knows `in_progress | review | approved`).
  (b) Every status write must include `status_updated_at` — currently four Phase 5 writes (lines 302, 322 and equivalents) miss it, breaking status.md's sort.
  (c) On slicing gate surface, write `status: review` AND `review_context: initial` to **every** slice in the batch — not just slice 01.
  (d) Add a "Mixed" row to Phase 5's response classification: split the response, advance approved subset to `speccing`, run planIteration on the rest, resurface only the affected slices.
  (e) Collapse Phase 4 and Phase 5 design-approval commits into one block (currently duplicated with subtle drift).
  (f) Purge `feedback_pending` reference in plan-project.md:226 alongside the broader feedback_pending purge.
  (g) Tighten Phase 5:278 "no slice gate previously shown" to a disk-readable signal (e.g. "all slices `draft` and no commit referencing `02-slices/` in git log").
  **Why:** These are real correctness bugs in the current commands; the batch flow surfaces them. Fixing them in the same project keeps the surgery cohesive.
  **Rejected:** Defer to a follow-up. Rejected because the design relies on these contracts holding.

- **Decision:** Cross-command contract fixes:
  (a) Extend next-actions reader tuple to `(project_id, artifact_kind, artifact_id, status, status_updated_at, next_actions)` where `artifact_kind ∈ {project_root, design, slice}`. Design-phase projects need first-class representation.
  (b) `follow_up_of:` becomes a distinct routing signal — Phase 0 of /plan-project surfaces follow-up slices distinctly, doesn't treat them as identical to fresh drafts.
  (c) "Scope frozen at entry" is the rule for /implement. Cut /implement's mid-batch re-read at lines 113-115; the execution list computed in Phase 0 is authoritative for the run.
  (d) Status-write helper scope: frontmatter only — no logging side effects, no iterations.md write. iterations.md remains owned by planIteration.
  (e) Agent preamble is the floor (CONSTRAINTS.md + task file + completion protocol). Each agent file adds role-specific read-order extensions.
  (f) Diagram-first trigger lives in /plan-project Phase 7: when the brief's breakdown table has any task that touches state-machine behavior, prepend a "update state-diagram.md" task. CLAUDE.md's rule becomes enforceable rather than human-managed.
  **Why:** These are the contract gaps that emerge once the consolidations land. Fixing them with the consolidations avoids a second round of churn.
  **Rejected:** Per-fix evaluation. Rejected — bundling matches scope.

- **Decision:** Extend cleanup beyond the previously-scoped surface:
  (a) Delete `defaults/config.yaml` — fully orphaned, references commands that don't exist (`/design`, `/slice`, `/breakdown`), not installed by current init-orchestrator.
  (b) Extend "Bdon" purge to `architect.md`, `standards.md`, `qa.md` (currently scoped to slice/spec/plan-project — the audit found three more sites).
  (c) Fix `qa.md:1` description path: writes `.orchestration/dashboard/{spec-id}-qa.md` but Phase 3 actually writes to `05-qa/slice-{NN}-qa-report.md`.
  (d) Replace `qa.md:70` legacy `reviewed` reference with `review`.
  (e) Replace `README.md:102` "(one per specced slice)" with "(one per spec)".
  (f) `defaults/README.md` tables become links to README.md / state-diagram.md, not re-lists, to prevent drift return.
  **Why:** These are exact same-class issues as the previously-scoped purge — the earlier scope was incomplete.
  **Rejected:** Defer. Rejected — same class as in-scope work.

- **Decision:** Pre-bake 00006 alignment into the consolidations to avoid renaming churn later:
  (a) Rename next-actions tuple field `next_action_command` → `next_actions` (list of legal next actions, mirroring 00006's `GET /graph/state` legal-actions response).
  (b) Name the tuple shape `SliceNextActions` (or equivalent for design/project_root) so 00006 can lift the type into a Go struct without renaming.
  (c) Write the slice/design/task frontmatter schemas in state-diagram.md as typed tables (`field_name | type | values | required`) — directly portable to Go structs later.
  (d) Lock vocabulary: "transition" (for state-machine edges) and "action" (for legal verbs an agent can take). 00006 uses both; matching avoids divergence.
  (e) `review_context:` defined as a string enum (`initial | post_iteration | question`) in the typed schema.
  **Why:** Quick wins that cost nothing now and prefigure the api-first server. Each one avoids a translation step in 00006.
  **Rejected:** Wait for 00006 to drive the alignment. Rejected because each item is one phrase change, not a refactor.

## Agent decisions

- **Decision made:** Cross-project /implement keeps current ordering — oldest `status_updated_at` first, project-ID tiebreak.
  Context: nobody complained about ordering. The ask is no-stopping, not reordering.
  Alternative: per-project explicit selection. Rejected because current ordering already works.

- **Decision made:** /implement re-entry refires the team gate when the team mix differs from a recorded prior batch, otherwise proceeds without prompting.
  Context: principle says no unnecessary gates, but team composition can shift between runs and the user may not remember. Recording the prior team mix in `.orchestration/projects/{id}/observability/` makes the comparison cheap.
  Alternative: always refire. Alternative: never refire. The picked middle path keeps batches frictionless when nothing changed.

- **Decision made:** /review feedback path during a batch creates dot-notation slices (e.g. 5.1) per current behavior, and the batch continues to the next signoff slice without pausing for plan-project handoff.
  Context: matches the existing /review feedback semantics; no need to invent new flow.
  Alternative: pausing the batch on first feedback to surface plan-project handoff. Rejected because it reintroduces a stop.

- **Decision made:** Subset directive parsing is implemented inline in the command markdown — no new support file. Each command's prompt instructs the agent to parse directives in natural language and map to its scope.
  Context: free-form parsing is small enough to live in command markdown.
  Alternative: a support file (`subset-directives.md`). Rejected as overengineering for this scope.

## Root context updates planned

State diagram (`.root-context/state-diagram.md`) gets these changes — to be done as the first task of any state-machine-touching slice:

- **Delete:** `Implementation.Asking: onAnswer {wantMoreSlicesBrokenDown} -> Slicing.Review` transition and its action block.
- **Delete:** "Slicing.Asking from an earlier draft was a mistake" stale comment.
- **Replace:** `Signoff.Approved: onCommitted {unfinishedSlicesRemaining > 0} -> Slicing.Review` with three batch-aware transitions:
  - `Signoff.Approved: onCommitted {moreSignoffSlicesInProject > 0} -> Signoff.Review` (continue the batch)
  - `Signoff.Approved: onCommitted {moreSignoffSlicesInProject == 0 && unfinishedSlicesRemaining > 0} -> End` (project-level batch done; user runs /implement or /plan-project as appropriate)
  - `Signoff.Approved: onCommitted {unfinishedSlicesRemaining == 0} -> End` (archive, unchanged)
- **Replace:** `Signoff.Review: onAnswer {containsFeedback} -> Slicing.Generating` with `Signoff.Review: onAnswer {containsFeedback} -> Signoff.FeedbackPending` (or equivalent) — write draft slices, return to caller, no jump back to Generating.
- **Add:** `Implementation.QA: onQAComplete {qaPass && morePending} -> Implementation.Running` transition for the next slice's tasks.
- **Collapse:** `Slicing.Generating` self-loop into a single `Slicing.Generating -> Slicing.Review` transition (no command behavior loops generation).
- **Add:** `review_context:` frontmatter field to slice status table for Slicing.Review disambiguation.
- **Add principle:** "Batch is the default. A command's full scope runs end-to-end without inter-item gates. Per-slice gates fire only when a slice's state genuinely needs human input — design review, slicing review, signoff review."

`README.md` and `defaults/README.md` get refreshed: drop "spec review" gate, rebuild stage table from canonical state set, link to state-diagram.md instead of redefining stages, purge `feedback_pending` terminology. Diagrams (`docs/diagrams/lifecycle.d2`, `docs/diagrams/state-machine.d2`, `docs/diagrams/multi-slice-sequence.d2`) updated for cut/added transitions and correct archive semantics. SVG files re-rendered from .d2 sources.
