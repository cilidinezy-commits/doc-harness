# Doc Harness — 检查

审计项目文档健康状况，并反思工作原则。

双重目的：(1) 发现文件层面的问题 (2) 提醒自己应当遵循的规则。

---

## 第一部分：文件健康审计

### 1.1 核心文件是否存在？

在当前目录（或最近的含 CLAUDE.md 的父目录）中查找以下4个核心文件：
- `CLAUDE.md`、`CURRENT_STATUS.md`、`FILE_INDEX.md`、`WORKLOG.md`

缺失 → `❌ 缺失: [文件名]`
全部未找到 → `❌ 未找到 Doc Harness。使用 /doc-harness init 创建。` → 停止。

同时检查：`DOC_HARNESS_SPEC.md` — 这是参考规范文档。
- 存在 → `✅ 规范文档存在`
- 不存在 → `⚠️ DOC_HARNESS_SPEC.md 未找到 — 建议但非必须。可从 skill 目录部署。`

### 1.2 CURRENT_STATUS 时效性

读取 CURRENT_STATUS.md 的"最后更新"日期（只需前5行，不读全文）。
- 今天 → `✅ 最新`
- 1-3天前 → `⚠️ [N]天前更新`
- >3天前 → `❌ 过期 — 立即更新或执行暂停协议`

### 1.3 CLAUDE.md 一句话状态

读取 CLAUDE.md 的"一句话状态（截至日期）"（只需前5行）。
- 日期与 CURRENT_STATUS 一致 → `✅ 当前`
- 更旧 → `⚠️ 过期`

### 1.4 FILE_INDEX 完整性（根与子索引）

将 FILE_INDEX 条目与磁盘实际文件进行对比。算法是**递归的**——项目根下可能有子 FILE_INDEX.md 文件，每个都要对自己的子树做一致性检查。使用以下方法：

