# Combinator refactoring assessment

Audit date: 2026-08-07. Read-only references were `demo-combinators` commit
`404ec6e` and sw-MLPL commit `e0c441a4`.

## Conclusion

Combinators can make selected boundaries in this repository shorter, more
configurable, and easier to test. They are not yet a general replacement for
the recursive cores of graph, dynamic-programming, tree, routing, or mutable-
work-array algorithms. A small pilot is worthwhile; a corpus-wide rewrite is
not.

The most useful shipped facilities are:

- named UDF references and uniform `call`;
- progressive application, which creates callable partial values by binding
  leading arguments;
- `atop(f,g,x...)` for immediate composition;
- `over(f,g,x,y)` for transforming two inputs before combining them;
- `each(f,array)` for scalar-to-scalar element mapping; and
- `table(f,left,right)` for scalar binary outer products.

`demo-combinators` proves that partials work with `each`, `table`, `atop`, and
`over`. Its Bluebird/Becard/Phoenix examples also prove that named combinators
can make a pipeline or fork/join policy explicit. Its current capability
matrix still records partial Result combinators and partial `bracket` hooks as
gated.

## Where this repository benefits now

| Candidate | Useful refactoring | Benefit | Caveat |
|---|---|---|---|
| Strategy scoring | bind weights or thresholds into one named scoring UDF, then store the partial as policy | removes several near-duplicate fixed policies; demonstrates real configuration | callable errors still need explicit Result handling |
| Template/report pipelines | compose pure unary prepare/analyze/publish projections with `atop` or Bluebird/Becard | makes stage wiring visible and reusable | named bird vocabulary may be less familiar than direct calls |
| Pairwise numeric construction | use `table` with a binary UDF or partial to build distance, compatibility, or cost matrices | replaces two-dimensional indexing recursion when every cell is independent | existing edge-list-to-matrix code is sparse/stateful and should not be forced into an outer product |
| Element policy application | use `each` for a genuinely named scalar policy | useful when behavior, not arithmetic, varies | pervasive array expressions are already clearer for simple arithmetic |
| Fork/combine summaries | use Phoenix-style wiring or `over` where two pure projections feed one combiner | reduces duplicated input plumbing | fixed records are clearer when more than two outputs must remain inspectable |
| Demo orchestration | compose validation-free pure preparation and presentation helpers | shorter top-level problem solution | do not hide the demonstrated algorithm behind a combinator call |

The strongest first pilot is a configurable Strategy refactor: replace fixed
balanced-score variants with a partially applied named weighted-score UDF,
while retaining the same selector and native tests. The strongest new-demo
pilot is a pairwise matrix application whose cell function is naturally an
outer product—such as travel-time estimates from two numeric attribute
vectors—so `table` is the algorithmic vocabulary rather than decoration.

## Where current combinators do not help enough

Do not mechanically rewrite these cores today:

- BFS/DFS queues, augmenting paths, cycle detection, and topological sorting;
- Held–Karp, LCS, coin-change, knapsack, and Hungarian work-table filling;
- union-find path compression and tree rotations;
- CVRP/TSP backtracking and branch pruning;
- residual-flow updates, minimum-cut edge collection, and stateful hashing;
- validations that must stop early or return path-specific Results.

Those algorithms thread records, update growing vectors/matrices, stop early,
or return non-scalar values. Current `each` requires scalar results; `table`
describes independent scalar pairs; `atop` and `over` compose fixed shallow
shapes. Bird combinators route calls but do not provide iteration, memoization,
state threading, pruning, or cheaper storage. Replacing named recursion with
nested birds in these cases would usually be less readable and would weaken
the repository's purpose of exposing each algorithm.

## What would change the answer

The high-payoff feature is a UDF-capable, Result-aware traversal family:

- left/right fold with explicit accumulator records;
- short-circuit fold for search, validation, and pruning;
- scan for observable intermediate states;
- unfold for queues, routes, and generators;
- map/filter over general values, not only scalar numeric results; and
- state-threading table/cell traversal for dynamic-programming matrices.

Partials working in `map_ok`, `and_then`, `or_else`, and `bracket` would also
make configured validation/resource policies compose naturally. Combined with
scoped transient/COW builders, these features could simplify algorithm cores
without multiplying immutable copies.

## Recommended adoption plan

1. Do not copy the full aviary into this repository or add a runtime dependency
   on the sibling checkout. Use shipped `atop`/`over`/`each`/`table` directly,
   or copy only a tiny well-named shared combinator module when a demo truly
   teaches that abstraction.
2. Pilot one Strategy partial refactor and one new pairwise-`table` mini-app.
   Preserve pre-refactor observable results and native oracle tests.
3. Measure source reduction, UDF count, error clarity, and whether the problem
   explanation becomes easier—not merely whether the code becomes shorter.
4. Keep direct algorithm implementations as the teaching baseline. A composed
   façade may delegate to them; it should not erase their data structures,
   invariants, or complexity evidence.
5. Re-audit after general UDF fold/scan/unfold and Result-aware partial support
   ship. That is the point where graph scans, validations, and DP builders may
   benefit broadly.

So: combinators are already better for loose coupling and policy composition,
occasionally more succinct for matrix/pipeline work, and useful for new demos.
They are not yet broadly better for the stateful recursive algorithms that
make up most of this repository.

## Strategy pilot result

The first pilot is now executable in `shipping_service_policy.mlpl`.
`score_weighted(cost_weight,duration_weight,cost,duration)` centralizes the
only scoring formula; `call(:u:score_weighted, 1, 2)` produces a two-argument
balanced policy that the unchanged selector invokes and that a policy record
retains as data. Native tests prove it is substitutable for the fixed balanced
UDF, a second `0,1` partial selects the urgent service, and the original
configuration record remains equal after both calls.

Measured outcome:

- arithmetic formula sites fell from three to one;
- public semantic aliases remained three, so policy-related UDF count rose
  from three to four rather than shrinking;
- adding another numeric weighting now requires data plus a partial, not a new
  UDF;
- selector recursion, validation, tie policy, and observable service choices
  did not change; and
- no bird library or sibling runtime dependency was introduced.

This is better loose coupling and configuration, but not fewer total lines for
the original three-policy example. The pilot supports selective adoption and
does not justify rewriting algorithm cores. A pairwise `table` pilot remains
worth doing because it can replace genuine two-dimensional construction rather
than merely reorganize policy declarations.
