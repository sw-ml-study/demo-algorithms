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

## Intended usage

Point `MLPL` at a built `mlpl-repl` binary and run one script:

```sh
MLPL=../sw-mlpl/target/release/mlpl-repl
"$MLPL" demos/algorithms/search/linear_search.mlpl
```

Every eventual demo will be executable without the web UI, deterministic,
small enough to read in one sitting, and self-checking. A successful script
will finish with `ok(...)`; a failed invariant will finish with `err(...)`,
which makes `mlpl-repl` exit nonzero.

## Planned repository shape

```text
demos/
  foundations/       # array-as-memory, records, invariants
  linear/            # stack, queue, linked list, deque
  associative/       # sets, maps, hashing
  trees/             # traversal, BST, heap, AVL
  graphs/            # representations, traversal, paths, MST
  algorithms/
    search/
    sort/
    sequence/
    divide_conquer/
    dynamic_programming/
    backtracking/
lib/                 # shared u: functions once modules/imports exist
tests/               # shell-level golden and exit-code tests
docs/                # generated catalog and capability reports
```

Until MLPL has modules/imports, each `.mlpl` file will remain standalone and
may repeat a few helper functions. That repetition is intentional: demos must
run with today's binary.

## Copyright and license

Copyright (c) 2026 Michael A Wright. See [COPYRIGHT](COPYRIGHT).

This project is available under the [MIT License](LICENSE).
