# Doc Harness

[中文版 README](README_zh.md)

**Document-based project control for AI-human collaboration.**

Doc Harness is a [Claude Code](https://claude.ai/code) skill that gives you and AI agents a structured way to manage any project — like a harness that keeps a horse's power directed and under control.

It keeps your project organized as it grows, ensures AI agents follow the principles you establish, captures every important result and decision in persistent documents instead of letting them vanish with AI context, and makes it possible for any new agent — or you, after a break — to pick up exactly where things left off.

Works for any project: writing a thesis, building a SaaS feature, analyzing data for a client, researching an investigative article, developing a software library, or anything else that spans multiple sessions and produces files.

---

## What Problem Does This Solve?

When you work with AI agents on a project over days or weeks:

- **Your AI loses its memory.** Context windows compress or reset. Yesterday's analysis is forgotten today.
- **Files pile up without a map.** After a few sessions you have 30 files and nobody remembers what's where.
- **Principles drift.** You set rules ("validate on out-of-sample data"), but the AI gradually forgets them.
- **Handoffs fail.** A different agent arrives with zero context. You spend 20 minutes re-explaining.
- **You lose your place.** After a weekend, neither you nor the AI knows exactly where you left off.

Doc Harness solves these by maintaining a **self-contained documentation system** — a set of files that any agent can read and immediately understand, without any external memory or briefing.

---

## What Is a "Project"?

Anything that has a goal, spans multiple work sessions, and generates files:

- An academic thesis or research paper
- A SaaS feature or software module
- A data analysis pipeline for a client
- A long-form article or report
- An experiment series
- A product launch plan

A project is simply **a folder**. Inside it, Doc Harness creates five status documents alongside whatever folders and files your work needs:

```
my-project/
├── CLAUDE.md                ← Doc Harness: stable anchor
├── CURRENT_STATUS.md        ← Doc Harness: living pulse
├── FILE_INDEX.md            ← Doc Harness: file catalog
├── WORKLOG.md               ← Doc Harness: permanent archive
├── DOC_HARNESS_SPEC.md      ← Doc Harness: reference manual
│
├── notes/                   ← Your work (organize however you like)
├── scripts/
├── data/
└── drafts/
```

Doc Harness doesn't dictate your folder structure — it only asks that every file gets registered in FILE_INDEX.

---

## The Five Documents: How They Work

Each document serves a distinct purpose, updates at a different rhythm, and answers a different question. Together they cover everything an agent or collaborator needs to know.

### CLAUDE.md — The Stable Anchor

*Answers: "What is this project? What are the rules? Where do I start?"*

The first thing any agent reads. Contains your project overview, non-negotiable rules ("iron rules"), technical details (build commands, paths), and — crucially — the **embedded operational rules** that teach the agent how to maintain Doc Harness. This means you never have to explain the system to a new agent; it's right there in the file.

**Barely changes.** Updated only when phases shift or important rules are added. It's the stable foundation everything else hangs from.

### CURRENT_STATUS.md — The Living Pulse

*Answers: "What just happened? What's happening now? What's next?"*

The most dynamic document. Structured as a **moving car** with four sections:

| Section | Plain label | What's in it |
|---------|------------|-------------|
| Tire Tracks | **Recent History** | 2-3 short summaries of recently completed phases. Points to WORKLOG for details. |
| Car Body | **Current Phase Detail** | Everything about what's happening RIGHT NOW — every completed step, files created, decisions made. The detailed working record. |
| Headlights | **Next Steps** | What to do next: immediate actions + future plans. |
| Driving Manual | **Phase Principles** | Working guidelines for the current phase — rules that matter now but may not matter next phase. |

**Updated every session.** When a phase of work ends, the car body (full details) is archived to WORKLOG, compressed to a summary in tire tracks, and cleared for the new phase. This keeps the document always compact (~200 lines) while nothing is ever lost.

**This is what makes recovery work.** An agent with zero memory reads this and within seconds knows: where the project has been (tire tracks), where it is now (car body), where it's going (headlights), and what rules to follow (driving manual).

### FILE_INDEX.md — The Library Catalog

*Answers: "What files exist, what are they, and where are they?"*

Every file in the project gets a one-line entry, organized by category:

```markdown
## Research Notes
- `notes/literature_review.md` — Survey of 30 papers on price impact
- `notes/key_findings.md` — Cross-paper synthesis

## Scripts
- `scripts/analyze_data.py` — Price impact regression
```

**Grows as files are created.** The rule is simple: create a file → register it immediately. An unregistered file is invisible to future agents — it might as well not exist.

### WORKLOG.md — The Permanent Archive

*Answers: "What exactly happened in phase 2, three weeks ago?"*

When a phase ends, its complete record moves here from CURRENT_STATUS. A table of contents at the top keeps it navigable. Content is append-only — never edited, never deleted.

CURRENT_STATUS keeps only recent summaries to stay compact. WORKLOG is where the full history lives, permanently searchable.

### DOC_HARNESS_SPEC.md — The Reference Manual

Complete specification with design rationale, edge cases, and worked examples. For daily work you don't need it — the operational rules in CLAUDE.md are enough. The spec is for unusual situations or understanding the system's design.

### Why They Work Together

| Document | Updates | Answers |
|----------|---------|---------|
| CLAUDE.md | Rarely | "What is this project?" |
| CURRENT_STATUS | Every session | "What's happening now?" |
| FILE_INDEX | When files change | "Where is everything?" |
| WORKLOG | Phase transitions | "What happened before?" |

Each fact lives in exactly **one** document (Single Source of Truth), so there are no contradictions. The operational rules are embedded in CLAUDE.md, so any agent reading it knows how to maintain the entire system.

---

## Getting Started

### Install (first time)

The skill is a folder of Markdown files. "Installing" means copying that folder into Claude Code's skills directory so the agent can find it.

**Step 1 — clone the repo:**
```bash
git clone https://github.com/cilidinezy-commits/doc-harness.git
cd doc-harness
```

**Step 2 — pick a language.** `skill/` is English; `skill-zh/` is Chinese. They install to the same path and cannot coexist — pick the language that matches the documentation your projects will use.

**Step 3 — copy into Claude Code's skills directory.**

Unix / macOS / Git Bash on Windows:
```bash
cp -r skill ~/.claude/skills/doc-harness        # English
# or:
cp -r skill-zh ~/.claude/skills/doc-harness     # Chinese
```

Windows PowerShell / cmd:
```powershell
xcopy skill %USERPROFILE%\.claude\skills\doc-harness\ /E /I
```

**Step 4 — verify.** Open Claude Code in any directory and type `/doc-harness`. You should see the help output describing `init` and `check`. If the command isn't recognized, the files weren't copied to the right path — check `~/.claude/skills/doc-harness/SKILL.md` exists.

**Check the installed version**: `head -3 ~/.claude/skills/doc-harness/spec.md` — should print the `**Version**` line (e.g., `v1.4`).

### Project-level install (optional)

If you want a specific project to pin a particular Doc Harness version independent of your user-level install, put the skill at `<project_root>/.claude/skills/doc-harness/` instead. Claude Code prefers project-level skills over user-level when both exist. `/doc-harness check` resolves install paths in this order: project → `~/.claude` → XDG → Windows default.

### Upgrade an existing install

1. **Pull the latest**: `cd doc-harness && git pull`
2. **Re-copy the skill folder** — the same command as Step 3 of first-install. It overwrites in place; no local state lives in the installed skill directory, so nothing is lost.
3. **Verify the new version**: `head -3 ~/.claude/skills/doc-harness/spec.md`.
4. **Upgrade your existing projects' CLAUDE.md** (important): the operational rules embedded inside each project's `CLAUDE.md` are a **snapshot** taken at `init` time — they do NOT update automatically when you upgrade the skill. To bring a project up to date, replace the bytes between `<!-- doc-harness-ops-start -->` and `<!-- doc-harness-ops-end -->` in that project's `CLAUDE.md` with the new contents of `operational_rules.md`. Anything outside those sentinels (custom iron rules, project-specific sections) is preserved. Run `/doc-harness check` in the project — §1.10 tells you if the embedded version is stale.
5. **(If the project has `DOC_HARNESS_SPEC.md`)** overwrite with the new `spec.md`.
6. **v1.2 → v1.3 / v1.4 specifically**: if the project has cross-project dependencies, follow the retrofit in `spec.md` §14.7 to enable `inbox/outbox`. Skip if the project is standalone.

### Uninstall

**Remove the skill globally** (stops Doc Harness from being available in any project):
```bash
rm -rf ~/.claude/skills/doc-harness
```
or Windows: `rmdir /S %USERPROFILE%\.claude\skills\doc-harness`.

**Stop using Doc Harness on one project** (keeps it available elsewhere): delete or move aside that project's 4 core files (`CLAUDE.md`, `CURRENT_STATUS.md`, `FILE_INDEX.md`, `WORKLOG.md`) — e.g., `mv *.md _archive/`. The skill itself is inert on a project that has no Doc Harness files.

**Downgrade to an earlier version**: `cd doc-harness && git checkout v1.3` (or whatever tag), then re-copy. Existing projects' embedded rules stay at whatever version they were when `init`'d.

### Use It

Once installed, the AI agent knows about Doc Harness. You don't need to memorize commands — just talk naturally:

> *"Let's set up project documentation for this."*
> *"I want to organize this project so we don't lose track of things."*
> *"Create a status documentation system for this project."*

The agent will recognize what you need and set up the five documents, asking you about your project's name, goals, and current state along the way.

You can also use the slash command directly if you prefer: `/doc-harness init`

### Works for New and Existing Projects

**New project?** The agent creates documents for a fresh start — your goals, first tasks, initial rules.

**Project already underway?** Works just as well. Tell the agent where you are:

> *"We've been working on this for two weeks already. We finished the data collection phase and are now building the analysis pipeline."*

The agent will create documents that reflect your current state — not a blank slate. Existing files can be gradually registered in FILE_INDEX.

You don't need to start from day one. Doc Harness meets your project where it is.

---

## What Actually Happens After You Install It

Here's what the generated CLAUDE.md looks like for a real project:

```markdown
# Market Analysis Tool — Entry Document

**Last updated**: 2026-04-02
**Current phase**: Data pipeline (⏳)
**One-line status (as of 2026-04-02)**: Core scraper working, building transformation layer

## Recovery Chain

### Must-read (baseline)
1. This file (CLAUDE.md)
2. CURRENT_STATUS.md

### Task-conditional
- If looking up a specific file: read FILE_INDEX.md
- If investigating phase history: read WORKLOG.md
- [Project-specific entries added as work categories emerge]

### Meta-rules
- Self-contained: only project-internal files. No dependency on agent-side features.
- Living: review at phase transitions.

## Project Overview
Building a market data analysis tool for internal use. Scrapes order book data,
transforms it, and generates daily reports. Python + pandas, deployed on AWS.

## Iron Rules
- Never commit API keys to git
- All data transformations must be idempotent
- "Write It Down or Lose It" — save important info to files, register in FILE_INDEX

## Doc Harness — Operational Rules
[~100 lines of rules that teach any agent how to maintain the system]
```

And CURRENT_STATUS.md:

```markdown
# CURRENT_STATUS — Market Analysis Tool

**Last updated**: 2026-04-02
**Current phase**: Data pipeline

## Recent History (Tire Tracks)
### Phase 1: Scraper (2026-03-20 ~ 2026-04-01)
Built order book scraper for 3 exchanges. Handles rate limits and reconnection.
Created `scripts/scraper.py` and `tests/test_scraper.py`. Details in WORKLOG.

## Current Phase Detail (Car Body)
### Phase Goal
Build the data transformation layer (raw → clean → aggregated)

### Completed Steps
#### Set up transformation framework (2026-04-02)
- Created `scripts/transform.py` with pipeline architecture
- Registered in FILE_INDEX

## Next Steps (Headlights)
### Immediate
1. Implement OHLCV aggregation
2. Add data quality checks

## Phase Principles (Driving Manual)
- Write tests before transformations
- Validate output schema after each stage
```

Every agent reading these two files can immediately continue your work.

---

## Day-to-Day Usage

**Session starts** → Agent reads CLAUDE.md (overview + rules) → CURRENT_STATUS (current state) → continues working.

**During work** → Agent completes a step → updates CURRENT_STATUS. Creates a file → registers in FILE_INDEX. Has an important insight → saves to a file ("Write It Down!").

**Phase ends** → Five-step transition: car body archived to WORKLOG (data protected first), compressed to a tire track summary, car body cleared for new phase.

**Session ends** → Quick checklist: status updated? Files registered? Anything unsaved?

**Context resets or new agent arrives** → Reads CLAUDE.md → CURRENT_STATUS → fully oriented.

### What You (the Human) Do

- **Most of the time: nothing extra.** The rules are in CLAUDE.md; the agent follows them.
- **Occasionally: nudge the agent** if you notice it's not updating status or registering files. A natural *"make sure you update the project status"* or *"did you register that new file?"* is enough.
- **When things feel messy:** Just say *"check the status documentation"* or *"let's do a health check on the project docs."* The agent knows what to do. (You can also type `/doc-harness check` directly.)

### Non-Sequential Work

Not all projects proceed in neat sequential phases. You might work on data analysis and report writing in parallel, or jump between features. Doc Harness handles this:
- Use the car body to track **all** active work threads with sub-headings
- A "phase transition" happens when the *overall focus* shifts, not every time you switch tasks
- When in doubt, don't trigger a phase transition — just organize within the car body

---

## Health Check

At any point, you can ask the agent to check how well the project documentation is maintained:

> *"Check the project documentation health."*
> *"Run a status doc check in the background."*

(Or directly: `/doc-harness check`)

The check does two things:

**File audit** — Are all documents present? Is CURRENT_STATUS fresh? Does FILE_INDEX match actual files on disk? Issues get flagged with specific fixes.

**Principle reflection** — Reads your iron rules and phase principles, prompts the agent: *"Am I actually following these?"* Also checks: *"Is there anything important sitting only in context right now?"*

> Tip: Ask for this as a background task so it doesn't interrupt your main work.

---

## Core Principle: "Write It Down or Lose It"

AI context is temporary. Analysis results, design decisions, insights, debugging discoveries — if it's not in a file, it will vanish when context resets. And the file must be **registered in FILE_INDEX** — an unregistered file is invisible to future agents.

This single principle prevents more information loss than any other feature.

---

## Languages

- `skill/` — English
- `skill-zh/` — 中文版

Install **one**: the two install to the same path and cannot coexist. Pick the language that matches the documentation your projects will use — install/upgrade/uninstall procedures are in the Getting Started section above.

## Requirements

- [Claude Code](https://claude.ai/code) — CLI, desktop app, web app, or IDE extension
- No other dependencies

## FAQ

**Q: Can I add this to a project that's already underway?**
Yes — this is a common use case. Run `/doc-harness init` and tell the agent about your project's current state. It will create documents reflecting where you are now, not just the beginning. Existing files can be gradually registered in FILE_INDEX.

**Q: My work isn't sequential — I juggle multiple things at once. Does this still work?**
Yes. Use sub-headings in the car body to track parallel work threads. Phase transitions happen when the overall focus shifts, not every time you switch tasks. The system is flexible about internal organization.

**Q: Does this work with AI tools other than Claude Code?**
The `/doc-harness` commands are Claude Code specific. But the documentation system itself is universal — any AI that reads markdown can follow the operational rules in CLAUDE.md.

**Q: How does this relate to Claude Code's MEMORY.md?**
They're complementary. MEMORY.md is Claude's personal memory across sessions (maintained automatically). Doc Harness is project-level documentation (maintained explicitly). Doc Harness is designed to work without MEMORY.md — any agent, with or without personal memory, can recover the project state from the files alone.

**Q: How much overhead does this add?**
Minimal. One line per completed step, one line per new file. The check takes ~2 minutes and can run in the background. The system is designed to serve the project, not burden it.

**Q: Will the AI actually follow the rules?**
The operational rules are embedded in CLAUDE.md, which the agent reads at session start. Most of the time it follows them well. Occasionally you may need to remind it — "update the status" or "register that file." The `/doc-harness check` catches drift.

**Q: Can I customize the structure?**
Yes. Add sections, define your own categories, adjust principles. Core requirements: keep the four documents, follow the phase transition protocol, register files.

**Q: Sub-projects?**
Each gets its own Doc Harness. Parent's FILE_INDEX links to sub-project entries.

**Q: My project has 1000+ files. Do I really have to register each one?**
No — that's what FILE_INDEX sub-indexes and bulk registration are for. See spec §4.3 (a sub-directory with >20 files should have its own sub-FILE_INDEX.md) and §4.4 (bulk registration lets you record a folder + count + naming rule in one entry instead of listing every file). `/doc-harness check` §1.4 recurses into sub-indexes automatically.

**Q: How do I disable Doc Harness on one project?**
Delete the 4 core files (CLAUDE.md, CURRENT_STATUS.md, FILE_INDEX.md, WORKLOG.md) or move them into `_archive/`. The skill itself (installed at `~/.claude/skills/doc-harness/`) is not per-project — it becomes inert for a project that has no Doc Harness files.

**Q: Cross-project messaging — what does an inbox message actually look like?**
A complete example (filename `2026-04-19-from-whoami-api-deadline.md` in the recipient's `inbox/`):

```markdown
---
from: whoami
to: lit-system-api
date: 2026-04-19
subject: API deadline moved forward to May 15
status: unread
in-reply-to: null
priority: high
---

Heads up — the academic job site launches 2026-05-20 and needs your
citation-marker API working by 2026-05-15. Contract unchanged from
the 2026-04-10 spec; just the deadline shifted.

Please confirm receipt by sending a reply message.
```

The recipient agent reads this, flips `status: unread` → `read`, performs whatever work is needed (here: acknowledgment + plan), then flips to `actioned`. Full protocol: spec Chapter 14. Enable on init (y/n prompt in Step 1) or retrofit existing projects per spec §14.7.

**Q: What's new in v1.2?**
- **Recovery Chain is now two-layer**: a minimal must-read baseline (2–3 files) plus a task-conditional list for work-specific lookups. Self-contained — no dependency on agent-side memory or external services.
- **WORKLOG archival**: when `WORKLOG.md` passes ~1000 lines, older phases move to `WORKLOG_ARCHIVE_<YYYY-QN>.md` (quarterly). Keeps the active WORKLOG readable without losing history.
- **Two optional documents** for long-horizon content: `PARKING_LOT.md` (deferred items with revival preconditions) and `PHILOSOPHY.md` (principles forged by project practice). Both opt-in — create only when there's content to put there.

**Q: What's new in v1.3?**
- **Inter-project inbox/outbox** is now an optional Doc Harness feature (Chapter 14 of the spec). When a project coordinates with others, it can adopt `inbox/` and `outbox/` directories with a YAML-frontmatter Markdown message protocol. The complete specification is self-contained inside each project's `DOC_HARNESS_SPEC.md` — no external spec needed. *(This reverses v1.2's position that inbox/outbox was out of scope; design rationale in `spec.md` Appendix E.)*
- `/doc-harness init` now asks whether to enable the inbox/outbox protocol and sets up the folders, iron rule block, Recovery Chain entry, and FILE_INDEX category automatically (Step 3.6).
- `/doc-harness check` now audits inbox unread-message count (§1.7) and checks Recovery Chain health for the two-layer structure (§2.5).
- **Hierarchical "portfolio" framing removed** from the spec. Projects in a group are self-contained peers; a parent navigation file is a lightweight optional pattern, not a Doc Harness concept. (The neutral term "project group" / §10.2 is retained for this flat-peer arrangement.)
- **Context-aware update cadence**: operational rules now instruct agents whose runtime exposes context-window usage to treat low remaining context (~<20%) as an immediate trigger for CURRENT_STATUS update and possible phase transition. Compression is involuntary session end — don't wait for a "meaningful step" that may never land.

**Q: What's new in v1.4?**
A comprehensive hardening pass driven by six review cycles. Key additions:
- **Mid-transition detection (§6.3.1)**: a three-way coherence check (CLAUDE.md phase / WORKLOG TOC / CURRENT_STATUS tire tracks) that detects an interrupted phase transition and repairs it deterministically. Wired into `/doc-harness check` §1.9.
- **Malformed inbox messages**: §14.8 specifies quarantine (`inbox/_malformed/`), classification, and the strict-vs-lenient policy for each malformation type.
- **Archival trigger for stale messages**: §14.4 rule 3 is now actionable — `/doc-harness check` §1.7(b) flags archival when ≥5 `actioned` messages are older than 30 days.
- **Sub-index recursion with prune**: `/doc-harness check` §1.4 now correctly handles nested `FILE_INDEX.md` files without false-positive ghost entries at parent indexes.
- **Version-drift detection**: `<!-- doc-harness-ops-start/end -->` sentinels delimit the embedded operational-rules region; check §1.10 reads the version tag and flags stale embeddings after a skill upgrade. Re-embed safely replaces only the delimited region, preserving any custom iron rules below it.
- **Pause/resume decision tree (§6.4)**: three paths — orderly, emergency (mid-transition), auto-resume with a ≤7d / 8–30d / >30d boundary. Auto-resume runs §6.3.1 first.
- **Inbox filename disambiguator**: §14.3 adds an `HHMMSS` suffix for same-day collisions and an `-<N>` counter for sub-second collisions.
- **Pre-send verification**: §14.3.1 requires senders to confirm the recipient has adopted the inbox/outbox protocol before writing; failed deliveries are recorded in the sender's CURRENT_STATUS.
- **Driving-manual review ritual (§6.2.2)**: five questions to apply to each phase-level principle at transition — promote / keep / reword / remove.
- **Quantified context-awareness threshold**: §11.2 bullet 4 now defines "substantial unsaved work" concretely.
- **Language-independent check.md**: anchors match either English or Chinese headings produced by `init` templates.
- **Skill-creator structural pass**: pushier SKILL.md description for better triggering; TOC at top of spec.md; explicit `Edit` in allowed-tools; the car metaphor is now explained narratively in §3.1.

## License

[MIT](LICENSE)

## Credits

Designed and built through iterative human-AI collaboration, with blind testing by independent agents, architectural review, stress-test simulation, and real-world project validation.
