# Doc Harness — Operational Rules

<!-- doc-harness-ops-start -->
<!-- doc-harness-ops-version: 1.5.1 -->

> This section is embedded in each project's CLAUDE.md as the complete guide for maintaining status documents.
> For full design rationale, see `DOC_HARNESS_SPEC.md` (in the project root directory).
> The HTML comments `doc-harness-ops-start` / `doc-harness-ops-end` delimit the embedded region — `init.md` re-embed and `/doc-harness check` §1.10 use them to locate and replace the block safely. Do not remove either marker. The `doc-harness-ops-version: N.N` tag is read by `check.md` §1.10 to detect stale operational-rules sections after a skill upgrade.

---

## First Principle: "Write It Down or Lose It"

All information in context will eventually be lost completely. Important information must be **written to a file** and **registered in FILE_INDEX**. Not written = lost. Not registered = exists but undiscoverable = effectively lost. Better to write one extra file than to let information exist only in context.

## Four Core Documents

| Document | Role | When to update |
|----------|------|---------------|
| **CLAUDE.md** | Project entry. Overview, recovery chain, iron rules, these operational rules | Phase transitions for body; "one-line status" refreshed every session end |
| **CURRENT_STATUS.md** | Active status (see below) | Every session |
| **FILE_INDEX.md** | Index all project files by category | When files are created/deleted |
| **WORKLOG.md** | Complete work history (append-only) | Phase transitions: receives content from CURRENT_STATUS |

## CURRENT_STATUS.md — Four Sections

Arranged in this order, each separated by `##`:

**§1 Recent Completed (Tire Tracks)**: Brief summaries (3-5 lines each) of the most recent 2-3 completed phases. For details → point to corresponding WORKLOG section. For new projects with no completed phases: write "(Project just started, no completed phases yet)".

**§2 Current Work (Car Body)**: Full detailed record of the current phase — phase goal, each completed step (what was done, files created, key decisions), unresolved issues. Organize by steps using `####` with dates in titles (e.g., `#### Completed BibTeX validation (2026-04-01)`). **Keep under ~200 lines**; if exceeded, consider triggering a phase transition.

**§3 Next Steps (Headlights)**: Immediate actions (1-3 specific steps) + future plans.

**§4 Current Working Principles (Driving Manual)**: Guidelines applicable to this phase. These live and die with the phase — on phase transition, review each: (a) promote to CLAUDE.md iron rule? (b) still applicable → keep? (c) no longer relevant → remove. Mark satisfied principles `[DONE]` but keep until phase ends.

## FILE_INDEX.md Rules

- Organize by **category** (`##` headings), not by time. Categories are project-specific; add/reorganize freely
- Each entry: `path` — one-line description
- File spans two categories → place in primary category only; other category writes "→ see §[primary]"
- Category has >10 files → recommend creating sub-FILE_INDEX.md in that folder; parent index points to it in one line
- Category has >20 files → must create sub-index
- Bulk file creation → register folder + count + naming pattern, not individual files

## WORKLOG.md Rules

- Maintain a **TOC table** at the top:

```markdown
## TOC
| Phase | Time | Anchor |
|-------|------|--------|
| Phase 2: [name] | YYYY-MM-DD~MM-DD | [→](#phase-2-name) |
| Phase 1: [name] | YYYY-MM-DD~MM-DD | [→](#phase-1-name) |
```

- Each phase is one `##` section containing "Phase Summary" (3-5 lines) + "Detailed Record" (copied from CURRENT_STATUS car body)
- Newest phase at top (after TOC)
- New project WORKLOG: only empty TOC table; content arrives at first phase transition
- Written content is **never modified or deleted**. Factual errors: annotate `[Erratum (date): correction]`

### Archival (when WORKLOG grows long)

**Trigger**: WORKLOG.md exceeds ~1000 lines (line count, not phase count — density varies across projects).

