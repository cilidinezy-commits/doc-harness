# WORKLOG — Doc Harness

## Table of Contents
| Phase | Period | Anchor |
|-------|--------|--------|
| Phase 3: v1.2 development | 2026-04-19 | [→](#phase-3-v12-development-2026-04-19) |
| Phase 2: Independent project | 2026-04-03 | [→](#phase-2-independent-project-setup-2026-04-03) |
| Phase 1: Design → publish (in project_reorganization) | 2026-04-01 ~ 04-03 | [→](#phase-1-design-development-and-publishing-2026-04-01--2026-04-03) |

---

## Phase 3: v1.2 development (2026-04-19)

### Summary

Incorporated three structural improvements into the skill driven by real-world feedback from sister projects (WhoAMI + SMSS). Added Recovery Chain two-layer structure with self-contained constraint; added WORKLOG archival rule with ~1000-line threshold; added two opt-in documents (PARKING_LOT.md and PHILOSOPHY.md) for deferred items and principles-from-practice respectively. Explicitly rejected one proposal (inbox/outbox as doc-harness element) and preserved rejection rationale in a new FAQ appendix. Both English and Chinese skill files synced; doc-harness self-applied the new rules before release.

### Detailed Record

#### Git baseline committed (2026-04-19)
Committed two logically separate baselines: Phase 2 self-apply docs (had existed uncommitted since 2026-04-03) as `92e5358`; cross-project inbox messages that motivated v1.2 as `d54f63d`. Pushed to GitHub master.

#### v1.2 design finalized (2026-04-19)

**Accepted** (3 of 4 proposals from WhoAMI 2026-04-19 inbox):
- Recovery Chain two-layer structure (must-read ≤3 + task-conditional + self-contained meta-rule)
- WORKLOG archival (threshold ~1000 lines, quarterly archive files, keep 3 most-recent phases)
- Optional long-horizon documents: PARKING_LOT.md (deferred items) and PHILOSOPHY.md (project-forged principles)

**Rejected** (with rationale preserved):
- inbox/outbox as doc-harness element — user-held principle: doc-harness stays agnostic to inter-project communication concerns. Those directories when they appear belong to a separate spec (`D:\Projects\docs\INTERPROJECT_COMM_SPEC.md`).
- VISION.md — role already served by CLAUDE.md Project Overview + Iron Rules sections.
- A spec "not-an-optional-document" subsection explaining VISION's absence — defining by negation is dead weight; if the concept isn't introduced, no defense is needed.

**Design call — threshold**: WORKLOG archival at **1000 lines** (not 2000). Cost of reading: 1000 lines is ~10-20K tokens, which is noticeable; 2000 lines is a hard punch. WhoAMI's 1500-line WORKLOG surfaced this pain, so threshold should catch that case.

**Design call — PHILOSOPHY location**: project-level PHILOSOPHY.md, not purely portfolio-level. Rationale (user-held): generalizable principles are forged by specific project practice; forbidding project-level records severs principle from origin. PHILOSOPHY.md can promote entries upward (portfolio PRINCIPLES or parent CLAUDE.md) without losing the birthplace record.

#### Skill files updated — English (`skill/`)

- **spec.md** v1.1 → v1.2:
  - Chapter 2.3: CLAUDE.md template's Recovery Chain section rewritten to two-layer structure + meta-rules (self-contained, living).
  - New §5.5 WORKLOG Archival with concrete trigger, procedure, naming, and non-goals.
  - §11.1 renamed "Session Start — Applying Recovery Chain" and rewritten to match two-layer logic.
  - §11.3 Session End checklist adds WORKLOG-length item.
  - Chapter 12 Anti-patterns: added three rows (Recovery Chain references agent-side features; must-read layer past 3 entries; WORKLOG past ~1000 lines untouched).
  - New Chapter 13 Optional Long-Horizon Documents — §13.1 PARKING_LOT (purpose, when, entry format, lifecycle, Recovery Chain integration) and §13.2 PHILOSOPHY (same, plus promotion pipeline).
  - New Appendix E Design Choices (FAQ) with 4 entries including the inbox/outbox rationale.
  - Appendix B Quick Checklist adds WORKLOG-length item.
  - Version History gains v1.1 and v1.2 entries.
- **operational_rules.md**: WORKLOG archival subsection added; "Session Start" replaced with two-layer "Recovery Chain"; Session End checklist adds WORKLOG-length item; new "Optional Long-Horizon Documents" closing section.
- **SKILL.md**: five mandatory + two optional docs clarification.
- **init.md**: CLAUDE.md Recovery Chain template switched to two-layer structure.
- **check.md**: new §1.6 WORKLOG length check (renumbered old §1.6 to §1.7); new §2.5 Recovery Chain health; output format updated.

#### Skill files mirrored — Chinese (`skill-zh/`)

All five files (SKILL.md, operational_rules.md, init.md, check.md, spec.md) mirrored to v1.2 per iron rule 1 (bilingual sync). Terminology: 恢复链 / 必读 / 任务条件读 / 自含 / 归档 / 可选长期文档 / PARKING_LOT / PHILOSOPHY.

#### Interim fix during design (2026-04-19)

User caught §13.3 "What is NOT an optional long-horizon document" — a spec subsection explaining why VISION isn't included. Rationale accepted: if VISION isn't introduced anywhere else, defining-by-negation reintroduces the concept. Removed from both English and Chinese spec. Root DOC_HARNESS_SPEC.md re-synced. Principle promoted to driving manual: "Define by what IS, not by what isn't."

#### DOC_HARNESS_SPEC.md re-synced (v1.2)

Copied `skill/spec.md` → project root `DOC_HARNESS_SPEC.md` (987 lines after §13.3 removal).

#### v1.3 addendum: inbox/outbox reversal (2026-04-19)

User reversed the v1.2 inbox/outbox rejection: "可以考虑做为本机能的一个选项" — cross-project communication can be an optional Doc Harness feature. Design constraint: "不应该依赖于项目之外的东西" — must be fully self-contained, no external spec references.

Built Chapter 14 (Optional Inter-Project Communication) in spec.md with:
- Complete sending/receiving lifecycle and message format
- Recovery Chain integration (task-conditional entry)
- Archival rule (30-day actioned messages → inbox/_archive/)
- Retrofit procedure for existing projects
- Appendix E FAQ updated (removed inbox exclusion rationale; added new entry explaining why it IS optional)

Updated operational_rules.md: new "Optional Inter-Project Communication" section with receiving/sending rules and snapshot-over-pointers principle.

DOC_HARNESS_SPEC.md re-synced (1139 lines, v1.3).

#### v1.3 addendum: "portfolio" purge (2026-04-19)

User: "考虑去掉所谓的portfolio，那是第一个版本的残留思想" — portfolio concept was v1 residue from project→sub-project hierarchy thinking. Each project is self-contained; a parent navigation file is an optional lightweight pattern, not a doc-harness concept.

Removed all "portfolio-level" / "portfolio-wide" language from spec.md and operational_rules.md in both languages. Replaced with "sibling project," "project group," or neutral framing. PHILOSOPHY.md section updated: principles can be shared to sibling projects, not "promoted to portfolio level."

#### v1.3 addendum: skill files updated — English and Chinese (2026-04-19)

English skill files:
- `check.md`: §1.7 inbox status (new); §1.8 car body (renumbered from §1.7); §2.5 Recovery Chain health (new); §2.6 session-end checklist (was duplicate §2.5); output format updated.
- `init.md`: Step 3.6 optional inbox/outbox setup (4 sub-steps: create folders, add iron rule block, add Recovery Chain entry, register in FILE_INDEX); Step 4 verification updated.
- `SKILL.md`: optional inbox/outbox mechanism listed alongside PARKING_LOT and PHILOSOPHY.

Chinese skill files (mirrored per iron rule 1):
- `skill-zh/check.md`: §1.7 收件箱状态; §1.8 车身长度; §2.6 Session结束清单; output format.
- `skill-zh/init.md`: Step 3.6 with full Chinese translation; Step 1 optional info; Step 4 verification.
- `skill-zh/SKILL.md`: optional inbox/outbox mechanism in Chinese.
- `skill-zh/operational_rules.md` and `skill-zh/spec.md`: already mirrored in v1.2 pass; portfolio language and Chapter 14 already applied.

#### v1.3 self-application: project docs updated (2026-04-19)

- `CLAUDE.md`: phase → v1.3; Recovery Chain adds inbox task-conditional; Iron Rule 6 added (inter-project comms block verbatim from init.md template).
- `CURRENT_STATUS.md`: phase → v1.3; car body updated with all v1.3 steps; headlights → commit+deploy+smoke-test.
- `FILE_INDEX.md`: Inter-Project Communication category updated to reference Chapter 14.
- `README.md` / `README_zh.md`: v1.2 FAQ bullet corrected (removed erroneous exclusion of inbox/outbox); v1.3 FAQ entry added.

#### v1.3 addition: context-aware update cadence (2026-04-19)

User prompted late in v1.3: should Doc Harness guide agents to monitor remaining context window and pre-emptively flush to files before compression? Accepted — fits naturally with "write it down or lose it." Added a 4th bullet to `spec.md §11.2` ("During Work") and the corresponding section of `operational_rules.md`, in both languages. Rule is platform-conditional: only applies if the runtime exposes context-usage metrics. Threshold suggested at ~<20% remaining. Action: update CURRENT_STATUS before the next tool call; if the car body holds substantial unsaved work, trigger a phase transition immediately rather than wait for the next "meaningful step" that may never land.

README v1.3 FAQ entry updated with this bullet. DOC_HARNESS_SPEC.md re-synced (1140 lines).

---

## Phase 2: Independent Project Setup (2026-04-03)

### Summary
Migrated from `project_reorganization/github-repo/` to `D:\Projects\doc-harness\` as standalone project. Applied Doc Harness to self. No code changes — purely organizational.

### Details
- Copied `D:\Projects\project_reorganization\github-repo\` → `D:\Projects\doc-harness\` (with .git history preserved)
- Created CLAUDE.md, CURRENT_STATUS.md, FILE_INDEX.md, WORKLOG.md, DOC_HARNESS_SPEC.md
- Documented deployment relationship (dev source → GitHub → installed copies)
- Iron rules established: bilingual sync, adapt-to-project, spec-authoritative, test-before-release, deployment-sync

---

## Phase 1: Design, Development, and Publishing (2026-04-01 ~ 2026-04-03)

### Summary
Complete lifecycle executed within the `project_reorganization` project. From initial concept to published v1.1 with 6 real-world applications.

### Milestone Timeline
| Date | Milestone |
|------|-----------|
| 04-01 | Spec v0.1 drafted (9 chapters + 2 appendices) |
| 04-02 | Three-way review (practical/architect/stress-test) → v0.2 → v1.0 |
| 04-02 | Skill developed: /doc-harness (init + check), 5 rounds of testing |
| 04-02 | GitHub publish (cilidinezy-commits/doc-harness), README 4 iterations |
| 04-02 | Chinese version (skill-zh/) created and synced |
| 04-02 | Applied to journal_ch5, WhoAMI, lit_review |
| 04-02 | BH_AgentsModel deep application, lit_review quality refinement |
| 04-02 ~ 03 | ZY_DoctorThesis (1504 files), notes/ sub-index (126 files) |
| 04-03 | v1.1: 10 improvements analyzed → 7 kept, 3 dropped → implemented |
| 04-03 | Backup notices at old locations, MEMORY.md updated |

### Key Design Decisions
- "Write It Down or Lose It" as first principle (user insight: context info is ephemeral)
- "Moving car" metaphor for CURRENT_STATUS (tire tracks / car body / headlights / driving manual)
- Two-level principles: project iron rules (permanent) + phase driving manual (temporary)
- 5-step phase transition protocol (data protection first)
- Spec as two versions: operational (~110 lines, embedded) + complete (~830 lines, reference)

### v1.1 Improvements
- 7 implemented: mid-project adoption, SUPERSEDED-but-retained, spec check, FILE_INDEX script, phase coherence, adapt-to-project, sub-index guidance
- 3 dropped after deep analysis: car body threshold (wrong metric), completed-project template (adds complexity), small-project lite rules (consistency > brevity)

Full details: `D:\Projects\project_reorganization\WORKLOG.md` §阶段2-7
