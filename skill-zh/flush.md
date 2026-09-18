# Doc Harness — 冲刷

压缩 / session 结束前的紧急保存。区分特征是强制上下文盘点 + 提取 + **刷新 NOW**。

> 若跳过阶段 B（盘点）与阶段 C（写入），冲刷就失败了——那只是 `sync`。

## 模式

- **interactive**（默认）：逐条提取前询问。
- **auto**（`--auto`）：启发式分类。

## 阶段 A：同步

执行完整 `sync`（它会向 `events.log` 补齐缺失的状态事件并重投影）。然后声明「阶段 A 完成——进入阶段 B」。

## 阶段 B：上下文盘点（强制）

扫描当前上下文，把每项非临时信息归类：DURABLE（已在文件） / EXTRACT（需写入） / EXCLUDE（临时、错误、用户禁止）。

关键去向：分析结果 → `notes/`；设计决策 → `design/`，若工作面本身变了则补一条 `plan:set`/`judgment:set` 事件；教训 → `PHILOSOPHY.md`；新规则 → 稳定锚/铁律；用户需求 → `## NOW` 下一步（通过 `next:set`）。

始终报告「总扫描 / DURABLE / EXTRACT / EXCLUDE」。若 EXTRACT = 0，产出显式空扫描报告。

## 阶段 C：写入并注册（EXTRACT > 0 时强制）

写入每项；注册 FILE_INDEX；把状态变更记为 `events.log` 里的事件（`tools/record.ps1`）。优先追加（带日期标题），不覆盖。

## 阶段 D：验证

模拟新 agent 到达：读 CLAUDE.md 稳定锚 → `## NOW` → 先读。刚写的东西能否被找到？修复任何缺口。

## 阶段 E：最终标记 + 刷新 NOW

- 压缩前刷新 `## NOW`：把变化记为事件（`tools/record.ps1 -Verb next|read|judgment -Text "..."`），它会重投影 CURRENT_STATUS 并刷新日期。刷新 NOW 靠事件——手改 CURRENT_STATUS 不是选项（它是生成物）。
- 把这次冲刷记入遥测：`tools/telemetry.ps1 -Event flush -Detail "N 项提取"`。`_runtime/ops-log.ndjson` 是审计轨迹；CURRENT_STATUS 装的是状态，不是过程历史。
- 若冲刷本身产出了持久结论，那就是一次状态变更：记录它（`judgment:set` / `unit:close`），而不是只在报告里提一句。

## 输出

```
═══════════════════════════════════════
  Doc Harness — 上下文冲刷   项目: [名称]   日期: ...   模式: auto/interactive
═══════════════════════════════════════
── 阶段 A: 同步 ── ...
── 阶段 B: 上下文盘点 ── [强制；即使为空]
── 阶段 C: 写入并注册 ── ...
── 阶段 D: 验证 ── ...
── 阶段 E: 标记 + 刷新 NOW ── ...
═══════════════════════════════════════
```
