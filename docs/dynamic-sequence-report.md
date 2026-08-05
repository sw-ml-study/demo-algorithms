# Dynamic Sequence Foundation Report

Verified 2026-08-05 with `mlpl-repl 0.20.0` (sw-MLPL `c7ef96bd`) and
mlplunit `cb86b57`.

## Executable evidence

The foundation currently has six problem-solving mini-apps and nine
conformance tests. Every registered script passes. Eight tests exercise the
six mini-apps and lower-level vector representations; the ninth covers basic
array memory operations.

| Structure | Mini-app problem | Dynamic | Demo loops | What is proven |
|---|---|---:|---:|---|
| Growable vector | fundraising goal day | yes | 0 | append, prefix scan, selection |
| Stack | browser Back history | yes | 0 | immutable LIFO push/pop and retained versions |
| Queue | fair printer scheduling | yes | 0 | immutable FIFO enqueue/dequeue and retained versions |
| Deque | urgent service desk | yes | 0 | immutable operations at both ends |
| Indexed singly linked list | urgent delivery insertion | yes | 3 | numeric handles, rewiring, validation, traversal |
| Persistent cons list | newest-first alert feed | yes | 0 | nested records, sentinel, prepend, recursion, retained snapshots |

The demo corpus therefore contains three explicit loops in total, all in the
indexed linked-list mini-app: validation, target search, and traversal. Its
target is zero once user-defined functions can be passed to suitable
find/fold/unfold combinators. The other five mini-apps already use zero
explicit loops. Test loop counts match their corresponding implementations.

## What sw-MLPL can do now

- Dynamically grow and shrink numeric sequences using pure returned values.
- Represent stack, queue, and deque APIs as records plus named functions.
- Model application-managed references with numeric arena indices.
- Model heterogeneous recursive immutable lists with nested records and an
  explicit empty sentinel.
- Retain prior values and demonstrate semantic persistence.
- Use recursion, whole-array primitives, Result propagation, records, and
  deterministic script output for small general-purpose applications.
- Run each conformance test in an isolated mlplunit process with shared
  assertions and human or TAP reporting.

No `malloc`, `free`, tracing GC, borrow checker, or sw-MLPL change was needed.

## Exact remaining constraints

These are limitations exposed by this phase, not blockers for the completed
scripts:

1. Pure array updates and concatenation currently copy storage, so logical
   O(1) stack/queue/deque operations are physically O(n).
2. Nested immutable records provide persistence semantics, but efficient
   Clojure-style structural sharing is not yet established by the runtime.
3. First-class UDF values and UDF-capable find/fold/unfold are needed to remove
   the linked-list's three traversal loops and express reusable policies.
4. Static modules/imports are needed for demos and tests to share production
   helpers with namespaces, privacy, cycle diagnostics, and correct source
   spans. mlplunit source composition currently shares assertions only.
5. Numeric scalars stand in for IDs because strings are not yet a mature
   general sequence type.
6. The current parser does not continue an infix expression merely because an
   operator ends a line; parenthesized or single-line expressions avoid this.

The planned ring-buffer queue, doubly linked list, and shrinking persistent
list operations remain future demos. Their absence does not invalidate the
working FIFO queue, singly linked application arena, or cons-list evidence.

## Tooling status

mlplunit is evolving rapidly. At the inspected revision it supports config
files, human/TAP formats, quiet mode, include composition, recursive discovery,
and richer assertion diagnostics. Re-inspect its current CLI and assertion
library before any harness change. A version-reporting/install workflow would
still improve reproducibility; it is not required by this repository today.
