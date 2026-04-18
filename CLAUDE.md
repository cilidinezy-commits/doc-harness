# Doc Harness — Entry Document

**Last updated**: 2026-04-19
**Current phase**: Phase 4 — Maintenance & field-feedback watch (⏳ idle)
**One-line status (as of 2026-04-19)**: v1.4 shipped + published. Plugin marketplace live (`/plugin marketplace add cilidinezy-commits/doc-harness`), smoke-tested, submitted to awesome-claude-code + two catalogs. Phase 3 (v1.2→v1.3→v1.4 + publishing) closed cleanly. Project now idle; reactivate on v1.5 triggers (see CURRENT_STATUS driving manual).

---

## Recovery Chain

### Must-read (baseline)

1. This file (CLAUDE.md)
2. `CURRENT_STATUS.md`

### Task-conditional

- If `inbox/` has any file with `status: unread`: read and action those first
- If looking up a file: read `FILE_INDEX.md`
- If investigating phase history: read `WORKLOG.md`
- If editing the spec or operational rules: read `skill/spec.md` (authoritative)

### Meta-rules

- Self-contained: all entries point to project-internal files. No dependency on agent-side features.
- Living: review at phase transitions.

## Project Overview

Doc Harness is a Claude Code skill that provides document-based project control for AI-human collaboration. It creates and maintains 5 status documents per project (CLAUDE.md, CURRENT_STATUS.md, FILE_INDEX.md, WORKLOG.md, DOC_HARNESS_SPEC.md) that enable any agent or human to understand and resume project work purely from reading files.

**Two subcommands**: `/doc-harness init` (create docs) and `/doc-harness check` (audit + reflect).

**Core principle**: "Write It Down or Lose It" — context info is temporary, files are permanent.

**Origin**: Designed and validated in `D:\Projects\project_reorganization\` (7 phases, 2026-04-01 ~ 04-03), then published as standalone skill.

## Project-Level Iron Rules

1. **中英文版本永远同步**: Every change to skill/ must be mirrored to skill-zh/, and vice versa. No exceptions.
2. **Doc Harness adapts to project, not project to Doc Harness**: The skill must accommodate diverse project structures. Never impose rigid templates that break existing workflows.
3. **spec.md is the authoritative specification**: All other files (operational_rules.md, init.md, check.md, README) derive from spec.md. Contradictions are resolved in favor of spec.md.
4. **Test before release**: Every change must be validated (blind test, real project test, or simulation) before pushing to GitHub or updating installed copies.
5. **Deployment sync**: After any change, update all 3 locations: dev source → GitHub push → installed copies (user-level + project-level).

6. **Inter-project communication via inbox/outbox (file-based protocol)**

   - **Mechanism**: This project maintains `inbox/` (received messages) and `outbox/` (sent messages). Messages are Markdown files with YAML frontmatter; filename `YYYY-MM-DD-from-<source>-<topic>.md`.
   - **Why this is mandatory (if adopted)**: Cross-project information exchanged only in chat is lost on session end. File-based messages survive session boundaries and are discoverable by any future agent through this project's Recovery Chain.
   - **Receiving**: Recovery Chain checks `inbox/` for `status: unread`. Read → update to `status: read`. After acting on the message → `status: actioned`. Never edit received messages beyond the status field; to respond, write a new message.
   - **Sending**: Write to this project's `outbox/` (permanent sender-side record) AND copy the same file into the recipient project's `inbox/`. Record the exchange in CURRENT_STATUS so it is traceable next session.
   - **Snapshots over pointers**: When communicating numbers/deliverables to another project, put the value in the message body rather than referencing internal files.
   - **Full specification**: `DOC_HARNESS_SPEC.md` §14 (in this project's root).

## Key Technical Information

**GitHub**: https://github.com/cilidinezy-commits/doc-harness (latest tag: v1.4)
**License**: MIT

**File structure**:
```
doc-harness/
├── skill/           ← English skill files (5 files, authoritative)
├── skill-zh/        ← Chinese skill files (5 files, synced)
├── README.md        ← English project description
├── README_zh.md     ← Chinese project description
└── LICENSE          ← MIT
```

**Deployment locations** (installed copies must match dev source):
- User-level: `~/.claude/skills/doc-harness/` ← from `skill/`
- Project-level (ObsVault_Tools): `.claude/skills/doc-harness/` ← from `skill/`

**Skill files** (same structure in both skill/ and skill-zh/):
| File | Role |
|------|------|
| SKILL.md | Entry point + router |
| init.md | `/doc-harness init` — create 5 docs |
| check.md | `/doc-harness check` — audit + reflect |
| operational_rules.md | Rules embedded in each project's CLAUDE.md (180 lines as of v1.4; delimited by `<!-- doc-harness-ops-start/end -->` sentinels) |
| spec.md | Complete specification (1320 lines as of v1.4, 14 chapters + 5 appendices, TOC at top) |

## Doc Harness — Operational Rules

> Complete specification: see `DOC_HARNESS_SPEC.md` in this directory.

### Core Principle: "Write It Down or Lose It"

Important information must be **written to a file** and **registered in FILE_INDEX**. Not written = lost. Not registered = undiscoverable = effectively lost.

### Four Core Documents

| Document | Role | When to update |
|----------|------|---------------|
| **CLAUDE.md** | Project entry | Phase transitions; one-line status every session end |
| **CURRENT_STATUS.md** | Active status | Every session |
| **FILE_INDEX.md** | File catalog by category | When files created/deleted |
| **WORKLOG.md** | Complete history (append-only) | Phase transitions |

### Session End Checklist

- [ ] CURRENT_STATUS reflects all work?
- [ ] Next steps accurate?
- [ ] Dates refreshed?
- [ ] New files registered in FILE_INDEX?
- [ ] Anything unsaved? → Write it down!
