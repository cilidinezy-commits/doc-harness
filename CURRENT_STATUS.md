---
now_refreshed: 2026-09-20
active_unit_ids: [真实项目试用]
read_first: ["README.md", "RELEASING.md", "notes/validation.md"]
---

# CURRENT_STATUS

## NOW

- **Active**: 真实项目试用
- **Next**: 把更新后的 skill（含新守卫与本地化修正）部署到试用项目与本地 Kimi 安装并重嵌其 ops 块；随后给该下游项目回信（指出其来信缺 YAML 头部 + 通报我们采纳了哪条判据、修出什么） blocker=无
- **Read-first**: README.md, RELEASING.md, notes/validation.md
- **Key-judgment**: 专用分支在模型换代后会变成负资产：v1.6 的 Kimi 分叉既过时又会（按同名优先规则）遮蔽新版；跨 agent 的正确形态是同一份 skill + 说清各家发现规则 source=notes/kimi-claude-interop.md class=root
- **Refreshed**: 2026-09-20

## Work Surface

### Plan
- 底层调研
- 核心设计
- 事件日志原语
- 工具带
- 自应用/验证
- 发布（待用户确认）

### Units
- [done] `核心文档重写` skill/命令全量 v2.0.0
- [done] `确定性工具带` 14 件
- [done] `自应用与对抗验证` 
- [done] `吸收两方评审` 共识落地
- [future] `发布` README/插件/GitHub/安装副本
- [done] `可用性收口` 单命令记录/工具随skill走/投影策略
- [done] `自洽收口` 文档/命令/工具同一模型+单一解析器+接手测试
- [active] `真实项目试用` 把 v2 装进 某真实项目 并让它用一段时间
- [done] `v2发布` 把 v2.0.0 发布到 GitHub（发布树自洽 + 门面与产品一致）
- [done] `对外口径快照` 回应 某下游项目对 v2 对外描述与对外材料一致性的请求

## Recent History (closed units)
- [done] `核心文档重写` evidence=skill/spec.md class=root
- [done] `确定性工具带` evidence=tools/ class=root
- [done] `自应用与对抗验证` evidence=notes/validation.md class=root
- [done] `吸收两方评审` evidence=notes/validation.md class=decision
- [done] `可用性收口` evidence=notes/validation.md class=root
- [done] `自洽收口` evidence=tools/handoff-test.ps1 class=root
- [done] `v2发布` evidence=notes/validation.md class=root
- [done] `对外口径快照` evidence=README.md class=root

## Notes (housekeeping)
- 2026-09-18 隐私复查（用户要求）：整个公开历史被重写——从每个提交里删除两份会话导出与那份事故报告，私人邮箱替换为 GitHub noreply，残余个人语境词改泛称；11 个 tag 与 master 全部强推并用全新 clone 复核（个人信息 0 命中、旧提交不可达、闸门 PASS）
- 2026-09-18 本地禁止词表加入私人邮箱、并把会话导出列入不发布清单；三个 plugin manifest 的联系邮箱改指 GitHub noreply，避免下一次发布把私人信息带回去
- 2026-09-18 toolbelt portability: child processes re-run the same PowerShell host; Windows-only path separators and regexes removed for Linux/macOS (CI pending)
- 2026-09-18 Kimi 线重新评估（用户投了 Kimi）：仓库里的 v1.6 专用分叉 kimi-skill/ 已删除（它教的是已淘汰的五文档/车身模型，对 Kimi 岗位是负资产）；README（中英）改为「同一个 skill 目录即装即可」并写明官方发现规则与出处；本地 ~/.kimi/skills/doc-harness 由 v1.6.0 换成 v2.0.0（中文版），旧版备份到 ~/.kimi/backup-doc-harness-v1.6-live-20260918/
- 2026-09-18 已发信给下游项目：把「支持 Kimi CLI」写回对外材料（附官方发现规则出处、复制式安装命令、以及「尚未做会话级验证」的诚实边界）；并已在全新 clone 上复核：kimi-skill/ 已不在树中、README 中英均含 Kimi 安装行、闸门 PASS
- 2026-09-18 完成度审计（用户提问）发现并修掉两处真缺口：①文档把命令写成 Claude Code 专有形式——SKILL.md 与 spec §8 现在写明「命令名是约定不是功能」并给出 Kimi（/skill:doc-harness）与其它 agent（自然语言）的调用方式；②文档默认工具带就在项目里——SKILL.md 现在写明工具带在仓库的 tools/（不在 skill 目录内）且可选，并点明缺它时变弱的两件事；另给两版 SKILL.md 补 license: MIT 前置字段（Kimi 官方字段表）
- 2026-09-18 工具带随 skill 走：已把 tools/ 复制进 skill/tools 与 skill-zh/tools（各 31 个文件），并新增 toolbelt-sync 守卫强制三份逐字节一致（空转检验：改一个字节即报红；复制成嵌套目录也会被它抓出——本轮就抓到一次）；ops-embed 增加「从自己所在 skill 目录找 operational_rules.md」的候选路径，安装态因此可用
- 2026-09-18 安装态实测：用 skill-zh/tools/record.ps1 驱动一个真实项目——事件成功追加、投影成功生成；ops-embed -Check 能从 skill 目录自身发现操作规则；toolbelt-sync/skill-consistency 在安装态正确 SKIP。本地 ~/.kimi/skills/doc-harness 已更新为含 tools/ 的 v2（41 个文件）
- 2026-09-20 处理一个下游项目的来信（《指导者↔被指导者：转达工作方式》v1，无 YAML 头部）：采纳其「支持多语言有四层」判据（含第③层渲染、第④层各写各的），用它扫出并修掉英文文档中全部汉字——README 示例整段改为英文示例、spec 的 CJK 示例与中文括注、check 的输出模板、operational_rules 的四态与 NOW 字段括注；并把它做成会红的守卫「英文文档不得出现 CJK」（保留 README_zh/doc-harness-zh/skill-zh 这类指名中文版的例外），空转检验通过
- 2026-09-20 英文读者体验补齐：PHILOSOPHY.md 顶部加英文导读＋四条原则一句话摘要（原文仍以中文维护，符合「各写各的」）；README 明确链接的两份中文笔记在顶部标注「以中文维护 + 英文摘要位置」；ops 块已重新嵌入 doc-harness 自身 CLAUDE.md
- (+9 older in events.log)

## Dead ends (negative ledger)
- 可用性收口: 试过把投影做成不落盘、用时现算，但人类可读快照更有价值，故保留落盘+conformance校验
- plan 多行结构：试过把 parts 做成一等元素，最终让 unit-id 的 part/unit 前缀承载结构（少一个词汇表，扁平项目零成本）
- 单一默认 class：迁移工具若只给一个默认 class，会把收口（root）与判断（decision）混为一谈；改为两个独立开关
- 用显式清单枚举「要排除发布」的文件：一次就漏掉当天新到的一封信；应让排除规则从磁盘现状枚举（pathspec），而不是靠记忆列举
- 用文件 mtime 判断「有没有未记录的工作」：在发布/克隆场景下必然误报（mtime=克隆当天）；必须优先用 git 状态（未提交改动 / 未触碰 events.log 的提交），非 git 项目才退回 mtime
