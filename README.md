# system-design

A skill for practicing system design interviews. Four modes:

- **`mock`** — Claude plays a strict staff-level interviewer. Phases, time-boxing, deep-dive, and a scored debrief at the end.
- **`learn`** — Reverse mock. *You* interview Claude. Watch what good answers look like. With `--auto`, Claude orchestrates two sub-agents (interviewer + candidate) and you observe a full session.
- **`postmortem`** — Diagnose a real interview you took. Pass `--file` with notes, or answer structured questions.
- **`generate`** — Author a fresh question + rubric. Writes four files (`question.md`, `assumptions.md`, `description.md`, `rubric.md`) to `./system-design-questions/<slug>/`.

Works in **Claude Code** (raw skill, or as a plugin via the marketplace) and **Codex CLI**.

## Demo

`learn --auto` on *design X.com's timeline feed* (staff level). Two sub-agents — one interviewer, one candidate — run a full 5-round interview while you watch, and the session closes with a written retrospective grading both sides.

https://github.com/user-attachments/assets/24673305-6dbf-4b39-a04a-6262a61d961c

A shorter clip showing first-run setup (`examples/init/demo-init.mp4`) is also checked into the repo.

## Install

Pick the path that matches your harness. The repo ships three pre-built install layouts so you can copy the right one.

### Claude Code — plugin (recommended)

Install via the built-in marketplace:

```
/plugin marketplace add ftvision/system-design-skill
/plugin install system-design@system-design
```

After install, `/system-design` is available in any Claude Code session. Updates flow through `/plugin update`.

### Claude Code — raw skill copy

```bash
git clone https://github.com/ftvision/system-design-skill.git /tmp/system-design-skill
cp -R /tmp/system-design-skill/.claude/skills/system-design ~/.claude/skills/system-design
```

Verify: `ls ~/.claude/skills/system-design/SKILL.md`. Then `/system-design` is available.

### Codex CLI

User-wide:

```bash
git clone https://github.com/ftvision/system-design-skill.git /tmp/system-design-skill
mkdir -p ~/.agents/skills
cp -R /tmp/system-design-skill/.agents/skills/system-design ~/.agents/skills/system-design
```

Project-local: copy `.agents/skills/system-design/` into your project's `.agents/skills/`.

After install, open `/skills` in Codex (or invoke `$system-design ...`). Restart Codex if the skill doesn't appear immediately.

## Usage

Replace the prefix with whatever your harness uses (`/` for Claude Code, `$` for Codex).

```
system-design mock                              # generate a question, run a strict mock
system-design mock "design a URL shortener"
system-design mock --level=senior

system-design postmortem                        # structured Q&A about a past interview
system-design postmortem --file=./notes.md

system-design generate                          # generate question + rubric (4 files)
system-design generate "rate limiter"
system-design generate "chat system" --level=staff
system-design generate --direction=ml-infra     # bias topic to ML infra subdomain
system-design generate --direction=llm          # LLM inference / RAG / agents

system-design learn                             # you interview Claude
system-design learn "design Cursor's autocomplete backend"
system-design learn --auto                      # two sub-agents, you watch
system-design learn --auto --exchanges=15       # cheaper run (default 30 exchanges)
```

## State (persisted across sessions)

The skill writes to `~/.system-design/state/`:

| File | Purpose |
|---|---|
| `runs.md` | One row per scored session: date, slug, mode, level, direction, and the five dimension scores. The primary tracker — read at the start of each `mock`/`postmortem` to surface a 3-line preamble (total sessions, recurring weak dimensions, last 3 slugs). Slug column also serves as the "already practiced" list for `mock` and `generate`. |
| `weaknesses.md` | One row per weak dimension (score ≤3) from past `mock` debriefs and `postmortem` diagnoses, with a one-line context quote. `mock` biases its deep-dive picks toward recurring weak dimensions. |
| `level.md` | Your target level (default `staff` if absent). |

State is per-user, harness-neutral, and not in this repo. It's created on first use. Same state directory whether you installed in Claude Code or Codex — practice carries over.

## What gets generated where

- `generate` writes question packages to **the current working directory**, under `./system-design-questions/<slug>/`. Run it from wherever you want the files to live (a notes repo, a dotfiles directory, etc.).
- `mock` and `postmortem` update state files in `~/.system-design/state/`.
- `learn` and `learn --auto` don't write any files unless you ask.

## Scoring dimensions

Both `mock` debriefs and `postmortem` diagnoses score across:

1. Requirements scoping
2. High-level structure
3. Deep-dive depth
4. Tradeoff reasoning
5. Communication

Each gets a 1–5 with one-line justification grounded in something you actually said.

## Cost note on `learn --auto`

Each exchange in `--auto` mode = 2 sub-agent calls. Default 30 exchanges = ~60 calls. The skill will tell you the count before starting and let you override with `--exchanges=N`. Use a smaller number to sanity-check the format before committing to a full run.

## Repo layout

```
system-design-skill/
├── README.md                              # this file
├── skill/                                 # canonical source (edit here)
│   ├── SKILL.md
│   └── reference/
│       ├── mock.md
│       ├── learn.md
│       ├── postmortem.md
│       └── generate.md
├── scripts/sync.sh                        # syncs skill/ -> the three install layouts
│
├── .claude-plugin/marketplace.json        # Claude Code marketplace manifest
├── plugin/                                # Claude Code plugin layout
│   ├── .claude-plugin/plugin.json
│   └── skills/system-design/              # synced from skill/
│
├── .claude/skills/system-design/          # Claude Code raw-install layout (synced)
└── .agents/skills/system-design/          # Codex CLI raw-install layout (synced)
```

**Edit `skill/` only.** Run `./scripts/sync.sh` after changes to regenerate the three install layouts. Commit all four (`skill/` + the three synced dirs) so users can `cp` directly without running the script.
