# v2.0.0 验证记录（持续更新）

## 已验证

- **中英同步**：`skill/` 与 `skill-zh/` 各 9 个文件一一对应（check/flush/init/operational_rules/recall/resume/SKILL/spec/sync）。
- **版本一致**：spec（EN/ZH）`v2.0.0`；operational_rules 与 doc-harness 自身 CLAUDE.md 的 `doc-harness-ops-version: 2.0.0`。
- **工具带可运行**：`tools/now-verify.ps1`（NOW ≤30 行、无乱码）与 `tools/unregistered.ps1`（启发式未注册检查）在 doc-harness 上运行通过。
- **自应用到手链**：doc-harness 的 CLAUDE.md（AGENT IDENTITY LOCK → 稳定锚 → 恢复链）+ CURRENT_STATUS（`## NOW` → 活跃工作面）+ AGENTS.md（薄指针）一致，新 agent 可先读入口定向。
- **端到端接手演练（demo-project）**：用新版模板建了 `_validation/demo-project`（三单元跨分支 + 关键判断 + 先读清单）。零上下文新 agent 按「CLAUDE.md 稳定锚 → `## NOW`（在办 3 件 / 下一步 + 障碍 / 先读 / 关键判断）→ 先读文件」即可正确定向；`now-verify` 与 `unregistered` 均 PASS，先读目标文件都存在。
- **F4 自证**：`now-verify.ps1` 初版的中文字面量在 PowerShell 5.1 被按 GBK 读成乱码（正是 F4 编码失败模式），已改为用码点构造「最后刷新」并加新鲜度判定，修复后对 doc-harness 与 demo 均 PASS。
- **对抗验证（adversarial-project）**：故意造 4 个缺陷（NOW 过期 6 天 / 未注册文件 / 第 3 次复发仍标可查 / AGENTS.md 过时副本），`now-verify`（过期→FAIL）、`unregistered`（未注册→FAIL）、`recurrence`（第3次+可查→FAIL）都正确抓红；并当场暴露并修复了 `recurrence.ps1` 初版一个真 bug（`-notmatch` 中文字面量在 `-File` 上下文失效，改用码点 + `IndexOf` 后修复）。

## 自洽收口验证（2026-09-13）

### 机制回归测试（新）

`tools/handoff-test.ps1` 在临时目录造一个**刻意非线性**的夹具（两个部分 A/B，open/activate/close 交错，一个挂起、一个死路、一个已收口、一条杂务记录），首轮 18 项断言全绿，此后加入迁移与 note 断言，现为 **24 项**：log 可解析（`#` 注释被忽略）、投影确定（两次渲染逐字节一致）、`## NOW` 有界、活跃前沿＝被 activate 的单元且按 open 序、挂起单元不在在办、已收口单元带 evidence、下一步带 blocker、先读路径全部存在、关键判断带 source+class、否定台账能回放、`#### A`/`#### B` 结构标题出现、plan 被切成部分而非一行、杂务记录带日期进投影；并且**反证守卫不空转**：删掉一条 `unit:open` → 立刻报 `activate before open`；手改 CURRENT_STATUS → 立刻判定与投影不符；缺 `class=` 的旧日志在迁移前被 `cite-check` 抓红、迁移后转绿且归档存在。

### 守卫自己红了两次（这是好兆头）

- 新加的 `encoding-guard`（工具脚本必须纯 ASCII）第一次运行就抓到我自己刚写的 `handoff-test.ps1` 里两个中文字面量——正是 F4 那类编码失败模式（PS 5.1 按 ANSI 读无 BOM 脚本）。夹具改成 ASCII 后转绿。
- 新的「未记录的工作」判定（`now-verify`：`now_refreshed` vs 项目文件最新改动）在本仓库当天的第一次运行即红：`skill/check.md`、`skill/SKILL.md`、`skill-zh/check.md` 当日改过而最后事件是 09-12。记录事件后转绿。守卫不是装饰。

### 批量记录的真实缺陷（已修）

