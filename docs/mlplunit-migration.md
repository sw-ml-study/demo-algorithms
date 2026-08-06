# Native mlplunit migration

## Target contract

mlplunit owns test discovery, one-process-per-file isolation, assertion
helpers, native `@test` registration, reflected `@cases`, bracketed lifecycle,
human/TAP reporting, and suite exit status. This repository retains catalog
taxonomy and selection, executable demos, production algorithm sources, and
learning documentation.

Reusable definitions live under `src/`. A demo includes them using a path
relative to its own source file and runs under `mlpl-repl --source-dir <repo>`.
An mlplunit test uses a source-root-relative include such as
`include "src/deques/service_desk.mlpl"`; this is required because the current
mlplunit runner composes its assertion prelude and test into a temporary main
source while preserving the configured repository source sandbox.

Tests use named and tagged `@test` functions followed by
`u:run_registered_tests()`. Use `@cases` only for genuinely table-shaped
numeric repetition. Use bracketed fixtures only when setup/teardown ownership
is real; immutable local values do not justify fixture ceremony.

## Inventory and batches

The starting corpus has 41 registered test files. Before this migration, none
used production source inclusion, `@test`, or `@cases`, and 38 used a
monolithic `u:test()` entry point. Migration is divided into bounded
batches so every commit keeps the full suite runnable:

| Batch | Test files | Scope | Status |
|---|---:|---|---|
| foundation | 1 | config, runner delegation, deque vertical slice | complete |
| sequences/search/sort | 16 | vectors, stack, queue, linked/persistent lists, search, sequence, sorts, heap | complete |
| associative/trees | 13 | sets, hashing, maps, cache, trees | complete |
| graphs | 8 | representation through Kruskal | complete |
| algorithm survey/closeout | 3 | DP and greedy tests, adoption audit, docs | complete |

Each batch must:

1. extract the tested implementation to matching `src/` paths;
2. make both demo and tests include that production source;
3. remove copied algorithm definitions from tests;
4. replace monolithic test entry points with focused named/tagged `@test`s;
5. adopt `@cases` or bracket only where they improve the contract;
6. retain leading doc strings on every `u:` function;
7. run human and TAP mlplunit modes plus all repository validation.

Completion is measured mechanically: every registered test delegates to
mlplunit, every applicable demo/test pair shares `src/` definitions, no local
assertion/lifecycle framework remains, native test registration is explicit,
and failures continue across files while producing a failing suite exit code.

The original 41-file migration is complete, and subsequent additions preserve
the contract: all 48 registered files execute shared production definitions
through native include and explicit `@test` registry suites. All 50 demos include those tested
sources. `scripts/check-mlplunit-adoption` mechanically compares configured
discovery with the test catalog and rejects missing includes, registrations,
registry execution, legacy `u:test` entry points, and copied framework helpers.
The lower-bound suite also uses reflected `@cases` for fixed-width numeric
rows; the other migrated tests retain direct assertions because their ragged
structures and policy cases are clearer as named code. No fixture was added:
these immutable algorithms have no resource lifecycle to set up or tear down.
