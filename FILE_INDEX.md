# FILE_INDEX — Doc Harness

**Last updated**: 2026-04-19 晚 (v1.4.1)

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
- `skill/operational_rules.md` — Rules embedded in each project's CLAUDE.md
- `skill/spec.md` — Complete Doc Harness specification (authoritative)

## Chinese Skill Files (skill-zh/)
- `skill-zh/SKILL.md` — 主入口和路由
- `skill-zh/init.md` — `/doc-harness init` 创建指令和模板
- `skill-zh/check.md` — `/doc-harness check` 审计+反思流程
- `skill-zh/operational_rules.md` — 嵌入项目CLAUDE.md的操作规则
- `skill-zh/spec.md` — Doc Harness完整规范

## Project Documentation
- `README.md` — English project description (installation, usage, FAQ)
- `README_zh.md` — Chinese project description
- `LICENSE` — MIT license

## Plugin Marketplace Metadata
- `.claude-plugin/marketplace.json` — Marketplace definition exposing two plugins (`doc-harness` / `doc-harness-zh`) so users can install via `/plugin marketplace add cilidinezy-commits/doc-harness` + `/plugin install <name>@doc-harness`

## Inter-Project Communication

Protocol: Doc Harness Chapter 14 (see `DOC_HARNESS_SPEC.md` §14).

- `inbox/` — Incoming messages from other projects (2 archived messages so far)
- `outbox/` — Outgoing messages (drafts and sent-copies; currently empty)
