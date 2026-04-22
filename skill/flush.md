# Doc Harness — Flush

Emergency save: systematically extract all important context information into documents and register them before context compression or session end.

**Purpose**: When context is about to be lost (compression, reset, or user-initiated session end), `flush` ensures that information which currently exists **only in context** is written to files, registered in FILE_INDEX, and discoverable by future agents. It is the ultimate defense against the "Write It Down or Lose It" failure mode.

**Core guarantee**: After a successful flush, a brand-new agent reading the project's Recovery Chain should be able to recover state **as if context had never been compressed** — not necessarily knowing every detail immediately, but knowing *what information exists* and *where to find it*.

---

## When to Use

- User says "save everything," "flush context," "prepare for compact," or "make sure nothing is lost"
- Context usage is high and the user wants to ensure zero information loss
- Before a known context reset (e.g., switching to a different conversation, closing the IDE)
- After a long, high-density work session where many decisions and analyses accumulated in context
- When the user feels uneasy about how much important state is "in the agent's head" rather than on disk

---

## Relationship to `sync`

`flush` **includes everything `sync` does** as its first phase. The difference is the mandatory **Context Inventory** (Phase B) and **Extraction** (Phase C).

If a project has no drift (all files registered, dates fresh, car body under limit), `sync` is a no-op. `flush` still performs the context inventory and extraction.

---

## Two Modes

### `interactive` (default)

Ask the user before each significant extraction:
- "I found [X analysis] in context. Save it as [path/xxx.md]? (yes/no/edit path)"
- "I found [Y decision rationale]. Append to car body or create [design/y.md]?"
- "I found [Z lesson]. Save to PHILOSOPHY.md?"

This is the default because context extraction involves judgment about what is important and where it belongs. The user should review before documents are created.

Use this when:
- The user says "flush" without qualification
- Context contains sensitive or draft information that should NOT be persisted
- The project has strict folder conventions that heuristics might violate

### `auto` (`--auto` or `-a`)

Execute the full procedure without asking the user, using heuristics to classify and route context information.

**Heuristic for "important" information** (any one suffices):
- The user explicitly emphasized it ("this is important," "remember this")
- It represents a decision, rationale, or trade-off (not a transient thought)
- It took significant effort to produce (>5 minutes of analysis, multi-step reasoning, or external data lookup)
- Losing it would cause confusion or duplicated work for the next agent

**Heuristic for target path**:
- Use existing project folder conventions if clear categories exist
- If no convention exists, create standard folders as needed: `notes/`, `design/`, `lessons/`, `data/`, `tmp/`
- Never overwrite existing files without appending; always prefer "create new" or "append to existing"

Use this when:
- The user explicitly says "flush auto" or adds `--auto`
- Speed and automation are preferred over human review

---

## Procedure

### Phase A: Run Sync

Execute the complete `sync` procedure (see `sync.md`) in the same mode (auto or interactive). This ensures the document foundation is sound before adding new extractions.

If sync triggers a phase transition or WORKLOG archival, complete it fully before proceeding to Phase B.

### Phase B: Context Inventory

Agent performs a self-scan of its current context. Classify every non-transient item into one of the categories below.

**Skip rule**: If an item is already referenced in CURRENT_STATUS car body OR already registered in FILE_INDEX, mark it `DURABLE` and skip — it is already discoverable.

| Context Information Type | Target Document | Example |
|-------------------------|-----------------|---------|
| Analysis results | `notes/` or `findings/` | "Regression shows R² = 0.87, significant at p<0.01" |
| Data discoveries | `notes/findings/` + registration | "Dataset has 12% missing values in column X" |
| Design decisions | `design/` or car body | "Chose PostgreSQL over SQLite for concurrent writes" |
| Architecture choices | `design/` or car body | "Microservice boundary drawn at payment vs. inventory" |
| Error lessons | `PHILOSOPHY.md` or `lessons/` | "Never trust CSV encoding headers — always sniff" |
| Mistake patterns | `PHILOSOPHY.md` | "Repeatedly forgot to validate null inputs before v0.3" |
| New rules / constraints | CLAUDE.md iron rules or driving manual | "All API responses must include request_id" |
| User verbal requirements | CURRENT_STATUS car body | "User wants dark mode by next release" |
| Intermediate data | `data/` or `tmp/` | "Cleaned dataset before final aggregation" |
| Debugging discoveries | `notes/debug/` or car body | "Race condition in thread pool fixed by adding barrier" |
| Cross-project dependencies | `outbox/` message (if inbox/outbox adopted) | "WhoAMI needs our model accuracy by Friday" |

