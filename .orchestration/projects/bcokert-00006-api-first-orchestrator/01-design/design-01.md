---
type: design
date: 2026-04-27
feature: api-first-orchestrator
project_id: bcokert-00006-api-first-orchestrator
status: review
---

# API-first orchestrator — Design

## Intent

The orchestrator today is a per-repo scaffold. Markdown commands sit in `.claude/commands/`, state and artifacts live under `.orchestration/projects/`, status is YAML frontmatter on slice files, the queue is a glob across all those files, observability is grep-able markdown logs. It works for one human in one repo. It doesn't extend to multiple users, multiple machines, real observability, or learning loops that need structured data.

This refactor moves the orchestrator behind a deterministic Go server. State, artifacts, and observability data become the server's job. The local agent harness keeps doing all LLM work. The API exposes legal actions for whatever state a project is in: the agent posts an action, the server validates and transitions, the response includes the new state plus the next-legal-actions set. Same state machine; new home. Storage is sqlite for state and logs, filesystem (later S3) for documents. Each repo gets a gitignored `.orchestration.env` with connection info — local vs. remote is invisible to the agent. Single user, single machine today; multi-user, multi-org cloud is the endgame.

## Current state

- Per-repo install: commands in `.claude/commands/`, state in `.orchestration/projects/{id}/`
- Status is YAML frontmatter on slice files; queue is a glob across all projects' slices
- Observability is markdown files in `.orchestration/projects/{id}/observability/`
- State changes happen by reading and writing files; nothing validates legal actions
- planIteration's "stage previous changes for VS Code diff" is filesystem-specific
- Two harnesses on the same project clobber each other silently — no concurrency control
- Multi-project means multi-repo and multi-`.orchestration` — no shared source of truth
- No machine-readable trace of decisions, context, or tool calls

## Desired end state

- One Go server holds all orchestrator state and artifacts. One source of truth across projects and machines.
- Server is fully deterministic — no LLM, no Anthropic SDK, no tokens
- Agents do all LLM work locally; server validates and records
- API surface = legal actions per state node. Agent calls actions, server transitions, response carries next legal actions.
- One API call = one trace = N internal spans, once the observability layer lands
- Local repo holds only code and a gitignored `.orchestration.env` pointing at the server
- `/status` runs against the server; a server-hosted UI eventually replaces local file review
- Install puts a single Go binary plus state/artifact folder under `~/.orchestrator/` by default
- Server-managed implementation queue replaces glob-based queue; agents poll for next task under async-hardened locks
- Server is local today, cloud tomorrow — agent code is identical either way

## Patterns to follow

- Server stays deterministic. No LLM calls server-side. Ever. If a feature needs an LLM, it lives in an agent.
- Action-focused API: `POST /transition/{action}` with JSON body for state changes. `GET /projects/{id}` and `GET /slices/{id}` for state. `GET /graph/state` for discovery — returns all states with current and next actions per node.
- Illegal action → 422 with legal-actions list. Agent surfaces options to the human or picks based on local context.
- Optimistic concurrency: transitions carry preconditions. Stale transition → 409 with current state. Agent retries with fresh state.
- Implementation queue lives in the server. Agents poll for next available task. Server hands tasks out in dependency-respecting order under async-hardened locks. One task is held by at most one agent.
- 1 API call = 1 trace = N spans. Added when the observability layer is built; not in slice 1.
- Fail loud on server unreachable. No silent buffering, no client-side retry. Caching and retries are deferred until evidence of need.
- Cohesion passes stay agent-side, fed from server state.
- Diagram-first rule applies: any slice that touches state-machine semantics or behavior updates `.root-context/state-diagram.md` as its first task.

## Patterns to avoid

- Server taking on anything LLM-shaped. No SDK, no key management, no agent loop on the server.
- Filesystem-era affordances carried forward — planIteration's staging-for-diff trick, frontmatter as source of truth, glob-driven queue logic. Drop them in the slices that move that state, not preserve as backwards-compat.
- Local copies of artifacts as a long-term pattern. They exist transiently during transition slices. Once artifacts are server-side, the agent surfaces them on demand and a server UI handles direct review.
- Coupling code commits to server actions. Code commits stay local. Server records that approval happened and the SHA, nothing more.

## Key edge cases

- **Server down at action time.** Fail loud, refuse to proceed, surface error to the human.
- **Agent calls an illegal action.** Server returns 422 + legal-actions list. Agent surfaces the options or picks based on context.
- **Concurrent action on the same slice.** One slice has at most one legal next action — no intra-slice concurrency to manage.
- **Concurrent action on the same project from two harnesses.** Optimistic preconditions guard transitions; loser gets 409 + current state and retries.
- **Implementation queue race.** Multiple agents polling — server hands out tasks under async-hardened locks; only one agent ever holds a given task.
- **Partial state during transition slices.** Status in DB but artifacts on disk in slice 1. Tolerated short-term; later slices migrate the rest. Not a long-term concern.
- **This repo dogfoods the orchestrator on itself.** Existing file-based orchestration continues here until the new system is stable enough to migrate. Same pattern as today.
- **Existing archived projects under `.orchestration/projects/done/`.** Left as historical artifacts. Not migrated unless cheap.
- **Span and context storage.** Idiomatic precedent unclear — defer until observability layer; sqlite vs. filesystem TBD by what the chosen tracing lib expects.
- **Server URL discovery.** Each repo has a gitignored `.orchestration.env` set up at install. Agent reads it. Local vs. remote is invisible.

## Resolved design decisions

