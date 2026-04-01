# Doc Harness — Init

Create the five Doc Harness files for a new project.

## Step 1: Gather Information

You need these details. Gather from three sources in priority order:

**Source A — Arguments**: Extract project name and description from `$ARGUMENTS`.
**Source B — Context**: If the project was just discussed in conversation, extract goals, first tasks, constraints, technical details.
**Source C — Ask the user**: For anything still unknown, ask explicitly. Do NOT guess. Reasonable inference from context is OK; fabrication is not.

**Required** (must have before creating):
- Project name (short, for document titles)
- Project description (1-3 sentences)
- First phase name (what is the initial work called)
- First concrete task (what to do first — for "headlights")

**Optional** (ask if unclear, OK to leave blank):
- Initial iron rules
- Key technical details (tools, languages, paths)
- Known sub-projects

## Step 2: Check Existing Files

Check if CLAUDE.md or other Doc Harness files exist. If yes, warn user before overwriting.

## Step 3: Create 5 Files

### File 1: CLAUDE.md

```markdown
# [PROJECT_NAME] — Entry Document

**Last updated**: [TODAY]
**Current phase**: [PHASE_NAME] (⏳)
**One-line status (as of [TODAY])**: [DESCRIPTION] — project just initialized

---

## Recovery Chain

1. Read this file → project scope, iron rules, operational rules
2. Read `CURRENT_STATUS.md` → current work, recent history, next steps
3. As needed: `FILE_INDEX.md` → find files
4. As needed: `WORKLOG.md` → find historical details

## Project Overview

[DESCRIPTION expanded to 3-5 lines]

## Project-Level Iron Rules

[USER_PROVIDED_RULES or defaults:]
- "Write it down or lose it" — important info must be saved to files and registered
- [project-specific rules]

## Key Technical Information

[From context, or: "To be filled as project progresses"]

## Sub-projects

[If any, or remove section]

---

## Doc Harness — Operational Rules

[INSERT FULL CONTENT OF operational_rules.md HERE]
```

**Important**: Read [operational_rules.md](operational_rules.md) and embed its FULL content into the CLAUDE.md at the location marked above.

### File 2: CURRENT_STATUS.md

```markdown
# CURRENT_STATUS — [PROJECT_NAME]

**Last updated**: [TODAY]
**Current phase**: [PHASE_NAME]

---

## Recent Completed (Tire Tracks)

(Project just started, no completed phases yet)

---

## Current Work (Car Body)

### Phase Goal
[What this initial phase aims to accomplish]

### Completed Steps
(No steps completed yet)

---

## Next Steps (Headlights)

### Immediate Actions
1. [First concrete task from gathered info]

### Future Plans
- [Broader goals from context]

---

## Current Working Principles (Driving Manual)

- Follow the Doc Harness operational rules (see CLAUDE.md)
- [Phase-specific principles from context]
```

### File 3: FILE_INDEX.md

```markdown
# FILE_INDEX — [PROJECT_NAME]

**Last updated**: [TODAY]

---

## Core Documents
- `CLAUDE.md` — Project entry point
- `CURRENT_STATUS.md` — Active status
- `FILE_INDEX.md` — This file
- `WORKLOG.md` — Work history
- `DOC_HARNESS_SPEC.md` — Doc Harness specification (reference)
```

### File 4: WORKLOG.md

```markdown
# WORKLOG — [PROJECT_NAME]

## TOC
| Phase | Time | Anchor |
|-------|------|--------|
| (No phases completed yet) | | |
```

### File 5: DOC_HARNESS_SPEC.md

Read [spec.md](spec.md) and write its content to the project directory as `DOC_HARNESS_SPEC.md`.

If spec.md is not accessible, note in FILE_INDEX: "DOC_HARNESS_SPEC.md — not yet deployed (operational rules in CLAUDE.md are sufficient for daily use)".

## Step 4: Verify

- All 5 files exist
- FILE_INDEX lists all 5
- CURRENT_STATUS has all 4 sections
- CLAUDE.md contains embedded operational rules
- WORKLOG has empty TOC

Report: "Doc Harness initialized for [PROJECT_NAME]. 5 files created."
