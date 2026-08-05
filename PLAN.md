# Data Structures and Algorithms Demo Plan

## 1. Scope and design rules

This plan targets general-purpose, non-ML programs. It is inspired by APL2,
but uses sw-MLPL's modern ASCII vocabulary and value semantics rather than
trying to transliterate glyphs.

The distinguishing challenge is not another collection of small fixed-array
demos. It is to show **dynamically sized logical structures**, expressed with
**few explicit loops (ideally zero)**, and assembled from pure, loosely coupled
functions. Where today's language cannot do that, the demo becomes an
acceptance specification for the missing composition facility.

Each test should be a `test_*.mlpl` assertion/pass-fail script executed in an
isolated process by mlplunit, using its shared assertion prelude. Each demo
should be a small application with a corresponding test and should:

- teach one principal idea and name its representation invariant;
- state a concrete problem, explain the data structure and algorithm used, and
  show a meaningful result rather than a final assertion summary;
- be a standalone `.mlpl` script runnable by `mlpl-repl` until modules land;
- use deterministic input and include normal, boundary, and failure cases;
- end in `ok(summary)` or `err({kind: ..., message: ...})`;
- use builtins as primitives or test oracles, not as substitutes for the
  algorithm being demonstrated;
- include a short note identifying whether its style is idiomatic array
  programming, deliberately imperative, or a persistent value structure;
- count explicit loops and report the count in the catalog; for every loop,
  state which missing combinator would remove it;
- separate policy from mechanism: ordering, equality, hashing, traversal, and
  construction policies should be passed/delegated rather than embedded once
  first-class user functions exist;
- prefer pipelines and composition over nested calls, immutable replacement
  over mutation, delegation over inheritance, and small protocols over broad
  concrete dependencies;
- avoid timing claims until the language has a stable benchmark facility.

The taxonomy separates **abstract data types** (behavior),
**representations** (how values are stored), and **algorithms** (operations on
those values). This matters in MLPL: a queue is possible today as a dense
array plus indices even though a conventional mutable linked queue is not.

## 2. Capability baseline (2026-08-05)

Audited against the adjacent `../sw-mlpl` tree at commit `16940f5d`, especially
`docs/lang-reference.md`, `docs/apl2-parity-gap.md`,
`docs/apl2-staging-plan.md`, `docs/memory-model.md`, the builtin catalog, and
the Life evaluator tests.

### Available and useful now

| Capability | Consequence for these demos |
|---|---|
| Dense rank-N `f64` arrays; scalars are rank-0 arrays | Natural storage for vectors, matrices, indices, flags, tables, and graphs |
| `range`, `fill`, `zeros`, `ones`, `reshape`, `flatten`, `transpose`, `rotate` | Construct and transform fixed-shape storage |
| `take(x, axis, index)` | Read one element/cell; there is no range slice |
| `scatter(vector, index, value)` | Functional update of one rank-1 slot |
| `concat` for vectors and arbitrary axes | Grow vectors and assemble results, with copying |
| Arithmetic, `mod`, `floor`, `eq`, `lt`, `gt`, reductions | Index arithmetic, predicates, invariants, and numeric hashing |
| `grade_up`, `grade_down`, `compress`, `gather_rows`, `argmax` | Sorting oracle, filtering, priority selection, row lookup |
| `if/else`, `while`, `for`, `repeat`, `break`, `continue`, `return` | Conventional iterative algorithms are expressible |
| Named `def u:name(...)` functions and recursion | Recursive search and persistent recursive structures |
| Records with static fields and nested values | Nodes and structured return values |
| Results, `try/catch`, and postfix `?` | Total APIs and self-checking scripts |
| Strings, string lists, CLI args, stdin, print/eprint | Script shell and simple textual labels |
| Deterministic random numeric constructors | Reproducible generated cases |
| `disp`, `shape`, `rank`, `size`, `tally`, `depth` | Inspect and explain representations |

### Semantic constraints that shape the examples

- Values are owned, copied values. There are no user-visible references,
  aliases, object identity, cycles, or in-place container mutation.
- `scatter` updates only a rank-1 numeric buffer and returns a copy. Record
  fields cannot be updated dynamically; a function must build and return a
  replacement record.
