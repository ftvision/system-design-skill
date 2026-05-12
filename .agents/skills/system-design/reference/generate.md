# generate — author a fresh question + rubric

Write 4 markdown files to `./system-design-questions/<slug>/` in the current working directory.

## Topic selection

- If `$2+` is provided, use it as the topic.
- If not, pick a domain biased toward weak dimensions in `~/.system-design/state/weaknesses.md`. Avoid slugs already in `~/.system-design/state/practiced.md`.

## Slug

Kebab-case the topic: lowercase, alphanumerics + hyphens. "Twitter feed" → `twitter-feed`.

If `./system-design-questions/<slug>/` already exists, suffix `-2`, `-3`, etc. **Never overwrite.**

## Files (exactly four)

### `question.md`

The interview question as the interviewer would deliver it. One paragraph. No solution hints. Write it the way a real interviewer speaks it aloud at the start of an interview.

### `assumptions.md`

Capacity assumptions a candidate should arrive at or be given. Concrete plausible numbers, not ranges.

- DAU / MAU
- QPS at peak (read and write separately)
- Payload sizes
- Storage growth per year
- Latency target (p50, p99)
- Read:write ratio

### `description.md`

Interviewer notes — what to look for:

- 5–8 clarifying questions a strong candidate should ask
- 2–3 likely deep-dive targets (the components an interviewer would zoom into)
- 3–5 common candidate failure modes (specific traps for this question)
- 1–2 "what breaks at 10x" follow-ups

### `rubric.md`

Per-dimension scoring rubric at the requested level and one above:

| Dimension | Bar at `<level>` | Bar at `<level+1>` |
|---|---|---|
| Requirements scoping | ... | ... |
| High-level structure | ... | ... |
| Deep-dive depth | ... | ... |
| Tradeoff reasoning | ... | ... |
| Communication | ... | ... |

Each cell is a one-sentence concrete observable behavior. No platitudes.

## After writing

Do **not** append to `practiced.md` — the user hasn't practiced the question yet. That happens on `mock`.

Report the slug and the four file paths back to the user.
