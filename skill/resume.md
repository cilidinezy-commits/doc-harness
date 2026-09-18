# Doc Harness — Resume

Explicit, verifiable state recovery when context is empty or the user says "resume". `resume` proves the agent has correctly taken over — it is not just reading files.

## When to Use

- "resume this project", "continue", "where were we".
- Empty context + core files present → auto-trigger before any other action.
- After compact recovery (user absent).

## Modes

- **interactive** (default): present the Recovery Report; confirm with the user.
- **auto** (`--auto`): apply the freshness decision tree without asking; if the recovered reality differs from the projection, record the difference as events (never hand-edit CURRENT_STATUS).

## Phase A: Execute the Handoff Chain

**Step 0 — Identity**: read the AGENT IDENTITY LOCK at the top of `CLAUDE.md`. State: "I am this project's agent; my scope is ...".

**Step 1 — Stable anchor + declaration**: read `CLAUDE.md`'s Stable Anchor (framework anchor, iron rules, bottom-line principles). Then **declare** which layer/boundary the current task falls in (from the framework anchor) — say it out loud, don't just read it. Reading slides past; declaring is heard.

**Step 2 — Current state**: read the current state from `events.log` (via `tools/project.ps1` or `Get-DocState`), and verify `CURRENT_STATUS.md` is a fresh projection (run `tools/conformance.ps1` — it flags `projection-stale`). Never trust a possibly-stale `CURRENT_STATUS.md` alone.

Also read the **dead-end ledger** (`dead-end:set` events) for entries relevant to the active units — avoid re-walking a path already marked dead.

**Step 3 — Read-first**: read only the files `## NOW`'s read-first list points to.

**Step 4 — Edge scan**:
- NOW freshness: is "last refreshed" today? stale?
- Inbox unread: any `status: unread`?
- Encoding/size: does `## NOW` look intact and ≤ ~30 lines?
- Mid-transition: does NOW match the work surface / `events.log`?

## Phase B: Recovery Report (7 sections)

1. Identity & scope.
2. Now snapshot (in-progress, next step, read-first, key judgment).
3. Active frontier (which units are in play, across which parts).
4. Last closed unit (from the work surface / `## Recent History`, both projected from `events.log`).
5. Unread signals (inbox, drift).
6. Edge conditions (stale NOW, encoding, mid-transition, blockers).
7. Readiness (proceed / wait / run check|sync|flush first).

## Phase C: Understanding Verification (5 questions, in your own words)

1. What is the current work trying to achieve? (not the whole project)
2. What is the #1 next step and what blocks it?
3. What was the last work unit closed?
4. Are there unread signals that need action first?
5. Is it safe to proceed without user confirmation? (≤7d fresh + no edge conditions + not paused = safe)

If any fails, re-read and retry once; else flag understanding as incomplete.

## Phase D: Decision

- **Interactive**: present report + verification; ask "match your understanding? proceed with #1, or changed?"
- **Auto**: ≤7d fresh + no edge conditions + not paused → proceed; else write "waiting for user confirmation".

## Output Format

```
═══════════════════════════════════════
  Doc Harness — Resume
  Project: [name]   Date: YYYY-MM-DD HH:MM   Mode: interactive/auto
═══════════════════════════════════════
── Phase A: Handoff Chain ──
Identity: ...   Anchor: read   NOW: read   Read-first: [files]   Edges: [list]
── Phase B: Recovery Report ──
§1 Identity ... §7 Readiness ...
── Phase C: Verification ──
Q1..Q5 → pass/fail   Overall: ...
── Phase D: Decision ──
...
═══════════════════════════════════════
```
