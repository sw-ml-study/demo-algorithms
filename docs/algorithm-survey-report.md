# General Algorithm Survey Closeout

Status date: 2026-08-06. Verified with `mlpl-repl` 0.20.0 build commit
`3cc61287` and mlplunit 0.1.0 commit `6f7ac47`.

## Outcome

The survey closes with twelve problem-solving mini-apps, eight native
mlplunit files, and fourteen named native tests. Every demo and test includes
the same production definition from `src/`; every `u:` function has a leading
doc string. All twelve demos use zero explicit loops and have zero target
loops. Recursion and array primitives express the control flow today.

| Family | Algorithms | Boundary and deterministic policy | Logical cost | Current immutable cost |
|---|---|---|---|---|
| Dynamic programming | unbounded coin change, 0/1 knapsack | empty/impossible/zero, validation, smaller-coin and exclude-later ties | O(target*coins), O(items*capacity) | growing table/row copies |
| Sequence comparison | numeric LCS | empty/disjoint/repeated inputs, upward tie | O(m*n) time/space | each point update copies the full table |
| Greedy | interval scheduling | empty/singleton/touching/zero-length, earliest `(finish,start,ID)` order | O(n²) baseline sort + O(n) selection | growing parallel-vector copies |
| Backtracking | N-queens, signed 0/1 subset sum, Sudoku | bounded validation, deterministic left/include/row-major choices, explicit unsatisfiable results | exponential worst case | partial-vector or board copy per choice |
| Numeric | Euclidean GCD/LCM, sieve, exponentiation by squaring | signs/zero/ranges/integrality | logarithmic scalar work; sieve O(n log log n) marking | sieve copies the flag vector per mark |
| Sampling | Fisher–Yates, reservoir sampling | empty/singleton/duplicates, `k=0`, `k>=n`, integral seed, reproducible state | O(n) | shuffle O(n²) physical copies; accepted reservoir replacement copies O(k) |

Tests cover retained inputs as well as results. Algorithm-specific invariants
check reconstructions, nonattacking queens, increasing subset indices, Sudoku
validity, shuffle multiplicities, and reservoir source-index uniqueness and
value correspondence. The small modulus-65521 LCG is deliberately explicit
for reproducible teaching fixtures. Its bounded modulo mapping has slight bias
and it is neither cryptographic nor a production statistical RNG.

## What works in sw-MLPL today

- Dynamic numeric vectors, flat matrices, records, Results, recursion,
  `concat`, `scatter`, `compress`, reshape/display, and static `include` are
  enough for all twelve demonstrations.
- Numeric tokens and IDs avoid dependence on the still-immature string model.
- Immutable values naturally retain input snapshots without `malloc`, `free`,
  a borrow checker, or direct cyclic ownership.
- Static include plus mlplunit native discovery provides one tested source for
  demos and tests. Full modules are no longer a prerequisite for reuse.

## Remaining gaps, in priority order

1. General pure point/gather/slice updates and record update/spread remove the
   most common reconstruction boilerplate.
2. First-class UDF values and UDF-capable folds/scans/unfolds turn recursive
   control policies into composable delegation and prepare the GoF work.
3. Full modules add namespaces, exports, privacy, and evaluate-once identity
   beyond transparent static include.
4. Copy-on-write storage and scoped transient builders remove the dominant
   table/vector copy amplification while retaining pure observable semantics.
5. A delegated RNG interface with unbiased bounded draws separates sampling
   algorithms from generator quality and state representation.
6. Stack-safe folds/tail calls improve large-input recursion safety; integer
   types improve index and seed diagnostics.

None of these gaps blocks the current survey. Counting/radix/shell variants,
edit distance, Huffman coding, and further routing algorithms can add breadth,
but add less language evidence than the next architectural milestone.

## Recommended next work

Proceed to the functional GoF baselines. Start with Adapter using existing
graph conversions, then demonstrate value-oriented Prototype, numeric
Flyweight, and immutable Memento. Reuse the existing closed
Composite/Interpreter tree, add a closed State transition and explicit
Iterator baseline, and clearly gate patterns that require first-class behavior
instead of claiming numeric opcode dispatch is delegation.

## Reproduction

```sh
./scripts/run-all
./scripts/run-tests
./scripts/run-tests --format tap
./scripts/check-docstrings
./scripts/check-mlplunit-adoption
./tests/test-harness
```

At closeout these commands report 48 passing demos, 58/58 passing native
tests/cases from 46 files, 449/449 documented user functions, and agreement
between both catalogs and the shared-source audit.