- Record field names are syntactic, not computed keys. There is no general
  dictionary/map value or key enumeration.
- Numeric arrays are homogeneous `f64`. Integers and booleans are conventions
  checked at runtime, not distinct types.
- Strings exist mainly as opaque atoms for messages and labels, not as a
  general-purpose data structure. There is no character indexing, concatenation, splitting,
  substring search, ordering, replacement, or user-defined string hashing.
- User functions are callable but not first-class operands. Current
  higher-order support is primarily quoted builtins accepted by operations
  such as `reduce`.
- There are no modules/imports, local lexical bindings, closures, or generic
  type parameters. Scripts must be self-contained and functions share the
  global `u:` namespace.
- There is no general slice/range gather, record update/spread, or general
  selective assignment. These increase code size and copying in many demos.
- The numeric hash primitive `ngram_hash` is domain-specific and should not be
  presented as a general hash-table API.

Consequently, the initial corpus uses numeric keys, numeric token sequences,
and static diagnostic strings only. No planned-now demo should quietly treat
`String` or `StrList` as a mature collection API.

### Dynamic size in a value/array language

“Dynamic” must be defined behaviorally, not by requiring a mutable heap:

- a logical collection may grow or shrink at runtime;
- operations return a new collection value and preserve the prior version;
- capacity is an implementation detail, not part of the abstract API;
- representations may be flat vectors, segmented/CSR arrays, parallel arrays,
  or nested records;
- logical cycles are represented through IDs/handles; stable runtime object
  identity is out of scope unless a specific pattern truly requires it.

Today's `concat` makes runtime growth possible, but usually with O(n) copying.
That is sufficient for semantic prototypes, not a satisfactory long-term
implementation. The corpus should compare three pure representations:

1. **Packed vector:** simple, cache-friendly, expensive append/delete today.
2. **Chunked/segmented vector:** record of fixed-size numeric chunks expressed
   as a rank-2 array plus logical length; growth allocates a larger chunk table.
3. **Persistent record chain/tree:** natural recursion and persistence, but
   current value cloning does not provide structural sharing.

The desired language outcome is persistent or copy-on-write dynamic values
whose operations stay pure while avoiding whole-structure copies.

The memory consequences are specified separately in
[MEMORY_DESIGN.md](MEMORY_DESIGN.md). In short: no user-visible
`malloc`/`free`, no borrow checker, and no tracing GC are required for the
language contract if MLPL keeps immutable value semantics, uses host-managed
structural sharing, and diagnoses risky runtime reference cycles through
compile/lint analysis. Intentional cycles are supported and application
managed; handles/arenas provide bulk-lifetime management when desired, while
leaks or exhaustion from unreclaimed strong cycles are application bugs.

## 3. Taxonomy and feasibility

Legend: **Now** means a faithful educational demo is implementable with the
current binary. **Constrained** means it runs, but the representation differs
materially from a conventional implementation or is inefficient because of
copy semantics. **Blocked** means a central operation cannot be expressed.

### 3.1 Foundations and representation patterns

| Topic | Status | Today's representation | Purpose |
|---|---|---|---|
| Array as random-access memory | Now | fixed vector + `take`/`scatter` | Establish the common substrate |
| Growable vector | Constrained | vector + `concat` | Correct, but append copies |
| Structured return values | Now | records and Results | Named outputs and explicit errors |
| Bit set / boolean mask | Now | 0/1 numeric vector | Membership and visited flags |
| Matrix/table | Now | rank-2 numeric array | Dense graph and DP storage |
| Persistent node | Now | `{empty, value, left/right/next, ...}` | Explain value trees without pointers |
| Pointer/alias graph | Blocked | none | Requires references or stable handles |

The first demos should establish two sanctioned patterns:

1. **Index structure:** nodes live in parallel numeric arrays and refer to one
   another by integer index, with `-1` as null. This supports mutation-like
   updates through returned arrays and is best for graphs, union-find, and
   imperative linked structures.
2. **Persistent value structure:** a node is a nested record and an operation
   returns a rebuilt path. This is best for explaining immutable lists, BSTs,
   and AVL trees. Today's implementation does not structurally share; the
   target is Clojure-style shared immutable substructure. Logical cycles use
   handles rather than recursive record literals.

