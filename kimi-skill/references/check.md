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

### 1.4 FILE_INDEX completeness (root and sub-indexes)

Compare FILE_INDEX entries against actual files on disk. The algorithm is recursive — a project may have sub-FILE_INDEX.md files below the root, and each must be checked against its own subtree. Use this approach:

```bash
# Locate all FILE_INDEX.md files in the project (root + sub-indexes)
find . -type f -name 'FILE_INDEX.md' \
  -not -path "./_archive*" -not -path "./.git/*" -not -path "./node_modules/*" -not -path "./dist/*" \
  | sort > /tmp/dh_indexes.txt

# For each index, check its own subtree — BUT prune at any sub-index boundary
# so a file like data/experiments/foo.md belongs to data/experiments/FILE_INDEX.md's
# scope, not to data/FILE_INDEX.md's scope.
while IFS= read -r INDEX; do
  DIR="$(dirname "$INDEX")"
  echo "── checking $INDEX (scope: $DIR) ──"

  # Build exclusion list: directories that contain OTHER FILE_INDEX.md files
  # strictly below DIR. These belong to their own sub-index's scope.
  EXCLUDES=()
  while IFS= read -r OTHER_INDEX; do
    OTHER_DIR="$(dirname "$OTHER_INDEX")"
    if [ "$OTHER_DIR" != "$DIR" ] && [[ "$OTHER_DIR" == "$DIR"* ]]; then
      EXCLUDES+=("-not" "-path" "$OTHER_DIR/*" "-not" "-path" "$OTHER_DIR")
    fi
  done < /tmp/dh_indexes.txt

  # Files actually present in this index's scope (pruned at sub-index boundaries)
  find "$DIR" -maxdepth 10 -type f \
    "${EXCLUDES[@]}" \
    \( -name '*.md' -o -name '*.py' -o -name '*.tex' -o -name '*.json' -o -name '*.csv' -o -name '*.txt' -o -name '*.pdf' -o -name '*.png' -o -name '*.bib' \) \
    -not -path "*/_archive/*" -not -path "*/.git/*" -not -path "*/node_modules/*" -not -path "*/dist/*" \
    -not -path "*/inbox/*" -not -path "*/outbox/*" \
    | sed "s|^$DIR/||" | sort > /tmp/dh_disk.txt

  # Entries mentioned inside this index
  grep -oE '`[^`]+\.(md|py|tex|json|csv|txt|pdf|png|bib)`' "$INDEX" | tr -d '`' | sort > /tmp/dh_entries.txt

  echo "Unregistered (files on disk but not in $INDEX):"
  comm -23 /tmp/dh_disk.txt /tmp/dh_entries.txt
  echo "Ghosts (entries in $INDEX but no such file):"
  comm -13 /tmp/dh_disk.txt /tmp/dh_entries.txt
done < /tmp/dh_indexes.txt
```

Note: if a sub-directory has its own sub-`FILE_INDEX.md`, the parent index registers the *sub-index file* in one line (per spec §4.3). The detailed files below belong to the sub-index's check, not the parent's.

- All files registered at every level → `✅ Complete (N indexes checked)`
- Unregistered files found → `❌ UNREGISTERED: [list with which index should register them]`
- Ghost entries found → `❌ GHOST: [list with which index holds the ghost]`

**Token efficiency**: Read `FILE_INDEX.md` files and `find` output only. Do NOT read leaf document content.

### 1.5 WORKLOG TOC consistency

Read WORKLOG.md. Compare TOC table rows with actual `##` headings (use Grep, not full file read).
- Match → `✅ Consistent`
- Mismatch → `⚠️ TOC has [N] entries, [M] sections found`

### 1.6 WORKLOG length

Count total lines of WORKLOG.md (use `wc -l` or equivalent; do not read the full file).
- <1000 lines → `✅ [N] lines`
- 1000–1500 → `⚠️ [N] lines — consider archival (§5.5)`
- >1500 → `❌ [N] lines — archival overdue`

### 1.7 Inbox status (if inter-project comms adopted)

If `inbox/` exists at project root, do all four sub-checks. Use Grep on the YAML `status:` line and on file-age (don't read message bodies).

**(a) Unread count** (scope: direct children of `inbox/` only — exclude `inbox/_archive/` and `inbox/_malformed/` so quarantined and archived messages don't double-count here):
- No `inbox/` → skip the whole §1.7
- All messages `read` or `actioned` → `✅ Inbox clean (N total, 0 unread)`
- Any `unread` → `⚠️ Inbox has N unread message(s) — action needed`

**(b) Archival trigger** (ties to spec §14.4 rule 3):
Count messages with `status: actioned` whose file-mtime is older than 30 days.
- ≥5 such messages → `⚠️ Archival due: N actioned message(s) older than 30 days — move to inbox/_archive/ this session`
- <5 → no action (reported only at ✅ level)

**(c) Malformed messages** (ties to §14.8):
Count files in `inbox/_malformed/` if that directory exists.
- 0 or no directory → ✅
- ≥1 → `⚠️ Malformed messages quarantined: N in inbox/_malformed/ — review`

**(d) Recent outbox send without CURRENT_STATUS entry**:
For each file in `outbox/` whose mtime is within the last 3 days, verify CURRENT_STATUS car body mentions it by filename.
- All recent sends recorded → ✅
- Missing entries → `⚠️ Outbox sends not logged in CURRENT_STATUS: [list]`

### 1.8 Car body length (language-independent)

Count lines in CURRENT_STATUS between the **car body heading** and the next `##` heading. Match either `## Current Work` or `## 当前工作` (both variants produced by init templates). Use Grep/line counting, not full read.
- <200 → `✅ [N] lines`
- 200–250 → `⚠️ Approaching limit`
- >250 → `❌ Over limit — consider phase transition`

### 1.9 Mid-transition coherence (spec §6.3.1)

Read three values and compare — this detects a phase transition interrupted between Steps 1 and 5.

- **A**: CLAUDE.md "current phase" / "当前阶段" line (first 10 lines; match either language).
- **B**: WORKLOG TOC's newest entry (first `| ` row after the TOC heading).
- **C**: CURRENT_STATUS tire tracks' newest phase summary (first `###` heading under "Recent Completed" / "近期已完成").

If A, B, C are mutually coherent per spec §6.3.1's table → `✅ Coherent`.
Otherwise → `❌ Mid-transition state detected: A=[...] B=[...] C=[...]. Apply §6.3.1 repair.`

### 1.10 Embedded operational-rules version

Grep for the HTML comment `<!-- doc-harness-ops-version: N.N -->` anywhere in CLAUDE.md (case-insensitive, one line).
- Found and matches the version of the installed skill (e.g. `1.4`) → `✅ Operational rules up to date (vN.N)`
- Found but older than installed skill → `⚠️ Operational rules snapshot is vX.X; installed skill is vY.Y — re-embed from operational_rules.md to upgrade`
- Missing entirely → `⚠️ No version marker found — this CLAUDE.md predates v1.4 or was hand-edited. Recommend re-embedding operational_rules.md.`

The installed skill's version is the `**Version**` line at the top of the installed `spec.md`. **Resolve the install path in this order** (first hit wins):

1. Project-level: `<project_root>/.claude/skills/doc-harness/spec.md`
2. User-level, Claude Code default on Unix: `$HOME/.claude/skills/doc-harness/spec.md`
3. User-level, XDG override: `${XDG_CONFIG_HOME:-$HOME/.config}/claude/skills/doc-harness/spec.md`
4. User-level, Windows: `%USERPROFILE%\.claude\skills\doc-harness\spec.md` (bash: `"$USERPROFILE/.claude/skills/doc-harness/spec.md"` — forward slashes work on Windows bash)

If no install path resolves, report `⚠️ Cannot locate installed skill — run check from a project where skill is deployed, or install at one of the paths above.` Do not treat "installed version not found" as passing.

### 1.11 Identity lock presence

Read the first 30 lines of CLAUDE.md. Check for the AGENT IDENTITY LOCK block:

- Contains `AGENT IDENTITY LOCK` (case-insensitive) → `✅ Present`
- Contains project name declaration (e.g., "你是 ... 项目的代理") → `✅ Project name declared`
- Contains self-test prompt (e.g., "如果你对自己的身份有任何怀疑...") → `✅ Self-test present`

If any sub-check fails → `⚠️ Identity lock missing or incomplete`. This is a recommendation, not a failure — existing projects created before v1.6.0 are not invalid. New projects should include it.

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
   → If yes → save NOW. If context compression is imminent → run `/doc-harness flush` to systematically extract all important context into documents.
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

### 2.5 Recovery Chain health

Read the Recovery Chain section from CLAUDE.md.

```
🗺️ Recovery Chain:
   → Is it two-layer (must-read + task-conditional)?
   → Must-read ≤ 3 entries?
   → All entries point to project-internal files (no agent-side features like memory / chat history)?
   → Any task-conditional entry consistently read every session? → promote to must-read.
   → Any must-read entry rarely actually needed? → demote to task-conditional.
   → Does CLAUDE.md begin with an AGENT IDENTITY LOCK?
```

### 2.6 Session-end checklist (if applicable)

```
- [ ] Car body reflects all session work?
- [ ] Headlights accurate?
- [ ] CURRENT_STATUS date refreshed?
- [ ] CLAUDE.md one-line status refreshed?
- [ ] New files registered in FILE_INDEX?
- [ ] Anything unsaved? → Write it down!
```

---

## Language-independence note

All Part-1 anchors (`## Current Work`, `## Recent Completed`, `## Next Steps`, `## Current Working Principles`, `Iron Rules`, `Driving Manual`, etc.) match **either English or Chinese** headings produced by `init.md` templates — implementations should Grep for either variant. A mixed-language project (e.g., Chinese CLAUDE.md but English CURRENT_STATUS) still checks correctly as long as each document uses one consistent language internally.

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
[1.4] FILE_INDEX:      ✅/❌ N unregistered/N ghosts  (recursive: N indexes)
[1.5] WORKLOG TOC:     ✅/⚠️
[1.6] WORKLOG length:  ✅ N lines / ⚠️/❌
[1.7] Inbox:           ✅ / ⚠️ <unread>/<archival>/<malformed>/<unlogged-outbox>  (skipped if not adopted)
[1.8] Car body:        ✅ N lines / ⚠️/❌
[1.9] Mid-transition:  ✅ coherent / ❌ §6.3.1 repair needed
[1.10] Ops-rules ver.: ✅ vN.N / ⚠️ vX.X (installed: vY.Y) — re-embed
[1.11] Identity lock:  ✅ Present / ⚠️ Missing or incomplete

── Part 2: Principle Reflection ──

🔒 Iron Rules: [list with reflections]
📋 Driving Manual: [list with reflections]
📝 Write It Down: [status]
🔄 Phase coherence: [step titles + assessment]
🗺️ Recovery Chain: [two-layer? self-contained? promotions/demotions?]

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
- Before `/doc-harness sync` or `/doc-harness flush` (to understand the full picture before repairing)
