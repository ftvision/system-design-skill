# postmortem — diagnose a real interview

Diagnose an interview the user already took.

## Input

If `--file=<path>` is given, read that file and treat it as source material (transcript, notes, recruiter feedback, anything).

Otherwise, run a structured Q&A. **Ask one or two questions at a time, not all at once:**

1. What was the question? (one-paragraph recall)
2. What level/role/company, and how long was the interview?
3. Walk through your approach phase by phase — what did you cover in roughly the first third, middle third, last third?
4. Where did the interviewer push hardest? What did they keep returning to?
5. Any feedback from interviewer or recruiter, even vague?
6. What did you feel went well? What didn't?

## Diagnosis

Before scoring: read `~/.system-design/state/runs.md` and surface the pre-session preamble per the rule in SKILL.md (3 lines: total sessions at the resolved level, recurring weak dimensions, last 3 slugs). Skip silently if fewer than 2 prior rows at this level. This frames the diagnosis against the user's recent pattern.

Map their narration to the 5 scoring dimensions (see SKILL.md). For each:
- Estimated score 1–5
- Reasoning grounded in something they said

Then output:

1. **Most likely failure modes** — specific, not generic. Quote what they said and tie it to a specific gap. Example: "You said you 'used a message queue' — staff bar requires naming the queue, semantics, retry behavior, and idempotency story."
2. **What a stronger candidate would have done** at the 2–3 moments they described. When the gap was structural (missing component, wrong topology, deep-dive without a wire-level walkthrough), include a diagram inline showing the stronger answer — in the style specified by `--diagram-style` (default `ascii`; see SKILL.md). Use templates from [reference/diagrams.md](diagrams.md). Skip the diagram when the gap was non-structural (numbers, communication, tradeoff articulation).
3. **Drills** as concrete commands the user can run next (e.g. `system-design mock <topic>`, `system-design generate <topic>`).

## State updates

Resolve the slug: the question's slug if the user named a known one, else `postmortem-YYYY-MM-DD`. Direction is always `general` (postmortem doesn't accept `--direction`).

Append one row to `~/.system-design/state/runs.md` with the estimated dimension scores:

```
YYYY-MM-DD | <slug> | postmortem | <level> | <direction> | <s_scoping>,<s_structure>,<s_depth>,<s_tradeoffs>,<s_comms>
```

Append one row to `~/.system-design/state/weaknesses.md` for each dimension that scored ≤3:

```
YYYY-MM-DD | <slug> | <dimension> | <one-line context>
```

If no dimension scored ≤3, skip `weaknesses.md` entirely.
