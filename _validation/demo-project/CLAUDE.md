# demo-extract — Entry Document

> 🔒 **AGENT IDENTITY LOCK**
>
> **你是 demo-extract 项目的代理。** 职责：维护文献信息提取引擎的元语体系与检索层。
>
> 若对身份有怀疑，立即停止并重读本段。

---

**Last updated**: 2026-09-07
**Current status**: 检索层在办 3 件；F49 门修复收尾
**One-line status (as of 2026-09-07)**: F49 完成判定门推不开，已修 C1-C6，余 C7 结构化交代；出口字段名 fail-open 对账中；外部题库待扩。

---

## Stable Anchor

### Framework Anchor

- 分层: ①数据底座（用户责）→ ②元语体系 → ③检索层（当前只做）→ ④加工层（未来）。
- 责任边界: 数据准不准→用户；意图→检索层上游；答案散文→加工层（未来）。
- 北极星红线: 归因诚实；「库里的客观事实」与「系统的加工」严格分离。

### Iron Rules

1. 中英同步；spec 权威；本地 git 备份、发布需确认。
2. 快照优于指针；不改对方内部文档。

### Bottom-line Principles

1. 出口侧对偶：机制知道的事，没有可计算的办法送出门，实践上等于不知道。
2. 纪律反复失败就该变守卫。
3. 修根不修例：同一形状的缺陷连修三次就停下来找根。

---

## Recovery Chain

### Must-read (in order)
1. 本文件：AGENT IDENTITY LOCK → 稳定锚
2. `CURRENT_STATUS.md` → `## NOW`

### Task-conditional
- `## NOW` 的「先读」清单指向的文件。

## Project Overview

demo-extract 是文献信息提取引擎的最小演示项目，用于验证 doc-harness v2 的接手能力。

## Doc Harness — Operational Rules

<!-- doc-harness-ops-start -->
<!-- doc-harness-ops-version: 2.0.0 -->
> 完整规则见 skill/operational_rules.md（嵌入区）。
<!-- doc-harness-ops-end -->
