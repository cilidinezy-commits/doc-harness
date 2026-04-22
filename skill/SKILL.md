---
name: doc-harness
description: "Document-based project control that lets any AI agent or human resume work from files alone — no external memory needed. Use this skill whenever the user wants to structure a long-running project, track progress across sessions, recover state after context loss, coordinate multiple agents on the same project, audit project documentation health, or stop forgetting what was done last session. Triggers include: '/doc-harness init' and '/doc-harness check' (explicit slash commands); requests like 'help me set up this project', 'I keep losing track', 'my agent forgets between sessions', 'organize my project docs', 'audit this project', 'check the documentation', 'what did we do last time'; multi-week projects (theses, research, analyses, software modules) that span many sessions; cross-project coordination (inbox/outbox for file-based messages between projects)."
argument-hint: "init [project-name] [description] | check | sync [--auto] | flush [--auto] | recall [query]"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Doc Harness — Document-Based Project Control

Doc Harness is a documentation system that enables any AI agent or human collaborator to understand and resume project work purely from reading files — no external memory needed.

It creates and maintains **five documents** per project:
- **CLAUDE.md** — Project entry point (overview, recovery chain, iron rules, operational rules)
- **CURRENT_STATUS.md** — Active state (tire tracks / car body / headlights / driving manual)
- **FILE_INDEX.md** — File catalog organized by category
- **WORKLOG.md** — Permanent work history (append-only)
- **DOC_HARNESS_SPEC.md** — Complete specification (reference document)

Two **optional** documents may be added when a project accumulates such content (see spec.md Chapter 13):
- **PARKING_LOT.md** — Deferred items with preconditions for revival
- **PHILOSOPHY.md** — Principles forged by this project's practice

One **optional** mechanism may be adopted when a project coordinates with others (see spec.md Chapter 14):
- **Inter-project inbox/outbox** — self-contained file-based messaging protocol. `inbox/` and `outbox/` directories; YAML-frontmatter Markdown messages; lifecycle `unread → read → actioned`. Fully described inside doc-harness itself; no external spec needed.

## Commands

### `/doc-harness init [project-name] [description]`

Initialize Doc Harness for a new project. Creates all 5 files in the current directory.

**→ See [init.md](init.md) for full instructions and templates.**

### `/doc-harness check`

Audit the current project's documentation health and reflect on working principles.

**→ See [check.md](check.md) for full check procedures.**

### `/doc-harness sync [--auto]`

Synchronize status documents with reality. Repair drift, refresh stale fields, register missing files, and optionally trigger phase transition or WORKLOG archival.

- **`interactive`** (default): Ask before phase transitions, archival, or creating new principle documents.
- **`auto`**: Execute fixes without asking.

**→ See [sync.md](sync.md) for full sync procedures.**

### `/doc-harness flush [--auto]`

Emergency save before context compression. Includes everything `sync` does, plus mandatory extraction of important context information into documents.

- **`interactive`** (default): Ask before each significant extraction.
- **`auto`**: Use heuristics to classify and save context information without asking.

**→ See [flush.md](flush.md) for full flush procedures.**

### `/doc-harness recall [query]`

Retrieve information from the project's Doc Harness document hierarchy. Search systematically across registered documents and return structured, source-cited results.

**Query types**:
- **Status/Plan**: "What's the current plan for auth?" → searches CURRENT_STATUS + headlights
- **History/Decision**: "Why did we choose PostgreSQL?" → searches WORKLOG + tire tracks
- **File lookup**: "Find all docs about caching" → searches FILE_INDEX
- **Synthesis**: "All discussions about authentication" → comprehensive search across all layers

**→ See [recall.md](recall.md) for the layered search protocol and output format.**

### `/doc-harness` (no arguments)

Inspect the current directory and suggest the right next step:
- **All 4 core files present** (CLAUDE.md, CURRENT_STATUS.md, FILE_INDEX.md, WORKLOG.md) → suggest `/doc-harness check`.
- **No Doc Harness files at all** → suggest `/doc-harness init` (clean init or mid-project adoption per `init.md` Step 2).
- **Partial state** (some files present, others missing or malformed) → suggest `/doc-harness init` in **mid-project adoption mode** (see `init.md` Step 2 branch (b)/(c)); do NOT suggest `check` on a broken installation.

Then show this help summary.

## Core Principle: "Write It Down or Lose It"

Information in context will eventually be completely lost. Important information must be **written to a file** and **registered in FILE_INDEX**. Not written = lost. Not registered = undiscoverable = effectively lost.

**Context-aware corollary**: if your runtime exposes a context-window usage metric (percentage or token count), treat **low remaining context** (~<20%) as an immediate trigger to flush CURRENT_STATUS before the next tool call, and consider a phase transition if the car body holds substantial unsaved work (see `spec.md` §11.2 bullet 4 for the concrete threshold). Compression is involuntary session end — preemptive writes are the only defense.

## Reference Documents

- [init.md](init.md) — Read when executing `/doc-harness init`. Covers clean init, mid-project adoption, partial-state repair, and optional inter-project inbox/outbox setup.
- [check.md](check.md) — Read when executing `/doc-harness check`. Audit procedures for file health, recovery-chain soundness, mid-transition detection, and inbox status.
- [sync.md](sync.md) — Read when executing `/doc-harness sync`. Drift repair, date refresh, file registration, phase-transition and archival triggers.
- [flush.md](flush.md) — Read when executing `/doc-harness flush`. Emergency save with systematic context-to-document extraction.
- [recall.md](recall.md) — Read when executing `/doc-harness recall`. Layered search protocol for retrieving information from registered documents.
- [operational_rules.md](operational_rules.md) — The operational rules embedded verbatim into every project's CLAUDE.md at `init` time. Carries the `<!-- doc-harness-ops-version -->` version tag so the check command can detect stale embeddings.
- [spec.md](spec.md) — Complete Doc Harness specification (14 chapters + 5 appendices). Authoritative — all other files derive from it. Has a Table of Contents at the top for navigation without full-read.
