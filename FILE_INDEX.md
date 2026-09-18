# FILE_INDEX — Doc Harness

**Last updated**: 2026-09-18 (v2.0.0 release preparation)

---

## Doc Harness Status Documents
- `CLAUDE.md` — Project entry point
- `AGENTS.md` — Thin pointer to CLAUDE.md
- `events.log` — Append-only event log (the state primitive; NOW + work surface are projected from it)
- `CURRENT_STATUS.md` — Current status
- `FILE_INDEX.md` — This file
- `_archive/WORKLOG_v1.md` — Archived v1 prose worklog (superseded by `events.log`)
- `DOC_HARNESS_SPEC.md` — Complete specification (synced from `skill/spec.md`)

## Deterministic Toolbelt (tools/)
- `tools/README.md` — Usage for the optional deterministic helpers
- `tools/ops-embed.ps1` — Re-embed (or `-Check`) the operational-rules block in a project's CLAUDE.md from the ops source; the copy is made falsifiable
- `tools/handoff-test.ps1` — Deterministic handoff regression test: non-linear fixture → asserts projection, frontier, part headings, evidence, and that guards go red on broken input
- `tools/lib/doc-harness-config.json` — Single source of normative parameters (thresholds, ops version)
- `tools/lib/doc-state.ps1` — Shared parser (Get-DocState) that all tools read instead of parsing prose
- `tools/lib/pshost.ps1` — Portable child-process host (re-runs the same PowerShell host, so the toolbelt works under both Windows PowerShell and `pwsh` on Linux/macOS)
- `tools/project.ps1` — Project an event log into `## NOW` + work surface (event-log-primitive prototype)
- `tools/now-verify.ps1` — Verify `## NOW`: bounded, valid UTF-8, refresh marker, resolvable read-first, and no file changed after the last recorded event (unrecorded work → red)
- `tools/unregistered.ps1` — Heuristic check for files on disk not mentioned in any FILE_INDEX
- `tools/nested-git-guard.ps1` — Pre-commit style check against staging files inside a nested project with its own CLAUDE.md
- `tools/mail-poll.ps1` — Wake-only inbox poll (absorbs 两个下游项目 pattern)
- `tools/mail-daemon.ps1` — Complete background mail daemon (detect → lock → status → optional processor launch → crash recovery → guards)
- `tools/mail-ledger.ps1` — Append a row to MAIL_LEDGER.md
- `tools/mail-process-template.md` — One-shot mail-processing prompt incl. post-task NOW guard
- `tools/recurrence.ps1` — Report disciplines re-stated ≥3 times that are still not a gate (no 会红)
- `tools/dead-pointer.ps1` — Verify every backtick-referenced path in FILE_INDEX/CURRENT_STATUS resolves to a real file
- `tools/conformance.ps1` — Run every guard + projection freshness + ops/spec version drift + ops-embed check as one gate; `-Full` also runs the handoff regression test
- `tools/stale-writer-guard.ps1` — Optimistic concurrency guard for CURRENT_STATUS (claim/check by mtime)
- `tools/batch-register.ps1` — Register a batch of files under a FILE_INDEX category (+ optional SHA-256 manifest)
- `tools/cite-check.ps1` — Flag NOW judgments / closed units without a source pointer and a provenance class (`root|decision|reported`)
- `tools/encoding-guard.ps1` — Strict UTF-8 validation of all status documents **and** ASCII-only tool scripts
- `tools/telemetry.ps1` — Append a timestamped event to `_runtime/ops-log.ndjson`
- `tools/record.ps1` — One-step state change: append an event + re-project + conformance (`-Verb note` for housekeeping; `-EventsFile` records a batch, failing closed on shell-glued input)
- `tools/log-migrate.ps1` — One-time event-schema migration (archive + normalize + comment trail + re-project)
- `tools/mail-send.ps1` — One-step cross-project send: write outbox + copy to recipient inbox
- `tools/search.ps1` — Layered search across the document system (`-Layer all|now|history|files|anchor`)
- `tools/stale-check.ps1` — Flag standing conclusions past their `conclusion_until` (freshness)
- `tools/skill-consistency.ps1` — Skill docs: EN/ZH skeleton parity, identical normative identifiers, and no retired (v1) model vocabulary outside a migration/history sentence
- `tools/entry-check.ps1` — Single entry: identity lock in CLAUDE.md, and AGENTS.md (if any) is a thin pointer rather than a second entry/state copy
- `tools/publish-scan.ps1` — Privacy scan for a release tree: no forbidden term (names/institutions/off-project context/sibling projects) anywhere; terms live in `.publish-terms.txt`

## English Skill Files (skill/)
- `skill/SKILL.md` — Entry point and router
- `skill/init.md` — `/doc-harness init` instructions and templates
- `skill/check.md` — `/doc-harness check` audit + reflection procedures
- `skill/sync.md` — `/doc-harness sync` drift repair and maintenance procedures
- `skill/flush.md` — `/doc-harness flush` emergency context-save procedures
- `skill/recall.md` — `/doc-harness recall` information retrieval protocol
- `skill/resume.md` — `/doc-harness resume` structured state recovery procedure
- `skill/operational_rules.md` — Rules embedded in each project's CLAUDE.md
- `skill/spec.md` — Complete Doc Harness specification (authoritative)

