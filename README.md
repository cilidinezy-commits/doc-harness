# Doc Harness

**Document-based project control for AI-human collaboration.**

Doc Harness is a [Claude Code](https://claude.ai/code) skill that helps you and AI agents stay in control of any project — from a research paper to a software build to a data analysis pipeline. It maintains a small set of structured documents that capture everything about your project's state, so that any agent (or you, after a break) can pick up exactly where things left off.

---

## What Problem Does This Solve?

When you work with AI agents on a project over days or weeks, several things go wrong:

**Your AI loses its memory.** AI context windows compress or reset. The agent that spent two hours analyzing your data yesterday doesn't remember any of it today.

**Files multiply without a map.** After a few sessions, your project has 30 files — analysis reports, plans, notes, scripts — and nobody remembers what's where.

**Principles drift.** You establish important rules ("always validate on out-of-sample data"), but as work gets complex, the AI gradually forgets to follow them.

**Handoffs fail.** A different agent arrives and asks "what is this project?" — there's no single place that answers this question.

Doc Harness solves all four by creating a **self-contained documentation system** that any agent can read and immediately understand.

---

## What Is a "Project"?

A **project** is any structured work effort that has a goal, spans multiple sessions, and generates files along the way. Examples: writing a research paper, building a data pipeline, developing a library, conducting a literature review, running experiments.

A project is simply a folder. Inside it, Doc Harness creates its five status documents alongside whatever folders and files your work needs:

```
my-research-project/
├── CLAUDE.md                ← Doc Harness: stable anchor
├── CURRENT_STATUS.md        ← Doc Harness: living pulse
├── FILE_INDEX.md            ← Doc Harness: file catalog
├── WORKLOG.md               ← Doc Harness: permanent archive
├── DOC_HARNESS_SPEC.md      ← Doc Harness: reference manual
│
├── notes/                   ← Your work
│   ├── literature_review.md
│   └── key_findings.md
├── scripts/                 ← Your work
│   ├── analyze_data.py
│   └── generate_figures.py
├── data/                    ← Your work
│   └── sample_data.csv
└── drafts/                  ← Your work
    └── chapter1.tex
```

Doc Harness doesn't dictate how you organize your work — it only asks that every file gets registered in FILE_INDEX so nothing becomes invisible.

---

## The Five Documents: What They Do and Why They Matter

Each document has a distinct role, a different update rhythm, and a different temporal focus. Together they answer every question an agent or collaborator could ask about the project.

### CLAUDE.md — The Stable Anchor

**Answers**: *"What is this project? What are the rules? Where do I start?"*

The first thing any agent reads. Contains:
- **Project overview** (what, why, for whom — 3-5 lines)
- **Recovery chain** (read this → then CURRENT_STATUS → then FILE_INDEX → then WORKLOG)
- **Iron rules** (permanent, non-negotiable constraints — e.g., "always validate on out-of-sample data")
- **Technical info** (build commands, paths, dependencies — things that don't change phase to phase)
- **Operational rules** (the embedded Doc Harness rules that teach agents how to maintain the system)

**How it evolves**: This is the most stable document. It changes only at phase transitions (updating the "current phase" line) and when important lessons become permanent iron rules. The body stays the same for weeks.

**Why it matters**: Without it, every new agent starts from zero. With it, any agent reads one file and knows exactly what this project is, what's forbidden, and where to look next. The embedded operational rules mean the agent automatically knows how to maintain Doc Harness — you don't have to explain the system each time.

---

### CURRENT_STATUS.md — The Living Pulse

**Answers**: *"What just happened? What's happening now? What's next? What should I watch out for?"*

The most dynamic document, organized as a **"moving car"**:

```
┌──────────────────────────────────────────────────────┐
│  🛤️  Tire Tracks   — 2-3 recent completed phases     │
│       Short summaries (3-5 lines each) pointing to    │
│       WORKLOG for full details                        │
│                                                       │
│  🚗 Car Body       — current phase in FULL detail     │
│       Every completed step: what was done, files       │
│       created, decisions made, problems found          │
│                                                       │
│  🔦 Headlights    — what comes next                   │
│       Immediate actions + longer-term plans            │
│                                                       │
│  📋 Driving Manual — this phase's working principles  │
│       Rules that live and die with the current phase   │
└──────────────────────────────────────────────────────┘
```

**How it evolves**: Updated every session. As you work, completed steps are added to the car body. When a phase ends (e.g., "literature review" is done, "data analysis" begins), a **phase transition** occurs:

1. The car body (full details) is copied to WORKLOG — data protected first
2. The car body is compressed to a 3-5 line tire track summary
3. Old tire tracks beyond 3 are removed (they're safe in WORKLOG)
4. The car body clears for the new phase
5. The driving manual updates for new phase principles

This cycle keeps CURRENT_STATUS compact (~200 lines) while nothing is ever lost.

**Why it matters**: This is what makes context recovery possible. An agent whose memory was just wiped reads CURRENT_STATUS and within seconds knows: what was recently finished (tire tracks), what's in progress right now (car body), what to do next (headlights), and what principles to follow (driving manual). No briefing needed, no asking the user "where were we?"

---

### FILE_INDEX.md — The Library Catalog

**Answers**: *"What files exist in this project, what are they, and where are they?"*

Organized by **category**, not by time:

```markdown
## Research Notes
- `notes/literature_review.md` — Survey of 30 papers on price impact
- `notes/key_findings.md` — Cross-paper synthesis of main results

## Scripts
- `scripts/analyze_data.py` — Price impact regression analysis
- `scripts/generate_figures.py` — Publication-quality figure generation

## Data
- `data/sample_data.csv` — 10,000 order book snapshots
```

**How it evolves**: Grows as files are created — every new file gets a one-line entry. Categories are yours to define and can be added anytime. When a category grows beyond 10-20 files, it can have its own sub-index file in its folder to keep things manageable.

**Why it matters**: Without an index, projects become graveyards of forgotten files. You *know* you created that analysis last week, but which file was it? FILE_INDEX eliminates this. The rule is simple: **create a file → register it immediately**. If a file isn't in FILE_INDEX, it might as well not exist.

---

### WORKLOG.md — The Permanent Archive

**Answers**: *"What exactly happened in phase 3? What did we try, what did we find, what files did we create?"*

```markdown
## TOC
| Phase | Time | Anchor |
|-------|------|--------|
| Phase 3: Data Analysis | 2026-03-14~03-28 | [→](#phase-3) |
| Phase 2: Literature Review | 2026-03-01~03-14 | [→](#phase-2) |
| Phase 1: Project Setup | 2026-02-15~03-01 | [→](#phase-1) |

---

## Phase 3: Data Analysis (2026-03-14 ~ 2026-03-28)
### Phase Summary
Completed price impact regression on 10K snapshots. Found concave impact...
### Detailed Record
[Full step-by-step record, copied verbatim from CURRENT_STATUS when phase ended]
```

**How it evolves**: Grows only at phase transitions, when CURRENT_STATUS's car body is copied here in full. A TOC at the top keeps it navigable even after many phases. Content is **append-only** — once written, never modified or deleted.

**Why it matters**: CURRENT_STATUS keeps only 2-3 recent phase summaries to stay compact. WORKLOG is where the complete history lives. Need to recall what you tried three weeks ago in phase 1? It's here, recorded exactly as it happened. This is especially valuable when you need to understand *why* a decision was made or *what* was tried before.

---

### DOC_HARNESS_SPEC.md — The Reference Manual

The complete specification with design rationale, edge cases, worked examples showing all four documents evolving through two phase transitions, and glossary of terms. You rarely need it — the operational rules in CLAUDE.md cover 95% of daily use. The spec is for unusual situations or when you want to understand *why* the system works this way.

---

### Why These Five Work Together

| Document | Updates | Temporal Focus | Question It Answers |
|----------|---------|---------------|-------------------|
| CLAUDE.md | Rarely | Timeless | "What is this project?" |
| CURRENT_STATUS | Every session | Present | "What's happening now?" |
| FILE_INDEX | When files change | Spatial | "Where is everything?" |
| WORKLOG | Phase transitions | Past | "What happened before?" |
| Spec | Never | Reference | "Why does the system work this way?" |

Each fact lives in exactly **one** document (Single Source of Truth), so there are no contradictions. And because the operational rules are embedded in CLAUDE.md, any agent reading it automatically knows how to maintain the entire system.

---

## The Three Commands

### `/doc-harness init` — Set Up a New Project

Run at the beginning of a project. The agent asks about your project (or extracts info from conversation context) and creates all 5 documents, tailored to your specific situation.

```
/doc-harness init MyProject A study of price dynamics in limit order book markets
```

### `/doc-harness check` — Audit and Reflect

Run anytime to verify the documentation is healthy and remind yourself of the rules:

```
/doc-harness check
```

**Part 1 — File audit**: Are all documents present? Is CURRENT_STATUS fresh? Does FILE_INDEX match actual files? Any issues flagged with fix suggestions.

**Part 2 — Principle reflection**: Reads the project's iron rules and driving manual, prompts the agent: *"Am I following these?"* Also runs a "Write It Down" check for unsaved information.

> Tip: Run as a background agent to avoid interrupting main work.

### `/doc-harness` — Help

Shows available commands and suggests `init` or `check` based on whether the project already has Doc Harness.

---

## How to Use It Day-to-Day

### Starting a project

1. Navigate to your project folder in Claude Code
2. Run `/doc-harness init` — answer the agent's questions
3. Start working. The rules are now embedded in CLAUDE.md — every agent that reads it will know what to do.

### During work

The agent follows the operational rules automatically (they're in CLAUDE.md). Key behaviors:
- **Complete a step → update CURRENT_STATUS car body** (one line: what was done, files created)
- **Create a file → register in FILE_INDEX** (one line: path + description)
- **Important insight or decision → write to a file** ("Write It Down or Lose It")
- **Session end → run quick checklist** (status updated? files registered? anything unsaved?)

You don't need to remind the agent — the rules are there every time it reads CLAUDE.md.

### Running a health check

Say to your AI: *"Run a doc-harness check"* or *"Check the status documentation in the background."*

The check will report issues (❌ unregistered files, ⚠️ stale dates) and prompt reflection on working principles. It takes about 2 minutes.

### When phases change

When your work shifts focus (e.g., "finished literature review, starting analysis"), tell the agent or it will recognize the shift. The five-step phase transition runs automatically — data is protected first, then reorganized.

---

## Core Principle: "Write It Down or Lose It"

The single most important rule. AI context is temporary — analysis results, design decisions, important insights, code logic, meeting notes — if it's not in a file, it will vanish when context resets. Better to create one extra file than to lose an hour of thinking.

And writing isn't enough — the file must be **registered in FILE_INDEX**. An unregistered file is invisible to future agents.

---

## Install

```bash
git clone https://github.com/cilidinezy-commits/doc-harness.git
cp -r doc-harness/skill ~/.claude/skills/doc-harness
```

Or project-level (one project only):
```bash
mkdir -p .claude/skills
cp -r doc-harness/skill .claude/skills/doc-harness
```

## Languages

- `skill/` — English (default)
- `skill-zh/` — 中文版

## Requirements

- [Claude Code](https://claude.ai/code) — CLI, desktop app, web app, or IDE extension
- No other dependencies

## FAQ

**Q: Does this work with AI tools other than Claude Code?**
The `/doc-harness` commands are Claude Code specific. But the documentation system itself is universal — any AI that reads markdown can follow the operational rules in CLAUDE.md.

**Q: How much overhead does this add?**
Minimal. One line per completed step, one line per new file. The check takes ~2 minutes and can run in the background.

**Q: Can I customize the structure?**
Yes. Add sections, define your own categories, adjust principles. Core requirements: keep the four documents, follow phase transitions, register files.

**Q: Existing project with many files?**
Run `/doc-harness init`, then populate FILE_INDEX. The agent can help scan and categorize.

**Q: Sub-projects?**
Each gets its own Doc Harness. Parent's FILE_INDEX links to sub-project entries.

## License

[MIT](LICENSE)

## Credits

Designed and built through iterative human-AI collaboration, with blind testing by independent agents, architectural review, stress-test simulation, and real-world project validation.
