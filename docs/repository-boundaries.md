# Demo repository boundaries

Status date: 2026-08-07. The adjacent
[`demo-memory`](https://github.com/sw-ml-study/demo-memory) repository is the
canonical home for memory-behavior experiments. This repository remains the
canonical general-purpose data-structure and algorithm collection.

## Ownership rule

`demo-algorithms` teaches what a data structure or algorithm does: its API,
representation, invariants, correctness boundaries, and a small application.
`demo-memory` measures how memory-oriented alternatives behave on identical
workloads: probes, displacement distributions, eviction patterns, false
positives, elapsed time, packed layout, cache behavior, and advanced hashing.

| Keep in `demo-algorithms` | Keep only in `demo-memory` |
|---|---|
| pedagogical numeric mixer | linear-versus-Robin-Hood comparisons |
| basic linear-probing map CRUD | probe workload matrices and distributions |
| tombstone deletion semantics | Robin Hood/backshift variants and their probe effects |
| resize and live-entry rehash mechanics | Bloom and counting Bloom filters |
| separate-chaining map | memory-oriented FIFO/LRU comparisons |
| one application-oriented LRU composition demo | timing, throughput, packed bytes, cache/SIMD behavior |
| logical/copy-complexity notes for general algorithms | funnel, elastic, rainbow, zombie, and adaptive hashing experiments |

Some concepts can appear in both repositories only when the observable lesson
is different. The LRU mini-app here demonstrates composition of a numeric map
and a doubly linked recency policy; `demo-memory` owns identical-workload FIFO
versus LRU measurements. That is complementary rather than duplicate.

## Removed overlap

The former `robin_hood_sensor_registry.mlpl` demo, shared source, and native
test were removed after `demo-memory` became the newer, broader owner. They
duplicated its linear-versus-Robin-Hood implementation, maximum-displacement
comparison, and early-termination evidence. Backward-shift deletion also
belongs there because its purpose is to compare cluster and probe behavior
without tombstones.

The retained hashing demos in this repository form a basic taxonomy rather
than a benchmark suite. Readers seeking advanced hashing should start with
`demo-memory`'s `demos/hash/probe_tradeoffs.mlpl`, benchmark schemas, probe
distributions, and `docs/upstream-contract.md`. That upstream contract—not
this repository—is authoritative for sw-MLPL features earned by advanced
memory experiments.
