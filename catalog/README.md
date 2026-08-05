# Demo catalog

The catalogs are machine-readable inventories consumed by the runners:

- `demos.tsv` contains only problem-solving mini-apps that show a meaningful
  result.
- `tests.tsv` contains assertion/pass-fail conformance scripts.

Both use the same tab-separated fields so the harness needs no package manager
or third-party parser.

Required columns:

| Column | Contract |
|---|---|
| `id` | Stable lowercase identifier using letters, digits, `_`, or `-` |
| `path` | Repository-relative `.mlpl` path under the catalog's matching `demos/` or `tests/` tree |
| `data_structure` | Primary structure demonstrated |
| `algorithm` | Operation or algorithm demonstrated |
| `dynamic_size` | `yes` or `no` |
| `explicit_loops` | Non-negative integer in the current script |
| `target_loops` | Non-negative integer after planned language features |
| `required_features` | Comma-separated feature IDs, or `current` |
| `status` | `runnable`, `constrained`, or `gated` |

`runnable` and `constrained` entries must name an existing script. A `gated`
entry may name its planned location before the script exists. The catalog
validator rejects duplicate IDs and paths, cross-kind paths, malformed values,
missing files, and a target loop count larger than the current count.

A demo may explain its input and method in comments, but it must visibly solve
a problem rather than end in a wall of assertions. Detailed correctness cases
belong in the corresponding test script.
