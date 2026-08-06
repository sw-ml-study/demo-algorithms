# mlplunit Adoption

## Capability status

As of 2026-08-05, mlplunit and the current sw-MLPL binary provide every test
capability this repository requested. No sw-MLPL or mlplunit enhancement blocks
the migration:

- root configuration through `mlplunit.conf`;
- deterministic recursive `test_*.mlpl` discovery and explicit path/pattern
  selection;
- one fresh `mlpl-repl` process per test file;
- the shared documented `u:assert_*` API and structured failures;
- sandboxed native `include` backed by sw-MLPL `--source-dir`;
- native `@test` registration with reflection, names, tags, skips, and expected
  failures;
- reflected numeric `@cases` and `u:run_cases`;
- `bracket`-based setup/use/teardown adapters;
- human and TAP 13 reporting, failure continuation, and deterministic nonzero
  suite status.

`scripts/run-tests` validates the catalog and documentation contract, converts
runnable catalog rows to paths, and delegates the complete selection to one
mlplunit invocation. Extra arguments are passed through for native operations
such as `--format tap`, `--list`, patterns, or directory selection. The catalog
adds algorithm taxonomy and maturity metadata; it does not reimplement test
discovery, assertions, lifecycle, reporting, or exit handling.

## Repository adoption status

Tool capability is complete; corpus migration is in progress. The deque
vertical slice is complete:

- `src/deques/service_desk.mlpl` is the single production implementation;
- the executable demo includes it under the repository source sandbox;
- the test includes it through mlplunit's configured source root;
- three named/tagged `@test` functions replace the former copied implementation
  and monolithic test function.

The deque and 16-file sequence/search/sort batches are complete: 17 registered
files now use shared `src/` production definitions and native `@test` suites.
The remaining 24 files are scheduled in bounded associative/tree, graph, and
algorithm-survey batches. See
[mlplunit-migration.md](mlplunit-migration.md) for the live inventory.

Use `@cases` where cases are naturally numeric table rows. Use bracketed
fixtures only where setup and teardown own a real lifecycle; immutable local
algorithm values should remain direct. Every helper, test, setup, teardown,
and case function must retain a leading doc string.

## Include versus full modules

Shipped static `include` is the correct current mechanism for sharing source
and preserving included-file diagnostics. It is not the future full module
system: qualified namespaces, explicit exports, private helpers, evaluate-once
module identities, and dependency/cycle policy remain feature work. The corpus
can eliminate demo/test implementation copying now without pretending those
larger library-boundary capabilities already exist.

The adjacent mlplunit and sw-MLPL repositories are read-only dependencies for
this project. Re-inspect their current documentation before changing the
integration because both evolve rapidly, but do not describe shipped
capabilities as blockers.

Last inspected for this status refresh: mlplunit commit `04a2afa` and sw-MLPL
commit `c8514b46` (`mlpl-repl` 0.20.0) on 2026-08-05. These are observations,
not requests to freeze either project.
