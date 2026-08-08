# Demo Delivery Plan

## Deliverable contract

Every test is a `test_*.mlpl` script that:

- runs in an isolated interpreter process through `mlplunit`;
- uses mlplunit's shared assertion prelude rather than local assertion copies;
- uses deterministic inputs;
- checks normal, boundary, and invalid cases;
- returns `ok(...)` on success and `err(...)` on invariant failure.

Every demo is a small application that:

- describes a concrete problem in its opening comments;
- explains why its data structure and algorithm solve that problem;
- shows or returns a meaningful result rather than a pass/fail assertion wall;
- has detailed correctness assertions in a corresponding `tests/` script;
- remains directly executable while including reusable production definitions
  from `src/` where that demo/test pair has migrated.

Both demos and tests:

- run against the selected `mlpl-repl` binary;
- give every `u:` function a meaningful leading doc string so REPL `:fns`,
  `:describe`, and `:list` make standalone scripts explorable;
- document representation and invariants at the top of the file;
- records logical complexity and current copy complexity separately;
- records `explicit_loops`, `target_loops`, and the feature that removes each
  remaining loop;
- retains old values in at least one test when the API claims persistence;
- uses strings only for static messages until string sequence support lands.

Each algorithm may have two formulations where necessary:

1. **Current baseline:** executable on the pinned sw-MLPL binary.
2. **Target formulation:** the preferred pure/compositional form, initially
   documentation or a gated fixture until its required feature lands.

## Proposed repository layout

```text
demos/
  vectors/
  stacks/
  queues/
  linked_lists/
  hash_tables/
  trees/
  graphs/
tests/
  vectors/
  stacks/
  queues/
  linked_lists/
  hash_tables/
  trees/
  graphs/
catalog/
  demos.tsv
  tests.tsv
scripts/
  run-all
  run-tests
  validate-catalog
```

The catalog should contain:

```text
id, category, status, dynamic_size, representation,
explicit_loops, target_loops, required_features,
patterns_exercised, expected_exit
```

## Track 0 — harness and conventions

Build before content:

- catalog-driven execution through `$MLPL`, with tests delegated to mlplunit;
- exit-code and final-Result checking;
- shared `assert_true`, `assert_eq`, and `assert_err` assertions from mlplunit;
- catalog validation;
- report of runnable/gated demos and total explicit loops;
- CI against a pinned known-good sw-MLPL binary and optionally latest main.

Acceptance: a passing fixture and intentional failing fixture prove the runner
detects both outcomes.

Status: framework capability and corpus migration complete.
`scripts/run-tests` resolves `$MLPLUNIT`, then `PATH`, then an adjacent
development checkout and delegates one catalog-selected suite under
`mlplunit.conf`. Config discovery, native include, named/tagged `@test`
reflection, `@cases`, bracket lifecycle, human/TAP reporting, failure
continuation, and deterministic exit status all work now. All 63 registered
tests and all 69 demos share production definitions under `src/`. See
[mlplunit-adoption.md](mlplunit-adoption.md) and
[mlplunit-migration.md](mlplunit-migration.md).
The current native event transport reports 104 individual tests/cases from the
63 files in human and TAP modes. A nonblocking refinement backlog remains:
split the 40 broad `u:test_contract` callables into behavior-focused `@test`s
and convert naturally tabular scalar policies to `@cases`; do not manufacture
fixtures for immutable algorithms without setup/teardown ownership.

## Track 1 — demos buildable today

### Milestone T1: dynamic sequence foundations

| Script | Main idea | Expected current loops |
|---|---|---:|
| `foundations/array_memory.mlpl` | pure read/write/swap and invariant helpers | 0–1 |
| `linear/growable_vector.mlpl` | append/remove and logical size | 1 |
| `linear/chunked_vector.mlpl` | logical size versus capacity | 1–2 |
| `linear/stack.mlpl` | storage delegation through named functions | 0 |
| `linear/ring_queue.mlpl` | wraparound and pure state transition | 1 |
| `linear/deque.mlpl` | operations at both ends | 1 |
| `linear/indexed_singly_linked_list.mlpl` | application arena and numeric handles | 2–3 |
| `linear/indexed_doubly_linked_list.mlpl` | bidirectional invariants | 3–4 |
| `linear/persistent_cons_list.mlpl` | recursive immutable records | recursion, ideally 0 loops |

Acceptance: every collection grows beyond its initial example size, shrinks,
handles empty operations through Result, and validates its representation after
each operation.

The indexed doubly linked-list deliverable explicitly covers insertion and
deletion at head/middle/tail, forward and reverse traversal, retained immutable
versions, reciprocal `next`/`previous` invariants, stable append-only handles,
stale-handle errors, and strict cycle rejection. It is now executable as the
editable delivery-route mini-app with zero explicit loops; recursive validation
and traversal remain candidates for future UDF folds.

Current evidence: `demos/persistent_lists/alert_feed.mlpl` and
`demos/persistent_lists/expiring_alert_feed.mlpl`, with their conformance
tests, implement prepend, pop/drop, value removal, stable cutoff filtering,
and recursive traversal with zero explicit loops. Old feed values remain
semantically unchanged. Efficient O(1) shared tails remain a runtime
structural-sharing feature; the current evaluator may clone nested records.

Foundation closeout evidence and aggregate loop counts are published in
[dynamic-sequence-report.md](dynamic-sequence-report.md).

### Milestone T2: search, ordering, and priority

| Script | Main idea |
|---|---|
| `algorithms/search/linear_search.mlpl` | baseline sequential search |
| `algorithms/search/binary_search.mlpl` | bounded divide and conquer |
| `algorithms/search/lower_bound.mlpl` | insertion position and duplicates |
| `algorithms/sequence/reverse.mlpl` | whole-array target versus swap baseline |
| `algorithms/sort/insertion_sort.mlpl` | stable incremental ordering |
| `algorithms/sort/merge_sort.mlpl` | recursive phases with index bounds |
| `trees/binary_heap.mlpl` | dense heap representation |
| `trees/priority_queue.mlpl` | heap delegated behind an ADT |
| `algorithms/sort/heap_sort.mlpl` | reuse of heap mechanism |

Use `grade_up` plus row gathering as the correctness oracle, not the
implementation.

Current evidence: the three search demos implement linear search, binary
search, and lower bound recursively with zero explicit loops. Their tests cover
empty and singleton inputs, absent values, boundaries, duplicates, and
negative values. The return-route mini-app adds recursive numeric reversal with
zero explicit loops; its current repeated concatenation may copy O(n^2) total
storage even though it visits each element once logically.
The stable-task-order mini-app implements insertion sort over parallel key and
payload vectors, inserting after equal keys so arrival order is retained. It
uses zero explicit loops and exposes O(n^2) comparison and immutable-copy cost.
The stable-delivery mini-app implements recursive merge sort with mask-based
halves and index-bound merging. It chooses the left payload on equal keys,
proving stability with zero explicit loops; slices/views and builder storage
would reduce current immutable allocation and copying.
The incident-dispatch mini-app delegates priority-queue behavior to a dense
binary min-heap with recursive sift-up/sift-down and zero explicit loops. It
proves dynamic growth/shrinkage and immutable retained versions; current pure
array updates copy storage despite logical O(log n) heap operations.
The batch-duration mini-app delegates heap sort to the same shared min-heap
contract with zero explicit loops. Its sift/insert/remove helpers live under
the tested `src/` heap boundary used by both demo and test.

