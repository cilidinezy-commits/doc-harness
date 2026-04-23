# Doc Harness v1.6.0 — I built a "save state" system for AI coding agents, and it actually works

**TL;DR**: Doc Harness gives your AI agent a memory that survives session boundaries. Five slash commands (`init`, `check`, `sync`, `flush`, `recall`) turn project chaos into structured documentation that any agent — Claude, GPT-4, Kimi, or you — can read and resume from. v1.6.0 adds an identity lock to prevent cross-project confusion.

---

## The problem

You know the drill. You spend 3 hours with Claude Code building a feature. Context compacts. New session starts. Claude opens the project and asks:

> "What would you like to work on?"

You: *"We were literally in the middle of refactoring the auth middleware 10 minutes ago."*

Or worse: you have multiple projects. Claude investigates a bug in Project B while working on Project A, and suddenly starts writing files to the wrong repo because it *forgot which project it belongs to*.

Chat history is not memory. Context windows are temporary. `MEMORY.md` is Claude-only and opaque.

## What Doc Harness does

Doc Harness is a **file-based project control system**. It creates 5 markdown documents in your project root that act as the agent's persistent memory:

| Document | Purpose |
|----------|---------|
| **CLAUDE.md** | Project entry point — identity, rules, recovery chain |
| **CURRENT_STATUS.md** | Active state — what just happened, what's happening now, what's next |
| **FILE_INDEX.md** | File catalog — every document and its role |
| **WORKLOG.md** | Permanent history — complete record of every phase |
| **DOC_HARNESS_SPEC.md** | Full spec reference for edge cases |

Any agent that opens your project reads these files and knows exactly where things stand. No external memory. No proprietary formats. Just markdown.

## The five commands

### `/doc-harness init` — Bootstrap in 30 seconds

Creates all 5 documents from a conversation. You say: *"Set up doc-harness for my Flask API"* — it asks 3 questions, writes the files, and you're done. Works on clean repos and mid-project adoption (it scans existing files and reconstructs history instead of wiping it).

### `/doc-harness check` — Health audit + principle reflection

Two purposes: (1) catch documentation drift (unregistered files, stale dates, broken recovery chain), and (2) force the agent to reflect on whether it's following the project's iron rules. I run this every 1-2 hours during long sessions. It finds problems before they become disasters.

### `/doc-harness sync` — Repair drift automatically

`check` reports; `sync` fixes. Scans for unregistered files, refreshes stale timestamps, and optionally triggers phase transitions or WORKLOG archival when thresholds are hit. `auto` mode fixes safe things without asking; `interactive` mode asks before major changes.

### `/doc-harness flush` — Emergency save before context death

The big one. When context compression is imminent, `flush` systematically extracts everything important from context into documents. After a successful flush, a new agent reading the recovery chain recovers state **as if context was never compressed**. Five phases: sync → inventory → write/register → verification → marker.

### `/doc-harness recall [query]` — Search your project's memory

As projects grow, information scatters across dozens of files. `recall` searches systematically: CLAUDE.md → CURRENT_STATUS → WORKLOG → FILE_INDEX → individual files. Four query types: status/plan, history/decision, file lookup, cross-document synthesis. Every claim is cited with file and line reference.

## What's new in v1.6.0

**AGENT IDENTITY LOCK** — The scariest bug I've seen: an agent spent 30 minutes reading another project's code, absorbed its context, and started writing to the wrong repo. v1.6.0 puts a cognitive anchor at the top of every CLAUDE.md:

> 🔒 **AGENT IDENTITY LOCK**
>
> **You are the [ProjectName] agent.**

Plus a Step 0 identity ritual in the recovery chain, a pre-send checklist for cross-project messaging, and automatic verification in `check`.

## Why this exists

I built this because I was losing work. Not to disk — to *context*. An agent would spend an hour on a complex analysis, context would compact, and the next session would start from zero. Or I'd switch from Project A to Project B and the agent would carry over assumptions from the wrong codebase.

Doc Harness treats documentation as **infrastructure**, not an afterthought. The 5 documents are the single source of truth. The 5 commands are the maintenance protocol.

## Installation

Claude Code:
```bash
/plugin marketplace add cilidinezy-commits/doc-harness
/plugin install doc-harness
```

Kimi CLI:
```bash
# Drop into ~/.kimi/skills/doc-harness/
```

Or manual: clone [github.com/cilidinezy-commits/doc-harness](https://github.com/cilidinezy-commits/doc-harness), copy `skill/` to `~/.claude/skills/doc-harness/`.

## Real-world usage

I've been dogfooding this for 4 weeks across 6 projects (Python APIs, LaTeX papers, React frontends, research code). The pattern that works:

1. **Start of session**: `/doc-harness check` (2 min) → knows project state
2. **Every hour**: update CURRENT_STATUS car body with completed steps
3. **Before break**: `/doc-harness flush --auto` → state saved to files
4. **Next session**: reads CLAUDE.md → CURRENT_STATUS → resumes exactly where it left off

Zero "what were we doing again?" moments. Zero lost analysis. Zero wrong-repo commits.

## Questions?

MIT licensed. Happy to answer questions or take feature requests. The spec is 1400 lines and self-contained — if you want to understand the design philosophy, it's all in there.
