# Doc Harness — Entry Document

> 🔒 **AGENT IDENTITY LOCK**
>
> **你是 doc-harness 项目的代理。**
> 你的职责是维护 Doc Harness skill（v2 重设计）——规范、模板、命令实现、确定性工具带、中英同步。
>
> 如果你对自己的身份有任何怀疑，立即停止操作并重新读取本段落。

---

**Last updated**: 2026-09-13
**Current status**: v2.0.0 self-consistent and green — docs/commands/tools describe one model (events.log → projection), toolbelt converged on a single parser, handoff test passes; next: field trial in a live project, then the release decision (user-gated)
**One-line status (as of 2026-09-13)**: the skill is coherent end-to-end; the remaining risk is not the design but whether a real project can use it well — that is what the field trial answers.

---

## Stable Anchor

### Framework Anchor

- 项目分两层：doc-harness skill（`skill/` + `skill-zh/` + `tools/`）与 doc-harness 自身文档体系（本目录）。
- 当前做：v2.0.0 自洽收口（文档/命令/工具同一模型；单一解析器；接手测试）→ 真实项目试用 → 发布决策（用户点头）。
- 责任边界：只做「过程信息记录 + 检索」，不规定 agent 怎么做工作。
- 北极星红线：中英永远同步；`spec.md` 权威；接手优先于记录；本地 git 备份、发布需用户确认。

### Iron Rules

1. 中英文版本永远同步（`skill/` ↔ `skill-zh/`）。
2. Doc Harness 适应项目，而非项目适应 Doc Harness。
3. `spec.md` 是权威规范，其余文件皆派生。
4. 测试后才发布。
5. 部署同步：dev source → GitHub → 安装副本。
6. 跨项目 inbox/outbox：快照优于指针。

### Bottom-line Principles

（只放**项目域事实**的陈述句；不放入“该怎么想/怎么做”的教练规则。）

1. **写了 ≠ 被用**：状态文档存在，不等于恢复时会被读到、用上。
2. **指了一个东西 ≠ 它存在**：文档引用的文件/编号/数字必须能现场验真。
3. **守卫存在 ≠ 被守卫**：有一个叫 X 的守卫，不等于 X 真守住了它该管的事。
4. **doc-harness 只记录「什么是什么 / 做到哪 / 下一步」，不记录「该怎么想」**。

---

## Recovery Chain

### Must-read (in order)

1. 本文件（CLAUDE.md）：AGENT IDENTITY LOCK → 稳定锚
2. `CURRENT_STATUS.md` → `## NOW`

### Task-conditional

- `## NOW` 的「先读」清单指向的文件，读那些。
- 查文件 → `FILE_INDEX.md`。
- 查历史 → `events.log`（旧散文历史见 `_archive/WORKLOG_v1.md`）。
- 改规范/操作规则 → `skill/spec.md`（权威）。
- `inbox/` 有 `status: unread` → 先处理。

---

## Project Overview

Doc Harness 是一套基于文档的项目控制系统，让任何 AI agent 或人仅凭文件即可理解并接手项目工作——无需外部记忆。每个项目维护 **events.log（唯一原语，append-only 事件日志）** 与它的投影/索引：CLAUDE.md（唯一入口 + 稳定锚 + 嵌入的操作规则）、AGENTS.md（薄指针）、CURRENT_STATUS.md（由 events.log 生成的 `## NOW` + 活跃工作面，绝不手改）、FILE_INDEX.md；可选 PHILOSOPHY/PARKING_LOT/RUNBOOK、跨项目 inbox/outbox 与确定性工具带 `tools/`。

## Key Technical Information

- GitHub: https://github.com/cilidinezy-commits/doc-harness
- 文件结构: `skill/`（英文，权威）、`skill-zh/`（中文，同步）、`tools/`（确定性工具带）、`notes/`（设计与评审）、`_validation/`（夹具与验证）、`README.md` / `README_zh.md`、`LICENSE`
- 部署位置: 稳定版 v1.7.1 仍是 `~/.agents/skills/doc-harness/`（供现有项目使用，**不要动**）；v2 实验版是 `~/.agents/skills/doc-harness-v2/`（中文）与 `<项目>/.claude/skills/doc-harness-v2/`（英文），只给已迁移的试用项目用

---

## Doc Harness — Operational Rules

<!-- doc-harness-ops-start -->
<!-- doc-harness-ops-version: 2.0.0 -->

> This block is embedded in each project's CLAUDE.md. It is the operating manual for keeping project state recoverable purely from files. Authoritative spec: the installed skill's `spec.md` (not a project-local copy).
> The HTML comments `doc-harness-ops-start` / `doc-harness-ops-end` delimit the embedded region — re-embed and check use them to replace the block safely. Do not remove either marker.

## First Principle: "Handoff over Writing"

