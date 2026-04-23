# Doc Harness — Flush (Kimi CLI Version)

Emergency save: systematically extract all important context information into documents and register them before context compression or session end.

**Trigger**: User says something like "save everything", "flush context", "prepare for compact", "ensure nothing is lost", "compress context but save important info first".

**Core guarantee**: After a successful flush, a brand-new agent reading the project's Recovery Chain should recover state **as if context had never been compressed** — knowing *what information exists* and *where to find it*.

> ⚠️ **Common Failure Mode — Read This First**
>
> Agents frequently execute `flush` by running `sync` (updating existing documents) and then **silently skipping Phase B and Phase C**. This produces output that looks like a successful flush but contains no context extraction — no new files created, no context information inventoried, no Phase B report.
>
> **If Phase B and Phase C are skipped, flush has failed. It is indistinguishable from sync.**
>
> The distinguishing feature of flush is **mandatory context inventory and extraction**. An agent that does not perform Phase B has not executed flush, regardless of what the output header claims.

---

## Relationship to Sync

`flush` **includes everything `sync` does** as its first phase. The difference is the mandatory **Context Inventory** (Phase B) and **Extraction** (Phase C).

If a project has no drift (all files registered, dates fresh, car body under limit), `sync` is a no-op. `flush` **still performs the context inventory and extraction** — this is its entire reason for existing.

> **Rule of thumb**: If the flush output does not contain a Phase B section (inventory report) and a Phase C section (created/appended files), the agent performed `sync`, not `flush`. Correct and re-run.

---

## How Kimi Decides: Ask or Auto?

Same as sync — default is to ask user before significant extractions. Auto only if user explicitly says "auto flush", "do it automatically", "no need to ask".

**Heuristic for "important" information** (any one suffices):
- User explicitly emphasized it ("this is important", "remember this")
- It represents a decision, rationale, or trade-off (not a transient thought)
- It required significant effort to produce (>5 minutes of analysis, multi-step reasoning, external lookup)
- Losing it would cause confusion or duplicated work for the next agent

---

## Procedure

### Phase A: Run Sync

Execute the complete `sync` procedure (see sync.md) in the same mode (ask-user or auto-approved). This ensures the document foundation is sound before adding new extractions.

If sync triggers a phase transition or WORKLOG archival, complete it fully before proceeding.

**Phase A completion gate**: Before proceeding, explicitly state:

```
Phase A (Sync) complete.
[Summary of sync actions performed]
Now entering Phase B: Context Inventory — MANDATORY, non-skippable.
```

---

### Phase B: Context Inventory (MANDATORY — non-skippable)

> 🚫 **This phase CANNOT be skipped.** Skipping Phase B means flush has failed.

Agent performs a self-scan of its current context. Classify every non-transient item.

**Skip rule**: If an item is already referenced in CURRENT_STATUS car body OR already registered in FILE_INDEX, mark it `DURABLE` and skip.

| Context Information Type | Target Document | Example |
|-------------------------|-----------------|---------|
| Analysis results | `notes/` or `findings/` | "Regression shows R² = 0.87" |
| Data discoveries | `notes/findings/` + registration | "Dataset has 12% missing values" |
| Design decisions | `design/` or car body | "Chose PostgreSQL over SQLite" |
| Architecture choices | `design/` or car body | "Microservice boundary at payment" |
| Error lessons | `PHILOSOPHY.md` or `lessons/` | "Never trust CSV encoding headers" |
| New rules / constraints | CLAUDE.md iron rules or driving manual | "All API responses must include request_id" |
| User verbal requirements | CURRENT_STATUS car body | "User wants dark mode by next release" |
| Intermediate data | `data/` or `tmp/` | "Cleaned dataset before aggregation" |
| Debugging discoveries | `notes/debug/` or car body | "Race condition fixed by adding barrier" |
| Cross-project dependencies | `outbox/` message (if adopted) | "WhoAMI needs model accuracy by Friday" |

**Exclusions** (never extract):
- Fleeting thoughts or brainstorming that did not converge
- Information already known to be wrong or superseded
- Transient tool output (e.g., `ls` listing, temporary error messages)
- Information user explicitly asked NOT to save

**Phase B completion checklist** (agent must produce this before proceeding):

