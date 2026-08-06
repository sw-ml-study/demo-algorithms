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

Verified baseline: `mlpl-repl 0.20.0`, local build commit `3cc61287`
(2026-08-06), with mlplunit `0.1.0` at commit `6f7ac47`.

The repository now contains 49 working mini-apps and 47 conformance-test
files, reporting 60 native tests and parameter cases, as well as the longer
implementation plan. See
[PLAN.md](PLAN.md) for the taxonomy, capability analysis, proposed file tree,
feature gaps, and delivery sequence. [DESIGN_PATTERNS.md](DESIGN_PATTERNS.md)
maps all 23 Gang of Four patterns to functional sw-MLPL forms, and
[MEMORY_DESIGN.md](MEMORY_DESIGN.md) analyzes dynamic values without
`malloc`/`free`, a language borrow checker, or a mandatory tracing GC.
The dated [dynamic-sequence foundation report](docs/dynamic-sequence-report.md)
summarizes executable evidence, loop counts, and remaining gaps.
The [search/sort/priority report](docs/search-sort-priority-report.md) records
the second saga's coverage, complexities, zero-loop result, and module evidence.
The [algorithm survey closeout](docs/algorithm-survey-report.md) audits twelve
representative algorithms, their boundary policies and costs, and the language
improvements they motivate.

## Scripts: demos versus tests

This repository uses two distinct kinds of `.mlpl` script:

- **Demos** are small applications. Each states a concrete problem, explains
  the data structure and algorithm used to solve it, and produces a meaningful
  result for a reader to inspect.
- **Tests** are assertion-heavy conformance scripts. Their product is a final
  `Ok(...)` or `Err(...)`, and the harness treats that result as pass/fail.

The original assertion-heavy scripts live under `tests/`; result-oriented
mini-apps live under `demos/` with matching conformance coverage.

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
drift. All 47 registered test files and all 49 demos now share production
sources. See
`docs/mlplunit-migration.md` for the inventory.

With current sw-MLPL native test events, the 47 files report 60 individual
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
passing suite on 2026-08-06.

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
| `tests/persistent_lists/test_alert_feed.mlpl` | Immutable prepend and recursive traversal | Conformance test |
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
| `demos/persistent_lists/alert_feed.mlpl` | Show newest alerts while retaining an earlier audit snapshot | Persistent immutable cons list with prepend and recursive traversal |
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

The seeded-sampling demos use a small explicitly documented linear
congruential generator so examples and tests reproduce exactly. It is an
educational mechanism, not a cryptographic or production statistical RNG; its
modulo-to-bound mapping can introduce slight bias. A future delegated RNG
abstraction should provide unbiased bounded draws without coupling either
algorithm to one generator.

The graph corpus currently comprises nine mini-apps and eight conformance
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
