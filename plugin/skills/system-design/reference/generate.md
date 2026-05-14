# generate — author a fresh question + rubric

Write 4 markdown files to `./system-design-questions/<slug>/` in the current working directory.

## Topic selection

- If `$2+` is provided, use it as the topic verbatim. `--direction` is ignored in this case.
- If not, pick a topic by combining, in order:
  1. **`--direction`** (if set, default `general`) — pick a topic from that subdomain. See the Direction table in SKILL.md for what each value includes.
  2. **`weaknesses.md`** — bias toward a topic that maximally pressures the user's recurring weak dimensions.
  3. **`runs.md`** — exclude slugs already attempted (project the slug column).

When `--direction != general`, also shape `description.md` and `rubric.md` so the likely deep-dive targets, common failure modes, and per-dimension bars emphasize that domain's canonical components (e.g. for `distributed-systems` expect consensus / sharding / hot-partition probes; for `ml-infra` expect feature-store parity / training-serving skew / model rollout probes; for `llm` expect KV-cache / RAG retrieval-quality / structured-output probes).

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

Do **not** append to `runs.md` — the user hasn't practiced the question yet. That happens on `mock`.

Report the slug and the four file paths back to the user.
