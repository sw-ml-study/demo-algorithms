# AgentRail Saga Queue: Currently Implementable Demos

Only one AgentRail saga is active at a time. This queue partitions the
currently implementable work from [plan.md](plan.md) into sequential sagas.
No saga below requires a change to sw-MLPL.

## Saga 1 — `dynamic-sequence-foundations`

Goal: establish the script harness and prove dynamically growing/shrinking
pure data structures on the current binary.

Steps:

1. `harness-contract` — add catalog schema, runner, passing/failing fixtures,
   and pinned/current binary configuration. Completed; conformance execution
   now delegates to mlplunit with shared assertions and isolated processes.
2. `array-memory` — pure array read/write/swap helpers and invariant idioms.
3. `growable-vector` — append/remove with dynamic logical size and copy-cost
   notes.
4. `chunked-vector` — capacity versus size and chunk addressing.
5. `stack-queue-deque` — storage-delegating stack, ring queue, and deque.
6. `indexed-linked-lists` — singly/doubly linked application arenas with
   numeric handles and validators.
7. `persistent-cons-list` — recursive immutable-record list, retained old
   versions, and explicit structural-sharing limitation.
8. `close-dynamic-sequences` — run full suite, publish catalog/loop report,
   update capability notes.

## Saga 2 — `search-sort-priority`

1. Linear search, binary search, and lower bound.
2. Numeric reverse with loop accounting.
3. Insertion sort and `grade_up` oracle.
4. Merge sort using index bounds rather than unavailable slices.
5. Binary heap and priority queue.
6. Heap sort by delegation to heap operations.
7. Cross-demo boundary/duplicate/negative fixtures and closeout.

## Saga 3 — `numeric-associative-structures`

1. Bit set and direct-address map.
2. Integer mixing/hash golden fixtures.
3. Open addressing with collision and duplicate-key behavior.
4. Delete/tombstone behavior.
5. Dynamic resize and rehash.
6. Separate chaining with indexed nodes.
7. Numeric LRU composition and invariant audit.

## Saga 4 — `persistent-tree-baselines`

1. Record and indexed binary-tree representations.
2. Recursive and iterative traversals.
3. Persistent BST search/insert with old-root tests.
4. Persistent BST deletion.
5. AVL rotations, insert, height, and balance validation.
6. Tagged numeric expression tree.
7. Closed Composite/Interpreter baselines and copy-cost report.

## Saga 5 — `graph-algorithms`

1. Adjacency matrix, edge list, and CSR representations.
2. BFS and DFS using prior queue/stack contracts, migrated to shared `src/`
   definitions through shipped static include.
3. Logical cycle detection and topological sort.
4. Strongly connected components.
5. Union-find with rank and path compression.
6. Dense Dijkstra and Bellman-Ford cross-check.
7. Floyd-Warshall cross-check.
8. Kruskal using grading plus union-find.
9. Graph invariant suite and closeout.

## Saga 6 — `algorithm-survey`

Status: complete. See [algorithm-survey-report.md](algorithm-survey-report.md).

1. Coin change and knapsack.
2. Numeric-token LCS.
3. Interval scheduling.
4. N-queens and subset sum.
5. Numeric Sudoku.
6. GCD, sieve, and fast power.
7. Fisher–Yates and reservoir sampling.
8. Survey closeout and explicit-loop classification.

## Saga 7 — `functional-gof-baselines`

Status: complete. Adapter, Prototype, Flyweight, Memento, closed
Composite/Interpreter, closed State, and explicit Iterator are executable and
tested. See [gof-baseline-report.md](gof-baseline-report.md) for the full
23-pattern feature-gated matrix.

1. Adapter through graph representation conversion.
2. Prototype through retained graph versions.
3. Flyweight through a shared numeric table and IDs.
4. Memento through immutable state history.
5. Closed Composite and Interpreter case study.
6. Closed State transition case study.
7. Explicit Iterator baseline.
8. Document why opcode-based approximations do not complete the other GoF
   patterns; publish the feature-gated matrix.

## Completed migration — `native-mlplunit-source-sharing`

sw-MLPL static include and mlplunit's complete native test surface have
shipped. The completed bounded migration batches:

1. extract reusable definitions under `src/`;
2. make demos and tests include the same production definitions;
3. replace copied implementations and monolithic tests with named `@test`
   registry suites;
4. use `@cases` and bracket lifecycle where they honestly improve the tests;
5. verify human/TAP parity, failure continuation, source diagnostics, and
   catalog selection.

A later full-module saga remains feature-gated for namespaces, exports,
privacy, evaluate-once identity, and module-cycle policy. Those features are
not blockers for current native source sharing or mlplunit adoption.

## Cross-saga rules

- Tests are deterministic `test_*.mlpl` assertion/pass-fail scripts under
  `tests/`, executed through mlplunit.
- Demos are problem-solving mini-apps under `demos/`; they explain the problem,
  data structure, algorithm, and meaningful result.
- Tests precede or accompany demo implementation in the same step.
- Each script records representation, invariant, dynamic behavior, logical
  complexity, current copy complexity, explicit loops, target loops, and
  missing loop-removal feature.
- A final test `Err` must fail the test runner.
- Builtins may serve as primitives or correctness oracles, not substitutes for
  the demonstrated algorithm.
- Strings are static diagnostics only.
- Logical cycles use application-managed numeric handles/arenas.
- Do not modify `../sw-mlpl` in these sagas.
- If a demo unexpectedly needs a language change, leave it gated, record the
  exact gap, and continue with other in-scope demos.