### 3.2 Linear abstract data types

| Demo | Status | Notes |
|---|---|---|
| Fixed-capacity stack | Now | `{data, size}`; push/pop replace slots and size |
| Ring-buffer queue | Now | `{data, head, tail, size}`; `mod` handles wraparound |
| Deque | Now | Same ring-buffer representation, two-ended operations |
| Singly linked list, index-backed | Now | parallel `value` and `next` vectors plus head/free indices |
| Singly linked list, persistent records | Constrained | Elegant recursion; rebuilding/copying and no identity |
| Doubly linked list | Now | index-backed parallel `prev`/`next` vectors |
| Mutable pointer-linked list | Blocked | No references, allocation primitive, null, or identity |

Operations: construct, push/pop, enqueue/dequeue, insert/remove, find, length,
reverse, validate invariants, and convert to/from a dense vector.

### 3.3 Associative structures

| Demo | Status | Notes |
|---|---|---|
| Small integer set | Now | bit set when universe is bounded; vector + linear search otherwise |
| Integer map | Now | parallel key/value vectors with a used mask |
| Direct-address table | Now | key is index; demonstrate the time/space tradeoff |
| Open-addressed hash table | Now | numeric keys; `mod`, linear/quadratic probing, tombstone state |
| Chained hash table | Constrained | index-backed link arrays; fixed capacity |
| String-keyed hash table | Blocked | No character/code-point access or general string hash |
| General heterogeneous dictionary | Blocked | No computed record keys or map value kind |

Hash demos must implement a small, explicit integer mixing function rather
than claim `mod(key, capacity)` alone is a good hash. Resizing can be shown by
returning a new table, though it will copy and reinsert every entry.

### 3.4 Trees and priority structures

| Demo | Status | Notes |
|---|---|---|
| Binary tree traversals | Now | persistent record tree or indexed arrays; recursive and iterative versions |
| Binary search tree | Now | search/insert/delete rebuild persistent paths |
| Binary heap / priority queue | Now | dense vector, `floor((i-1)/2)`, repeated `scatter` swaps |
| Heap sort | Now | uses the heap representation |
| AVL tree | Constrained | Persistent rotations and stored heights are expressible; verbose record rebuilding |
| Red-black tree | Constrained | Expressible with numeric color tags; complexity may obscure the language lesson |
| B-tree | Constrained | Fixed order is possible; variable child lists and slices are awkward |
| Trie over strings | Blocked | Strings cannot be decomposed; numeric-token trie is possible but is a different demo |

Balancing should start with AVL, whose numeric height invariant is easy to
check. Red-black and B-tree demos belong after record update and slicing improve.

### 3.5 Graphs and disjoint sets

| Demo | Status | Preferred representation |
|---|---|---|
| Adjacency matrix | Now | rank-2 0/1 or weighted array |
| Edge list | Now | `[E,2]` or `[E,3]` matrix |
| Adjacency list | Constrained | CSR-style `offsets` + `neighbors`; no nested ragged arrays |
| BFS / DFS | Now | visited bit vector + ring queue / explicit stack |
| Topological sort | Now | indegree vector + queue (Kahn) |
| Connected components | Now | DFS/BFS labels or union-find |
| Union-find | Now | parent/rank vectors; path compression returns updated parent vector |
| Dijkstra | Now | O(V^2) dense version first; heap-backed version later |
| Bellman-Ford / Floyd-Warshall | Now | edge-list loops / matrix DP |
| Prim / Kruskal MST | Now | dense minimum selection / grade edges + union-find |
| A* | Constrained | Numeric node IDs and a supplied heuristic; no general callbacks |

CSR is an especially useful forcing demo: it shows that ragged logical data
can be encoded today while making the case for nested arrays and slice ranges.

### 3.6 Algorithm families

