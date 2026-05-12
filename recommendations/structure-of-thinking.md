# Structure of thinking — system design at staff bar

A small number of patterns to internalize, not a checklist. These show up across questions; if they're reflexive, the design follows.

## The one sentence

**Numbers force architecture. Architecture forces tradeoffs. Tradeoffs reveal seniority.**

The chain runs in one direction. Skip the first link — requirements without scale numbers — and the rest collapses: architecture choices have no forcing function, tradeoffs become preferences, the interviewer has nothing at staff bar to grade.

---

## The five moves

### 1. Pin or Default

Never accept ambiguity, but never block on it either. Batch 5–8 clarifying questions at once, **with the assumption you'll make if the interviewer doesn't pin each one**. This simultaneously:

- shows you can scope
- gives the interviewer a fast way to course-correct
- gives you permission to keep moving

A staff-bar opener looks like:

> *"Before architecture, a few things. Order of magnitude — 1M, 100M, 1B users? Typical payload — KB, MB? Update frequency — interactive, hourly, rare? Freshness SLO — seconds, minutes, next-launch? If you don't pin these, I'll assume X for ..."*

### 2. Math first, architecture follows

Before drawing any box: QPS (read vs write split), payload size, storage growth, peak fanout. The numbers do the design work for you:

- 95% cache hit rate → CDN
- 60k peak writes → sharding
- <30s propagation to 50k devices → push, not poll

The architecture becomes *constrained* by the numbers, not *chosen* by preference. A common failure mode is sketching the standard boxes (web tier, app tier, database) before any number forces them.

### 3. "X over Y because Z" — for every named component

Not *"we'll use a queue."*
→ *"Kafka over Redis Streams because durable replay and partition ordering — audit needs replay, we want per-key ordering, the latency tradeoff is acceptable."*

Not *"version per field."*
→ *"Per-field LWW over CRDTs because single-actor writes and scalar fields; over full-doc versioning because that would 409 every disjoint edit, killing UX."*

Every named technology earns its place with a one-sentence defense. Reflexively naming Kafka, Redis, Postgres etc. without the defense is what staff bar punishes — and what senior-bar gets away with.

### 4. Engage technically, then note product input

When the interviewer asks a depth-probing question that touches policy or UX, never deflect:

- ❌ *"That's a product design question."*
- ✅ *"Technically, two real options. (A) … — simple, scales, loses [X]. (B) … — stronger correctness, more code. For this workload I'd pick A because [reason]. The product input I'd want is [Y], but the engineering work is the same either way."*

Product framing is the **finishing move**, not the **escape route**. The bar wants to see you carry the technical framework first, then notice where product context refines it.

### 5. Volunteer the deep dive

Don't wait to be asked. End your high-level pass with:

> *"Want me to go deeper on the push fanout, the merge engine, or the write path?"*

This signals you can see your own design's load-bearing parts. The interviewer is grading whether you know where the hard pieces are — handing them three correctly-identified deep-dive options is half the grade.

---

## The meta-structure

### Phase discipline

45-minute interviews have phases: requirements → high-level → deep dive → tradeoffs → close. If you're 12 minutes in and still on data model, you've already lost. Watch your clock and push yourself forward — interviewers rarely correct your pacing.

### Information density

Staff candidates pack roughly 5 substantive ideas per minute of speaking. Not by talking fast — by skipping the obvious.

- *"We need a database"* → don't say.
- *"Postgres with row-level security, sharded by user_id via Citus, audit table append-only with monthly Parquet exports"* → say.

Every sentence should carry a tradeoff or a named choice.

### Depth, not width, under pressure

When the interviewer pushes on a component, go *deeper* on the same thing, never sideways. Race conditions on a field? → schema, version column, optimistic-concurrency UPDATE, 409 semantics, client state machine, idempotency keys. Don't pivot to *"well, also for the other side…"* — that's how you lose the thread and never reach depth on anything.

---

## The single move that decides most rounds

When the interviewer asks a depth-probing question, **never deflect to product**.

Replace any version of *"that's a product design question"* with:

> *"Technically, two real options — [name them]. I'd pick [one] because [reason with a number if possible]. The product input I'd want is [Y], but the engineering shape is the same either way."*

Practice that exact pattern until it's reflexive. It's the difference between *"I don't have a technical framework here"* and *"I have a framework AND I know when product context refines it."*