Saga closeout coverage, aggregate loop counts, complexities, and module
evidence are published in
[search-sort-priority-report.md](search-sort-priority-report.md).

### Milestone T3: associative structures

| Script | Main idea |
|---|---|
| `associative/bit_set.mlpl` | bounded-universe set as mask |
| `associative/direct_address_map.mlpl` | time/space tradeoff |
| `associative/numeric_hash_map.mlpl` | open addressing and numeric mixing |
| `associative/hash_map_resize.mlpl` | dynamic capacity and rehash |
| `associative/chained_hash_map.mlpl` | bucket heads plus indexed nodes |
| `associative/numeric_lru.mlpl` | map plus doubly linked ordering |

Acceptance: collisions, duplicate insert, missing lookup/delete, tombstones,
load threshold, resize, and retained-old-version behavior.

Current bounded-universe evidence: the feature-flag bit set and warehouse
direct-address map implement membership, idempotent updates, stored-zero-aware
lookup, removal, invariants, and retained immutable versions with zero explicit
loops. Both trade O(universe) storage and current update copying for O(1)
logical operations; hashing is needed when the key universe is sparse or not
known in advance.
The device-worker mini-app adds a deterministic, platform-independent numeric
mixer with signed-key normalization, explicit integer/precision bounds, golden
fixtures, bucket-range checks, and collision evidence. It is intentionally
pedagogical rather than cryptographic and supplies the stable hash contract for
the upcoming open-address table.
The sparse-meter mini-app implements a fixed-capacity open-address map with
recursive linear probing, collision chains, wraparound, duplicate-key update,
stored zero, negative keys, bounded full-table termination, and retained
versions. It uses zero explicit loops. Tombstones and load-factor-driven resize
remain deliberately separate acceptance steps.
The meter-tombstone mini-app adds deletion that preserves collision chains and
reuses the first tombstone on later insertion, still with zero explicit loops.
The growing-meter mini-app adds a 75% load threshold, 2n+1 capacity growth,
recursive live-entry rehash, tombstone cleanup, repeated growth, and retained
old versions. Logical operations are expected amortized O(1), while the current
pure implementation performs substantial full-array copying during updates and
rehash. Recursive rehash works with zero explicit loops. Implementation
exposed a current binding hazard: seemingly ordinary local names (confirmed
with `table`, and encountered among short workflow-state names) can resolve to
string-valued symbols in nested/recursive code and fail later with `expected an
array value, got a string`. The scripts use unambiguous names as a workaround. Lexical local
bindings, reserved-name diagnostics, or namespace-aware shadowing remain a
high-value sw-MLPL improvement; a UDF-capable fold would also simplify rehash.
The chained-sensor registry provides the separate-chaining alternative using
bucket-head handles and parallel immutable node arrays. It supports collision
chains, duplicate updates, head/interior deletion, negative keys, stored zero,
retained versions, and recursive load-driven rehash with zero explicit loops.
Logical operations are expected O(1) at controlled load, but every append,
scatter, and rehash currently copies array storage. Deleted nodes remain in an
old immutable arena until rehash compacts live entries; application-visible
numeric handles therefore must be validated and must not be reused across map
versions.
The recent-route cache closes the current numeric-associative baseline by
composing recursive numeric-key lookup with an index-backed doubly linked
recency list. It demonstrates hit/update promotion, head/tail/middle rewiring,
least-recent eviction, capacity-one behavior, stored zero, negative keys,
forward/reverse traversal, retained versions, and bounded cycle/handle
validation with zero explicit loops. Lookup is currently O(n); importing the
separate-chaining map after modules arrive would restore expected O(1) lookup
without coupling recency policy to hashing. Immutable versions append arena
nodes after eviction, so retired storage is reclaimed only with an explicit
application-level compaction/rebuild; stale numeric handles must not cross
versions.

Advanced hashing and memory-behavior experiments are intentionally delegated
to the adjacent `demo-memory` repository. See
[repository-boundaries.md](repository-boundaries.md) for the ownership rule.
This plan stops after foundational mixer, linear probing, tombstones,
resize/rehash, separate chaining, and application-oriented LRU correctness.
`demo-memory` exclusively owns Robin Hood/backshift work, identical-workload
probe comparisons, distributions, Bloom filters, timing, packed metadata,
cache/SIMD behavior, and funnel/elastic/rainbow/zombie/adaptive hashing.

The retained [modern hashing assessment](modern-hashing-assessment.md) is
background and a routing aid, not an implementation queue. `demo-memory`'s
`docs/upstream-contract.md` is authoritative for the evolving sw-MLPL feature
requirements behind those advanced experiments.

### Milestone T4: trees and persistence baselines