| Family | Initial demos possible now | Important limitations |
|---|---|---|
| Searching | linear, sentinel, binary, lower-bound, matrix search | No substring/text search |
| Elementary sorting | bubble, selection, insertion, shell | Repeated functional swaps copy vectors |
| Efficient sorting | merge, quick, heap, counting, radix for nonnegative ints | No slice views; merge/partition code is verbose |
| Sequence transforms | reverse, rotate, partition, dedupe numeric values, prefix sums/products | Reverse is intentionally manual; strings blocked |
| Divide and conquer | binary search, merge sort, quicksort, exponentiation | No cheap slices; pass `(lo, hi)` bounds |
| Dynamic programming | Fibonacci table, coin change, knapsack, LCS on numeric token arrays, edit distance on numeric tokens | Multidimensional cell update needs flatten-and-scatter |
| Greedy | interval scheduling, activity selection, Huffman over numeric symbols | Pair records/rows and grade indices; no general comparator |
| Backtracking | permutations, N-queens, subset sum, Sudoku | Result accumulation copies; recursion is available |
| Numeric algorithms | Euclid GCD, sieve, exponentiation, matrix power | Strong fit for the language |
| Randomized algorithms | Fisher-Yates, reservoir sampling, randomized quicksort | No mutable RNG state object; derive deterministic seeds explicitly |

## 4. Missing features discovered by this corpus

### P0: correctness and reuse enablers

1. **General indexed update/gather and slice ranges.** Add operations equivalent
   to `gather(a, indices[, axis])`, `slice(a, axis, start, stop)`, and functional
   `put(a, indices, values[, axis])`. This removes flattening gymnastics in
   heaps, DP tables, CSR, and sorting.
2. **First-class user functions and composition.** Permit `:u:name`, function
   values in records/arrays, `compose` / `>>`, application pipe `|>`, partial
   application, and uniform invocation. This is the prerequisite for Strategy,
   Command, Visitor, Observer, reusable folds, and policy/mechanism separation.
3. **Core collection combinators.** `each/map`, `filter` (or generalized
   compress), `fold/reduce` over user functions, `scan`, `unfold`, `zip`,
   `partition`, and `flat_map`. `unfold` is particularly important: it creates
   dynamically sized output from state without exposing a loop.
4. **Static modules/imports with private helpers.** mlplunit already removes
   duplicated test assertions through a runner-level source-composition bridge,
   but every standalone test/demo pair still duplicates production helpers such
   as swaps, queues, and utilities. Do
   not implement this before roughly 6–10 real mini-apps expose actual reuse.
   Prefer module-relative static imports, namespaces, private-by-default
   definitions, explicit exports, load-once caching, cycle diagnostics,
   filename-aware spans, and a CLI/web source-provider seam. Packages, remote
   imports, dynamic imports, and version resolution are not required initially.
5. **General scalar `min`/`max` calls and boolean connectives documented as
   ordinary calls.** Reductions already quote these operations, but algorithm
   code needs a clear scalar/elementwise surface and short-circuit boolean
   semantics where side effects or errors matter.
6. **Integer and boolean value types, or checked integer indexing helpers.**
   Algorithms use indices everywhere; silent `f64` conventions weaken both
   error messages and teaching value.

### P1: expressiveness and idiomatic array programming

7. **Structural array verbs.** General `reverse`, range `take/drop`, generalized
   transpose, `where`, `member`, `index_of`, and `sort`. Some can be coded with
   loops today, but they are part of the APL2 thesis and useful as reference
   oracles.
8. **Record update/spread and field/key introspection.** `{..node, left: x}`
   would make persistent tree rotations much clearer. Dynamic-key maps still
   require a separate map type.
9. **Lexical local scope.** Recursive demos currently rely on function argument
   save/restore plus a global environment. Local bindings and block scope reduce
   accidental coupling between standalone helpers.

### P2: new data domains and runtime completeness

10. **Strings as sequences.** Length, code-point/byte conversion, indexing,
   slice, concat/join/split, comparison, find, replace, and case operations are
   prerequisites for string search, tries, string hashing, parsers, and report
   programs.
11. **Nested arrays.** Ragged adjacency lists, generic lists, and APL2-style
    heterogeneous/nested algorithms need enclose/disclose/pick and `each` over
    boxes. This is a substantial data-model change, not a convenience builtin.
12. **General map/set values.** Computed keys, insert/remove/lookup, iteration,
    and equality/hash contracts are needed for conventional associative
    structures over strings and records.