`record.ps1` 新增批量模式时发现：经 `powershell -File` 调用时，数组参数会被**粘成一个逗号字符串**，三条事件曾静默记成一条（`unit:open` 有效 ⇒ 校验通过 ⇒ 无人察觉）。现在：逗号粘连直接 fail-closed 拒绝；新增 `-EventsFile`（UTF-8，一行一条，`#` 注释与空行跳过）作为可靠批量路径；探针确认中文经该路径落盘无乱码。

### ops 嵌入不再靠人仔细

`tools/ops-embed.ps1` 让「重新嵌入操作规则」成为机械操作：只替换哨兵之间区域，其余字节不动，写回 LF + UTF-8 无 BOM；`-Check` 只比对不写。它对 doc-harness 自己的 CLAUDE.md 先报 FAIL（那里原本是摘要式 stub + 旧版本摘要），重新嵌入后 PASS；`conformance.ps1` 已接入它的 `-Check` 模式（conformance 永不写文件）。

## doc-harness 自检（完整 check 1.1–1.12，2026-09-07）——历史记录（v1 五文档模型时期）

- 1.1 核心文件：CLAUDE.md / CURRENT_STATUS.md / FILE_INDEX.md / WORKLOG.md ✅；AGENTS.md（146 字符薄指针）✅；DOC_HARNESS_SPEC.md ✅。
- 1.2 NOW 新鲜度：今天 ✅。
- 1.3 NOW 行数/编码：7 行、有效 UTF-8 ✅。
- 1.4 FILE_INDEX：`unregistered` PASS ✅。
- 1.5 WORKLOG 目录：与 `##` 标题一致（Phase 4/3/2/1）✅。
- 1.6 WORKLOG 长度：532 行 <1000 ✅。
- 1.7 收件箱：3 条均 actioned、0 未读；`_archive/` 3、`_malformed/` 1 ✅。
- 1.8 入口唯一：AGENTS.md 是薄指针 ✅。
- 1.9 中继一致：NOW（在办=审计修复/验证/发布门槛）与活跃工作面一致 ✅。
- 1.10 操作规则版本：`doc-harness-ops-version: 2.0.0` ✅。
- 1.11 身份锁：AGENT IDENTITY LOCK + 项目名 + 自检 ✅。
- 1.12 复发：`recurrence` PASS（唯一 ≥3 次复发原则已标会红）✅。

## 完整工作循环试用（trial-project，2026-09-07）

用 v2 模板建了一个「数据准备→建模→结论」的中期项目：`alpha`/`gamma` 在办、`beta` 已收口折叠进 WORKLOG、`delta` 未启动；NOW 含关键判断「量级对样本选择敏感 ⇒ 加 gamma 稳健性」。三件工具全部 PASS，先读目标都存在。

**零上下文接手演练**：只读 `CLAUDE.md`（身份→稳定锚）→ `CURRENT_STATUS.md ## NOW` → 先读（`beta-findings.md`、`WORKLOG#beta`），即可正确说出：身份/范围；活跃前沿=alpha+gamma；#1 下一步=完成 gamma 异方差稳健标准误（无障碍）；关键判断=量级敏感→加 gamma；beta 已收口（中介解释约 40%）且 delta 未启动。与真值一致。

## 待验证（发布前必做）

- **真实项目试用（进行中）**：把 v2 装进一个真实项目，由它的 agent 用新模型记录一段时间；再回看它的文档体系是否真的更好读、更好接手。
- 用真正大型（上千文档量级）的真实项目做一次迁移/接手演练——夹具再像也不是真实。
- 后台邮件守护在长跑下的表现（崩溃恢复、锁、静默期、连续失败的暂停）尚未做长时间实测。
- 发布态版本号（README / `.claude-plugin` / marketplace）——发布时才需要。

## 真实项目首轮（2026-09-14，项目名从略）

把 v2 部署到一个真实项目（项目内 `.claude/skills/doc-harness-v2/` 英文版；agent 级 `~/.agents/skills/doc-harness-v2/` 中文版）之前，先用**新工具只读扫描**了它的现状。这个被旧版 v2（两周前）管着的项目，在 7 个守卫上红了 4 个：

