# Doc Harness — Check

Audit the project's documentation health and reflect on working principles.

Two purposes: (1) catch file-level problems, (2) remind yourself of the rules you should be following.

---

## Part 1: File Health Audit

### 1.1 Core files exist?

Look for these 4 files in the current directory (or nearest parent with CLAUDE.md):
- `CLAUDE.md`, `CURRENT_STATUS.md`, `FILE_INDEX.md`, `WORKLOG.md`

Missing → `❌ MISSING: [file]`
None found → `❌ No Doc Harness found. Use /doc-harness init.` → stop.

### 1.2 CURRENT_STATUS freshness

Read the "Last updated" date from CURRENT_STATUS.md (only the first 5 lines, not full file).
- Today → `✅ Fresh`
- 1-3 days → `⚠️ [N] days old`
- >3 days → `❌ Stale — update or execute pause protocol`

### 1.3 CLAUDE.md one-line status

Read the "one-line status (as of DATE)" from CLAUDE.md (only the first 5 lines).
- Date matches CURRENT_STATUS → `✅ Current`
- Older → `⚠️ Stale`

### 1.4 FILE_INDEX completeness

```bash
# List actual .md files (exclude _archive)
find . -name "*.md" -not -path "./_archive*" | sort
```

Compare with FILE_INDEX.md entries:
- File on disk but not in index → `❌ UNREGISTERED: [path]`
- Entry in index but no file → `❌ GHOST: [path]`

**Token efficiency**: Only read FILE_INDEX.md content and `find` output. Do NOT read any leaf document content.

### 1.5 WORKLOG TOC consistency

Read WORKLOG.md. Compare TOC table rows with actual `##` headings (use Grep, not full file read).
- Match → `✅ Consistent`
- Mismatch → `⚠️ TOC has [N] entries, [M] sections found`

### 1.6 Car body length

Count lines in CURRENT_STATUS between "## Current Work" and the next "##" heading (use Grep/line counting, not full read).
- <200 → `✅ [N] lines`
- 200-250 → `⚠️ Approaching limit`
- >250 → `❌ Over limit — consider phase transition`

---

## Part 2: Principle Reflection

### 2.1 Iron rules

Read CLAUDE.md. Find the "Iron Rules" / "铁律" section. For each rule:

```
🔒 "[rule text]"
   → Have I followed this? Any violations?
```

### 2.2 Driving manual

Read CURRENT_STATUS.md. Find the "Driving Manual" / "驾驶手册" section. For each principle:

```
📋 "[principle text]"
   → Am I keeping this in mind?
```

### 2.3 "Write It Down" check

```
📝 Write It Down check:
   → Any important information ONLY in context right now?
   → Unsaved analysis results, decisions, insights?
   → If yes → save NOW.
```

### 2.4 Session-end checklist (if applicable)

```
- [ ] Car body reflects all session work?
- [ ] Headlights accurate?
- [ ] CURRENT_STATUS date refreshed?
- [ ] CLAUDE.md one-line status refreshed?
- [ ] New files registered in FILE_INDEX?
- [ ] Anything unsaved? → Write it down!
```

---

## Output Format

```
═══════════════════════════════════════
  Doc Harness — Health Check
  Project: [name]
  Date: [today]
═══════════════════════════════════════

── Part 1: File Health ──

[1.1] Core files:      ✅/❌
[1.2] CURRENT_STATUS:  ✅/⚠️/❌
[1.3] CLAUDE.md:       ✅/⚠️
[1.4] FILE_INDEX:      ✅/❌ N unregistered/N ghosts
[1.5] WORKLOG TOC:     ✅/⚠️
[1.6] Car body:        ✅ N lines / ⚠️/❌

── Part 2: Principle Reflection ──

🔒 Iron Rules: [list with reflections]
📋 Driving Manual: [list with reflections]
📝 Write It Down: [status]

── Actions Needed ──
[specific fixes for ❌/⚠️ items]
═══════════════════════════════════════
```

## When to use

- Every 1-2 hours during long sessions
- Before session end
- After context compact
- When feeling drift from principles
- When user requests
