# sw-MLPL General-Purpose Algorithms: Capability Analysis

## Purpose and baseline

This repository tests whether sw-MLPL can serve as a compositional,
general-purpose array language—not merely whether a `while` loop can simulate
an imperative language. The distinguishing goals are:

- dynamically sized logical data structures;
- pure functions and immutable values;
- Clojure-style structural sharing where practical;
- function composition and delegation instead of object inheritance;
- few explicit loops, ideally none where an array combinator is natural;
- loose coupling and honest implementations of all 23 Gang of Four patterns;
- clear identification of language gaps exposed by executable demos.

This analysis uses sw-MLPL commit `16940f5d` from 2026-08-05 as its baseline.
Relevant current capabilities include dense numeric arrays, `concat`, `take`,
`scatter`, records, Results, user-defined functions, recursion, `if`, `while`,
`for`, sorting indices, compression, reductions, CLI arguments, and basic
script I/O. Strings exist chiefly as opaque messages and labels; they are not
yet a general sequence type.

## What “dynamic” means here

A structure is dynamically sized when its logical size can grow or shrink at
runtime and operations return a new valid value. It need not expose heap
pointers or mutation. Current representations can include:

- packed numeric arrays grown with `concat`;
- fixed or growing application-owned arenas addressed by numeric handles;
- parallel arrays such as `values`, `next`, `prev`, and `used`;
- chunked rectangular arrays plus a logical length;
- nested immutable records for lists and trees;
- CSR arrays for variable-degree graphs.

Current sw-MLPL can express these semantics, but array updates and nested
record reconstruction may copy whole values. Persistent structures therefore
preserve old versions semantically without yet providing efficient structural
sharing.

Logical cycles are already representable through numeric IDs or handles.
Future direct strong-reference cycles should be supported and diagnosed by the
compiler/linter, not prohibited. With reference counting and no cycle
collector, leaks or exhaustion caused by unreachable strong cycles are
application bugs.

## Scripts implementable today

The capabilities below support both conformance tests and problem-solving
mini-apps. Assertion-heavy scripts belong under `tests/`; `demos/` is reserved
for scripts that state a problem, apply a data structure and algorithm, and
show the resulting solution.

### Dynamic linear structures

| Demo | Representation | Principal constraint |
|---|---|---|
| Growable vector | vector + `concat` | Append copies |
| Chunked vector | rank-2 chunks + logical length | Reallocation and indexing are verbose |
| Stack | delegated sequence + logical size | No modules for reusable storage protocol |
| Ring queue/deque | buffer, head, tail, size | Functional updates copy buffers |
| Singly linked list | parallel `value`/`next` arrays | Integer handles rather than references |
| Doubly linked list | parallel `value`/`prev`/`next` arrays | Same |
| Persistent cons list | nested records | No structural sharing; recursion required |
| History/undo | vector or retained roots | Copies can make snapshots expensive |

### Numeric associative structures

- bit set and bounded integer set;
- linear-search set/map;
- direct-address table;
- open-addressed numeric hash map;
- linear/quadratic probing and tombstones;
- dynamic resize and rehash;
- separate chaining through index-backed nodes;
- numeric-key LRU policy using an index-backed doubly linked list.

These cannot yet accept user-supplied hash/equality policies. String-keyed and
heterogeneous maps are blocked by the string and value models.

### Trees and priority structures

- binary trees using records or indexed arenas;
- recursive and iterative preorder/inorder/postorder traversals;
- binary search tree search, insert, and delete;
- binary heap and priority queue;
- heap sort;
- AVL insertion, rotations, and invariant checking;
- numeric tagged expression trees;
- application-owned cyclic arenas using integer handles.

Persistent BST and AVL implementations are honest semantic demos today, but
record rebuilding is verbose and unchanged subtrees may be copied.

### Graph structures and algorithms