| 守卫 | 发现 | 性质 |
|------|------|------|
| `now-verify` | `## NOW` 没有刷新标记（旧渲染器不输出该行）；且「有未记录的工作」——CLAUDE.md 于 09-09 被改而最后事件是 08-21 | 机制（渲染器）+ 项目（未记录） |
| `unregistered` | `163_config.json`、`gmail_config.json` 未注册 | 项目 |
| `cite-check` | 1 条判断 + 10 个已收口单元全部缺 `class=`（早于 L3 约定） | 项目（需迁移） |
| `ops-embed` | 嵌入的 ops 块与 ops 源不一致（旧版） | 机制（部署） |

顺带发现并修掉的两件**机制**问题（这才是首轮真正的收获）：

- **`(idle — no active unit)` 乱码**：旧 `doc-state.ps1` 里有一个 em dash 字面量，PS 5.1 按 ANSI 读脚本 → 写进 CURRENT_STATUS 就是乱码。这解释了那个项目里那行 `(idle 鈥?no active unit)`。现在渲染器只用 ASCII（`(idle)`），并有 `encoding-guard` 强制工具脚本纯 ASCII。
- **事件词汇缺一个「杂务」动词**：一次 ops 重新嵌入、一次 schema 迁移、一次守卫修复——都改了状态文档，却既不是单元、也不是判断、也不是计划变更。旧词表无从记录它们，于是时效守卫会**永远**报「有未记录的工作」，而它报的其实是对的。新增 `note:set`（带日期、进投影的 housekeeping 区、只渲染最近 10 条）后，这类工作可被如实记录，红灯可被正当清除。
- **`record.ps1` 的退出码语义**：记录的「成功/失败」与其它守卫的「红/绿」被混成一个退出码——项目一旦有历史红灯，agent 每记一次状态都像「记录失败」。现在明确分开：先报 `recorded N event(s) + re-projected`，再报 `conformance: RED - …` 并说明事件确实已记录、红灯是另一件事。

给那个项目的处置是**机制我修、项目数据它自己修**（写信告知 4 项及精确命令）——这样这一轮同时也是「文档体系能否指导它自己的 agent 修好自己」的真实测试。

## 公开发布 v2.0.0（2026-09-18）

**触发**：外部读者会按仓库首页的第一印象判断这个项目，而公开的 `master` 停在 v1.7.1（五文档/车身模型），与本地 v2 完全脱节——**门面与产品不一致**本身就是缺陷，与谁来看无关。

**做法**：发布不是「把本地分支推上去」，而是构建一个**自洽的发布树**：

- 在临时克隆里删掉不发布的路径（跨项目往来信件 `inbox/2026-*.md`、`outbox/`、`_runtime/`，以及会引用其它私有项目的 4 份 notes），并同步修剪 `FILE_INDEX.md` 中指向它们的条目；
- 用 `git reset --soft <公开 tip>` + 一次提交，把发布做成公开历史之上的**单个 release commit**（本地完整的 100+ 提交历史原样保留，不外泄 WIP 提交信息）；
- **在发布树上（而非本地树上）跑完整闸门**——发布树必须自己通过自己的守卫，`dead-pointer`/`unregistered` 尤其如此；
- 再对发布树做一次「泄漏扫描」（`tools/publish-scan.ps1`，按本地禁止词表 grep：人名/机构/其它项目名/一切不适合公开的语境词），确认只剩已经公开过的旧文件。

结果：tag `v2.0.0`（公开 `master`），README 重写为中英双语 v2 版（新增「给谁用 + 5 分钟试用」），manifest 升到 2.0.0，仓库描述与 topics 同步更新。

**两个真实教训（都已修）**：

1. **枚举权威源，不要手抄清单**——这本来是项目自己的铁律，我第一次构建发布树时却手写了「要排除的 10 封信」的显式清单，结果恰好漏掉当天 10:04 新到的一封下游来信（它被 `git add -A` 扫进了提交、并进入发布树）。改成 pathspec（`inbox/2026-*.md`）后，清单由磁盘现状枚举，不再依赖我的记忆。
2. **git pathspec 的 `*` 会跨越 `/`**——按 `inbox/*.md` 排除会连带删掉 `inbox/_archive/`、`inbox/_malformed/` 里**已经公开**的 4 封信，发布树的 `FILE_INDEX` 就会指向不存在的文件（自己的守卫会红）。正确写法是 `inbox/2026-*.md`。这条也是在发布树上跑闸门时才会暴露的——`conformance` 在发布树上跑，正是为了这个。

