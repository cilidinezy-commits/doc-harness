---
now_refreshed: 2026-09-18
active_unit_ids: [真实项目试用]
read_first: ["README.md", "RELEASING.md", "notes/validation.md"]
---

# CURRENT_STATUS

## NOW

- **Active**: 真实项目试用
- **Next**: 等该下游项目回《引用清单》逐句核对；把发布流程固化为脚本，避免手抄排除清单再次漂移 blocker=无
- **Read-first**: README.md, RELEASING.md, notes/validation.md
- **Key-judgment**: 「会红」的判据必须覆盖到规则本身：语言一致、入口唯一、单解析器、不得教回旧模型——这些过去都靠人眼评审，现在都有机器判据 source=notes/validation.md class=root
- **Refreshed**: 2026-09-18

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
- 2026-09-14 新增 note:set 动词（改状态文档但非单元/判断/计划的杂务可记录）；渲染器去除非 ASCII 字面量；record.ps1 区分「记录失败」与「其它守卫变红」；ops 块重新嵌入
- 2026-09-18 v2 skill+工具带已部署到 Misc（项目内英文版）与 agent 级（中文版）；Misc 的 ops 块重新嵌入、CURRENT_STATUS 重投影；写信托它自修 3 项数据缺陷；batch-register 逗号粘连与 mail-send 收件方 inbox 缺失已修
- 2026-09-18 v2.0.0 已发布（tag v2.0.0）：README 中英重写、manifest 升 2.0.0、仓库描述与 topics 更新；下游项目来信已处理并回信
- 2026-09-18 发布树复审：从 GitHub 全新 clone 后跑完整闸门 PASS；并把 now-verify 的「未记录的工作」判定从文件 mtime 改为 git 状态（否则任何 clone 都会因 mtime=克隆当天而自判红），因此在任何人依赖 v2.0.0 之前修正了发布提交
- 2026-09-18 新增 zh-sync-check：铁律 1「中英同步」从人眼核对变成机器判据（文件集合/标题层级序列/围栏数/表格行数一致），并做空转检验（删一个中文小节即红）；已接入 conformance
- 2026-09-18 审计发现并补齐：flush.md 两版都补上 events.log 指名（此前 9 个 skill 文档中唯一没点名原语的）；新增 entry-check（身份锁 + AGENTS.md 薄指针，含空转检验）；handoff-test 夹具因缺身份锁被新守卫抓出并修正
- 2026-09-18 隐私修正：发布记录与状态事件里泄露的私人语境/兄弟项目名已从 notes/validation.md、events.log、CURRENT_STATUS.md 改写（原日志归档到 _archive/events-pre-redaction-2026-09-18.log，不发布）
- 2026-09-18 新增发布机制：.publish-exclude.txt（不发布的路径）与 .publish-terms.txt（禁止词表）两个本地数据文件 + tools/publish-scan.ps1；RELEASING.md 要求发布前在发布树上跑扫描——排除清单与禁止词表从此由数据枚举，不再靠当场回忆

## Dead ends (negative ledger)
- 可用性收口: 试过把投影做成不落盘、用时现算，但人类可读快照更有价值，故保留落盘+conformance校验
- plan 多行结构：试过把 parts 做成一等元素，最终让 unit-id 的 part/unit 前缀承载结构（少一个词汇表，扁平项目零成本）
- 单一默认 class：迁移工具若只给一个默认 class，会把收口（root）与判断（decision）混为一谈；改为两个独立开关
- 用显式清单枚举「要排除发布」的文件：一次就漏掉当天新到的一封信；应让排除规则从磁盘现状枚举（pathspec），而不是靠记忆列举
- 用文件 mtime 判断「有没有未记录的工作」：在发布/克隆场景下必然误报（mtime=克隆当天）；必须优先用 git 状态（未提交改动 / 未触碰 events.log 的提交），非 git 项目才退回 mtime
