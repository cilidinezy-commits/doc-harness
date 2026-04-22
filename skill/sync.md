# Doc Harness — Sync

Synchronize project status documents with reality. Repair drift, refresh stale fields, register missing files, and optionally trigger phase transition or WORKLOG archival.

**Purpose**: When agents fail to auto-update status documents during work, or when the user feels "it's been a while — the docs should catch up," `sync` actively repairs the gap. Unlike `check` (which only diagnoses), `sync` modifies files.

---

## When to Use

- User says "update the status docs," "sync the project state," or "catch up the documentation"
- Agent failed to maintain documents during a session (files created but not registered, dates stale, car body drifted)
- Before a long pause (>3 days) to ensure documents reflect current reality
- After bulk file operations outside agent awareness (e.g., user copied 50 files manually)
- When `check` reports actionable drift that the user wants fixed immediately

---

## Two Modes

### `interactive` (default)

Ask the user before actions that go beyond routine bookkeeping:
- Before executing a phase transition (car body ≥200 lines)
- Before WORKLOG archival (≥1000 lines)
- Before creating new documents for principles/lessons extracted from context
- Before promoting a driving-manual principle to an iron rule

This is the default because phase transitions and archival are irreversible or significant actions. The user should always be asked before them unless they explicitly opt into automation.

Use this when:
- The user says "sync" without qualification
- This is the first sync on a project with significant drift
- The project is in a sensitive state and transitions should be human-gated

### `auto` (`--auto` or `-a`)

Execute all applicable fixes without asking the user. Use this when:
- The user explicitly says "sync auto" or adds `--auto`
- The command is invoked as a background task
- Speed and automation are preferred over human review

**Safety**: Auto mode respects all spec §6.2 trigger conditions literally. It will execute phase transitions and archival without confirmation.

---

## Procedure

### Step 1: Drift Scan (read-only)

Perform a targeted scan focused on actionable drift items:

| Check | How | Action threshold |
|-------|-----|-----------------|
| Unregistered files | Compare filesystem (excluding `_archive/`, `.git/`, `node_modules/`, `dist/`, `inbox/`, `outbox/`) against FILE_INDEX entries (recursive with sub-index prune, same algorithm as `check` §1.4) | Any file found on disk but not in index |
| CURRENT_STATUS freshness | Read first 5 lines, extract "Last updated" date | Not today |
| CLAUDE.md one-line status | Read first 5 lines, extract "One-line status (as of DATE)" | Date mismatches CURRENT_STATUS |
| Car body length | Count lines between car-body heading and next `##` | ≥200 lines |
| WORKLOG length | `wc -l` | ≥1000 lines |
| Inbox/outbox | Same four sub-checks as `check` §1.7 (if adopted) | Any non-✅ result |

**Token efficiency**: Do NOT read leaf document content during the scan. Use Grep, line counting, and `find` only.

### Step 2: Execute Auto Fixes

Apply all fixes that are unambiguously safe:

1. **Register unregistered files**
   - Determine category by file extension and parent folder name (heuristic)
   - If no clear category exists, create or use `## Uncategorized`
   - If a category exceeds 20 files after registration, flag for sub-index creation (do NOT auto-create sub-indexes — that requires human judgment about category boundaries)
   - Record in CURRENT_STATUS car body: `#### Sync-registered N files (YYYY-MM-DD)` with a summary list

2. **Refresh stale dates**
   - Update CURRENT_STATUS "Last updated" to today
   - Update CLAUDE.md "One-line status (as of [DATE])" to today (preserve the text, bump only the date)
   - Update FILE_INDEX "Last updated" to today

3. **Inbox/outbox housekeeping** (if adopted)
   - Same remedial actions as `check` §1.7 flags would prompt (archival of stale actioned messages, malformed review, etc.)

### Step 3: Phase-Transition Check

If car body ≥200 lines:

- **Interactive mode** (default) → Ask: "Car body is N lines (threshold: 200). Execute phase transition now? (yes/no)" If yes → proceed. If no → record in car body: `#### Phase transition deferred by user on YYYY-MM-DD (car body at N lines)`.
- **Auto mode** → Execute the five-step phase transition (spec §6.2) immediately. Data protection first: Step 1 (copy car body to WORKLOG) executes before any other write.

If car body <200 lines but the steps within it no longer serve the same phase goal (phase coherence failure per `check` §2.4):

- **Auto mode** → Still execute phase transition. Coherence failure is a stronger signal than line count.
- **Interactive mode** → Ask: "Steps in car body appear to serve different goals. Execute phase transition? (yes/no)"

### Step 4: WORKLOG Archival Check

If WORKLOG ≥1000 lines:

- **Interactive mode** (default) → Ask: "WORKLOG is N lines (threshold: 1000). Archive older phases now? (yes/no)"
- **Auto mode** → Execute archival per spec §5.5 (keep most recent 3 phases, move earlier to `WORKLOG_ARCHIVE_YYYY-MM-DD.md`, register, record in car body, atomic git commit).

### Step 5: Context-Principle Extraction (interactive only)

If mode is interactive:

1. Scan the current session's context for principles, lessons, or rules that have emerged but are not yet recorded.
2. Present a concise summary to the user: "During this session/work phase, I observed: [list]. Should any of these be recorded in PHILOSOPHY.md or promoted to CLAUDE.md iron rules?"
3. If the user confirms any item → create/append the document, register in FILE_INDEX, record in car body.

In **auto mode**, skip this step entirely. Auto mode does NOT attempt to synthesize principles from context — that requires human judgment about which insights generalize.

---

## Output Format

```
═══════════════════════════════════════
  Doc Harness — Status Sync
  Project: [name]
  Date: YYYY-MM-DD
  Mode: auto / interactive
═══════════════════════════════════════

── Scan Results ──
[FILE_INDEX]    N unregistered files found
[CURRENT_STATUS] Last updated: YYYY-MM-DD (stale/fresh)
[CLAUDE.md]     One-line status date: YYYY-MM-DD (stale/fresh)
[Car body]      N lines (under limit / at threshold / over limit)
[WORKLOG]       N lines (under limit / at threshold / over limit)
[Inbox/Outbox]  [if adopted: summary of sub-checks]

── Actions Taken ──
- Registered N files: [category list]
- Refreshed dates: CURRENT_STATUS, CLAUDE.md, FILE_INDEX
- Phase transition: [not needed / executed / deferred by user]
- WORKLOG archival: [not needed / executed / deferred by user]
- Principles recorded: [none / list]

── Remaining Items (if any) ──
[Interactive-mode user decisions still pending, or auto-mode notes]
═══════════════════════════════════════
```

---

## Relationship to Other Commands

| | `check` | `sync` | `flush` |
|--|---------|--------|---------|
| **Modifies files?** | No | Yes | Yes |
| **Scope** | Full audit + principle reflection | Drift repair + maintenance | Everything sync does + context extraction |
| **Trigger** | Periodic / user request / drift felt | "Docs are behind" | "Context is about to compress" |
| **Phase transition** | Reports threshold | Can execute (auto or ask) | Can execute (auto or ask) |
| **Context extraction** | Asks "anything unsaved?" (no action) | Interactive-only principle ask | Mandatory inventory + write |

---

## Language-Independence Note

All anchors match **either English or Chinese** headings produced by `init.md` templates — same dual-anchor logic as `check.md`.