**Exclusions** (never extract):
- Fleeting thoughts or brainstorming that did not converge
- Information already known to be wrong or superseded
- Transient tool output (e.g., `ls` listing, temporary error messages)
- Information that the user explicitly asked NOT to save

### Phase C: Write and Register

For each inventory item not marked `DURABLE`:

1. **Determine target path**
   - Auto: apply heuristic above
   - Interactive: propose to user; accept, reject, or edit path

2. **Write content**
   - If target file exists → append with a dated header (`## Added on YYYY-MM-DD`)
   - If target file does not exist → create with frontmatter-style header:
     ```markdown
     # [Title]
     
     > Extracted from context on YYYY-MM-DD during `/doc-harness flush`
     
     [content]
     ```

3. **Register in FILE_INDEX**
   - Add the file path under the appropriate category
   - If the category does not exist, create it
   - If bulk registration is more appropriate (many similar files), register the folder + count

4. **Record in CURRENT_STATUS car body**
   - Add a one-line entry: `- (YYYY-MM-DD) Flushed: created/updated [path] — [one-line description]`
   - This ensures the next agent sees the extraction event even without reading the new file

### Phase D: Verification

Agent performs a simulated fresh arrival:

```
Simulation: "I am a new agent with zero context. I read CLAUDE.md → CURRENT_STATUS.
   From CURRENT_STATUS car body, do I see references to all the files I just created?
   From FILE_INDEX, can I locate each new file by category?
   From Recovery Chain, would I know to read these files if I needed their content?"
```

- **If any gap** → supplement: add missing references to car body, ensure FILE_INDEX categories are clear, add Recovery Chain task-conditional entries if a new document category warrants it.
- **If all covered** → pass.

### Phase E: Final Flush Marker

Append to CURRENT_STATUS car body:

```markdown
#### Context flushed (YYYY-MM-DD HH:MM) — N items extracted to files
- Sync actions: [phase transition? yes/no] [archival? yes/no]
- New files created: [list]
- Existing files appended: [list]
```

This marker serves as a durable record that a flush occurred, so future agents know the context was systematically saved.

---

## Output Format

```
═══════════════════════════════════════
  Doc Harness — Context Flush
  Project: [name]
  Date: YYYY-MM-DD HH:MM
  Mode: auto / interactive
═══════════════════════════════════════

── Phase A: Sync ──
[Same output as sync.md]

── Phase B: Context Inventory ──
Scanned context. Found N items:
  [1] [type] — [one-line summary] → [target path]
  [2] [type] — [one-line summary] → [target path]
  ...
  [M] items already durable (skipped)

── Phase C: Write & Register ──
- Created: [list]
- Appended: [list]
- Registered in FILE_INDEX: [category list]
- Recorded in car body: yes

── Phase D: Verification ──
Simulated fresh arrival: [pass / gaps found and fixed]

── Phase E: Flush Marker ──
Recorded in CURRENT_STATUS car body.

═══════════════════════════════════════
```

---

## Auto-Mode Heuristic Details

### "Important" threshold

Information is **important** if ANY of the following is true:
1. User explicitly called it out ("important," "remember this," "write this down")
2. It is a decision or rationale (choosing X over Y, why Z was rejected)
3. It required significant effort to produce (>5 min of analysis, multi-step reasoning, external lookup)
4. Losing it would cause a future agent to redo work or make inconsistent choices
5. It changes a previously established project fact or constraint

Information is **NOT important** if ALL of the following are true:
1. It is a transient observation ("the file is 4KB")
2. It does not affect future work
3. It can be trivially reproduced
4. The user did not call attention to it

### Target path selection

Priority order:
1. Existing project conventions (if `design/` already exists, use it)
2. Standard folder names by type:
   - Analysis → `notes/` or `analysis/`
   - Design → `design/`
   - Lessons → `lessons/` or `PHILOSOPHY.md`
   - Data → `data/`
   - Debug → `notes/debug/`
3. If no folder exists and creation is needed, prefer `notes/` as the generic catch-all

---

## Language-Independence Note

All anchors and heading matches follow the same dual-language logic as `check.md` and `sync.md`.
