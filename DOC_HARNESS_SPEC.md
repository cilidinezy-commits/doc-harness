# Doc Harness — Complete Specification

**Version**: v1.3
**Date**: 2026-04-19
**Status**: Production-ready

---

## Chapter 1: First Principles & Overview

### 1.1 First Principle: "Write It Down or Lose It"

All information in context is temporary. No matter how important an analysis result or how brilliant a design idea, if it is not **written to a file** and **registered in FILE_INDEX**, it effectively does not exist.

- **Write it down**: Important information must be saved to a file. Not written = lost.
- **Register it**: The file must be registered in FILE_INDEX. Not registered = exists but undiscoverable = effectively lost.

This principle takes priority over all efficiency considerations. Better to create one extra file than to let information exist only in context.

### 1.2 What is Doc Harness

Doc Harness is an information management system composed of four core documents, serving a **project**. A project is the basic unit — a working paper, a software tool, a research initiative.

| Document | Role | Core Responsibility | Update Frequency |
|----------|------|-------------------|-----------------|
| **CLAUDE.md** | Front door | Project entry, recovery chain, iron rules | Phase transitions |
| **CURRENT_STATUS.md** | Moving car | Active phase info, recent history, next steps, phase principles | Every session |
| **FILE_INDEX.md** | Library catalog | Index all project files by category | When files change |
| **WORKLOG.md** | Dash cam | Permanently store complete work details from all phases | Phase transitions (batch) |

### 1.3 Core Scenarios

| Scenario | Need |
|----------|------|
| **New agent arrives** | Read CLAUDE.md → CURRENT_STATUS → know what to do |
| **Context compact recovery** | Read CURRENT_STATUS → resume from car body |
| **Cross-project switch** | Read target project's CLAUDE.md → quick orientation |
| **During work** | Update CURRENT_STATUS car body + register new files in FILE_INDEX |

### 1.4 No External Memory Dependency

Doc Harness is fully self-contained. It does not depend on MEMORY.md, conversation history, or any agent's private memory. Any agent can fully recover project state by reading files alone.

