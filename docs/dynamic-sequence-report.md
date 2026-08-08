# Dynamic Sequence Foundation Report

Updated 2026-08-07 with `mlpl-repl 0.20.0` build `6c4a1a24` and mlplunit
`71dd16f`.

## Executable evidence

The foundation currently has eight problem-solving mini-apps and eleven
conformance tests. Every registered script passes. Ten tests exercise the
eight mini-apps and lower-level vector representations; the eleventh covers basic
array memory operations.

| Structure | Mini-app problem | Dynamic | Demo loops | What is proven |
|---|---|---:|---:|---|
| Growable vector | fundraising goal day | yes | 0 | append, prefix scan, selection |
| Stack | browser Back history | yes | 0 | immutable LIFO push/pop and retained versions |
| Queue | fair printer scheduling | yes | 0 | immutable FIFO enqueue/dequeue and retained versions |
| Deque | urgent service desk | yes | 0 | immutable operations at both ends |
| Indexed singly linked list | urgent delivery insertion | yes | 3 | numeric handles, rewiring, validation, traversal |
| Indexed doubly linked list | editable delivery itinerary | yes | 0 | head/middle/tail edits, reciprocal traversal, stale handles, cycle rejection |
| Persistent cons list | newest-first alert feed | yes | 0 | nested records, sentinel, prepend, recursion, retained snapshots |
| Persistent cons list | expire old alerts while retaining an audit | yes | 0 | pop/drop, stable removal/filtering, empty/singleton boundaries, retained snapshots |

The demo corpus therefore contains three explicit loops in total, all in the
indexed linked-list mini-app: validation, target search, and traversal. Its
target is zero once user-defined functions can be passed to suitable
find/fold/unfold combinators. The other seven mini-apps already use zero
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
3. UDF-capable find/fold/unfold is needed to remove the singly linked-list's
   three traversal loops and replace bespoke doubly linked-list recursion;
   first-class named UDF values already work.
4. Shipped static include now lets demos and tests share production helpers
   with source-aware diagnostics; the corpus migration is complete. Full
   modules are still needed for namespaces, privacy, exports, and module-cycle
   policy, not for basic source reuse.
5. Numeric scalars stand in for IDs because strings are not yet a mature
   general sequence type.
6. The current parser does not continue an infix expression merely because an
   operator ends a line; parenthesized or single-line expressions avoid this.

Persistent-list pop, bounded drop, value removal, and cutoff filtering are now
executable. They preserve retained values but do not claim runtime structural
sharing. The ring-buffer queue/deque and indexed doubly linked list are also
executable alongside the singly linked arena.

## Tooling status

This report originally captured an earlier mlplunit revision. The current tool
also supports native include, `@test` reflection, `@cases`, bracket lifecycle,
configuration discovery, human/TAP reporting, failure continuation, and stable
suite exit status. See `mlplunit-adoption.md` for current status.