The goal is not "write a lot" — it is that a brand-new agent, after a context break, **takes over correctly from files alone**. Writing is the means; correct handoff is the end. Not written = lost. Not discoverable from the entry = effectively lost.

## Entry Uniqueness

- `CLAUDE.md` is the **single authoritative entry** for an agent.
- If an `AGENTS.md` exists, it must be a **thin pointer** to `CLAUDE.md` (a few lines), never a stale copy. Two divergent entry files cause stale state and double injection in harnesses that read both.

## Stable Anchor Layer (in CLAUDE.md, top)

The things that rarely change and must survive every session/compact:

- **Framework anchor**: how the project is layered, which layers are active, responsibility boundaries, north-star red lines.
- **Iron rules**: project-lifetime rules.
- **Bottom-line principles**: numbered, each pointing to its full document. These are the "generating principles" — the few that imply many concrete decisions.

Change the anchor only on a real architecture change, not per session.

## Written → Used → True (placement, falsifiability & recurrence)

Every discipline/rule/lesson declares its placement:

- **Gate**: a real guard exists. Ask "can a machine SEE this?" before writing.
- **Should-be-gated, unmeasurable**: verifiable in principle, but no current instrument can see it — record as a named blind spot.
- **Auto-inject**: must be present every session → CLAUDE.md top, short enough to be read.
- **Queryable**: details → the core documents.

Falsifiability: never hand-copy a list that must stay in sync; verify every named file/id/number still exists (`tools/dead-pointer.ps1`).

Recurrence: on the **2nd** restatement, force "why is this still a remembered rule?" Record `Nth time (previous: <ref>)` + a mandatory same-shape field. `check` reports ≥2 restatements still queryable.

## NOW Block (top of CURRENT_STATUS)

A fixed `## NOW` section, the first thing a resuming agent reads. **≤ ~20–30 lines.** Contains:

- **In progress**: the 1–3 active work units right now (may span branches; not a single linear step).
- **Next step**: the `#1` action + any blocker.
- **Read first**: a minimal handoff list (2–4 files/anchors), not a full map.
- **Key judgment** (optional but important): the most recent direction/priority change that reorients work. It must carry `source=<path> class=root|decision|reported` — the projection carries it verbatim and `cite-check` enforces it.
- **Last refreshed**: projected from the last event's date — **recording an event is what refreshes NOW**.

Refresh `## NOW` at session end, before compaction, and whenever the active frontier changes. History never goes into `## NOW`.

## Work Surface (replaces the linear "phase")

Record current work as a **mutable, structured surface**, not a linear sequence:

- Top plan (may change) → parts → sub-parts → **minimal work units**.
- **Active frontier** = the few units in play now; `## NOW` shows this frontier's current slice.
- Structural changes (new part, reorg, unit closed) are recorded as **surface mutations**, not an ever-growing linear list.

This is recording reality, not doing the project's planning.

## Core Documents

| Document | Role | Updated |
|----------|------|---------|
| **CLAUDE.md** | Single entry + stable anchor + iron rules + these rules | anchor on architecture change; one-line status per session |
| **AGENTS.md** | Thin pointer to CLAUDE.md (never a state copy) | almost never |
| **CURRENT_STATUS.md** | generated projection from events.log (never hand-edited) | regenerated via `project.ps1` |
| **FILE_INDEX.md** | File catalog by category | when files created/deleted |
| **events.log** | Append-only event log (the primitive: history + state) | every state change (open/activate/close/pause/next/judgment/read-first/plan/dead-end) |

## FILE_INDEX.md Rules

- Organize by category (`##`), not time.
- Each entry: `path` — one-line description.
- Category >20 files → create a sub-index.
- **Registration is not optional**: an unregistered file is effectively lost. `check` reports unregistered files as a **red** item.

## events.log Rules

- One structured event per line: `<date> <verb> <payload>`; verb ∈ `unit:open/activate/close/pause`, `next:set`, `judgment:set`, `read-first:set`, `plan:set`, `dead-end:set`, `note:set`. A line starting with `#` is a comment and replays as a no-op.
- `note:set <text>` records housekeeping that changes the state documents without being a unit, a decision, or a plan change (an ops re-embed, a schema migration, a guard fix). Without it such work is unnotable, and the freshness guard correctly keeps reporting it as unrecorded.
- Append-only; never rewrite. The projection is a deterministic replay of this log.
- On a state change, append the corresponding event; `project.ps1` regenerates CURRENT_STATUS. One line is the whole cost of recording state — that is why there is never a good reason to leave work unrecorded.
- A closed unit's payload carries its evidence + class: `unit:close <id> evidence=<path> class=root|decision|reported`. A key judgment carries `source=<path> class=...`.
- No routine archival: the log grows one line per state change. If it ever passes ~5000 lines, compaction is a **rewrite that preserves the projection**, not a trim (§events.log Compaction in the spec).

