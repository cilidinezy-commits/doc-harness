# Doc Harness — Check

Audit documentation health and reflect on principles. Two parts: file health + principle reflection.

## Part 1: File Health

### 1.1 Core files

Required: `CLAUDE.md`, `AGENTS.md`, `events.log`, `CURRENT_STATUS.md`, `FILE_INDEX.md`. Optional: `DOC_HARNESS_SPEC.md` (reference).

### 1.2 NOW freshness

Read `CURRENT_STATUS.md` `## NOW`'s "Refreshed" line. Today → ✅; 1–3 days → ⚠️; >3 days → ❌ stale.

### 1.3 NOW size and encoding

- Size: `## NOW` ≤ ~30 lines → ✅; over → ❌ (too long — history has leaked into NOW).
- Encoding: open CURRENT_STATUS as UTF-8 and confirm no mojibake → ✅; mojibake → ❌ corrupted (rewrite from clean source).

### 1.4 FILE_INDEX completeness (unregistered → red)

Compare files on disk vs FILE_INDEX entries (recursive with sub-index prune). Unregistered files are a **❌ red** item, not a warning. Ghost entries are also ❌.

### 1.5 events.log well-formedness

Run `tools/project.ps1` (or `Get-DocState`): no parse errors → ✅; any `malformed / duplicate open / activate-before-open / unknown verb` error → ❌.

### 1.6 events.log length & archival

<1000 lines ✅; 1000–1500 ⚠️ consider rolling old units into `_archive/`; >1500 ❌ archival overdue.

### 1.7 Inbox (if adopted)

(a) unread count; (b) actioned >30 days (archival due at ≥5); (c) `inbox/_malformed/` count; (d) recent outbox sends recorded in CURRENT_STATUS.

### 1.8 Entry uniqueness

- `AGENTS.md` (if present) is a thin pointer to `CLAUDE.md`, not a stale copy → ✅; stale/duplicated → ❌.
- `CLAUDE.md` is the authoritative entry → ✅.

### 1.9 Projection coherence

Run `tools/conformance.ps1`: the in-memory projection from `events.log` must equal the on-disk `CURRENT_STATUS.md` → ✅; `projection-stale` → ❌ (re-project).

### 1.10 Operational-rules version

Grep `<!-- doc-harness-ops-version: N.N -->` in CLAUDE.md; compare to installed `spec.md` version. Stale → ⚠️ re-embed.

### 1.11 Identity lock

CLAUDE.md begins with AGENT IDENTITY LOCK + project name + self-test → ✅; else ⚠️.

### 1.12 Recurrence (written → used)

Scan PHILOSOPHY.md / iron rules / `events.log` for `Nth time` markers. For any discipline re-stated **≥2 times** that is still marked queryable or has no layer, report:

```
⚠ These disciplines have been restated ≥3 times and still rely on being remembered (queryable layer) — they should have been guards:
- [discipline] — Nth time (previous: <ref>) + missing same-shape field?
```

No such markers → ✅.

### 1.13 Falsifiability (dead pointers)

Run `tools/dead-pointer.ps1`. Every backtick-referenced path in FILE_INDEX.md / CURRENT_STATUS.md must resolve to an existing file or directory. Dangling references → ❌ (the document names something that no longer exists).

### 1.14 Freshness (stale conclusions)

Run `tools/stale-check.ps1`. Any standing conclusion past its `conclusion_until` → ❌ (an expired conclusion written as if current).

### 1.15 Provenance class

Run `tools/cite-check.ps1`. Every judgment / closed-unit source must carry `class=root|decision|reported` → ✅; missing source or missing class → ❌.

## Part 2: Principle Reflection

```
🔒 Stable anchor / iron rules: [list + reflection]
🧭 Bottom-line principles: [list + reflection]
📝 Write It Down: any important info only in context?
🗺️ Work surface: is the active frontier current and coherent?
🚪 Entry: can a fresh agent orient from CLAUDE.md → ## NOW → read-first in ≤ a few reads?
🔁 Recurrence: any discipline that keeps being re-stated? → it should be a gate.
```

## Output

```
═══════════════════════════════════════
  Doc Harness — Health Check   Project: [name]   Date: [today]
═══════════════════════════════════════
── Part 1: File Health ──
[1.1] Core files: ✅/❌   Spec/AGENTS: ✅/⚠️
[1.2] NOW freshness: ✅/⚠️/❌
[1.3] NOW size/encoding: ✅/❌
[1.4] FILE_INDEX: ✅/❌ N unregistered / N ghosts
[1.5] events.log: ✅/❌ parse
[1.6] events.log length: ✅/⚠️/❌
[1.7] Inbox: ✅/⚠️ (unread/archival/malformed/unlogged)
[1.8] Entry uniqueness: ✅/❌
[1.9] Projection: ✅/❌ stale
[1.10] Ops-rules version: ✅ vN.N / ⚠️
[1.11] Identity lock: ✅/⚠️
[1.12] Recurrence: ✅/⚠️ <re-stated ≥2x still queryable>
[1.13] Dead pointers: ✅/❌
[1.14] Stale conclusions: ✅/❌
[1.15] Provenance class: ✅/❌
── Part 2: Principle Reflection ──
...
── Actions Needed ──
...
═══════════════════════════════════════
```

Use: every 1–2h, before session end, after compact, before sync/flush.
