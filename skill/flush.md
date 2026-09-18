# Doc Harness — Flush

Emergency save before compaction/session end. The defining feature is mandatory context inventory + extraction + **NOW refresh**.

> If Phase B (inventory) and Phase C (write) are skipped, flush has failed — it is just `sync`.

## Modes

- **interactive** (default): ask per extraction.
- **auto** (`--auto`): heuristic classification.

## Phase A: Sync

Run the full `sync` procedure (which appends any missing state events to `events.log` and re-projects). Then state: "Phase A complete — entering Phase B."

## Phase B: Context Inventory (MANDATORY)

Scan current context. Classify every non-transient item: DURABLE (already in files) / EXTRACT (needs writing) / EXCLUDE (transient, wrong, user-denied).

Key targets: analysis results → `notes/`; design decisions → `design/`, plus a `plan:set`/`judgment:set` event if the work surface itself changed; lessons → `PHILOSOPHY.md`; new rules → stable anchor/iron rules; user requirements → `## NOW` next step (via `next:set`).

Always report `Total scanned / DURABLE / EXTRACT / EXCLUDE`. If EXTRACT = 0, produce an explicit Empty Scan Report.

## Phase C: Write & Register (MANDATORY if EXTRACT > 0)

Write each item; register in FILE_INDEX; record the state change as an event in `events.log` (`tools/record.ps1`). Prefer append with a dated header over overwrite.

## Phase D: Verify

Simulate fresh arrival: read CLAUDE.md stable anchor → `## NOW` → read-first. Can the new agent find everything just written? Fix any gap.

## Phase E: Final Marker + NOW Refresh

- Refresh `## NOW` **before** compaction by recording what changed (`tools/record.ps1 -Verb next|read|judgment -Text "..."`), which re-projects CURRENT_STATUS and refreshes its date. An event is what refreshes NOW — editing CURRENT_STATUS by hand is not an option (it is generated).
- Record the flush in telemetry: `tools/telemetry.ps1 -Event flush -Detail "N items extracted"`. `_runtime/ops-log.ndjson` is the audit trail; CURRENT_STATUS holds state, not process history.
- If the flush itself produced a durable conclusion, it is a state change: record it (`judgment:set` / `unit:close`) rather than only mentioning it in the report.

## Output

```
═══════════════════════════════════════
  Doc Harness — Context Flush   Project: [name]   Date: ...   Mode: auto/interactive
═══════════════════════════════════════
── Phase A: Sync ── ...
── Phase B: Context Inventory ── [MANDATORY; even if empty]
── Phase C: Write & Register ── ...
── Phase D: Verify ── ...
── Phase E: Marker + NOW Refresh ── ...
═══════════════════════════════════════
```
