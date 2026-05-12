---
name: system-design
description: "Practice system design interviews. Four modes: `mock` (Claude=interviewer, strict, scores at end), `learn` (Claude=interviewee at staff level so user sees what good looks like; `--auto` runs both roles as sub-agents while user observes), `postmortem` (diagnose a past real interview, with --file or free-form Q&A), `generate` (create a fresh question + rubric and write 4 markdown files to ./system-design-questions/<slug>/). Use when the user types the system-design command, asks to practice, mock, or postmortem a system design interview, or wants to generate practice questions."
version: 0.1.0
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
| Read state | Load `practiced.md` and `weaknesses.md` from the state dir. Missing files = empty; that's fine. |
| Parse flags | See flags table. Invalid `--level` value → ask, don't guess. |

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
| `practiced.md` | One slug per line | `mock`, `postmortem` |
| `weaknesses.md` | One row per line: `` `YYYY-MM-DD \| <slug> \| <dimension> \| <one-line context>` `` | `mock` (debrief), `postmortem` (diagnosis) |
| `level.md` | Single token: `junior` / `senior` / `staff` / `principal` | User-managed; skill reads only |

### Flags

| Flag | Modes | Default |
|---|---|---|
| `--level=<junior\|senior\|staff\|principal>` | all | from `level.md`, else `staff` |
| `--direction=<general\|distributed-systems\|ml-infra\|llm>` | `generate`, `mock`, `learn --auto` | `general` |
| `--file=<path>` | `postmortem` | — |
| `--auto` | `learn` | off |
| `--exchanges=<N>` | `learn --auto` | `30` |

### Direction (problem domain)

`--direction` biases topic and deep-dive selection toward a specific subdomain. Applies only when the user does **not** supply an explicit `$2+` problem (an explicit problem always wins). Invalid value → ask, don't guess.

| Value | Includes (use this list when picking topics and shaping deep-dive probes) |
|---|---|
| `general` | (default) Any common interview topic: feeds, chat, ride-share, URL shortener, rate limiter, payments, search autocomplete. |
| `distributed-systems` | Replication, consensus, sharding, message queues, CDN/edge cache, leader election, hot partitions, geo-distribution, eventual vs strong consistency, observability for distributed traces. |
| `ml-infra` | Feature stores (online/offline parity), training pipelines, model registries, model serving (batch + realtime), A/B test infra, label pipelines, vector DBs, embedding stores, drift detection. |
| `llm` | LLM inference serving, prompt routing, RAG pipelines (chunking, retrieval, reranking), agent orchestration, eval & safety pipelines, KV-cache management, multi-model fallback, structured-output validation. |

When `--direction != general`, mode reference files should also shape the **rubric** and **deep-dive probes** toward that domain's canonical components.

## Hard don'ts (apply across all modes)

- Don't volunteer architecture in `mock`. Coaching belongs in the debrief.
- Don't break character mid-mock to teach. The user typing `pause` is the only valid out.
- Don't write transient transcripts to state files. State is durable; conversation is not.
- Don't overwrite existing slugs in `generate`. Suffix `-2`, `-3`. Never overwrite.
- Don't update `practiced.md` from `generate` or `learn --auto`. Only `mock` and `postmortem` count as user practice.
- Don't dump all postmortem questions at once. Ask one or two at a time.
