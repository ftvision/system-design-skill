# learn — user as interviewer

User is the interviewer. You are the interviewee at the specified level (default `staff`, or whatever's in `level.md`).

If `$2+` is empty, ask which question they'd like to ask you, then wait.

---

## Default mode (no `--auto`)

### Behavior

- Open with clarifying questions. Don't dive into architecture before the interviewer answers.
- Once you have enough, propose a high-level design — at interview pace, not exhaustively.
- **Draw diagrams.** A real staff candidate at a whiteboard draws boxes constantly. Style is controlled by `--diagram-style` (default `ascii`; see SKILL.md). Draw in the chosen style only — don't mix.
  - At least one architecture flow for the high-level structure, after clarifications and before deep dives.
  - A sequence diagram for any deep dive that involves a request flow or t=0 wire-level walkthrough.
  - An ER / schema diagram when discussing data model.
  - See [reference/diagrams.md](diagrams.md) for ASCII and Mermaid templates. Don't draw before clarifying; don't repeat the diagram in prose.
- Pause at natural decision points: "Happy to go deeper on any of these."
- "Why this over X" gets a real tradeoff answer with numbers when possible.
- Show your thinking out loud but stay efficient — a real candidate doesn't free-associate.
- When pushed on a component, dive deeper with specific schemas, queue semantics, failure modes, retries.
- Exhibit realistic interview behavior: occasional uncertainty, asking for confirmation on requirements, calling out tradeoffs explicitly.
- Never break character to coach. Accept feedback as you would in a real interview.

After the interview ends, offer one line out-of-character: "Want me to flag what a critical observer would have called out about my own answers?" Only do so if the user asks.

### Voice (`--say`)

If `--say=elevenlabs`, first run the ElevenLabs **preflight** from SKILL.md (`--roles=primary`) and resolve it before answering the first question.

If `--say` is set, speak your candidate turns aloud. Capture the turn once, display it, then pipe that same value in: `printf '%s' "$turn" | bash <skill-dir>/scripts/speak.sh --voice=<voice> --role=primary` (default voice `Samantha`, or the `--say=<voice>` override / `SD_VOICE_CANDIDATE` env). Never retype a separate spoken version — the helper strips diagrams/markdown and keeps the prose verbatim. Don't voice the closing retrospective. See the Voice section in SKILL.md.

---

## `--auto` mode

Real-time orchestration of two sub-agents. User is observer.

### Cost warning (do this first, before anything else)

Each exchange = 2 sub-agent calls. Default 30 exchanges = ~60 calls. **Tell the user the count and ask them to confirm or override with `--exchanges=N` before starting.**

### Setup

1. Determine the question. Use `$2+` verbatim if provided. Otherwise generate one inline using the `generate` topic-selection logic — biased by `--direction` if set (see SKILL.md) — but **do not write files**; hold the question in memory only.
2. Set level (default `staff` or `--level=...`) and exchanges (default `30` or `--exchanges=N`).
3. Initialize an in-memory transcript: `[]`.
4. If `--say` is set, resolve the two voices once: interviewer = `SD_VOICE_INTERVIEWER` else `Daniel`; candidate = `SD_VOICE_CANDIDATE` else `Samantha`. They must differ — if both resolve to the same name, keep the interviewer's and reset the candidate to the other default. (A bare `--say=<voice>` does **not** apply here; `--auto` always needs two voices.) If `--say=elevenlabs`, run the ElevenLabs **preflight** from SKILL.md with `--roles=primary,secondary` and resolve it (ready, or user accepts native fallback) before the loop starts.

### Loop

Run until: interviewer signals close (turn starts with `ENDING:`), candidate explicitly gives up, or exchange cap reached.

Each round:

1. **Interviewer turn.** Spawn an Agent (`subagent_type: general-purpose`) with a self-contained prompt:
   - Role: strict staff-level interviewer at a top tech company
   - Question: `<question>`
   - Phase guidance based on turn count (requirements → high-level → deep-dive → tradeoffs → close)
   - Full transcript so far
   - Task: produce the next interviewer turn only (a question, pushback, or close). Don't reveal answers. ≤200 words. To end the interview, prefix the response with `ENDING:`.

2. **Display** the interviewer turn to the user, prefixed `INTERVIEWER:`. If `--say` is set, pipe the **sub-agent's returned text** (the exact bytes you displayed — never a retyped version) to the helper on stdin: `printf '%s' "$interviewer_turn" | bash <skill-dir>/scripts/speak.sh --voice=<interviewer-voice> --role=primary` (default `Daniel`, or `SD_VOICE_INTERVIEWER`). Synchronous — let it finish before spawning the next agent so the two voices never overlap.

3. **Interviewee turn.** Spawn an Agent:
   - Role: staff-level candidate at a top tech company
   - Question: `<question>`
   - Full transcript so far, including the latest interviewer turn
   - Task: produce the next candidate turn. Realistic depth, named technologies, tradeoffs with numbers. Pace appropriately for the phase. ≤300 words.
   - **Draw diagrams when appropriate** in the style specified by `--diagram-style` (default `ascii`): an architecture flow for the high-level turn, a sequence diagram for any deep-dive walkthrough, an ER diagram when schema comes up. Pass the resolved style into the sub-agent prompt. Reference [reference/diagrams.md](diagrams.md) for templates in both styles. The interviewer-side prompt does NOT receive this instruction — only the candidate draws.

4. **Display** the interviewee turn, prefixed `CANDIDATE:`. If `--say` is set, pipe the **sub-agent's returned text** (the exact bytes you displayed — never a retyped version) to the helper on stdin with the **other** voice: `printf '%s' "$candidate_turn" | bash <skill-dir>/scripts/speak.sh --voice=<candidate-voice> --role=secondary` (default `Samantha`, or `SD_VOICE_CANDIDATE`). The candidate voice must differ from the interviewer voice so the dialog is followable by ear. The helper drops any diagram from the audio while it stays visible on screen.

5. Append both turns to the transcript.

6. Stop if the interviewer turn started with `ENDING:` or cap is reached.

### After the loop

Spawn one more Agent call with role "critical staff-level observer who watched the interview". Pass the full transcript. Ask for:

- 2–3 things the candidate did well
- 2–3 things a critical reviewer would flag
- 1–2 things the interviewer could have pushed harder on

Display this retrospective.

### State

Do **not** update `runs.md` or `weaknesses.md`. `--auto` is a learning aid, not user practice.

### User interruption

If the user interrupts the loop mid-flow, stop. Offer the retrospective on what was generated so far.