**对外口径协调**：一个下游项目来信询问 v2 的对外描述，回信给出了口径快照与**必须停用的 v1.7.x 说法清单**（「五个文档」「WORKLOG」「车身/阶段」停用；「六个命令」「恢复链」「MIT/双语/插件市场」保留；「支持 Kimi CLI」须改口为「与 agent 解耦」，因为 Kimi 专版已归档），并附上给外部读者的入口链接。这类「材料与仓库脱节」的风险与谁来看无关，因此口径快照应随发布一起给出。

**第四个教训（比前三个都更该记住）**：我在同一轮里犯了与教训 1 同类、但后果更严重的错误——**验证记录本身泄露了不该公开的内容**。我写发布记录时写进了一段与 doc-harness 无关的私人语境，又在发布日志的状态事件里写进了兄弟项目的名字；而泄漏扫描只 grep 了「其它项目名」这一维度、且**词表是我当场手写的**，于是这一版被推了上去。几十分钟后自查才发现，随即：把私人语境与项目名从 `notes/validation.md`、`events.log`、`CURRENT_STATUS.md` 中改写（原始日志归档到本地 `_archive/`，不发布）并重做发布。教训有两条：①**验证记录是公开发布物的一部分**，写作时就该按公开发布物的标准写；②**禁止词表必须是持久文件，不能靠当场回忆**（`RELEASING.md` 现在要求发布前跑 `tools/publish-scan.ps1`，词表存在本地 `.publish-terms.txt` 且本身不发布）。

**这次修正的完整三步（都不是「改一版就完事」）**：

1. **内容**：私人语境、人名与兄弟项目名从 `notes/validation.md`、`events.log`、`CURRENT_STATUS.md` 以及若干设计笔记中改写为泛称（下游项目名 → 「一个大型下游项目」等泛称等）；原始日志归档到本地、且**不发布**。
2. **机制**：`.publish-exclude.txt`（不发布的路径）与 `.publish-terms.txt`（禁止词表，含 `allow:` 豁免**早已公开**的文件）作为两个本地数据文件落下来；`tools/publish-scan.ps1` 按词表扫描发布树；`RELEASING.md` 把「在发布树上跑扫描」写成发布前必做项。排除清单从此由数据枚举——这正是同一轮里两次踩到的同一个坑（手写清单 / 当场回忆词表）。
3. **历史**：仅仅「再提交一次」是不够的——被推上去的那一版仍在公开历史里可被检出。做法是把发布提交**重新挂回泄露之前的公开 tip**（`git reset --soft 3ebcc0e` 后重新提交、force-push、tag 重指），使泄露提交从任何 ref 都不可达；随后用全新 clone 验证：旧提交不可达、工作树里没有个人语境词、完整闸门 PASS。

**残留下限（必须如实记录）**：GitHub 可能在一段时间内仍保留不可达对象（按 SHA 的 raw 链接可能短暂可用），且在约一小时的窗口内 clone 过该仓库的人手上会留有副本——这一段无法用 git 撤销。窗口很短、仓库访问量很小，但它是真实存在的残余风险，已如实告知用户。

**第五个教训（用户一句「个人隐私信息还是不要在线公开的好」之后做的全面复查）**：此前只检查了工作树与最近的历史，这次把**整个公开历史**按个人信息维度扫了一遍，发现问题比想象的大：一次四月的事故报告与**两份会话导出文件（单个 9600 行 / 503 KB / 226 条消息）**曾被提交进仓库——它们含姓名、个人站点与大量上下文；另外三个 manifest 里的联系邮箱是私人 Gmail。工作树早已干净，但**历史是公开物的一部分**，任何人 `git log -p` 或按 SHA 都能看到。处置：

