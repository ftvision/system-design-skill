# primitives — numbers, math templates, and named patterns

A cheat sheet of the numbers staff-level candidates have memorized, with citations. Use it during prep; cite specific sections during a `mock` debrief when a candidate hand-waves where they should have done arithmetic.

Every quantitative claim links to a source. If you're using a number in an interview, the rule is: **state the number, state the assumption it sits on, state the source if asked.** "About a millisecond for a same-DC round trip" is staff-level. "Fast" is not.

---

## §1 — Latency reference (the Jeff Dean canon)

The original numbers come from a 2009 LADIS keynote by Jeff Dean (originally circulated by Peter Norvig). Hardware has improved since; trust the *order of magnitude*, not the digit. Use [Colin Scott's interactive visualization](https://colin-scott.github.io/personal_website/research/interactive_latency.html) when you need a year-adjusted number — he models exponential improvement per operation.

Canonical 2012 table, [verbatim from the jboner gist](https://gist.github.com/jboner/2841832):

| Operation | Time | Notes |
|---|---|---|
| L1 cache reference | 0.5 ns | |
| Branch mispredict | 5 ns | |
| L2 cache reference | 7 ns | 14× L1 |
| Mutex lock/unlock | 25 ns | |
| Main memory reference | 100 ns | 200× L1 |
| Compress 1 KB with Zippy/Snappy | 3,000 ns (3 µs) | |
| Send 1 KB over 1 Gbps network | 10,000 ns (10 µs) | |
| Read 4 KB randomly from SSD | 150,000 ns (150 µs) | ~1 GB/s sequential |
| Read 1 MB sequentially from memory | 250,000 ns (250 µs) | |
| Round trip within same datacenter | 500,000 ns (500 µs) | **memorize this** |
| Read 1 MB sequentially from SSD | 1,000,000 ns (1 ms) | 4× memory bandwidth penalty |
| HDD seek | 10,000,000 ns (10 ms) | |
| Read 1 MB sequentially from HDD | 20,000,000 ns (20 ms) | |
| Send packet CA → Netherlands → CA | 150,000,000 ns (150 ms) | inter-continental RTT |

**Heuristics that fall out of this table:**
- Memory is ~100× faster than SSD for random access; ~4× faster for sequential.
- A datacenter RTT (~500 µs) costs as much as 5× the time to read 1 MB sequentially from RAM. Network is the dominant cost in distributed systems.
- A cross-continental RTT (~150 ms) is **300× the same-DC RTT**. This is why "just call the EU region" is rarely "just."
- Disk seek (10 ms) is 20× a same-DC RTT. Avoid random disk I/O on the hot path; prefer sequential or skip disk entirely.

---

## §2 — Capacity numbers (single-node ceilings)

These are **rules of thumb**, not guarantees. Hardware, workload shape, and tuning move them by 5–10×. Cite the source if asked; defend the order of magnitude.

### PostgreSQL (single primary)

- **TPC-B / pgbench, tuned commodity hardware**: ~5–10k TPS on default config; **45k TPS** on 6-core NVMe workstation after checkpoint tuning ([source](https://dev.to/haikasatryan/postgresql-write-performance-what-the-benchmarks-wont-tell-you-mm7)).
- **TPC-C record**: 137k write TPS on serious hardware ([Vonng/pgtpc](https://github.com/Vonng/pgtpc)).
- **Practical staff-interview number**: assume **10–50k writes/s on a single primary** before you need sharding. Reads scale further with replicas. See [pgbench docs](https://www.postgresql.org/docs/current/pgbench.html) for the canonical benchmark methodology.

### Redis (single instance)

- **Baseline**: >100k ops/s ([Redis docs: How fast is Redis?](https://redis.io/docs/latest/operate/oss_and_stack/management/optimization/benchmarks/)).
- **With pipelining (16 commands)**: **1.5M SET/s, 1.8M GET/s** on a MacBook Air ([same source](https://redis.io/docs/latest/operate/oss_and_stack/management/optimization/benchmarks/)).
- **Practical**: assume **~100k ops/s without pipelining, ~1M ops/s with pipelining**, per instance. Redis is single-threaded for command execution — CPU-bound on one core.

### Apache Kafka

- **Cluster peak**: **605 MB/s** on a 3-broker cluster of `i3en.2xlarge` (8 vCPU, 64 GB RAM, NVMe, 25 Gbps), 100 partitions, replication factor 3 ([Confluent: Kafka Performance](https://developer.confluent.io/learn/kafka-performance/)).
- **p99 latency**: **5 ms at 200 MB/s sustained load** (200k 1-KB messages/sec) ([same source](https://developer.confluent.io/learn/kafka-performance/)).
- **Per-partition throughput**: ~10s of MB/s, depends heavily on batching/compression/acks ([Confluent partition guidance](https://www.confluent.io/blog/how-choose-number-topics-partitions-kafka-cluster/)).
- **Partition ceilings**: Confluent recommends ≤**4,000 partitions per broker** and ≤**200,000 per cluster** ([Apache Kafka Supports 200K Partitions Per Cluster](https://www.confluent.io/blog/apache-kafka-supports-200k-partitions-per-cluster/)).

### WebSocket connections per node

- **Phoenix on 128 GB / 40-core OnMetal**: **2,000,000 concurrent connections**, ulimit-bound (40% RAM remaining) ([Phoenix blog](https://www.phoenixframework.org/blog/the-road-to-2-million-websocket-connections)). This is the upper-bound demo.
- **Typical production single node** (commodity c-class instance, well-tuned): **200–500k connections** with sub-50 ms broadcast latency.
- **Practical staff-interview number**: assume **~250k–750k connections per node** for sizing; cite Phoenix's 2M as the demonstrated ceiling under tuning. Per-conn memory is the cost driver — budget tens of KB per idle socket.

### Other rough ceilings (quote with care; less canonical sourcing)
- **Single MySQL/Postgres connection**: ~10k QPS on simple queries with the connection pool warm.
- **HTTP load balancer (nginx, HAProxy on c5.large)**: 50–100k req/s pass-through.
- **Single CPU core, JSON parse**: ~500 MB/s (~50k typical 10-KB requests/sec, before app logic).

---

## §3 — Storage cost & economics (for sizing storage budgets)

[AWS S3 Standard, us-east-1, current pricing](https://aws.amazon.com/s3/pricing/):

| Tier | Price |
|---|---|
| First 50 TB / month | $0.023 / GB-month |
| Next 450 TB / month | $0.022 / GB-month |
| Over 500 TB / month | $0.021 / GB-month |

- **Requests**: PUT/POST/COPY/LIST = $0.005 / 1,000. GET/SELECT = $0.0004 / 1,000.
- **Quick math**: 1 TB stored = ~$23/mo. 1 PB stored = ~$22k/mo (tiered).
- **Egress out**: ~$0.09/GB to internet first 10 TB/month — **often the dominant cost**, dwarfs storage. Inter-region transfer ~$0.02/GB.

**Mental model:** storage is cheap, requests are mid, egress is expensive. Design to keep bytes near compute and avoid cross-region transfer for bulk data.

---

## §4 — Network bandwidth conversions

| Link speed | Bytes/sec |
|---|---|
| 1 Gbps | 125 MB/s |
| 10 Gbps | 1.25 GB/s |
| 25 Gbps (e.g. `i3en.2xlarge`) | ~3.1 GB/s |
| 100 Gbps (top-tier instances) | ~12.5 GB/s |

**Cross-region RTT (AWS, measured)**, [via cloudping.co](https://cloudping.co/):
- us-east-1 ↔ us-west-2: ~65 ms
- us-east-1 ↔ eu-west-1 (Ireland): **~63 ms** ([source](https://github.com/ekalinin/awsping))
- us-east-1 ↔ ap-southeast-1 (Singapore): ~210 ms
- Same-AZ: <1 ms; cross-AZ same region: 1–2 ms.

**Heuristic:** any synchronous cross-region call adds 60–200 ms to your p99. If your SLO is <100 ms p99, your write path cannot cross regions synchronously.

---

## §5 — Back-of-envelope templates

Use these as the **first thing you say** when entering a deep dive. The numbers force the architecture.

### DAU → QPS

```
avg_QPS    = DAU × actions_per_user_per_day / 86,400
peak_QPS   = avg_QPS × peak_factor
```

**Peak factors** ([systemdesign.one BOE guide](https://systemdesign.one/back-of-the-envelope/), and convention):
- **2×** — predictable SaaS (lunch hour spike).
- **5–10×** — bursty consumer (ride-sharing rush, food delivery).
- **100×+** — flash sale, viral event, breaking news.

**Worked example:** 10M DAU × 50 actions/day / 86,400 ≈ **5,800 avg QPS** → **~17k peak QPS** at 3×. (Memorize: 86,400 sec/day. ~10⁵.)

### Storage growth

```
bytes_per_day  = avg_QPS × payload_bytes × 86,400
bytes_per_year = bytes_per_day × 365
```

**Worked example:** 5,800 QPS × 1 KB × 86,400 = **~500 GB/day**, **~180 TB/year**. At S3 Standard tiering: ~$4k/mo year 1, $35k/mo year 5.

### Bandwidth

```
egress_bytes_per_sec = QPS × response_payload_size
ingress_bytes_per_sec = QPS × request_payload_size
```

**Worked example:** 17k peak QPS × 10 KB response = **170 MB/s** = **~1.4 Gbps** — comfortably one ALB worth, but every cache miss matters.

### Connections

```
required_connections = concurrent_users × persistent_sockets_per_user
nodes_needed = required_connections / per_node_capacity
```

For 10M concurrent WS users at 250k/node → **40 gateway nodes**. Add headroom for deploy waves and reconnect storms (see §7).

---

## §6 — Useful constants to memorize

| Constant | Value |
|---|---|
| Seconds per day | 86,400 (~10⁵) |
| Seconds per year | 31.5M (~3 × 10⁷) |
| Bytes in 1 KB / 1 MB / 1 GB / 1 TB | 10³ / 10⁶ / 10⁹ / 10¹² (SI; binary differs by ~7%) |
| 1 Gbps in MB/s | 125 |
| Same-DC RTT | ~0.5 ms |
| Cross-continent RTT | ~150 ms |
| Speed of light, fiber | ~200,000 km/s (2/3 of c) |
| Earth circumference | 40,000 km → light-RTT floor ~133 ms equator-to-equator |

---

## §7 — Named patterns staff candidates reach for

When you say "we'd use a queue here," interviewer hears "junior." When you say "transactional outbox publishing to Kafka, partition key on tenant_id, consumed by a fanout worker with at-least-once delivery and idempotent downstream," interviewer hears "staff."

| Problem | Named pattern | One-line semantics |
|---|---|---|
| Reliable event publishing from a transactional write | **Transactional outbox** | Write event row in same DB txn as state change; relay to message bus async. ([Microservices.io](https://microservices.io/patterns/data/transactional-outbox.html)) |
| Ordering across partitions | **Partition by entity ID** | Choose key = entity whose updates must stay ordered (user_id, tenant_id). |
| Avoiding hot partitions | **Composite key with shard suffix** | `tenant_id:shard` where `shard = hash(secondary) % N`. Trades global ordering for parallelism. |
| Cross-system data sync | **Change Data Capture (CDC)** | Log-tail the source DB (Debezium, AWS DMS); downstream consumes the binlog. |
| Avoiding double-billing on retries | **Idempotency key** | Client supplies UUID; server stores response keyed by it for N hours. |
| Concurrent edits, single-writer-per-field | **Optimistic concurrency with version** | `UPDATE ... WHERE version = ?`; 0 rows → 409, client refetches. |
| Concurrent edits, multi-writer collaborative | **CRDT or OT** | CRDT for state-based merge (no central server); OT for transformation-based (Google Docs). |
| Read-your-writes after async replication | **Read-from-primary-after-write window** | Sticky route to primary for N seconds post-write; or version-token in client. |
| Cache invalidation on write | **Write-through, write-around, write-back** | Pick based on read/write ratio and staleness tolerance. |
| Push to many subscribers cheaply | **Invalidation, not value** | Push "v123 invalid" nudge; client pulls fresh from CDN. (Bandwidth saver.) |
| Bounding queue growth | **Backpressure with bounded buffers + coalescing** | Drop or merge older messages of same key; never silently drop without observability. |
| Avoiding thundering herd on cache miss | **Request coalescing / single-flight** | One miss triggers one origin fetch; concurrent requests wait. |
| Avoiding deploy reconnect storms | **Jittered backoff + max wave fraction** | Cap % of fleet that can reconnect per second; randomize. |
| Detecting silent corruption | **Sample read-back + checksum** | After write, async read-back at t+30s; mismatch fires alert. |
| Cross-tenant isolation in shared infra | **Tenant_id on every row + RLS / per-tenant assertion** | Enforce at DB layer (Postgres RLS) and runtime; sample correctness via async drift check. |

---

## §8 — Reasoning shortcuts (what to say out loud)

These are **moves**, not facts. Use them when stuck.

1. **"Let me size the SLO first."** — Before architecture, restate the numerical target. Read p99 < 200 ms? Force-push <30 s? It pins which choices are off the table.
2. **"What's the read:write ratio?"** — Drives caching strategy and replication topology. >100:1 reads → invest in cache and read replicas. ~1:1 → invest in write path.
3. **"What's the hot key?"** — In any sharded system, find the entity whose traffic is most skewed. Hot tenant, hot user, hot product page. That's your partition design driver.
4. **"What absorbs backpressure?"** — Every async pipeline needs one durable buffer where pressure pools (typically Kafka). Identify it and bound it.
5. **"What's the kill switch?"** — For any control-plane system (config, feature flags, policy), name the lever that disables the system itself, served from a path independent of what it controls.
6. **"What's the failure domain?"** — When a component fails, what's the blast radius? Region? Tenant? Single user? Argue for the smallest blast you can afford.
7. **"How do I observe this?"** — For each SLO, name the SLI (the measurement) and the burn-rate alert (when it pages). Synthetic probers lie; real-traffic SLIs don't.

---

## Sources

- [Jeff Dean / Peter Norvig latency table (jboner gist)](https://gist.github.com/jboner/2841832)
- [Colin Scott's interactive latency-by-year](https://colin-scott.github.io/personal_website/research/interactive_latency.html)
- [PostgreSQL pgbench documentation](https://www.postgresql.org/docs/current/pgbench.html)
- [Vonng/pgtpc TPC benchmarks](https://github.com/Vonng/pgtpc)
- [PostgreSQL write performance benchmarks (commentary)](https://dev.to/haikasatryan/postgresql-write-performance-what-the-benchmarks-wont-tell-you-mm7)
- [Redis benchmark official docs](https://redis.io/docs/latest/operate/oss_and_stack/management/optimization/benchmarks/)
- [Confluent: Kafka performance](https://developer.confluent.io/learn/kafka-performance/)
- [Confluent: How to choose number of partitions](https://www.confluent.io/blog/how-choose-number-topics-partitions-kafka-cluster/)
- [Confluent: 200k partitions per cluster](https://www.confluent.io/blog/apache-kafka-supports-200k-partitions-per-cluster/)
- [Phoenix: 2M WebSocket connections](https://www.phoenixframework.org/blog/the-road-to-2-million-websocket-connections)
- [AWS S3 pricing](https://aws.amazon.com/s3/pricing/)
- [cloudping.co AWS region latency](https://cloudping.co/)
- [systemdesign.one BOE guide](https://systemdesign.one/back-of-the-envelope/)
- [Microservices.io: Transactional Outbox pattern](https://microservices.io/patterns/data/transactional-outbox.html)
