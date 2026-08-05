# mlplunit Adoption

## What works today

The existing mlplunit runner works with the pinned sw-MLPL binary without
changes to either adjacent repository. It provides:

- a fresh `mlpl-repl` process and data directory per test;
- shared `assert_true`, `assert_false`, `assert_eq`, `assert_approx`,
  `assert_ok`, `assert_err`, and `fail` helpers;
- explicit-file execution for the catalog runner;
- recursive, deterministic `test_*.mlpl` discovery for local development;
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

No mlplunit or sw-MLPL change is required for the current eight-test suite.

## Improvements to evaluate as the suite grows

These are candidates, not current blockers:

- **mlplunit:** a machine-readable summary would let the catalog runner report
  one aggregate result without parsing human output.
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