Current evidence begins with `team_hierarchy_traversals.mlpl`, which represents
the same numeric binary tree as nested immutable records and as parallel indexed
arena arrays. Recursive preorder, inorder, and postorder agree across both
forms with zero explicit loops. Tests cover empty, singleton, balanced and
skewed shapes, duplicate and negative payloads, retained record versions,
conversion parity, invalid handles, cycles, and shared children. The indexed
validator carries a per-traversal visited vector: cycles are permitted as raw
application data but rejected by the strict-tree contract before traversal.
Application code owns numeric-handle validity and recursion-depth safety.
Nested records express ownership naturally today, but without runtime
structural sharing they may copy subtrees; indexed appends also copy arrays.
Static include now places traversal contracts and validators in one `src/`
file used by demos and tests. Full modules later add namespace and visibility
boundaries.
`persistent_reservation_index.mlpl` adds a nested-record BST map whose duplicate
policy replaces the value at an existing numeric key. Recursive insert rebuilds
the logical root-to-leaf path, while search and invariant auditing require zero
explicit loops. Tests cover empty, singleton, balanced, skewed, negative-key,
stored-zero, replacement, missing lookup, ordering violation, and retained-root
behavior. In a structurally sharing runtime, insert allocates O(height) new
nodes and directly shares untouched subtrees, matching Clojure-style persistent
semantics. sw-MLPL currently preserves value semantics but may clone nested
record payloads, so the demo cannot yet claim physical O(height) allocation or
verify reference identity. Runtime immutable references/GC and structural
sharing—not application-visible malloc/free—are the enabling implementation
changes.
`persistent_reservation_cancellation.mlpl` extends the same BST map with
immutable deletion for leaves, one-child promotion, and two-child inorder-
successor replacement. Missing deletion returns `Err`; negative keys, stored
zero, root deletion, successor-path rebuilding, repeated deletion to empty,
ordering/size invariants, and retained prior roots are covered with zero
explicit loops. Logical work and new structure remain O(height). True
O(height) physical allocation still depends on shared immutable subtree
references and tracing GC; manual `malloc`/`free` is neither required nor
desirable for the language-level API.
`balanced_dispatch_index.mlpl` adds cached-height persistent AVL insertion and
all four LL/RR/LR/RL rotation paths. Sequential keys 1 through 15 produce a
validated height-four tree, providing deterministic logarithmic-height
evidence; tests also cover ordering, search, negative keys, stored zero,
duplicate replacement, bad cached heights, balance bounds, and retained roots
with zero explicit loops. AVL invariants make logical search and insertion
O(log n), but physical O(log n) persistent allocation still requires runtime
sharing of untouched immutable subtrees plus GC for unreachable versions.
`live_leaderboard_rank.mlpl` augments an immutable AVL set with cached subtree
sizes. Rank returns the sorted insertion position for present or missing keys,
and select returns the zero-based key at a position, both in logical O(log n).
Tests cover every rotation, empty/singleton trees, duplicate-as-set policy,
negative and zero keys, invalid positions, corrupt height/size caches,
ordering/balance, and retained roots. Physical O(log n) persistence remains
dependent on runtime structural sharing rather than application allocation.
`appointment_conflicts.mlpl` adds an immutable AVL interval tree for numeric
half-open intervals. Cached maximum endpoints prune subtrees during overlap
search; equal starts replace the prior endpoint. Tests cover all rotations,
touching boundaries, nesting, negative/zero endpoints, left/right pruning,
malformed intervals, cache/order/balance corruption, and retained schedules.
Insert is logical O(log n); overlap search is typically O(log n + matches)
but remains O(n) in the worst case. Physical sharing is not claimed.
`warehouse_range_analytics.mlpl` adds an immutable segment tree built over an
arbitrary-length numeric vector. Half-open range queries combine cached sum
and minimum aggregates, and point updates rebuild a single logical path while
retaining the audited root. Empty, singleton, non-power-of-two, signed/zero,
full/partial/point/disjoint, invalid-range, corrupt-cache, and retained-version
behavior is executable. Logical update and ordinary range decomposition are
O(log n); runtime structural sharing remains unguaranteed.
`cumulative_shipments.mlpl` complements that tree with a compact immutable
Fenwick-tree array. It provides point-add, prefix-sum, and half-open range-sum
operations in logical O(log n), including empty and arbitrary-length vectors.
It deliberately does not duplicate range minimum: the segment tree owns that
richer aggregate. Validation rebuilds the internal array from retained source
values. Current recursive `scatter` calls amplify each logical operation into
multiple whole-array copies until transient or copy-on-write builders exist.
`numeric_prefix_routing.mlpl` adds an immutable indexed decimal-digit trie.
Digit vectors substitute for immature general strings; each arena node owns a
fixed ten-cell child row plus an optional numeric value. Exact lookup and
longest-prefix routing are logical O(key length), including an optional empty
key/default at the root. Tests cover shared/prefix/zero-digit keys, duplicate
replacement, missing routes, bad digits/shapes/handles/flags, cycles/shared
children, unreachable nodes, and retained versions. Arena updates currently
copy arrays; mature strings would generalize the key domain.
`page_index.mlpl` adds a fixed-order immutable B-tree expressed as a 2-3 tree:
each page carries one or two numeric key/value pairs and internal pages carry
two or three children. Persistent insertion handles leaf and internal splits,
median promotion, and root growth; duplicates replace values. Recursive audit
checks key counts, ordering, child ranges/presence, and uniform leaf depth.
Logical search/insertion visits O(log n) pages, while physical path sharing is
not guaranteed. B-tree deletion remains a separate planned operation.
`shipping_cost_expression.mlpl` supplies executable closed Composite and
Interpreter evidence: immutable numeric-tag nodes compose uniformly, tree shape
encodes precedence, and a recursive evaluator handles literals plus add,
subtract, multiply, and divide with Result-based tag/shape/division errors and
zero explicit loops. This is deliberately closed dispatch, not completion of
the open GoF patterns. Adding operations or node variants requires editing the
central evaluator until first-class functions, tagged unions with exhaustive
matching, protocols, and modules support independently extensible algebras.

| Script | Main idea |
|---|---|
| `demos/trees/team_hierarchy_traversals.mlpl` | record/indexed conversion plus three recursive traversals |
| `demos/trees/persistent_reservation_index.mlpl` | path rebuilding and old-root validity |
| `demos/trees/persistent_reservation_cancellation.mlpl` | all structural cases in deletion |
| `demos/trees/balanced_dispatch_index.mlpl` | rotations, cached heights, and balance invariant |
| `demos/trees/live_leaderboard_rank.mlpl` | cached subtree sizes, rank/select, and retained leaderboard roots |
| `demos/trees/appointment_conflicts.mlpl` | half-open overlap search with cached maximum-endpoint pruning |
| `demos/trees/warehouse_range_analytics.mlpl` | persistent point updates and half-open cached sum/minimum queries |
| `demos/trees/cumulative_shipments.mlpl` | compact point-add and prefix/range-sum analytics with retained values |
| `demos/trees/numeric_prefix_routing.mlpl` | indexed decimal-digit exact and longest-prefix route lookup |
| `demos/trees/page_index.mlpl` | immutable 2-3-tree page splits, root growth, lookup, and retained roots |
| `demos/trees/shipping_cost_expression.mlpl` | closed Composite/Interpreter baseline |

Document that “persistent” currently describes semantics, not efficient shared
storage.

#### T4 closeout

The tree baseline closes with five registered mini-apps and five matching
mlplunit scripts. All ten catalog entries report zero explicit loops and zero
target loops. Coverage includes record and indexed representations, conversion
parity, preorder/inorder/postorder, strict handle/cycle/shared-child validation,
persistent BST insert/search/delete, every AVL insertion rotation, cached
height/balance auditing, and Result-based closed expression interpretation.

The exact gaps exposed by this corpus preserve the global priority order in
`docs/analysis.md`:

1. rank 4 record update/spread would remove verbose whole-node rebuilding;
2. shipped static include now enables shared tree implementations and
   source-aware diagnostics; rank 3 full modules add namespaces/privacy;
3. rank 7 structurally shared persistent collections would
   turn semantic persistence into physical O(height) BST/AVL updates;
4. rank 5 tagged variants and exhaustive matching would replace numeric AST
   tags and ad hoc empty sentinels;
5. rank 1 UDF-capable recursive folds would make Composite,
   Interpreter, and Visitor behavior delegated rather than centrally closed.

Cycle detection remains advisory/contractual: indexed arenas may contain valid
application cycles, while strict-tree validators reject them before recursive
tree algorithms. No `malloc`/`free`, borrow checker, or mandatory cycle ban is
required. Direct reference cycles should eventually receive linter warnings
and retained-memory diagnostics; application-caused leaks or exhaustion remain
application bugs.

### Milestone T5: graph corpus

