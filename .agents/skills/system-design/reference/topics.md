# topics — vetted catalog for `mock` and `generate`

A curated set of system-design problems, tagged by difficulty and by the dimension(s) they stress. Use as the default suggestion list when a user runs `mock` or `generate` without a topic.

**Tagging key:**
- **Difficulty**: `easy` (warmup, ~30 min), `medium` (canonical 45-min mock), `hard` (staff bar, multiple deep dives), `staff+` (principal-level, requires multi-region or novel substrate).
- **Dimensions**: which of the 5 scoring dimensions the problem most stresses. (Most problems stress all five; the tag picks out where the *teeth* are.)
- **Slug**: stable identifier for `practiced.md` / `weaknesses.md` entries.

---

## Easy — warmup / fundamentals

Single-server fundamentals, simple data flow. Good for first-time practice or warming up before a harder mock.

| Topic | Slug | Stresses | Notes |
|---|---|---|---|
| URL shortener (TinyURL, bit.ly) | `url-shortener` | scoping, structure | Classic. Hash function choice + collision handling + redirect path. |
| Pastebin | `pastebin` | scoping, structure | Like url-shortener with blob storage. Good for cache reasoning. |
| Rate limiter (per-user, per-IP) | `rate-limiter` | tradeoff, deep-dive | Token bucket vs leaky bucket vs sliding window. Distributed coordination. |
| Key-value store (single-node) | `kv-store` | structure, deep-dive | Memory layout, persistence, expiry. Set up for a follow-up "now make it distributed." |
| Web crawler (basic, single-machine) | `web-crawler-basic` | structure, scoping | Frontier, dedup, politeness. |
| Notification service (email/push fanout) | `notification-service` | structure, tradeoff | Queue + worker, retry, dedup. Good for outbox-pattern reps. |
| Health check / heartbeat system | `heartbeat` | scoping, tradeoff | Push vs pull, failure detection latency vs false positives. |

---

## Medium — canonical 45-min mocks

The standard interview repertoire. Most FAANG-tier loops draw from this set.

| Topic | Slug | Stresses | Notes |
|---|---|---|---|
| News feed / Twitter timeline | `news-feed` | structure, deep-dive, tradeoff | Fanout-on-write vs fanout-on-read; celebrity problem. |
| Instagram (photos + feed) | `instagram` | structure, deep-dive | Adds blob storage + CDN to the timeline problem. |
| WhatsApp / chat messaging | `chat-messaging` | deep-dive, tradeoff | Delivery semantics, online/offline, group chats. |
| Distributed cache (Memcached / Redis-cluster-style) | `distributed-cache` | deep-dive, tradeoff | Consistent hashing, replication, eviction. |
| Distributed task queue (Sidekiq / Celery scale) | `task-queue` | structure, deep-dive | At-least-once vs exactly-once, idempotency, DLQ. |
| Search autocomplete / typeahead | `autocomplete` | deep-dive, communication | Trie sharding, freshness, personalization layer. |
| File storage / sync (Dropbox subset) | `file-sync` | structure, deep-dive | Chunking, dedup, delta sync, conflict resolution. |
| Ride-sharing dispatch (Uber/Lyft) | `ride-sharing` | structure, tradeoff | Geo-indexing (S2/H3), supply-demand match, pricing. |
| Event ticketing with inventory (Ticketmaster) | `ticketing` | deep-dive, tradeoff | Hold-and-confirm, oversell prevention, fairness under stampede. |
| Distributed ID generation (Snowflake-like) | `distributed-id` | tradeoff, scoping | Time vs random vs hybrid; clock skew. |
| Web crawler (distributed, polite) | `web-crawler-distributed` | structure, deep-dive | URL frontier, sharding, robots.txt, freshness scheduling. |
| Logging / metrics ingestion pipeline | `metrics-ingest` | structure, deep-dive | Aggregation tiers, sampling, retention. |
| Multi-device sync (calendar, notes) | `multi-device-sync` | deep-dive, tradeoff | Per-field versioning, LWW vs CRDT, offline. |

---

## Hard — staff bar

Require multiple deep dives, real numbers, and explicit failure-mode reasoning. Expect 60+ minutes if done well.

| Topic | Slug | Stresses | Notes |
|---|---|---|---|
| Google search (crawl + index + rank + serve) | `google-search` | structure, deep-dive, scoping | Three sub-systems; pick one for the deep dive. |
| YouTube / Netflix (upload + transcode + CDN + recs) | `video-streaming` | structure, deep-dive | Transcoding pipeline, CDN tiering, ABR streaming. |
| Google Docs (collaborative editing) | `google-docs` | deep-dive, tradeoff | OT vs CRDT, presence, offline reconciliation. |
| Distributed log (Kafka-clone) | `distributed-log` | deep-dive, tradeoff | Replication, ISR, exactly-once semantics, controller. |
| Distributed database (Spanner-like) | `distributed-db` | deep-dive, tradeoff | TrueTime, Paxos groups, external consistency. |
| Real-time bidding / ad serving | `ad-serving` | deep-dive, tradeoff | <100 ms p99 budget, fraud, budget pacing, k-of-n auction. |
| Stock exchange / order matching | `order-matching` | deep-dive, tradeoff | Determinism, low-latency matching engine, market data fanout. |
| Payment system (Stripe-like) | `payments` | deep-dive, tradeoff | Idempotency, double-entry ledger, settlement, retries across providers. |
| Slack / large-scale messaging | `slack` | structure, deep-dive | Channel fanout, search, presence, mobile push. |
| Geo-distributed CDN | `cdn` | structure, tradeoff, scoping | Edge POPs, cache hierarchy, invalidation, origin shielding. |
| Distributed file system (HDFS-like) | `dfs` | deep-dive, tradeoff | Block placement, replication, NameNode HA. |
| Real-time analytics (Mixpanel/Amplitude) | `realtime-analytics` | structure, deep-dive | Ingest → aggregate → query; pre-aggregation tradeoffs. |

