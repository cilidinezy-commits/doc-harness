---
name: doc-harness
description: "Doc Harness: document-based project control system. Use '/doc-harness init' to set up status docs for a new project, or '/doc-harness check' to audit health and reflect on working principles."
argument-hint: "init [project-name] [description] | check"
allowed-tools: Read, Write, Bash, Glob, Grep
---

# Doc Harness — Document-Based Project Control

Doc Harness is a documentation system that enables any AI agent or human collaborator to understand and resume project work purely from reading files — no external memory needed.

It creates and maintains **five documents** per project:
- **CLAUDE.md** — Project entry point (overview, recovery chain, iron rules, operational rules)
- **CURRENT_STATUS.md** — Active state (tire tracks / car body / headlights / driving manual)
- **FILE_INDEX.md** — File catalog organized by category
- **WORKLOG.md** — Permanent work history (append-only)
- **DOC_HARNESS_SPEC.md** — Complete specification (reference document)

## Commands

### `/doc-harness init [project-name] [description]`

Initialize Doc Harness for a new project. Creates all 5 files in the current directory.

**→ See [init.md](init.md) for full instructions and templates.**

### `/doc-harness check`

Audit the current project's documentation health and reflect on working principles.

**→ See [check.md](check.md) for full check procedures.**

### `/doc-harness` (no arguments)

Show this help message. Suggest `init` or `check` based on whether CLAUDE.md exists in current directory.

## Core Principle: "Write It Down or Lose It"

Information in context will eventually be completely lost. Important information must be **written to a file** and **registered in FILE_INDEX**. Not written = lost. Not registered = undiscoverable = effectively lost.

## Reference Documents

- [operational_rules.md](operational_rules.md) — The operational rules embedded in every project's CLAUDE.md (~106 lines)
- [spec.md](spec.md) — Complete Doc Harness specification with design rationale, worked examples, and edge cases
