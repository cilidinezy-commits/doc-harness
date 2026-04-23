# Doc Harness — Resume

Structured state recovery: when context is empty or the user explicitly wants to resume work, systematically read the project's status documents, verify understanding, and produce a recovery report before continuing.

**Purpose**: Doc Harness's Recovery Chain (in CLAUDE.md) and Session Start protocol (spec.md §11.1) describe what an agent *should* do on arrival, but they are implicit — agents may skip them silently, and there is no proof that understanding was actually recovered. `resume` makes state recovery **explicit, verifiable, and user-triggerable**.

**Core guarantee**: After a successful resume, the agent can articulate:
- Who it is (project identity)
- What the project is doing right now (phase goal, active work)
- What should happen next (headlights, blockers)
- Whether it is safe to proceed or user confirmation is needed

> **Relationship to Session Start**: `resume` **codifies and extends** spec.md §11.1. It does not replace it. An agent running `resume` follows the Session Start protocol, then adds the Recovery Report and Understanding Verification phases. If an agent arrives at a project and context is empty, it should run `/doc-harness resume` before proceeding with any work.

---

## When to Use

- User says "resume this project", "continue work", "where were we", "back to [project name]", "pick up where we left off"
- User says "what's the current status?" in a project with existing Doc Harness documents
- Agent detects **empty context** + all 4 core files present → auto-trigger resume before any other action
- After compact recovery (context compressed, user absent) — resume is the mandatory first step before acting on headlights

---

## Two Modes

### `interactive` (default)

Agent produces the Recovery Report, answers verification questions, and **presents them to the user** for confirmation or correction before proceeding.

Use this when:
- User explicitly says "resume" or "continue"
- User is present and can validate the agent's understanding
- The project has complex or ambiguous state that benefits from human review

### `auto` (`--auto` or `-a`)

Agent performs the full procedure without user interaction, writes the Recovery Report to CURRENT_STATUS car body, and makes an autonomous resume decision based on freshness rules.

Use this when:
- Compact recovery (user absent, context reset)
- User explicitly says "resume auto" or "just continue"
- Agent is running as a background process and needs to self-orient

**Auto-mode resume decision tree**:
- CURRENT_STATUS updated today, headlights ≤7 days old, no edge conditions → write `#### Auto-resumed on YYYY-MM-DD` to car body, proceed per headlights
- Headlights 8–30 days old OR any edge condition flagged → write `#### Auto-resume attempted YYYY-MM-DD — waiting for user confirmation` to car body, leave CLAUDE.md at ⏸️ if paused, do NOT proceed silently
- Headlights >30 days OR project explicitly paused → never auto-resume; always wait for user

---

## Procedure

### Phase A: Execute Recovery Chain

Follow the project's Recovery Chain **exactly** as defined in CLAUDE.md and spec.md §11.1. Do not skip steps. Do not read task-conditional entries whose conditions do not match.

**Step 0 — Identity anchor** (before reading any files):
Read the AGENT IDENTITY LOCK at the top of CLAUDE.md. Confirm:
"I am [PROJECT_NAME]'s agent. My role is [role from the lock]."

**Step 1 — Must-read layer**:
Read in order (typically 2–3 files):
1. `CLAUDE.md` — project overview, iron rules, Recovery Chain, operational rules
2. `CURRENT_STATUS.md` — tire tracks, car body, headlights, driving manual

**Step 2 — Task-conditional layer**:
Scan Recovery Chain task-conditional entries. Read **only** those whose conditions match the current situation:
- If `inbox/` has unread messages → read them per Chapter 14 protocol
- If investigating history → read `WORKLOG.md`
- If looking up files → read `FILE_INDEX.md`
- Any project-specific entries (e.g., PHILOSOPHY.md for architectural decisions)

**Step 3 — Edge-condition scan** (before proceeding to report):
Run these checks **in order**:

1. **Mid-transition detection** (spec.md §6.3.1):
   - Check CLAUDE.md phase / WORKLOG TOC / CURRENT_STATUS tire tracks for three-way coherence
   - If incoherent → **repair first** (per §6.3.1 stepwise failure table), then continue resume
   - Record repair in car body if any action taken

2. **Pause check**:
   - Is CLAUDE.md status ⏸️ (paused)?
   - If yes → follow spec.md §6.4 resume rules (confirm headlights freshness, check time-sensitive context)
   - Auto-mode: apply ≤7d / 8–30d / >30d decision tree

3. **Inbox unread check**:
   - Any `status: unread` messages in `inbox/`?
   - If yes → flag as priority action; do not silently ignore

4. **Freshness check**:
   - CURRENT_STATUS "Last updated" date — today? stale (>3 days)?
   - Headlights items — any with explicit dates that have passed?

**Phase A completion checklist**:
```
Phase A (Recovery Chain) complete.
- Must-read files: [list]
- Task-conditional files read: [list, or "none matched"]
- Edge conditions found: [list, or "none"]
- Repairs performed: [list, or "none"]
```

---

### Phase B: Produce Recovery Report (MANDATORY — non-skippable)

> **This phase is the distinguishing feature of resume.** An agent that reads files but does not produce a Recovery Report has not executed resume — it has only performed Session Start.

Synthesize all information gathered in Phase A into the following 7-section report. Each section must contain **agent-generated synthesis**, not copy-pasted headings. The report proves understanding.

#### Section 1: Identity Confirmation

```
Project: [name from CLAUDE.md / AGENT IDENTITY LOCK]
My role: [role from AGENT IDENTITY LOCK]
Current phase: [phase name from CLAUDE.md / CURRENT_STATUS]
Phase status: [⏳ active / ⏸️ paused / other]
```

#### Section 2: Current Phase & Goal

```
Phase goal: [1-2 sentences summarizing the current phase goal from car body]
Started: [date if available]
Key constraints: [any iron rules or driving-manual principles relevant to current work]
```

#### Section 3: Active Work Summary

```
Most recent completed steps (top 3–5 from car body):
  1. [step title + date + one-line what was done]
  2. ...

Current open work:
  - [what is in progress or unresolved]
```

#### Section 4: Next Steps (Headlights)

```
Immediate actions (ranked #1, #2, #3 from headlights):
  #1: [action + any blocker]
  #2: ...

Freshness assessment:
  - Headlights last updated: [date]
  - Items with passed deadlines: [list, or "none"]
  - Confidence that headlights are still valid: [high / medium / low + reason]
```

#### Section 5: Unread Signals

```
Inbox unread: [count + subjects, or "none"]
Outbox pending (if any): [count + recipients awaiting response, or "none"]
Other signals requiring action: [e.g., check.md findings, sync drift detected]
```

#### Section 6: Edge Conditions

```
Mid-transition detected: [yes/no — if yes, repair status]
Project paused: [yes/no — if yes, pause date + reason]
Stale status: [yes/no — CURRENT_STATUS last updated >3 days?]
Critical blockers: [any unresolved issues from car body that prevent work]
```

#### Section 7: Agent Readiness Self-Assessment

```
I am ready to proceed: [yes / no / conditional]
If conditional: [what needs to happen before work can resume]
Recommended action: [proceed per headlights / wait for user / run check|sync|flush first]
```

---

### Phase C: Understanding Verification (MANDATORY — non-skippable)

Answer the following questions **in your own words**, using only the information gathered in Phase A. Do not look up answers — this tests synthesis, not search.

**Question 1 — Phase Goal**: What is the current phase trying to achieve, in one sentence?
- Pass: A concrete, accurate summary of the phase goal
- Fail: Vague, incorrect, or "I need to re-read the documents"

**Question 2 — Next Step**: What is the #1 next step, and what (if anything) blocks it?
- Pass: Specific action + identified blocker or "no blocker"
- Fail: Generic action ("continue working") or missed blocker

**Question 3 — Last Step**: What was the last meaningful step completed before this session?
- Pass: Accurate identification of the most recent car-body entry
- Fail: Wrong step or "unsure"