1. 在发布历史的克隆上跑 `git filter-branch --tree-filter`：从**每一个**提交里删除那两个 session 导出与那份事故报告，把私人邮箱替换为 GitHub noreply 地址，把残余的个人语境词改为泛称；
2. 用「只看真实 ref（排除 filter-branch 备份 ref）」的方式复核，逐项确认 0 命中——**这一步是必要的**：我第一次复核用的是 `git rev-list --all`，它把备份 ref 也算进来，于是误以为重写没生效；
3. `--tag-name-filter cat` 重写并强推 **全部 11 个 tag** 与 master，再用全新 clone 验证：姓名、个人站点、私人邮箱、申请类语境词在**所有可达提交**里 0 命中，旧提交不可达，闸门 PASS。

同时把私人邮箱加入本地禁止词表、把会话导出与事故报告列入本地不发布清单。**由此确立一条写作规则：公开文档只写「类别」（姓名/站点/私信/申请语境），不写具体词**——否则验证记录本身会再次把敏感词带回来（本轮 `publish-scan` 正是这样拦住了我）。**本地开发树保留完整原始历史**（这是用户自己的备份，不发布）。

**第三个教训（发布树才暴露的工具缺陷）**：`now-verify` 的「未记录的工作」判定原先比较**文件 mtime**。发布之后才意识到：任何人 clone 这个仓库时，所有文件的 mtime 都是**克隆当天**——于是发布的仓库在发布次日就会自己判自己红。这是「自己的守卫在健康项目上误报」的典型：它会摧毁对所有守卫的信任。已改为**在 git 工作副本里以 git 状态为准**（未提交的改动 + 一次没有触碰 `events.log` 的提交；非 git 项目才退回 mtime），并用「干净树 / 只改 mtime 不改内容 / 真有未提交改动且事件更旧」三种情形分别验证。因为这是工具修正而非规则变更，spec 版本仍是 2.0.0，发布提交在任何人依赖它之前被修正。

**新增守卫：`skill-consistency`**（原 `zh-sync-check`，扩展后改名）。它把三条过去只靠人眼评审的断言变成机器判据：①**语言一致**——两版文件集合、标题层级序列、代码围栏数、表格行数必须完全一致（翻译改的是词，不是结构）；②**规范性标识符一致**——两版必须点名同样的路径（带扩展名）与同样的事件动词；命令示例里被翻译的占位符（如 `-Detail "N items extracted"` / `-Detail "N 项提取"`）刻意不在此列，否则守卫会在合法翻译上误报；③**不得重新教回 v1 模型**——`WORKLOG`、`car body`、`车灯`、`驾驶手册`、"five documents"、"phase transition" 等淘汰术语，只允许出现在同时带有 v1/归档/迁移/历史 标记的句子里。三项都做了空转检验：删掉一个中文小节 → `heading structure differs`；只在一侧写 `tools/telemetry.ps1` → `identifier in skill/recall.md but not skill-zh/recall.md`；故意写「The car body records…」或「车身记录…」→ `retired v1 vocabulary without a migration/history marker`。至此铁律 1 与「文档必须描述事件日志模型」从「承诺」变成「会红」。

**新增守卫：`entry-check`**。「唯一入口」此前也是靠人眼：`CLAUDE.md` 带身份锁、`AGENTS.md` 只是薄指针。现在它有了机器判据——入口必须含身份锁；`AGENTS.md` 若存在，不得多于 15 行、必须点名 `CLAUDE.md`、不得自带 ops 哨兵、不得含状态小节。空转检验：故意把 `AGENTS.md` 写成 24 行并塞进 `## NOW` → 立刻报「不是薄指针」＋「带了状态副本」。同时本次审计发现并修掉一个真缺口：`flush.md` 通篇没有点名 `events.log`（只说「记为事件」），两版都已补上——现在 9 个 skill 文档在中英两版里都至少点名一次 `events.log`。

## 红线自检

- 不干预 agent 工作方式：v1.7.2 子代理规则已从 operational_rules / recall / resume 移除；spec §1 明确「不规定 agent 怎么做工作」。
