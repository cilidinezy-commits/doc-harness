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

#### v1.4 comprehensive release: six-review audit, 30 issues closed (2026-04-19)

After v1.3 shipped, user requested self-review (3 issues). User pivoted from the planned v1.3.1 patch to a comprehensive v1.4 intended to fix **all found and potential issues**. Total process: six review cycles.

**Review cycle summary**:
1. **Self-review**: 3 issues (§14.5 filename typo, WhoAMI inbox still unread, 项目群 mistranslation).
2. **Agents A + B** (first third-party pair): Agent A (internal consistency) found 3 critical + design gaps; Agent B (user-facing doc review) surfaced retrofit-path discoverability, missing v1.2→v1.3 reversal note, worked-example gap.
3. **Agents C + D** (scenario-driven pair): Agent C (onboarding) surfaced upgrade path, language install collision, init mid-project branch, zero-args dispatcher, FAQ gaps; Agent D (lived-project) surfaced 10+ operational gaps (mid-transition, WORKLOG quarter boundary, malformed handling, collision resolution, archival trigger, version drift, sub-index recursion, principle ambiguity, check.md language-dependency).
4. **Agents E + F** (final v1.4 design-integrity pair): Agent E identified 6 post-draft issues (bash prune, install path resolution, §6.4 ordering, §6.3.1 ambiguity, ops-rules archival gap, §14.8 `to:`); Agent F identified 10 scenario gaps (⏸️ row in table, sub-second collision, pre-send verification, `_malformed/` exclusion, unchanged/rewrite conflict, re-embed sentinels, mid-project override, cross-quarter scar, and more).
5. **skill-creator structural review**: pushier SKILL.md description, spec TOC, `Edit` in allowed-tools, car-metaphor narrative explanation.
6. User prompt surfaces a 6th mid-v1.4 addition: expand §3.1 to narratively explain the car metaphor (tire tracks / car body / headlights / driving manual as four questions an agent asks on arrival).

**30 distinct issues** closed in v1.4 — see spec.md Version History v1.4 row for the complete list with labels B1–B8 (content/quick fixes), P1–P12 (design additions), plus the structural and integrity items.

