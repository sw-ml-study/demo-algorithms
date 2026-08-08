# sw-MLPL Data Structures and Algorithms

General-purpose data-structure and algorithm demonstrations written as
standalone `.mlpl` scripts for the
[sw-MLPL](https://sw-ml-study.github.io/sw-mlpl/) interpreter.

This repository has two jobs:

1. Show that an array language designed around modern ML can also explain
   dynamically sized structures and ordinary programming clearly, with few
   explicit loops and preferably none.
2. Act as a forcing function: when a normal algorithm is awkward or
   impossible, record the missing language capability precisely and turn it
   into an executable acceptance case for sw-MLPL.

The demonstrations deliberately favor pure transformations, function
composition, delegation, and whole-array operations. An explicit loop is a
baseline or a last resort, not the intended destination. A sorting demo should
still expose the algorithm rather than merely call `grade_up`; the challenge is
to express its phases through reusable array combinators.

## Status

### Verified tools

Verified baseline: `mlpl-repl 0.20.0`, local build commit `533b69f8`
(2026-08-07), with mlplunit `0.1.0` at commit `a06191f`.

### Executable corpus

The repository now contains 94 working mini-apps and 86 conformance-test
files, reporting 183 native tests and parameter cases, as well as the longer
implementation plan.

### Core design and roadmap

- [PLAN.md](PLAN.md) covers the taxonomy, capability analysis, proposed file
  tree, feature gaps, and delivery sequence.
- [Current capability status](docs/current-capability-status.md) summarizes
  what works now, efficiency gaps versus semantic blockers, and the recommended
  next language-driven wave.
- [UDF collection-combinator contract](docs/udf-collection-combinator-contract.md)
  specifies the minimum general-value and Result-aware fold surface needed for
  the next high-value refactoring wave.
- [Module and Singleton contract](docs/module-singleton-acceptance-contract.md)
  distinguishes shipped static include from qualified evaluate-once modules
  and defines the exact acceptance fixture for the final gated GoF pattern.
- [DESIGN_PATTERNS.md](DESIGN_PATTERNS.md) maps all 23 Gang of Four patterns to
  functional sw-MLPL forms.
- [MEMORY_DESIGN.md](MEMORY_DESIGN.md) analyzes dynamic values without
  `malloc`/`free`, a language borrow checker, or a mandatory tracing GC.
- [General-purpose serialization acceptance](docs/serialization-acceptance.md)
  records executable JSON, TOML-subset, and raw-byte persistence and separates
  that baseline from future typed native formats, streaming, and wider budgets.

### Algorithm and data-structure reports

- [Dynamic-sequence foundation report](docs/dynamic-sequence-report.md):
  executable evidence, loop counts, and remaining gaps.
- [Search/sort/priority report](docs/search-sort-priority-report.md): coverage,
  complexity, zero-loop results, and module evidence.
- [Algorithm survey closeout](docs/algorithm-survey-report.md): twelve
  representative algorithms, boundary policies, costs, and motivated language
  improvements.
- [Advanced routing, flow, and assignment closeout](docs/advanced-routing-flow-assignment-report.md):
  exact/heuristic classifications, independent cross-checks, representations,
  copy costs, and phase-specific language priorities.
- [Combinator refactoring assessment](docs/combinator-refactoring.md): where
  current partials and `each`/`table`/`atop`/`over` improve demos, where direct
  recursion remains clearer, and two recommended pilots.
- [Modern hashing assessment](docs/modern-hashing-assessment.md): separates
  mixers, table organization, and cryptographic claims; evaluates recent
  funnel, rainbow, zombie, and adaptive hashing work; and defines the gates for
  an honest high-load experiment.
- [Demo repository boundaries](docs/repository-boundaries.md): keeps basic
  algorithm correctness here while routing probe distributions, benchmarks,
  Bloom filters, and advanced hashing exclusively to
  [`demo-memory`](https://github.com/sw-ml-study/demo-memory).

### Design-pattern reports

- [Functional GoF closeout](docs/gof-baseline-report.md) and the concise
  [all-23 status and feature ranking](docs/gof-status.md) provide the overview.
- [Strategy](docs/strategy-acceptance.md),
  [Factory Method and Abstract Factory](docs/factory-acceptance.md),
  [Bridge](docs/bridge-acceptance.md), and
  [Template Method](docs/template-method-acceptance.md) cover callable
  construction and policy substitution.
- [Decorator and Proxy](docs/decorator-proxy-acceptance.md),
  [Command and Visitor](docs/command-visitor-acceptance.md), and
  [Builder](docs/builder-remaining-gates.md) cover composition, executable
  operations, and staged construction.
- [Facade](docs/facade-acceptance.md), [fixed Chain](docs/chain-acceptance.md),
  and [Observer and Mediator](docs/observer-mediator-acceptance.md) cover
  subsystem boundaries and functional coordination.

## Scripts: demos versus tests

This repository uses two distinct kinds of `.mlpl` script:

- **Demos** are small applications. Each states a concrete problem, explains
  the data structure and algorithm used to solve it, and produces a meaningful
  result for a reader to inspect.
- **Tests** are assertion-heavy conformance scripts. Their product is a final
  `Ok(...)` or `Err(...)`, and the harness treats that result as pass/fail.

The original assertion-heavy scripts live under `tests/`; result-oriented
mini-apps live under `demos/` with matching conformance coverage.

## Task runner

[`just`](https://just.systems/) is the preferred task runner for this
repository. The root `justfile` is intentionally a thin façade over the
existing scripts; it does not duplicate test discovery, catalogs, or binary
selection. This project does not use `make` and has no Makefile.

```sh
just                 # list recipes
just demos           # run all problem-solving demos
just tests           # run all native conformance tests
just tests tests/maps
just tap tests/maps  # focused TAP output
just list-tests
just audit
just check           # complete local validation gate
```

The direct `./scripts/...` commands documented below remain supported for
minimal environments and debugging. Prefer adding a delegating `just` recipe
for new routine workflows; do not add a Makefile unless an external integration
explicitly requires Make compatibility.

## Related repository: memory and advanced hashing demos

Memory-behavior and advanced-hashing demos are intentionally not part of this
repository. Use [`demo-memory`](https://github.com/sw-ml-study/demo-memory) for:

- linear-versus-Robin-Hood probing and backward-shift follow-ons;
- probe workload matrices, distributions, histograms, and tail percentiles;
- Bloom and counting Bloom filters;
- FIFO/LRU memory-policy comparisons;
- timing, throughput, packed-layout, bytes-per-key, cache, and SIMD studies;
- funnel, elastic, rainbow, zombie, and adaptive hashing experiments; and
- the authoritative sw-MLPL feature requests earned by those experiments.

This repository retains the foundational algorithm lessons: numeric mixing,
basic linear-probing CRUD, tombstone semantics, resize/rehash, separate
chaining, and one application-oriented LRU composition demo. The removed Robin
Hood demo was redundant with the newer `demo-memory` work. See the full
[repository ownership boundary](docs/repository-boundaries.md).

## Prerequisite: build sw-MLPL

The scripts require the `mlpl-repl` executable from
[sw-MLPL](https://github.com/sw-ml-study/sw-mlpl). A convenient checkout layout
places both repositories under the same parent directory:

```text
sw-ml-study/
  sw-mlpl/
  demo-algorithms/
```

Build the release interpreter from the sw-MLPL checkout:

```sh
cd ../sw-mlpl
cargo build --manifest-path components/cli/Cargo.toml -p mlpl-repl --release
cd ../demo-algorithms
```

The commands in this repository default to the resulting sibling binary:

```text
../sw-mlpl/target/release/mlpl-repl
```

No package installation or modification of the user's globally installed
`mlpl-repl` is required.

## Prerequisite: mlplunit for tests

Conformance tests use
[mlplunit](https://github.com/softwarewrighter/mlplunit) for configuration and
discovery, isolated processes, shared assertions, native `@test`/`@cases`,
bracketed lifecycle, human/TAP reporting, and deterministic suite status.
`scripts/run-tests` resolves it from `MLPLUNIT`, then `PATH`, then the adjacent development checkout at
`../../softwarewrighter/mlplunit/bin/mlplunit`.

Run one currently working conformance test through mlplunit:

```sh
MLPL=../sw-mlpl/target/release/mlpl-repl \
  ../../softwarewrighter/mlplunit/bin/mlplunit \
  tests/vectors/test_array_memory.mlpl
```

Run every registered problem-solving demo:

```sh
./scripts/run-all
```

Run every registered MLPL conformance test:

```sh
./scripts/run-tests
```

The root `mlplunit.conf` also enables native discovery and selection:

```sh
MLPL=../sw-mlpl/target/release/mlpl-repl \
  ../../softwarewrighter/mlplunit/bin/mlplunit --config mlplunit.conf
./scripts/run-tests --format tap
./scripts/run-tests --list
./scripts/run-tests tests/deques
```

Tests use native `include`, named/tagged `@test` discovery, and
explicit `u:run_registered_tests()`. Reusable tested implementations live in
`src/`; demos and tests include the same definitions, preventing test/demo
drift. All 85 registered test files and all 92 demos now share production
sources. See
`docs/mlplunit-migration.md` for the inventory.

With current sw-MLPL native test events, the 73 files report 136 individual
tests and parameter rows in both human and TAP output. Files that still expose
one broad `test_contract` are valid native suites, but remain candidates for
finer-grained names and failure isolation.

### Test report formats

Human reporting is console text: one `TEST` line per file, one named `PASS` or
`FAIL` line per native test/case, diagnostics for failures, and a final summary.
It does not create an HTML or text file automatically:

```sh
./scripts/run-tests
```

TAP 13 is also written to the console and contains one numbered record per
native test or parameter row:

```sh
./scripts/run-tests --format tap
```

Redirect either stream when a persistent artifact is needed:

```sh
./scripts/run-tests > test-report.txt 2>&1
./scripts/run-tests --format tap > test-report.tap 2>&1
```

Current captured examples are tracked as
[human console output](docs/mlplunit-human-sample.lst) and
[TAP output](docs/mlplunit-tap-sample.lst). They were generated from the full
passing suite on 2026-08-08.

Run the harness contract tests, including proof that a final `Err` exits
nonzero:

```sh
./tests/test-harness
```

Audit native registration, shared-source adoption, config discovery, and
catalog agreement:

```sh
./scripts/check-mlplunit-adoption
```

To use a binary in another location, set `MLPL` for either runner:

```sh
MLPL=/absolute/path/to/mlpl-repl ./scripts/run-all
MLPL=/absolute/path/to/mlpl-repl ./scripts/run-tests
MLPL=/absolute/path/to/mlpl-repl ./tests/test-harness
```

To use another mlplunit checkout or installation:

```sh
MLPLUNIT=/absolute/path/to/mlplunit ./scripts/run-tests
```

Test files follow mlplunit's `test_*.mlpl` discovery convention. Directly
running a test with `mlpl-repl` alone no longer works because the assertion
prelude is deliberately supplied by mlplunit.

All scripts run in terminal script mode without the web UI.

## Currently working scripts

These conformance tests are currently registered and pass against the baseline
interpreter:

| Script | Structure and algorithm | Kind |
|---|---|---|
| `tests/vectors/test_array_memory.mlpl` | Vector read, pure write, and swap | Conformance test |
| `tests/vectors/test_growable_vector.mlpl` | Immutable append and pop | Conformance test |
| `tests/vectors/test_chunked_vector.mlpl` | Chunked append, capacity growth, and indexed read | Conformance test |
| `tests/vectors/test_campaign_goal.mlpl` | Prefix sum and first goal-reaching day | Conformance test |
| `tests/stacks/test_browser_back_history.mlpl` | Immutable LIFO push/pop | Conformance test |
| `tests/queues/test_printer_jobs.mlpl` | Immutable FIFO enqueue/dequeue | Conformance test |
| `tests/deques/test_service_desk.mlpl` | Immutable operations at both ends | Conformance test |
| `tests/linked_lists/test_delivery_route.mlpl` | Index-backed insert-after and traversal | Conformance test |
| `tests/linked_lists/test_indexed_doubly_linked_route.mlpl` | Bidirectional insertion/deletion, reciprocal invariants, stale handles, and cycle rejection | Conformance test |
| `tests/persistent_lists/test_alert_feed.mlpl` | Immutable prepend and recursive traversal | Conformance test |
| `tests/persistent_lists/test_alert_feed_expiry.mlpl` | Immutable pop/drop, positional removal, cutoff filtering, and retained versions | Conformance test |
| `tests/search/test_linear_search.mlpl` | First match in an unsorted vector | Conformance test |
| `tests/search/test_binary_search.mlpl` | Logarithmic lookup in a sorted vector | Conformance test |
| `tests/search/test_lower_bound.mlpl` | First legal sorted insertion position | Conformance test |
| `tests/sequences/test_reverse.mlpl` | Recursive immutable numeric reversal | Conformance test |
| `tests/sorts/test_insertion_sort.mlpl` | Stable insertion sort over parallel vectors | Conformance test |
| `tests/sorts/test_merge_sort.mlpl` | Stable merge sort over parallel vectors | Conformance test |
| `tests/heaps/test_priority_queue.mlpl` | Dense min-heap insert/remove and invariants | Conformance test |
| `tests/sorts/test_heap_sort.mlpl` | Heap sort delegated to min-heap operations | Conformance test |
| `tests/sets/test_bit_set.mlpl` | Bounded numeric set membership and updates | Conformance test |
| `tests/maps/test_direct_address_map.mlpl` | Bounded integer-key map operations | Conformance test |
| `tests/hashing/test_numeric_hash.mlpl` | Deterministic bounded integer mixing | Conformance test |
| `tests/maps/test_open_address_map.mlpl` | Fixed-capacity linear-probing hash map | Conformance test |
| `tests/maps/test_hash_tombstones.mlpl` | Deletion, chain preservation, and tombstone reuse | Conformance test |
| `tests/maps/test_hash_resize.mlpl` | Load-factor growth and live-entry rehash | Conformance test |
| `tests/maps/test_separate_chaining.mlpl` | Indexed-node separate chaining, deletion, and resize | Conformance test |
| `tests/caches/test_numeric_lru.mlpl` | Numeric lookup plus doubly linked LRU recency | Conformance test |
| `tests/trees/test_binary_tree_representations.mlpl` | Record/indexed tree parity, traversal, and validation | Conformance test |
| `tests/trees/test_persistent_bst.mlpl` | Persistent BST search, insert, replacement, and invariants | Conformance test |
| `tests/trees/test_persistent_bst_delete.mlpl` | Persistent leaf, one-child, and two-child deletion | Conformance test |
| `tests/trees/test_persistent_avl.mlpl` | Persistent AVL insertion, rotations, heights, and balance | Conformance test |
| `tests/trees/test_order_statistic_avl.mlpl` | Persistent AVL rank/select, cached sizes, rotations, and retained roots | Conformance test |
| `tests/trees/test_interval_tree.mlpl` | Half-open overlap search, AVL rotations, cached maximum endpoints, and retained roots | Conformance test |
| `tests/trees/test_segment_tree.mlpl` | Half-open range sum/minimum, persistent point updates, and aggregate validation | Conformance test |
| `tests/trees/test_fenwick_tree.mlpl` | Compact cumulative sums, point-add updates, range queries, and internal validation | Conformance test |
| `tests/trees/test_numeric_digit_trie.mlpl` | Persistent digit keys, exact/longest-prefix lookup, and arena validation | Conformance test |
| `tests/trees/test_btree_page_index.mlpl` | Persistent 2-3-tree search/insertion, page splits, root growth, and invariants | Conformance test |
| `tests/trees/test_btree_page_deletion.mlpl` | Persistent deletion, predecessor replacement, borrowing, merging, and root contraction | Conformance test |
| `tests/linked_lists/test_indexed_skip_list.mlpl` | Deterministic skip levels, stable handles, insertion/deletion, ordering, and validation | Conformance test |
| `tests/matrices/test_sparse_csr.mlpl` | COO normalization, CSR validation, sparse matvec, transpose, and dense oracles | Conformance test |
| `tests/matrices/test_sparse_composition.mlpl` | CSR addition/multiplication, zero cancellation, dimensions, and dense oracles | Conformance test |
| `tests/trees/test_expression_tree.mlpl` | Closed tagged expression evaluation and error cases | Conformance test |
| `tests/graphs/test_graph_representations.mlpl` | Edge-list, matrix, and CSR representation parity | Conformance test |
| `tests/graphs/test_bfs_dfs.mlpl` | Deterministic BFS/DFS, levels, parents, and cycle termination | Conformance test |
| `tests/graphs/test_cycle_topological.mlpl` | Directed cycle detection and Kahn topological ordering | Conformance test |
| `tests/graphs/test_scc.mlpl` | Kosaraju strongly connected component labeling | Conformance test |
| `tests/graphs/test_union_find.mlpl` | Immutable union by rank and path compression | Conformance test |
| `tests/graphs/test_shortest_paths.mlpl` | Dijkstra/Bellman–Ford parity, policy, and reconstructed paths | Conformance test |
| `tests/graphs/test_floyd_warshall.mlpl` | Floyd–Warshall all-pairs distances, cycles, and reconstructed paths | Conformance test |
| `tests/graphs/test_kruskal.mlpl` | Kruskal normalization, deterministic forest selection, and union-find agreement | Conformance test |
| `tests/algorithms/dynamic_programming/test_coin_change_knapsack.mlpl` | Coin-change and 0/1-knapsack optimality, reconstruction, and edge policies | Conformance test |
| `tests/algorithms/dynamic_programming/test_numeric_lcs.mlpl` | Numeric LCS optimality, deterministic reconstruction, and table invariants | Conformance test |
| `tests/algorithms/greedy/test_interval_scheduling.mlpl` | Earliest-finish interval policies, optimality, and compatibility | Conformance test |
| `tests/algorithms/sequence/test_seeded_sampling.mlpl` | Deterministic Fisher–Yates and reservoir-sampling policies | Conformance test |
| `tests/patterns/adapter/test_transit_departure_adapter.mlpl` | Edge-list/CSR parity and target-only consumer behavior | Conformance test |
| `tests/patterns/prototype/test_transit_service_prototype.mlpl` | Retained prototypes and independent derived graph variants | Conformance test |
| `tests/patterns/flyweight/test_shipment_type_table.mlpl` | Shared intrinsic-table reuse, lookup, and boundary policies | Conformance test |
| `tests/patterns/memento/test_room_plan_history.mlpl` | Snapshot restoration, multi-step undo, retention, and boundaries | Conformance test |
| `tests/patterns/composite_interpreter/test_shipping_quote_rules.mlpl` | Part-whole structure and closed interpretation policies | Conformance test |
| `tests/patterns/state/test_incident_workflow.mlpl` | Deterministic state transitions, effects, and invalid policies | Conformance test |
| `tests/patterns/iterator/test_numeric_iterator.mlpl` | Traversal, independent cursors, exhaustion, and consumer policies | Conformance test |
| `tests/patterns/strategy/test_shipping_service_strategy.mlpl` | Injected policy substitutability, stable ties, and validation | Conformance test |

`catalog/demos.tsv` drives `scripts/run-all`; `catalog/tests.tsv` drives
`scripts/run-tests`. The demo catalog lists only result-oriented mini-apps.

Every `def u:name(...)` begins with a string expression documenting the
function's intent. sw-MLPL exposes that doc string through `:fns`,
`:describe u:name`, and `:list u:name`. For example:

```mlpl
def u:pop_front(deque) {
  "Remove the front item and return the resulting structure.";
  deque
}
```

Run `./scripts/check-docstrings` to audit the entire demo and test corpus.
Both `scripts/run-all` and `scripts/run-tests` invoke this audit, so new
undocumented helpers fail routine validation.

### Working mini-app demos

| Demo | Problem solved | Data structure and algorithm |
|---|---|---|
| `demos/vectors/campaign_goal.mlpl` | Find the first day cumulative donations reach a fundraising goal | Growable vector, prefix sum, and first matching index |
| `demos/stacks/browser_back_history.mlpl` | Return to the correct page after pressing a browser Back button twice | Immutable stack with LIFO push/pop |
| `demos/queues/printer_jobs.mlpl` | Process shared-printer jobs fairly in arrival order | Immutable queue with FIFO enqueue/dequeue |
| `demos/deques/service_desk.mlpl` | Serve urgent requests first without reversing regular arrivals | Immutable deque with insertion/removal at both ends |
| `demos/linked_lists/delivery_route.mlpl` | Insert an urgent delivery stop without shifting existing logical nodes | Index-backed singly linked list with insert-after and traversal |
| `demos/linked_lists/editable_delivery_route.mlpl` | Insert, extend, and cancel route stops while preserving dispatch history | Indexed doubly linked list with stable handles and reciprocal traversal |
| `demos/persistent_lists/alert_feed.mlpl` | Show newest alerts while retaining an earlier audit snapshot | Persistent immutable cons list with prepend and recursive traversal |
| `demos/persistent_lists/expiring_alert_feed.mlpl` | Remove expired alerts without changing an audit snapshot | Persistent immutable cons list with recursive stable filtering |
| `demos/search/linear_inventory_lookup.mlpl` | Locate a part on an unsorted shelf | Recursive linear search |
| `demos/search/binary_appointment_lookup.mlpl` | Determine whether an appointment time is reserved | Recursive binary search |
| `demos/search/lower_bound_scoreboard.mlpl` | Insert a tied score before existing equals | Recursive lower bound plus pure insertion |
| `demos/sequences/return_route.mlpl` | Derive a return route from outbound checkpoints | Recursive immutable reversal |
| `demos/sorts/stable_task_order.mlpl` | Order tasks by priority while retaining FIFO ties | Stable recursive insertion sort over parallel vectors |
| `demos/sorts/stable_delivery_merge.mlpl` | Order deliveries by ETA while retaining dispatch order for ties | Stable recursive merge sort over parallel vectors |
| `demos/heaps/incident_priority_queue.mlpl` | Dispatch incidents by numeric urgency | Priority queue delegated to a dense binary min-heap |
| `demos/sorts/batch_duration_heap_sort.mlpl` | Report batch durations shortest-first | Heap sort delegated to dense min-heap operations |
| `demos/sets/feature_flag_bit_set.mlpl` | Enable and retire bounded numeric feature flags | Bit-set mask membership, set, and clear |
| `demos/maps/warehouse_direct_map.mlpl` | Track quantities for bounded warehouse bin IDs | Direct-address insert, update, lookup, and remove |
| `demos/hashing/device_worker_assignment.mlpl` | Assign device IDs reproducibly to worker buckets | Signed normalization and deterministic integer mixing |
| `demos/maps/sparse_meter_hash_map.mlpl` | Store sparse meter readings with colliding IDs | Open addressing with recursive linear probing |
| `demos/maps/meter_tombstone_reuse.mlpl` | Remove a colliding meter without breaking later lookups | Tombstone deletion and first-tombstone reuse |
| `demos/maps/growing_meter_hash_map.mlpl` | Grow a sparse meter map while preserving readings | 75% threshold growth and recursive rehash |
| `demos/maps/chained_sensor_registry.mlpl` | Maintain a collision-heavy sensor registry | Indexed bucket chains, deletion, and load-driven rehash |
| `demos/caches/recent_route_cache.mlpl` | Retain three recently used numeric route results | Lookup composed with indexed doubly linked promotion and eviction |
| `demos/trees/team_hierarchy_traversals.mlpl` | Report a numeric team hierarchy in three orders | Record/indexed conversion with recursive preorder, inorder, and postorder |
| `demos/trees/persistent_reservation_index.mlpl` | Maintain reservations while retaining an audit snapshot | Persistent BST search and path-rebuilding insert |
| `demos/trees/persistent_reservation_cancellation.mlpl` | Cancel reservations while retaining the morning audit | Persistent structural deletion with successor replacement |
| `demos/trees/balanced_dispatch_index.mlpl` | Index adversarially ordered dispatch times | Persistent AVL insertion with cached heights and rotations |
| `demos/trees/live_leaderboard_rank.mlpl` | Place a score and answer rank/select queries while retaining a published board | Order-statistic AVL with cached subtree sizes |
| `demos/trees/appointment_conflicts.mlpl` | Detect a reservation conflict without scanning the schedule | Augmented AVL interval tree with maximum-endpoint pruning |
| `demos/trees/warehouse_range_analytics.mlpl` | Revise one bin and compare live range analytics with an audit snapshot | Persistent segment tree with cached sum and minimum |
| `demos/trees/cumulative_shipments.mlpl` | Correct one day and compare cumulative live totals with an audit | Immutable Fenwick tree with prefix/range sums |
| `demos/trees/numeric_prefix_routing.mlpl` | Route a numeric account code through its most specific configured prefix | Indexed decimal-digit trie with ten-way child rows |
| `demos/trees/page_index.mlpl` | Grow a page-oriented numeric index while retaining its published root | Immutable order-three B-tree with median promotion |
| `demos/trees/page_index_retirement.mlpl` | Retire index entries without changing the published page index | Persistent 2-3-tree deletion with underflow repair |
| `demos/linked_lists/ordered_directory.mlpl` | Update and retire entries while retaining a published ordered directory | Indexed four-level skip list with deterministic heights |
| `demos/matrices/sparse_inventory_projection.mlpl` | Project sparse inventory totals and expose a transposed view | COO-to-CSR conversion, sparse matvec, and transpose |
| `demos/matrices/sparse_resource_composition.mlpl` | Compose sparse site-resource and resource-cost transformations | CSR addition and rectangular multiplication |
| `demos/trees/shipping_cost_expression.mlpl` | Calculate a numeric shipping-cost formula | Closed Composite/Interpreter expression tree with numeric tags |
| `demos/graphs/transit_network_representations.mlpl` | Query a cyclic directed transit network | Normalized weighted edge list converted to matrix and CSR |
| `demos/graphs/evacuation_bfs.mlpl` | Find reachable evacuation stations and minimum hops | Pure-queue breadth-first search with parents and levels |
| `demos/graphs/dependency_dfs.mlpl` | Inspect transitive dependencies deeply | Recursive depth-first preorder with visited-mask termination |
| `demos/graphs/dependency_cycle_and_order.mlpl` | Schedule a DAG or report its blocking cycle | Recursion-stack colors plus pure-queue Kahn ordering |
| `demos/graphs/service_clusters_scc.mlpl` | Group mutually reachable services for recovery | Recursive Kosaraju finish order, transpose, and labeling |
| `demos/graphs/network_components_union_find.mlpl` | Group devices by undirected connectivity | Pure find/compression plus deterministic union by rank |
| `demos/graphs/route_shortest_paths.mlpl` | Find and reconstruct the least-cost depot route | Dense Dijkstra cross-checked by Bellman–Ford |
| `demos/graphs/all_pairs_routes.mlpl` | Precompute least-cost routes between every pair of depots | Floyd–Warshall distance and next-hop matrices |
| `demos/graphs/network_cabling_kruskal.mlpl` | Connect sites with minimum total cable cost | Normalized edge list, deterministic sorting, and Kruskal union-find |
| `demos/graphs/a_star_route.mlpl` | Guide an optimal route toward one target | Deterministic A* cross-checked against Dijkstra |
| `demos/graphs/traveling_salesman.mlpl` | Visit every city and return to a fixed depot | Factorial and Held–Karp exact TSP versus nearest neighbor and 2-opt |
| `demos/graphs/capacitated_delivery_routes.mlpl` | Serve every customer without exceeding vehicle capacity | Exact order/split CVRP versus nearest-feasible greedy routing |
| `demos/graphs/warehouse_transfer_capacity.mlpl` | Maximize warehouse transfer and identify limiting hub links | Edmonds–Karp BFS plus residual minimum-cut certificate |
| `demos/graphs/technician_job_matching.mlpl` | Assign technicians to compatible jobs with maximum coverage | Deterministic bipartite augmenting paths cross-checked by maximum flow |
| `demos/graphs/technician_task_cost_assignment.mlpl` | Assign every technician while minimizing total effort | Hungarian primal-dual assignment cross-checked by exhaustive permutations |
| `demos/matrices/batch_machine_plan.mlpl` | Estimate every machine/batch pairing and route each batch independently | Partially configured scalar policy, `table` outer product, and column argmin |
| `demos/serialization/sensor_grid_envelope.mlpl` | Preserve a sensor grid's shape across a numeric-vector-only channel | Versioned, checksummed in-memory numeric envelope |
| `demos/serialization/json_delivery_dispatch.mlpl` | Configure a capacity-safe delivery dispatch from an external file | Sandboxed text read, budgeted typed JSON decode, validation, and prefix planning |
| `demos/serialization/json_dispatch_roundtrip.mlpl` | Persist and reload a validated delivery plan | Deterministic sorted-key JSON encode/write/read/decode/cleanup |
| `demos/serialization/toml_delivery_dispatch.mlpl` | Configure a capacity-safe delivery dispatch from a TOML file | Budgeted TOML-subset decode delegated to shared validation and prefix planning |
| `demos/serialization/toml_dispatch_roundtrip.mlpl` | Persist and reload a generated dispatch policy | Sorted TOML encode, atomic replacement, decode, validation, and cleanup |
| `demos/serialization/binary_device_command.mlpl` | Persist a compact warehouse-device command | Versioned checksummed packet with sandboxed raw-byte I/O |
| `demos/algorithms/dynamic_programming/making_change.mlpl` | Make an exact refund with the fewest coins | Unbounded coin-change DP with predecessor reconstruction |
| `demos/algorithms/dynamic_programming/loading_drone.mlpl` | Maximize delivered value within a drone capacity | 0/1-knapsack DP with take/skip reconstruction |
| `demos/algorithms/dynamic_programming/shared_event_trace.mlpl` | Find the longest ordered event trace shared by two runs | Numeric-token LCS with flat-table reconstruction |
| `demos/algorithms/greedy/meeting_room_schedule.mlpl` | Accept the most non-overlapping requests for one room | Deterministic earliest-finish interval scheduling |
| `demos/algorithms/backtracking/exhibit_queens.mlpl` | Place eight wireless exhibits without row, column, or diagonal interference | Deterministic left-first N-queens backtracking |
| `demos/algorithms/backtracking/exact_project_budget.mlpl` | Select signed adjustments that exactly match a target | Include-first zero-one subset-sum backtracking |
| `demos/algorithms/backtracking/sudoku_shift_roster.mlpl` | Complete a numeric shift roster under Sudoku constraints | Validated row-major, digit-ascending backtracking |
| `demos/algorithms/numeric/synchronize_maintenance.mlpl` | Align two repeating maintenance schedules | Euclidean GCD composed into an LCM |
| `demos/algorithms/numeric/prime_capacity_plan.mlpl` | List prime worker-pool capacities through 50 | Recursive Sieve of Eratosthenes |
| `demos/algorithms/numeric/compound_growth_power.mlpl` | Calculate repeated doubling over 20 periods | Exponentiation by squaring |
| `demos/algorithms/sequence/randomize_interview_order.mlpl` | Assign candidates a reproducible random interview order | Seeded Fisher–Yates shuffle |
| `demos/algorithms/sequence/audit_stream_sample.mlpl` | Retain a fixed-size reproducible audit selection | Seeded reservoir sampling without replacement |
| `demos/patterns/adapter/transit_departure_board.mlpl` | Feed a CSR departure-board consumer from a legacy edge-list graph | Pure functional Adapter |
| `demos/patterns/prototype/event_transit_service.mlpl` | Derive a special-event service without changing its weekday template | Immutable functional Prototype |
| `demos/patterns/flyweight/shipment_manifest.mlpl` | Resolve many order rows without repeating package-type attributes | Numeric functional Flyweight |
| `demos/patterns/memento/undo_room_plan.mlpl` | Undo an unsafe capacity edit while retaining earlier plans | Immutable functional Memento |
| `demos/patterns/composite_interpreter/shipping_quote_rules.mlpl` | Compose reusable quote parts and interpret the pricing rule | Closed Composite and Interpreter |
| `demos/patterns/state/incident_response_workflow.mlpl` | Evolve an incident while keeping effects outside transition logic | Closed functional State |
| `demos/patterns/iterator/maintenance_budget_iterator.mlpl` | Accept jobs in order while retaining the cursor at the first over-budget job | Explicit functional Iterator |
| `demos/patterns/strategy/shipping_service_policy.mlpl` | Select services through interchangeable economy, urgent, and balanced policies | First-class functional Strategy |
| `demos/patterns/factory/fulfillment_factory_method.mlpl` | Prepare one order through interchangeable fulfillment constructors | Functional Factory Method |
| `demos/patterns/factory/analytics_abstract_factory.mlpl` | Provision compatible local or remote analytics products | Fixed-record functional Abstract Factory |
| `demos/patterns/bridge/energy_meter_reporting.mlpl` | Report direct and scaled energy readings through one abstraction | Fixed-protocol functional Bridge |
| `demos/patterns/template_method/numeric_reporting_workflow.mlpl` | Run audit and capacity reports through one invariant workflow | Functional Template Method |
| `demos/patterns/decorator/shipping_quote_layers.mlpl` | Add surcharge and insurance without editing a base quote | Functional Decorator with explicit environments |
| `demos/patterns/proxy/inventory_access_proxy.mlpl` | Protect inventory reads while returning explicit access state/effects | Functional protection Proxy |
| `demos/patterns/command/account_commands.mlpl` | Execute account requests carrying behavior, arguments, and environment | Fixed-schema functional Command |
| `demos/patterns/visitor/expression_visitors.mlpl` | Evaluate and count one expression tree through operation algebras | Fixed-algebra functional Visitor |
| `demos/patterns/builder/storage_plan.mlpl` | Assemble and validate a replicated-storage plan through retained drafts | Constrained functional Builder |
| `demos/patterns/facade/delivery_booking.mlpl` | Book delivery through validation, pricing, and fleet subsystems | Constrained functional Facade |
| `demos/patterns/chain/purchase_approval.mlpl` | Stop purchase routing at the first accepting handler | Fixed nested functional Chain of Responsibility |
| `demos/patterns/observer/sale_observers.mlpl` | Notify inventory and audit subscribers with immutable states/effects | Fixed functional Observer |
| `demos/patterns/mediator/order_mediator.mlpl` | Coordinate inventory and billing without direct participant coupling | Fixed functional Mediator |

The seeded-sampling demos use a small explicitly documented linear
congruential generator so examples and tests reproduce exactly. It is an
educational mechanism, not a cryptographic or production statistical RNG; its
modulo-to-bound mapping can introduce slight bias. A future delegated RNG
abstraction should provide unbiased bounded draws without coupling either
algorithm to one generator.

The graph corpus currently comprises eleven mini-apps and ten conformance
scripts, all with zero explicit loops. Cross-checks are intentionally embedded
where the implementations share a contract: BFS and DFS agree on reachability,
cycle detection governs whether topological ordering succeeds, SCC labels agree
with mutual reachability, Dijkstra and Bellman–Ford agree on nonnegative input,
each applicable Floyd–Warshall source row agrees with the single-source
fixture, and Kruskal connectivity agrees with union-find. Numeric node IDs make
logical cycles ordinary application-managed data rather than runtime reference
cycles.

## Planned repository shape

```text
demos/               # problem-solving mini-apps, grouped by data structure
  caches/
  vectors/
  stacks/
  queues/
  linked_lists/
  persistent_lists/
  search/
  sequences/
  sorts/
  heaps/
  sets/
  maps/
  hashing/
  hash_tables/
  trees/
  graphs/
  algorithms/backtracking/
tests/               # assertion/pass-fail scripts in matching subdirectories
  vectors/
  stacks/
  queues/
  linked_lists/
  persistent_lists/
  search/
  sequences/
  sorts/
  heaps/
  sets/
  maps/
  hashing/
  hash_tables/
  trees/
  graphs/
  algorithms/backtracking/
src/                 # includable production definitions shared by demos/tests
catalog/             # demo and test inventories
scripts/             # validation and execution harnesses
docs/                # analysis and plans
```

sw-MLPL static `include` and mlplunit's configured source sandbox now let demos
and tests execute the same production definitions from `src/`. The deque slice
already uses this layout; the remaining corpus is migrating in bounded domain
batches. Future full modules are still useful for qualified namespaces,
exports, privacy, and evaluate-once identities, but no longer block source
sharing or native testing.

## Copyright and license

Copyright (c) 2026 Michael A Wright. See [COPYRIGHT](COPYRIGHT).

This project is available under the [MIT License](LICENSE).
