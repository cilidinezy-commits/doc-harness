---
name: doc-harness
description: "Doc Harness：基于文档的项目控制系统。使用 '/doc-harness init' 为新项目创建状态文档，或使用 '/doc-harness check' 审计健康状况并反思工作原则。"
argument-hint: "init [项目名] [描述] | check"
allowed-tools: Read, Write, Bash, Glob, Grep
---

# Doc Harness — 基于文档的项目控制系统

Doc Harness 是一套文档管理系统，使任何 AI Agent 或人类协作者能够仅通过阅读文件来理解和恢复项目工作状态——无需任何外部记忆系统。

每个项目创建并维护**五个文档**：
- **CLAUDE.md** — 项目入口（概述、恢复链、铁律、操作规则）
- **CURRENT_STATUS.md** — 活跃状态（车辙/车身/车灯/驾驶手册）
- **FILE_INDEX.md** — 按类别组织的文件目录
- **WORKLOG.md** — 永久工作历史（只增不改）
- **DOC_HARNESS_SPEC.md** — 完整规范（参考文档）

## 命令

### `/doc-harness init [项目名] [描述]`

为新项目初始化 Doc Harness。在当前目录创建全部5个文件。

**→ 详见 [init.md](init.md)**

### `/doc-harness check`

审计当前项目的文档健康状况并反思工作原则。

**→ 详见 [check.md](check.md)**

### `/doc-harness`（无参数）

显示帮助。根据当前目录是否存在 CLAUDE.md 建议使用 `init` 或 `check`。

## 首要原则："落笔为安"

Context 中的信息早晚彻底丢失。重要信息必须**写入文件**并**注册到 FILE_INDEX**。不写=丢失，不注册=虽存在但不可发现=等同于丢失。

## 参考文档

- [operational_rules.md](operational_rules.md) — 嵌入每个项目 CLAUDE.md 的操作规则（约110行）
- [spec.md](spec.md) — Doc Harness 完整规范：设计原理、实战示例、边缘情况
