# CURRENT_STATUS — Doc Harness

**Last updated**: 2026-04-19 晚
**Current phase**: Phase 4 — Maintenance & field-feedback watch (⏳ active — one patch landed)

---

## Recent Completed (Tire Tracks)

### Phase 3: v1.2 → v1.3 → v1.4 + publishing (2026-04-19)
v1.2 (Recovery Chain two-layer, WORKLOG archival, optional PARKING_LOT/PHILOSOPHY) → v1.3 (reversed v1.2's inbox/outbox exclusion; Chapter 14 self-contained cross-project messaging; portfolio language purged) → v1.4 (six-review audit, 30 issues closed; mid-transition detection §6.3.1, malformed-message quarantine §14.8, auto-resume tree §6.4, quantified thresholds, sentinels for safe re-embed, language-independent check.md). Shipped as Claude Code plugin marketplace (`/plugin marketplace add cilidinezy-commits/doc-harness`); smoke-tested; submitted to awesome-claude-code + two catalog sites. Detailed record in WORKLOG.md § Phase 3.

### Phase 2: Independent Project Setup (2026-04-03)
Migrated from `project_reorganization/github-repo/` to standalone `D:\Projects\doc-harness\`. Doc Harness self-applied. Installed at user-level and ObsVault_Tools project-level. v1.1 stable on GitHub; community submissions active. Detailed record in WORKLOG.md § Phase 2.

### Phase 1: Design, Development, Publishing (2026-04-01 ~ 2026-04-03)
Full lifecycle in project_reorganization: spec v0.1→v1.0→v1.1, /doc-harness skill with init+check, 5 test rounds, GitHub publish, bilingual sync, 6 real-world applications. Detailed record in WORKLOG.md § Phase 1.

---

## Current Work (Car Body)

### Phase Goal

**Maintenance & field-feedback watch.** v1.4 is shipped and published; installation paths are verified; community catalogs notified. Building on Phase 3's delivery, this phase holds until real-world signal accumulates enough to justify v1.5. No active design or spec work planned.

### Completed Steps

#### v1.4.1 patch — §5.5 WORKLOG archival filename correction (2026-04-19)

First field-feedback hit of Phase 4. User (also the author) flagged that the v1.2 quarterly-bin archive filename (`WORKLOG_ARCHIVE_<YYYY-QN>.md`) grows unbounded for high-density projects — a project writing 5,000 lines/quarter puts all 5,000 lines into one "archive," defeating the purpose. Corrected to per-event date naming (`WORKLOG_ARCHIVE_<YYYY-MM-DD>.md`), which keeps each archive bounded by the ~1000-line trigger.

Changes made (7 files):
- `skill/spec.md` §5.5 (procedure rewritten; step 2 filename change; cross-quarter scar step removed; new step 7 logging archival in CURRENT_STATUS; git commit message updated; version bumped to v1.4.1 + new version-history row); TOC chapter 5 description adjusted.
- `skill/operational_rules.md` mirror-updated; version tag `<!-- doc-harness-ops-version: 1.4.1 -->`.
- `skill-zh/spec.md` and `skill-zh/operational_rules.md` — full Chinese mirror.
- `README.md` and `README_zh.md` — v1.2 FAQ entry amended with v1.4.1 note.
- `DOC_HARNESS_SPEC.md` re-synced from `skill/spec.md`.

Committed + pushed to GitHub. Plugin marketplace consumers will get v1.4.1 via `/plugin marketplace update doc-harness`.

Side observation (worth keeping as a driving-manual principle, see below): The Phase 4 rule "don't iterate without real user signal" worked — this is exactly the signal pattern it was waiting for. Decision on v1.5 aggregation remains: 1 of ≥3 real-world issues logged. Does not trigger v1.5 on its own.

### Unresolved Issues

(None.)

---

## Next Steps (Headlights)

### Immediate Actions

No active work items. Revisit when any of the v1.5 triggers (see Driving Manual below) fires.

### Future Plans

- Opportunistic: when working in a sister project (WhoAMI, ZY_DoctorThesis, etc.), run `/doc-harness check` and note what v1.4's new audits (§1.4 sub-index recursion, §1.7 four sub-checks, §1.9 mid-transition, §1.10 version drift) surface on real v1.1-era data. Any finding becomes a car body entry.
- Watch GitHub issues at `cilidinezy-commits/doc-harness` and the awesome-claude-code / claudemarketplaces / claudepluginhub listings for user feedback.
- Consider writing the project's first `PHILOSOPHY.md` entry about the six-review-cycles pattern. Each cycle's distinct angle surfaced issues the earlier cycles structurally could not — the sequence matters as much as the count. Useful principle for future spec work here or in sibling projects.

---

## Current Working Principles (Driving Manual)

*(Reviewed at phase transition per §6.2.2. Phase 3 principles that duplicated iron rules — bilingual sync, test before release, deployment sync — were removed since iron rules cover them permanently. Principles that responded to now-resolved constraints — inbox/outbox opt-in rule, portfolio-purge reminder — were removed since the spec now codifies those positions structurally. New principles specific to maintenance mode added below.)*

- **Don't iterate without real user signal.** The v1.4 release extracted most of the latent issues a team of review agents could find through simulation. Further iteration from simulation alone has sharply diminishing returns; next changes should be driven by observed user problems, not hypothetical ones.
- **v1.5 triggers are concrete**: ≥3 distinct real-world issues accumulated from field use, OR a breaking change in Claude Code's plugin system (e.g., marketplace.json schema change), OR a merge/comment on the awesome-claude-code submission that surfaces a needed change. Anything less, stay idle.
- **If a release is triggered, re-run the 6-review pattern.** Don't skip review cycles because the change feels small. The v1.4 process found issues in cycles 5 and 6 that earlier cycles missed structurally, not accidentally.
- **Define by what IS, not by what isn't.** (Carried over — applicable whenever new spec text is written. If no spec work, this principle is dormant but cheap to keep.)