**Question 4 — Unread Signals**: Are there any unread inbox messages or other signals that require action before normal work?
- Pass: Correct count + subjects, or correctly identifies "none"
- Fail: Misses unread messages or falsely claims action is needed

**Question 5 — Safety Check**: Is it safe to proceed with the #1 next step without user confirmation?
- Pass: Correctly applies auto-resume rules (≤7d fresh + no edge conditions + not paused = safe; otherwise = wait)
- Fail: Auto-proceeds when conditions are unsafe, or waits unnecessarily when conditions are safe

**Phase C completion checklist**:
```
Phase C (Understanding Verification) complete.
- Q1 (Phase Goal): [pass / fail]
- Q2 (Next Step): [pass / fail]
- Q3 (Last Step): [pass / fail]
- Q4 (Unread Signals): [pass / fail]
- Q5 (Safety Check): [pass / fail]
- Overall: [all passed / N failures — action taken]
```

> **If any question fails**: Re-read the relevant document section and retry once. If it fails again, flag in the Recovery Report (Section 7) that understanding is incomplete and user clarification is needed.

---

### Phase D: Resume Decision

**Interactive mode**:
1. Present the full Recovery Report (Sections 1–7) to the user
2. Summarize verification results (Phase C)
3. Ask: "Does this match your understanding? Should I proceed with the #1 next step, or has anything changed?"
4. Record user's response in CURRENT_STATUS car body:
   ```markdown
   #### Resumed on YYYY-MM-DD — user confirmed
   - Recovery report verified: [yes / with corrections]
   - Corrections noted: [list, or "none"]
   - Proceeding with: [#1 next step, or user-directed alternative]
   ```

**Auto mode**:
1. Append Recovery Report (condensed) to CURRENT_STATUS car body
2. Apply auto-resume decision tree (see "Two Modes" above)
3. If proceeding: write `#### Auto-resumed on YYYY-MM-DD` and continue per headlights
4. If waiting: write `#### Auto-resume attempted YYYY-MM-DD — waiting for user confirmation` and stop

---

## Output Format

```
═══════════════════════════════════════
  Doc Harness — Resume
  Project: [name]
  Date: YYYY-MM-DD HH:MM
  Mode: interactive / auto
═══════════════════════════════════════

── Phase A: Recovery Chain ──
Must-read: [files]
Task-conditional: [files read, or "none matched"]
Edge conditions: [list, or "none"]
Repairs: [list, or "none"]

── Phase B: Recovery Report ──
[MANDATORY — all 7 sections must be present]

§1 Identity Confirmation
  Project: ...
  My role: ...
  Current phase: ...

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
Q1 (Phase Goal): [answer] → [pass/fail]
Q2 (Next Step): [answer] → [pass/fail]
Q3 (Last Step): [answer] → [pass/fail]
Q4 (Unread Signals): [answer] → [pass/fail]
Q5 (Safety Check): [answer] → [pass/fail]
Overall: [all passed / N failures]

── Phase D: Resume Decision ──
[Interactive: user confirmation requested]
[Auto: auto-resume decision + car body entry]

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

**resume vs. check**: `check` audits documentation health (are the files correct?). `resume` recovers the agent's understanding of project state (does the agent know what to do?). A project can have healthy docs but an agent with empty context — resume fixes the latter.

**resume vs. Session Start**: `resume` **is** Session Start plus verifiable output. If an agent runs `resume`, it has fulfilled its Session Start obligation. If an agent performs Session Start manually, it has not produced the Recovery Report or Verification — it should run `resume` to complete the process.

---

## Language-Independence Note

All anchors and heading matches follow the same dual-language logic as `check.md` and `sync.md`. In Chinese projects, the Recovery Report sections translate directly:
- §1 身份确认 → §2 当前阶段与目标 → §3 活跃工作摘要 → §4 下一步 → §5 未读信号 → §6 边缘条件 → §7 就绪自评
