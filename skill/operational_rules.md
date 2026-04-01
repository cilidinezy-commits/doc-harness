# Doc Harness — Operational Rules

> This section is embedded in each project's CLAUDE.md as the complete guide for maintaining status documents.
> For full design rationale, see `DOC_HARNESS_SPEC.md` (in the project root directory).

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

## Phase Transition — Five Steps

**When to transition**: Work goal fundamentally changes; user explicitly declares; pause >3 days; car body >200 lines. Sub-task switches within same goal (e.g., Ch4→Ch5 both under "literature reinforcement") → do NOT transition; use sub-headings in car body. When in doubt → don't transition.

**Five steps (strictly in this order)**:

1. **Protect data**: Copy CURRENT_STATUS car body content in full to WORKLOG top (after TOC). Add phase summary. → After this step, even if interrupted, no data is lost.
2. Insert new summary (3-5 lines) at top of CURRENT_STATUS tire tracks. Note "Detailed record in WORKLOG §[phase title]".
3. If tire tracks exceed 3 → remove the oldest (already permanently in WORKLOG).
4. Clear car body → fill in new phase goal. May include one brief context line (e.g., "Building on Phase N results"). Update driving manual (review each old principle).
5. Update CLAUDE.md "current phase" and "one-line status (as of date)". Update WORKLOG TOC.

## Session Start

1. Read CLAUDE.md → understand project, iron rules, operational rules
2. Read CURRENT_STATUS.md → tire tracks (recent context), car body (current progress), headlights (next steps), driving manual (principles)
3. User present → confirm if next steps have changed; compact recovery without user → continue per headlights

## During Work

- Complete a **meaningful step** → update CURRENT_STATUS car body. "Meaningful" = if context is lost now, next agent needs to know this step is done.
- Create a new file → **do two things simultaneously**: (1) register in FILE_INDEX (2) record in CURRENT_STATUS car body.
- Important information → **immediately** write to file and register (Write It Down!).

## Session End Checklist

- [ ] CURRENT_STATUS car body reflects all work from this session?
- [ ] Headlights "next steps" are accurate?
- [ ] CURRENT_STATUS "last updated" date refreshed?
- [ ] CLAUDE.md "one-line status (as of date)" refreshed?
- [ ] All files created this session registered in FILE_INDEX?
- [ ] Any important information only in context? → Write it down!

> The user may request `/doc-harness check` at any time for a comprehensive health audit and principle reflection. Recommended to run as a background agent to avoid interrupting current work.

## Project Pause

Execute phase transition five steps → write "Project paused on YYYY-MM-DD. Reason: ..." in car body → set CLAUDE.md status to ⏸️. On resume: headlights "next steps" may be stale — confirm with user before proceeding.

## Single Source of Truth

Each fact maintained in only one document. Current state/numbers → CURRENT_STATUS. File catalog → FILE_INDEX. Historical details → WORKLOG. Project overview/iron rules → CLAUDE.md. CLAUDE.md's "one-line status (as of date)" is the only allowed redundancy; if contradicted, CURRENT_STATUS is authoritative.

## Iron Rule Management

Iron rules live in CLAUDE.md; they persist for the project's lifetime. New iron rules may be added at phase transitions (promoted from driving manual). Iron rules are generally not deleted; if preconditions no longer apply, annotate "[No longer applicable: reason]" but keep original text.

## Document Lifecycle

Superseded documents: add at **first line**: `⚠️ SUPERSEDED BY [new document path] — this file is for historical reference only`. Archived documents: remove from FILE_INDEX.
