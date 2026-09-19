# Doc Harness — Complete Specification

**Version**: v2.0.0
**Date**: 2026-09-07
**Status**: Production design (v2)

## 1. Purpose and Scope

Doc Harness keeps a project resumable purely from files: after any session break or context compaction, a brand-new agent can take over correctly by reading the entry documents.

**The one question it answers**: under the inevitable fact that sessions end and context is lost, what is the minimal, trustworthy representation of a project's state such that a new agent can correctly take over?

**Scope**: Doc Harness records process information and helps retrieve/orient it. It does **not** prescribe how an agent does its work (no "use a sub-agent", no "think this way" rules).

**Core principle — handoff over writing**: writing is the means; correct handoff is the end. Not written = lost. Not reachable from the entry = effectively lost.

## 2. Documents

### 2.1 CLAUDE.md — single authoritative entry

Contains, in order:

1. **AGENT IDENTITY LOCK** (top): who the agent is and its scope; a self-test.
2. **Stable Anchor**: framework anchor, iron rules, bottom-line principles.
3. **One-line status** (the only allowed redundancy).
4. **Recovery Chain** (must-read + task-conditional).
5. **Project overview / key technical information**.
6. **Operational rules** (embedded between `<!-- doc-harness-ops-start -->` and `<!-- doc-harness-ops-end -->`; the region carries `<!-- doc-harness-ops-version: N.N -->`).

### 2.2 AGENTS.md — thin pointer

If it exists, it is a few-line pointer to `CLAUDE.md`. It must never hold a divergent copy of state. Two divergent entry files cause stale state and double injection in harnesses that read both.

### 2.3 CURRENT_STATUS.md — generated projection

`## NOW` + work surface + recent history, **projected from `events.log`** by `tools/project.ps1`. It is a derived view, never hand-edited.

### 2.4 FILE_INDEX.md — catalog

Files organized by category. Unregistered files are a red (failing) condition in `check`.

### 2.5 events.log — append-only event log (the primitive)

One structured event per line (`<date> <verb> <payload>`). It is the single source of both history and current state; the projection (§2.3) is derived from it. Prose worklogs written under v1 may be kept under `_archive/` as historical reference.

## 3. The NOW Block (normative)

`## NOW` is the project's **current snapshot** — the first thing a resuming agent reads after the anchor. It is not history.

Exact format (field names are the contract — English, ASCII, and **generated**; never hand-written):

```markdown
## NOW

- **Active**: `<unit-id>`, `<unit-id>`   (1–3 units = the active frontier; `(idle)` / `(paused)`)
- **Next**: `#1 action` — blocker: `...`
- **Read-first**: `<path>, <path>`       (2–4 pointers, in order)
- **Key-judgment**: one sentence (recent direction/priority change) — `source=<path> class=...`
- **Refreshed**: `YYYY-MM-DD`
```

Field semantics:

- **Active**: the 1–3 work units in play now. Each is a stable `unit-id` that exists in the Work Surface (§5). Rendered as `(paused)` when every open unit is paused, `(idle)` when none is in play.
- **Next**: the single highest-priority action, always paired with its blocker (or "none").
- **Read-first**: the minimal handoff list — concrete files/anchors only, in reading order.
- **Key-judgment**: optional but high-value — a recent conclusion that reorients work and is easy to lose. When present it **must carry a source pointer with a class** (`source=<path> class=root|decision|reported`); the projection carries it verbatim and `tools/cite-check.ps1` enforces it.
- **Refreshed**: projected from the date of the **last event** — so *recording an event is what refreshes NOW*. A project with no new events legitimately keeps an old date; `tools/now-verify.ps1` compares that date against the newest project file change to catch work that happened but was never recorded.

Constraints:

- ≤ ~30 lines (one screen). History must not leak into `## NOW`.
- Refreshed at session end, before compaction, and whenever the active frontier changes.
- The **active** list is the only place "what is in progress now" lives. The Work Surface's `[active]` markers mirror it, and `check` verifies they agree.
- `check` verifies freshness, size, and encoding; `resume` reads it first; `flush` refreshes it last.

Machine-readable frontmatter (single source for tools). `CURRENT_STATUS.md` begins with YAML:

```yaml
---
now_refreshed: YYYY-MM-DD
active_unit_ids: [unit-a, unit-b]
read_first: ["path/to/a.md", "path/to/b.md"]
---
```

Tools read these fields, not prose: `now_refreshed` is authoritative for freshness; `active_unit_ids` must equal the Work Surface's `[active]` set; `read_first` paths must exist (`tools/dead-pointer.ps1`).

## 4. Stable Anchor (normative)

The anchor holds the things that rarely change and must survive every session/compact:

- **Framework anchor**: how the project is layered, which layers are active, responsibility boundaries, north-star red lines.
- **Iron rules**: project-lifetime rules.
- **Bottom-line principles**: **declarative project-domain facts only** (e.g., "a guard named X ≠ X actually guards it"), each pointing to its full document (`PHILOSOPHY.md` or a design doc). Agent-operational conventions ("how to think", "ask yourself before concluding") do **not** belong here — they are coaching, not state; keep them in `PHILOSOPHY.md` only if the project itself wants them.

The anchor changes only on a real architecture change, not per session.

## 5. Work Surface (replaces the linear phase)

Record current work as a **mutable, structured surface**, not a linear list.

Format (as projected):

```markdown
## Work Surface

### Plan
- <part>
- <part>          (one bullet per top-level part — the `plan:set` payload, split on `|` or `->`)

### Units
#### <part>                          (present only when unit ids use the `part/unit` form)
- [active] `<unit-id>` description
- [future] `<unit-id>` description
- [done] `<unit-id>` description
- [paused] `<unit-id>` description
```

Rules:

- `unit-id` is a stable, project-chosen identifier (e.g., `F49`, `shipping/reconcile`). It is referenced by `## NOW`. `[active]` / `[done]` units should carry a source pointer to their evidence.
- A `unit-id` never contains a space (the parser splits `unit:open <id> <description>` on the first space). **Structure comes free with the id**: write `shipping/reconcile` and the surface groups it under `#### shipping`. Flat ids stay valid and render as a flat list — a project can stay flat until it actually branches.
- Status markers: `[active]` (frontier), `[future]` (not started), `[done]` (closed; its close event carries the evidence), `[paused]`.
- Structural changes (new part, reorg, unit moved, unit closed) are **surface mutations** — edit the surface in place; do not append a linear history.
- Prefer **delta edits** (add/remove/change one unit) over rewriting the whole Work Surface.
- The surface records reality; it does not plan. A part/unit exists here because the project actually has it.

Non-redundancy: the surface holds structure + status; `## NOW` holds the current focus; `events.log` holds the history and the detail of completed units. `check` verifies NOW's active units match the surface's `[active]` markers.

**Primitive**: `## NOW` and the Work Surface are **projected** from an append-only event log (`events.log`), not hand-maintained. The agent appends events; `tools/project.ps1` derives the views by deterministic replay. Event schema (one per line): `<date> <verb> <payload>`, where verb ∈ `unit:open` / `unit:activate` / `unit:close` / `unit:pause` / `next:set` / `judgment:set` / `read-first:set` / `plan:set` / `dead-end:set` / `note:set`. A line starting with `#` is a comment and replays as a no-op (this is how a log carries its own header/notes). Replay is mechanical (no semantics): the prose (descriptions, judgments) is written at write time and carried verbatim.

Projection layout: `## NOW` → `## Work Surface` (`### Plan`, `### Units`) → `## Recent History (closed units)` → `## Notes (housekeeping)` → `## Dead ends (negative ledger)`. Notes carry the date they were recorded and only the most recent are rendered (the rest stay in the log); they exist so that housekeeping which changes state documents — an ops re-embed, a schema migration, a guard fix — can be *recorded* instead of leaving the freshness guard permanently red.

**Schema migration** (adopting a project that predates a schema change — e.g. closes/judgments written before `class=` became mandatory): append-only is the rule for *recording*; a one-time schema migration is a deliberate rewrite and must be auditable, so it is not a hand edit:

1. `tools/log-migrate.ps1` archives the pre-migration log to `_archive/events-pre-migration-<date>.log` (evidence), normalizes the events, and leaves a `#` comment in the log recording what was migrated and where the old log went.
2. The projection must be unchanged by the migration (comments replay as no-ops); verify with `tools/conformance.ps1`.
3. Register the archive in FILE_INDEX, and record the migration in the project's own history (`judgment:set … source=<archive> class=decision`).

A migration never invents evidence: a close with no `evidence=` at all is reported for a human/agent to resolve, not patched with a guess.

## 6. Placement, Falsifiability & Recurrence (written → used → true)

Writing information down does not guarantee it is **used**, and using it does not guarantee it is **true**. Every discipline/rule/lesson declares its placement, and every document must be falsifiable by a machine.

Four placement states:

| State | Meaning | Test |
|-------|---------|------|
| **Gate** | a real guard exists | violation turns something red |
| **Should-be-gated, unmeasurable** | verifiable in principle, but no current instrument can see it | recorded as a named blind spot |
| **Auto-inject** | cannot be a gate, but must be present every session | lives at the top of CLAUDE.md |
| **Queryable** | details and rationale | the current documents |

Placement rule — before writing a discipline, ask **"can a machine SEE this?"** (not just "can it be verified"):

