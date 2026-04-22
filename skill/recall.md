# Doc Harness — Recall

Retrieve information from the project's Doc Harness document hierarchy. Given a user query, search systematically across registered documents and return structured, source-cited results.

**Trigger**: User types `/doc-harness recall [query]` or natural-language equivalents.

**Purpose**: As projects grow, information scatters across dozens of registered files. `recall` provides a systematic retrieval protocol that mirrors the Recovery Chain's hierarchy — from high-level summaries to low-level details — so the agent finds relevant information efficiently without reading every file.

**Relationship to other commands**:
- `check` audits documentation **health** ("Are the docs OK?")
- `sync` repairs documentation **drift** ("Fix the docs.")
- `flush` saves **context** to files ("Preserve what we know.")
- `recall` retrieves **information** from files ("What do we know about X?")

`recall` is **read-only**. It never modifies files.

---

## Query Type Classification

Classify the user's query into one of four types. The type determines which layers to search and how deeply.

| Type | Pattern | Primary layers | Example queries |
|------|---------|----------------|-----------------|
| **A. Status / Plan** | "What next?", "Current status of X?", "What's the plan?" | Layer 0–1 | "What's the current plan for auth?" |
| **B. History / Decision** | "Why did we...", "When did...", "Phase N", "Who decided..." | Layer 1–2 | "Why did we choose PostgreSQL?" |
| **C. File / Topic lookup** | "Find files about...", "Where is...", "List docs on..." | Layer 3–4 | "Find all docs about caching" |
| **D. Cross-document synthesis** | "Summarize...", "Everything about...", "All mentions of..." | Layer 1–4 | "All discussions about authentication" |

**Ambiguous query** (does not clearly fit one type): Default to **Type D** (synthesis) — it is the most comprehensive and will surface information from all layers. Note in the output: `Query type ambiguous — running comprehensive search.`

---

## The Layered Search Protocol

Search proceeds layer by layer, **top-down**. Stop early when the query is fully answered — do not read Layer 4 files if Layer 1–2 already provide a complete answer.

```
User query
    ↓
[Phase 1] Classify query type
    ↓
[Phase 2] Layered search (priority order)
    ├── Layer 0: CLAUDE.md (iron rules, overview, recovery chain)
    ├── Layer 1: CURRENT_STATUS (tire tracks, car body, headlights, driving manual)
    ├── Layer 2: WORKLOG (historical phase summaries)
    ├── Layer 3: FILE_INDEX + sub-indexes (catalog scan)
    └── Layer 4: Individual registered files (full-text when needed)
    ↓
[Phase 3] Synthesize & output
```

### Layer 0: CLAUDE.md

**When to read**: Always read first (it is small). Extract:
- Iron rules that may constrain the answer
- Project overview for context
- Recovery Chain entries that might be relevant

**Stop condition**: If the query is about iron rules or recovery chain, answer after this layer.

### Layer 1: CURRENT_STATUS.md

**When to read**: Always read (it is small, ~100–200 lines).

Search these sections in order:
1. **Headlights** (`## Next Steps`) — for Type A (status/plan) queries
2. **Car body** (`## Current Work`) — for Type A and B
3. **Tire tracks** (`## Recent Completed`) — for Type B (history) queries
4. **Driving manual** (`## Current Working Principles`) — for rule-related queries

**Stop condition**: If CURRENT_STATUS fully answers the query (e.g., "What are the next steps?" → headlights), stop here.

### Layer 2: WORKLOG.md

**When to read**: For Type B (history/decision) and Type D (synthesis). Skip for pure Type A (status/plan) unless the user explicitly asks for historical comparison.

**Search strategy**:
1. Read the TOC (first 20 lines) to identify relevant phases
2. Jump to matching phase sections by anchor link
3. Extract phase summaries that mention the query topic

**Stop condition**: If WORKLOG answers the historical question completely, stop here.

### Layer 3: FILE_INDEX + Sub-indexes

**When to read**: For Type C (lookup) and Type D (synthesis). For Type A/B, read only if Layers 1–2 were insufficient.

**Search strategy**:
1. Read the root FILE_INDEX.md
2. For each category, grep for the query keywords in entry descriptions
3. If a category points to a sub-FILE_INDEX.md, recurse into it
4. Record matching entries with their one-line descriptions

**Sub-index recursion rule**: When FILE_INDEX contains an entry like:
```
- `notes/findings/` → see [`notes/findings/FILE_INDEX.md`]
```
Read that sub-FILE_INDEX and search it too.

**Stop condition**: For Type C, if the user only wanted a file list, stop after collecting matches.

### Layer 4: Individual Files

