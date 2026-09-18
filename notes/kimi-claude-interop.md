# Kimi CLI — how it discovers skills (and why doc-harness needs no Kimi fork)

> **Re-verified 2026-09-18** against the official docs (Kimi Code CLI v1.37.0,
> <https://moonshotai.github.io/kimi-cli/en/customization/skills.html>). The April 2026 findings
> below are kept because they explain how the current behaviour was discovered.

## Current rules (2026-09-18)

User-level skill directories, in two groups:

| Group | Directories |
|-------|-------------|
| Brand group | `~/.kimi/skills/`, `~/.claude/skills/`, `~/.codex/skills/` |
| Generic group | `~/.config/agents/skills/` |

- `merge_all_available_skills` (config) **defaults to `true`**: every brand directory that exists is
  merged, and skills with the same name are resolved by priority **`kimi > claude > codex`**.
  Setting it to `false` restores the older first-match-only behaviour (only the highest-priority
  brand directory is used).
- Project-level skills use the same names inside the project: `.kimi/skills/`, `.claude/skills/`,
  `.codex/skills/`, plus the generic `.agents/skills/`.
- Extra directories can be added with `--skills-dir`.
- Layout: `<skill-name>/SKILL.md` (required), optionally `references/` and `assets/`. `SKILL.md`
  needs YAML frontmatter with at least `name` and `description`.

## Consequence for doc-harness

**One skill folder serves every agent.** doc-harness v2 is plain Markdown plus an optional
PowerShell toolbelt, and its folder already has the required shape (`SKILL.md` + flat command
documents + `tools/`), so installing it for Kimi CLI is a copy — not a port:

```bash
cp -r skill ~/.kimi/skills/doc-harness            # English
# or: cp -r skill-zh ~/.kimi/skills/doc-harness   (中文)
```

There is no Kimi-specific fork. The `kimi-skill/` directory that existed until 2026-09-18 was a
v1.6-era fork; it was removed because it was both stale (it taught the retired document model) and
unnecessary.

⚠️ **The trap this note exists to prevent**: because same-name skills prefer the *kimi* directory,
a stale copy in `~/.kimi/skills/doc-harness/` **silently shadows** newer installs in the other
directories. If Kimi behaves like an older version, check that directory first.

## Local state (this machine, 2026-09-18)

- Kimi Code CLI v1.37.0 installed (`kimi`, `kimi-cli`).
- `~/.kimi/skills/doc-harness/` was **v1.6.0** (stale, and shadowing everything else). It has been
  replaced with **v2.0.0 (中文版)**; the old copy is backed up at
  `~/.kimi/backup-doc-harness-v1.6-live-20260918/`.
- `~/.claude/skills/doc-harness/` is v1.7.1 (the stable line used by other projects — deliberately
  untouched).
- **Session-level verification is currently blocked**: `kimi --print` returns
  `401 invalid_authentication_error`, i.e. the local Kimi credential has expired. Run `kimi login`
  and then re-check with a prompt that discriminates the models, e.g.
  *"doc-harness 里项目状态的唯一来源是哪个文件？"* → v2 answers `events.log`; v1 answers the
  five-document set.

## History (April 2026, v1 era)

- **2026-04-22**: `~/.claude/skills/doc-harness/` (v1.4.1) appeared in Kimi CLI with no
  Kimi-specific installation — the brand-group fallback was how cross-tool discovery was found.
- **2026-04-22**: installing `~/.kimi/skills/doc-harness/` (v1.5.0) shadowed the Claude version;
  updating the Claude copy to v1.5.0 did not change which one Kimi loaded. That is the same
  priority rule that is still documented today.
