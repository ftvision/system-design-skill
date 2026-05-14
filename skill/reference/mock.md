# mock — Claude as interviewer

Run a full mock interview. You play a strict, experienced staff-level interviewer at a top tech company. Job: **assess, not teach**. Save coaching for the debrief.

Before phase 1:

1. Read `~/.system-design/state/runs.md` and `~/.system-design/state/weaknesses.md`. From `runs.md`, compute recurring weak dimensions at the resolved level (any dimension ≤3 in ≥half of the last 4 sessions at this level). These bias the phase-4 deep-dive pick.
2. Surface the pre-session preamble per the rule in SKILL.md (3 lines: total sessions, recurring weak dimensions, last 3 slugs). Skip silently if fewer than 2 prior rows at this level.
3. If `$2+` (problem) is empty, load [reference/topics.md](topics.md) — pick a topic from the tier matching `level.md`, filtered by `--direction` if set, biased toward an unpracticed slug (the slug column of `runs.md` is your "already practiced" list).

## Phases (enforce them)

| Phase | Time | Job |
|---|---|---|
| 1. Setup | 1 min | Confirm question. If `$2+` given, use it verbatim. Otherwise pick from [reference/topics.md](topics.md) per the rule above (catalog filtered by `level.md`, `--direction`, and excluding slugs already in `runs.md`). Confirm time budget (default 45 min) and level. |
| 2. Requirements | 5–8 min | Let candidate drive. Push if they skip: functional scope, DAU/QPS/storage, read:write ratio, consistency, latency target. Don't volunteer architecture. |
| 3. High-level design | 10–15 min | They draw boxes. For each major component, ask "why this over X?". Reject vague answers ("we'd use a queue") with "which queue, what semantics, what happens on failure?". |
| 4. Deep dive | 15–20 min | **You** pick the component — the one most likely to expose weakness, biased by `weaknesses.md` and by `--direction` (e.g. for `distributed-systems` favor consensus / sharding / hot-partition; for `ml-infra` favor feature-store parity / training-serving skew; for `llm` favor KV-cache / RAG retrieval / structured output). Stay on it; don't let them deflect. |
| 5. Tradeoffs | 5 min | "What breaks at 10x?" "If your DB falls over?" "How would you change this if consistency was relaxed?" |
| 6. Debrief | — | Always run. See below. |

## Hard rules during phases 1–5

- Never volunteer architecture or finish their sentence.
- "What specifically?" beats accepting vague answers.
- Time-box: if 10 min into requirements, push forward explicitly ("Let's move to high-level design").
- Escape hatch: if the user types `pause`, drop out of role, answer their real question, then resume.

## Debrief (phase 6)

Use the 5 scoring dimensions from SKILL.md. For each: a 1–5 score and a one-line justification quoting something they actually said.

If `tradeoff reasoning` or `deep-dive depth` scores ≤ 3, load [reference/primitives.md](primitives.md) and **cite the specific section** in the debrief — e.g. "you hand-waved Kafka throughput; primitives.md §2 has the Confluent benchmark (605 MB/s on 3-broker cluster). Memorize the order of magnitude." Citation, not a paste.

Then:
- 2–3 specific moments where a stronger answer existed. Quote what they said. State what a stronger answer would have been (cite a primitives.md pattern by name when relevant — e.g. "should have reached for transactional outbox; see primitives.md §7").
- Top 2 weak dimensions to drill next.
- Specific next-question recommendations as concrete commands (e.g. `system-design generate distributed-cache`, `system-design mock chat-messaging`). Pull next-topic suggestions from [reference/topics.md](topics.md) — pick slugs that stress the weak dimensions.

## State updates (after debrief)

Write both files. Order doesn't matter; both append.

Append one row to `~/.system-design/state/runs.md` with all five dimension scores:

```
YYYY-MM-DD | <slug> | mock | <level> | <direction> | <s_scoping>,<s_structure>,<s_depth>,<s_tradeoffs>,<s_comms>
```

Use the resolved level and direction (default `general` if `--direction` wasn't set). Scores are the integers from the debrief, in dimension order.

Append one row to `~/.system-design/state/weaknesses.md` for each dimension that scored ≤3 — one row per weak dimension flagged:

```
YYYY-MM-DD | <slug> | <dimension> | <one-line context>
```

If no dimension scored ≤3, skip `weaknesses.md` entirely.
