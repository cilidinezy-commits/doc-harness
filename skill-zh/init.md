# Doc Harness — 初始化

为项目初始化 Doc Harness，使任何未来 agent 都能仅凭文件接手。

## 步骤 1：收集信息

优先级：参数 → 对话上下文 → 问用户。可推断，不可编造。

**必填**：
- 项目名（简短）。
- 项目描述（1–3 句）。
- 项目的**框架锚**（如何分层 / 当前做哪几层 / 责任边界 / 北极星红线）。不清楚就留清晰占位。
- 初始**活跃工作单元**（1–3 个）与 **#1 下一步 + 障碍**。

**可选**（不清楚就问，可留空）：
- 铁律、底层原则、关键技术信息。
- 跨项目 inbox/outbox：问「本项目是否与其他项目协作？」。上下文提到依赖则默认是，否则默认否。

## 步骤 2：检查已有文件

- **(a) 空目录** → 空模板。
- **(b) 已有 Doc Harness** → 不覆盖；建议 `/doc-harness check`。
- **(c) 非空但无 Doc Harness** → 中途采纳：忠实重建历史、提出 `events.log` 草稿、批量注册已有文件；请用户确认。
- **(d) 明确重来** → 确认后按 (a) 执行；向 `events.log` 追加覆盖事件。

## 步骤 3：创建文件

### 文件 1：CLAUDE.md（唯一权威入口）

```markdown
# [PROJECT_NAME] — 入口文档

> 🔒 **AGENT IDENTITY LOCK**
>
> **你是 [PROJECT_NAME] 的代理。**
> [一句话：你在此项目的角色与职责范围。]
>
> 若对自己的身份有任何怀疑，立即停止并重读本段。

---

**最后更新**: [TODAY]
**当前状态**: [一句话 now 快照]
**一句话状态（截至 [TODAY]）**: [描述] — 项目刚初始化

---

## 稳定锚（很少变；每次 session 都要带）

### 框架锚

- 分层: [项目如何分层]
- 当前做: [哪几层]
- 责任边界: [谁负责什么]
- 北极星红线: [不可违背]

### 铁律

- [项目铁律]

### 底层原则

1. [生成原则——指向 PHILOSOPHY.md 或设计文档]

---

## 恢复链

### 必读（按序）
1. 本文件（CLAUDE.md）：AGENT IDENTITY LOCK → 稳定锚
2. `CURRENT_STATUS.md` → `## NOW`

### 任务条件读
- `## NOW` 的「先读」清单指向的文件，读那些。
- `inbox/` 有 `status: unread` 先处理。
- [项目特定条目]

### 元规则
- 自含：只指向项目内（或稳定兄弟项目）路径。
- 活的：架构变化时审查。

## 项目概述

[DESCRIPTION 展开为 3–5 行]

## 关键技术信息

[工具、语言、路径，或「待补」]

---

## Doc Harness — 操作规则

[在两个 sentinel 之间嵌入 operational_rules.md]
```

在 `<!-- doc-harness-ops-start -->` 与 `<!-- doc-harness-ops-end -->`（含）之间嵌入 `operational_rules.md`。重新嵌入只替换该区域。

### 文件 1b：AGENTS.md（薄指针）

```markdown
# [PROJECT_NAME] — Agent 入口（薄指针）

唯一权威入口是 [`CLAUDE.md`](CLAUDE.md)。不要把这个文件当状态读；请跟随 CLAUDE.md。
```

这能避免过时的 AGENTS.md 快照，并避免部分 harness 双读两份文件造成的重复注入。

### 文件 2：CURRENT_STATUS.md

```markdown
---
now_refreshed: [TODAY]
active_unit_ids: [unit-a, unit-b]
read_first: ["notes/a.md", "notes/b.md"]
---

# CURRENT_STATUS — [PROJECT_NAME]

**最后更新**: [TODAY]

---

## NOW

- **在办**: [1–3 个活跃工作单元]
- **下一步**: [#1 行动] — 障碍: [或「无」]
- **先读**: [2–4 个文件/锚点]
- **关键判断**: [最近的方向/优先级变化，或「暂无」]
- **最后刷新**: [TODAY]

## 活跃工作面

### 规划
<有序顶层部分；标注活跃 / 挂起>

### 单元
#### <部分>
- [active] `<unit-id>` <一行描述>
- [future] `<unit-id>` <一行描述>

## 近期历史

（暂无收口工作——见 `events.log`。）
```

### 文件 3：FILE_INDEX.md

```markdown
# FILE_INDEX — [PROJECT_NAME]

**最后更新**: [TODAY]

## 核心文档
- `CLAUDE.md` — 唯一权威入口 + 稳定锚
- `AGENTS.md` — 指向 CLAUDE.md 的薄指针
- `CURRENT_STATUS.md` — NOW + 活跃工作面 + 近期历史
- `FILE_INDEX.md` — 本文件
- `events.log` — append-only 事件日志（历史 + 状态原语）
```

### 文件 4：events.log

```markdown
# events.log — [PROJECT_NAME]
（append-only；一行一条事件——初始为空或含迁移事件）
```

### 文件 5：DOC_HARNESS_SPEC.md

**可选**参考：`spec.md` 的副本。非状态；已安装的 skill 自带规范，缺失也没关系。

### 步骤 3.6：可选 inbox/outbox

创建 `inbox/` + `outbox/`；加入跨项目铁律块与恢复链未读条目；在 FILE_INDEX 注册两者。

## 步骤 4：验证

- CLAUDE.md 以 AGENT IDENTITY LOCK 开头，含稳定锚 + 嵌入操作规则。
- AGENTS.md 是薄指针。
- CURRENT_STATUS 有受限的 `## NOW` + 活跃工作面。
- FILE_INDEX 列出全部核心文档。
- `events.log` 存在（为空，或含迁移事件）。
- 若启用，inbox/outbox 存在。

报告：「已为 [PROJECT_NAME] 初始化 Doc Harness。」