- adjacency matrices, edge lists, and CSR graphs;
- BFS, DFS, cycle detection, and connected components;
- strongly connected components and topological sort;
- union-find with union by rank and path compression;
- Dijkstra, Bellman-Ford, and Floyd-Warshall;
- Prim and Kruskal minimum spanning trees;
- A*, bipartite testing, maximum flow, and random walks.

Graph cycles do not require cyclic runtime references. Node IDs and edge arrays
let the complete graph remain one automatically managed value.

The completed current-language baseline is narrower and concrete: nine
problem-solving graph mini-apps plus eight mlplunit scripts cover edge-list,
matrix, and CSR conversion; BFS/DFS; directed cycle detection and topological
ordering; Kosaraju SCCs; union-find; Dijkstra/Bellman–Ford; Floyd–Warshall; and
Kruskal minimum spanning forests. All nine demos use zero explicit loops.
Their conformance fixtures cross-check reachability between BFS/DFS, DAG status
between cycle detection/topological ordering, mutual reachability within SCCs,
nonnegative single-source distances between Dijkstra/Bellman–Ford, applicable
single-source rows against Floyd–Warshall, and final Kruskal connectivity
against union-find.

This corpus reinforces, rather than changes, the ranked gaps below. General
point updates and record update syntax would remove state-rebuild boilerplate;
first-class UDFs/folds would express neighbor and relaxation policies without
recursive local control code; static modules/imports would eliminate copied
graph, queue, sorting, and union-find helpers; and COW buffers or scoped
transients would avoid whole-vector/matrix copies during otherwise efficient
logical updates. Deep recursion remains application-bounded until reliable
tail calls or stack-safe folds exist. Cycle linting should distinguish valid
numeric graph cycles from future ownership cycles and remain advisory.

### General algorithms

- linear and binary search, lower/upper bound;
- numeric reverse, rotate, partition, and deduplication;
- bubble, insertion, selection, shell, heap, merge, quick, counting, and
  nonnegative-integer radix sort;
- prefix sums/products;
- GCD, sieve, fast exponentiation, and matrix exponentiation;
- coin change, knapsack, numeric-token LCS/edit distance;
- interval scheduling;
- N-queens, subset sum, and numeric Sudoku;
- Fisher–Yates shuffle and reservoir sampling.

Most require explicit loops or recursion today because UDFs cannot be supplied
to general `map`, `fold`, `scan`, or `unfold` operations.

The algorithm survey now has executable unbounded coin-change and 0/1-knapsack
baselines. Recursive bottom-up table construction and deterministic solution
reconstruction need no explicit loops, but immutable growth copies partial
tables and helper definitions are duplicated between demos and tests. This is
additional evidence for general point updates/COW builders, UDF-capable folds,
and static modules; neither algorithm requires manual allocation or a garbage
collector.

### GoF patterns available today

Honest closed or numeric demonstrations:

- Adapter;
- Prototype;
- Flyweight;
- Memento;
- closed tagged-record Composite;
- closed numeric/tagged Interpreter;
- closed State transition system;
- explicit stateful Iterator baseline.

Hard-coded opcodes or strategy tags are useful baseline comparisons, but do
not count as complete Strategy, Command, Visitor, Factory, or Observer
implementations because their clients are not open to delegated behavior.

## Demos requiring language/runtime changes

### Behavioral composition

Preferred implementations of Abstract Factory, Factory Method, Bridge,
Decorator, Proxy, Chain of Responsibility, Command, Mediator, Observer,
Strategy, Template Method, and Visitor require first-class UDFs. Reusable
Iterator and Composite folds also need higher-order combinators.

### String-oriented data structures and algorithms

The following require strings to become sequence values:

- string-keyed hash tables and sets;
- tries and radix trees over text;
- KMP, Boyer–Moore, Rabin–Karp, and ordinary substring search;
- tokenization, parsers, and text interpreters written in MLPL;
- address books, inventories, and formatted reports keyed by names;
- string sorting, comparison, and user-defined string hashing.

