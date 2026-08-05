# sw-MLPL Data Structures and Algorithms

General-purpose data-structure and algorithm demonstrations written as
standalone `.mlpl` scripts for the
[sw-MLPL](https://sw-ml-study.github.io/sw-mlpl/) interpreter.

This repository has two jobs:

1. Show that an array language designed around modern ML can also explain
   dynamically sized structures and ordinary programming clearly, with few
   explicit loops and preferably none.
2. Act as a forcing function: when a normal algorithm is awkward or
   impossible, record the missing language capability precisely and turn it
   into an executable acceptance case for sw-MLPL.

The demonstrations deliberately favor pure transformations, function
composition, delegation, and whole-array operations. An explicit loop is a
baseline or a last resort, not the intended destination. A sorting demo should
still expose the algorithm rather than merely call `grade_up`; the challenge is
to express its phases through reusable array combinators.

## Status

Planning baseline: sw-MLPL commit `16940f5d` (2026-08-05).

The repository is currently a design and implementation plan. See
[PLAN.md](PLAN.md) for the taxonomy, capability analysis, proposed file tree,
feature gaps, and delivery sequence. [DESIGN_PATTERNS.md](DESIGN_PATTERNS.md)
maps all 23 Gang of Four patterns to functional sw-MLPL forms, and
[MEMORY_DESIGN.md](MEMORY_DESIGN.md) analyzes dynamic values without
`malloc`/`free`, a language borrow checker, or a mandatory tracing GC.

## Scripts: demos versus tests

This repository uses two distinct kinds of `.mlpl` script:

- **Demos** are small applications. Each states a concrete problem, explains
  the data structure and algorithm used to solve it, and produces a meaningful
  result for a reader to inspect.
- **Tests** are assertion-heavy conformance scripts. Their product is a final
  `Ok(...)` or `Err(...)`, and the harness treats that result as pass/fail.

The first three vector scripts were written in the conformance style and live
under `tests/vectors/`. The first result-oriented vector mini-application is
the next planned script.

## Prerequisite: build sw-MLPL

The scripts require the `mlpl-repl` executable from
[sw-MLPL](https://github.com/sw-ml-study/sw-mlpl). A convenient checkout layout
places both repositories under the same parent directory:

```text
sw-ml-study/
  sw-mlpl/
  demo-algorithms/
```

Build the release interpreter from the sw-MLPL checkout:

```sh
cd ../sw-mlpl
cargo build --manifest-path components/cli/Cargo.toml -p mlpl-repl --release
cd ../demo-algorithms
```

The commands in this repository default to the resulting sibling binary:

```text
../sw-mlpl/target/release/mlpl-repl
```

No package installation or modification of the user's globally installed
`mlpl-repl` is required.

## Run scripts

Run one currently working conformance test directly:

```sh
../sw-mlpl/target/release/mlpl-repl tests/vectors/array_memory.mlpl
```

Run every registered problem-solving demo:

```sh
./scripts/run-all
```

Run every registered MLPL conformance test:

```sh
./scripts/run-tests
```

Run the harness contract tests, including proof that a final `Err` exits
nonzero:

```sh
./tests/test-harness
```

To use a binary in another location, set `MLPL` for either runner:

```sh
MLPL=/absolute/path/to/mlpl-repl ./scripts/run-all
MLPL=/absolute/path/to/mlpl-repl ./scripts/run-tests
MLPL=/absolute/path/to/mlpl-repl ./tests/test-harness
```

All scripts run in terminal script mode without the web UI.

## Currently working scripts

These conformance tests are currently registered and pass against the baseline
interpreter:

| Script | Structure and algorithm | Kind |
|---|---|---|
| `tests/vectors/array_memory.mlpl` | Vector read, pure write, and swap | Conformance test |
| `tests/vectors/growable_vector.mlpl` | Immutable append and pop | Conformance test |
| `tests/vectors/chunked_vector.mlpl` | Chunked append, capacity growth, and indexed read | Conformance test |

`catalog/demos.tsv` drives `scripts/run-all`; `catalog/tests.tsv` drives
`scripts/run-tests`. The demo catalog lists only result-oriented mini-apps.

### Working mini-app demos

| Demo | Problem solved | Data structure and algorithm |
|---|---|---|
| `demos/vectors/campaign_goal.mlpl` | Find the first day cumulative donations reach a fundraising goal | Growable vector, prefix sum, and first matching index |
| `demos/stacks/browser_back_history.mlpl` | Return to the correct page after pressing a browser Back button twice | Immutable stack with LIFO push/pop |
| `demos/queues/printer_jobs.mlpl` | Process shared-printer jobs fairly in arrival order | Immutable queue with FIFO enqueue/dequeue |
| `demos/deques/service_desk.mlpl` | Serve urgent requests first without reversing regular arrivals | Immutable deque with insertion/removal at both ends |

## Planned repository shape

```text
demos/               # problem-solving mini-apps, grouped by data structure
  vectors/
  stacks/
  queues/
  linked_lists/
  hash_tables/
  trees/
  graphs/
tests/               # assertion/pass-fail scripts in matching subdirectories
  vectors/
  stacks/
  queues/
  linked_lists/
  hash_tables/
  trees/
  graphs/
lib/                 # shared u: functions once modules/imports exist
catalog/             # demo and test inventories
scripts/             # validation and execution harnesses
docs/                # analysis and plans
```

Until MLPL has modules/imports, each `.mlpl` file will remain standalone and
may repeat a few helper functions. That repetition is intentional: demos and
tests must run with today's binary.

## Copyright and license

Copyright (c) 2026 Michael A Wright. See [COPYRIGHT](COPYRIGHT).

This project is available under the [MIT License](LICENSE).
