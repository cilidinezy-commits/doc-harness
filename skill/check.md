# Doc Harness — Check

Audit the project's documentation health and reflect on working principles.

Two purposes: (1) catch file-level problems, (2) remind yourself of the rules you should be following.

---

## Part 1: File Health Audit

### 1.1 Core files exist?

Look for these 4 core files in the current directory (or nearest parent with CLAUDE.md):
- `CLAUDE.md`, `CURRENT_STATUS.md`, `FILE_INDEX.md`, `WORKLOG.md`

Missing → `❌ MISSING: [file]`
None found → `❌ No Doc Harness found. Use /doc-harness init.` → stop.

Also check: `DOC_HARNESS_SPEC.md` — this is the reference specification.
- Present → `✅ Spec present`
- Missing → `⚠️ DOC_HARNESS_SPEC.md not found — recommended but not required. Deploy from skill directory if available.`

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

Compare FILE_INDEX entries against actual files on disk. Use this tested approach:

```bash
# Step 1: List actual files (exclude _archive, dist, .git, node_modules)
find . -name "*.md" -not -path "./_archive*" -not -path "./dist/*" -not -path "./.git/*" | sed 's|^\./||' | sort > /tmp/dh_disk.txt

# Step 2: Extract entries from FILE_INDEX (and any sub-FILE_INDEX files referenced)
grep -oP '`[^`]+\.(md|py|tex|json|csv|txt|pdf|png|bib)`' FILE_INDEX.md | tr -d '`' | sort > /tmp/dh_index.txt

# Step 3: Compare
echo "Unregistered:" && comm -23 /tmp/dh_disk.txt /tmp/dh_index.txt
echo "Ghosts:" && comm -13 /tmp/dh_disk.txt /tmp/dh_index.txt
```

For projects with sub-FILE_INDEX.md files, also check those sub-indexes against their respective directories.

- All files registered → `✅ Complete`
- Unregistered files found → `❌ UNREGISTERED: [list]`
- Ghost entries found → `❌ GHOST: [list]`

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

### 2.4 Phase coherence check

List all `####` step titles from the CURRENT_STATUS car body section. Ask yourself:

```
🔄 Phase coherence:
   Steps in car body:
   1. [step title 1]
   2. [step title 2]
   3. [step title 3]
   ...
   → Do all these steps serve the SAME phase goal?
   → Or do some steps represent a different objective that should be a new phase?
   → If goals have shifted, consider executing a phase transition.
```

### 2.5 Session-end checklist (if applicable)

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

[1.1] Core files:      ✅/❌  |  Spec: ✅/⚠️
[1.2] CURRENT_STATUS:  ✅/⚠️/❌
[1.3] CLAUDE.md:       ✅/⚠️
[1.4] FILE_INDEX:      ✅/❌ N unregistered/N ghosts
[1.5] WORKLOG TOC:     ✅/⚠️
[1.6] Car body:        ✅ N lines / ⚠️/❌

── Part 2: Principle Reflection ──

🔒 Iron Rules: [list with reflections]
📋 Driving Manual: [list with reflections]
📝 Write It Down: [status]
🔄 Phase coherence: [step titles + assessment]

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
