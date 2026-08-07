# Advanced routing, flow, and assignment closeout

Status as of 2026-08-07: all six advanced mini-app files and their five
focused test files run on the current sw-MLPL binary with zero explicit loops.
Together they add 20 native test cases to the earlier graph corpus.

## Executable comparison

| Problem | Result type | Method and status | Logical complexity | Current representation | Main physical cost |
|---|---|---|---|---|---|
| Point-to-point route | one path | A*, exact with admissible heuristic | dense baseline O(VE) | weighted edge vectors, heuristic, parent vectors | repeated immutable distance/parent/visited scatters |
| Traveling salesman | one closed tour | factorial exact oracle; Held–Karp exact; nearest neighbor and 2-opt heuristic | factorial; O(V²·2^V); O(V²) heuristic scans | flat distance matrix and route vector | branch copies; full DP-table scatters; segment rebuilds |
| Capacitated vehicle routing | several closed routes | bounded exact order/split search; nearest-feasible heuristic | O(N!·2^N) exact; O(N²) greedy | depot-delimited flat route stream | copied visited/routes; no nested route collection |
| Maximum flow / minimum cut | flow matrix and cut certificate | Edmonds–Karp exact plus residual min-cut proof | O(V·E²), plus O(V²) certificate scan | flat capacity/residual/signed-flow matrices; parallel cut-edge vectors | four V² matrix copies per augmented edge |
| Bipartite cardinality matching | inverse mate vectors | deterministic Kuhn augmenting paths, exact cardinality | O(L·E) | flat binary adjacency and left/right mates | copied seen and mate vectors |
| Weighted square assignment | inverse mate vectors and cost | deterministic Hungarian, exact minimum cost | O(N³) | flat cost matrix; potential/slack/owner/predecessor vectors | copied work vector on each logical update |

“Exact” refers to the stated problem and accepted numeric input contract.
Nearest neighbor and 2-opt remain clearly labeled heuristics. The CVRP exact
solver is intentionally limited to seven customers, Held–Karp to twelve
cities, and factorial assignment/TSP routines to small oracle fixtures so
application input cannot silently request impractical exponential work.

## Cross-algorithm evidence

- A* matches Dijkstra's optimal route and does not expand more vertices than
  zero guidance on the acceptance graph.
- Held–Karp matches factorial TSP cost and ascending first-minimum tour; 2-opt
  improves the nearest-neighbor fixture from 62 to the optimum 52.
- CVRP exact search proves cost 24 while the deterministic greedy comparison
  costs 41; both respect capacity and serve every customer.
- Edmonds–Karp produces flow 23 with conservation and capacity bounds. The
  saturated crossing edges sum to the same minimum-cut capacity 23.
- Direct bipartite augmenting paths produce cardinality 4, independently
  matched by the transformed unit-capacity flow network.
- Hungarian assignment produces cost 13 and the same first-minimum assignment
  as exhaustive permutation search.

These checks already sit beside their implementations and exercise different
algorithms or proof certificates. A new omnibus assertion file would repeat
them without improving failure localization.

## What current sw-MLPL does not block

The current language can express recursive BFS/DFS, backtracking, memoized
dynamic programming, primal-dual work arrays, immutable state threading,
first-class Result errors, deterministic numeric records, shared source through
`include`, and native mlplunit tests. No language change is required for the
logical correctness of these numeric baselines. Cyclic application graphs are
already handled safely through numeric vertex IDs and matrices.

## Phase-specific feature ranking

This ranking reflects friction measured in these executable algorithms, not a
replacement for the repository-wide ranking.

1. **Scoped transient builders backed by COW/persistent storage.** Every major
   algorithm is logically pure but repeatedly copies O(V), O(V²), or O(V·2^V)
   work arrays. A non-escaping mutable scope has the largest performance payoff.
2. **UDF-capable traversal and short-circuit folds.** Neighbor scans, candidate
   scans, conservation checks, cut filtering, and argmin selection all repeat
   bespoke recursion.
3. **Nested/general collections and zipped record vectors.** CVRP wants a
   collection of routes; cuts want edge records; assignments want pair records.
   Flat delimiters and parallel vectors are correct but less composable.
4. **Efficient bit sets and numeric-key maps.** Held–Karp subset state, visited
   sets, sparse residual graphs, and memo tables should not require dense
   floating-point vectors.
5. **Argmin/grade with callable tie policy plus row/column operations.** A*,
   greedy routing, Hungarian slack selection, and sorting/pruning code would
   become shorter without hiding deterministic choices.
6. **Record update/destructuring and modules.** These remove state-rebuild
   boilerplate and give queue/graph libraries privacy, but they gate less
   algorithmic behavior than the five items above.

Strings, serialization, automatic cycle collection, and weak references do
not block this phase. Strings and serialization remain important for external
datasets and durable applications; their separate acceptance plan remains in
`serialization-acceptance.md`.

The sibling combinator work was also audited during closeout. Current
`each`/`table`/`atop`/`over`, callable partials, and bird-style composition are
useful at policy, pipeline, pairwise-construction, and fork/combine boundaries,
but they do not replace state-threading or short-circuit algorithm recursion.
See [combinator-refactoring.md](combinator-refactoring.md) for recommended
pilots and the no-bulk-rewrite conclusion.
