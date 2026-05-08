# Decision log
<!-- Format: ## YYYY-MM-DD HH:MM — Decision. Why. Rejected: alternatives. -->

## 2026-05-06 14:33 — Cut Phase 7 team gate from /plan-project. Why: per-slice gates drain batched runs into single-slice work. Rejected: keep a single batched team gate at end of plan-project (redundant with /implement Phase 1).

## 2026-05-06 14:33 — /review = one project at a time, batched signoff iteration. Why: humans review the whole project's implemented surface, not slice-by-slice. Rejected: system-wide /review iteration; slice-level prompt within a project.

## 2026-05-06 14:33 — Keep four commands; each thin wrapper over a shared next-actions reader. Why: smallest surface change, aligns with api-first server. Rejected: new /do command; folding into /status.

## 2026-05-06 14:33 — No state.json. Frontmatter remains authoritative. Why: project 00006 replaces storage entirely; a bridge gets discarded. Rejected: top-level state.json as source of truth.

## 2026-05-06 14:33 — Free-form natural-language subset directives. Why: matches actual harness usage; api-first server provides stricter contract later. Rejected: formal numbered-menu syntax.

## 2026-05-06 14:33 — Cut "review more slices first" branch from /implement Phase 1 and matching state-diagram transition. Why: detour into /plan-project that the user can do directly. Rejected: keep for convenience.

## 2026-05-06 14:33 — Mixed-response handling in /review batch: re-ask once on ambiguity, default to feedback. Why: feedback is recoverable; accidental approval commits. Rejected: default-to-approval.

## 2026-05-06 14:33 — Shared reader lives at .orchestration/support/next-actions.md. Why: matches existing support-file pattern. Rejected: inline per-command.

## 2026-05-06 14:55 — Cut both /plan-project Phase 7 team gates (per-slice and end-of-batch). Why: user never reviews the end-of-batch one either. Rejected: keep end-of-batch alone.

## 2026-05-06 14:55 — Auto-stage untracked files in /review and planIteration; surface single summary line; user can abort. Why: per-file prompts drain a batch into per-file work. Rejected: keep prompts.

## 2026-05-06 14:55 — Consolidated init-orchestrator update gate ("N files would update — accept all / review / skip"). Why: matches batch principle. Rejected: keep per-file.

## 2026-05-06 14:55 — Persist Slicing.Review disambiguation via review_context: frontmatter. Why: surviving crashes; brittle "agent tracks last prompt" replaced. Rejected: split into three states.

## 2026-05-06 14:55 — Bundled legacy/dead value purge: specced, reviewed, feedback_pending, /delegate, Slicing.Asking comment, dead route rows. Why: bloat that confuses readers. Rejected: per-item evaluation.

## 2026-05-06 15:10 — Status-write helper at .orchestration/support/write-slice-status.md. Why: most-repeated logic block in the system (8 sites). Rejected: inline references.

## 2026-05-06 15:10 — Shared agent preamble at defaults/agents/_common-preamble.md. Why: ~30 lines of duplication across 5 agents; per-invocation read tax. Rejected: leave per-agent.

## 2026-05-06 15:10 — state-diagram.md becomes single anchor: principles, schemas, vocabulary, crash recovery, "skip if clean" idiom. Why: avoids new file proliferation; commands link rather than redefine. Rejected: separate support files.

## 2026-05-06 15:10 — Vocabulary unification: "human", "active project", "queue" canonical. "Bdon" removed from shipped defaults. Why: shipped defaults that mention "Bdon" are broken for downstream users. Rejected: leave terms.

## 2026-05-06 15:10 — Per-command Behavior rules cut to deltas; shared rules live in state-diagram.md Principles. Why: 4 commands restate ~10 overlapping rules. Rejected: keep per-command for readability.

## 2026-05-06 15:10 — Shrinkage targets folded in (~36% across four command files). Why: smaller commands = faster reads on every invocation. Rejected: defer to follow-up project.

## 2026-05-06 15:10 — Cut state-machine prose from slice.md; reference state-diagram.md. Why: two sources for transitions create real inconsistency bugs. Rejected: leave as secondary source.

## 2026-05-06 16:09 — Vocab pivot: "user" canonical (not "human", "operator", "Bdon"). Why: "user" reads more naturally for downstream users; Bdon ships to other users.

## 2026-05-06 16:09 — Plan-project correctness bundle: status:ready→in_progress, write status_updated_at at every status write, write status: review + review_context: initial to every batched slice (not just 01), add Mixed-response row to slicing review, collapse Phase 4+5 design-approval commit, purge feedback_pending in plan-project.md:226, tighten 5:278 to disk-readable signal. Why: real correctness bugs the batch flow surfaces. Rejected: defer to follow-up.

## 2026-05-06 16:09 — Cross-command contract bundle: next-actions tuple extended (artifact_kind), follow_up_of: distinct routing, scope-frozen-at-entry for /implement, status-write helper frontmatter-only, agent preamble as floor + role deltas, diagram-first trigger in /plan-project Phase 7. Why: contract gaps emerge when consolidations land. Rejected: per-fix evaluation.

## 2026-05-06 16:09 — Extended cleanup: delete defaults/config.yaml (orphan), Bdon purge extended to architect/standards/qa, qa.md description path fix, qa.md:70 reviewed→review, README.md:102 specced→spec, defaults/README.md tables become links. Why: same-class bugs missed in earlier scope. Rejected: defer.

## 2026-05-06 16:09 — 00006 alignment quick wins: next_action_command → next_actions list, name SliceNextActions shape, typed schema tables, lock "transition" + "action" terms, review_context as string enum. Why: cost nothing now; prefigure api-first server cleanly. Rejected: wait for 00006 to drive renames.