## Chinese Skill Files (skill-zh/)
- `skill-zh/SKILL.md` — 主入口和路由
- `skill-zh/init.md` — `/doc-harness init` 创建指令和模板
- `skill-zh/check.md` — `/doc-harness check` 审计+反思流程
- `skill-zh/sync.md` — `/doc-harness sync` 漂移修复与维护流程
- `skill-zh/flush.md` — `/doc-harness flush` 紧急上下文保存流程
- `skill-zh/recall.md` — `/doc-harness recall` 信息召回协议
- `skill-zh/resume.md` — `/doc-harness resume` 结构化状态恢复流程
- `skill-zh/operational_rules.md` — 嵌入项目CLAUDE.md的操作规则
- `skill-zh/spec.md` — Doc Harness完整规范

## Notes
- `notes/kimi-claude-interop.md` — Cross-tool skill discovery behavior (Kimi CLI vs Claude Code)
- `notes/state-model.md` — Why the state must be a projection from an append-only event log (the foundational design)
- `notes/design-core.md` — Core v2 design (unique entry + NOW block + stable anchor + work surface + toolbelt)
- `notes/foundational-analysis.md` — Session-switch failure modes F1–F6 → requirements R1–R5
- `notes/deep-analysis.md` — Deeper analysis while waiting (event-log primitive, contract + verifiers, honest map, formal handoff)
- `notes/upgrade-design-proposal.md` — Upgrade design proposal (work surface + ENTRY/NOW + deterministic toolbelt)
- `notes/document-guard-levels.md` — Four-level document-guard principle (form vs meaning; provenance/freshness gap)
- `notes/validation.md` — Verification log: what has been verified, what failed, what is still unverified
- `notes/reddit-v160-announcement.md` — Reddit announcement post for v1.6.0
- `notes/wechat-promo-v160.md` — WeChat group promotion copy for v1.6.0
- `PHILOSOPHY.md` — Principles forged by practice, now layer-marked (会红/自动注入/可查) + recurrence: zoom-out, curse-of-knowledge, delegate-read-not-judge, repeated-failure→make-it-a-gate

## Project Documentation
- `README.md` — English project description (installation, usage, FAQ)
- `README_zh.md` — Chinese project description
- `RELEASING.md` — How a release is built: what is not published, the pre-flight checks, and the curated-commit procedure
- `LICENSE` — MIT license
- `.gitignore` — Git ignore rules (kimi-export artifacts, etc.)
- `.gitattributes` — Pin LF for text files (the projection is compared byte-for-byte, so a CRLF checkout must not read as stale)

## Validation Fixtures
- `_validation/demo-project/` — Small branching fixture (three units, key judgment, read-first list) used for the handoff walkthrough
- `_validation/trial-project/` — Mid-project fixture (in-flight units + a closed unit + a robust-check unit)
- `_validation/adversarial-project/` — Deliberately broken fixture (four defects) proving the guards go red
- `_validation/mail-daemon-test/`, `_validation/mail-test-recipient/`, `_validation/bad-events/` — Mail daemon and malformed-log probes

## Kimi CLI Skill Files (kimi-skill/)
- ⚠️ `kimi-skill/` 已**废弃**（2026-09-07，放弃维护，仅历史留存）；见 `kimi-skill/README.md`。
- `kimi-skill/SKILL.md` — Kimi CLI entry point (natural-language triggers)
- `kimi-skill/README.md` — Standalone repo README with install/usage/upgrade instructions
- `kimi-skill/references/init.md` — Project setup procedure
- `kimi-skill/references/check.md` — Health audit + principle reflection
- `kimi-skill/references/sync.md` — Drift repair with ask/auto heuristics
- `kimi-skill/references/flush.md` — Emergency context save before compression
- `kimi-skill/references/recall.md` — Information retrieval protocol
- `kimi-skill/references/resume.md` — Structured state recovery after context loss
- `kimi-skill/references/spec.md` — Normative spec reference for edge cases

## Plugin Marketplace Metadata
- `.claude-plugin/marketplace.json` — Marketplace definition (current schema, v1.7.1) exposing two plugins (`doc-harness` / `doc-harness-zh`); install via `/plugin marketplace add cilidinezy-commits/doc-harness` + `/plugin install <name>@doc-harness`
- `skill/.claude-plugin/plugin.json` — English plugin manifest (v1.7.1)
- `skill-zh/.claude-plugin/plugin.json` — Chinese plugin manifest (v1.7.1)

## Inter-Project Communication

Protocol: Doc Harness Chapter 14 (see `DOC_HARNESS_SPEC.md` §14).

- `inbox/_archive/` — Archived actioned messages from 2026-04 (3, all >30 days old); the filenames are in the directory itself
- `inbox/_malformed/` — Quarantined malformed messages (1, no YAML frontmatter); the filename is in the directory itself
