# Practice cadence — using this skill to self-teach

A sustainable rhythm for getting better at system design interviews using the four modes of this skill. Roughly 5 hours/week, with diminishing returns past the ladder below.

## The ladder

| Cadence | Mode | Purpose |
|---|---|---|
| Daily, ~15 min | `system-design generate <topic>` | Read the rubric + assumptions + interviewer notes. Don't solve. Just absorb what "good" and "common failure modes" look like for varied problems. After ~10 of these, you have a working catalog. |
| 2×/week, 45 min | `system-design mock <topic>` cold | Run a real-feeling mock. The interviewer pushes on requirements gathering and picks the deep-dive you didn't. Ends with a scored debrief that updates your state. |
| 1×/week, ~30 min | `system-design learn --auto <topic> --exchanges=10` | Watch two agents run a full session. The transcript shows what staff-bar pacing and density look like; the retrospective shows where even strong runs have holes. |
| Within 24h of a real interview | `system-design postmortem` | Memory decay is brutal — what feels vague today is unrecoverable next week. Run this immediately after every real round, win or lose. |

(Replace the prefix with whatever your harness uses — `/` for Claude Code, `$` for Codex.)

---

## How the modes compound

### `generate` builds your pattern catalog

Each generate run produces four files (question, assumptions, description, rubric). After ~10 different topics you'll have internalized:

- What 5–8 clarifying questions *actually* looks like across domains
- The shape of plausible numbers (DAU, QPS, payload, latency) for common workloads
- Which components real interviewers zoom into for each pattern
- The 3–5 common candidate traps per question

This is cheap and high-leverage. You're not solving — you're absorbing the interviewer's mental model.

### `mock` exposes what isn't yet reflexive

Cold mocks reveal the gap between *"I know I should batch clarifying questions"* and *"I reflexively batch clarifying questions under pressure."* The scored debrief is honest about which of the five dimensions are still weak, and the state file biases the next mock's deep-dive toward your recurring weaknesses.

### `learn --auto` gives you a reference recording

You don't need to do this often. The point is to see what staff-bar density and pacing sound like on a problem similar to one you'd be asked. Read the transcript actively — pause at the candidate turns and ask *"would I have said something this dense at this point?"*

The retrospective is the most valuable part. Even strong runs have real flaws; spotting them is the same skill as recovering from your own.

### `postmortem` converts experience into signal

A real interview is the most expensive data you'll generate this quarter. Postmortem within 24 hours, every time. It writes to the same `weaknesses.md` that biases future mocks — so a single bad round automatically focuses the next month of practice.

---

## Getting started

If you're picking up this skill cold:

1. **Day 1, 30 min.** Run `generate "URL shortener"` and `generate "rate limiter"`. Read both packages end-to-end. Don't try to solve. Notice the shape of the rubric.
2. **Day 2, 45 min.** Run `mock` cold on either question. Get the debrief. Note where you scored low.
3. **Day 3, 30 min.** Run `learn --auto --exchanges=8` on a question in a domain you don't know well (chat, payments, notifications, search). Read the transcript and retrospective.
4. **Day 4 onward.** Settle into the ladder above.

---

## What signals progress

Three observable changes after ~6 weeks on the ladder:

- Your clarifying-question count climbs from 2–3 to 6–8 in the first 2 minutes, and they include **scale before semantics**.
- You finish requirements + back-of-envelope numbers **before** drawing any architecture box.
- The phrase *"X over Y because Z"* appears in your speech reflexively, with numbers attached.

If `weaknesses.md` keeps logging the same dimension after 3–4 mocks, drill it: run `generate` on a question that maximally pressures that dimension, then `mock` it twice in a week.

---

## What state persists

The skill writes to `~/.system-design/state/`:

- `practiced.md` — slugs already attempted; prevents `generate` and `mock` from repeating.
- `weaknesses.md` — append-only log of weak dimensions per session. `mock` reads this and biases deep-dive picks.
- `level.md` — your target level (default `staff`).

State is per-user, persists across sessions, and is shared between Claude Code and Codex installs. You don't need to bring anything between sessions — the skill remembers.
