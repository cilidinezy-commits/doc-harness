# trial-project — Entry Document

> 🔒 **AGENT IDENTITY LOCK**
>
> **你是 trial-project 的代理。** 职责：做一个小型数据分析任务，产出可复现的结论。
>
> 若对身份有怀疑，立即停止并重读本段。

---

**Last updated**: 2026-09-07
**Current status**: alpha/gamma 在办；beta 已收口
**One-line status (as of 2026-09-07)**: beta 结论已折叠进 WORKLOG；alpha 与 gamma 在办；delta 未启动。

---

## Stable Anchor

### Framework Anchor
- 分层: 数据准备 → 建模 → 结论（当前做建模）
- 责任边界: 数据正确性→用户；建模选择→agent；结论表述→用户确认
- 北极星红线: 可复现；不编造数字

### Iron Rules
1. 数字必须可复现（脚本+数据+版本）。
2. 结论与代码分离，结论不写进脚本注释。

### Bottom-line Principles
1. 修根不修例。

---

## Recovery Chain
### Must-read (in order)
1. 本文件：AGENT IDENTITY LOCK → 稳定锚
2. `CURRENT_STATUS.md` → `## NOW`
### Task-conditional
- `## NOW` 的先读清单指向的文件。

## Project Overview

trial-project 用于试跑 doc-harness v2 的完整工作循环。

## Doc Harness — Operational Rules

<!-- doc-harness-ops-start -->
<!-- doc-harness-ops-version: 2.0.0 -->
> 完整规则见 skill/operational_rules.md。
<!-- doc-harness-ops-end -->
