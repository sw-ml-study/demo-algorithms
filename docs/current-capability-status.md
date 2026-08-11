# Current sw-MLPL General-Purpose Capability Status

Status date: 2026-08-11. Verified with `mlpl-repl 0.20.0` local build commit
`d373584c` (MLPB v2 codec commit `00945f7d`)
and mlplunit `a06191f`.

## Executable baseline

The repository contains 96 problem-solving demos and 88 conformance-test
files reporting 192 native tests/cases. All 984 user-defined functions have
doc strings. The demo catalog contains 20 `runnable` and 76 `constrained`
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
| Serialization and external configuration | deterministic MLPB native-value round trips with exact shapes and bounded decode; byte/depth/element-budgeted JSON, reserved tagged envelopes, TOML-subset interoperability, atomic replacement, and application packets |
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
| Reference-preserving or streaming object codecs | reference tables/cycle policy, reference limits, streaming state, scoped resources, and authenticated integrity beyond one-shot MLPB v2 CRC32 |
| Reusable libraries with encapsulation | qualified modules, explicit exports, private-by-default helpers, evaluate-once imports, cycle diagnostics |
| Generic collection algorithms | UDF-capable map/filter/fold/scan/unfold/zip/partition/flat-map over general values, including short circuit and Result propagation |

The latest read-only audit at sw-MLPL `778ce30d` confirms this row remains a
real blocker: shipped `each` is scalar-to-scalar, while `reduce` accepts fixed
associative builtin references. The minimal `fold`/`fold_while` acceptance
contract is documented in
[udf-collection-combinator-contract.md](udf-collection-combinator-contract.md).

A later read-only audit at `0904bfcf` confirms static include still splices a
shared environment and does not supply namespace/export/privacy identity. The
minimum behavior and Singleton fixture are specified in
[module-singleton-acceptance-contract.md](module-singleton-acceptance-contract.md).

The initial native serialization audit through source and binary revision
`7f6dee4d`, extended for MLPB v2 at codec revision `00945f7d`, confirms
`has_field` and `record_get` now make missing required fields, optional
defaults, additive fields, and schema versions ordinary Result-driven policy;
`type_of` safely rejects non-record roots, `to_json` enables deterministic
ordinary-data round trips, and sandboxed `read_bytes`/`write_bytes` persist
numeric byte vectors exactly.
`write_atomic` now replaces string or numeric-byte files through a hidden
sibling plus same-filesystem rename; focused tests prove shorter replacements
leave neither stale JSON text nor stale packet bytes.
The breaking Result contract is adopted: `to_json(v)?` rejects unsupported and
non-finite values without aborting, and invalid cells supplied to
`write_bytes`/`write_atomic` return Err while retaining the prior file. Numeric
rank-1 arrays constrained to integer `0..=255` are the language byte policy,
not a placeholder for a distinct byte type. Deterministic Result-based
`to_toml` and `parse_toml` now provide the documented bounded configuration
subset; they do not imply general typed-value or higher-rank preservation.
Both text decoders now enforce a default depth ceiling and accept explicit
`max_depth`/`max_bytes` application budgets. Invalid external input returns
`Err`; malformed option records remain hard programmer errors by design.
With `{results: 1}`, both decoders recursively reconstruct the exact
`{ok,value}`/`{ok,error}` shapes emitted by their encoders. Reconstruction is
off by default because an application record can legitimately use that shape.
For lossless MLPL-to-MLPL JSON, `to_json(value, {tagged: 1})` now emits a
versioned reserved `$mlpl` envelope for Results and rank-2-or-higher arrays;
`parse_json` reconstructs those envelopes unconditionally while preserving
matrix shape. This removes the ambiguous decode flag from the canonical JSON
round trip. The compact Result form remains useful for ordinary JSON/TOML
interoperability. TOML tagged mode and general user-defined variants remain
future work.
MLPB v2 now supplies deterministic `to_native(value)` and budgeted
`parse_native(bytes[, limits])` for every current MLPL data kind. The executable
acceptance suite pins canonical little-endian scalar/string CRC32 golden bytes,
round-trips rank-4 arrays and nested Results, rejects malformed/truncated/version
and non-data inputs through Results, enforces byte/depth/element budgets, and
persists snapshots through atomic raw-byte replacement, rejects payload/trailer
corruption, and proves checksum-free v1 buffers remain readable. Reference
identity, cycles, streaming, and authenticated integrity remain follow-ups.

The local release interpreter was rebuilt from an adjacent checkout containing
unrelated in-progress changes. Its embedded commit is `d373584c`; reproducible
release pinning should use a clean upstream worktree even though the exercised
MLPB v2 implementation is committed independently at `00945f7d`.

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
5. Build on the shipped TOML configuration subset with shared text-codec
   metadata and a typed native format after tightening higher-rank values,
   collection/reference limits and path-aware errors.

Until one of those enablers lands, useful repository work is closeout,
refactoring, invariant strengthening, and documentation—not adding another
near-duplicate numeric structure merely to raise the demo count.
