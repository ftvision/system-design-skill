---
name: system-design
description: "Practice system design interviews. Four modes: `mock` (Claude=interviewer, strict, scores at end), `learn` (Claude=interviewee at staff level so user sees what good looks like; `--auto` runs both roles as sub-agents while user observes), `postmortem` (diagnose a past real interview, with --file or free-form Q&A), `generate` (create a fresh question + rubric and write 4 markdown files to ./system-design-questions/<slug>/). Use when the user types the system-design command, asks to practice, mock, or postmortem a system design interview, or wants to generate practice questions."
version: 0.3.0
argument-hint: "<mock|learn|postmortem|generate> [problem-or-topic] [--flags]"
user-invocable: true
---

# System Design Interview Practice

A practice harness for system design interviews. Each invocation dispatches on the first positional argument.

> Invocation differs by harness: Claude Code uses `/system-design ...`, Codex uses `$system-design ...`. The rest of this document writes commands without a prefix — use whichever your harness expects.

## Commands

| `$1` | Description | Reference |
|---|---|---|
| `mock [problem]` | Claude = strict interviewer. Phases enforced, scored debrief at end. | [reference/mock.md](reference/mock.md) |
| `learn [problem] [--auto]` | User = interviewer, Claude = staff candidate. `--auto` runs both via sub-agents while user observes. | [reference/learn.md](reference/learn.md) |
| `postmortem [--file=<path>]` | Diagnose a real interview the user already took. | [reference/postmortem.md](reference/postmortem.md) |
| `generate [topic]` | Author a new question + rubric. Writes 4 markdown files to `./system-design-questions/<slug>/`. | [reference/generate.md](reference/generate.md) |

## Routing rules

1. **No argument** — show the command table above and ask which mode + topic. Don't guess.
2. **First word matches a command** — run setup below, then load the matching reference file and follow its instructions. Everything after `$1` is mode-specific (problem text, flags).
3. **First word unrecognized** — ask, don't guess.

## Setup (every invocation)

Run before loading the reference file.

| Step | Action |
|---|---|
| Read level | Load `~/.system-design/state/level.md`. If absent, default to `staff`. `--level=<value>` overrides for this invocation. |
| Read state | Load `runs.md` and `weaknesses.md` from the state dir. Missing files = empty; that's fine. |
| Parse flags | See flags table. Invalid `--level` value → ask, don't guess. `--say` follows the Voice rules below (invalid voice → silent fallback, never ask). |

## Shared concepts

### Scoring dimensions

Both `mock` and `postmortem` score across these. For each: 1–5 with a one-line justification grounded in something the candidate actually said.

1. **Requirements scoping** — gathering scope, scale, latency, consistency before designing.
2. **High-level structure** — right boxes, coherent data flow.
3. **Deep-dive depth** — reaching real specificity (schemas, queue semantics, failure modes) when pushed.
4. **Tradeoff reasoning** — "why this over X" answered with numbers and constraints, not preferences.
5. **Communication** — clarity, pacing, recovery from pushback.

### State files

Location: `~/.system-design/state/`. Create the directory on first write; absent = empty.

| File | Format | Written by |
|---|---|---|
| `runs.md` | One row per scored session: `` `YYYY-MM-DD \| <slug> \| <mode> \| <level> \| <direction> \| <s1>,<s2>,<s3>,<s4>,<s5> \| <next>` ``. Scores are the 5 dimensions in order: scoping, structure, depth, tradeoffs, comms. `<next>` is one short sentence — the single most actionable drill before next session — or blank if nothing specific emerges. | `mock` (debrief), `postmortem` (diagnosis) |
| `weaknesses.md` | One row per weak dimension (score ≤3): `` `YYYY-MM-DD \| <slug> \| <dimension> \| <one-line context>` `` | `mock` (debrief), `postmortem` (diagnosis) |
| `level.md` | Single token: `junior` / `senior` / `staff` / `principal` | User-managed; skill reads only |

`runs.md` is the primary tracker — slug, level, direction, and the five scores are all there. `weaknesses.md` annotates the recurring gaps with a one-line context quote per weak dimension. Project the slug column of `runs.md` for "already practiced" checks.

### Pre-session preamble (mock and postmortem)

