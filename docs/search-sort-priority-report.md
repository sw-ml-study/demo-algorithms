# Search, Sort, and Priority Report

Originally verified 2026-08-05. Reverified 2026-08-06 with `mlpl-repl 0.20.0`
(local build commit `185003e3`) and mlplunit `3e344763`.

## Executable evidence

This saga added eight problem-solving mini-apps and eight matching conformance
tests. At saga closeout the repository had fourteen demos and seventeen tests;
the current repository has 64 demos and 59 test files, all passing.

| Algorithm/structure | Mini-app problem | Logical behavior | Demo loops |
|---|---|---|---:|
| Linear search | unsorted inventory lookup | O(n) | 0 |
| Binary search | reserved appointment lookup | O(log n) | 0 |
| Lower bound | duplicate-aware score insertion | O(log n) search + O(n) insertion | 0 |
| Reverse | outbound-to-return route | O(n) visits | 0 |
| Stable insertion sort | FIFO task priorities | O(n²) | 0 |
| Stable merge sort | delivery ETA ordering | O(n log n) | 0 |
| Binary min-heap/priority queue | incident dispatch | O(log n) enqueue/dequeue | 0 |
| Heap sort | shortest batch duration first | O(n log n) logical work | 0 |

The saga contains zero explicit loops in both demos and tests. Recursion
expresses sequential recurrence; array masks, `compress`, `concat`, `scatter`,
and scalar indexing express collection transformations.

## Coverage audit

- Search tests cover empty/singleton, absent, first/last boundaries,
  duplicates, and negative values.
- Reverse covers empty/singleton, odd/even sizes, duplicates, negatives,
  input immutability, and reversal as an involution.
- Insertion and merge sort cover empty/singleton, already/reverse sorted,
  odd/even sizes, negative keys, and parallel payload alignment.
- Sort stability is executable: equal-key payload IDs retain arrival order.
- The heap covers empty/singleton, duplicates, negative priorities,
  growth/shrinkage, ordered draining, heap invariants, and retained old values.
- Heap sort covers the same numeric boundaries and proves its input unchanged.

No sorting builtin implements any demo. The algorithms expose comparisons,
partitioning, insertion, merging, sifting, heap construction, and draining.

## Complexity and runtime constraints

The logical algorithms have conventional comparison counts, but immutable
array operations may copy full storage:

- reverse and insertion sort can perform O(n²) physical copying;
- merge sort's masks and repeated concatenation allocate more than an ideal
  O(n) auxiliary merge buffer;
- logical O(log n) heap updates can trigger O(n) array copies per sift step;
- heap sort can therefore incur O(n²) copying despite O(n log n) logical work.

Copy-on-write buffers, persistent vectors, slice/views, and scoped
builder/transient storage would improve physical cost without changing pure
observable semantics.

## Concrete module evidence

The priority-queue and heap-sort demos now include their tested implementations
from `src/heaps/priority_queue.mlpl` and `src/sorts/heap_sort.mlpl`; the native
mlplunit source-sharing migration is complete. Full modules remain useful for
namespaces, exports/privacy, load-once behavior, and module-cycle policy; they
no longer block sharing tested production source.

## Exact remaining gaps

No sw-MLPL or mlplunit change is required by the completed saga. Improvements
exposed by it are:

1. Complete the shipped-include migration for canonical heap/search/sort
   implementations; later add full module namespaces/privacy.
2. First-class comparator/key UDFs for policy-driven generic algorithms.
3. UDF-capable folds/unfolds for reusable traversal and construction.
4. Pure general slices/views/gather/put to replace mask/index boilerplate.
5. Copy-on-write, persistent vectors, or scoped builders for physical cost.
6. Tail-call optimization or a documented recursion-depth contract for large
   inputs.
7. Record/nested-array support sufficient to sort ordinary record collections
   rather than parallel numeric vectors.

The current mlplunit additionally supports native include, `@test` reflection,
`@cases`, bracket lifecycle, failure continuation, and deterministic suite
status. See `mlplunit-adoption.md`; re-inspect the evolving tool before changing
the integration rather than treating this report as a frozen interface.