## Session Start / Resume

1. Read the **AGENT IDENTITY LOCK** at the top of `CLAUDE.md` and state who you are and your scope.
2. Read the **stable anchor** (framework anchor, iron rules, bottom-line principles).
3. Read `## NOW` (in-progress, next step, read-first, key judgment).
4. Read only the task-conditional files that `## NOW`'s read-first list points to.

If context is empty or the user says "resume", run `/doc-harness resume` to do the above **explicitly and verifiably**.

## During Work

- Complete a **meaningful unit** → append its `unit:close` event (with evidence) to `events.log` and re-project `## NOW`.
- Create a file → register it in FILE_INDEX **immediately**.
- Important information → write it down now.
- Watch remaining context: if it drops low (~<20%), refresh `## NOW` before the next tool call. Compaction is an involuntary session end.

## Session End Checklist

- [ ] `## NOW` reflects current in-progress / next step / read-first / key judgment?
- [ ] `## NOW` "last refreshed" updated?
- [ ] CLAUDE.md one-line status refreshed?
- [ ] New files registered in FILE_INDEX?
- [ ] Closed work units have `unit:close` events in `events.log`?
- [ ] Anything still only in context? → write it down.

## Deterministic Toolbelt (optional)

Doc Harness may ship a `tools/` directory with optional deterministic helpers so mechanical bookkeeping does not depend on the agent remembering to do it:

- **One-step record** (`record.ps1`): append the event, re-project, run conformance — recording state is one command, not a ritual.
- **Unregistered-red**: deterministic check that a new file is in FILE_INDEX.
- **Falsifiability pack**: dead pointers, encoding, recurrence, provenance class, freshness of standing conclusions.
- **NOW verify**: bounded NOW, valid UTF-8, resolvable read-first, and **no file changed after the last recorded event** (unrecorded work turns red).
- **Layered search** (`search.ps1`): `all|now|history|files|anchor` — grep the right layer instead of reading everything.
- **Mail**: one-step send, wake-only poll, or a complete background daemon (idle = pure sleep, no LLM) with lock + crash recovery + status; runtime artifacts under `_runtime/`.
- **Nested-project git guard**: pre-commit hook that blocks a directory-level `git add` from swallowing a nested project that has its own `CLAUDE.md`.

These are helpers, not commands to the agent; using them is optional.

## Project Pause

Refresh `## NOW` → record "paused on YYYY-MM-DD. Reason: ..." → set CLAUDE.md status to ⏸️. On resume, treat `## NOW` as possibly stale and confirm with the user.

## Single Source of Truth

Each fact lives in one document. Current state → CURRENT_STATUS (`## NOW`). File catalog → FILE_INDEX. History → `events.log`. Anchor/iron rules → CLAUDE.md. The one-line status in CLAUDE.md is the only allowed redundancy; on conflict, CURRENT_STATUS wins.

## Iron Rule Management

Iron rules live in CLAUDE.md. Add at architecture/scope changes; generally don't delete — annotate `[No longer applicable: reason]`.

## Document Lifecycle

Superseded documents: add `⚠️ SUPERSEDED BY <path>` at line 1, then move to a `## Superseded` category or `_archive/`.

## Optional Long-Horizon Documents

- **`PHILOSOPHY.md`** — principles forged by practice: statement, the practice that forged it, scope, first-recorded date. Home of the "bottom-line principles" referenced by the anchor.
- **`PARKING_LOT.md`** — deferred items with revival preconditions.
- **`RUNBOOK.md`** — operational restart/resume state (tasks, sources, thresholds, commands), distinct from documentation state.

## Optional Inter-Project Communication (inbox/outbox)

Active if `inbox/` and `outbox/` exist.

**Receiving**: read unread → act → set `status: actioned`. Never edit a received message beyond the status field.

Lifecycle: `unread → read → actioned → awaiting-reply → closed`. Set `awaiting-reply` when a reply is owed; `closed` when the thread ends.

**Sending**: filename `YYYY-MM-DD-from-<this-project>-<topic>.md`; YAML `from/to/date/subject/status/priority`; write to this project's `outbox/` AND copy to the recipient's `inbox/`. Put values in the body (snapshots over pointers). If the exchange changed state, record it as an event (`judgment:set`) or in `MAIL_LEDGER.md` — CURRENT_STATUS is generated and cannot be written by hand.

**Pre-send checklist**: `from:` is THIS project; written to THIS `outbox/`; copy targets recipient `inbox/`; no recipient internal docs modified; recipient protocol active; **the recipient can understand the message without my context** (curse-of-knowledge check — include the relevant snapshot in the body, not a pointer).

**Mail ledger (optional)**: at high message volume, maintain a `MAIL_LEDGER.md` for who/when/status/awaiting-reply.

<!-- doc-harness-ops-end -->
