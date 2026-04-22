# CURRENT_STATUS — Doc Harness

**Last updated**: 2026-04-22
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

#### v1.5.0 design — sync + flush commands (2026-04-22)

User requested two new commands to fill the gap between `check` (read-only diagnosis) and `init` (creation).

- **`/doc-harness sync`** — Status synchronization. Repairs drift (unregistered files, stale dates), optionally triggers phase transition or WORKLOG archival. Two modes: `auto` (default, no asking) and `interactive` (asks before major changes). Distinct from `check`: sync modifies files; check only reports.
- **`/doc-harness flush`** — Emergency context save. Includes everything sync does, PLUS mandatory extraction of important context information into documents before compression. Core guarantee: after flush, a new agent reading Recovery Chain recovers state as if context was never compressed. Two modes: `auto` (heuristic classification) and `interactive` (asks per item).

**Design artifacts created**:
- `skill/sync.md` (222 lines) — English sync procedure with 5-step workflow
- `skill/flush.md` (261 lines) — English flush procedure with 5-phase workflow (A: sync, B: inventory, C: write/register, D: verification, E: marker)
- `skill-zh/sync.md` (211 lines) — Chinese mirror
- `skill-zh/flush.md` (247 lines) — Chinese mirror
- `skill/SKILL.md` — Command listing and argument-hint expanded
- `skill/spec.md` — §11.5 (sync), §11.6 (flush), Version History v1.5.0
- `skill/operational_rules.md` — Version bumped to 1.5.0; added sync/flush references
- `skill/check.md` — Updated "Write It Down" check to mention flush; added pre-sync/flush to "When to use"
- Same 5 files mirrored in `skill-zh/`

**Completed**: All design artifacts, English skill files, Chinese mirrors, project root doc updates, DOC_HARNESS_SPEC.md re-sync, README bilingual updates. Verified: version numbers consistent, new files registered, argument-hints aligned.

**Post-commit design change (2026-04-22)**: User decided default mode for both `sync` and `flush` should be **interactive** (asking), not auto. Auto now requires explicit `--auto` flag. Rationale: phase transitions and context extractions involve judgment; the safe default is to ask. Updated in all 8 skill files + both READMEs.

#### GitHub push SSL fix via WhoAMI inbox (2026-04-22)

`git push` for marketplace.json update (commit `235e19a`) repeatedly failed with `schannel: failed to receive handshake, SSL/TLS connection failed`. Received inbox message from WhoAMI (`2026-04-22-from-whoami-github-push-experience-report.md`) sharing their Windows + Clash Verge push solution. Applied the 4-config combo:
- `http.sslBackend = schannel`
- `http.proxy = http://127.0.0.1:7897`
- `https.proxy = http://127.0.0.1:7897`
- `http.lowSpeedLimit = 1000` + `http.lowSpeedTime = 60`

Push succeeded immediately after configuration. WhoAMI message marked `actioned`.

#### Kimi CLI skill version created (2026-04-22)

Created `kimi-skill/` — a Kimi CLI-compatible skill version of Doc Harness, adapting the v1.5.0 feature set for Kimi's natural-language trigger model.

#### Documentation sync run (2026-04-22)

`/doc-harness sync` executed by Kimi CLI. Fixes applied:
- Registered 3 inbox messages in FILE_INDEX (SMSS mandate, WhoAMI proposals, WhoAMI push experience)
- Updated CLAUDE.md one-line status to reflect v1.5.0 shipped + kimi-skill created + standalone repo published
- Updated CLAUDE.md current phase description
- Car body: 84 lines (under limit); WORKLOG: 261 lines (under limit); no phase transition or archival needed

#### Context flush (2026-04-22 21:38) — 1 item extracted to file
- Sync actions: phase transition no; archival no
- New file created: `notes/kimi-claude-interop.md` — Cross-tool skill discovery behavior (Kimi auto-discovers Claude skills, brand-directory priority rules, dual distribution strategy)
- Existing files appended: none
- Context-principle extraction: skipped by user

#### v1.5.1 design — recall command (2026-04-22)

User requested a fifth command to fill the retrieval gap: `recall`.

- **`/doc-harness recall [query]`** — Information retrieval. Searches systematically across all registered documents along the Doc Harness hierarchy (CLAUDE.md → CURRENT_STATUS → WORKLOG → FILE_INDEX → individual files) and returns structured, source-cited answers. Four query types: status/plan (Layer 0–1), history/decision (Layer 1–2), file lookup (Layer 3–4), cross-document synthesis (Layer 1–4). Read-only; never modifies files.

**Design artifacts created**:
- `skill/recall.md` (~270 lines) — English recall procedure with layered search protocol
- `skill-zh/recall.md` (~260 lines) — Chinese mirror
- `kimi-skill/references/recall.md` (~230 lines) — Kimi CLI adaptation (natural-language triggers)
- `skill/SKILL.md`, `skill-zh/SKILL.md`, `kimi-skill/SKILL.md` — Command listings updated
- `skill/spec.md`, `skill-zh/spec.md` — §11.7 recall normative spec added
- `README.md`, `README_zh.md` — Feature lists updated

**Completed**: All design artifacts, English + Chinese + Kimi skill files, project root doc updates. Recall.md registered in FILE_INDEX under all three skill categories.

**Key differences from Claude Code version**:
- No slash commands (`/doc-harness init`) — all triggers are natural language parsed from SKILL.md `description`
- No `argument-hint` or `allowed-tools` in frontmatter (Kimi only supports `name` + `description`)
- No `--auto` / `--interactive` flags — Kimi uses conversation context to decide whether to ask the user
- Supports `references/` directory for on-demand loaded docs (same mechanism as Claude Code's reference docs)

**Files created**:
- `kimi-skill/SKILL.md` (132 lines) — entry point with trigger table mapping natural language to procedures
- `kimi-skill/references/init.md` — project setup, including inter-project inbox/outbox adoption
- `kimi-skill/references/check.md` — health audit + principle reflection
- `kimi-skill/references/sync.md` — drift repair with ask/auto heuristics
- `kimi-skill/references/flush.md` — emergency context save before compression
- `kimi-skill/references/spec.md` — normative spec reference for edge cases

**Translation approach**: All docs written in English with Chinese annotations where helpful. Chinese mirror (`kimi-skill-zh/`) can follow later per Iron Rule 1.

Committed + pushed to GitHub (`f36a1ae`).

### Unresolved Issues

(None.)

---

## Next Steps (Headlights)

### Immediate Actions

1. Deploy sync to installed copies (user-level + project-level)
2. Run smoke test: `/doc-harness sync --interactive` and `/doc-harness flush --interactive` on a real project
3. Update plugin marketplace if schema requires version bump
4. Create standalone repo `cilidinezy-commits/doc-harness-for-kimi` (optional — decide if separate repo vs monorepo)

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
