# 微信群推广文案

---

**【你的 AI 编程助手是不是也得了"失忆症"？】**

你有没有遇到过这种情况：

💬 跟 Claude Code 聊了3小时，改了一堆代码，context 一压缩，新会话进来，它一脸茫然地问："今天我们做什么？"

💬 同时维护两个项目，AI 读着读着 Project B 的代码，突然开始往 Project A 的仓库里写文件……

Chat 历史不是记忆。Context window 是有限的。MEMORY.md 是 Claude 私有的黑盒，换一个 agent 就全没了。

---

**【Doc Harness —— 给 AI agent 配一个"交接班本"】**

这是一个文件式的项目控制系统。它在你项目根目录创建 5 个 Markdown 文档，AI 每次开始工作先读这 5 个文件，就像人类同事交接班看笔记本一样——

- **CLAUDE.md** → 项目说明书（我是谁、规则、从哪开始）
- **CURRENT_STATUS.md** → 工作进度（刚做了什么、现在在做什么、下一步做什么）
- **FILE_INDEX.md** → 文件目录（项目里有什么文件、干什么用的）
- **WORKLOG.md** → 工作日志（完整历史，只增不改）
- **DOC_HARNESS_SPEC.md** → 完整规范（遇到边缘情况查这个）

**核心原则就一句话："落笔为安"——重要信息不写进文件，就等于丢了。**

---

**【5 个命令，像用 Git 一样管理 AI 的记忆】**

| 命令 | 人话解释 | 什么时候用 |
|------|---------|-----------|
| `/doc-harness init` | 初始化项目文档（30秒搞定） | 新项目启动，或已有项目补文档 |
| `/doc-harness check` | 健康检查+原则反思 | 每1-2小时运行一次，防止跑偏 |
| `/doc-harness sync` | 自动修复文档漂移 | 发现文件没登记、日期过期时 |
| `/doc-harness flush` | 紧急存档（防 context 爆炸） | 准备关窗口/换话题前必做 |
| `/doc-harness recall` | 项目内搜索（带出处引用） | "我们上次为什么选 PostgreSQL？" |

** flush 是最强的** —— 它把 context 里所有重要信息系统化地提取到文档中。flush 完之后，就算 context 被清空，下一个 agent 读 5 个文件就能完全恢复状态，就像什么都没发生过。

---

**【v1.6.0 新功能 —— AI 身份锁】**

这次更新解决了一个真实事故：有个 agent 调研别的项目代码太久，把自己当成那个项目的 agent 了，结果往错误的仓库写文件、改别人的内部文档、发信时 from 字段写错项目名……

v1.6.0 在 CLAUDE.md 顶部加了一个 🔒 **AGENT IDENTITY LOCK**：

> **你是 [项目名] 的代理。**
> 如果你对自己的身份有任何怀疑，立即停止操作并重新读取本段落。

每次执行 doc-harness 命令前、每个 session 开始时，都会强制确认一次身份。再也不怕 AI "认错家门"。

---

**【怎么安装】**

**Claude Code 用户**：
```
/plugin marketplace add cilidinezy-commits/doc-harness
/plugin install doc-harness
```

**Kimi CLI 用户**：
把 `kimi-skill/` 目录的内容丢进 `~/.kimi/skills/doc-harness/`

**手动安装**：
https://github.com/cilidinezy-commits/doc-harness

---

**【我用了一个月后的感受】**

以前：session 一断，前功尽弃，重新解释需求要半小时。
现在：`/doc-harness flush` → 关窗口 → 新开 session → AI 读 5 个文件 → 直接继续，零解释成本。

以前：多项目并行时，AI 经常搞混上下文。
现在：身份锁 + 文件隔离，每个项目的记忆独立且完整。

这玩意不是让 AI 更聪明，而是让 AI 的"健忘"不再成为问题。

---

MIT 协议，开源免费。有问题可以直接在 GitHub 提 issue，或者在这群里@我。

👆 值得一试。
