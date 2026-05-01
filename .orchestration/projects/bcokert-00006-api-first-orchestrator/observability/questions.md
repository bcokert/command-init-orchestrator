# Questions log
<!-- Format: ## YYYY-MM-DD HH:MM — [open|answered] Question text -->

## 2026-04-27 — [answered] What is the API actually for — state-store-with-tracing or orchestrator-engine-Claude-calls-into?
- Single source of truth + observability backbone. Same data debugs the system AND improves it. Server is orchestrator + state + observability sink.

## 2026-04-27 — [answered] Dumbest slice 1 — local server + sqlite swapping one or two transitions, full state machine, design phase, or walking skeleton?
- Local server, simple db. Start with design phase. Like AI org adoption: define graph, replace parts gradually rather than the whole thing.

## 2026-04-27 — [answered] What happens to existing projects + this repo?
- This repo becomes installer for the server. Per-project init scaffolds local commands/skills (form TBD). Old projects: convert if cheap, otherwise leave as historical artifacts.

## 2026-04-27 — [answered] Graph scope — states only, states + artifacts, or states + artifacts + actors?
- Nodes = SDLC states. Edges = legal actions. Possible-actions surface enumerable from current state. Multiple "pointers" (actions in flight) at slice granularity.

## 2026-04-27 — [answered] Action granularity — coarse, medium, or fine?
- Action = initiating traversal from a node along an edge. One action = one trace = many internal spans. SDK-backed internals; API exposes possible legal actions.

## 2026-04-27 — [answered] Span model — API-call spans only, or logical + API spans?
- 1 API hit = 1 trace = N spans. Internals (research, context, decisions, artifacts, traversal) are spans within the trace.

## 2026-04-27 — [answered] Where does LLM work run — server, local harness, or hybrid?
- Server has no LLM at all. Pure deterministic state/artifact/context store + observability sink. All LLM work in local agents. Server tells agent what's legal next (MCP-flavored).

## 2026-04-27 — [answered] Filesystem and git — DB-canonical, files-canonical, or DB-only?
- Artifacts canonical in server. Locally materialized only transiently for review. Server UI is the long-term review tool. Code commits stay local.

## 2026-04-27 — [answered] Slice 1 cut — interview only, full design phase, or walking skeleton?
- State/status to server first; transitions become API calls; commands otherwise unchanged. Artifacts move next slice.

## 2026-04-27 — [answered] Server stack and packaging — language, db, lifecycle, repo shape, install location?
- Go. Sqlite for state/logs, filesystem (later S3) for documents. Daemon eventually (systemd in cloud); slice 1 user runs it. Same repo for now (renames later). Install folder configurable, default ~/.orchestrator/.

## 2026-04-27 — [answered] State machine survival — port unchanged or revise during the move?
- Transitions unchanged in semantics, only storage moves. Drop staging/commit-for-diff tricks. Cohesion stays agent-side. Approval is server action; commit stays local for code only.

## 2026-04-27 — [answered] Context management — solve or park?
- Park (option a) for now. (b) is destination, (c) future. Local agent handles context; future research subagents handle code-state.

## 2026-04-27 — [answered] API style and install mechanics?
- Action-focused POSTs (POST /transition/plan-approve etc.), REST GETs for state, /graph/state for discovery. Single install folder default ~/.orchestrator/. Per-repo gitignored .orchestration.env carries connection info.

## 2026-04-27 — [answered] Concurrency model?
- Independent actions move in parallel if preconditions met. One slice has one next action. Server replaces the queue; impl agents poll for next task; async-hardened locks.

## 2026-04-27 — [answered] Dogfooding strategy + edge cases?
- Use existing orchestrator to build the new one. Server down → fail loud. Illegal action → server returns legal actions list, agent presents or picks. Partial state tolerated short-term.