```
Phase B (Context Inventory) complete.
- Total items scanned: [N]
- Items marked DURABLE (already in files): [M]
- Items classified for extraction: [K]
- Items excluded (transient/wrong/user-denied): [P]
```

If `K > 0` → proceed to Phase C.
If `K = 0` → produce the **Empty Scan Report** below, then proceed to Phase D.

#### Empty Scan Report (mandatory when K = 0)

Even when no extractable items are found, the agent must document what was scanned and why nothing qualified:

```markdown
#### Context Inventory — Empty Scan (YYYY-MM-DD HH:MM)
- Scan scope: [e.g., "All analysis results, design decisions, debugging discoveries, and user requirements from this session"]
- Durable items found: [N] (already in car body or FILE_INDEX — listed below)
- Excluded items: [P] (transient / superseded / user-denied — listed below)
- Judgment basis: [Why the remaining context was deemed non-extractable]
```

> **Why this matters**: An empty scan with documented reasoning proves Phase B was performed. A missing Phase B section proves it was skipped.

---

### Phase C: Write and Register (MANDATORY — non-skippable if K > 0)

For each inventory item classified for extraction (not marked `DURABLE`):

1. **Determine target path**
   - Ask-user mode: propose to user; accept, reject, or edit path
   - Auto mode: apply heuristic (existing conventions → standard folders: `notes/`, `design/`, `lessons/`, `data/`)

2. **Write content**
   - Target file exists → append with dated header (`## Added on YYYY-MM-DD`)
   - Target file does not exist → create:
     ```markdown
     # [Title]
     
     > Extracted from context on YYYY-MM-DD during flush
     
     [content]
     ```

3. **Register in FILE_INDEX**
   - Add file path under appropriate category
   - If category does not exist, create it

4. **Record in CURRENT_STATUS car body**
   - `- (YYYY-MM-DD) Flushed: created/updated [path] — [one-line description]`

**Phase C completion checklist**:

```
Phase C (Write & Register) complete.
- New files created: [list with paths]
- Existing files appended: [list with paths]
- FILE_INDEX categories updated: [list]
- Car body entries added: [count]
```

---

### Phase D: Verification

Agent simulates a fresh arrival:

```
"I am a new agent with zero context. I read CLAUDE.md → CURRENT_STATUS.
   From car body, do I see references to all files I just created?
   From FILE_INDEX, can I locate each new file by category?
   From Recovery Chain, would I know to read these files if needed?"
```

- Any gap → supplement: add missing references to car body, ensure FILE_INDEX categories are clear
- All covered → pass

**Verification checklist**:
```
Phase D (Verification) complete.
- Fresh-arrival simulation: [pass / gaps found and fixed]
- Gaps fixed: [list, or "none"]
```

---

### Phase E: Final Flush Marker

Append to CURRENT_STATUS car body:

```markdown
#### Context flushed (YYYY-MM-DD HH:MM) — N items extracted to files
- Sync actions: [phase transition? yes/no] [archival? yes/no]
- New files created: [list]
- Existing files appended: [list]
- Empty scan: [yes/no — if yes, link to Empty Scan Report above]
```

---

## Output Format

```
═══════════════════════════════════════
  Doc Harness — Context Flush
  Project: [name]
  Date: YYYY-MM-DD HH:MM
  Mode: ask-user / auto-approved
═══════════════════════════════════════

── Phase A: Sync ──
[Same output as sync.md]

── Phase B: Context Inventory ──
[MANDATORY — this section must appear even if empty]
Scanned context. Found N items:
  [1] [type] — [summary] → [target path] / DURABLE / EXCLUDED
  [2] [type] — [summary] → [target path] / DURABLE / EXCLUDED
  ...
  [M] items already durable (skipped)
  [P] items excluded (reasons listed)

If K = 0:
  Empty Scan Report:
  - Scan scope: ...
  - Judgment basis: ...

── Phase C: Write & Register ──
[If K > 0: list created/appended files and registrations]
[If K = 0: "No items required extraction. Phase C skipped per Empty Scan Report."]

── Phase D: Verification ──
Simulated fresh arrival: [pass / gaps found and fixed]

── Phase E: Flush Marker ──
Recorded in CURRENT_STATUS car body.

═══════════════════════════════════════
```

> **If the output above does not contain a Phase B section**, the agent failed to execute flush. Treat as an incomplete operation and request re-execution.
