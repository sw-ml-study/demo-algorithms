# Demo repository boundaries

Status date: 2026-08-16. The adjacent
[`demo-memory`](https://github.com/sw-ml-study/demo-memory) repository is the
canonical home for memory-behavior experiments. The existing sibling
`demo-data-structures` repository is the migration target for reusable
container abstractions. This repository is becoming the canonical home for
algorithm-centered lessons.

## Algorithms/data-structures split contract

[`catalog/repository-ownership.tsv`](../catalog/repository-ownership.tsv) is
the executable migration manifest. Every tracked demo, production source,
test, catalog/tooling file, and project document must match exactly one rule.
`just audit` checks that coverage; `just boundary-final` additionally rejects
duplicate authoritative catalog rows across the two repositories.

The decision rule is the observable lesson:

| `demo-algorithms` | `demo-data-structures` |
|---|---|
| searching, sorting, and sequence transformations | vectors, stacks, queues, and deques |
| graph representations that support graph algorithms | linked, persistent, and indexed lists |
| dynamic programming, greedy, backtracking, and numeric algorithms | sets, maps, foundational hashing, and LRU composition |
| serialization, validation, and persistence procedures | heaps and priority queues |
| matrix and sparse-matrix operations | trees, tries, and indexed-tree structures |

Ambiguous cases are intentional. Heap sort stays here with a standalone
implementation while the priority-queue lesson moves. Graph representations
and union-find stay with the graph curriculum. COO/CSR conversion and sparse
matrix arithmetic stay with matrix algorithms. Foundational integer mixing and
hash-table mechanics move, while advanced probe/memory experiments remain in
`demo-memory`. Serialization remains algorithm-owned. The LRU lesson moves
because it teaches composition of map and linked-recency structures.

All `patterns/` material and its reports remain in `demo-algorithms` unchanged
during the data-structure batches. Design-pattern extraction is now separately
authorized and queued. Until that step lands, the uncataloged
`src/trees/shipping_cost_expression.mlpl` remains here solely because existing
Composite/Interpreter and Visitor consumers include it; authoritative tree
demo/test ownership is already in `demo-data-structures`.

## Ownership rule

`demo-data-structures` teaches what a data structure does: its API,
representation, invariants, correctness boundaries, and a small application.
`demo-memory` measures how memory-oriented alternatives behave on identical
workloads: probes, displacement distributions, eviction patterns, false
positives, elapsed time, packed layout, cache behavior, and advanced hashing.

| Keep in `demo-data-structures` | Keep only in `demo-memory` |
|---|---|
| pedagogical numeric mixer | linear-versus-Robin-Hood comparisons |
| basic linear-probing map CRUD | probe workload matrices and distributions |
| tombstone deletion semantics | Robin Hood/backshift variants and their probe effects |
| resize and live-entry rehash mechanics | Bloom and counting Bloom filters |
| separate-chaining map | memory-oriented FIFO/LRU comparisons |
| one application-oriented LRU composition demo | timing, throughput, packed bytes, cache/SIMD behavior |
| logical/copy-complexity notes for general algorithms | funnel, elastic, rainbow, zombie, and adaptive hashing experiments |

Some concepts can appear in both repositories only when the observable lesson
is different. The LRU mini-app in `demo-data-structures` demonstrates composition of a numeric map
and a doubly linked recency policy; `demo-memory` owns identical-workload FIFO
versus LRU measurements. That is complementary rather than duplicate.

## Removed overlap

The former `robin_hood_sensor_registry.mlpl` demo, shared source, and native
test were removed after `demo-memory` became the newer, broader owner. They
duplicated its linear-versus-Robin-Hood implementation, maximum-displacement
comparison, and early-termination evidence. Backward-shift deletion also
belongs there because its purpose is to compare cluster and probe behavior
without tombstones.

The retained hashing demos in `demo-data-structures` form a basic taxonomy rather
than a benchmark suite. Readers seeking advanced hashing should start with
`demo-memory`'s `demos/hash/probe_tradeoffs.mlpl`, benchmark schemas, probe
distributions, and `docs/upstream-contract.md`. That upstream contract—not
this repository—is authoritative for sw-MLPL features earned by advanced
memory experiments.