13. **Text/array file I/O and formatting.** Persistence, corpus algorithms, and
    golden outputs need read/write plus predictable numeric/text formatting.
14. **Structured serialization and codecs.** JSON and TOML need mature strings
    and text I/O; a versioned native binary value format additionally needs
    byte arrays and exact numeric type/shape/endianness metadata. Decoding must
    be bounded, non-executable, version-aware, and path-diagnostic. Delegated
    codecs and migrations follow first-class UDFs. Keep quantized tensor/model
    formats in the future `demo-sw-mlpl` repository while sharing these general
    primitives.

### Performance follow-ups (not blockers for correctness demos)

- Copy-on-write or uniqueness-aware array updates so `scatter`, assignment,
  and append do not copy entire buffers unnecessarily.
- Mutable local buffers or a builder/transient block with value semantics at
  the boundary.
- Tail-call optimization or an explicit recursion-depth contract.
- Monotonic timing and a benchmark harness with warmup and machine metadata.

These changes must preserve the semantic constraints in
[MEMORY_DESIGN.md](MEMORY_DESIGN.md); performance work must not leak Rust
lifetimes, ownership, or manual reclamation into MLPL source.

Pointer identity is deliberately **not** proposed as an immediate requirement.
Index-backed storage demonstrates cyclic algorithms without requiring cyclic
ownership. Persistent immutable values may share substructure, while the
compiler/linter diagnoses strong ownership cycles as described in
[MEMORY_DESIGN.md](MEMORY_DESIGN.md). Revisit general references only if a
later corpus proves stable identity itself is essential.

## 5. Delivery plan for today's language

The project maintains two tracks for each important example:

- **Executable baseline:** the clearest implementation today's binary permits,
  even if it contains loops.
- **Target formulation:** a loop-light/loop-free composition sketch plus exact
  required features. When those features land, the target replaces the
  baseline and the loop budget ratchets downward.

This prevents “possible with `while`” from being mistaken for language
completeness.

### Phase 0 — executable contract and harness

Create:

- `scripts/run-all` to discover `.mlpl` files and invoke `$MLPL`;
- a manifest recording category, status, required features, and expected exit;
- manifest fields `dynamic_size`, `explicit_loops`, `target_loops`,
  `composition_gaps`, and `patterns_exercised`;
- common conventions for assertions, integer validation, null index `-1`, and
  `{ok/value}` results;
- CI that builds or downloads a pinned sw-MLPL binary, then runs every demo.

Acceptance: one passing and one intentionally failing fixture prove that a
final `Err` becomes exit code 1. Do not publish performance comparisons here.

### Phase 1 — dynamic collections and composition pressure tests

Implement in this order:

1. `linear/growable_vector.mlpl`: runtime append/remove with a pure API.
2. `linear/chunked_vector.mlpl`: separate logical size from capacity.
3. `linear/persistent_list.mlpl`: recursive values and folds (baseline recursion;
   target first-class fold/composition).
4. `linear/{stack,queue}.mlpl`: delegate storage to one of those sequences.
5. `algorithms/sequence/reverse.mlpl`: array formulation plus baseline
   two-pointer comparison.
6. `algorithms/search/{linear,binary}_search.mlpl`: search result as `Result`.
7. `algorithms/sort/merge_sort.mlpl`: phases expressed as split, recursive sort,
   merge; target comparator delegation.
8. `associative/numeric_hash_map.mlpl`: runtime resize and rehash.

These immediately exercise runtime size changes, persistence, policy
delegation, and composition gaps. Elementary imperative sorts may be retained
as comparisons, but they are no longer the headline milestone.

Acceptance per sort: empty, singleton, duplicates, negatives, already sorted,
reverse sorted; compare output with `gather_rows(reshape(input,[n,1]),
grade_up(input))` flattened back to a vector.

### Phase 2 — indexed structures and graph algorithms

Implement:

- index-backed singly and doubly linked lists;
- integer bit set, direct-address map, open-addressed hash table;
- union-find with union by rank and path compression;
- adjacency matrix, edge list, and CSR conversion;
- BFS, iterative DFS, connected components, topological sort;
- dense Dijkstra, Bellman-Ford, Floyd-Warshall, Kruskal.

