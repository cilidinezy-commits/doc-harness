# PHILOSOPHY — Doc Harness

> **English readers**: this document is the author's working record and is maintained in Chinese.
> The one-line English summary of each principle:
>
> 1. **Zoom out before patching** — when a fix keeps failing, step back and ask whether the problem (or the way you verify it) is what you think it is.
> 2. **The curse of knowledge** — you know what you know; the recipient does not. Assume no shared context, and put the snapshot in the message itself.
> 3. **Delegate the reading, keep only the conclusion** — a lead agent should not hoard raw text in its context; send a sub-agent to read and return findings.
> 4. **A repeated failure becomes a guard** — if the same mistake recurs, stop restating the rule: make it something a machine can turn red.
>
> Full English summary of the design principles: [`README.md`](README.md) (Design philosophy). Normative rules: [`DOC_HARNESS_SPEC.md`](DOC_HARNESS_SPEC.md) §6.

> 来自实践的原则。由具体工作催生的、可推广的教训。
> 每条记录：原则陈述、催生它的实践、适用范围、首次记录日期、**层（会红 / 自动注入 / 可查）**。
> 层规则：能机器验的→会红（做成守卫）；每次都要在场的→自动注入；详情→可查。重申时标 `第 N 次（上次: <ref>）`。
> 原则可复制到兄弟项目的 PHILOSOPHY.md 中；本文件保留为 Doc Harness 的诞生记录。
>
> conclusion_until: 2026-12-31 · verify_via: 本文件的原则由 doc-harness 自用实践定期复核

---

## 1. 深入浅出：视角变换的方法论

**原则陈述**：
我们总是面临着"系统"，可以放大聚焦到细节，也可以后退以更大的视角审视。在遇到问题的时候，要在聚焦和后退观察之间进行切换，以避免陷入细节中盲目操作——不仅不解决问题，还可能带来新的问题。要学会从多层面、多视角去研究和审视问题。

**催生它的实践**：
一个下游项目 部署 Agent 在排查环境失效问题时，连续数小时陷入代码 patch 细节：反复修改文件、写脚本、清除缓存、对比版本差异。直到被叫停后后退一步系统排查，才发现生产环境实际上早已恢复正常；之前的"反复失败"全部是测试方法本身的问题（没有 sudo 权限、环境变量加载方式不对）。如果更早后退审视，看到系统日志中服务已被正常调用，就能避免数小时的无效操作。

**适用范围**：
任何涉及复杂系统排查、多组件交互、环境配置类问题的调试场景。当同一个问题反复出现且 patch 不生效时，强制后退一步，检查"问题是否真的还存在"以及"验证方法是否可靠"。

**首次记录日期**：2026-04-22

**层**：可查（排查启发式，非守卫）

---

## 2. 知识的诅咒：自己知道 ≠ 别人知道

**原则陈述**：
智能体（包括人类和 AI）的一个通病：自己知道的事情，就倾向于认为别人也知道；自己已经（可能经过一番努力和周折）明白的事情，就倾向于认为别人得到一些简单的信息就能轻松明白。在沟通和协作中，必须主动提供完整的背景信息，不能假设对方了解你的上下文、流程、部署结构或历史决策。

**催生它的实践**：
一个下游项目 部署 Agent 在写给 下游系统 的 bug 报告中，使用了一系列内部术语（"外部依赖同步""环境变量引用""systemd 配置"），假设对方理解这些部署流程。对方回信明确指出：他只清楚代码本身，对上线前的修改和准备工作一无所知。第二封报告补充了完整的部署结构、修改历史、本地-服务器关系等背景信息后，对方才能给出精准的根因分析和修复建议。

**适用范围**：
所有跨项目、跨角色、跨团队的沟通场景：写 bug 报告、写交接文档、请求代码审查、发送 inbox/outbox 消息。核心动作：在发送任何请求或报告前，检查"收件人是否知道我默认他知道的一切？"

**首次记录日期**：2026-04-22

**层**：自动注入（跨项目沟通前自检）

---

## 3. 封闭重读委派：主 agent 只留结论，不囤原文

**原则陈述**：
当某个任务高度封闭（自包含、无上下文耦合）且会向主 agent 的上下文灌入大量原文时（例如为查一个事实而通读冗长的 WORKLOG、庞大的 FILE_INDEX 或归档文件），应把"读取并浓缩"委托给一个低智力子代理；子代理只返回浓缩的、带引用的摘要，主 agent 保留结论而非原文。反过来，上下文强耦合的工作不应为了并行而拆给子代理。

**催生它的实践**：
Anthropic 开源的 Claude Commerce Agents 架构给出了子代理的两种适用情形，其中第一种即"任务高度封闭且重上下文"（深度调研子代理翻文档 / 跑代码 / 查数据后只回精简结论）。⚠ **撤回记录（2026-09-07）**：曾把它作为给 agent 的行为规则写入 v1.7.2，后经用户纠正为**越权**——doc-harness 不规定 agent 是否/何时启动子代理；此原则仅在 doc-harness 自身 recall 机制内部可作为可选检索手段，且只委托"读/浓缩"、不委托"判"。

**适用范围**：
任何"需要读完大量文件才能回答一个窄问题"的场景——查历史、查文件索引、翻归档、跑脚本取数后只回结果。也适用于一切以文档为核心的长上下文 agent 工作流。

**首次记录日期**：2026-09-07

**层**：可查（边界教训；已从操作规则撤回）

---

## 4. 反复失败就该变守卫

**原则陈述**：
一条纪律如果只能靠人记得，它的失效是必然事件，只是时间问题。反复复发的纪律不是记性问题，是机制问题。停止它复发的那一刻，不是"又强调了一次"，而是它**变成会红的东西**（守卫）的那一刻。

**催生它的实践**：
一个大型下游项目 同一天在同一功能上犯六次同类错误，其中 4 次是守卫/关口发现的、2 次靠用户提醒、0 次靠读文档想起；三条反复复发的纪律（半截话术 / 目录级 git add 误提交 / 宽泛 except）每一条都是"变成守卫"才真正停住。由此催生 doc-harness v2 的 §6 三层放置 + 复发计数（`check` §1.12）。

**适用范围**：
任何"反反复复出现的问题"。处理顺序：先问"它能不能变成会红的东西？"→ 能则做守卫；不能则住进自动注入层；只写进可查层等于承认它会丢。

**首次记录日期**：2026-09-07

**层**：会红（已做成机制：`check` 复发报告 + `tools/` 守卫）

**复发**：第 5 次（此前散见于用户提醒、lit 反馈、driving manual、foundational-analysis、design-core）

---

## 待考察的原则

以下观察尚未达到"经历 3+ 阶段仍有效"的晋升门槛，暂不录入正式条目，留作观察：

- **遇事不应盲目动手** — 有时候其实就应该先动手再说。此原则高度不够，适用范围模糊，暂不入 PHILOSOPHY.md，可作为具体项目的 driving-manual 条目使用。
