# Current sw-MLPL General-Purpose Capability Status

Status date: 2026-08-07. Verified with `mlpl-repl 0.20.0` build `6c4a1a24`
and mlplunit `71dd16f`.

## Executable baseline

The repository contains 89 problem-solving demos and 83 conformance-test
files reporting 166 native tests/cases. All 927 user-defined functions have
doc strings. The demo catalog contains 13 `runnable` and 76 `constrained`
entries, no gated entries, and three explicit loops in total. `just check`
validates both catalogs, doc strings, shared-source adoption, the shell harness,
all demos, and all tests.

“Constrained” means the implementation is honest and executable with a numeric
or fixed-schema representation; it does not mean the script is blocked.

## Working families

| Family | Current executable evidence |
|---|---|
| Dynamic sequences | growable/chunked vectors, stack, ring queue/deque, singly/doubly linked arenas, persistent cons lists, deterministic skip list |
| Ordered and persistent trees | BST insert/delete, AVL, order-statistic AVL, interval tree, segment tree, Fenwick tree, numeric digit trie, 2-3/B-tree insertion and full deletion |
| Associative structures | bit set, direct-address map, numeric mixing, linear probing, tombstones, resize/rehash, separate chaining, application LRU |
| Search, sort, and priority | linear/binary/lower-bound search, reverse, stable insertion/merge sort, heap/priority queue, heap sort |
| Graphs and routing | representations, BFS/DFS, cycles/topological order, SCC, union-find, shortest paths, MST, A*, TSP variants, CVRP, flow/min-cut, matching, assignment |
| Algorithm survey | dynamic programming, greedy selection, backtracking, Sudoku, numeric algorithms, deterministic sampling |
| Sparse/general matrices | COO normalization, CSR, matvec, transpose, addition, rectangular multiplication, dense oracles |
| Functional GoF evidence | 22 executable patterns, with fixed-schema or constrained forms clearly labeled; Singleton remains gated |
| Composition/tooling | shared `src/` includes, native mlplunit discovery/reporting, callable Strategy and constructor policies, partial/table combinator pilots |

Steps 096–107 specifically closed the previously weak dynamic-structure area:
doubly linked edits, persistent-list shrinking, rank/select AVL, interval and
segment trees, Fenwick analytics, numeric prefix trie, B-tree insertion and
deletion, skip list, and sparse matrix analytics/composition are all executable.

## Efficiency gaps, not semantic blockers

These affect asymptotic physical cost but do not prevent correct demos:

- immutable `concat` and `scatter` copy arrays, amplifying arena, Fenwick, CSR,
  hash-table, queue, and dynamic-programming updates;
- nested immutable records preserve earlier roots semantically, but runtime
  structural sharing is not guaranteed, so persistent trees/lists may copy
  more than their logical changed path;
- recursive output construction lacks transient/copy-on-write builders;
- several pedagogical sparse conversions scan coordinate domains rather than
  using grouped sparse accumulators;
- deterministic skip-list heights demonstrate the structure but cannot claim
  randomized expected logarithmic performance.

Highest-value runtime improvement: immutable structural sharing backed by
automatic reclamation, plus transient/copy-on-write builders. No language-level
`malloc`/`free` or borrow checker is required. Application-created strong
cycles remain application-managed; lint/compile diagnostics should identify
them without prohibiting valid cyclic structures.

## Genuine semantic blockers and exact enablers

| Blocked capability/demo class | Exact sw-MLPL enabler |
|---|---|
| Singleton with stable private identity | evaluate-once modules, private bindings/constructors, stable module export identity |
| Dynamic Observer/Mediator/Chain registries | callable/general-value sequences or maps plus short-circuit UDF fold and general nested result values |
| Open extensible Composite/Interpreter/Visitor algebras | variants/tagged unions, exhaustive pattern matching, callable folds, module boundaries |
| General string-key tries/maps and text algorithms | strings as indexable/sliceable/comparable general sequences, Unicode/byte policy, mature string I/O |
| JSON/TOML and portable binary object codecs | mature strings/bytes, structured file I/O, tagged value introspection, deterministic codec/error APIs |
| Reusable libraries with encapsulation | qualified modules, explicit exports, private-by-default helpers, evaluate-once imports, cycle diagnostics |
| Generic collection algorithms | UDF-capable map/filter/fold/scan/unfold/zip/partition/flat-map over general values, including short circuit and Result propagation |

The latest read-only audit at sw-MLPL `778ce30d` confirms this row remains a
real blocker: shipped `each` is scalar-to-scalar, while `reduce` accepts fixed
associative builtin references. The minimal `fold`/`fold_while` acceptance
contract is documented in
[udf-collection-combinator-contract.md](udf-collection-combinator-contract.md).

First-class named UDFs, uniform `call`, partial application, and `table` are
current capabilities, not blockers. They already power executable Strategy,
Factory, Bridge, Template Method, Decorator, Proxy, Command, Visitor, and
matrix-planning evidence. The remaining gap is applying callables uniformly
over dynamic general-value collections.

Advanced hashing, probe distributions, Bloom filters, packed metadata,
timing/cache/SIMD behavior, and experimental funnel/elastic/rainbow/zombie
hashing belong to
[`demo-memory`](https://github.com/sw-ml-study/demo-memory), whose upstream
contract is authoritative for their fixed-width integer, bitwise, timing, and
memory-layout requirements. They should not be reintroduced here.

## Recommended next wave

1. Pause breadth-first addition of data structures; the current corpus is
   broad enough to force meaningful language/runtime decisions.
2. Prioritize UDF-capable general-value folds and short-circuit traversal. Use
   them to refactor existing list, graph, GoF, and validation recursion and
   measure reduced code/loop counts.
3. Add qualified evaluate-once modules with visibility. Refactor repeated
   helpers from the observed corpus and use Singleton as the semantic
   acceptance test.
4. Add structural sharing/automatic reclamation and transient builders, then
   rerun persistent-tree/list and array-copy demonstrations with measurable
   allocation/copy evidence.
5. Mature strings/bytes and structured I/O before adding general text tries or
   JSON/TOML/binary serialization demos.

Until one of those enablers lands, useful repository work is closeout,
refactoring, invariant strengthening, and documentation—not adding another
near-duplicate numeric structure merely to raise the demo count.
