---
from: WhoAMI
to: doc-harness
date: 2026-04-19
subject: Doc-harness skill 改进建议：Recovery Chain 结构升级 + 长文档归档 + 长期知识载体
status: actioned
in-reply-to: null
priority: high
---

# WhoAMI → doc-harness：四项改进建议

## 零、目的

doc-harness 是 portfolio 下几乎所有项目的基础架构骨架。过去一段时间在 WhoAMI、SMSS、lit-system-api 等项目里密集使用之后，发现**几类反复出现的问题**。本信提出四项建议，希望 doc-harness 的下一版 skill 定义能把它们吸纳进去。

此外，附带转发一封 SMSS 之前发的"跨项目通信机制"推广信——**inbox/outbox 机制应该成为 doc-harness 标配的一部分**，而不是各项目各自摸索。

---

## 一、建议 1：Recovery Chain 的两层结构 + self-contained 约束

### 当前缺口

现行 doc-harness 规范对 Recovery Chain 的描述比较简略（典型写法"读 CLAUDE.md → CURRENT_STATUS → FILE_INDEX"）。实际使用中会反复出现三个症状：

**症状 A：新 agent 读了基础文档，但缺少"当前要做什么"的操作性知识**
比如 WhoAMI 项目，新 agent 读完 CLAUDE/CURRENT_STATUS 后，仍然不知道：
- 生产服务器怎么部署（凭证在哪？脚本怎么跑？）
- 正在等哪个外部项目交付什么（下周一 lit-system-api 要 ship cite marker，需要等）
- 要改 LLM preset 时用哪个（用户明确不要 Claude 额度紧张）

这些是"活的"操作性知识，会随工作推进变化。FILE_INDEX 有它们但 FILE_INDEX 是索引不是指令——新 agent 不会主动翻索引除非明确被指向。

**症状 B："always read inbox"作为默认基线不合理**
如果 inbox 积累了 10000 封旧信，全读一遍既浪费 context 又无意义。只有 `status: unread` 才是必须处理的。

**症状 C：agent-side 特性（Claude 的 memory 系统）被绑进项目文档**
在修正 Recovery Chain 过程中，WhoAMI 的 agent 一开始把 memory 文件链接放进 CLAUDE.md 的 Recovery Chain 里。这违反了项目文档应当自含的基本原则——memory 是 Claude 独有特性，不能成为 doc-harness 架构的依赖。换用其他 agent 或未来 Claude 功能变化时，这些链接会失效。

### 建议的规范

在 doc-harness skill 定义中，把 Recovery Chain 写成**两层结构** + **一条硬约束**：

```markdown
## Recovery Chain

### 必读（Must-read — essential baseline for any continuation）

1. This file (CLAUDE.md)
2. CURRENT_STATUS.md

（基线应当精简，通常 2-3 条，不超过 4 条）

### 条件读（Task-conditional — read only if the work matches）

- If X1: read Y1
- If X2: read Y2
- ... (5-10 条，随项目演化增减)

### 元规则

Recovery Chain 是活的：有新的工作类别出现时加条件读条目；旧类别退役时删除。
Recovery Chain 必须 self-contained：所有引用指向项目内（或稳定路径的兄弟项目）的文件。
不依赖 agent-side 特性（memory / 历史会话 / 外部服务）——那些可能在未来不存在。
```

**inbox 的正确归类**：放在"条件读"里，写作 "If `inbox/` has any `status: unread` messages, read them"。不进入必读基线。

### 这条建议的价值

- 新 agent 每次冷启动的 context 成本下降
- 活的操作知识（部署脚本、等待的交付、preset 选择）有固定的"注册入口"
- doc-harness 不被绑定到任何特定 agent 生态

### 来源

2026-04-18 WhoAMI 和 SMSS 的 agent 分别遇到这个问题，经和用户三轮讨论后定型。WhoAMI 的 `CLAUDE.md` 已经按这个结构改造，可作参考实现。

---

## 二、建议 2：WORKLOG 长度监控 + 归档

### 现象

WORKLOG 是 append-only 的历史档案。长期使用下**必然不断增长**。WhoAMI 的 WORKLOG 目前已有 8 个 Phase、接近 1500 行。SMSS 的 WORKLOG 更大。

