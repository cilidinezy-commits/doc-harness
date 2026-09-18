# Doc Harness v2 — Deterministic Toolbelt (optional)

These are **optional deterministic helpers** for mechanical bookkeeping. They are not commands to the agent and do not prescribe how the agent works.

**This folder ships three times**: at the repository root (canonical, used by this project's own gate) and inside each language's skill folder (`skill/tools/`, `skill-zh/tools/`) so that installing the skill also delivers the mechanism. `toolbelt-sync.ps1` fails if any copy differs by a byte — edit the canonical copy, then re-copy:

```powershell
Copy-Item -Path tools/* -Destination skill/tools    -Recurse -Force
Copy-Item -Path tools/* -Destination skill-zh/tools -Recurse -Force
```

Copy the *contents*: `Copy-Item tools -Destination skill/tools` nests the folder instead.

**Single parser invariant**: reconstructing state from `events.log` happens in exactly one place — `lib/doc-state.ps1` (`Get-DocState`) — and every tool that needs state dot-sources it. Tools that read the log as *text* (grep, migration, telemetry) must never reimplement the replay.

- `now-verify.ps1` — verify `## NOW`: present, ≤30 lines, valid UTF-8, refresh marker, next + resolvable read-first, **and no project file changed after the last recorded event** (work that was never recorded → red). `-NoFreshness` skips the last check.
- `unregistered.ps1` — list files on disk that are not mentioned in any `FILE_INDEX.md` (a heuristic "unregistered → red" check).
- `nested-git-guard.ps1` — block staging files that live inside a nested project that has its own `CLAUDE.md`.
- `ops-embed.ps1` — re-embed the operational-rules block in a project's `CLAUDE.md` from the ops source (auto-discovered at `skill/` or `.claude/skills/doc-harness-v2/`); `-Check` verifies the copy instead of writing. Conformance runs it in `-Check` mode, so a half-updated or hand-edited ops block is a red.
- `log-migrate.ps1` — one-time event-schema migration (`-CloseClass` / `-JudgmentClass`, `-WhatIf`): archives the old log under `_archive/`, adds the missing field, leaves a `#` comment trail, and re-projects. Never invents evidence — closes with no `evidence=` are reported.
- `mail-poll.ps1` — background inbox poll (configurable `-IntervalSeconds` / `-CheckInSeconds` / `-NotifyDelaySeconds`): on `status: unread`, writes heartbeat and emits `TASK=inbox|ITEM=...`.
- `mail-daemon.ps1` — complete background mail daemon: persistent loop (idle = pure sleep, no LLM), `inbox/_processing/` lock + crash recovery, status file (`_runtime/mail-status.md` by default — runtime, so it never trips the unregistered check), optional `-ProcessCommand` to launch the processing agent, quiet-period + consecutive-failure guards.
- `mail-ledger.ps1` — append a row to `MAIL_LEDGER.md`.
- `mail-process-template.md` — the one-shot mail-processing prompt; after actioning, run `now-verify.ps1` to confirm `## NOW` advanced.
- `recurrence.ps1` — scan PHILOSOPHY/CLAUDE/events.log for `第 N 次` (N≥3) markers and flag any that are still not marked `会红` (should be a gate).
- `dead-pointer.ps1` — verify every backtick-referenced path in FILE_INDEX.md / CURRENT_STATUS.md resolves to an existing file or directory.
- `conformance.ps1` — run `now-verify` + `encoding-guard` + `unregistered` + `dead-pointer` + `recurrence` + `cite-check` + `stale-check`, the projection-freshness check and the ops/spec version-drift check as a single gate. `-Full` also runs `handoff-test`.
- `stale-writer-guard.ps1` — optimistic concurrency: `-Action claim -Token X` records CURRENT_STATUS mtime; `-Action check -Token X` fails if it changed since the claim.
- `batch-register.ps1` — append a batch of files under a FILE_INDEX category, and optionally write a SHA-256 manifest.
- `cite-check.ps1` — flag `## NOW` key-judgment lines and `[active]`/`[done]` work-surface units that lack a source pointer.
- `encoding-guard.ps1` — strict UTF-8 validation across CLAUDE/CURRENT_STATUS/FILE_INDEX/events.log/PHILOSOPHY/AGENTS, **and** that every tool script is pure ASCII (PowerShell 5.1 reads BOM-less `.ps1` as ANSI, so a literal non-ASCII char in a script becomes mojibake at parse time; build it from its code point instead).
- `telemetry.ps1` — append an event to `_runtime/ops-log.ndjson` (audit/telemetry loop).
- `record.ps1` — the one-step state change: `-Verb open|activate|close|pause|next|judgment|read|plan|deadend|note -Text "..."` (appends the event, re-projects, runs conformance; `note` records housekeeping that is not a unit/decision/plan change). For several changes at once use `-EventsFile <file>` (one raw `<verb> <payload>` per line; blank lines and `#` comments ignored) or `-Events` with newline-separated entries. Beware: via `powershell -File`, an array argument arrives comma-joined, so the script **fails closed** on a comma-joined line rather than gluing events together. A red guard is reported as `conformance: RED …` and explicitly distinguished from a failed record.
- `mail-send.ps1` — one-step cross-project send: writes `outbox/` + copies to the recipient `inbox/` (creating that inbox if the recipient has never received mail, with YAML frontmatter). `-BodyFile` avoids shell quoting entirely for a long body.
- `search.ps1` — layered search: `-Query "..." -Layer all|now|history|files|anchor` returns `file:line: content` matches.
- `stale-check.ps1` — flag standing conclusions past their `conclusion_until: YYYY-MM-DD` (freshness guard).
- `skill-consistency.ps1` — the skill docs' review-only claims, machine-checked: **language parity** (`skill/` and `skill-zh/` must share one skeleton — files, heading levels in order, code fences, table rows), **identical normative identifiers** (every path and event verb named in one language must be named in the other), and **no retired model vocabulary** (v1 terms are allowed only in a sentence that also marks them as v1/archived/migrated). Skips when there is no such pair, so it does not burden ordinary projects.
- `entry-check.ps1` — single entry: `CLAUDE.md` must carry the identity lock, and `AGENTS.md` (if present) must be a thin pointer — small, pointing at the entry, carrying neither state sections nor its own copy of the operational rules.
- `publish-scan.ps1` — privacy scan for a release build: no file may contain a forbidden term (names, institutions, off-project context, sibling project names). The terms live in a local, never-published file (`-TermsFile`, default `<root>/.publish-terms.txt`; `allow:` lines exempt files that were already public). Skips when there is no terms file, so it is inert in an installed copy.
- `handoff-test.ps1` — deterministic regression test of the mechanism: builds a non-linear fixture (two parts, interleaved open/activate/close, one paused, one dead end), then asserts the projection (bounded NOW, frontier order, part headings, evidence, plan split, resolvable read-first) and that the guards go red on broken input. This is the deterministic half of handoff verification; the judgment half (a reader recovering the state) can only be done by a reader.

Usage (PowerShell):

```powershell
powershell -File tools/now-verify.ps1 -ProjectRoot D:\Projects\<project>
powershell -File tools/unregistered.ps1 -ProjectRoot D:\Projects\<project>
powershell -File tools/mail-poll.ps1 -Inbox D:\Projects\<project>\inbox -IntervalSeconds 60 -CheckInSeconds 7200
powershell -File tools/recurrence.ps1 -ProjectRoot D:\Projects\<project>
powershell -File tools/dead-pointer.ps1 -ProjectRoot D:\Projects\<project>
powershell -File tools/conformance.ps1 -ProjectRoot D:\Projects\<project>
powershell -File tools/stale-writer-guard.ps1 -ProjectRoot D:\Projects\<project> -Action claim -Token me
powershell -File tools/batch-register.ps1 -ProjectRoot D:\Projects\<project> -Files @('a.md','b.md') -Category 'Notes'
powershell -File tools/record.ps1 -ProjectRoot D:\Projects\<project> -Verb open -Text "T9 调研"
powershell -File tools/mail-send.ps1 -ProjectRoot . -To D:\Projects\<recipient> -From <me> -Subject "..." -Body "..." -Topic "..."
powershell -File tools/search.ps1 -ProjectRoot D:\Projects\<project> -Query "keyword" -Layer all
powershell -File tools/handoff-test.ps1
powershell -File tools/conformance.ps1 -ProjectRoot D:\Projects\<project> -Full
# Background mail daemon — tool-agnostic; -ProcessCommand launches whichever agent CLI is installed:
powershell -File tools/mail-daemon.ps1 -ProjectRoot . -IntervalSeconds 60 -ProcessCommand "codex exec --skip-git-repo-check <prompt>"
powershell -File tools/mail-daemon.ps1 -ProjectRoot . -IntervalSeconds 60 -ProcessCommand "claude -p <prompt>"
```

Both exit non-zero when a problem is found, so they can be wired into a pre-commit or CI gate.

All tools are plain PowerShell and work under any agent (Codex, Claude Code, or a human's shell). The only tool-specific knob is `mail-daemon.ps1 -ProcessCommand`.