### Efficient persistent structures

The following are semantically approximable today but require runtime
structural sharing for their intended performance:

- persistent vector;
- persistent queue/deque;
- persistent BST/AVL/red-black tree;
- persistent hash map/HAMT;
- cheap Memento histories;
- shared Composite/AST subtrees.

### Direct reference cycles

Direct self-referential records, mutually capturing closures, parent/child
strong links, and callback registries that capture themselves require
reference-bearing values and defined capture semantics. They also require
cycle linting and retained-memory diagnostics. Automatic cycle reclamation is
not required by the language contract.

## Feature prioritization method

Features are ordered by practical return, not conceptual grandeur. Scores are
relative, 1–5:

- **Reach:** number and importance of demos unlocked;
- **Frequency:** likelihood ordinary MLPL programs use the feature;
- **Ease:** expected implementation/design tractability; 5 is easiest;
- **Leverage:** improvement to composition, clarity, or performance.

Dependencies override raw scores: a combinator accepting UDFs depends on
first-class UDF values. The final ordering progresses from low-hanging,
high-frequency improvements through larger foundational investments and then
specialized capabilities.

## Ranked changes

The test harness no longer needs a language change to share assertions:
mlplunit prepends its assertion library and runs each test in a fresh process.
This is useful today, but source concatenation is a tooling bridge rather than
a replacement for language-level modules. Static modules remain rank 5 because
they enable demos and tests to share the actual data-structure and algorithm
implementations with namespaces, privacy, and source-aware diagnostics.

The completed tree corpus sharpens these priorities. Five tree mini-apps and
five matching tests run with zero explicit loops, so recursion itself is not a
blocker. The dominant friction is verbose full-record reconstruction (rank 2),
duplicated helpers without modules (rank 5), and the inability to verify or
obtain physical subtree sharing (rank 9). Numeric expression tags work as a
closed baseline, while variants/pattern matching (rank 10) and first-class
function algebras (ranks 3–4) gate open Composite, Interpreter, and Visitor.

| Rank | Change | Reach | Frequency | Ease | Leverage | Rationale |
|---:|---|---:|---:|---:|---:|---|
| 1 | General pure `put` plus multi-index gather and slice ranges | 5 | 5 | 4 | 5 | Removes update/indexing boilerplate from nearly every structure and algorithm while preserving value semantics |
| 2 | Record update/spread and destructuring | 4 | 5 | 4 | 5 | Low-hanging syntax/AST work with immediate payoff for trees, builders, state, Results, and configuration pipelines |
| 3 | First-class named UDF references and uniform invocation | 5 | 5 | 3 | 5 | Foundation for delegation, loose coupling, policy injection, and most GoF patterns |
| 4 | UDF-capable `map`, `filter`, `fold`, short-circuit fold, `scan`, `unfold`, `zip`, `partition`, `flat_map` | 5 | 5 | 3 | 5 | Primary mechanism for eliminating loops; `unfold` directly constructs dynamic sequences |
| 5 | Static modules/imports with explicit exports and private helpers | 5 | 5 | 3 | 5 | Makes the corpus reusable and supports Facade, dependency inversion, and library boundaries; specify after real demos expose actual repetition |
| 6 | Function composition, application pipe, and partial binding | 4 | 5 | 3 | 5 | Turns first-class functions into readable pipelines; enables functional Decorator and Template Method idioms |
| 7 | Integer and boolean value types or checked integer/boolean surface | 5 | 5 | 2 | 4 | Algorithms use indices and predicates constantly; improves correctness and diagnostics but touches the value/type/runtime stack |
| 8 | Copy-on-write dense buffers | 4 | 5 | 3 | 4 | Preserves semantics while reducing common assignment and update copies; broadly useful to ML workloads too |
| 9 | Clojure-style structurally shared persistent collections | 5 | 4 | 1 | 5 | Essential to efficient dynamic immutable structures, but a substantial runtime/data-model project |
| 10 | Tagged variants/sum types with exhaustiveness checking | 4 | 4 | 2 | 4 | Clarifies lists, trees, ASTs, State, Command, Composite, and Interpreter |
| 11 | General numeric map/set value | 4 | 4 | 2 | 4 | Frequently useful and removes hand-built parallel-array maps; should accept delegated hash/equality policies |
| 12 | Cycle ownership/capture linter and retained-memory diagnostics | 3 | 3 | 2 | 4 | Required when reference-bearing closures/values arrive; warnings remain advisory and application-owned |
| 13 | Scoped transient/builder optimization | 3 | 3 | 2 | 4 | Speeds update-heavy pure pipelines without exposing a borrow checker; defer until profiling justifies it |
| 14 | Nested/general arrays | 4 | 3 | 1 | 5 | Unlocks ragged structures and APL2 depth, but is a major representation and serialization change |
| 15 | Mature strings as sequences | 4 | 4 | 1 | 4 | Necessary for text applications, tries, and string maps; broad but currently far from the numeric core |
| 16 | Text/array file I/O and formatting | 3 | 4 | 2 | 3 | Enables persistent applications and reports; should follow usable strings and capability-based resource handling |
| 17 | Structured serialization plus safe delegated codecs | 4 | 4 | 2 | 4 | Enables durable general-purpose values and format conversion after byte/text I/O; native format should preserve numeric types and shapes |
| 18 | Weak reference/handle conveniences for direct reference graphs | 2 | 2 | 1 | 3 | Useful for specialized cyclic ownership; numeric application arenas already cover graph algorithms |
| 19 | Optional cycle collection or tracing GC | 2 | 1 | 1 | 2 | Not required by the stated contract; application-created strong-cycle leaks remain application bugs |