Acceptance: validate every internal invariant after every public operation.
Cross-check shortest paths across Dijkstra/Bellman-Ford/Floyd-Warshall on the
same nonnegative graph and components across BFS/union-find.

### Phase 3 — persistent recursive structures

Implement:

- persistent cons list with map-like operations written explicitly;
- binary tree recursive preorder/inorder/postorder;
- persistent BST insert/search/delete;
- AVL insert and rotations with a stored height and recursive validator;
- recursive merge sort/quicksort using index bounds rather than slices.

Acceptance: demonstrate persistence by retaining the old root and proving it
is unchanged after insertion. Document copy costs and the absence of sharing;
do not call these pointer-based structures.

### Phase 4 — classic algorithm survey

Add representative, not exhaustive, demos:

- counting/radix/shell sorts;
- lower-bound and binary-search variants;
- Euclid, sieve, fast exponentiation;
- coin change, 0/1 knapsack, numeric-token LCS/edit distance;
- interval scheduling and numeric-symbol Huffman;
- N-queens, subset sum, Sudoku;
- deterministic Fisher-Yates and reservoir sampling.

Prefer one strong demo per concept. Variants that add no language coverage
belong in a comparison script or documentation, not separate files.

### Phase 5 — feature-gated acceptance demos

Keep blocked demos in a catalog, not as fake implementations:

- `strings/substring_search.mlpl` gates string sequence operations;
- `associative/string_hash_map.mlpl` gates strings plus maps;
- `trees/trie.mlpl` gates strings and dynamic/nested children;
- `graphs/ragged_adjacency.mlpl` gates nested arrays;
- shared-library versions of earlier demos gate modules/imports;
- comparator-driven generic sort and traversal gate first-class UDFs;
- clean persistent AVL rotations gate record update/spread;
- file-backed inventory/report demo gates file I/O and formatting.
- JSON/TOML configuration and native shaped-value round trips gate safe
  serialization, schema evolution, and codec delegation; ML quant formats are
  explicitly outside this repository.
- all 23 functional GoF demonstrations gate the capabilities identified in
  [DESIGN_PATTERNS.md](DESIGN_PATTERNS.md).

When a capability lands in sw-MLPL, promote its smallest acceptance demo into
the runnable suite first, then refactor later demos to use it.

## 6. Recommended first milestone

Call the first release **M0: Dynamic Values, Pure Interfaces**. It should
contain growable/chunked vectors, persistent list, delegated stack and queue,
numeric hash map with resize, merge sort, search, and one CSR graph traversal.

Why this slice:

- all are implementable against the audited binary today;
- together they exercise runtime growth/shrinkage, pure updates, records,
  Results, recursion, storage delegation, and numeric indexing;
- they expose the cost and ergonomics of array updates before the project
  commits to dozens of demos;
- they make explicit which loops should disappear into APL-style operators;
- they tell a coherent APL-derived story: dynamic structures are value
  transformations over arrays, while folds/scans/unfolds are the control
  vocabulary.

Exit criteria:

- every test is deterministic and self-checking, while every demo visibly
  solves its stated problem and has a corresponding test;
- all run from a clean checkout with one documented command;
- CI tests both debug/latest and a pinned known-good sw-MLPL revision;
- the catalog reports runnable, constrained, and blocked counts;
- the catalog reports total explicit loops and fails CI if that count rises
  without a documented exception;
- each awkward workaround has either an issue in sw-MLPL or an explicit
  decision that it is acceptable pedagogy.

## 7. Upstream issue sequence

Open narrow upstream issues only after a demo supplies a failing or awkward
acceptance case. Suggested order:

1. first-class UDF values, invocation, composition, and pipes;
2. `map/filter/fold/scan/unfold/zip/partition` over UDFs;
3. general gather/slice/put;
4. modules/imports;
5. record update/spread and lightweight protocols;
6. integer/boolean typing decision;
7. string sequence operations (explicitly later; strings are not assumed now);
8. nested arrays;
9. general map/set, byte/text file I/O, and safe structured serialization.

Every issue should link to the smallest affected demo, show the current
workaround, define the desired MLPL spelling, and state whether the feature is
also useful for ML workloads. That keeps this repository a forcing function
rather than a speculative language wish list.
