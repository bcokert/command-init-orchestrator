# Questions log — bcokert-00004-state-machine-refactor

All questions asked during design, with status and timestamps.

---

<!-- Format: [YYYY-MM-DD HH:MM] status: open|answered -->
<!-- Status open = not yet answered, answered = resolved -->

[2026-04-21 session] answered: Commit timing — commits happen when human approves at review gate (not at start of next phase)
[2026-04-21 session] answered: Push — agent never pushes; human triggers manually
[2026-04-21 session] answered: Batch slice approval — each slice is independent state machine; slice N must approve before N+1; partial approval supported
[2026-04-21 session] answered: Slicing.Iterating — same pattern as Design.Iterating; triggered by feedback from Slicing.Review; planIteration updates all pending artifacts
[2026-04-21 session] answered: Implementation.Asking — start button only; always implements all ready work; human can choose to review more slices first
[2026-04-21 session] answered: Research agents — deferred to future project; removed from state machine
[2026-04-21 session] answered: planIteration staging — git add previous changes at start of each iteration for VS Code diff readability
[2026-04-21 session] answered: Open questions storage — store in observability/questions.md per project
[2026-04-21 session] answered: Slice status storage — slice file frontmatter is source of truth
[2026-04-21 session] answered: Error escalation — QA stays in qa_in_progress during auto-retry; moves to signoff_review on give-up; human fix → back to QA
[2026-04-21 session] answered: Staging scope — .orchestration/ + related root-context; surface code files before staging
[2026-04-21 session] answered: Human status transitions — agent owns ALL transitions; human never edits frontmatter; responds to prompts only
[2026-04-21 session] answered: Signoff feedback slices — start at draft; full Slicing.Review → Speccing → Breakdown flow
[2026-04-21 session] answered: Slicing.Asking — was a mistake in original diagram; collapses into Slicing.Review
[2026-04-21 session] answered: Slicing.Review is multi-purpose — handles initial review, post-iteration summary, interview questions; agent tracks what it last asked
[2026-04-21 session] answered: Slicing.Iterating entry — only via feedback from Slicing.Review; initial flow is Generating → Review → Speccing
[2026-04-21 session] answered: Spec+breakdown atomic — no review gate between them; resumable via status field
[2026-04-21 session] answered: Support file scope — defaults/commands/ contains source for both user commands and support files; same file, different install targets
[2026-04-21 session] answered: Project scope — defaults/ only; local .claude/commands/ updated via /init-orchestrator after implementation
