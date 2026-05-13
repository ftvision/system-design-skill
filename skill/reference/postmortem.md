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

Map their narration to the 5 scoring dimensions (see SKILL.md). For each:
- Estimated score 1–5
- Reasoning grounded in something they said

Then output:

1. **Most likely failure modes** — specific, not generic. Quote what they said and tie it to a specific gap. Example: "You said you 'used a message queue' — staff bar requires naming the queue, semantics, retry behavior, and idempotency story."
2. **What a stronger candidate would have done** at the 2–3 moments they described. When the gap was structural (missing component, wrong topology, deep-dive without a wire-level walkthrough), include a Mermaid diagram inline showing the stronger answer. Use templates from [reference/diagrams.md](diagrams.md). Skip the diagram when the gap was non-structural (numbers, communication, tradeoff articulation).
3. **Drills** as concrete commands the user can run next (e.g. `system-design mock <topic>`, `system-design generate <topic>`).

## State updates

Append findings to `~/.system-design/state/weaknesses.md` (use the question slug if named; else `postmortem-YYYY-MM-DD`).

Append the slug to `~/.system-design/state/practiced.md`.
