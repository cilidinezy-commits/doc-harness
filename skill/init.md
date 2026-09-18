# Doc Harness — Init

Initialize Doc Harness for a project so any future agent can take over from files alone.

## Step 1: Gather Information

Priority order: arguments → conversation context → ask the user. Infer, don't fabricate.

**Required**:
- Project name (short).
- Project description (1–3 sentences).
- The project's **framework anchor** (how it is layered / which layers are active / responsibility boundaries / north-star red lines). If unknown, leave a clear placeholder.
- Initial **active work units** (1–3 minimal units in play) and the **#1 next step + blocker**.

**Optional** (ask if unclear; OK to leave blank):
- Iron rules, bottom-line principles, key technical details.
- Inter-project inbox/outbox: ask "Does this project coordinate with other projects?" Default yes if dependencies were mentioned, otherwise no.

## Step 2: Check Existing Files

- **(a) Clean** → blank templates.
- **(b) Doc Harness already present** → do not overwrite; suggest `/doc-harness check`.
- **(c) Non-empty without Doc Harness** → mid-project adoption: reconstruct history faithfully, propose a draft `events.log`, bulk-register existing files; ask the user to confirm.
- **(d) Explicit clean restart** → confirm, then proceed as (a); append an override event to `events.log`.

## Step 3: Create Files

### File 1: CLAUDE.md (single authoritative entry)

```markdown
# [PROJECT_NAME] — Entry Document

> 🔒 **AGENT IDENTITY LOCK**
>
> **You are the [PROJECT_NAME] agent.**
> [One sentence: your role and scope in this project.]
>
> If you doubt your identity, stop and re-read this paragraph.

---

**Last updated**: [TODAY]
**Current status**: [ONE-LINE now snapshot]
**One-line status (as of [TODAY])**: [description] — project just initialized

---

## Stable Anchor (rarely changes; survive every session)

### Framework Anchor

- Layers: [how the project is layered]
- Active now: [which layers]
- Responsibility boundaries: [who owns what]
- North-star red lines: [non-negotiables]

### Iron Rules

- [project iron rules]

### Bottom-line Principles

1. [generating principle — points to PHILOSOPHY.md or a design doc]

---

## Recovery Chain

### Must-read (in order)
1. This file (CLAUDE.md): AGENT IDENTITY LOCK → Stable Anchor
2. `CURRENT_STATUS.md` → `## NOW`

### Task-conditional
- If `## NOW`'s "read first" list points to files, read those.
- If `inbox/` has `status: unread`, action those first.
- [project-specific entries]

### Meta-rules
- Self-contained: only project-internal (or stable sibling) paths.
- Living: review at architecture changes.

## Project Overview

[DESCRIPTION expanded to 3–5 lines]

## Key Technical Information

[tools, languages, paths, or "to be filled"]

---

## Doc Harness — Operational Rules

[EMBED operational_rules.md between its sentinels]
```

Embed `operational_rules.md` between `<!-- doc-harness-ops-start -->` and `<!-- doc-harness-ops-end -->` (inclusive). Re-embed replaces only that region.

### File 1b: AGENTS.md (thin pointer)

```markdown
# [PROJECT_NAME] — Agent entry (thin pointer)

The single authoritative entry is [`CLAUDE.md`](CLAUDE.md). Do not read this file as state; follow CLAUDE.md.
```

This prevents a stale AGENTS.md snapshot and avoids double injection by harnesses that read both files.

### File 2: CURRENT_STATUS.md

```markdown
---
now_refreshed: [TODAY]
active_unit_ids: [unit-a, unit-b]
read_first: ["notes/a.md", "notes/b.md"]
---

# CURRENT_STATUS — [PROJECT_NAME]

**Last updated**: [TODAY]

---

## NOW

- **In progress**: [1–3 active work units]
- **Next step**: [#1 action] — blocker: [or "none"]
- **Read first**: [2–4 files/anchors]
- **Key judgment**: [recent direction/priority change, or "none yet"]
- **Last refreshed**: [TODAY]

## Work Surface

### Plan
<ordered top-level parts; mark active / paused>

### Units
#### <part>
- [active] `<unit-id>` <one-line description>
- [future] `<unit-id>` <one-line description>

## Recent History

(No completed work yet — see `events.log`.)
```

### File 3: FILE_INDEX.md

```markdown
# FILE_INDEX — [PROJECT_NAME]

**Last updated**: [TODAY]

## Core Documents
- `CLAUDE.md` — single authoritative entry + stable anchor
- `AGENTS.md` — thin pointer to CLAUDE.md
- `CURRENT_STATUS.md` — NOW + work surface + recent history
- `FILE_INDEX.md` — this file
- `events.log` — append-only event log (history + state primitive)
```

### File 4: events.log

```markdown
# events.log — [PROJECT_NAME]
(append-only; one event per line — starts empty or with a migration event)
```

### File 5: DOC_HARNESS_SPEC.md

**Optional** reference copy of `spec.md`. Not state; the installed skill already carries the spec. If absent, that is fine.

### Step 3.6: Optional inbox/outbox

Create `inbox/` + `outbox/`; add the inter-project iron-rule block and the Recovery Chain unread entry; register both in FILE_INDEX.

## Step 4: Verify

- CLAUDE.md begins with AGENT IDENTITY LOCK and contains a Stable Anchor + embedded operational rules.
- AGENTS.md is a thin pointer.
- CURRENT_STATUS has a bounded `## NOW` + Work Surface.
- FILE_INDEX lists all core docs.
- `events.log` exists (empty, or with migration events).
- inbox/outbox present if enabled.

Report: "Doc Harness initialized for [PROJECT_NAME]."