**Decision: Server is fully deterministic — no LLM, no Anthropic SDK, no tokens.**
Why: separates concerns cleanly. Server is reliable, fast, testable, cheap. Agents already handle LLM work. Avoids server-side key management, server-side LLM cost, and conflating storage with model behavior.
Rejected: hybrid server-LLM (interactive turns local, background work on server) — more flexible but more surface, key management server-side, conflated roles. Can be layered later without breaking the deterministic core.

**Decision: Go server, sqlite for state and logs, filesystem (later S3) for documents.**
Why: matches the existing stack. Sqlite is honest local-first and ports to Postgres for cloud behind the same query layer. Filesystem for blobs is cheap and migrates to S3 cleanly. Span/context storage left open until tracing-lib precedent is checked.
Rejected: pure-DB blob storage (slow, awkward for markdown), pure-filesystem state (loses queryability).

**Decision: Action-focused API with REST elements.**
Why: maps directly to edges-as-actions. `POST /transition/{action}` with body for state changes, `GET /projects/{id}` and `GET /slices/{id}` for state reads, `GET /graph/state` for discovery. State reads always include current and next actions, so the agent always knows what's possible.
Rejected: pure-REST resource model — semantically muddier for actions like "approve", "feedback". Pure-action without GETs — agent has no way to read state without running an action.

**Decision: Single install folder at `~/.orchestrator/`, configurable via install script. Per-repo connection via gitignored `.orchestration.env`.**
Why: one folder for everything (binary, sqlite, artifacts) is simple to install and to back up. Per-repo env file means the agent treats local and remote servers identically.
Rejected: scattered paths (binary in `~/.local/bin`, state in `~/.claude/orchestrator/`) — more install-script work, no real benefit. Hardcoded URL — rules out remote.

**Decision: Optimistic concurrency via preconditions; 409 with current state on stale transitions.**
Why: simpler than leases, no timeouts to manage, matches the action model. One slice has one legal next action, so intra-slice contention is impossible by design. Across slices, agents retry with fresh state.
Rejected: pessimistic locks (lease cleanup, timeout management), first-writer-wins (silent clobbering).

**Decision: Server-managed implementation queue. Agents poll for next task. Server holds async-hardened task locks.**
Why: replaces the glob-driven queue with one source of truth. Server prioritizes, handles dependencies, prevents double-execution. Async-hardened locks keep the loop safe under multiple concurrent agents.
Rejected: client-side queue logic (drift across multiple agents), file-based locks (race-prone, hard to reason about).

**Decision: Slice plan starts with state/status to server, then artifacts, then `/status` + UI, then observability layer.**
Why: status is the smallest valuable thing — it proves the API and state-machine boundary without touching artifacts. Artifacts come next because they're the bulk of the value. Observability layered last so the trace surface lands on a stable action surface.
Rejected: walking-skeleton thin slice through every phase (proves less per slice), full design phase first (couples state and artifact migration in slice 1, more surface).

**Decision: Fail loud on server unreachable. No client-side retries or buffering for now.**
Why: silent buffering hides bugs. Loud failures expose problems early. Caching and retries land when there's evidence of need.
Rejected: client-side cache + replay (complex, hides outages, hard to test).

**Decision: Existing `.orchestration/projects/done/` archives stay file-based as historical artifacts.**
Why: migration cost dwarfs value. They're done. Nobody acts on them.
Rejected: full migration (expensive), automatic conversion (complex, brittle, low payoff).

**Decision: Same repo for now; rename later when it's the whole system.**
Why: avoids early naming churn. Two installers (server + local agent files) live alongside the existing tooling. Repo becomes the system once that's the bulk of what it is.
Rejected: split into separate repos now — more overhead, no clear benefit while early.

**Decision: This repo dogfoods the existing orchestrator until the new system is stable enough to migrate.**
Why: same pattern as today — use the working system to build the next one. Forcing migration mid-build blocks work on the system itself if the new system is broken.
Rejected: hard cutover at slice 2 — needlessly disruptive.

## Agent decisions

**Project slug `api-first-orchestrator`.**
Context: API-first is the architectural fork that drives every other decision. Picked the principle over the action.
Alternative: `orchestrator-server-refactor` (names what's being done) or `single-install-orchestrator` (names the deployment). Either works — rename if it sticks badly.

**Default install path `~/.orchestrator/` rather than `~/.claude/orchestrator/`.**
Context: Bdon stated this default directly. Worth flagging because `~/.claude/` was the obvious sibling location given commands live there.
Alternative: `~/.claude/orchestrator/` — keeps Claude-related stuff under one umbrella.

**API style: action-named POSTs with JSON body for transitions; REST GETs for reads.**
Context: Bdon described both URL-route and query-param styles. Going with `POST /transition/{action}` for state changes plus `GET /projects/{id}`, `GET /slices/{id}`, `GET /graph/state` for reads. Reads idiomatic in HTTP, actions clearly named.
Alternative: query-param style throughout — works, but reads less HTTP-natural.

**Slice 1 boundary: status/state only, artifacts stay on disk.**
Context: Bdon explicitly described this as the first cut. Treating it as decided.
Alternative: walking skeleton across phases — proves architecture cheaper but per-slice value is lower.

**Status starts at `review` rather than `ready`.**
Context: doc template field shows `status: ready` but the Phase 4 gate sets `status: review`. The state-diagram only knows `in_progress`, `review`, `approved`. Picked `review` to match the running state machine.
Alternative: `ready` per template — would be inconsistent with the rest of the system.
