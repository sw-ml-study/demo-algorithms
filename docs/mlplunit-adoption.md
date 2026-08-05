# mlplunit Adoption

## What works today

mlplunit is under active, rapid development. This section records observed
behavior, not a pinned or exhaustive API contract; inspect the adjacent
checkout and rerun its own tests before every harness-related change.

The existing mlplunit runner works with the pinned sw-MLPL binary without
changes to either adjacent repository. It provides:

- a fresh `mlpl-repl` process and data directory per test;
- a growing shared assertion API (currently including boolean, equality,
  inequality, ordering, approximation, Result, and explicit-failure helpers);
- explicit-file execution for the catalog runner;
- recursive, deterministic `test_*.mlpl` discovery for local development;
- human and TAP output, quiet mode, and repository configuration;
- useful nonzero status and captured interpreter output on failure.

`scripts/run-tests` retains the repository's catalog, status, and feature-gate
policy, while delegating each runnable test to mlplunit. It accepts
`MLPLUNIT=/path/to/mlplunit`, searches `PATH`, and finally checks the adjacent
development checkout.

## Current boundary

mlplunit prepends its assertion library by source concatenation. This removes
duplicated test assertions now, but demos and tests still duplicate their
algorithm helpers. Its `--include` option could prove a proposed helper split,
but this repository will not make textual inclusion its production module
model.

No mlplunit or sw-MLPL change is required for the current nine-test suite.

## Improvements to evaluate as the suite grows

These are candidates, not current blockers, and may already be addressed by a
newer mlplunit revision when revisited:

- **mlplunit:** an installed/version-reporting workflow would make CI and
  reproducible setup clearer than relying on an adjacent checkout.
- **sw-MLPL:** static modules/imports are needed to share production helpers
  with namespaces, explicit exports, privacy, cycle diagnostics, and accurate
  source spans.
- **sw-MLPL:** richer structural equality and value formatting would improve
  assertion diagnostics for records, variants, and future nested arrays.

When static modules arrive, move data-structure and algorithm helpers into
`lib/`, import them from both demos and tests, and decide whether mlplunit's
assertion API should itself be exposed as an importable module. Keep isolated
test processes and catalog gating unchanged.

Last inspected: mlplunit commit `cee246c` on 2026-08-05. This identifier is an
observation for reproducibility, not a request to freeze ongoing development.
