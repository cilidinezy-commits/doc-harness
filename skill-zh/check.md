# Doc Harness — 健康检查

审计文档健康并反思原则。两部分：文件健康 + 原则反思。

## 第一部分：文件健康

### 1.1 核心文件

必需：`CLAUDE.md`、`AGENTS.md`、`events.log`、`CURRENT_STATUS.md`、`FILE_INDEX.md`。可选：`DOC_HARNESS_SPEC.md`（参考）。

### 1.2 NOW 新鲜度

读 `CURRENT_STATUS.md` `## NOW` 的「最后刷新 / Last refreshed」。今天 → ✅；1–3 天 → ⚠️；>3 天 → ❌ 过期。

### 1.3 NOW 行数与编码

- 行数：`## NOW` ≤ 约 30 行 → ✅；超过 → ❌（历史泄进了 NOW）。
- 编码：以 UTF-8 打开 CURRENT_STATUS 确认无乱码 → ✅；乱码 → ❌ 损坏（从干净源重写）。

### 1.4 FILE_INDEX 完整性（未注册 = 红）

对比磁盘文件与 FILE_INDEX 条目（递归 + 子索引裁剪）。未注册文件是 **❌ 红项**，不是警告。幽灵条目同样 ❌。

### 1.5 events.log 良好性

跑 `tools/project.ps1`（或 `Get-DocState`）：无解析错误 → ✅；出现任何 `malformed / duplicate open / activate-before-open / unknown verb` → ❌。

### 1.6 events.log 长度与归档

<1000 行 ✅；1000–1500 ⚠️ 考虑把早期单元滚入 `_archive/`；>1500 ❌ 归档逾期。

### 1.7 收件箱（若启用）

(a) 未读数；(b) actioned 超 30 天（≥5 则归档到期）；(c) `inbox/_malformed/` 数量；(d) 近期 outbox 发送是否记录在 CURRENT_STATUS。

### 1.8 入口唯一

- 若有 `AGENTS.md`，是薄指针而非过时副本 → ✅；过时/重复 → ❌。
- `CLAUDE.md` 是权威入口 → ✅。

### 1.9 投影一致

跑 `tools/conformance.ps1`：由 `events.log` 得到的内存投影必须等于磁盘上的 `CURRENT_STATUS.md` → ✅；`projection-stale` → ❌（重新投影）。

### 1.10 操作规则版本

grep CLAUDE.md 里的 `<!-- doc-harness-ops-version: N.N -->`；与已安装 `spec.md` 版本对比。陈旧 → ⚠️ 重新嵌入。

### 1.11 身份锁

CLAUDE.md 以 AGENT IDENTITY LOCK + 项目名 + 自检开头 → ✅；否则 ⚠️。

### 1.12 复发（写下来 → 用起来）

扫 PHILOSOPHY.md / 铁律 / `events.log` 里的 `第 N 次` / `Nth time` 标记。对任何**重申 ≥2 次**却仍标「可查」或未标层的纪律，报告：

```
⚠ 这些纪律已被重申 ≥3 次却仍靠记得（可查层）——它们早该是守卫：
- [纪律] — 第 N 次（上次: <ref>）＋缺同形字段？
```

无此标记 → ✅。

### 1.13 可反证（死指针）

跑 `tools/dead-pointer.ps1`。FILE_INDEX.md / CURRENT_STATUS.md 里每个反引号引用的路径都必须能解析到现存文件或目录。悬空引用 → ❌（文档指名了某个已不存在的东西）。

### 1.14 时效（超期结论）

跑 `tools/stale-check.ps1`。任何仍在架的结论一旦过了 `conclusion_until` → ❌（一条已过期的结论被当作现行）。

### 1.15 溯源 class

跑 `tools/cite-check.ps1`。每条判断 / 收口单元的来源必须带 `class=root|decision|reported` → ✅；缺来源或缺 class → ❌。

## 第二部分：原则反思

```
🔒 稳定锚 / 铁律: [列表 + 反思]
🧭 底层原则: [列表 + 反思]
📝 落笔为安: 有没有只存在于 context 的重要信息？
🗺️ 活跃工作面: 活跃前沿是否当前且一致？
🚪 入口: 新 agent 能否从 CLAUDE.md → ## NOW → 先读，几次内完成定向？
🔁 复发: 有没有反复被重申的纪律？→ 它该是守卫。
```

## 输出

```
═══════════════════════════════════════
  Doc Harness — 健康检查   项目: [名称]   日期: [今天]
═══════════════════════════════════════
── 第一部分: 文件健康 ──
[1.1] 核心文件: ✅/❌   Spec/AGENTS: ✅/⚠️
[1.2] NOW 新鲜度: ✅/⚠️/❌
[1.3] NOW 行数/编码: ✅/❌
[1.4] FILE_INDEX: ✅/❌ N 未注册 / N 幽灵
[1.5] events.log: ✅/❌ 解析
[1.6] events.log 长度: ✅/⚠️/❌
[1.7] 收件箱: ✅/⚠️（未读/归档/畸形/未记录）
[1.8] 入口唯一: ✅/❌
[1.9] 投影: ✅/❌ 陈旧
[1.10] 操作规则版本: ✅ vN.N / ⚠️
[1.11] 身份锁: ✅/⚠️
[1.12] 复发: ✅/⚠️ <重申 ≥2 次仍可查>
[1.13] 死指针: ✅/❌
[1.14] 超期结论: ✅/❌
[1.15] 溯源 class: ✅/❌
── 第二部分: 原则反思 ──
...
── 待办 ──
...
═══════════════════════════════════════
```

时机：每 1–2 小时、session 结束前、compact 后、sync/flush 前。