**Procedure**:
1. Keep the most recent 3 phases in `WORKLOG.md`.
2. Move earlier phases (and their TOC entries) to `WORKLOG_ARCHIVE_<YYYY-MM-DD>.md` where the date is **the archival event date** (today), not a fixed-period bin. Each archival event produces its own file, keeping any single archive bounded by the ~1000-line trigger. Multiple archive files accumulate chronologically over time.
3. At the top of the **archive file**, add a backlink: `> Part of the WORKLOG series. Current WORKLOG: WORKLOG.md. Other archives: WORKLOG_ARCHIVE_2025-12-03.md, ...`
4. At the top of `WORKLOG.md`, add (or update) a forward pointer: `> Earlier history archived in: WORKLOG_ARCHIVE_2025-12-03.md, WORKLOG_ARCHIVE_2026-04-19.md, ...` (chronological order).
5. Register the new archive file in FILE_INDEX under a `## Archived History` category (create if missing).
6. Record the archival in CURRENT_STATUS car body as a one-line "Completed Step": `- (YYYY-MM-DD) Archived WORKLOG: moved phases N–M into WORKLOG_ARCHIVE_<YYYY-MM-DD>.md; active WORKLOG keeps most recent 3 phases.`

**Git convention**: make the entire archival move a single atomic commit with message `Archive WORKLOG <YYYY-MM-DD> (keep most recent 3 phases)`. Don't mix with unrelated work.

Archive files are permanent records; never delete. Full details: `DOC_HARNESS_SPEC.md` §5.5.

## Phase Transition — Five Steps

**When to transition**: Work goal fundamentally changes; user explicitly declares; pause >3 days; car body >200 lines. Sub-task switches within same goal (e.g., Ch4→Ch5 both under "literature reinforcement") → do NOT transition; use sub-headings in car body. When in doubt → don't transition.

**Five steps (strictly in this order)**:

1. **Protect data**: Copy CURRENT_STATUS car body content in full to WORKLOG top (after TOC). Add phase summary. → After this step, even if interrupted, no data is lost.
2. Insert new summary (3-5 lines) at top of CURRENT_STATUS tire tracks. Note "Detailed record in WORKLOG §[phase title]".
3. If tire tracks exceed 3 → remove the oldest (already permanently in WORKLOG).
4. Clear car body → fill in new phase goal. May include one brief context line (e.g., "Building on Phase N results"). Update driving manual (review each old principle).
5. Update CLAUDE.md "current phase" and "one-line status (as of date)". Update WORKLOG TOC.

## Recovery Chain (Session Start)

Recovery Chain is defined in CLAUDE.md and has two layers:

**Must-read** (2–3 files, baseline for any continuation):
1. CLAUDE.md (project scope, iron rules, operational rules)
2. CURRENT_STATUS.md (tire tracks / car body / headlights / driving manual)

**Task-conditional** (read only if the work matches):
- If looking up a file: read FILE_INDEX.md
- If investigating phase history: read WORKLOG.md
- [Project-specific entries added over time]

**Meta-rules**:
- Recovery Chain is **self-contained**: only project-internal files (or stable sibling-project paths). No dependency on agent-side features (memory, chat history, external services) — those may not exist for the next agent.
- Recovery Chain is **living**: update it at phase transitions (add entries for new work classes; remove retired ones).

**Applying at session start**:
1. Read must-read layer in order.
2. Scan task-conditional; read only entries whose condition matches current work.
3. If user present → confirm whether next steps have changed. Compact recovery without user → continue per headlights.

## During Work

- Complete a **meaningful step** → update CURRENT_STATUS car body. "Meaningful" = if context is lost now, next agent needs to know this step is done.
- Create a new file → **do two things simultaneously**: (1) register in FILE_INDEX (2) record in CURRENT_STATUS car body.
- Important information → **immediately** write to file and register (Write It Down!).
- **Watch remaining context** (if the runtime exposes it). Compression is involuntary session end. When remaining context drops low (~<20%), update CURRENT_STATUS *before* the next tool call; if the car body holds substantial unsaved work, consider a phase transition now. Don't wait for the next "meaningful step" — it may not land in time. If the user notices context is running low, they may request `/doc-harness flush` to systematically save all important context information to files before compression.

## Session End Checklist

- [ ] CURRENT_STATUS car body reflects all work from this session?
- [ ] Headlights "next steps" are accurate?
- [ ] CURRENT_STATUS "last updated" date refreshed?
- [ ] CLAUDE.md "one-line status (as of date)" refreshed?
- [ ] All files created this session registered in FILE_INDEX?
- [ ] Any important information only in context? → Write it down!
- [ ] If a phase transition occurred: WORKLOG under ~1000 lines? (Over → trigger archival.)

