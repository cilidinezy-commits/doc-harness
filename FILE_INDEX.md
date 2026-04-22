# FILE_INDEX — Doc Harness

**Last updated**: 2026-04-22 (sync run)

---

## Doc Harness Status Documents
- `CLAUDE.md` — Project entry point
- `CURRENT_STATUS.md` — Current status
- `FILE_INDEX.md` — This file
- `WORKLOG.md` — Work history
- `DOC_HARNESS_SPEC.md` — Complete specification (synced from `skill/spec.md`)

## English Skill Files (skill/)
- `skill/SKILL.md` — Entry point and router
- `skill/init.md` — `/doc-harness init` instructions and templates
- `skill/check.md` — `/doc-harness check` audit + reflection procedures
- `skill/sync.md` — `/doc-harness sync` drift repair and maintenance procedures
- `skill/flush.md` — `/doc-harness flush` emergency context-save procedures
- `skill/operational_rules.md` — Rules embedded in each project's CLAUDE.md
- `skill/spec.md` — Complete Doc Harness specification (authoritative)

## Chinese Skill Files (skill-zh/)
- `skill-zh/SKILL.md` — 主入口和路由
- `skill-zh/init.md` — `/doc-harness init` 创建指令和模板
- `skill-zh/check.md` — `/doc-harness check` 审计+反思流程
- `skill-zh/sync.md` — `/doc-harness sync` 漂移修复与维护流程
- `skill-zh/flush.md` — `/doc-harness flush` 紧急上下文保存流程
- `skill-zh/operational_rules.md` — 嵌入项目CLAUDE.md的操作规则
- `skill-zh/spec.md` — Doc Harness完整规范

## Notes
- `notes/kimi-claude-interop.md` — Cross-tool skill discovery behavior (Kimi CLI vs Claude Code)

## Project Documentation
- `README.md` — English project description (installation, usage, FAQ)
- `README_zh.md` — Chinese project description
- `LICENSE` — MIT license

## Kimi CLI Skill Files (kimi-skill/)
- `kimi-skill/SKILL.md` — Kimi CLI entry point (natural-language triggers)
- `kimi-skill/references/init.md` — Project setup procedure
- `kimi-skill/references/check.md` — Health audit + principle reflection
- `kimi-skill/references/sync.md` — Drift repair with ask/auto heuristics
- `kimi-skill/references/flush.md` — Emergency context save before compression
- `kimi-skill/references/spec.md` — Normative spec reference for edge cases

## Plugin Marketplace Metadata
- `.claude-plugin/marketplace.json` — Marketplace definition exposing two plugins (`doc-harness` / `doc-harness-zh`) so users can install via `/plugin marketplace add cilidinezy-commits/doc-harness` + `/plugin install <name>@doc-harness`

## Inter-Project Communication

Protocol: Doc Harness Chapter 14 (see `DOC_HARNESS_SPEC.md` §14).

- `inbox/2026-04-18-from-smss-inbox-protocol-mandate.md` — SMSS inbox protocol mandate
- `inbox/2026-04-19-from-whoami-skill-improvement-proposals.md` — WhoAMI skill improvement proposals
- `inbox/2026-04-22-from-whoami-github-push-experience-report.md` — WhoAMI GitHub push SSL fix experience
- `outbox/` — Outgoing messages (drafts and sent-copies; currently empty)
