# Kimi CLI — Claude Code Skill Interoperability

> Extracted from context on 2026-04-22 during flush

## Discovery 1: Kimi Auto-Discovers Claude Skills

Kimi CLI's skill discovery mechanism searches `~/.claude/skills/` as a **brand-group fallback**.

From [Kimi CLI documentation](https://moonshotai.github.io/kimi-cli/en/customization/skills.md):

> **Brand group** (mutually exclusive):
> 1. `~/.kimi/skills/`
> 2. `~/.claude/skills/`
> 3. `~/.codex/skills/`

This means a skill installed for Claude Code (e.g., `~/.claude/skills/doc-harness/`) **automatically appears** in Kimi CLI with no extra installation step.

**Practical implication**: A user who installed doc-harness for Claude Code will see it in Kimi immediately — but Kimi will load the Claude Code version (with `argument-hint`, `/doc-harness` slash commands) rather than the Kimi-native version.

---

## Discovery 2: Brand-Directory Priority Is Deterministic

When a skill with the **same name** exists in multiple brand directories, Kimi resolves by priority:

```
~/.kimi/skills/doc-harness/     ← HIGHEST (Kimi native)
~/.claude/skills/doc-harness/   ← MIDDLE (Claude fallback)
~/.codex/skills/doc-harness/    ← LOWEST (Codex fallback)
```

**Practical implication**: To ensure Kimi loads the Kimi-native version of doc-harness, it must be installed in `~/.kimi/skills/doc-harness/`. The Claude Code version in `~/.claude/skills/doc-harness/` is shadowed and will not be loaded.

---

## Decision: Dual Distribution Strategy

For doc-harness (a cross-tool skill), we maintain two distribution paths:

| Path | Audience | Content |
|------|----------|---------|
| `doc-harness/kimi-skill/` (in main repo) | Developers | Source of truth for Kimi version; synced with main development |
| `cilidinezy-commits/doc-harness-for-kimi` | Kimi users | Standalone repo for `git clone` installation |
| `cilidinezy-commits/doc-harness` | Claude users | Main repo with `skill/` directory; installable via marketplace |

**Why two repos?** The main repo contains bilingual skill files (`skill/`, `skill-zh/`), spec documents, and project infrastructure. A Kimi-only user does not need the Claude-specific marketplace metadata or Chinese mirror files. The standalone repo provides a clean install target.

---

## Verification Log

- **2026-04-22**: Confirmed `~/.claude/skills/doc-harness/` (v1.4.1) appeared in Kimi CLI before any Kimi-specific installation.
- **2026-04-22**: Installed `~/.kimi/skills/doc-harness/` (v1.5.0 Kimi version). Verified it shadowed the Claude version.
- **2026-04-22**: Updated `~/.claude/skills/doc-harness/` to v1.5.0 (Claude version). Confirmed Kimi still loads the `~/.kimi/` version due to priority.