Current graph evidence begins with `transit_network_representations.mlpl`.
It normalizes duplicate directed edges with a last-write-wins policy, keeps
matrix presence separate from weights so zero-weight edges remain observable,
and converts the retained edge list to adjacency-matrix and CSR forms with zero
explicit loops. Tests cover empty/singleton graphs, directed asymmetry,
self-loops, isolated vertices, malformed endpoints, negative numeric payloads,
CSR offsets/targets, representation parity, retained source versions, and a
three-vertex cycle as valid application data. Numeric IDs make cycles ordinary
values with application-owned lifetimes; no reference cycle or GC is required.
The weighted baseline feeds Dijkstra, Bellman–Ford, Floyd–Warshall, A*, and
routing demos. Shared graph sources now provide normalization and converters;
slices/gather and sparse builders would reduce current mask/copy overhead.
`evacuation_bfs.mlpl` and `dependency_dfs.mlpl` add deterministic traversal
over dense presence matrices. BFS delegates to a copied-local pure queue state
and records first parents plus minimum hop levels; DFS recursively visits
ordered neighbors. Both terminate cycles/self-loops through visited masks and
use zero explicit loops. Tests cover invalid starts, empty/singleton, chains,
branches, duplicate edges, directed cycles, disconnected vertices, retained
graph versions, and traversal order. Until modules exist, graph and queue
helpers are intentionally duplicated; CSR plus shared imported traversal
contracts should replace dense O(V^2) scans and repeated immutable queue copies.
`dependency_cycle_and_order.mlpl` makes cycle policy explicit. Three-color DFS
reports a deterministic recursion-stack back edge, while pure-queue Kahn
ordering returns a complete deterministic DAG order or `Err` when cyclic input
blocks completion. Tests include empty/singleton, self-loop, two/three-node
cycles, disconnected DAGs, branching/ties, edge-order validation, normalized
and raw duplicate policy, malformed endpoints, retained versions, and cycle
rejection with zero explicit loops. Graph construction remains permissive:
detection informs the application and does not prohibit cyclical structures.
`service_clusters_scc.mlpl` implements Kosaraju with recursive finish-order
DFS, explicit graph transposition, and recursive component assignment. It
deterministically separates two cyclic service groups, a one-way tail, and an
isolated service with zero explicit loops. Tests cover empty/singleton,
self-loop, DAG singleton components, one large cycle, multiple SCCs, inter-SCC
edges, transpose parity, malformed endpoints, deterministic labels, and
retained versions. Dense traversal is O(V^2), recursion depth is application-
bounded, and immutable vectors copy heavily. Numeric IDs keep cycle ownership
application-managed; modules and CSR-aware folds should later share helpers.
`network_components_union_find.mlpl` adds an immutable disjoint-set forest.
Recursive `find` returns both root and a compressed forest; union uses rank and
deterministically retains the left root on ties. Tests cover empty/invalid IDs,
singleton/separate sets, idempotent union, rank merging, multiple components,
connected queries, explicit path compression, parent cycles, invariants, and
retained versions with zero explicit loops. Logical rank/compression behavior
has inverse-Ackermann amortized bounds, but immutable `scatter` currently copies
whole vectors; copy-on-write buffers or scoped transients would recover the
practical benefit without exposing mutation in the API.
`route_shortest_paths.mlpl` adds dense Dijkstra and Bellman–Ford over one
weighted edge fixture, including deterministic predecessors and recursive path
reconstruction. Nonnegative distances cross-check exactly; Dijkstra rejects
negative edges, while Bellman–Ford supports them and rejects only reachable
negative cycles. Tests cover source/self, direct and multi-hop choices,
unreachable vertices, zero weights, equal-distance ties, positive cycles,
negative edges/cycles, malformed endpoints, retained versions, and route
reconstruction with zero explicit loops. Both algorithms are logically O(VE)
in this transparent baseline and pay additional full-vector immutable-copy
costs; later priority queues, CSR, modules, and COW/transients can specialize
the implementation without changing its pure result contract.
`all_pairs_routes.mlpl` adds recursive Floyd–Warshall over flat row-major
distance and next-hop matrices, with deterministic path reconstruction and
explicit infinity/no-hop sentinels. It preserves unreachable pairs, supports
zero and negative edges, and detects negative cycles through the final
diagonal. Tests cover empty and singleton graphs, direct versus multi-hop
routes, asymmetric and unreachable pairs, zero/negative edges, positive and
negative cycles, malformed endpoints, retained graph versions, matrix
indexing, reconstructed paths, and row parity with the established
Dijkstra/Bellman–Ford fixture, all with zero explicit loops. Logical work is
O(V^3); immutable `scatter` additionally copies whole matrices for each cell
update. Array builders, efficient point updates, COW buffers, or scoped
transients would remove that practical overhead while retaining a pure public
result.
`network_cabling_kruskal.mlpl` composes a normalized undirected weighted edge
list, deterministic recursive insertion sort, and copied-local immutable
union-find helpers into a minimum-spanning-forest mini-app. Reverse and
duplicate offers collapse to their cheapest edge, self-loops are ignored,
and ties sort by weight then normalized endpoints. Tests cover empty and
singleton graphs, a known connected optimum, disconnected forests, duplicate
normalization, signed and zero weights, deterministic ties, cycle avoidance,
malformed endpoints/shapes, retained results, and union-find connectivity with
zero explicit loops. The transparent baseline uses O(E^2) insertion sorting;
immutable vector growth and union `scatter` add repeated copying. Modules would
remove copied helper definitions, while `grade_up` over composite keys plus
COW/transient builders would improve practical sorting and selection costs.

| Script | Main idea |
|---|---|
| `graphs/representations.mlpl` | matrix, edge list, CSR conversion |
| `graphs/bfs.mlpl` | delegated queue and visited mask |
| `graphs/dfs.mlpl` | explicit stack and recursive comparison |
| `graphs/cycle_detection.mlpl` | valid logical cycles through node IDs |
| `graphs/topological_sort.mlpl` | Kahn indegrees and queue |
| `graphs/strongly_connected.mlpl` | SCC decomposition |
| `graphs/union_find.mlpl` | path compression and rank |
| `graphs/dijkstra_dense.mlpl` | dense priority selection |
| `graphs/bellman_ford.mlpl` | edge relaxation and negative-cycle detection |
| `graphs/floyd_warshall.mlpl` | matrix dynamic programming |
| `graphs/kruskal.mlpl` | grade edges plus union-find |

Cross-check shortest-path algorithms on shared fixtures and connected
components against union-find.

Routing deliverables include weighted-edge shortest path with predecessor/path
reconstruction (Dijkstra), negative-edge comparison (Bellman–Ford), all-pairs
routes (Floyd–Warshall), A* with an explicit heuristic, and traveling-salesman
baselines: exact brute force or Held–Karp on small graphs plus clearly labeled
nearest-neighbor/2-opt approximations. Tests cover path weights, unreachable
vertices, ties, cycles, disconnected graphs, and negative-edge policy. Cycle
detection remains a separate explicit demo feeding topological-sort validation;
strongly connected components demonstrate cycles that are valid application
data.

The Held–Karp baseline is now executable as top-down memoization over a flat
`2^V * V` table. Ascending recursive successors and strict improvement match
the factorial solver's first-minimum tour on shared fixtures. It uses zero
explicit loops and exposes a deliberate implementation cost: every immutable
memo update scatters into full cost/next/known vectors. A native bit set,
general numeric-key map, UDF state fold, or scoped transient/COW table would
retain the pure API while making the physical cost closer to the logical
O(V²·2^V) time and O(V·2^V) space bounds.