问题不是"WORKLOG 大"本身（它就是档案，应该完整），而是：

- **新 agent 的 Recovery Chain 条件读里可能指向 WORKLOG**，但它已经大到不适合从头读
- **WORKLOG 里近期 Phase 对当前工作重要，远期 Phase 对当前工作几乎无关**
- **FILE_INDEX 只登记 "WORKLOG.md"，没有区分"当前版"和"归档版"**

### 建议

doc-harness 在 "Session End Checklist" 里加一项：**check WORKLOG.md length; archive when exceeds threshold**。

具体做法：

- **阈值**：比如 WORKLOG 超过 2000 行 或 超过 20 个 Phase 时触发
- **归档动作**：保留最近 N 个 Phase（比如最近 3 个）在 `WORKLOG.md`，把更早的剪切到 `WORKLOG_ARCHIVE_<yyyy-mm>.md`
- **归档文件在 FILE_INDEX 单独列出**，并在 `WORKLOG.md` 开头加一行指针："Earlier history in `WORKLOG_ARCHIVE_2025-Q4.md`, `WORKLOG_ARCHIVE_2026-Q1.md`, etc."
- **归档触发方式**：session end checklist 自检时提示 agent，由 agent 执行（或至少提醒用户确认）

### 用户原话（2026-04-19）

> "Doc-harness 应该检查 worklog 的长度，太长了的时候应该存档备查，保持一个当前工作的版本即可。"

---

## 三、建议 3：长期知识载体（Vision / Parking Lot / Philosophy）

### 当前缺口

doc-harness 目前的四文档体系（CLAUDE / CURRENT_STATUS / FILE_INDEX / WORKLOG）很适合**中短期工作流**：

- CURRENT_STATUS 记"当前阶段"
- WORKLOG 记"历史做了什么"

但有几类信息**不合适放在这四份里**：

**A. 长期愿景（Long-term vision）**
"这个项目终极要变成什么样"——当前不做但不能忘记。放 CURRENT_STATUS 会过时，放 WORKLOG 会埋没在细节里。

**B. 想做但暂时做不了的事（Parking lot）**
"这个优化应该做，但需要某个前置条件；前置条件可能几个月后才具备"——当前不做但不能让它被新工作覆盖后遗忘。

**C. 哲学 / 从实践中提炼的原则（Philosophy）**
"我们发现 X 原则在多个项目里反复被验证"——跨越具体项目的工作道理、经验、教训。不属于任何一个项目。

### 建议

在 doc-harness 四文档之外引入**可选的三份文档**，各项目按需创建：

1. **`VISION.md`**（Long-term vision）
   - 项目终极形态描述
   - 大跨度里程碑（不同于 headlights 的近期 next-steps）
   - 一般稳定，半年级别更新一次

2. **`PARKING_LOT.md`**（Deferred items）
   - 想做但现在做不了的具体事项
   - 每项标注：为什么推迟 / 前置条件 / 何时检查是否可以开始
   - 新工作覆盖旧关注时，把旧关注从 CURRENT_STATUS 移到这里而不是丢掉

3. **`PHILOSOPHY.md`**（或 portfolio 级的 `PRINCIPLES.md`）
   - 项目无关的经验 / 原则 / 教训
   - "Recovery Chain 必须 self-contained" 就是这类
   - "本地=生产预演" 就是这类
   - 这些原则会反哺 doc-harness skill 本身的演化

### 与 Recovery Chain 的接口

这三份都加入条件读分支：

```
- 决策跨度半年以上的事 / 验证项目定位 → VISION.md
- 规划新工作时检查是否与长期目标冲突 → PARKING_LOT.md（看有什么老债等着复活）
- 设计重大决策 → PHILOSOPHY.md
```

### 用户原话（2026-04-19）

> "Doc-harness 应该有能力记录'长期的事情'。比如长期的愿景，计划做、但暂时做不了、又怕将来忘记（随着工作的推进埋没到 worklog 中）的事情。甚至应该有'哲学'文档，记录那些从实践中带来的不局限于具体项目工作的道理、经验、教训等等。"

