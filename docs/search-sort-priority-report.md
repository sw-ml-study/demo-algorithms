# Search, Sort, and Priority Report

Verified 2026-08-05 with `mlpl-repl 0.20.0` (sw-MLPL `bdc12eed`) and
mlplunit `cee246c`.

## Executable evidence

This saga added eight problem-solving mini-apps and eight matching conformance
tests. The repository now has fourteen demos and seventeen tests, all passing.

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

The priority-queue and heap-sort scripts duplicate the same dense-heap
mechanism: swap, sift-up, sift-down, insert, and remove-min. Demo/test pairs
also copy each production algorithm because sw-MLPL has no imports. This is
now sufficient evidence for an eventual `lib/heap.mlpl` plus narrow search and
sort modules once static modules/imports land.

mlplunit's source composition is appropriate for assertions, but making it the
production dependency mechanism would lose namespaces, exports/privacy,
load-once behavior, cycle diagnostics, and accurate per-file source spans.

## Exact remaining gaps

No sw-MLPL or mlplunit change is required by the completed saga. Improvements
exposed by it are:

1. Static modules/imports for canonical heap/search/sort implementations.
2. First-class comparator/key UDFs for policy-driven generic algorithms.
3. UDF-capable folds/unfolds for reusable traversal and construction.
4. Pure general slices/views/gather/put to replace mask/index boilerplate.
5. Copy-on-write, persistent vectors, or scoped builders for physical cost.
6. Tail-call optimization or a documented recursion-depth contract for large
   inputs.
7. Record/nested-array support sufficient to sort ordinary record collections
   rather than parallel numeric vectors.

At the inspected revision, mlplunit supports configuration, human/TAP output,
quiet mode, recursive discovery, shared assertions, and isolated processes.
Because it is evolving rapidly, re-inspect rather than treating this list as a
frozen interface.