Capacitated Vehicle Routing now extends the routing evidence beyond one TSP
tour. A zero-demand depot, per-customer demands, and a vehicle capacity produce
multiple closed routes encoded as one depot-delimited numeric stream because
nested numeric route collections are not yet available. The bounded exact
solver enumerates order and split decisions for at most seven customers; a
nearest-feasible greedy solver supplies the O(N²) practical comparison. Tests
cover exact-capacity service, deterministic ties, served counts, retained
inputs, excessive demand, malformed matrices, disconnected customers, and the
exponential size guard. General nested arrays, reusable branch-and-bound
policies, bit sets, folds, and scoped transient/COW builders are the direct
language improvements.

Edmonds–Karp maximum flow now provides a throughput-routing baseline over flat
capacity, residual, and signed-flow matrices. Recursive BFS finds deterministic
shortest augmenting paths, predecessor reconstruction finds bottlenecks, and
paired forward/reverse updates make cancellation/rerouting explicit. The
capacity-matrix contract requires callers to pre-sum parallel edges into one
cell. Tests cover the 23-unit classic oracle, conservation, capacity bounds,
source/sink totals, deterministic augmentation evidence, disconnected graphs,
parallel normalization, malformed shapes, negative capacity, retained inputs,
and source/sink policy. Logical complexity is O(V·E²); immutable residual and
flow scatters amplify physical copying. Queue modules, neighbor folds, paired
matrix updates, and scoped transient/COW arrays would simplify the code and
cost model.

Minimum-cut certification now completes the maximum-flow proof story.
Positive-residual reachability defines a source-side mask, then a row-major
capacity scan returns deterministic crossing edges and their summed capacity.
Tests prove cut membership, saturation, crossing capacity, max-flow/min-cut
equality, disconnected zero cuts, retention, and inherited validation. The
current parallel `from`/`to`/`capacity`/`residual` vectors avoid pretending
that nested edge records exist; edge filters, zipped record collections, and
transient builders are the natural representation improvements.

Bipartite maximum matching now demonstrates augmenting paths in a direct
assignment domain and cross-checks cardinality through the existing maximum-
flow solver. Flat binary adjacency and inverse left/right mate vectors make
uniqueness inspectable without general nested collections. Tests cover perfect
and partial results, deterministic rerouting, isolated vertices, empty sides,
malformed and nonbinary inputs, inverse-mate invariants, retained inputs, and
flow equality. The pure recursive Kuhn baseline is O(L·E), with immutable
scatter amplification in seen/mate vectors. Neighbor folds, general sets/maps,
zipped pair collections, and transient/COW updates are the direct refinements.

Minimum-cost square assignment now extends the matching corpus with a
deterministic Hungarian primal-dual solver and a separate factorial oracle for
fixtures of at most eight workers. The public result uses zero-based inverse
worker/task mates and total cost; internal arrays follow the conventional
one-indexed potential/ownership formulation. Tests cover a known optimum,
oracle and tie-policy agreement, equal costs, negative and fractional costs,
singleton and empty policy, inverse uniqueness, retention, malformed shape,
invalid size, and oracle bounds. Logical O(N³) work is obscured physically by
immutable work-vector copying; row/column folds, argmin policies, record
updates, and transient/COW arrays are the direct language improvements.

#### T5 closeout

The graph baseline has fifteen registered mini-apps and fourteen focused
mlplunit scripts. Every graph demo reports zero explicit loops and zero target
loops. The advanced follow-on is also complete; see
[advanced-routing-flow-assignment-report.md](advanced-routing-flow-assignment-report.md).
Its independent checks connect A* to Dijkstra, Held–Karp to factorial search,
matching to maximum flow, flow to minimum cut, and Hungarian assignment to
permutation search. No further umbrella test is planned because those focused
oracles already localize failures at the relevant abstraction boundary.

The parallel `demo-combinators` work is assessed in
[combinator-refactoring.md](combinator-refactoring.md). Adopt it selectively:
pilot a partially configured Strategy and a naturally pairwise `table` demo,
but retain direct recursive algorithm cores until Result-aware UDF
fold/scan/unfold and general-value traversal exist.

The Strategy partial pilot is complete: one weighted scorer plus bound weight
data is substitutable for the fixed balanced policy inside the unchanged
selector. The naturally pairwise `table` experiment is also complete: dynamic
machine-speed and batch-work vectors form an estimate matrix through a bound
setup-time policy, while a recursive oracle proves every cell and a column
scan turns the matrix into useful routing decisions. This removes real two-
dimensional construction recursion from the application path. Further
combinator adoption is paused pending UDF fold/scan/unfold, short-circuit and
Result-aware traversal, and general-value mapping; existing algorithm cores
remain the teaching baseline.

Rather than adding a redundant omnibus implementation, the focused tests carry
cross-algorithm invariants on shared fixtures:

| Contract | Evidence |
|---|---|
| representation and endpoint policy | edge-list/matrix/CSR parity plus malformed and asymmetric edges |
| reachability | BFS and DFS agree while preserving their deterministic traversal policies |
| DAG/cycle policy | three-color cycle detection and Kahn ordering succeed or fail consistently |
| strong connectivity | SCC labels group exactly the mutually reachable fixtures |
| undirected connectivity | union-find invariants and retained forests are checked directly |
| single-source distances | Dijkstra and Bellman–Ford agree where nonnegative-edge policy overlaps |
| all-pairs distances | applicable Floyd–Warshall rows match the established single-source fixture |
| spanning forest | Kruskal accepts `V-components` edges and its connectivity agrees with union-find |

Determinism is explicit: normalized endpoint order, ascending neighbor order,
stable queue order, left-root rank ties, lower predecessor/next-hop ties, and
Kruskal `(weight, low endpoint, high endpoint)` order. Logical complexities
range from dense O(V^2) traversals through O(VE) relaxation and O(V^3)
Floyd–Warshall; current immutable `concat`/`scatter` operations add full-vector
or full-matrix copies that the logical bounds do not show. Recursion depth is
application-managed, as are logical graph cycles represented by numeric IDs.

The gaps exposed by T5 now map to rank 1 UDF folds, rank 3 modules, rank 4
point/gather/record updates, rank 7 COW sharing, and later stack-safe recursion. Shipped
include is the immediate path for refactoring copied-local queue, graph, sort,
and union-find helpers into `src/`; full modules later add namespaces/privacy.

### Milestone T6: representative algorithm survey

Implement one strong example per idea before variants:

- `algorithms/dynamic_programming/{coin_change,knapsack,numeric_lcs}.mlpl`;
- `algorithms/greedy/interval_scheduling.mlpl`;
- `algorithms/backtracking/{n_queens,subset_sum,numeric_sudoku}.mlpl`;
- `algorithms/numeric/{gcd,sieve,fast_power}.mlpl`;
- `algorithms/sequence/{fisher_yates,reservoir_sampling}.mlpl`.