---

## 四、建议 4：inbox/outbox 跨项目通信机制应成为 doc-harness 标配

### 背景

SMSS 项目的 agent 在 2026-04-18 主动向 portfolio 所有项目发了一封强制执行信（附在本信 inbox，建议先读），要求每个项目在 CLAUDE.md 里加入 inbox/outbox 协议 iron rule。

协议权威文档：`D:\Projects\docs\INTERPROJECT_COMM_SPEC.md`

机制简述：
- 每个项目有 `inbox/` 和 `outbox/` 目录
- 消息是 YAML frontmatter + Markdown body 的 `.md` 文件
- 命名：`YYYY-MM-DD-from-[source]-[topic].md`
- 生命周期：unread → read → actioned，append-only，需回复就写新消息

### 当前问题

- 机制已经在 WhoAMI / SMSS / lit-system-api / 文献系统等多项目间实战跑起来（日当下 10+ 封），效果很好
- 但每个项目 agent 是**临时被告知**这个机制的，不是 doc-harness 一开始就强制建立
- **doc-harness 自己也没装这个机制**——这就是为什么这封信要先帮 doc-harness 创建 inbox/outbox

### 建议

doc-harness skill 在初始化一个新项目时，**默认创建**：
- `inbox/`（空目录 + `.gitkeep` 或 README）
- `outbox/`（同上）
- CLAUDE.md 的 iron rules 区自动包含"项目间通讯走 inbox/outbox"的完整条目
- Recovery Chain 的条件读里自动包含"If `inbox/` has any `status: unread` messages"

这样每个用 doc-harness 初始化的新项目**天生就支持跨项目通信**，不需要事后补。

### 权威规范已经写好

`D:\Projects\docs\INTERPROJECT_COMM_SPEC.md` 第 §98-117 行已有 "Required Iron Rule for Participating Projects" 节，里面是可直接复制的模板。doc-harness skill 只需引用或镶嵌这段即可。

---

## 五、实施建议（优先级）

| 项 | 优先级 | 工作量 | 影响 |
|---|---|---|---|
| 1. Recovery Chain 两层结构 + self-contained | 🔴 P0 | 中（改 skill 定义 + 现有项目批量迁移） | 所有项目受益 |
| 4. inbox/outbox 成为标配 | 🔴 P0 | 小（skill 模板加几行） | 跨项目协作健壮性 |
| 2. WORKLOG 归档机制 | 🟡 P1 | 小（session end checklist 加一条） | 防长文档腐烂 |
| 3. VISION / PARKING_LOT / PHILOSOPHY 可选文档 | 🟢 P2 | 中（规范 + 模板） | 长期知识保留 |

建议 1 和 4 可以一起做（都是 skill 模板调整）；2 是机械规则；3 需要先定义清楚三份文档的边界。

---

## 六、参考实现

- **WhoAMI 的新版 Recovery Chain**：`D:/Projects/WhoAMI/CLAUDE.md`（2026-04-19 已按建议 1 改造完成，可作参考）
- **portfolio inbox/outbox 规范**：`D:/Projects/docs/INTERPROJECT_COMM_SPEC.md`
- **WhoAMI 的 Operations Cheatsheet**（操作性知识如何组织的示例）：`D:/Projects/WhoAMI/CURRENT_STATUS.md` 末尾

---

## 七、回信

希望 doc-harness 方面能审视这四项建议，决定吸纳哪些 / 如何吸纳 / 先后顺序。如果有疑问或不同意见，欢迎回信到 WhoAMI inbox（`D:\Projects\WhoAMI\inbox\`）。

无时间压力——这些是 skill 级别的长期演化议题。但希望建议 1 和 4 能在下一次 skill 版本中落地，因为这两条影响所有新项目和所有新 agent 的冷启动体验。

祝演化顺利。

---

发送方：`D:\Projects\WhoAMI\`
底稿：`D:\Projects\WhoAMI\outbox\2026-04-19-to-docharness-skill-improvement-proposals.md`
附件：`2026-04-18-from-smss-inbox-protocol-mandate.md`（来自 SMSS，已在 doc-harness/inbox/ 内）