---

## Staff+ / Principal — multi-region, novel substrate

Multi-region active-active, regulatory complexity, or invented primitives.

| Topic | Slug | Stresses | Notes |
|---|---|---|---|
| Multi-region active-active database | `multi-region-db` | tradeoff, deep-dive | Conflict resolution, CRDT vs Spanner-style, residency. |
| Global feature flag system (sub-100ms global propagation) | `global-feature-flags` | deep-dive, tradeoff | Push vs pull, kill-switch independence, blast radius. |
| Cross-tenant SaaS isolation (Snowflake-like) | `multi-tenant-saas` | deep-dive, tradeoff | Compute isolation, noisy-neighbor, billing, per-tenant SLOs. |
| Federated identity / SSO at scale (Okta-like) | `sso` | deep-dive, tradeoff | OIDC/SAML, session management, breach blast radius. |
| Edge-compute platform (Cloudflare Workers / Lambda@Edge) | `edge-compute` | structure, deep-dive | Cold start, isolation, deploy propagation, observability. |

---

## Modern (LLM-era / 2024–2026)

Newer topics that show up in current loops, especially at AI-native companies. Less canonical reference material; candidates who have *actually built* in this space have a real edge.

| Topic | Slug | Stresses | Notes |
|---|---|---|---|
| LLM serving infrastructure (vLLM-style) | `llm-serving` | deep-dive, tradeoff | Continuous batching, KV cache management, paged attention, GPU utilization. |
| Vector database / semantic search | `vector-db` | structure, deep-dive | HNSW vs IVF, recall vs latency, hybrid search. |
| RAG pipeline (chunking + embed + retrieve + rerank) | `rag-pipeline` | structure, tradeoff | Chunking strategy, embedding refresh, evaluation. |
| AI agent orchestration (long-running, tool-using) | `agent-orchestration` | structure, deep-dive | Durable execution, tool dispatch, observability, cost control. |
| Code completion service (Copilot-like, low-latency) | `code-completion` | deep-dive, tradeoff | <200 ms p99, context window management, accept-rate as SLI. |
| Multi-tenant LLM gateway (rate-limit, route, cache) | `llm-gateway` | structure, tradeoff | Per-tenant quotas, model routing, prompt cache, fallback. |
| Multi-device config sync with team policy | `team-policy-sync` | scoping, deep-dive | Force vs default modes, multi-team precedence, sub-30s force-push fanout. |
| Prompt cache / response cache for LLMs | `llm-cache` | tradeoff, deep-dive | Semantic vs exact, TTL, invalidation on model swap. |
| Evaluation infrastructure for LLM apps | `llm-eval` | structure, scoping | Offline vs online, golden set drift, statistical power. |
| Real-time voice agent (Whisper + LLM + TTS) | `voice-agent` | deep-dive, tradeoff | Streaming pipeline, interruption handling, sub-second turn-taking. |

---

## Domain-deep (specialized)

Less universal, but realistic if the company's product is in this space. Worth practicing if interviewing somewhere in the domain.

| Topic | Slug | Stresses | Notes |
|---|---|---|---|
| Reddit / HN ranking + voting | `reddit` | structure, tradeoff | Score decay, vote fraud, comment trees. |
| Tinder / dating match | `tinder` | structure, deep-dive | Geo-indexing, deck generation, match notification. |
| Zoom / WebRTC video conferencing | `webrtc` | deep-dive, tradeoff | SFU vs MCU, NAT traversal, simulcast. |
| Spotify / music streaming + recs | `spotify` | structure, deep-dive | CDN for audio, recs ML loop, social graph. |
| GitHub (git hosting + UI + CI integration) | `github` | structure, deep-dive | Git protocol, large-repo perf, hooks, webhooks. |
| DNS at scale (Route53-like) | `dns` | structure, tradeoff | Anycast, zone propagation, DDoS resilience. |
| API gateway (Kong/Envoy-like) | `api-gateway` | structure, deep-dive | Routing, auth, rate limiting, observability. |
| Distributed cron / job scheduler | `distributed-cron` | deep-dive, tradeoff | Exactly-once trigger, leader election, missed-run policy. |
| DoorDash / food delivery dispatch | `food-delivery` | structure, tradeoff | Three-sided market, batching, ETA prediction. |
| Live-streaming (Twitch-like) | `live-streaming` | deep-dive, tradeoff | HLS/DASH, low-latency vs scalability, chat integration. |

---

## Selection guidance

When the user asks for a problem and hasn't specified one:

1. **First mock ever** → suggest from `easy`. Build the rhythm before the depth.
2. **Practicing for a specific company** → mix domain-deep matches with one canonical medium for breadth.
3. **Targeting staff/principal** → at least half from `hard` or `staff+`. Never default to easy at this level.
4. **AI-native company** → bias toward `modern` plus one classic to test fundamentals.
5. **Want to find your weak spot** → cross-reference `weaknesses.md`. If `tradeoff` is the recurring gap, suggest a topic where the deep-dive forces a binary choice (e.g., `google-docs` for OT-vs-CRDT, `payments` for ledger-vs-event-sourcing).

When the user asks `generate` without a topic: pick from `modern` first (less reference material exists, so a generated rubric is more useful), then `staff+` (fewer canonical worked examples to crib from).