Current T6 evidence begins with `making_change.mlpl` and `loading_drone.mlpl`.
The former builds minimum counts and predecessor coins for unbounded change;
the latter builds rolling values plus a flat decision matrix for 0/1 item
selection. Both reconstruct one optimum deterministically with zero explicit
loops. Coin ties prefer the smaller denomination; knapsack value ties retain
the earlier solution by excluding the later item. Tests cover empty/zero and
impossible cases, invalid inputs, canonical/noncanonical and duplicate coin
systems, exact reconstruction, heavy/exact-fit/competing packages, deterministic
ties, retained inputs, and known optima. Logical costs are O(target * coins)
and O(items * capacity); recursive table construction is stack-bounded by those
dimensions, while immutable `concat` adds growing-table copies. Modules, folds,
and COW/transient builders remain the direct simplification/performance path.
`shared_event_trace.mlpl` extends that evidence with numeric-token longest
common subsequence over a flat row-major table. It reconstructs a shared event
trace recursively, resolving equal-length alternatives by moving upward in the
table. Tests cover empty, identical, disjoint, prefix/suffix, repeated-token,
and multiple-optimum inputs; length symmetry; known optimal reconstruction;
subsequence validity against both inputs; table dimensions/indexing; and
retained inputs. It uses zero explicit loops with logical O(m*n) time/space.
Each current immutable `scatter` copies the O(m*n) table, so matrix builders or
COW/transient storage remain the material performance improvement.
`meeting_room_schedule.mlpl` adds earliest-finish interval scheduling over
parallel numeric start/end/ID vectors. It validates unique IDs and ordered
endpoints, recursively insertion-sorts by `(finish, start, ID)`, then greedily
accepts compatible half-open intervals. Touching and zero-length intervals are
allowed; duplicate time ranges are deterministic, while duplicate IDs are
rejected. Tests cover empty/singleton, disjoint/overlapping/nested, unsorted,
negative-time, zero-length, duplicate, malformed, reversed, tie, retained-input,
compatibility, and known-optimum cases with zero explicit loops. The transparent
sort is O(n^2), versus an O(n log n) target with a general comparator sort;
immutable insert/append also copy growing parallel vectors. UDF comparators,
modules, and COW/transient builders are the direct improvements.
`exhibit_queens.mlpl` and `exact_project_budget.mlpl` add the first
backtracking evidence. N-queens tries columns left-to-right for each row and
returns the deterministic first nonattacking placement; signed subset sum tries
including each increasing input index before excluding it, so items cannot be
reused and negative/zero adjustments remain valid. Tests cover N=0/1/2/3/4/8,
unsatisfiable boards, attack invariants, invalid bounded sizes, empty and
impossible subsets, singleton/tie/duplicate cases, signed values, no reuse,
retained inputs, and selected-sum/index invariants. Both use zero explicit
loops, O(n) recursion depth, exponential worst-case search, and immutable
partial-vector copies. Modules, folds, generators, memoization, and transient
builders are the direct future improvements.
`sudoku_shift_roster.mlpl` completes the initial backtracking trio with a flat
81-cell numeric board, zero for blanks, initial-given validation, and
deterministic row-major/digit-ascending search. Tests cover a known solution,
repeatability, retained input, an already solved grid, an internally valid but
unsatisfiable board, conflicting givens, malformed shapes, fractional cells,
and range errors. Search is exponential in the worst case, recursion is bounded
by 81 assignments, and immutable `scatter` copies the board per candidate;
candidate masks, generators, folds, modules, and transient builders are the
direct improvements.
The numeric survey now includes Euclidean GCD, the Sieve of Eratosthenes, and
exponentiation by squaring. GCD and fast power use logarithmic scalar recursion;
the sieve recursively marks multiples in an immutable flag vector. Tests cover
zero, signs, coprime/common-factor inputs, known prime ranges, odd/even powers,
large known results, retained values, validation boundaries, and a linear-power
oracle. All three use zero explicit loops. Immutable sieve `scatter` copies are
the material cost; folds, transient builders, and modules are the direct future
improvements.
Seeded Fisher–Yates and reservoir sampling complete the sequence-sampling
slice. Both use an explicit modulus-65521 LCG state so runs are reproducible,
validate integral seeds in `[0,65520]`, and use zero explicit loops. Shuffle
preserves input multiplicities, including duplicates; reservoir sampling
tracks distinct source indices, caps `k>=n`, and handles `k=0` and empty input.
The bounded modulo mapping has slight bias and is not cryptographic. Logical
work is O(n), while immutable shuffle scatters amplify physical copying to
O(n²) and reservoir replacements copy O(k) state. A delegated unbiased RNG,
folds, COW/transient builders, and modules are the future refactoring path.

### Milestone T7: patterns possible today

Focused baselines:

- Adapter: convert edge list to CSR;
- Prototype: derive a modified graph while retaining the original;
- Flyweight: graph nodes refer to a shared numeric payload table;
- Memento: retain versions of a numeric editor/state machine;
- Composite: tagged numeric expression tree;
- Interpreter: evaluate that expression tree;
- State: closed numeric event transition system;
- Iterator: explicit `{collection, index}` baseline.

These establish acceptance cases that later features must simplify.

Strategy is now executable through `shipping_service_policy.mlpl`. Named UDF
references stored in a record are passed to one unchanged selector and invoked
uniformly with `call`; economy, urgent, and balanced policies select different
services. This removes first-class named UDF invocation from the blocker list.
UDF-capable folds, dynamic callable collections, composition/binding, modules,
variants, and persistent storage remain the next feature layers. See
[strategy-acceptance.md](strategy-acceptance.md).

Adapter is now executable through `transit_departure_board.mlpl`: a pure
boundary reuses edge-list-to-CSR conversion but exposes renamed target fields
to a departure consumer. Tests prove CSR parity, retained source versions,
isolated and zero-cost routes, and endpoint errors. It uses zero explicit
loops; logical conversion is O(VE), with growing-vector copies in the current
immutable implementation. Modules improve privacy but do not gate Adapter.
Prototype is now executable through `event_transit_service.mlpl`: named pure
transformations derive event and sibling graph variants while tests retain the
prototype and all earlier versions. Route lookup is O(E), payload update O(V),
and current vector operations copy affected arrays. Record update/lenses and
structural sharing improve clarity and cost, but value-level Prototype intent
works today; physical sharing is neither observable nor claimed.
Flyweight is now executable through `shipment_manifest.mlpl`: a shared
intrinsic table holds package weights/handling factors, and orders retain only
numeric type IDs plus extrinsic quantities. Resolution is O(orders) with
growing immutable output copies. Tests cover reuse, lookup policy, empty and
malformed inputs, and retained table values. No runtime interning or physical
identity claim is needed or made.
Memento is now executable through `undo_room_plan.mlpl`: originator capacity
transitions remain separate from caretaker capture, restore, and undo over
flat fixed-width snapshots. Tests cover multiple revisions, two-step undo,
retained histories/states, and empty/shape/index/edit errors. Current history
operations copy O(history*rooms); modules/private mementos and persistent
vectors improve encapsulation and cost without gating numeric Memento intent.
Closed Composite and Interpreter are now explicit through
`shipping_quote_rules.mlpl`, reusing the established expression-tree source.
Tests separately cover part-whole structure/traversal/retained subtrees and
deterministic interpretation with unknown, malformed, empty, and division
errors. Both use zero loops and O(nodes) evaluation. They remain closed:
variants or operations require dispatch edits until UDF algebras,
variants/pattern matching, folds, and modules arrive.
Closed State is now executable through `incident_response_workflow.mlpl`:
immutable incident states interpret numeric events and return effects-as-data,
which a separate boundary function summarizes. Tests cover deterministic
acknowledge/resolve/reopen transitions, retained prior states, ownership,
unknown events, invalid transitions, and empty effects. Adding states/events
still edits central dispatch; first-class function tables, variants, folds,
modules, and record update gate the preferred open form.
Explicit Iterator is now executable through
`maintenance_budget_iterator.mlpl`: immutable collection/index cursors expose
`has_next`/`next`, and a protocol-only consumer stops before an over-budget
job while returning the remaining cursor. Tests cover empty/singleton/dynamic
traversal, exhaustion, deterministic order, independent states, retained
collections, and budget errors. Folds/scan/unfold/each with first-class UDFs
and modules remain the preferred reusable/private form.

