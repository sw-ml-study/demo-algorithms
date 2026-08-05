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

Verified baseline: `mlpl-repl 0.20.0`, sw-MLPL commit `c7ef96bd`
(2026-08-05).

The repository now contains eleven working mini-apps and fourteen conformance tests,
as well as the longer implementation plan. See
[PLAN.md](PLAN.md) for the taxonomy, capability analysis, proposed file tree,
feature gaps, and delivery sequence. [DESIGN_PATTERNS.md](DESIGN_PATTERNS.md)
maps all 23 Gang of Four patterns to functional sw-MLPL forms, and
[MEMORY_DESIGN.md](MEMORY_DESIGN.md) analyzes dynamic values without
`malloc`/`free`, a language borrow checker, or a mandatory tracing GC.
The dated [dynamic-sequence foundation report](docs/dynamic-sequence-report.md)
summarizes executable evidence, loop counts, and remaining gaps.

## Scripts: demos versus tests

This repository uses two distinct kinds of `.mlpl` script:

- **Demos** are small applications. Each states a concrete problem, explains
  the data structure and algorithm used to solve it, and produces a meaningful
  result for a reader to inspect.
- **Tests** are assertion-heavy conformance scripts. Their product is a final
  `Ok(...)` or `Err(...)`, and the harness treats that result as pass/fail.

The original assertion-heavy scripts live under `tests/`; result-oriented
mini-apps live under `demos/` with matching conformance coverage.

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

## Prerequisite: mlplunit for tests

Conformance tests use
[mlplunit](https://github.com/softwarewrighter/mlplunit) for isolated processes
and shared assertions. `scripts/run-tests` resolves it from `MLPLUNIT`, then
`PATH`, then the adjacent development checkout at
`../../softwarewrighter/mlplunit/bin/mlplunit`.

Run one currently working conformance test through mlplunit:

```sh
MLPL=../sw-mlpl/target/release/mlpl-repl \
  ../../softwarewrighter/mlplunit/bin/mlplunit \
  tests/vectors/test_array_memory.mlpl
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

To use another mlplunit checkout or installation:

```sh
MLPLUNIT=/absolute/path/to/mlplunit ./scripts/run-tests
```

Test files follow mlplunit's `test_*.mlpl` discovery convention. Directly
running a test with `mlpl-repl` alone no longer works because the assertion
prelude is deliberately supplied by mlplunit.

All scripts run in terminal script mode without the web UI.

## Currently working scripts

These conformance tests are currently registered and pass against the baseline
interpreter:

| Script | Structure and algorithm | Kind |
|---|---|---|
| `tests/vectors/test_array_memory.mlpl` | Vector read, pure write, and swap | Conformance test |
| `tests/vectors/test_growable_vector.mlpl` | Immutable append and pop | Conformance test |
| `tests/vectors/test_chunked_vector.mlpl` | Chunked append, capacity growth, and indexed read | Conformance test |
| `tests/vectors/test_campaign_goal.mlpl` | Prefix sum and first goal-reaching day | Conformance test |
| `tests/stacks/test_browser_back_history.mlpl` | Immutable LIFO push/pop | Conformance test |
| `tests/queues/test_printer_jobs.mlpl` | Immutable FIFO enqueue/dequeue | Conformance test |
| `tests/deques/test_service_desk.mlpl` | Immutable operations at both ends | Conformance test |
| `tests/linked_lists/test_delivery_route.mlpl` | Index-backed insert-after and traversal | Conformance test |
| `tests/persistent_lists/test_alert_feed.mlpl` | Immutable prepend and recursive traversal | Conformance test |
| `tests/search/test_linear_search.mlpl` | First match in an unsorted vector | Conformance test |
| `tests/search/test_binary_search.mlpl` | Logarithmic lookup in a sorted vector | Conformance test |
| `tests/search/test_lower_bound.mlpl` | First legal sorted insertion position | Conformance test |
| `tests/sequences/test_reverse.mlpl` | Recursive immutable numeric reversal | Conformance test |
| `tests/sorts/test_insertion_sort.mlpl` | Stable insertion sort over parallel vectors | Conformance test |

`catalog/demos.tsv` drives `scripts/run-all`; `catalog/tests.tsv` drives
`scripts/run-tests`. The demo catalog lists only result-oriented mini-apps.

### Working mini-app demos

| Demo | Problem solved | Data structure and algorithm |
|---|---|---|
| `demos/vectors/campaign_goal.mlpl` | Find the first day cumulative donations reach a fundraising goal | Growable vector, prefix sum, and first matching index |
| `demos/stacks/browser_back_history.mlpl` | Return to the correct page after pressing a browser Back button twice | Immutable stack with LIFO push/pop |
| `demos/queues/printer_jobs.mlpl` | Process shared-printer jobs fairly in arrival order | Immutable queue with FIFO enqueue/dequeue |
| `demos/deques/service_desk.mlpl` | Serve urgent requests first without reversing regular arrivals | Immutable deque with insertion/removal at both ends |
| `demos/linked_lists/delivery_route.mlpl` | Insert an urgent delivery stop without shifting existing logical nodes | Index-backed singly linked list with insert-after and traversal |
| `demos/persistent_lists/alert_feed.mlpl` | Show newest alerts while retaining an earlier audit snapshot | Persistent immutable cons list with prepend and recursive traversal |
| `demos/search/linear_inventory_lookup.mlpl` | Locate a part on an unsorted shelf | Recursive linear search |
| `demos/search/binary_appointment_lookup.mlpl` | Determine whether an appointment time is reserved | Recursive binary search |
| `demos/search/lower_bound_scoreboard.mlpl` | Insert a tied score before existing equals | Recursive lower bound plus pure insertion |
| `demos/sequences/return_route.mlpl` | Derive a return route from outbound checkpoints | Recursive immutable reversal |
| `demos/sorts/stable_task_order.mlpl` | Order tasks by priority while retaining FIFO ties | Stable recursive insertion sort over parallel vectors |

## Planned repository shape

```text
demos/               # problem-solving mini-apps, grouped by data structure
  vectors/
  stacks/
  queues/
  linked_lists/
  persistent_lists/
  search/
  sequences/
  sorts/
  hash_tables/
  trees/
  graphs/
tests/               # assertion/pass-fail scripts in matching subdirectories
  vectors/
  stacks/
  queues/
  linked_lists/
  persistent_lists/
  search/
  sequences/
  sorts/
  hash_tables/
  trees/
  graphs/
lib/                 # shared u: functions once modules/imports exist
catalog/             # demo and test inventories
scripts/             # validation and execution harnesses
docs/                # analysis and plans
```

Until MLPL has modules/imports, each demo remains standalone and may repeat
algorithm helpers. Tests already share mlplunit's assertion prelude through a
runner-level source-composition bridge. Once static modules exist, demos and
tests can import the same production helpers without textual concatenation.

## Copyright and license

Copyright (c) 2026 Michael A Wright. See [COPYRIGHT](COPYRIGHT).

This project is available under the [MIT License](LICENSE).
