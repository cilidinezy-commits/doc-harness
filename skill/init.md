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
- **Inter-project inbox/outbox**: one y/n question — "Does this project coordinate with other projects (has dependencies in either direction)? If yes, I'll enable the inter-project inbox/outbox protocol (Chapter 14 of the spec)." Default: **yes** if the user mentioned dependencies or sibling projects in context; **no** for standalone projects. If enabled, see Step 3.6 below.

## Step 2: Check Existing Files and Project State

Check the target directory for three situations:

**(a) Clean directory** (no files, or only trivial starter files like a blank README/LICENSE) → proceed to Step 3 with blank templates.

**(b) Doc Harness already present** (CLAUDE.md + CURRENT_STATUS.md + ... already exist) → do NOT overwrite. Warn the user and suggest `/doc-harness check` instead. If only *some* of the 5 files exist (partial or broken state), offer to complete the missing ones (mid-project adoption mode, see (c)) rather than wiping the partial state.

**(c) Non-empty directory without Doc Harness** (has code, notes, existing README, accumulated files) → this is **mid-project adoption**. Do NOT treat as a clean init. Before writing any template:
- Read `spec.md` §10.3 ("Adapting to Existing Projects") for the full procedure.
- In short: scan existing files to reconstruct project history; propose (not impose) a draft WORKLOG reflecting past phases; ask the user to confirm/correct before writing; register existing files in FILE_INDEX in bulk per §4.4 if there are many (>~20 files); mark any superseded documents per §9.2.
- The goal is to **describe reality faithfully**, not to pretend the project just started.

**(d) Non-empty directory, user explicitly requests a clean start** (e.g., "ignore the existing files, I'm starting fresh on a new task"): this is the escape hatch from (c). Confirm explicitly with the user — "Existing files will NOT be reconstructed into WORKLOG; they remain on disk but are not represented in the documentation system. Do you want to proceed with clean init?" — and if the user confirms, proceed as (a). Record the user's override decision in WORKLOG's first phase summary so future agents understand why no prior history was reconstructed.

## Step 3: Create 5 Files

### File 1: CLAUDE.md

```markdown
# [PROJECT_NAME] — Entry Document

**Last updated**: [TODAY]
**Current phase**: [PHASE_NAME] (⏳)
**One-line status (as of [TODAY])**: [DESCRIPTION] — project just initialized

---

## Recovery Chain

Recovery Chain is the entry ritual for any agent or human resuming work on this project.
It has two layers.

### Must-read (baseline)

1. This file (CLAUDE.md)
2. `CURRENT_STATUS.md`

### Task-conditional

- If looking up a specific file: read `FILE_INDEX.md`
- If investigating historical phase details: read `WORKLOG.md`
- [Add project-specific entries as work categories emerge]

### Meta-rules

- Recovery Chain is **self-contained**: every entry points to a file inside the project
  (or a stable sibling-project path). No dependency on agent-side features (memory,
  chat history, external services).
- Recovery Chain is **living**: review and update at phase transitions.

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

**Important**: Read [operational_rules.md](operational_rules.md) and embed its FULL content (from the `<!-- doc-harness-ops-start -->` comment through the `<!-- doc-harness-ops-end -->` comment, inclusive) into the CLAUDE.md at the location marked above. Preserve **both sentinels and the `<!-- doc-harness-ops-version: N.N -->` version tag** — these delimit the region that future re-embeds (after a skill upgrade) and `/doc-harness check` §1.10 can safely locate and replace. **Re-embed semantics**: a future `init` pass or manual re-embed replaces ONLY the bytes between `<!-- doc-harness-ops-start -->` and `<!-- doc-harness-ops-end -->`. Any custom iron rules, project-specific sections, or other content outside the delimited region is preserved untouched.

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

### Step 3.6: (Optional) Enable inter-project inbox/outbox

If the user opted in (see Step 1), do the following:

**(a) Create folders**: `inbox/` and `outbox/` at project root (both empty; git-track with `.gitkeep` if needed).

**(b) Add the iron rule block** to CLAUDE.md inside the Iron Rules section (copy-paste, no customization needed):

```markdown
**Inter-project communication via inbox/outbox (file-based protocol)**

- **Mechanism**: This project maintains `inbox/` (received messages) and `outbox/` (sent messages). Messages are Markdown files with YAML frontmatter; filename `YYYY-MM-DD-from-<source>-<topic>.md`.
- **Why this is mandatory (if adopted)**: Cross-project information exchanged only in chat is lost on session end. File-based messages survive session boundaries and are discoverable by any future agent through this project's Recovery Chain.
- **Receiving**: Recovery Chain checks `inbox/` for `status: unread`. Read → update to `status: read`. After acting on the message → `status: actioned`. Never edit received messages beyond the status field; to respond, write a new message.
- **Sending**: Write to this project's `outbox/` (permanent sender-side record) AND copy the same file into the recipient project's `inbox/`. Record the exchange in CURRENT_STATUS so it is traceable next session.
- **Snapshots over pointers**: When communicating numbers/deliverables to another project, put the value in the message body rather than referencing internal files.
- **Full specification**: `DOC_HARNESS_SPEC.md` §14 (in this project's root).
```

**(c) Add to Recovery Chain** task-conditional layer in CLAUDE.md:

```markdown
- If `inbox/` has any file with `status: unread`: read and action those first
```

**(d) Register in FILE_INDEX**:

```markdown
## Inter-Project Communication
- `inbox/` — Incoming messages from other projects
- `outbox/` — Outgoing messages (drafts and sent-copies)
```

## Step 4: Verify

- All 5 files exist
- FILE_INDEX lists all 5 (plus `inbox/`/`outbox/` if enabled)
- CURRENT_STATUS has all 4 sections
- CLAUDE.md contains embedded operational rules (and inter-project iron rule block if enabled)
- WORKLOG has empty TOC
- If inter-project comms enabled: `inbox/` and `outbox/` exist; Recovery Chain includes the task-conditional entry

Report: "Doc Harness initialized for [PROJECT_NAME]. 5 files created[, with inter-project inbox/outbox enabled if applicable]."
