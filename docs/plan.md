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
- remains standalone until static modules/imports exist.

Both demos and tests:

- run against the selected `mlpl-repl` binary;
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

Status: adopted. `scripts/run-tests` resolves `$MLPLUNIT`, then `PATH`, then an
adjacent development checkout. All tests use native `test_*.mlpl` discovery
names and can also be run by passing the `tests/` directory to mlplunit. See
[mlplunit-adoption.md](mlplunit-adoption.md). Because mlplunit is evolving
rapidly, re-inspect its current CLI and assertion library before changing this
integration rather than relying on this plan as a frozen API description.

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
versions, and reciprocal `next`/`previous` invariants. It remains planned; the
existing delivery-route demo is singly linked only.

Current evidence: `demos/persistent_lists/alert_feed.mlpl` and its conformance
test implement prepend and recursive traversal with zero explicit loops. Old
feed values remain semantically unchanged. Efficient O(1) shared tails remain
a runtime structural-sharing feature; the current evaluator may clone nested
records.

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
The batch-duration mini-app delegates heap sort to the same min-heap contract
with zero explicit loops. Until modules/imports exist, its sift/insert/remove
helpers are copied locally; this is now concrete evidence for the planned heap
module refactoring rather than hypothetical duplication.

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

Advanced hashing experiments follow the classical baseline rather than replace
it. Candidate comparisons include Robin Hood/cuckoo-style probing,
high-load-factor probe distributions, and simplified pedagogical adaptations
inspired by [Modern Hashing Made Simple](https://epubs.siam.org/doi/10.1137/1.9781611977936.33),
[rainbow hashing](https://arxiv.org/abs/2409.11280), and
[optimal open addressing without reordering](https://arxiv.org/abs/2501.02305).
These schemes may require randomness, packed bit metadata, and stronger integer
primitives. Initial demos should reproduce small invariants and probe-count
comparisons without claiming a paper's asymptotic guarantees unless all its
assumptions are implemented.

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
Future modules/imports should place traversal contracts and validators in one
helper module rather than duplicating `u:` functions between demos and tests.
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

1. rank 2 record update/spread would remove verbose whole-node rebuilding;
2. rank 5 modules/imports would share tree implementations between demos and
   tests with source-aware diagnostics;
3. rank 9 structurally shared persistent collections plus tracing GC would
   turn semantic persistence into physical O(height) BST/AVL updates;
4. rank 10 tagged variants and exhaustive matching would replace numeric AST
   tags and ad hoc empty sentinels;
5. ranks 3–4 first-class UDFs and recursive folds would make Composite,
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
routing demos. Modules should eventually share normalization and converters;
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

### Milestone T6: representative algorithm survey

Implement one strong example per idea before variants:

- `algorithms/dynamic_programming/{coin_change,knapsack,numeric_lcs}.mlpl`;
- `algorithms/greedy/interval_scheduling.mlpl`;
- `algorithms/backtracking/{n_queens,subset_sum,numeric_sudoku}.mlpl`;
- `algorithms/numeric/{gcd,sieve,fast_power}.mlpl`;
- `algorithms/sequence/{fisher_yates,reservoir_sampling}.mlpl`.

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

Newly complete demos:

- Strategy: comparator-driven sort, hash/equality policy, graph search policy;
- Factory Method: inject graph/storage constructors;
- Abstract Factory: record of related constructors;
- Bridge: graph abstraction paired with dense/CSR implementation;
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

### F5 — static modules/imports and visibility

Evidence gate: do not begin this feature until approximately 6–10 genuine
problem-solving mini-apps exist and repeated helpers have been inventoried.
The initial corpus intentionally duplicates small helpers so module boundaries
come from observed reuse.

Minimum language/runtime changes:

- static import AST and parser support;
- paths relative to the importing source;
- qualified module namespace lookup;
- explicit exports and private-by-default helpers;
- one evaluation per module;
- import-cycle diagnostics with full paths;
- filename-aware spans and errors;
- a pluggable source provider for CLI filesystem and web/WASM bundles;
- compile-to-Rust-compatible dependency ordering.

Do not require package registries, versions, remote/dynamic imports, or runtime
`eval` in the first version. Textual `include`, if provided, should be sugar
over the same static loader.

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

#### Post-module library refactoring

After F5 lands, create canonical helpers such as:

```text
lib/assertions.mlpl
lib/vectors.mlpl
lib/stacks.mlpl
lib/queues.mlpl
lib/indexed_arena.mlpl
lib/graph_representations.mlpl
```

Refactor tests to import production helpers; assertions may remain supplied by
mlplunit or move to an importable mlplunit module. Refactor demos to
import only production helpers, leaving each mini-app focused on its problem,
input, algorithm assembly, and result. Verify that old and refactored scripts
produce equivalent outputs and that module cycles/name collisions receive
clear diagnostics.

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

| Stage | Patterns completed |
|---|---|
| Today | Adapter, array Prototype, numeric Flyweight, Memento, closed Composite, closed Interpreter, closed State, Iterator baseline |
| F2 | Builder and clean record Prototype |
| F3 | Strategy, Factory Method, Abstract Factory, Bridge, basic Template Method, basic Decorator, basic Proxy |
| F4 | Chain of Responsibility, functional Iterator, Visitor fold, Observer fold, generic Composite/Interpreter |
| F5 | Facade and module-scoped immutable Singleton interpretation |
| F6 | Command, full Decorator/Proxy/Template Method, composition-centric pipelines |
| F11 | Mediator and registry-driven Observer/State |
| F9/F10/F14 | Efficient and open-ended persistent variants of Composite, Memento, Command, Interpreter, and Visitor |

Completion means all 23 have runnable preferred functional implementations;
a numeric opcode switch does not substitute for delegated behavior.

## Release milestones

1. **M0 — Dynamic Values Today:** T0–T3; runnable vectors, queues, linked
   arenas, sorting/search, and resizable numeric hashing.
2. **M1 — Trees and Cycles by ID:** T4–T5; persistence baselines, AVL, CSR,
   traversal, paths, and explicit logical cycles.
3. **M2 — General Algorithm Survey:** T6–T7; representative algorithms and
   honest pattern baselines.
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