> The user may request `/doc-harness check` at any time for a comprehensive health audit and principle reflection. Recommended to run as a background agent to avoid interrupting current work.
> If significant drift is detected (files unregistered, dates stale, car body over limit), the user may request `/doc-harness sync` to repair it automatically.
> If context compression is imminent, run `/doc-harness flush` to systematically extract all important context information into documents before it is lost.

## Status Sync and Context Flush

Two commands complement the daily workflow:

- **`/doc-harness sync`** — Repair documentation drift. Scans for unregistered files, stale dates, and length thresholds; executes fixes; optionally triggers phase transition or WORKLOG archival. Auto mode (default) executes without asking; interactive mode asks before major changes.
- **`/doc-harness flush`** — Emergency save. Includes everything `sync` does, plus mandatory extraction of important context information into documents. Use when context is about to compress or reset. After a successful flush, a new agent reading the Recovery Chain should recover state as if context had never been compressed.

## Project Pause

Execute phase transition five steps → write "Project paused on YYYY-MM-DD. Reason: ..." in car body → set CLAUDE.md status to ⏸️. On resume: headlights "next steps" may be stale — confirm with user before proceeding.

## Single Source of Truth

Each fact maintained in only one document. Current state/numbers → CURRENT_STATUS. File catalog → FILE_INDEX. Historical details → WORKLOG. Project overview/iron rules → CLAUDE.md. CLAUDE.md's "one-line status (as of date)" is the only allowed redundancy; if contradicted, CURRENT_STATUS is authoritative.

## Iron Rule Management

Iron rules live in CLAUDE.md; they persist for the project's lifetime. New iron rules may be added at phase transitions (promoted from driving manual). Iron rules are generally not deleted; if preconditions no longer apply, annotate "[No longer applicable: reason]" but keep original text.

## Document Lifecycle

Superseded documents: add at **first line**: `⚠️ SUPERSEDED BY [new document path]`. Then choose:
- **Retained as reference** (most common): move to `## Superseded` category in FILE_INDEX. Note why retained.
- **No longer useful**: move to `_archive/` and remove from FILE_INDEX.

## Optional Long-Horizon Documents

Two opt-in documents exist outside the core four. Create only when there is content to put in them; keep them in the task-conditional Recovery Chain layer, not must-read.

- **`PARKING_LOT.md`** — Deferred items: things you want to do but can't now. Each entry: what, why deferred, preconditions for revival, re-check date. Never silently delete; annotate when revived or dropped. Use when CURRENT_STATUS would otherwise lose an item to work churn.

- **`PHILOSOPHY.md`** — Principles from practice: generalizable lessons forged by this project's specific work. Each entry: principle statement, the practice that forged it, scope, first-recorded date. Principles may be shared into sibling projects' PHILOSOPHY.md; this file remains the birthplace record for *this* project. Use when an insight likely applies beyond the immediate situation.

See `DOC_HARNESS_SPEC.md` Chapter 13 for full formats, lifecycle, and rationale.

## Optional Inter-Project Communication (inbox/outbox)

Adopted when this project coordinates with other projects (dependencies in either direction, repeated cross-project decisions/deliverables). If `inbox/` and `outbox/` directories exist at the project root, the protocol is active.

**Receiving**:
- Recovery Chain task-conditional includes: "If `inbox/` has any file with `status: unread`: read them."
- Read the message → update its YAML `status` field to `read` → perform any required action → update to `actioned`.
- Never edit received messages beyond the status field. To respond, write a **new** message.

**Sending**:
- Filename: `YYYY-MM-DD-from-<this-project>-<topic-slug>.md`.
- YAML frontmatter: `from`, `to`, `date`, `subject`, `status: unread` (sender sets), `in-reply-to` (if reply), `priority`.
- Body: free-form Markdown.
- Write to this project's `outbox/` (sender-side permanent record) AND copy the same file to recipient's `inbox/`.
- Record the exchange in CURRENT_STATUS car body.

**Snapshots over pointers**: when communicating numbers/deliverables to another project, put the value in the message body — do NOT point the recipient at your internal files (they churn and break external references).

Complete specification, including archival (30-day actioned messages → `inbox/_archive/`) and retrofit procedure: see `DOC_HARNESS_SPEC.md` Chapter 14.

<!-- doc-harness-ops-end -->
