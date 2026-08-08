# UDF Collection Combinator Acceptance Contract

Audit date: 2026-08-07. Read-only sw-MLPL revision: `778ce30d`.

## Current evidence

Current sw-MLPL provides callable named UDFs, `call`, partial application,
`atop`, `over`, `each`, `table`, builtin-reference `reduce`, and Result
combinators (`map_ok`, `and_then`, `or_else`, `bracket`). These are useful and
already exercised by this repository's Strategy and pairwise-table pilots.

They do not yet provide the traversal needed to replace recursive persistent
list filtering or graph-neighbor walks:

- `each(f, v)` maps numeric scalar cells to numeric scalar cells;
- `reduce(:op, array)` accepts a fixed associative builtin reference, not an
  arbitrary UDF with a record/general-value accumulator;
- there is no general UDF `fold`, short-circuit fold, `scan`, `unfold`, `zip`,
  `partition`, `filter`, or `flat_map` surface in the language reference or
  builtin catalog.

No demo was refactored during this audit. Replacing named recursion with an
opcode dispatch or wrapping it in a callable would not exercise a collection
combinator and would not reduce coupling.

## Minimum high-value acceptance surface

The smallest useful language increment is two operations:

```text
fold(step, initial, sequence)
fold_while(step, initial, sequence)
```

Required semantics:

1. `step` accepts a named UDF, builtin reference, or partial callable.
2. The accumulator may be any runtime value, including records, vectors,
   callable-bearing records, and nested values.
3. `fold` processes rank-one major cells left-to-right and returns the final
   accumulator. Empty input returns `initial` without invoking `step`.
4. A plain step has shape `step(accumulator, item) -> accumulator`.
5. A fallible step may return `ok(accumulator)` or `err(error)`. The fold
   propagates the first `Err` without invoking later steps and returns a Result.
   The API must not silently mix plain and Result accumulator modes mid-fold.
6. `fold_while` uses a documented control record such as
   `{continue, state}` (or its Result-wrapped form). It stops immediately when
   `continue` is zero and returns `state`; later items are not evaluated.
7. Callable arity/type errors and the failing item index retain source-aware
   diagnostics.
8. Evaluation order and exactly-once invocation are specified and tested.
9. Empty, singleton, early-stop-first, early-stop-last, `Err`-first,
   `Err`-middle, partial-callable, record-accumulator, and retained-input cases
   have interpreter and web/runtime parity tests.

This pair is enough to unlock honest refactors of:

- persistent-list traversal/filter accumulation;
- graph neighbor expansion and invariant audits;
- Chain of Responsibility short-circuiting;
- dynamic Observer notification accumulation;
- validation with the first structured error retained; and
- many recursive vector builders when paired with append or a future builder.

## Follow-on surface

After the accumulator contract is stable, derive or add:

- `scan(step, initial, sequence)` with the same general/Result semantics;
- `filter(predicate, sequence)` and `partition(predicate, sequence)` with
  scalar truth and Result-aware predicates;
- `unfold(step, seed)` with explicit termination and bounded-resource policy;
- `zip` with an explicit shortest-versus-equal-length rule;
- `flat_map` and general-value `each` once nested/general sequences can retain
  heterogeneous or record results.

Transient/copy-on-write builders are a separate efficiency improvement. They
are not required to prove fold semantics, but they are required before these
combinators can avoid repeated immutable `concat` costs in growing outputs.

## Repository acceptance refactor

When the two minimum operations land, use this order:

1. Refactor `u:retain_at_least` in `src/persistent_lists/alert_feed.mlpl` to a
   fold over alert IDs with an immutable feed/vector accumulator. Preserve the
   stable order, retained snapshot, malformed-input errors, and zero-loop
   claim; compare UDF/branch/line counts with the recursive version.
2. Refactor one graph neighbor validation or collection path with
   `fold_while`, proving first-error/early-stop behavior and no evaluation of
   later invalid neighbors.
3. Run the complete corpus and publish measured clarity and code-size results.
   Do not launch a corpus-wide rewrite unless both pilots improve readability
   and diagnostics rather than merely reducing line count.