**When to read**: When Layers 1–3 identify relevant files but their descriptions are insufficient to answer the query.

**Search strategy**:
1. Prioritize files matched in Layer 3
2. Read each file's full content (or grep for query keywords)
3. Extract relevant excerpts with line/section references

**Scope limit**: If >20 files match in Layer 3, **do not read all of them**. Instead:
- Present the FILE_INDEX match summary to the user
- Ask: "20+ files match. Which categories should I deep-read?"
- Or, if the query is narrow enough, read only the top 5 most relevant files and note: "Showing top 5 matches — more available."

---

## Search Rules (Normative)

1. **Only search registered files** (in FILE_INDEX or sub-indexes). Unregistered files are invisible to `recall` — this incentivizes registration per the core principle.
2. **Respect Recovery Chain priority**: Summaries in CURRENT_STATUS take precedence over raw files. If tire tracks already answer the question, do not force-read 10 source files.
3. **Sub-indexes are first-class**: Recurse into sub-FILE_INDEX.md files exactly as FILE_INDEX traversal would.
4. **Cite every claim**: Every fact must carry a citation:
   - `(CLAUDE.md §Iron Rules)`
   - `(CURRENT_STATUS.md §Car Body)`
   - `(WORKLOG.md §Phase 3)`
   - `(FILE_INDEX.md → notes/design.md)`
   - `(notes/design.md §Database Choice, L42)`
5. **"Not found" is acceptable**: If the query has no match, say so clearly. Do not hallucinate or guess.
6. **No file modifications**: `recall` is read-only. If you notice drift during recall, note it in the output but do not fix it — that is `sync`'s job.
7. **Stop early**: Do not read Layer 4 if Layers 1–2 already answer the query.

---

## Output Format

```
═══════════════════════════════════════
  Doc Harness — Recall
  Query: [user's exact query]
  Type: [A | B | C | D | ambiguous→D]
  Layers searched: [0–1 | 0–2 | 0–3 | 0–4]
═══════════════════════════════════════

── Layer 0: Project Overview ──
[relevant excerpts from CLAUDE.md, if any]

── Layer 1: Current Status ──
[relevant excerpts from CURRENT_STATUS, with citations]

── Layer 2: Worklog History ──
[relevant phase summaries from WORKLOG, with citations]
(omit if skipped)

── Layer 3: File Index Matches ──
[matching FILE_INDEX entries with descriptions]
(omit if no matches or skipped)

── Layer 4: Document Details ──
[if read: key excerpts from individual files, with citations]
(omit if skipped)

── Synthesis ──
[concise answer to the user's question; every claim cited]

── Not Found ──
[if applicable: "The following topics were not found in registered documents: ..."]

── Drift Note ──
[if applicable: "Note: recall noticed unregistered files that may be relevant: ..."]
═══════════════════════════════════════
```

**Omission rule**: If a layer was skipped (because an earlier layer fully answered the query), omit that layer's section entirely. Do not write "Layer 2: (skipped)."

---

## Edge Cases

### Query matches nothing

```
── Synthesis ──
No registered documents mention "[query topic]". 

Possible reasons:
- The topic has not been documented yet.
- Relevant files exist but are not registered in FILE_INDEX.
- The topic is described using different terminology.

Suggestion: Run `/doc-harness sync` to ensure all files are registered, then retry.
```

### Query matches unregistered files

If a grep across the filesystem finds matches in **unregistered** files, note them in the `Drift Note` section but do not read their contents (they are not part of the Doc Harness trust boundary):

```
── Drift Note ──
The following unregistered files also mention "[topic]" but were not read:
- `tmp/draft.md`
- `data/experiment_notes.txt`

Consider registering them in FILE_INDEX if they contain durable information.
```

### Very large project (>100 registered files)

If FILE_INDEX lists 100+ files (including sub-indexes):
1. Read FILE_INDEX categories first
2. Only search categories whose descriptions match the query
3. For matching categories with >20 files, present the category list and ask user which to deep-read
4. Never read more than 20 individual files in a single recall

---

## When to Use

- User asks "Why did we decide X?" → Type B
- User asks "What's the current status of Y?" → Type A
- User asks "Find all files about Z" → Type C
- User asks "Summarize everything we know about W" → Type D
- User asks vague open-ended questions that imply "search the project docs"

## When NOT to Use

- Do not use `recall` when the user is clearly asking you to **create** something — that is normal work, not retrieval.
- Do not use `recall` for questions that can be answered from context alone (e.g., "What did you just say?").
- Do not use `recall` when the user explicitly asks you to **modify** a file — retrieval is a side effect, not the goal.