```bash
# 找到项目中所有 FILE_INDEX.md 文件（根 + 子索引）
find . -type f -name 'FILE_INDEX.md' \
  -not -path "./_archive*" -not -path "./.git/*" -not -path "./node_modules/*" -not -path "./dist/*" \
  | sort > /tmp/dh_indexes.txt

# 对每个索引，检查其自身子树——并**在子索引边界处剪枝**
# 以便 data/experiments/foo.md 属于 data/experiments/FILE_INDEX.md 的范围，
# 而不是被 data/FILE_INDEX.md 当作幽灵条目报告。
while IFS= read -r INDEX; do
  DIR="$(dirname "$INDEX")"
  echo "── 检查 $INDEX （范围：$DIR）──"

  # 构建排除列表：DIR 之下严格拥有自己的 FILE_INDEX.md 的目录，
  # 它们属于各自子索引的范围。
  EXCLUDES=()
  while IFS= read -r OTHER_INDEX; do
    OTHER_DIR="$(dirname "$OTHER_INDEX")"
    if [ "$OTHER_DIR" != "$DIR" ] && [[ "$OTHER_DIR" == "$DIR"* ]]; then
      EXCLUDES+=("-not" "-path" "$OTHER_DIR/*" "-not" "-path" "$OTHER_DIR")
    fi
  done < /tmp/dh_indexes.txt

  # 该索引范围内实际存在的文件（在子索引边界处剪枝）
  find "$DIR" -maxdepth 10 -type f \
    "${EXCLUDES[@]}" \
    \( -name '*.md' -o -name '*.py' -o -name '*.tex' -o -name '*.json' -o -name '*.csv' -o -name '*.txt' -o -name '*.pdf' -o -name '*.png' -o -name '*.bib' \) \
    -not -path "*/_archive/*" -not -path "*/.git/*" -not -path "*/node_modules/*" -not -path "*/dist/*" \
    -not -path "*/inbox/*" -not -path "*/outbox/*" \
    | sed "s|^$DIR/||" | sort > /tmp/dh_disk.txt

  # 该索引中提及的条目
  grep -oE '`[^`]+\.(md|py|tex|json|csv|txt|pdf|png|bib)`' "$INDEX" | tr -d '`' | sort > /tmp/dh_entries.txt

  echo "未注册（磁盘存在但 $INDEX 未列）："
  comm -23 /tmp/dh_disk.txt /tmp/dh_entries.txt
  echo "幽灵（$INDEX 中列出但无文件）："
  comm -13 /tmp/dh_disk.txt /tmp/dh_entries.txt
done < /tmp/dh_indexes.txt
```

注意：若子目录本身有子 `FILE_INDEX.md`，父索引只需一行引用子索引文件（spec §4.3）。子树下的详细文件应由子索引审计，不在父索引范围。

- 所有层级全部已注册 → `✅ 完整（检查了 N 个索引）`
- 有未注册 → `❌ 未注册：[列表，注明应由哪个索引注册]`
- 有幽灵条目 → `❌ 幽灵：[列表，注明在哪个索引中]`

**Token 效率**：只读 `FILE_INDEX.md` 文件和 `find` 输出。不读任何叶子文档内容。

### 1.5 WORKLOG 目录一致性

读取 WORKLOG.md。对比目录表行数与实际 `##` 章节标题（用 Grep，不读全文）。
- 一致 → `✅ 一致`
- 不一致 → `⚠️ 目录有[N]条，实际有[M]个章节`

### 1.6 WORKLOG 长度

统计 WORKLOG.md 的总行数（用 `wc -l` 或等价方法，不读全文）。
- <1000 行 → `✅ [N] 行`
- 1000–1500 → `⚠️ [N] 行 — 建议归档（§5.5）`
- >1500 → `❌ [N] 行 — 归档已逾期`

### 1.7 收件箱状态（如已启用跨项目通信）

若根目录存在 `inbox/`，依次执行四个子检查。使用 Grep 读取 YAML `status:` 行和文件 mtime（不读正文）。

**(a) 未读计数**（范围：`inbox/` 的直接子文件；**排除** `inbox/_archive/` 和 `inbox/_malformed/`，以免隔离或归档消息与其他子检查重复计数）：
- 无 `inbox/` → 跳过整个 §1.7
- 全部 `read` 或 `actioned` → `✅ 收件箱清空（共 N 条，0 条未读）`
- 有 `unread` → `⚠️ 收件箱有 N 条未读消息——需要处理`

**(b) 归档触发**（对应 spec §14.4 规则 3）：
统计 `status: actioned` 且 mtime 超过 30 天的消息数。
- ≥5 条 → `⚠️ 归档到期：N 条 actioned 消息超过 30 天——本 session 内移入 inbox/_archive/`
- <5 条 → 无需动作（仅在 ✅ 级别汇报）

**(c) 异常消息**（对应 §14.8）：
统计 `inbox/_malformed/` 目录中的文件数（若该目录存在）。
- 0 或目录不存在 → ✅
- ≥1 → `⚠️ 异常消息已隔离：inbox/_malformed/ 中有 N 条——需审查`

**(d) 近期 outbox 发送未记录于 CURRENT_STATUS**：
对 `outbox/` 中 mtime 在最近 3 天内的每个文件，核对 CURRENT_STATUS 车身是否提及该文件名。
- 全部已记录 → ✅
- 有遗漏 → `⚠️ Outbox 发送未在 CURRENT_STATUS 中记录：[列表]`

### 1.8 车身长度（语言无关）

统计 CURRENT_STATUS 中**车身标题**到下一个 `##` 之间的行数。匹配 `## Current Work` 或 `## 当前工作`（init 模板产生的两种变体）。用 Grep/行计数，不读全文。
- <200行 → `✅ [N]行`
- 200–250行 → `⚠️ 接近上限`
- >250行 → `❌ 超出上限——建议执行阶段切换`

### 1.9 Mid-Transition 一致性（spec §6.3.1）

读取并比较三个值——用于检测在 Step 1 与 Step 5 之间被中断的阶段切换。

- **A**：CLAUDE.md 中 "current phase" / "当前阶段" 行（前 10 行，两种语言都匹配）。
- **B**：WORKLOG TOC 最新条目（TOC 表头之后首行 `| `）。
- **C**：CURRENT_STATUS 车辙最新阶段摘要（"Recent Completed" / "近期已完成"下第一个 `###` 标题）。

若 A、B、C 按 spec §6.3.1 表互相一致 → `✅ 一致`。
否则 → `❌ 检测到 mid-transition 状态：A=[...] B=[...] C=[...]。按 §6.3.1 修复。`

### 1.10 嵌入的操作规则版本

Grep 查找 CLAUDE.md 中任意位置的 HTML 注释 `<!-- doc-harness-ops-version: N.N -->`（不区分大小写，单行）。
- 找到且与安装的 skill 版本一致（如 `1.4`） → `✅ 操作规则已是最新（vN.N）`
- 找到但旧于安装的 skill 版本 → `⚠️ 操作规则快照为 vX.X；安装的 skill 为 vY.Y——重新从 operational_rules.md 嵌入以升级`
- 完全未找到 → `⚠️ 未找到版本标签——此 CLAUDE.md 早于 v1.4 或被手工编辑。建议重新嵌入 operational_rules.md。`

安装的 skill 版本见已安装 `spec.md` 顶部的 `**Version**` 行。**按以下顺序解析安装路径**（命中即停）：

1. 项目级：`<项目根>/.claude/skills/doc-harness/spec.md`
2. 用户级，Claude Code Unix 默认：`$HOME/.claude/skills/doc-harness/spec.md`
3. 用户级，XDG 覆盖：`${XDG_CONFIG_HOME:-$HOME/.config}/claude/skills/doc-harness/spec.md`
4. 用户级，Windows：`%USERPROFILE%\.claude\skills\doc-harness\spec.md`（bash 下：`"$USERPROFILE/.claude/skills/doc-harness/spec.md"`——Windows bash 支持正斜杠）

若无路径可解析，报告 `⚠️ 无法定位已安装的 skill——请在 skill 已部署的项目中运行 check，或安装到上述任一路径`。"安装版本未找到"**不**视为通过。

---

## 第二部分：原则反思

### 2.1 铁律

读取 CLAUDE.md。找到"铁律"/"Iron Rules"区域。对每条铁律：

```
🔒 "[铁律内容]"
   → 我遵守了吗？有没有违反？
```

### 2.2 驾驶手册

读取 CURRENT_STATUS.md。找到"驾驶手册"/"Driving Manual"区域。对每条原则：

```
📋 "[原则内容]"
   → 我在工作中注意到这一点了吗？
```

### 2.3 "落笔为安"检查

```
📝 落笔为安检查：
   → 有没有重要信息目前只存在于 context 中？
   → 有没有未保存的分析结果、决策、洞见？
   → 如果有 → 现在立刻保存。
```

### 2.4 阶段一致性检查

列出 CURRENT_STATUS 车身区域中所有 `####` 步骤标题，然后自问：

```
🔄 阶段一致性：
   车身中的步骤：
   1. [步骤标题1]
   2. [步骤标题2]
   3. [步骤标题3]
   ...
   → 这些步骤是否都服务于同一个阶段目标？
   → 有没有步骤实际上代表了不同的目标，应该开启新阶段？
   → 如果目标已发生偏移，考虑执行阶段切换。
```

### 2.5 恢复链健康度

读取 CLAUDE.md 中的恢复链章节。

```
🗺️ 恢复链：
   → 是两层结构吗（必读 + 任务条件读）？
   → 必读层 ≤ 3 条？
   → 所有条目都指向项目内文件（没有 memory / 对话历史等 agent 侧依赖）？
   → 有没有任务条件读条目每次都要读？→ 提升为必读。
   → 有没有必读条目实际很少真用？→ 降级为任务条件读。
```

### 2.6 Session 结束清单（如适用）

```
- [ ] 车身反映了本 session 全部工作？
- [ ] 车灯准确？
- [ ] CURRENT_STATUS 日期已刷新？
- [ ] CLAUDE.md 一句话状态已刷新？
- [ ] 新文件都注册了 FILE_INDEX？
- [ ] 有没有信息只在 context 中？→ 落笔为安！
```

---

## 语言无关性说明

第一部分的所有锚点（`## Current Work` / `## 当前工作`、`## Recent Completed` / `## 近期已完成`、`Iron Rules` / `铁律`、`Driving Manual` / `驾驶手册` 等）都应**兼容中英两种形式**——实现时 Grep 两种变体中的任一。混合语言项目（如中文 CLAUDE.md + 英文 CURRENT_STATUS）只要每个文档内部语言一致即可正确审计。

## 输出格式

```
═══════════════════════════════════════
  Doc Harness — 健康检查
  项目: [名称]
  日期: [今天]
═══════════════════════════════════════

── 第一部分：文件健康 ──

[1.1] 核心文件:      ✅/❌  |  规范: ✅/⚠️
[1.2] CURRENT_STATUS: ✅/⚠️/❌
[1.3] CLAUDE.md:      ✅/⚠️
[1.4] FILE_INDEX:     ✅/❌ N个未注册/N个幽灵  （递归：N个索引）
[1.5] WORKLOG 目录:   ✅/⚠️
[1.6] WORKLOG 长度:   ✅ N行 / ⚠️/❌
[1.7] 收件箱:         ✅ / ⚠️ <未读>/<归档>/<异常>/<outbox未记录>  （未启用则跳过）
[1.8] 车身长度:       ✅ N行 / ⚠️/❌
[1.9] Mid-transition: ✅ 一致 / ❌ 需按 §6.3.1 修复
[1.10] 操作规则版本:   ✅ vN.N / ⚠️ vX.X (安装: vY.Y) — 重新嵌入

── 第二部分：原则反思 ──

🔒 铁律: [列出并反思]
📋 驾驶手册: [列出并反思]
📝 落笔为安: [状态]
🔄 阶段一致性: [步骤标题 + 评估]
🗺️ 恢复链: [两层？自含？升降级？]

── 需要的行动 ──
[修复 ❌/⚠️ 项目的具体措施]
═══════════════════════════════════════
```

## 何时使用

- 长时间工作中每1-2小时
- Session 结束前
- Context compact 后
- 感觉偏离原则时
- 用户要求时
