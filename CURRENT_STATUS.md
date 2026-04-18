# CURRENT_STATUS — Doc Harness

**Last updated**: 2026-04-19
**Current phase**: v1.4 pre-commit (⏳)

---

## Recent Completed (Tire Tracks)

### Phase 2: Independent Project Setup (2026-04-03)
Migrated from `project_reorganization/github-repo/` to standalone `D:\Projects\doc-harness\`. Doc Harness self-applied. Installed at user-level and ObsVault_Tools project-level. v1.1 stable on GitHub; community submissions active. Detailed record in WORKLOG.md § Phase 2.

### Phase 1: Design, Development, Publishing (2026-04-01 ~ 2026-04-03)
Full lifecycle in project_reorganization: spec v0.1→v1.0→v1.1, /doc-harness skill with init+check, 5 test rounds, GitHub publish, bilingual sync, 6 real-world applications. Detailed record in WORKLOG.md § Phase 1.

---

## Current Work (Car Body)

### Phase Goal

Deliver v1.2 and v1.3 of Doc Harness skill files. v1.2 scope: Recovery Chain two-layer + self-contained; WORKLOG archival; optional PARKING_LOT/PHILOSOPHY. v1.3 scope (reversal from v1.2): inbox/outbox IS an optional Doc Harness feature (Chapter 14); "portfolio" language purged. Apply both to doc-harness own docs and ship.

### Completed Steps

#### Git baseline committed (2026-04-19)
- Committed Phase 2 self-apply docs (CLAUDE.md / CURRENT_STATUS.md / DOC_HARNESS_SPEC.md / FILE_INDEX.md / WORKLOG.md) that had been uncommitted since 2026-04-03 — commit `92e5358`.
- Committed inbox/ messages as traceable motivation for v1.2 — commit `d54f63d`.
- Pushed to GitHub master.

#### v1.2 design finalized (2026-04-19)
- Accepted: Recovery Chain two-layer (must-read ≤3 + task-conditional + self-contained meta-rule); WORKLOG archival at ~1000 lines with quarterly archives; optional PARKING_LOT.md and PHILOSOPHY.md (Chapter 13).
- Rejected: inbox/outbox as doc-harness element (user-held principle: doc-harness stays agnostic to inter-project communication). Rationale preserved in spec Appendix E FAQ.
- Rejected: VISION.md (role already served by CLAUDE.md Project Overview + Iron Rules).
- Rejected: dedicated "not-an-optional-doc" section in spec (defining by negation was dead weight; concept is not introduced, so no defense needed).
- Philosophy rationale (user): universal principles emerge from long-term project practice — forbidding project-level PHILOSOPHY severs principle from origin.

#### Skill files updated — English (`skill/`) (2026-04-19)
- `spec.md` v1.1 → v1.2: Chapter 2.3 Recovery Chain template rewritten (two layers + meta-rules); new §5.5 WORKLOG Archival; §11.1 Session Start replaced with "Applying Recovery Chain"; §11.3 Session End adds WORKLOG length item; Chapter 12 Anti-patterns adds three rows (self-contained dep, must-read bloat, WORKLOG bloat); new Chapter 13 Optional Long-Horizon Documents (§13.1 PARKING_LOT, §13.2 PHILOSOPHY); new Appendix E Design Choices (FAQ including inbox/outbox rationale); Appendix B updated; Version History gains v1.1 and v1.2 entries.
- `operational_rules.md`: WORKLOG archival subsection; "Session Start" → "Recovery Chain" with two layers; Session End checklist adds WORKLOG-length item; new "Optional Long-Horizon Documents" section at end.
- `SKILL.md`: five mandatory docs + two optional docs clarification.
- `init.md`: CLAUDE.md template Recovery Chain switched to two-layer.
- `check.md`: new §1.6 WORKLOG length check (old §1.6 renumbered to §1.7); new §2.5 Recovery Chain health; output format updated.

#### Skill files mirrored — Chinese (`skill-zh/`) (2026-04-19)
- All five files mirrored to v1.2 per iron rule 1 (bilingual sync).

#### DOC_HARNESS_SPEC.md re-synced (2026-04-19)
- Copied `skill/spec.md` → `DOC_HARNESS_SPEC.md` at project root (987 lines, v1.2).

#### v1.3 design: inbox/outbox reversal (2026-04-19)
- User reversed earlier v1.2 stance: inbox/outbox IS an optional Doc Harness feature.
- Rationale: "inter-project communication must not depend on anything outside the project."
- New Chapter 14 in spec: self-contained inbox/outbox protocol (folders, YAML frontmatter, lifecycle unread→read→actioned, archival, retrofit). DOC_HARNESS_SPEC.md re-synced (1139 lines, v1.3).

#### v1.3 "portfolio" purge (2026-04-19)
- User: "portfolio is a remnant of v1 thinking." Projects are flat self-contained peers.
- Removed all "portfolio-level" / "portfolio-wide" language from spec.md and operational_rules.md (both languages). Replaced with "sibling project," "project group," neutral framing.

#### v1.3 skill files updated — English (2026-04-19)
- `spec.md`: v1.3 — Chapter 14 (inbox/outbox), portfolio language purged, §13.3 removed.
- `operational_rules.md`: new "Optional Inter-Project Communication" section; "portfolio" purged.
- `init.md`: Step 3.6 (optional inbox/outbox setup); Step 4 verification updated.
- `check.md`: §1.7 inbox status (new); §1.8 car body (renumbered); §2.6 session-end checklist (was duplicate §2.5); §2.5 Recovery Chain health.
- `SKILL.md`: optional inbox/outbox mechanism listed.

#### v1.3 skill files mirrored — Chinese (2026-04-19)
- `skill-zh/check.md`: §1.7 收件箱状态; §1.8 车身长度; §2.6 session结束清单; output format.
- `skill-zh/init.md`: Step 3.6 (跨项目通信设置); Step 4 verification; inbox optional info in Step 1.
- `skill-zh/SKILL.md`: optional inbox/outbox mechanism listed.
- `skill-zh/operational_rules.md`: "portfolio" purged (done in v1.2 pass).
- `skill-zh/spec.md`: full Chapter 14 + portfolio purge (done in v1.2 pass).

#### v1.3 self-application: doc-harness project docs updated (2026-04-19)
- `CLAUDE.md`: phase → v1.3 development; inbox task-conditional in Recovery Chain; Iron Rule 6 (inter-project comms block).
- `FILE_INDEX.md`: Inter-Project Communication category updated (references Chapter 14).
- README.md / README_zh.md: v1.2 FAQ corrected (removed erroneous inbox exclusion); v1.3 FAQ entry added.

#### v1.3 addition: context-aware update cadence (2026-04-19)
- User prompted: should agents monitor remaining context window and adjust doc-update frequency accordingly?
- Accepted: added a 4th bullet to "During Work" in both `spec.md §11.2` and `operational_rules.md` (English + Chinese). Rule is platform-conditional — only applies if the runtime exposes context-usage metrics. Threshold: ~<20% remaining → immediate CURRENT_STATUS update before next tool call; consider phase transition if car body substantial.
- Rationale: compression is involuntary session end; "write it down or lose it" principle extends naturally to "write it down *before* it's too late."
- README FAQ v1.3 entry updated with this bullet. DOC_HARNESS_SPEC.md re-synced (1140 lines).

#### v1.4 comprehensive release: six-review audit closed (2026-04-19)

**Process**: after shipping v1.3, user requested self-review (3 issues). User then pivoted from v1.3.1 patch to a comprehensive v1.4 that fixes **everything found AND potential**. Spawned two more review agents to probe v1.4 after substantial design work, then invoked `skill-creator` for a structural pass.

**Six review cycles surfaced 30 distinct issues**:
- Self-review: 3 (§14.5 filename typo, WhoAMI inbox unread, 项目群 mistranslation)
- Agent A (internal consistency): added missing Chinese inbox section + 2 integrity issues
- Agent B (user-facing): v1.2→v1.3 reversal note missing, retrofit path not discoverable, worked example, decision criteria
- Agent C (onboarding scenarios): upgrade path undocumented, language install collision, `init.md` mid-project branch missing, etc.
- Agent D (lived-project scenarios): mid-transition detection, WORKLOG quarter boundary, malformed handling, collision resolution, archival trigger, version drift, sub-index recursion, etc.
- Agent E (v1.4 design integrity): §1.4 bash double-counts; §1.10 Windows path + project-level install; §6.4 ordering bug; §6.3.1 table ambiguity; operational_rules archival gap; §14.8 `to:` field
- Agent F (v1.4 scenario gauntlet): emergency-pause ⏸️ not in table; §1.4 sub-index prune; HHMMSS sub-second collision; install-path resolution; cross-quarter scar; pre-send verification; §1.7 `_malformed/` exclusion; "unchanged" vs "rewrite" conflict; re-embed sentinels; mid-project override escape
- skill-creator structural: pushier description, spec TOC, `Edit` in allowed-tools, car metaphor narrative

**All 30 closed in v1.4**. Spec grew from 1140 → 1320 lines; operational_rules 171 → 180; check.md 201 → 278; SKILL.md expanded frontmatter. Bilingual parity preserved throughout.

**Key design artifacts added**:
- §6.3.1 mid-transition three-way coherence table (6 rows + footnote + zero-progress note)
- §6.2.1 stepwise failure table (Step 1–5 signatures + repair per step)
- §6.2.2 driving-manual review ritual (5-question checklist)
- §6.4 three-path pause/resume (orderly / emergency / auto-resume decision tree)
- §14.3 HHMMSS + sub-second `-<N>` counter
- §14.3.1 pre-send verification (3-step protocol before writing to recipient inbox)
- §14.8 malformed-message classification table (8 rows)
- `<!-- doc-harness-ops-start/end -->` sentinels in operational_rules.md
- check.md §1.4 recursive audit with sub-index prune
- check.md §1.7 four sub-checks (unread + archival-due + malformed + outbox-logged)
- check.md §1.9 mid-transition coherence (mirrors §6.3.1)
- check.md §1.10 version drift + 4-path install resolution

**Self-application**: CLAUDE.md, CURRENT_STATUS, WORKLOG all updated. `PARKING_LOT.md` deleted (nothing parked since v1.4 closes all). FILE_INDEX updated.

**Inbox housekeeping**: both prior inbox messages (SMSS + WhoAMI) marked `actioned` since all their content is implemented.

### Unresolved Issues

(None — all within scope)

---

## Next Steps (Headlights)

### Immediate Actions

1. [DONE] Commit v1.3 — `bc8637d` on master; tag `v1.3` pushed.
2. [DONE] v1.4 comprehensive release drafted (30 fixes).
3. Commit v1.4; tag `v1.4`; push master + tag.
4. Deploy sync v1.4: copy `skill/` → `~/.claude/skills/doc-harness/` and `C:\Users\ZY\Documents\ObsVault_Tools\.claude\skills\doc-harness\`.
5. Smoke-test: run `/doc-harness check` on a live project to verify v1.4 check.md logic (§1.4 sub-index recursion, §1.9 mid-transition, §1.10 version drift). Defer to next session working in a sister project.

### Future Plans

- Field-test v1.3 in 1–2 projects over the coming weeks; collect drift/rough-edge reports via inbox.
- Monitor GitHub issues and community PRs.
- Possible v1.4 directions: WORKLOG archival automation trigger; FILE_INDEX auto-generation script.

---

## Current Working Principles (Driving Manual)

- **Bilingual sync is non-negotiable** (iron rule 1). Every English edit must land in Chinese in the same session. Don't defer.
- **Test before release** (iron rule 4). v1.2 applies itself before v1.2 ships — dogfooding is the smoke test.
- **Deployment sync is three places**: dev source → GitHub → installed copies (user-level + ObsVault_Tools). Missing any one produces inconsistent behavior.
- **inbox/outbox is opt-in, self-contained, and doc-harness-native.** The mechanism depends only on files inside each project and DOC_HARNESS_SPEC.md — no external spec, no external memory, no portfolio layer needed.
- **Define by what IS, not by what isn't.** If a concept isn't introduced, don't introduce it just to reject it.
- **Projects are self-contained peers.** "Portfolio" thinking was v1 residue; remove it wherever it creeps back in.