**Major design artifacts introduced in v1.4**:
- §6.2.1 stepwise failure table (Step 1–5 signatures + per-step repair)
- §6.2.2 driving-manual review ritual as 5-question checklist with "semantic intent unchanged" criterion
- §6.3.1 mid-transition three-way coherence table (6 rows + ⏸️ row + footnote + zero-progress note)
- §6.4 three-path pause/resume (orderly / emergency / auto-resume) with ≤7d / 8–30d / >30d decision tree and §6.3.1 as mandatory repair gate
- §14.3 HHMMSS disambiguator + sub-second `-<N>` counter
- §14.3.1 pre-send verification (sender must confirm recipient adoption via 3 checks before writing)
- §14.8 malformed-message handling with `inbox/_malformed/` quarantine and 8-row classification table
- `<!-- doc-harness-ops-start -->` / `<!-- doc-harness-ops-end -->` sentinels delimiting the embedded region in CLAUDE.md so re-embeds don't clobber custom content
- `<!-- doc-harness-ops-version: 1.4 -->` version tag read by `/doc-harness check` §1.10
- check.md §1.4 recursive sub-index audit **with prune at sub-index boundaries** (Agent E's key finding)
- check.md §1.7 four sub-checks (unread + archival-due + malformed count + recent-outbox logged)
- check.md §1.8 language-independent car-body anchor (matches English OR Chinese)
- check.md §1.9 mid-transition coherence (mirrors spec §6.3.1)
- check.md §1.10 ops-rules version drift with full 4-path install-path resolution (project-local / ~/.claude / XDG / Windows)
- §5.5 quarter-boundary rule (archive by end date, don't split), archive↔WORKLOG backlinks, cross-quarter scar, atomic-commit git convention
- §11.2 bullet 4 quantified "substantial" threshold (a: ≥3 `####` steps; b: ≥50 lines added; c: car body ≥100 lines)
- §3.1 car metaphor expanded into narrative form (tire tracks / car body / headlights / driving manual → four questions an arriving agent asks)
- operational_rules.md archival section catches up to spec §5.5 (quarter-boundary, backlinks, git convention)
- SKILL.md description rewrite for triggering (implicit user phrases alongside explicit slash commands)
- spec.md gains TOC at top for 1320-line navigation

**Bilingual sync** (iron rule 1): all changes mirrored into `skill-zh/`. Exact line counts: spec 1320 (en) / 1315 (zh); operational_rules 180 / 180; check 278 / 278; init 221 / 218; SKILL 58 / 58.

**Self-application**: CLAUDE.md phase → v1.4; Recovery Chain unchanged (already two-layer); operational rules row in Key Technical Info refreshed; FILE_INDEX dates bumped. `PARKING_LOT.md` deleted (nothing parked — v1.4 closed every item). Inbox: both messages marked `actioned`.

**Skill-creator consultation**: `skill-creator:skill-creator` loaded and applied as the final structural review gate. Its guidance drove the description rewrite, TOC, and tool-list update. All recommendations applied.

**Pending**: commit + tag v1.4 + push + deploy to both installed copies.

---

#### v1.3 addition: context-aware update cadence (2026-04-19)

User prompted late in v1.3: should Doc Harness guide agents to monitor remaining context window and pre-emptively flush to files before compression? Accepted — fits naturally with "write it down or lose it." Added a 4th bullet to `spec.md §11.2` ("During Work") and the corresponding section of `operational_rules.md`, in both languages. Rule is platform-conditional: only applies if the runtime exposes context-usage metrics. Threshold suggested at ~<20% remaining. Action: update CURRENT_STATUS before the next tool call; if the car body holds substantial unsaved work, trigger a phase transition immediately rather than wait for the next "meaningful step" that may never land.

README v1.3 FAQ entry updated with this bullet. DOC_HARNESS_SPEC.md re-synced (1140 lines).

#### v1.3.1 patch: four-reviewer audit response (2026-04-19)

After v1.3 shipped, user requested self-review. Initial pass found 3 issues. User then asked for two third-party reviews (code-reviewer + general-purpose) in parallel, then two more scenario-driven reviews (onboarding + lived-project) in parallel. **Total of 16 issues surfaced across four independent reviewers plus the self-review.**

**v1.3.1 addresses 8 of the 16** — pure documentation / sync / consistency fixes:

- **B1** (iron rule 1 violation): `skill-zh/operational_rules.md` gained the inbox/outbox section that was absent — English had lines 152–170, Chinese ended at 151.
- **B2** (spec internal contradiction): `§14.5` car body template previously showed `outbox/YYYY-MM-DD-to-<target>-<topic>.md` but `§14.3` defines filenames as always `from-<source>`. Corrected in both languages and DOC_HARNESS_SPEC.md. Added a clarifying parenthetical.
- **B3** (upgrade path undocumented): README gained a 4-step **Upgrading from an earlier version** section. Key point documented: embedded `operational_rules` in existing CLAUDE.md files are snapshots taken at `init` time and do NOT auto-update when the skill is upgraded — user must replace the section manually.
- **B4** (default-language contradiction): English README said `skill/` was default; Chinese README said `skill-zh/` was default. Both install to the same path (`~/.claude/skills/doc-harness/`) and cannot coexist. Text updated in both to "install one; pick the language that matches your project documentation language."
- **B5** (v1.2→v1.3 reversal not noted): Readers of v1.2 saw "Doc Harness deliberately does NOT include inbox/outbox." v1.3 FAQ now explicitly notes this decision was reversed and points to Appendix E for rationale.
- **B6** (Chinese mistranslation): `README_zh` said `规范中移除了"项目群"框架` — but 项目群 is still the spec's preferred term for flat peer groups (§10.2, retained). Only the hierarchical *portfolio* concept was removed. Fixed to `规范中移除了层级化的"portfolio（项目组合）"框架`.
- **B7** (mid-project adoption path): `init.md` Step 2 previously said "if CLAUDE.md exists, warn." Now branches into 4 cases: (a) clean directory → clean init; (b) Doc Harness present → don't overwrite, suggest check; (c) non-empty directory without Doc Harness → mid-project adoption per spec §10.3; (d) partial state → complete the missing files in mid-project mode.
- **B8** (no-args dispatcher partial state): SKILL.md `/doc-harness` no-args now handles three cases — all core files present (→ check), none present (→ init), partial state (→ init in mid-project mode; do NOT suggest check on a broken installation).

**8 design gaps parked** in new `PARKING_LOT.md` at project root (first use of the v1.2 optional document in this project):

- P1 Mid-phase-transition interruption detection
- P2 Inbox filename collision / disambiguator
- P3 Malformed inbox message handling
- P4 30-day actioned-message archival trigger
- P5 WORKLOG archival: phases spanning quarter boundaries
- P6 `check.md` language-dependency (headings hardcoded per language)
- P7 `check.md` sub-index recursion not implemented
- P8 `check.md` has no spec-version drift detection

Plus 4 polish items (P13–P16). Each entry names revival preconditions and re-check dates.

**Spec**: `spec.md` Version History gains v1.3.1 row in both languages. `DOC_HARNESS_SPEC.md` re-synced from `skill/spec.md`.

**Inbox housekeeping**: both inbox messages (SMSS 2026-04-18, WhoAMI 2026-04-19) moved from `unread/read` → `actioned` since all their content has been implemented across v1.2 + v1.3 + v1.3.1.

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