- Yes and instrumentable → make the gate.
- Yes in principle but no instrument → mark it as a **named blind spot** (the only way its absence becomes visible).
- No → it must live in the auto-inject layer, short enough to actually be read.
- Queryable-only is an explicit choice that it may be lost.

**Falsifiability (the "true" layer)**: every document gets a red counterpart — enumerate from the source (never hand-copy a list that must stay in sync), and verify every named file / id / number still exists. `check` asks: "is this list copied or computed?" and "does every thing it names still exist?"

**Freshness** has two faces, and both are gated:

- *Standing conclusions* (stable anchor, PHILOSOPHY, design docs) carry a machine-readable `conclusion_until: YYYY-MM-DD` and `verify_via: <command or path>`. `tools/stale-check.ps1` flags any conclusion past its date as overdue — it cures "an expired conclusion written as if current".
- *The state itself* can be unrecorded. `tools/now-verify.ps1` compares `now_refreshed` (the last event's date) against the newest change among the project's own files; work newer than the last event is a **red** ("work happened, state was not recorded") — the exact loss a session switch would make permanent.

**Provenance**: every source pointer carries a class — `root` (verifiable at a real data structure / a real run / the code), `decision` (a stated decision), or `reported` (second-hand). A fact with no source, or a source with no class, is flagged. Guards check "does it carry a live root", not "is the root correct". A project that predates this convention migrates once (§5 Schema migration), and then only forward: new events must carry a class.

**Recurrence**: a discipline re-stated is itself a signal. On the **2nd** restatement, force the question "why is this still a remembered rule?" — do not wait for the 3rd. When re-stating, record `Nth time (previous: <ref>)` and a mandatory **same-shape** field: "which existing discipline is this the same shape as?" (or "new shape — how"). Tools cannot detect shape, but they can force the answer. `check` reports re-stated ≥2 times and still queryable.

## 7. Entry Uniqueness

- `CLAUDE.md` is the single authoritative entry.
- `AGENTS.md`, if present, is a thin pointer.
- Each fact lives in exactly one document. The one-line status is the only allowed redundancy; on conflict CURRENT_STATUS wins.

## 8. Commands

The command names below are a **convention, not an agent feature**: `/doc-harness <command>` is how a Claude Code plugin exposes them; Kimi CLI loads the same skill with `/skill:doc-harness`; any other agent is driven by natural language. Each command is defined by its outcome, so "resume this project" and `/doc-harness resume` must produce the same behaviour.

### 8.1 `/doc-harness init`

Create the documents (see `init.md`): CLAUDE.md (identity + anchor + recovery chain + embedded rules), AGENTS.md thin pointer, CURRENT_STATUS (generated from `events.log`), FILE_INDEX, `events.log`. `DOC_HARNESS_SPEC.md` is an optional reference copy, not state. Mid-project adoption reconstructs reality faithfully.

### 8.2 `/doc-harness check`

Audit: NOW freshness/size/encoding, unregistered files (red), entry uniqueness, `events.log` well-formedness, inbox, ops-rules version, identity lock; then reflect on the anchor and bottom-line principles.

The ops-rules version is the `<!-- doc-harness-ops-version: N.N -->` tag inside CLAUDE.md, compared against `spec.md`'s `**Version**` line.

### 8.3 `/doc-harness sync`

Repair drift: register files, refresh `## NOW` + dates, append the missing state events to `events.log`, inbox housekeeping. Interactive (default) asks before state changes.

### 8.4 `/doc-harness flush`

Emergency save: sync, then **mandatorily** inventory context (Phase B), write/register extracted items (Phase C), verify a fresh arrival can find them (Phase D), and refresh `## NOW` last (Phase E). Omitting Phase B/C is a flush failure.

### 8.5 `/doc-harness recall`

Read-only retrieval: Layer 0 anchor → Layer 1 `## NOW`/work surface → Layer 2 `events.log` (history) → Layer 3 FILE_INDEX → Layer 4 files. Cite every claim.

### 8.6 `/doc-harness resume`

Structured, verifiable takeover: identity → stable anchor → `## NOW` → read-first list → Recovery Report → 5-question verification → proceed/wait decision.

## 9. Deterministic Toolbelt (optional)

Doc Harness may ship a `tools/` directory with optional deterministic helpers so mechanical bookkeeping does not depend on the agent remembering it:

- **State**: event append (`record.ps1` — append, re-project, run conformance; `-EventsFile` records a batch in one pass), projection (`project.ps1`), projection/version/ops-embed conformance (`conformance.ps1`), layered search (`search.ps1`). **Single parser invariant**: reconstructing state from `events.log` happens in exactly one place (`lib/doc-state.ps1` / `Get-DocState`); other tools may read the log as *text* (grep, migration, telemetry) but must never reimplement the replay.
- **Truth**: unregistered-red, dead-pointer, encoding, recurrence, provenance class (`cite-check`), freshness of standing conclusions (`stale-check`), staleness of the projection, NOW structure + unrecorded work (`now-verify`).
- **Coordination**: mail send (`mail-send.ps1`), wake-only poll (`mail-poll.ps1`), complete background daemon with lock/status/crash-recovery and an optional processor launch (`mail-daemon.ps1`), ledger; runtime artifacts live under `_runtime/`.
- **Hygiene**: nested-project git guard (pre-commit), stale-writer guard, batch registration, telemetry, single entry (`entry-check` — identity lock present, and `AGENTS.md` may not grow into a second entry or a second copy of state), skill consistency (`skill-consistency` — the two languages must share one skeleton *and* no document may teach the retired v1 model outside a migration sentence; all of these used to rest on human review).

These are helpers, not commands to the agent; using them is optional.

## 10. Optional Documents

- `PHILOSOPHY.md` — bottom-line principles from practice.
- `PARKING_LOT.md` — deferred items with revival preconditions.
- `RUNBOOK.md` — operational restart/resume state (distinct from documentation state).

## 11. Inter-Project Communication (inbox/outbox)

Optional; active if `inbox/` and `outbox/` exist.

- Receiving: read unread → act → `actioned`; never edit beyond the status field.
- Lifecycle: `unread → read → actioned → awaiting-reply → closed`. A message whose handling produced a reply (or that explicitly expects one) is `awaiting-reply`; `closed` when the thread ends. `check` can flag `awaiting-reply` older than a project-chosen deadline.
- Sending: `YYYY-MM-DD-from-<source>-<topic>.md` with YAML `from/to/date/subject/status/priority`; write to this project's `outbox/` and copy to the recipient's `inbox/`; snapshots over pointers.
- Pre-send checklist: correct `from`, correct outbox, recipient inbox, no recipient-doc modification, protocol active, **recipient can understand without my context** (snapshot over pointers).
- At high volume, an optional `MAIL_LEDGER.md` tracks who/when/status/awaiting-reply.
- Malformed messages → `inbox/_malformed/` quarantine.

## 12. Anti-Patterns

| Anti-pattern | Correct approach |
|--------------|------------------|
| History leaking into `## NOW` | NOW is current-only; history goes to `events.log` |
| Editing `CURRENT_STATUS.md` by hand | it is a projection: record an event, re-project (`tools/record.ps1`) |
| Hand-editing `events.log` to adopt a new schema | one-time migration with an archive + a comment trail (`tools/log-migrate.ps1`) |
| Recording state in prose | one line per state change in `events.log`; prose lives in the documents it describes |
| Two divergent entry files | CLAUDE.md authoritative; AGENTS.md thin pointer |
| Unregistered files ignored | `check` red + `sync` registers |
| A linear "phase" list for a branching project | work surface + active frontier (structure via `part/unit` ids) |
| Prescribing how the agent works | only record + retrieve |
| A guard that fires on healthy projects | a guard must be actionably red; noise kills trust (`now-verify` compares against real file changes, not the calendar) |

## 13. Handoff Guarantee & Verification

A handoff is correct when a zero-context agent, reading **only** these in order:

1. `CLAUDE.md`: AGENT IDENTITY LOCK → stable anchor
2. `CURRENT_STATUS.md`: `## NOW`
3. the files named in NOW's read-first list

...can state, without reading anything else: identity/scope, the active frontier, the #1 next action + blocker, the most recent key judgment, and the next files to read.

Verification has a deterministic half and a judgment half:

- **Deterministic half** — `tools/now-verify.ps1` checks the structural invariants the reading depends on: a `## NOW` block exists and is bounded (≤30 lines), the file is valid UTF-8, a refresh marker is present, next + read-first are non-empty and every read-first path resolves, and no project file changed after the last recorded event. `tools/conformance.ps1` runs this together with the other guards as one gate.
- **Judgment half** — the **simulation**: use a project with a non-trivial branching state, read only the three items above, and compare the recovered state against ground truth. Only a reader can verify that the prose actually says what it means; the tools verify that it is there, current, and consistent.

## 14. Version History

| Version | Date | Changes |
|---------|------|---------|
| v1.0–v1.7.1 | 2026-04 → 2026-09 | Original linear phase/car-body model; six commands; inbox/outbox; AGENT IDENTITY LOCK; flush/resume/recall. |
| v2.0.0 | 2026-09-07 | Foundational redesign: handoff-over-writing; unique entry + AGENTS.md thin pointer; stable anchor layer; bounded `## NOW` block; work surface + active frontier; deterministic toolbelt; remove agent-behavior prescriptions. |
