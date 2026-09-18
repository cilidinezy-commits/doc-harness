# Doc Harness — Sync

Repair drift and refresh the durable state so it matches reality. Unlike `check` (diagnose only), `sync` modifies files.

## Modes

- **interactive** (default): ask before work-unit folding, archival, or principle extraction.
- **auto** (`--auto`): execute safe fixes without asking.

## Step 1: Drift Scan (read-only)

| Check | Action |
|-------|--------|
| Unregistered files | files on disk vs FILE_INDEX (recursive, sub-index prune) |
| NOW freshness | `## NOW` "last refreshed" not today? |
| NOW size / encoding | >30 lines? mojibake? |
| Entry uniqueness | AGENTS.md thin pointer? stale? |
| Work-unit events | units whose real status changed but have no matching event in `events.log`? |
| events.log length | ≥5000 lines (compaction worth considering)? |
| Inbox | unread / archival-due / malformed / unlogged outbox |

## Step 2: Safe Auto Fixes

1. Register unregistered files (heuristic category; create `## Uncategorized` if needed).
2. Refresh `## NOW` by recording the events that describe reality (`next:set` / `read-first:set` / `judgment:set`), then re-project with `tools/project.ps1 -Write`; update CLAUDE.md one-line status + FILE_INDEX date.
3. Inbox housekeeping: archive stale actioned, quarantine malformed.
4. If a work unit has closed, append its `unit:close` event **with evidence** (`evidence=<path> class=root|decision|reported`) and re-project (interactive: ask first). The evidence is what makes the closure falsifiable.

## Step 3: Close-out Recording

Compare the work surface against reality: any unit that is done in reality but still `[active]`/`[future]` in the projection needs its event (`unit:close` with evidence, or `unit:pause`). Any unit whose real status is active but that was never activated needs `unit:activate`. Each fixed unit is one appended line — never rewrite the log.

## Step 4: events.log Compaction (rare, interactive only)

`events.log` grows one line per state change and needs no routine archival — a very busy project reaches ~5000 lines per year. If it ever gets that long, **compaction is a rewrite, not a trim**: move the raw log to `_archive/events-<YYYY-MM-DD>.log` (kept as evidence), then start a fresh log containing, for each archived unit, a `unit:open` + a terminal event (`unit:close`/`unit:pause`) that reproduces its final state, followed by the live units' events. Verify with `tools/conformance.ps1` that the projection is unchanged except for the intended history trimming. Never leave `activate`/`close` events whose `open` was archived away — that is a parse error.

## Step 5: Principle Extraction (interactive only)

Offer to record any session-forged principle into `PHILOSOPHY.md` or promote to the stable anchor. Auto mode skips this.

## Output

```
═══════════════════════════════════════
  Doc Harness — Status Sync   Project: [name]   Date: YYYY-MM-DD   Mode: auto/interactive
═══════════════════════════════════════
── Scan ──
unregistered: N · NOW: stale/fresh · entry: ok/stale · units: N missing events · events.log: N lines · inbox: ...
── Actions ──
registered N files · refreshed NOW/dates · recorded N unit events · compacted: no/yes · principles: none/list
── Remaining ──
[user decisions if interactive]
═══════════════════════════════════════
```