## Feature-gated tracks

The following order matches `docs/analysis.md`: low-hanging broad changes
first, followed by foundational composition/runtime work, then specialized
domains.

### F1 — pure `put`, general gather, and slices

Promote or refactor:

- reverse, insertion sort, merge sort, heap, and heap sort;
- chunked vector, ring queue/deque, linked arenas;
- hash maps and rehash;
- CSR traversal;
- every dynamic-programming table;
- persistent tree arena operations.

New demos:

- `foundations/lens_get_put.mlpl`;
- `algorithms/sequence/partition.mlpl`;
- `algorithms/sort/quicksort.mlpl`;
- `graphs/csr_slicing.mlpl`.

Success metric: remove flatten/mask workarounds and reduce total loop/body LOC
without weakening purity.

### F2 — record update/spread and destructuring

Promote or refactor:

- persistent cons list, BST, AVL, and expression tree;
- Builder baseline;
- State and Memento records;
- Result-rich collection APIs.

New demos:

- `patterns/creational/builder.mlpl`;
- `foundations/composed_lenses.mlpl` once functions are values;
- `patterns/creational/prototype_records.mlpl`.

### F3 — first-class named UDFs and uniform invocation

This is the first major language milestone.

Executable acceptance demos:

- Strategy: comparator-driven sort, hash/equality policy, graph search policy;
- Factory Method: the fulfillment workflow injects economy/expedited constructors;
- Abstract Factory: a fixed record supplies related worker/storage constructors;
- Bridge: energy reporting abstraction paired with direct/scaled implementations;
- Template Method: algorithm skeleton parameterized by steps;
- basic Decorator and Proxy wrappers;
- function-valued lens pairs.

Refactor all collection APIs so equality, ordering, hashing, storage, and
traversal policies can be delegated rather than hard-coded.

### F4 — UDF-capable collection combinators

Add `map`, `filter`, `fold`, short-circuit fold, `scan`, `unfold`, `zip`,
`partition`, and `flat_map`.

Gated demos:

- loop-free persistent-list traversal;
- loop-light vector construction through `unfold`;
- comparator/key-driven merge and quicksort;
- generic graph neighbor folds and path expansion;
- Chain of Responsibility as short-circuit fold;
- Iterator as fold/unfold protocol;
- Visitor as an algebra fold;
- Observer notification fold;
- Composite and Interpreter generic folds;
- dynamic programming rows via scans where dependencies permit.

Success metric: catalog loop count ratchets down; each remaining loop explains
why it represents temporal recurrence rather than collection traversal.

### F5 — modules and visibility beyond shipped static include

Status: sandboxed static `include` is now available and is being adopted under
`src/` so demos and tests share production definitions. The remaining feature
is a module system with qualified namespaces, explicit exports, and private
helpers; textual inclusion alone does not provide those boundaries.

Evidence gate: do not begin this feature until approximately 6–10 genuine
problem-solving mini-apps exist and repeated helpers have been inventoried.
The initial corpus intentionally duplicates small helpers so module boundaries
come from observed reuse.

Minimum language/runtime changes:

- module/import AST and parser support beyond textual static inclusion;
- qualified paths and stable module identities;
- qualified module namespace lookup;
- explicit exports and private-by-default helpers;
- one evaluation per module;
- import-cycle diagnostics with full paths;
- filename-aware spans and errors;
- a pluggable source provider for CLI filesystem and web/WASM bundles;
- compile-to-Rust-compatible dependency ordering.

Do not require package registries, versions, remote/dynamic imports, or runtime
`eval` in the first version. Shipped textual `include` remains the transparent
source-splicing surface; full modules build namespace and visibility semantics
on the same sandboxed source-provider foundation.

Extract reusable libraries:

```text
lib/assert.mlpl
lib/sequence.mlpl
lib/queue.mlpl
lib/heap.mlpl
lib/hash.mlpl
lib/graph.mlpl
lib/fold.mlpl
```

Gated demos/patterns:

- Facade with private implementation modules;
- module-scoped immutable Singleton interpretation;
- dependency-inverted graph algorithms;
- reusable storage protocols shared by stack, queue, and deque;
- case studies composed without copied helpers.

#### Static-include source refactoring

This migration is active now; create canonical production sources such as:

```text
src/vectors.mlpl
src/stacks.mlpl
src/queues.mlpl
src/indexed_arena.mlpl
src/graph_representations.mlpl
```

Refactor tests and demos to include the same production helpers; assertions
remain supplied by mlplunit. Leave each mini-app focused on its problem, input,
algorithm assembly, and result, and verify output parity. After F5 lands,
qualified modules can resolve helper-name collisions and add exports, privacy,
evaluate-once identity, and module-cycle diagnostics.

### F6 — composition, pipes, partial application, captures

Gated demos:

- Decorator chains for validation/tracing/caching;
- functional Template Method pipelines;
- Proxy with access/lazy/cache policy;
- bound comparator and hash functions;
- point-free transformation pipelines;
- Command values with bound immutable arguments;
- fully composed lens pipelines.

Case-study gate: `patterns/case_studies/graph_pipeline.mlpl` should read as a
top-down composition with no nested policy dispatch.

### F7 — integer and boolean types

Refactor nearly the entire corpus:

- indices and handles become integers;
- visited/used/tombstone/color fields become booleans or variants;
- hash arithmetic becomes exact integer arithmetic;
- bounds, overflow, and invalid-index errors become type-directed.

New validation demos:

- integer overflow/checked indexing;
- hash mixing golden cases;
- boolean reduction and short-circuit behavior.

### F8 — copy-on-write dense buffers

Performance acceptance demos:

- vector append/update with retained old version;
- queue workloads;
- hash-map insert/resize;
- union-find path compression;
- dynamic-programming table updates;
- Memento history.

Measure bytes copied and retained; observable results must remain identical.