### Why first-class functions are not ranked first

They have the greatest architectural impact, but `put`/gather/slice and record
update are smaller changes with immediate payoff to almost every executable
demo. First-class named UDF references are the first major language milestone
and should begin as soon as those two low-risk improvements are specified.

### Why structural sharing is below syntax and combinators

Structural sharing is central to the long-term dynamic-data story, but the
corpus can validate APIs and semantics using copying implementations first.
That executable evidence can guide whether the first shared structure should
be a COW vector, persistent vector trie, cons/tree node, or HAMT.

### Why modules are high priority but deliberately deferred

Modules/imports rank fifth by expected value, but should not block the first
mini-app corpus. Build approximately 6–10 genuine demos first, tolerate small
amounts of copied `u:` helper code, and measure what actually repeats. That
evidence defines the first useful library boundaries and prevents designing a
module system around hypothetical reuse.

Prefer static modules to textual `include`. A minimum viable design needs:

- imports resolved relative to the importing script;
- module namespaces, private-by-default definitions, and explicit exports;
- load/evaluate-once caching;
- import-cycle diagnostics showing the complete path;
- source filenames/spans preserved in parser and evaluator errors;
- a source-provider abstraction so CLI files and bundled web/WASM modules use
  one resolver contract;
- compatibility with future compile-to-Rust lowering.

It does not initially need packages, remote imports, version resolution,
dynamic imports, macros, or runtime string evaluation. If lightweight
`include` syntax is later offered, it should lower through this static module
loader rather than concatenate/evaluate arbitrary text.

## Design requirements applying to every change

- Preserve pure observable value semantics.
- Avoid user-visible `malloc`, `free`, ownership, or borrow annotations.
- Make functions and policies explicit dependencies rather than ambient state.
- Keep effects at program boundaries and return effect descriptions as data.
- Do not conflate logical graph cycles with runtime ownership cycles.
- Warn about ownership cycles without prohibiting valid applications.
- Treat memory exhaustion or leaks from application-managed strong cycles as
  application bugs.
- Make every feature earn its place through at least one executable demo and
  preferably a non-ML and an ML use case.
- Record explicit-loop count before and after each feature lands.