Before phase 1 of `mock` (and before diagnosis in `postmortem`), if `runs.md` has ≥2 prior rows at the resolved level, surface a preamble to the user (3 or 4 lines depending on the last row's `<next>` field):

1. Total sessions at this level (count rows where `<level>` matches the resolved level).
2. Recurring weak dimensions — name any of the 5 dimensions that scored ≤3 in ≥half of the last 4 sessions at this level. If none, say "no recurring weaknesses; pick a new topic to broaden."
3. Last 3 slugs practiced at this level, most recent first.
4. Last session's action item — if the most recent row at this level has a non-blank `<next>` field, surface it as `last action item: <text>`. Omit the line if blank or if the row is in the legacy 6-column format.

If fewer than 2 rows exist at this level, skip the preamble silently — it has nothing useful to say yet. Rows in the legacy 6-column format (no trailing `<next>`) are read as `<next>` = empty.

### Flags

| Flag | Modes | Default |
|---|---|---|
| `--level=<junior\|senior\|staff\|principal>` | all | from `level.md`, else `staff` |
| `--direction=<general\|distributed-systems\|ml-infra\|llm>` | `generate`, `mock`, `learn --auto` | `general` |
| `--diagram-style=<ascii\|mermaid>` | `learn`, `postmortem` | `ascii` |
| `--file=<path>` | `postmortem` | — |
| `--auto` | `learn` | off |
| `--exchanges=<N>` | `learn --auto` | `30` |
| `--say[=<voice>\|elevenlabs]` | `mock`, `learn` | off |

### Direction (problem domain)

`--direction` biases topic and deep-dive selection toward a specific subdomain. Applies only when the user does **not** supply an explicit `$2+` problem (an explicit problem always wins). Invalid value → ask, don't guess.

| Value | Includes (use this list when picking topics and shaping deep-dive probes) |
|---|---|
| `general` | (default) Any common interview topic: feeds, chat, ride-share, URL shortener, rate limiter, payments, search autocomplete. |
| `distributed-systems` | Replication, consensus, sharding, message queues, CDN/edge cache, leader election, hot partitions, geo-distribution, eventual vs strong consistency, observability for distributed traces. |
| `ml-infra` | Feature stores (online/offline parity), training pipelines, model registries, model serving (batch + realtime), A/B test infra, label pipelines, vector DBs, embedding stores, drift detection. |
| `llm` | LLM inference serving, prompt routing, RAG pipelines (chunking, retrieval, reranking), agent orchestration, eval & safety pipelines, KV-cache management, multi-model fallback, structured-output validation. |

When `--direction != general`, mode reference files should also shape the **rubric** and **deep-dive probes** toward that domain's canonical components.

### Diagram style

`--diagram-style` controls how Claude renders diagrams in modes that draw them (`learn`, `postmortem`). Pick once at the start of a session; don't mix styles mid-flow.

| Value | Renders in | Use when |
|---|---|---|
| `ascii` (default) | Any terminal, Codex CLI, plain Markdown, code-review diffs, Slack | Default — works everywhere |
| `mermaid` | Claude Code, GitHub, Markdown viewers with Mermaid support | User is reading in a rendered surface and asks for it explicitly |

Templates for both styles live in [reference/diagrams.md](reference/diagrams.md). The mode files honor the flag — don't draw in the wrong style.

### Voice (`--say`)

`--say` reads **spoken turns** aloud through the bundled `scripts/speak.sh` helper (resolve it relative to this skill's directory). Off by default. Only `mock` (Claude = interviewer) and `learn` (Claude = candidate) have a voice role; `--say` is a silent no-op in `postmortem` and `generate`.

| Form | Effect |
|---|---|
| `--say` | On, using native macOS `say` with per-role default voices. |
| `--say=<voice>` | On, forcing that macOS voice for the single speaking role (e.g. `--say=Samantha`). In `learn --auto`, ignored in favor of the two-voice defaults below — override those via env instead. |
| `--say=elevenlabs` | On, routing through ElevenLabs if `ELEVENLABS_API_KEY` is set; falls back to native `say` otherwise. |

**ElevenLabs setup:** export `ELEVENLABS_API_KEY`. Voices are picked by **role**: built-in defaults already give `primary` (interviewer / single-speaker) and `secondary` (candidate) two distinct ElevenLabs voices, so `learn --auto` works with no extra setup. Override either with `ELEVENLABS_VOICE_PRIMARY` / `ELEVENLABS_VOICE_SECONDARY`, or force one voice everywhere with `ELEVENLABS_VOICE_ID`. Any network/auth failure falls back to native `say` mid-session without interrupting.

**Preflight (required when `--say=elevenlabs`).** Before the first spoken turn, run the bundled check and act on it — do **not** start the interview until it's resolved:

```
bash <skill-dir>/scripts/speak.sh --check --engine=elevenlabs --roles=<roles>
```

`<roles>` is the role(s) this session will use: `mock` and `learn` default → `primary`; `learn --auto` → `primary,secondary`. Read the final `STATUS:` line:

- `ready` → proceed silently.
- `needs-key` or `needs-voices` → **relay the command's printed guidance to the user verbatim** (it contains the exact `export` lines and how to list voice IDs), then ask them to either (a) set the vars — in `~/.zshrc`, then reply so you re-run `--check` — or (b) continue this session on native `say` instead, or (c) cancel. Loop on `--check` until `ready` or the user picks a fallback.

This preflight applies only to `--say=elevenlabs`. Plain `--say` / `--say=<voice>` use native `say` and need no check.

How modes call it:

- **Single source — pipe the displayed turn in via stdin; never retype it.** Capture each turn once (the sub-agent's returned text in `--auto`, or the exact string you're about to display otherwise), display *that*, and feed the *same* value to the helper on stdin:
  `printf '%s' "$turn" | bash <skill-dir>/scripts/speak.sh --voice=<name> --role=<primary|secondary>`
  Screen and audio must come from one variable so they cannot diverge. **Do not** hand-write, condense, summarize, re-order, or respell a separate "spoken version" in the command — that reintroduces drift.
- `--voice` is the macOS `say` voice; `--role` selects the ElevenLabs voice (single-speaker modes → `primary`; `learn --auto` → `primary` for interviewer, `secondary` for candidate).
- The helper sanitizes its stdin itself — stripping fenced diagrams, markdown tables, stray ASCII-art, and inline markup — while keeping the prose **verbatim**. So pass the full turn (diagrams and all); don't pre-edit it. macOS `say` handles acronyms and numbers acceptably on its own.
- Default voices: interviewer = `Daniel` (en_GB), candidate = `Samantha` (en_US). These are deliberately distinct so `learn --auto` is a listenable two-person dialog. Override with env `SD_VOICE_INTERVIEWER` / `SD_VOICE_CANDIDATE` (single-role modes also honor a plain `--say=<voice>`).
- Speaking is synchronous (turns are heard in order). Never let a TTS failure interrupt the session — `speak.sh` always exits 0; treat it as fire-and-forget.

Invalid voice names fall back to the default inside `speak.sh` — don't ask, don't error.

### Reference assets (load on demand)

These are reference files modes consult when relevant. Don't load them on every invocation; load when the rule below fires.

| File | Load when |
|---|---|
| [reference/primitives.md](reference/primitives.md) — cited cheatsheet of latency, capacity, BOE templates, named patterns | `mock` debrief when scoring `tradeoff reasoning` or `deep-dive depth` ≤ 3 (cite the relevant section); `postmortem` when diagnosis includes "missed numbers" or "no BOE"; `learn` when the candidate-side agent needs to ground a number. |
| [reference/topics.md](reference/topics.md) — vetted topic catalog with difficulty + slugs | `mock` or `learn` invoked without a topic (suggest from the catalog filtered by `level.md` and `--direction`); `generate` invoked without a topic (pick from `modern` or `staff+`). |
| [reference/diagrams.md](reference/diagrams.md) — Mermaid cheatsheet with system-design templates | `learn` whenever Claude is in the candidate role (default mode always; `--auto` candidate sub-agent only — never the interviewer sub-agent); `postmortem` when illustrating a structural gap in "what stronger would have done." **Never** loaded by `mock` (interviewer doesn't draw) or `generate` (questions are prose only). |

## Hard don'ts (apply across all modes)

- Don't volunteer architecture in `mock`. Coaching belongs in the debrief.
- Don't break character mid-mock to teach. The user typing `pause` is the only valid out.
- Don't write transient transcripts to state files. State is durable; conversation is not.
- Don't overwrite existing slugs in `generate`. Suffix `-2`, `-3`. Never overwrite.
- Don't update `runs.md` or `weaknesses.md` from `generate` or `learn --auto`. Only `mock` and `postmortem` count as user practice.
- Don't dump all postmortem questions at once. Ask one or two at a time.