### F9 — structurally shared persistent collections

Gated or upgraded demos:

- persistent cons list with shared tail;
- persistent vector and chunked vector;
- persistent queue/deque;
- persistent BST, AVL, and red-black tree;
- persistent numeric map, then HAMT;
- cheap Memento history;
- shared Composite/AST subtrees.

Acceptance: one tree update allocates proportional to path height, not total
tree size; old and new roots remain valid.

### F10 — tagged variants and exhaustive matching

Upgrade:

- List `Empty | Cons`;
- Tree `Empty | Branch`;
- AST node variants;
- State events and transitions;
- Command variants;
- Composite, Interpreter, Visitor, and State demos.

Acceptance: adding a variant produces an exhaustiveness diagnostic at every
incomplete consumer.

### F11 — general numeric map/set value

Gated demos:

- generic frequency table;
- sparse graph construction;
- memoized numeric recursion;
- Observer registry keyed by numeric subscription ID;
- Mediator routing table;
- State transition table;
- Strategy-configured map with hash/equality functions.

Keep the hand-built hash map as the implementation teaching demo and use the
builtin value as infrastructure elsewhere.

### F12 — cycle linter and memory diagnostics

Gated demos:

- direct cyclic list/tree/graph values when reference-bearing values exist;
- mutually capturing callbacks;
- Observer registry capture cycle;
- Mediator/component cycle;
- Proxy/Decorator wrapper cycle;
- safe handle-arena alternative for each.

Acceptance: diagnostics show the full strong-ownership path, do not confuse
named recursion or ID-based graph cycles with ownership cycles, and never
prohibit execution by default. Demonstrate that an intentionally leaked cycle
can hit a configured limit and is reported as an application bug.

### F13 — scoped transient/builder optimization

Gated performance demos:

- bulk vector builder;
- hash-map rehash;
- Fisher–Yates shuffle;
- union-find compression batch;
- DP matrix construction;
- CSR graph builder.

Source remains observationally pure; the builder cannot escape its scope.

### F14 — nested/general arrays

Gated demos:

- ragged adjacency lists;
- nested persistent sequences;
- generic heterogeneous command history;
- open Composite trees without fixed record fields;
- nested-array `each` and structural display;
- APL2-style depth/enclose/disclose/pick exercises.

### F15 — mature string sequences

Gated demos:

- string-keyed map and set;
- trie/radix tree;
- naive substring search, KMP, Boyer–Moore, and Rabin–Karp;
- tokenizer and small parser;
- string comparator Strategy;
- address-book/inventory domain for GoF case studies.

Required surface includes length, indexing, slicing, concatenation, code-point
or byte conversion, split/join, comparison, find, replace, and hashing hooks.

### F16 — file I/O and formatting

Gated demos:

- persistent inventory/address book;
- graph load/save;
- external-sort pipeline;
- formatted numeric report;
- command/event log replay;
- resource-safe Proxy/Facade around file capabilities.

Resource APIs should be scoped so close/release happens on every Result path.

### F17 — structured serialization and codec delegation

The executable current-language baseline and concrete cross-format acceptance
fixtures are in [serialization-acceptance.md](serialization-acceptance.md).
Today the repository can honestly demonstrate a numeric in-memory application
envelope that preserves shape and detects accidental corruption. It must not be
described as JSON, TOML, bytes, or durable binary I/O.

Gated general-purpose demos:

- round-trip a numeric application configuration through JSON;
- load and validate TOML configuration;
- save/load a graph or immutable application snapshot;
- convert between JSON, TOML, and a versioned native value format;
- round-trip shaped numeric arrays while preserving exact element type,
  dimensions, byte order, and extensible metadata;
- reject malformed, oversized, excessively deep, and unsupported cyclic data.

The native binary format should preserve sw-MLPL values more faithfully than
JSON, including numeric types, shapes, records, Results, future variants, and
eventually shared-reference tables. Decoders need path-aware errors, size/depth
limits, format versions, optional fields, and application-defined migrations.
User codecs and schema policies should use first-class function delegation.

This repository demonstrates only general-purpose serialization. Quantized
tensor/model encodings and ML format conversion belong in the future
`demo-sw-mlpl` repository, built on the same byte, shape, type, endianness,
metadata, and codec facilities.

### F18 — weak references or ergonomic arena handles

Specialized demos:

- direct parent links in a tree;
- graph nodes with weak metadata back-links;
- observer lifetimes without strong callback cycles;
- generational arena handles detecting stale IDs.

This is lower priority because numeric handles already support algorithmic
cycles and application-owned bulk lifetimes.

### F19 — optional automatic cycle collection

No core demo is gated by this under the project contract. If implemented,
extend memory stress tests to prove unreachable strong cycles are reclaimed.
Until then, leaks or exhaustion from application-managed strong cycles remain
application bugs.

## GoF completion sequence

The current baseline stage is complete; see
[gof-baseline-report.md](gof-baseline-report.md) for the evidence audit and
all-23 feature matrix. “Completed” below means preferred functional form, so
closed Composite/Interpreter/State and explicit Iterator remain scheduled for
later open/combinator refinement even though their honest baselines run now.

| Stage | Patterns completed |
|---|---|
| Baseline complete | Adapter, graph Prototype, numeric Flyweight, Memento, closed Composite, closed Interpreter, closed State, explicit Iterator |
| F2 | Builder and clean record Prototype |
| F3 | Strategy, Factory Method, Abstract Factory, Bridge, basic Template Method, basic Decorator, basic Proxy |
| F4 | Chain of Responsibility, functional Iterator, Visitor fold, Observer fold, generic Composite/Interpreter |
| F5 | Preferred Facade boundary and module-scoped immutable Singleton interpretation |
| F6 | Command, full Decorator/Proxy/Template Method, composition-centric pipelines |
| F11 | Mediator and registry-driven Observer/State |
| F9/F10/F14 | Efficient and open-ended persistent variants of Composite, Memento, Command, Interpreter, and Visitor |

Current acceptance status is 22 executable patterns plus one precisely gated
Singleton. Preferred dynamic/open refinements remain scheduled; a numeric
opcode switch does not substitute for delegated behavior.

## Release milestones

1. **M0 — Dynamic Values Today:** T0–T3; runnable vectors, queues, linked
   arenas, sorting/search, and resizable numeric hashing.
2. **M1 — Trees and Cycles by ID:** T4–T5; persistence baselines, AVL, CSR,
   traversal, paths, and explicit logical cycles.
3. **M2 — General Algorithm Survey (complete):** T6–T7; representative
   algorithms and honest pattern baselines.
4. **M3 — Pure Update Ergonomics:** F1–F2.
5. **M4 — Behavior as Values:** F3–F6; first-class delegation and loop-count
   reduction.
6. **M5 — Correct and Efficient Values:** F7–F10; types, COW, structural
   sharing, variants.
7. **M6 — General Data Domains:** F11–F16; maps, diagnostics, nesting, strings,
   and persistence boundaries.

At every release, publish the catalog counts: runnable, gated, constrained,
total explicit loops, loops removable by known features, and demos exercising
each GoF pattern.
