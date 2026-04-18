---
name: doc-harness
description: "基于文档的项目控制系统，让任何 AI 智能体或人类仅通过读取文件就能恢复项目工作状态——无需外部记忆。当用户需要管理长期项目、跨 session 追踪进度、context 丢失后恢复状态、多智能体协作、审计项目文档健康状况、或避免忘记上次做到哪里时，应使用本 skill。触发场景：'/doc-harness init' 与 '/doc-harness check'（显式斜杠命令）；"帮我把这个项目结构化"、"老是忘记做到哪里了"、"智能体 session 之间会忘记上下文"、"整理项目文档"、"审计这个项目"、"上次我们做了什么"等请求；跨周的长期项目（论文、研究、分析、软件模块）；跨项目协调（inbox/outbox 文件级消息）。"
argument-hint: "init [项目名] [描述] | check"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Doc Harness — 基于文档的项目控制系统

Doc Harness 是一套文档管理系统，使任何 AI Agent 或人类协作者能够仅通过阅读文件来理解和恢复项目工作状态——无需任何外部记忆系统。

每个项目创建并维护**五个文档**：
- **CLAUDE.md** — 项目入口（概述、恢复链、铁律、操作规则）
- **CURRENT_STATUS.md** — 活跃状态（车辙/车身/车灯/驾驶手册）
- **FILE_INDEX.md** — 按类别组织的文件目录
- **WORKLOG.md** — 永久工作历史（只增不改）
- **DOC_HARNESS_SPEC.md** — 完整规范（参考文档）

另有两个**可选文档**，当项目真正积累了相应内容时才创建（详见 spec.md 第13章）：
- **PARKING_LOT.md** — 暂缓事项，含复活前置条件
- **PHILOSOPHY.md** — 本项目实践催生的原则

当项目需要与其他项目协调时，可启用一套**可选机制**（详见 spec.md 第14章）：
- **跨项目 inbox/outbox** — 自含式文件消息协议。`inbox/` 和 `outbox/` 目录；带 YAML 前置信息的 Markdown 消息；生命周期 `unread → read → actioned`。完整规范内嵌于 doc-harness 本身，无需外部文档。

## 命令

### `/doc-harness init [项目名] [描述]`

为新项目初始化 Doc Harness。在当前目录创建全部5个文件。

**→ 详见 [init.md](init.md)**

### `/doc-harness check`

审计当前项目的文档健康状况并反思工作原则。

**→ 详见 [check.md](check.md)**

### `/doc-harness`（无参数）

检查当前目录并给出合适的下一步建议：
- **4个核心文件齐全**（CLAUDE.md、CURRENT_STATUS.md、FILE_INDEX.md、WORKLOG.md）→ 建议 `/doc-harness check`。
- **完全没有 Doc Harness 文件** → 建议 `/doc-harness init`（按 `init.md` 第二步执行干净 init 或中途引入）。
- **部分存在**（部分文件存在，其他缺失或损坏）→ 建议 `/doc-harness init` 进入**中途引入模式**（见 `init.md` 第二步 (b)/(c) 分支）；**不要**对损坏的安装建议 `check`。

然后显示以下帮助信息。

## 首要原则："落笔为安"

Context 中的信息早晚彻底丢失。重要信息必须**写入文件**并**注册到 FILE_INDEX**。不写=丢失，不注册=虽存在但不可发现=等同于丢失。

**上下文感知推论**：如果运行环境暴露了 context 使用率（百分比或 token 数），将**剩余不足**（~<20%）视作立即刷新 CURRENT_STATUS 的触发信号（在下次工具调用前完成）；如车身已积累大量未保存工作，考虑立即阶段切换（具体阈值见 `spec.md` §11.2 第 4 条）。压缩等同于非自愿的 session 结束——提前写盘是唯一防御。

## 参考文档

- [init.md](init.md) — 执行 `/doc-harness init` 时读。涵盖干净 init、中途引入、部分状态修复、可选 inbox/outbox 协议启用。
- [check.md](check.md) — 执行 `/doc-harness check` 时读。审计文件健康、恢复链健全性、mid-transition 检测、inbox 状态等。
- [operational_rules.md](operational_rules.md) — `init` 时原样嵌入每个项目 CLAUDE.md 的操作规则。带有 `<!-- doc-harness-ops-version -->` 版本标签，供 check 检测过时嵌入。
- [spec.md](spec.md) — Doc Harness 完整规范（14 章 + 5 附录）。权威文档——其他文件皆从此派生。顶部有目录可供不全读导航。