If the environment provides a memory system (e.g., Claude Code's MEMORY.md), it can serve as **supplementary acceleration** but is never a requirement for recovery.

---

## Chapter 2: CLAUDE.md — Entry Document

### 2.1 Responsibilities
- Tell newcomers "what this project is"
- Provide recovery chain (reading order)
- Define project-level iron rules (permanent, phase-independent)
- Point to the other three core documents
- Provide stable project-specific technical information

### 2.2 What it does NOT do
- Does not record detailed current state (→ CURRENT_STATUS)
- Does not list all files (→ FILE_INDEX)
- Does not record historical work details (→ WORKLOG)

### 2.3 Template

CLAUDE.md consists of three parts: project-specific information + embedded operational rules + pointer to full spec.

```markdown
# [PROJECT_NAME] — Entry Document

**Last updated**: YYYY-MM-DD
**Current phase**: [Phase name] (⏳/⏸️/✅)
**One-line status (as of YYYY-MM-DD)**: [Brief description]

---

## Recovery Chain

Recovery Chain is the entry ritual for any agent or human resuming work on this project.
It has two layers.

### Must-read (baseline)

Files any continuation must read. Keep to 2–3 entries.

1. This file (CLAUDE.md)
2. `CURRENT_STATUS.md`

### Task-conditional

Read only if the work matches. Grows and shrinks as the project evolves.

- If looking up a specific file: read `FILE_INDEX.md`
- If investigating historical phase details: read `WORKLOG.md`
- [Add project-specific entries as needed — e.g., "If doing X: read Y.md"]

### Meta-rules

- Recovery Chain is **self-contained**: every entry points to a file inside the project
  (or a stable sibling-project path). Do not depend on agent-side features
  (memory systems, chat history, external services) — those may not exist for the next agent.
- Recovery Chain is **living**: add entries when new classes of work appear; remove entries
  when work categories retire. Review at phase transitions.

## Project Overview

[3-5 lines: project goals, outputs, key context]

## Project-Level Iron Rules

[Permanently valid, phase-independent rules]
- Iron rule 1: ...
- Iron rule 2: ...

## Key Technical Information

[Stable technical details: build commands, path conventions, dependencies]

## Sub-projects (if any)

- `subproject/` → see [subproject/CLAUDE.md](subproject/CLAUDE.md) (status: ⏳/⏸️/✅)

## Doc Harness — Operational Rules

[EMBED FULL CONTENT OF operational_rules.md HERE (~106 lines).
 These rules are the complete guide for daily status document maintenance.
 For full design rationale, see DOC_HARNESS_SPEC.md in project root.]
```

The complete operational rules are in `operational_rules.md`. The `/doc-harness init` skill embeds the current version automatically when creating CLAUDE.md.

### 2.4 Update Rules
- Update "current phase" and body content at phase transitions
- Refresh "one-line status (as of date)" at every session end
- Update "iron rules" when new rules are added
- Operational rules section generally not modified — determined by the spec version at creation time

---

## Chapter 3: CURRENT_STATUS.md — Active Status Document

### 3.1 Role and Structure

CURRENT_STATUS is the project's **active nerve center**, organized using the "moving car" metaphor:

| Section | Metaphor | Content | Lifecycle |
|---------|----------|---------|-----------|
| §1 Recent Completed | Tire Tracks | Brief summaries of 2-3 most recent completed phases (3-5 lines each) | Rolling window |
| §2 Current Work | Car Body | Full detailed record of current phase | Transfers to WORKLOG at phase end |
| §3 Next Steps | Headlights | Immediate actions + future plans | Updated every session |
| §4 Working Principles | Driving Manual | Guidelines for this phase | Lives and dies with the phase |

### 3.2 Template

```markdown
# CURRENT_STATUS — [PROJECT_NAME]

**Last updated**: YYYY-MM-DD
**Current phase**: [Phase name]

---

## Recent Completed (Tire Tracks)

(For new projects: "Project just started, no completed phases yet")

### [Phase N-1 name] (YYYY-MM-DD ~ YYYY-MM-DD)
[3-5 line summary]
Detailed record in WORKLOG.md § [corresponding title].

### [Phase N-2 name] (YYYY-MM-DD ~ YYYY-MM-DD)
[3-5 line summary]
Detailed record in WORKLOG.md § [corresponding title].

---

## Current Work (Car Body)

### Phase Goal
[What this phase aims to accomplish]

### Completed Steps

#### [Step 1 name] (YYYY-MM-DD)
- What was done
- Files created → registered in FILE_INDEX
- Key findings/decisions

#### [Step 2 name] (YYYY-MM-DD)
- ...

### Unresolved Issues
- [Issue 1]

---

## Next Steps (Headlights)

### Immediate Actions
1. [Next specific step]

### Future Plans
- [Longer-term plans]

---

## Current Working Principles (Driving Manual)

[Guidelines for this phase. On phase transition, review each:
 (a) promote to iron rule? (b) keep? (c) remove?
 Mark satisfied principles [DONE] but keep until phase ends.]
- Principle 1: ...
- Principle 2: ...
```

### 3.3 Car Body Update Granularity

**Key rule: Prepare for compact.** Do not assume the current session will complete normally.

- After completing each **meaningful step**, update the car body. "Meaningful" = if context is lost now, the next agent needs to know this step is done.
- Organize by **steps** (not sessions). One session may complete multiple steps; one step may span multiple sessions.
- **Car body length guideline**: Keep under ~200 lines. If exceeded, consider triggering a phase transition.

### 3.4 Update Rules
- Update at least once per session (completed steps + headlights + last updated date)
- When creating new files, record "created xxx" in car body AND register in FILE_INDEX

---

## Chapter 4: FILE_INDEX.md — File Index Document

### 4.1 Responsibility
Index all project files by **category**. Answer "what files exist, what are they, where are they?"

### 4.2 Organization Principles
- Group by category (`##` headings), **not by time**
- Categories are project-specific; add or reorganize freely
- Each entry: file path + one-line description
- File spans two categories → place in primary only; other category writes "→ see §[primary]"

### 4.3 Recursive Sub-indexes

When a category exceeds **10 files**, recommend creating a sub-FILE_INDEX.md in that folder. Over **20 files**, it is mandatory.

Parent FILE_INDEX keeps one line for that category:
```markdown
- `notes/findings/` → see [`notes/findings/FILE_INDEX.md`](notes/findings/FILE_INDEX.md)
  (Ch04/Ch05 research findings, 38 files, organized by chapter)
```

Sub-FILE_INDEX header references parent:
```markdown
# FILE_INDEX — [Category name]
**Parent index**: [`../../FILE_INDEX.md`](../../FILE_INDEX.md)
```

Recursion depth limited to **2 levels** (parent → child → grandchild). Deeper nesting indicates overly complex structure; consider reorganizing folders.

### 4.4 Bulk File Creation

When a session creates many similar files (e.g., 20 analysis reports at once), no need to register individually:
1. Register the **folder** in FILE_INDEX with file count and naming pattern
2. If count >10, create sub-FILE_INDEX.md
3. Record in CURRENT_STATUS car body: "Created N files in xxx/, naming pattern: ..."

### 4.5 Template

```markdown
# FILE_INDEX — [PROJECT_NAME]

**Last updated**: YYYY-MM-DD

---

## Core Documents
- `CLAUDE.md` — Project entry
- `CURRENT_STATUS.md` — Active status
- `FILE_INDEX.md` — This file
- `WORKLOG.md` — Work history

## [Category 1]
- `path/file1.md` — Description
- `path/file2.md` — Description

## [Category 2]
- `path/folder/` → see [`path/folder/FILE_INDEX.md`] (N files, brief description)

## [Category 3]
- `path/file3.py` — Description
```

### 4.6 Update Rules
- Register when creating new files
- Remove when deleting/archiving files
- No need to update every session — only when the file system changes

---

## Chapter 5: WORKLOG.md — Work Log Document

### 5.1 Responsibility
Permanently store **complete** work details from all phases. Content comes from CURRENT_STATUS during phase transitions.

### 5.2 Table of Contents (TOC)

WORKLOG maintains a TOC at the top for quick navigation in long documents:

```markdown
# WORKLOG — [PROJECT_NAME]

## TOC
| Phase | Time | Anchor |
|-------|------|--------|
| Phase 5: Format fixes | 2026-03-29~03-30 | [→](#phase-5-format-fixes) |
| Phase 4: Literature | 2026-03-27~03-29 | [→](#phase-4-literature) |
| Phase 3: Ch5 rebuild | 2026-03-25~03-27 | [→](#phase-3-ch5-rebuild) |

---

## Phase 5: Format fixes
[Detailed content...]

## Phase 4: Literature
[Detailed content...]
```

### 5.3 Content Format

Each phase is a top-level section (`##`):

```markdown
## Phase N: [Name] (YYYY-MM-DD ~ YYYY-MM-DD)

### Phase Summary
[3-5 line summary added at phase end]

### Detailed Record
[Content copied verbatim from CURRENT_STATUS car body]
```

### 5.4 Modification Rules

- **Allowed**: Append summary or errata at the beginning of existing phases
- **Allowed**: Add new entries to the TOC
- **Forbidden**: Modify or delete content copied from CURRENT_STATUS
- Factual errors: annotate as `[Erratum (YYYY-MM-DD): actual value was 4087, not 4090]`

### 5.5 Archival

WORKLOG is append-only, so it inevitably grows. A 2000-line WORKLOG is a liability — any agent asked to "check the history" fetches the whole thing and burns context. Archive to keep WORKLOG.md itself readable while preserving full history on disk.

**Trigger** (soft threshold): WORKLOG.md exceeds **~1000 lines**. Measure by line count, not phase count — phase density varies ten-fold across projects, so lines are the reliable unit.

**Archival procedure**:

1. Decide the cut point: keep the most recent **3 phases** in `WORKLOG.md`; move earlier phases out.
2. Create `WORKLOG_ARCHIVE_<YYYY-QN>.md` (quarterly granularity, e.g. `WORKLOG_ARCHIVE_2026-Q1.md`). Use the date range of the archived phases to choose the quarter label. Multiple archive files accumulate over time.
3. Move the older phase sections (including their entries in the TOC) to the archive file. The archive file has the same structure as WORKLOG.md (TOC at top + phase sections below).
4. At the top of `WORKLOG.md`, add a pointer line immediately under the title:
   ```
   > Earlier history archived in: WORKLOG_ARCHIVE_2026-Q1.md, WORKLOG_ARCHIVE_2026-Q2.md, ...
   ```
5. Register each archive file in FILE_INDEX under a `## Archived History` category (create if missing).

**Non-goals**: Archival is not deletion. Archive files are permanent records, never edited after creation except for errata. Never delete an archive file.

**When to skip**: Projects with compact phases (e.g. ~20 lines each) may never trigger. That's fine; the threshold catches only projects that need it.

---

## Chapter 6: Information Flow Rules

### 6.1 Daily Workflow

```
Read CLAUDE.md → Read CURRENT_STATUS → Start working
During work:
  ├── Complete meaningful step → update CURRENT_STATUS car body
  ├── Create new file → register FILE_INDEX + record in CURRENT_STATUS car body
  └── Session end → confirm car body reflects all work + update headlights + update date
```

### 6.2 Phase Transition (Five-Step Protocol)

**Trigger conditions** (any one is sufficient):
- Work goal fundamentally changes (e.g., "writing" → "reviewing")
- User explicitly declares a new phase
- Project pauses (>3 days without work)
- Car body exceeds 200 lines

**Does NOT trigger**: Sub-task switches within the same goal (e.g., Ch4→Ch5 within "literature reinforcement")

**Five steps (execute in this order)**:

```
Step 1 (Protective — execute first):
  Copy CURRENT_STATUS car body content in full to WORKLOG top (after TOC).
  Add phase summary.
  → After this step, even if interrupted, no data is lost.

Step 2:
  Insert new summary (3-5 lines) at top of CURRENT_STATUS tire tracks.
  Note "Detailed record in WORKLOG § Phase N".

Step 3:
  If tire tracks exceed 3 → remove the oldest.

Step 4:
  Clear car body. Fill in new phase goal.
  May include one brief context line.
  Update driving manual:
    - Remove principles no longer applicable
    - Check if any should be promoted to CLAUDE.md iron rules
    - Add new principles for the new phase

Step 5:
  Update CLAUDE.md "current phase" and "one-line status (as of date)".
  Update WORKLOG TOC.
```

**Interrupt safety**: Step 1 executes first (copying content to WORKLOG), ensuring that even if compact occurs during Steps 2-5, data is safely preserved. The next agent can find complete content in WORKLOG and finish the remaining steps.

### 6.3 Context Compact Recovery

```
Compact occurs
  → Read CLAUDE.md → understand project and recovery chain
  → Read CURRENT_STATUS.md:
      Tire tracks → "what was recently completed"
      Car body → "what's the current state" (if car body seems incomplete,
                  check WORKLOG's latest entry for a more complete record —
                  may indicate an interrupted phase transition)
      Headlights → "what to do next"
      Driving manual → "what to watch out for"
  → Continue working (if user is present, confirm whether next steps have changed)
```

### 6.4 Project Pause and Resume

**Pausing**:
1. Execute the five-step phase transition (save current work to WORKLOG)
2. Write in CURRENT_STATUS car body: "Project paused on YYYY-MM-DD. Reason: ..."
3. Update CLAUDE.md status to ⏸️

**Resuming**:
1. Agent reads CLAUDE.md → sees ⏸️
2. Reads CURRENT_STATUS → tire tracks have the last phase summary, car body has pause notice
3. Reads WORKLOG latest phase → gets complete pre-pause work details
4. **Critical**: Headlights "next steps" may be stale (circumstances may have changed during pause) — confirm with user before executing

---

## Chapter 7: Single Source of Truth

### 7.1 Core Rule

**Each fact is maintained in only one document.**

| Fact Type | Sole Source |
|-----------|------------|
| Current state/progress/numbers | CURRENT_STATUS.md |
| File catalog/locations | FILE_INDEX.md |
| Historical work details | WORKLOG.md |
| Project overview/entry/iron rules | CLAUDE.md |

### 7.2 Only Allowed Redundancy

CLAUDE.md's "one-line status (as of date)". Must include a date stamp; if contradicted, CURRENT_STATUS is authoritative.

---

## Chapter 8: Two-Level Principle Management

### 8.1 Two Types of Principles

| Type | Location | Lifecycle | Example |
|------|----------|-----------|---------|
| **Project-level iron rules** | CLAUDE.md "Iron Rules" section | Lives with project | "Never read paper .md files directly" |
| **Phase-level principles** | CURRENT_STATUS "Driving Manual" | Lives and dies with phase | "Compile LaTeX after every edit this phase" |

### 8.2 Promotion and Demotion

- At phase transition, check if any driving manual principles **should be promoted to iron rules**
- If a principle appears in 3 consecutive phases, it likely should be promoted
- Promotion: move from driving manual to CLAUDE.md iron rules section
- Demotion is rare — once established, iron rules generally persist

### 8.3 Iron Rule Management

Iron rules live in CLAUDE.md and persist for the project's lifetime. New iron rules may be added at phase transitions (promoted from driving manual). Iron rules are generally not deleted — if preconditions no longer apply, annotate "[No longer applicable: reason]" but keep the original text for historical reference.

---

## Chapter 9: Document Lifecycle

### 9.1 Core Status Documents
The four core documents live as long as the project.

### 9.2 Leaf Documents

| State | Meaning | Marking |
|-------|---------|---------|
| Active | In use or still valid | Default (no marking needed) |
| SUPERSEDED (retained) | Replaced, but still has reference value | First line: `⚠️ SUPERSEDED BY [new document]`. Move to `## Superseded` category in FILE_INDEX. |
| SUPERSEDED (archived) | Replaced and no longer needed | First line: `⚠️ SUPERSEDED BY [new document]`. Move to _archive/. Remove from FILE_INDEX. |
| ARCHIVED | Historical, moved to _archive/ | Remove from FILE_INDEX |

Most superseded documents in practice are **retained** because they contain valuable reference information (e.g., original README with style guides, old STATUS with detailed session logs). Use the "retained" option unless the document truly has no remaining value.

---

## Chapter 10: Sub-projects and Project Groups

### 10.1 Sub-projects
Sub-projects have their own complete four-document system; all rules apply recursively. The parent project's FILE_INDEX registers the sub-project entry point.

### 10.2 Project Groups
When multiple independent projects share a parent directory, the parent may have a lightweight CLAUDE.md (navigation table only — no CURRENT_STATUS/FILE_INDEX/WORKLOG).

```markdown
# [Workspace] — Project Navigation

## Active Projects
| Project | Entry | Status |
|---------|-------|--------|
| Project A | [CLAUDE.md](A/CLAUDE.md) | ⏳ |
| Project B | [CLAUDE.md](B/CLAUDE.md) | ⏸️ |

## Shared Infrastructure
| Tool | Path | Description |
|------|------|-------------|

## Archived Projects
| Project | Path | Completion Date |
|---------|------|----------------|
```

When an agent arrives at a project group, the user's instructions typically determine which sub-project to enter.

---

## Chapter 10.3: Adapting to Existing Projects

**Core principle: Doc Harness adapts to the project, not the other way around.**

### Mid-Project Adoption

Most real-world adoption happens mid-project — the project already has files, possibly existing status documents, and a history of work. The process:

1. **Understand the project first.** Read all existing status/readme documents thoroughly before creating Doc Harness files. Understand the project's goals, current state, directory structure, and what documentation already exists.

2. **Create the four core documents.** CLAUDE.md, CURRENT_STATUS.md, FILE_INDEX.md, WORKLOG.md — populated with the project's actual current state, not blank templates.

3. **Handle existing status documents.** Most should be marked SUPERSEDED but retained:
   - Add `⚠️ SUPERSEDED BY [new doc]` at the first line
   - Move to the `## Superseded` category in FILE_INDEX
   - Note why it's retained (e.g., "contains detailed session logs" or "has style guide reference")

4. **Reconstruct WORKLOG from history.** Use existing logs, status docs, and git history to build phase records. Mark reconstructed sections: "(Reconstructed from [source document])". The goal is useful history, not perfect accuracy — real-time records will always be more detailed.

5. **Preserve existing high-quality indexes.** If a sub-directory already has a well-maintained index (e.g., a research analysis INDEX.md with 100+ entries and status labels), FILE_INDEX.md should **point to it** rather than rebuild it. Add a line like: `→ See [subdir/INDEX.md] (N entries, covers [scope])`.

### Sub-Index Guidelines for Large Directories

For directories with more than 20 files, create a sub-FILE_INDEX.md. For initial creation of large sub-indexes (100+ files), automated file-system scanning can generate the initial structure, which should then be manually verified and annotated where possible.

---

## Chapter 11: Agent Behavior Guidelines

### 11.1 Session Start — Applying Recovery Chain

Follow the project's Recovery Chain (defined in CLAUDE.md §Recovery Chain):

1. Read the **must-read** layer in order (CLAUDE.md → CURRENT_STATUS.md, typically 2–3 files).
2. Scan the **task-conditional** layer. Read only the entries whose condition matches the current work.
3. If user is present → confirm whether next steps have changed.
4. If compact recovery (user not present) → continue per headlights.

Do not unconditionally read all task-conditional entries at startup. That defeats the purpose of the two-layer split. If you find yourself reading a file every session, it probably belongs in must-read — promote it explicitly.

### 11.2 During Work

1. Complete a **meaningful step** → update CURRENT_STATUS car body
2. Create a new file → **do two things simultaneously**: (1) register in FILE_INDEX (2) record in CURRENT_STATUS car body
3. **"Write It Down"**: important analysis results, design ideas, decision rationale → save to file + register
4. **Watch remaining context** (if exposed by the runtime): context compression is involuntary session end. If your environment reports a context-usage percentage or token count, treat **low remaining context** (~<20%) as an immediate trigger — update CURRENT_STATUS before the next tool call; if the car body has substantial unsaved work, consider a phase transition now. Don't wait for a "meaningful step" that may never land.

### 11.3 Session End

1. Ensure CURRENT_STATUS car body reflects all work from this session
2. Update headlights "next steps"
3. Update CURRENT_STATUS "last updated" date
4. Update CLAUDE.md "one-line status (as of date)"
5. Check: are all files created this session registered in FILE_INDEX?
6. Check: is there any important information only in context? → Write it down!
7. If a phase transition occurred: check WORKLOG length — over ~1000 lines? → trigger archival per §5.5.

### 11.4 Phase Transition

Execute the five-step protocol defined in Chapter 6 §6.2.

---

## Chapter 12: Anti-patterns

| Anti-pattern | Correct Approach |
|-------------|-----------------|
| Same number hardcoded in multiple documents | Maintain only in CURRENT_STATUS; others reference it |
| Superseded document not marked | Add SUPERSEDED notice at first line |
| Multiple recovery chains | Recovery chain defined only in CLAUDE.md |
| Recovery Chain references agent-side features (memory / chat history / external services) | Recovery Chain must be self-contained — only project-internal files |
| Recovery Chain must-read layer grows past 3 entries | Demote extras to task-conditional; must-read stays lean |
| File created but not registered | Register in FILE_INDEX immediately on creation |
| CURRENT_STATUS grows indefinitely | Transfer details to WORKLOG at phase transitions |
| WORKLOG grows past ~1000 lines untouched | Archive per §5.5 |
| Information exists only in context | "Write It Down" — save to file and register |
| Phase principles become permanent legacy | Review at phase transition: promote to iron rule or remove |
| WORKLOG has no table of contents | Maintain TOC table at top |

---

## Chapter 13: Optional Long-Horizon Documents

The four core documents (CLAUDE / CURRENT_STATUS / FILE_INDEX / WORKLOG) are tuned for short-to-medium-horizon work flow: what's the current phase, what got done, where are the files, what's the history. Two categories of information don't fit well in any of them. Doc Harness offers two **optional** documents for these, used only when a project genuinely accumulates such content.

These documents are opt-in. A project that doesn't need them should not create them.

### 13.1 PARKING_LOT.md — Deferred Items

**Purpose**: Concrete things you'd like to do but can't right now. Without a parking lot, such items either clutter CURRENT_STATUS headlights (wrong — they're not next) or get overwritten by new work and forgotten.

**When to create**: When a specific item is being removed from active consideration but shouldn't be lost. Typical trigger: during phase transition, some driving manual principle or next-step item is no longer for *now* but will be relevant again under known conditions.

**Entry format**: Each entry records **what** to do, **why it's deferred**, **preconditions for revival**, and **when to re-check**.

```markdown
## Entries

### [Item title] — deferred YYYY-MM-DD
- **What**: [concrete action or goal]
- **Why deferred**: [reason — e.g., "depends on X which won't ship until Q3"]
- **Preconditions for revival**: [what must be true before this can resume]
- **Re-check**: [date or event — e.g., "check at next phase transition" or "2026-09-01"]
```

**Lifecycle**: When preconditions become true, either (a) move the item to CURRENT_STATUS headlights, striking from PARKING_LOT; or (b) keep the entry and annotate with a decision — e.g., "[Revived 2026-09-15 → now active]" or "[No longer relevant 2026-09-15 because X]". Never silently delete.

**Recovery Chain integration**: Add to the task-conditional layer, e.g. `- If planning a new phase: read PARKING_LOT.md (any deferred items revivable?)`.

### 13.2 PHILOSOPHY.md — Principles From Practice

**Purpose**: Record principles, lessons, and generalizable insights that emerge from the project's specific practice. These are broader than iron rules (which govern *this* project's operations) and more durable than the driving manual (which governs *this phase*).

**Design rationale**: General wisdom is born from specific practice. The project is the forge; the principle is what comes out. Forbidding projects from recording their own philosophy severs the principle from its origin. PHILOSOPHY.md is that capture layer.

**When to create**: When working on the project surfaces an insight you suspect generalizes beyond the immediate situation — a reusable lesson, a design trade-off worth remembering, a mistake pattern you don't want to repeat.

**Entry format**: Each entry states the principle, the practice that forged it, and the first-recorded date.

```markdown
## Principles

### [Short principle name] — first recorded YYYY-MM-DD
**Principle**: [one-sentence statement of the principle]

**Forged by**: [the specific practice / incident / observation that produced this — be concrete about *what happened* that led to this lesson]

**Scope**: [where this applies — this project only? likely broader? already confirmed broader?]
```

**Sharing across projects (optional)**: When a principle turns out to apply beyond this project, it may be copied into a sibling project's own `PHILOSOPHY.md`, or (if a parent navigation CLAUDE.md exists over a project group — see Chapter 10) referenced there. Copying/referencing **does not remove** the entry from this project's `PHILOSOPHY.md` — each project that adopted the principle keeps its own birthplace record, and this file documents how *this* project arrived at it. Annotate shared entries with `[Also adopted by <project> YYYY-MM-DD]` for traceability.

**Lifecycle**: Principles may be refined with errata (`[Refined YYYY-MM-DD: ...]`) or marked superseded (`[Superseded YYYY-MM-DD by: new formulation]`), but entries are not deleted. A PHILOSOPHY.md is read rarely but should survive intact.

**Recovery Chain integration**: Add to task-conditional layer for reflective decisions, e.g. `- If making a major architectural decision: read PHILOSOPHY.md`.

---

## Chapter 14: Optional Inter-Project Communication (inbox/outbox)

When a project operates alongside other projects that depend on it or that it depends on, cross-project information (requirements, deliverables, status changes, confirmations) must persist across session boundaries. Verbal/chat-only exchange is lost when a session ends; the recipient project's next agent has no way to discover it. Doc Harness offers an **optional** file-based protocol for this.

This entire chapter is **self-contained** — a project that adopts it needs no documentation beyond this chapter and its own `DOC_HARNESS_SPEC.md`. No external protocol file required, no dependency on any parent folder or sibling project. A project that does NOT adopt it is unaffected.

### 14.1 When to adopt

Adopt if any of the following is true:
- This project has a dependency on another project (e.g., consumes data, an API, or deliverables from it).
- Another project depends on this one.
- Cross-project coordination happens repeatedly (decisions, requirements, numbers exchanged more than once).

Skip if the project is truly standalone.

### 14.2 Folder structure

Two directories at the project root:

```
project_root/
├── inbox/        ← messages addressed TO this project
├── outbox/       ← messages sent FROM this project (drafts / sent-copies)
└── ... (rest of project)
```

Both start empty. Git-track them by adding a `.gitkeep` (or equivalent) if your VCS requires it.

### 14.3 Message format

**Filename**: `YYYY-MM-DD-from-<source-project>-<topic-slug>.md`

- `<source-project>`: short identifier of the sender (e.g. `whoami`, `smss`).
- `<topic-slug>`: kebab-case summary of the topic.
- Example: `2026-04-19-from-whoami-skill-improvement-proposals.md`.

**Header** (YAML frontmatter, required):

```yaml
---
from: <source project name>
to: <target project name>
date: YYYY-MM-DD
subject: <one-line subject>
status: unread | read | actioned
in-reply-to: <original filename, if this message is a reply; else null>
priority: low | normal | high
---
```

**Body**: free-form Markdown. Tables, checklists, code blocks permitted.

### 14.4 Message lifecycle and rules

```
Sender                                        Recipient
  │                                              │
  ├─ writes new message to own outbox/           │
  ├─ copies the same file into recipient inbox/  │
  │  (status: unread, set by sender)             │
  │                                              │
  │   ─── session boundary ───                   │
  │                                              │
  │                      recipient's Recovery ──┤
  │                      Chain points to inbox/ ─┤
  │                      recipient reads msg    ─┤
  │                      → status: read         ─┤
  │                      performs any action    ─┤
  │                      → status: actioned     ─┤
  │                      (if reply needed:      ─┤
  │                       sends a NEW message)  ─┤
```

**Rules**:

1. **Received messages are immutable** — never edit a file in your `inbox/` beyond updating the `status` field. To respond, write a new message.
2. **Status transitions** — sender sets `unread` at delivery. Recipient changes to `read` after reading, then to `actioned` after completing any required action. An `actioned` message with no required action is equivalent to acknowledged-and-closed.
3. **Archival** — messages older than 30 days with `status: actioned` may be moved to `inbox/_archive/` to keep the active inbox scannable. Archived messages are permanent records; do not delete.
4. **Sender retains a copy** — the sender's `outbox/` is the permanent draft/record. If the recipient loses their copy, the sender's `outbox/` is authoritative for what was sent.
5. **Cross-project reference snapshots** — when communicating numbers, deliverables, or state ("our model reached accuracy 0.88"), send a **snapshot** in an inbox message rather than pointing the recipient at your internal files. Internal files churn and refactors break external references. A snapshot, once delivered, does not lie.

### 14.5 Integration with the four core documents

**CLAUDE.md** — add one iron rule block (copy-paste template, no customization required):

```markdown
**Inter-project communication via inbox/outbox (file-based protocol)**

- **Mechanism**: This project maintains `inbox/` (received messages) and `outbox/` (sent messages). Messages are Markdown files with YAML frontmatter; filename `YYYY-MM-DD-from-<source>-<topic>.md`.
- **Why this is mandatory (if adopted)**: Cross-project information exchanged only in chat is lost on session end. File-based messages survive session boundaries and are discoverable by any future agent through this project's Recovery Chain.
- **Receiving**: Recovery Chain checks `inbox/` for `status: unread`. Read → update to `status: read`. After acting on the message → `status: actioned`. Never edit received messages beyond the status field; to respond, write a new message.
- **Sending**: Write to this project's `outbox/` (permanent sender-side record) AND copy the same file into the recipient project's `inbox/`. Record the exchange in CURRENT_STATUS so it is traceable next session.
- **Snapshots over pointers**: When communicating numbers/deliverables to another project, put the value in the message body rather than referencing internal files.
- **Full specification**: `DOC_HARNESS_SPEC.md` §14 (in this project's root).
```

**CURRENT_STATUS.md** — when an incoming message requires action, add it to Headlights:

```markdown
### Immediate Actions
- [ ] Respond to <sender>'s <topic> (see `inbox/YYYY-MM-DD-from-<source>-<topic>.md`)
```

Also record outbound exchanges in the car body as they happen:

```markdown
#### Sent deliverable to <target> (YYYY-MM-DD)
- Message: `outbox/YYYY-MM-DD-to-<target>-<topic>.md`
- Summary: <one line>
```

**FILE_INDEX.md** — register both directories under their own category:

```markdown
## Inter-Project Communication
- `inbox/` — Incoming messages from other projects
- `outbox/` — Outgoing messages (drafts and sent-copies)
```

**Recovery Chain (CLAUDE.md)** — add one task-conditional entry:

```markdown
### Task-conditional
- If `inbox/` has any file with `status: unread`: read and action those first
- ...
```

Note: this entry sits in **task-conditional**, not must-read. Reading the entire inbox at every session start would burn context; only unread messages matter. If inbox is empty or all messages are `read`/`actioned`, this entry is a no-op.

### 14.6 Quick Start for a fresh agent

If you arrive at a project and see `inbox/` and `outbox/` in the root, the project uses this protocol. Do this:

1. Scan `inbox/` for any file whose frontmatter has `status: unread`.
2. For each: read it, take the required action if any, update its `status` field (`read` after reading, `actioned` after completing).
3. Before modifying project internal files that other projects might reference (models, interfaces, numbers), consider whether a snapshot needs to be sent to dependents via their inbox.
4. To send: write to your project's `outbox/` AND copy the same file to the recipient's `inbox/`. Record the exchange in CURRENT_STATUS.

Everything you need is in this chapter. No external file required.

### 14.7 Adopting on an existing project

To retrofit an existing project:
1. Create `inbox/` and `outbox/` at project root.
2. Copy the iron rule block from §14.5 into CLAUDE.md's Iron Rules section.
3. Add the task-conditional entry to Recovery Chain (also §14.5).
4. Add the `## Inter-Project Communication` category to FILE_INDEX.
5. (Optional) Send a notification message to dependent projects that this project is now reachable via inbox.

---

## Appendix A: Phase Boundary Decision Guide

| Signal | Transition? |
|--------|------------|
| Work goal fundamentally changes ("writing" → "reviewing") | ✅ Yes |
| User explicitly says "start something else" | ✅ Yes |
| Project pause >3 days | ✅ Yes (pause = phase end) |
| Car body exceeds 200 lines | ✅ Consider (signal, not hard rule) |
| Sub-task switch within same goal (Ch4→Ch5, both "literature reinforcement") | ❌ No — use sub-headings in car body |
| Temporary small task (fix a typo, then return) | ❌ No |
| Uncertain | ❌ Don't transition (avoid over-maintenance); use clear headings in car body |

---

## Appendix B: Quick Checklist

Run through at session end:

- [ ] CURRENT_STATUS "last updated" is today?
- [ ] All new files registered in FILE_INDEX?
- [ ] All work steps recorded in car body?
- [ ] Headlights "next steps" accurate?
- [ ] Any important information only in context? (Write it down!)
- [ ] If a phase transition happened: WORKLOG under ~1000 lines? (If over, trigger §5.5 archival.)

---

## Appendix C: Glossary

| Term | Definition |
|------|-----------|
| **Project** | Basic unit of the Doc Harness system. A work stream with independent goals and outputs. |
| **Phase** | A period within a project with a clear goal. Transition triggers information flow operations. |
| **Leaf document** | Any file that is not one of the four core status documents. |
| **Car body / Tire tracks / Headlights / Driving manual** | Metaphors for the four sections of CURRENT_STATUS. |
| **Register** | Add a file to the appropriate category in FILE_INDEX. |
| **Write It Down** | First principle: important information must be saved to file and registered. |
| **SUPERSEDED** | Document has been replaced; marked at first line. |
| **Iron rule** | Project-level permanent rule defined in CLAUDE.md. |

---

## Appendix D: Worked Example — Four Documents Through Two Phase Transitions

Using a hypothetical research paper project to show how all four documents evolve from project start through Phase 3.

### Project Start (Phase 1 begins)

**CLAUDE.md**:
```
# Market Microstructure Paper — Entry Document
Last updated: 2026-03-01
Current phase: Model Building (⏳)
One-line status (as of 2026-03-01): Project just started, building base model

## Recovery Chain
1. Read this file  2. Read CURRENT_STATUS.md  3. As needed: FILE_INDEX/WORKLOG

## Project Overview
Studying stock market microstructure using computational equilibrium methods. Goal: produce a submittable working paper.

## Iron Rules
- Simulation data must not be stated as "real market conclusions"
- Python commands must include PYTHONIOENCODING=utf-8
```

**CURRENT_STATUS.md**:
```
# CURRENT_STATUS — Market Microstructure Paper
Last updated: 2026-03-01
Current phase: Model Building

## Recent Completed (Tire Tracks)
(Project just started, no completed phases yet)

## Current Work (Car Body)
### Phase Goal
Build LOB matching engine and trader behavior modules

### Completed Steps
(None yet)

## Next Steps (Headlights)
### Immediate Actions
1. Design order book data structure
2. Implement price-time priority matching logic

## Current Working Principles (Driving Manual)
- Write test cases before implementation
- Each module independently testable
```

**FILE_INDEX.md**:
```
# FILE_INDEX — Market Microstructure Paper
Last updated: 2026-03-01

## Core Documents
- CLAUDE.md — Entry
- CURRENT_STATUS.md — Active status
- FILE_INDEX.md — This file
- WORKLOG.md — Work history

## Code
(None yet)

## Documents
(None yet)
```

**WORKLOG.md**:
```
# WORKLOG — Market Microstructure Paper

## TOC
| Phase | Time | Anchor |
|-------|------|--------|
| (No phases completed yet) | | |
```

---

### Phase 1 Ends → Phase 2 Begins (Phase Transition)

Phase 1 (Model Building) lasted two weeks. Matching engine and trader modules completed; several files created.

**After the five-step transition:**

**WORKLOG.md** (Step 1: car body content copied):
```
# WORKLOG — Market Microstructure Paper

## TOC
| Phase | Time | Anchor |
|-------|------|--------|
| Phase 1: Model Building | 2026-03-01~03-14 | [→](#phase-1-model-building) |

---

## Phase 1: Model Building (2026-03-01 ~ 2026-03-14)

### Phase Summary
Completed LOB matching engine (C, 3000 orders/sec) and trader behavior module (Python).
Passed basic validation: hump-shaped order book, log-normal spread distribution. Discovered endogenous price crash phenomenon.

### Detailed Record
[Copied verbatim from CURRENT_STATUS car body]

#### Designed order book data structure (2026-03-01)
- Doubly-linked list for price levels, red-black tree index
- Created src/orderbook.c — core data structure
- Created tests/test_orderbook.py — unit tests

#### Implemented matching logic (2026-03-03)
- Price-time priority, supports limit and market orders
- Created src/matching_engine.c
- Performance: 3000 orders/sec (single-threaded)

#### Trader behavior module (2026-03-07)
- Two-stage decision: willingness formation → order execution
- Created src/trader.py
- Created notes/design_two_stage.md — two-stage design document

#### Basic validation (2026-03-12)
- Hump-shaped order book ✅
- Log-normal spread distribution ✅
- Unexpected discovery: endogenous price crash phenomenon
- Created notes/crash_discovery.md — crash analysis
```

**CURRENT_STATUS.md** (Steps 2-4: car body compressed to tire track, car body cleared):
```
# CURRENT_STATUS — Market Microstructure Paper
Last updated: 2026-03-14
Current phase: Equilibrium Simulation

## Recent Completed (Tire Tracks)

### Phase 1: Model Building (2026-03-01 ~ 2026-03-14)
Completed LOB matching engine and trader behavior module. C implementation, 3000 orders/sec.
Passed basic validation (hump-shaped order book, log-normal spread). Discovered endogenous price crash.
Detailed record in WORKLOG.md § Phase 1.

## Current Work (Car Body)
### Phase Goal
Run equilibrium simulations: short-term / long-term / mixed models

### Completed Steps
(None yet — phase just started)

## Next Steps (Headlights)
### Immediate Actions
1. Configure BM_S model parameters (τ_min=720)
2. Run Learn phase to find equilibrium beliefs

## Current Working Principles (Driving Manual)
- Back up parameter config before each model run
- Equilibrium convergence: 3 consecutive rounds with belief change <0.1%
```

**CLAUDE.md** (Step 5: update phase and one-line status):
```
Current phase: Equilibrium Simulation (⏳)
One-line status (as of 2026-03-14): Model building complete, starting three equilibrium simulations
```

**FILE_INDEX.md** (files from Phase 1 registered):
```
## Code
- src/orderbook.c — LOB core data structure (C)
- src/matching_engine.c — Matching engine
- src/trader.py — Trader behavior module
- tests/test_orderbook.py — Order book unit tests

## Design & Analysis Documents
- notes/design_two_stage.md — Two-stage trading decision design
- notes/crash_discovery.md — Endogenous price crash analysis
```

---

### Phase 2 Ends → Phase 3 Begins

Phase 2 (Equilibrium Simulation) complete. Tire tracks now have two summaries.

**CURRENT_STATUS.md**:
```
## Recent Completed (Tire Tracks)

### Phase 2: Equilibrium Simulation (2026-03-14 ~ 2026-03-28)
Completed BM_S/BM_L/BM_SL equilibrium simulations. Mixed model produced leverage effect (1.88 ≈ DAX 2.0).
Belief data saved in data/. 10 of 12 stylized facts covered.
Detailed record in WORKLOG.md § Phase 2.

### Phase 1: Model Building (2026-03-01 ~ 2026-03-14)
Completed LOB matching engine and trader behavior module. Discovered endogenous price crash.
Detailed record in WORKLOG.md § Phase 1.

## Current Work (Car Body)
### Phase Goal
Write paper first draft (Ch1-Ch8)

### Completed Steps
(None yet — phase just started)

## Next Steps (Headlights)
### Immediate Actions
1. Determine paper structure (8 chapters)
2. Write Ch3 model chapter first (most familiar)
```

**WORKLOG.md TOC** (two phases):
```
## TOC
| Phase | Time | Anchor |
|-------|------|--------|
| Phase 2: Equilibrium Simulation | 2026-03-14~03-28 | [→](#phase-2-equilibrium-simulation) |
| Phase 1: Model Building | 2026-03-01~03-14 | [→](#phase-1-model-building) |
```

---

### A Brand New Agent Arrives

Agent opens CLAUDE.md:
1. Sees "Market Microstructure Paper", project overview, iron rules
2. Recovery chain → reads CURRENT_STATUS.md
3. From tire tracks: model building and equilibrium simulation completed; mixed model found leverage effect 1.88
4. From car body: writing paper first draft, phase just started
5. From headlights: next step is to determine structure and write Ch3
6. From driving manual: current phase principles
7. Need to find specific files → FILE_INDEX
8. Need model building details → WORKLOG § Phase 1

**The agent needs no external memory to fully recover project state.**

---

## Appendix E: Design Choices (FAQ)

### Why is inter-project inbox/outbox an optional mechanism, not a required one?

Because many projects are standalone and have no dependents. Mandating inbox/outbox on every project would impose empty directories and an unused iron rule, eroding trust in the skill. The mechanism is offered as a standard optional feature with a complete self-contained spec (Chapter 14) so projects that need it can adopt it consistently and projects that don't need it ignore it.

### Why is the mechanism described inside doc-harness instead of as a separate spec?

Because an external spec is **brittle**. An agent working inside a project has no reliable entry point to an external file; over long project lifetimes the external reference tends to be lost, misinterpreted, or forgotten. By embedding the full mechanism into doc-harness's spec, every project that deploys `DOC_HARNESS_SPEC.md` carries a self-contained description — the project becomes its own authoritative source for how the protocol works.

### Why are PARKING_LOT.md and PHILOSOPHY.md optional, not mandatory?

Not every project has deferred items or emergent cross-project principles worth recording. Mandating these files would produce empty shells that erode trust in the four-document system. Offer them as patterns; let each project adopt when there's content to put there.

### Why keep must-read layer at 2–3 files?

Any larger, and "must-read" becomes "should probably read," and agents start skipping entries or reading the whole project defensively. The two-layer split only works if the baseline is genuinely minimal. Entries that only apply to *some* work belong in task-conditional.

### Why use line count (not phase count) as WORKLOG archival trigger?

Phase density varies enormously across projects — from ~20 lines per phase (infrastructure work, terse records) to ~200 lines per phase (dense research work). Line count reflects the actual cost of reading the file, which is what we care about.

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| v0.1 | 2026-04-01 | Initial draft |
| v0.2 | 2026-04-02 | Incorporated feedback from three independent reviews |
| v1.0 | 2026-04-02 | Production release. CLAUDE.md template embeds operational rules; 8 ambiguities resolved (session-end status refresh, new project initial state, WORKLOG TOC format, cross-phase context, driving manual lifecycle, FILE_INDEX cross-category, iron rule management §8.3, session-end checklist additions) |
| v1.1 | 2026-04-03 | Mid-project adoption guidance (§10.3); SUPERSEDED-but-retained document lifecycle (§9.2); improved `/doc-harness check` (spec presence, FILE_INDEX script, phase coherence); sub-index guidelines for large directories |
| v1.2 | 2026-04-19 | Recovery Chain two-layer structure (must-read + task-conditional) with self-contained constraint; WORKLOG archival rule (§5.5, ~1000-line threshold, quarterly archive files); new optional documents PARKING_LOT.md and PHILOSOPHY.md (Chapter 13); anti-pattern additions; Appendix E Design Choices |
| v1.3 | 2026-04-19 | New Chapter 14: Optional Inter-Project Communication (inbox/outbox) — self-contained, portable mechanism for file-based cross-project messaging. Spec covers folder structure, message format (YAML frontmatter + Markdown body), lifecycle (unread→read→actioned), integration with all four core documents, quick start for fresh agents, and adopt-on-existing-project procedure. init gains one y/n prompt to enable. Appendix E updated to explain why the mechanism is optional and why it lives inside doc-harness rather than as an external spec. "Portfolio" framing removed throughout — project groups are flat peers. §11.2 gains a context-aware update rule: if the runtime exposes context-window usage, low remaining context (~<20%) is an immediate trigger to flush CURRENT_STATUS and possibly phase-transition. |
