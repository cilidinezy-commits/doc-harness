# Doc Harness — Recall

Retrieve information from a project's Doc Harness documents. Read-only; cite every claim.

Use `tools/search.ps1` for the mechanical grep (layers: `all` / `now` / `history` / `files` / `anchor`); `recall` is the synthesis protocol layered on top.

## Query Types

| Type | Meaning | Primary layers |
|------|---------|----------------|
| A. Status / plan | "What next?", "current state" | NOW + work surface |
| B. History / decision | "Why / when / who decided" | `events.log` (grep by unit-id / verb / date) |
| C. File / topic lookup | "find docs about X" | FILE_INDEX |
| D. Synthesis | "everything about X" | all layers |

Ambiguous → default to D.

## Layered Search (top-down, stop early)

- **Layer 0**: `CLAUDE.md` — stable anchor (framework anchor, iron rules, bottom-line principles).
- **Layer 1**: `CURRENT_STATUS.md` — `## NOW` first, then work surface / recent history.
- **Layer 2**: `events.log` — history lives here, one line per state change. Grep it (by unit-id, verb, or date); the Work Surface in CURRENT_STATUS is its readable table of contents. Do not read it top-to-bottom.
- **Layer 3**: `FILE_INDEX.md` — grep only; recurse into sub-indexes.
- **Layer 4**: individual files — grep + `-C 3`; full-read only as last resort.

## Token-Efficiency Rules

1. Context first: check whether the answer is already in conversation context.
2. Grep before read.
3. Never full-read large files: `events.log` is grep-only (by unit-id/verb/date); FILE_INDEX >50 lines → grep; any file >100 lines → grep + context.
4. Sub-indexes via grep, not full reads.
5. Cite every claim: `(CURRENT_STATUS.md ## NOW)` or `(notes/design.md#L42)`.
6. "Not found" is acceptable — do not hallucinate.
7. Stop early once answered.
8. Scope limit: >10 matches → show top 5 and ask to narrow.

## Output Format

```
═══════════════════════════════════════
  Doc Harness — Recall
  Query: ...   Type: A|B|C|D   Layers: 0–N
═══════════════════════════════════════
── Layer 0: Anchor ── ...
── Layer 1: NOW / Work Surface ── ...
── Layer 2: History ── ...
── Layer 3: Index Matches ── ...
── Layer 4: Document Details ── ...
── Synthesis ── [answer, every claim cited]
── Not Found / Drift Note ── [if any]
═══════════════════════════════════════
```

Recall is read-only. It notes drift but does not fix it (`sync` fixes; `check` reports).

