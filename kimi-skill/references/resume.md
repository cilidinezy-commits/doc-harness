# Doc Harness — Resume (Kimi CLI Version)

Structured state recovery: when context is empty or the user explicitly wants to resume work, systematically read the project's status documents, verify understanding, and produce a recovery report before continuing.

**Trigger**: User says something like "resume this project", "continue work", "where were we", "back to project", "pick up where we left off", "what's the current status".

**Core guarantee**: After a successful resume, the agent can articulate: (1) its project identity and role, (2) the current phase goal, (3) the active work state, (4) the #1 next step and its blockers, and (5) whether it is safe to proceed or user confirmation is needed.

> **Relationship to Session Start**: `resume` **codifies and extends** the Session Start protocol (spec.md §11.1). An agent running `resume` follows Recovery Chain exactly, then adds mandatory Recovery Report synthesis and Understanding Verification. If an agent arrives at a project and context is empty, it should run `resume` before proceeding with any work.

---

## How Kimi Decides: Ask or Auto?

Same as sync and flush — default is to ask user before proceeding with headlights. Auto-decision only if user explicitly says "just continue", "no need to ask", "auto resume".

**Auto-resume decision tree** (applied when user is absent or explicitly requests auto):
- CURRENT_STATUS updated today, headlights ≤7 days old, no edge conditions, not paused → proceed per headlights
- Headlights 8–30 days old OR any edge condition → write "waiting for user confirmation" to car body, do NOT proceed
- Headlights >30 days OR explicitly paused → always wait for explicit user direction

---

## Procedure

### Phase A: Execute Recovery Chain

Follow the project's Recovery Chain **exactly** as defined in CLAUDE.md and spec.md §11.1.

**Step 0 — Identity anchor** (before reading any files):
Read the AGENT IDENTITY LOCK at the top of CLAUDE.md. Confirm:
"I am [PROJECT_NAME]'s agent. My role is [role from the lock]."

**Step 1 — Must-read layer**:
Read in order (typically 2–3 files):
1. `CLAUDE.md` — project overview, iron rules, Recovery Chain, operational rules
2. `CURRENT_STATUS.md` — tire tracks, car body, headlights, driving manual

**Step 2 — Task-conditional layer**:
Scan Recovery Chain task-conditional entries. Read **only** those whose conditions match the current situation.

**Step 3 — Edge-condition scan**:
1. **Mid-transition detection** (spec.md §6.3.1): check CLAUDE.md phase / WORKLOG TOC / CURRENT_STATUS tire tracks for coherence. Repair if needed.
2. **Pause check**: Is CLAUDE.md status ⏸️? If yes, follow spec.md §6.4 resume rules.
3. **Inbox unread check**: Any `status: unread` messages in `inbox/`?
4. **Freshness check**: CURRENT_STATUS "Last updated" — today? stale (>3 days)?

---

### Phase B: Produce Recovery Report (MANDATORY — non-skippable)

Synthesize all information into 7 sections. Each section must contain **agent-generated synthesis**, not copy-pasted headings.

#### §1 Identity Confirmation
- Project, role, current phase, phase status

#### §2 Current Phase & Goal
- Phase goal (1–2 sentences), start date, key constraints

#### §3 Active Work Summary
- Top 3–5 recent completed steps from car body
- Current open work

#### §4 Next Steps
- Immediate actions ranked #1, #2, #3 from headlights
- Freshness assessment (last updated, passed deadlines, confidence)

#### §5 Unread Signals
- Inbox unread count + subjects
- Outbox pending (if any)
- Other signals requiring action

#### §6 Edge Conditions
- Mid-transition detected (yes/no + repair status)
- Project paused (yes/no + date + reason)
- Stale status (>3 days?)
- Critical blockers

#### §7 Agent Readiness Self-Assessment
- Ready to proceed: yes / no / conditional
- If conditional: what needs to happen first
- Recommended action

---

### Phase C: Understanding Verification (MANDATORY — non-skippable)

Answer in your own words using only Phase A information:

1. **Phase Goal**: What is the current phase trying to achieve, in one sentence?
2. **Next Step**: What is the #1 next step, and what (if anything) blocks it?
3. **Last Step**: What was the last meaningful step completed before this session?
4. **Unread Signals**: Are there any unread inbox messages requiring action before normal work?
5. **Safety Check**: Is it safe to proceed with the #1 next step without user confirmation?

If any answer is uncertain → flag in Recovery Report §7 that understanding is incomplete and user clarification is needed.

---

### Phase D: Resume Decision

**Ask-user mode** (default):
1. Present full Recovery Report to user
2. Summarize verification results
3. Ask: "Does this match your understanding? Should I proceed with the #1 next step, or has anything changed?"
4. Record response in CURRENT_STATUS car body

**Auto mode** (user explicitly requests or compact recovery):
1. Append condensed Recovery Report to car body
2. Apply auto-resume decision tree
3. Proceed or wait per rules

---

## Output Format

```
═══════════════════════════════════════
  Doc Harness — Resume
  Project: [name]
  Date: YYYY-MM-DD HH:MM
  Mode: ask-user / auto
═══════════════════════════════════════

── Phase A: Recovery Chain ──
Must-read: [files]
Task-conditional: [files read, or "none matched"]
Edge conditions: [list, or "none"]
Repairs: [list, or "none"]

── Phase B: Recovery Report ──
§1 Identity Confirmation
  ...
§2 Current Phase & Goal
  ...
§3 Active Work Summary
  ...
§4 Next Steps
  ...
§5 Unread Signals
  ...
§6 Edge Conditions
  ...
§7 Agent Readiness Self-Assessment
  ...

── Phase C: Understanding Verification ──
Q1–Q5 with pass/fail

── Phase D: Resume Decision ──
[Ask-user: user confirmation requested]
[Auto: decision + car body entry]

═══════════════════════════════════════
```

---

## Relationship to Other Commands

| Situation | Command |
|-----------|---------|
| No Doc Harness files at all | `init` |
| Docs present, context empty, need to recover state | `resume` |
| Docs present, context OK, want to audit health | `check` |
| Docs present, context OK, drift detected | `sync` |
| Context about to compress | `flush` |
| Need to find specific information | `recall` |
