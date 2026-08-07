# Modern general-purpose hashing assessment

Assessment date: 2026-08-07. This is a general-purpose data-structure review,
not an ML similarity-hashing or cryptographic-hashing proposal.

## Decision

Do not add a purported elastic, funnel, rainbow, zombie, or adaptive hash-table
demo yet. Current sw-MLPL can encode a small deterministic imitation, but it
cannot reproduce the models, randomized assumptions, packed layouts, or useful
performance measurements behind the recent results. Such a script would look
current while teaching the wrong claim.

The best next executable experiment, after the gates below, is **funnel
hashing**. It is the clearest match for the request to explore a striking recent
improvement, it extends this repository's open-addressing sequence directly,
and it has a precise paper model and probe-count claims. Until then, the current
linear-probing maps remain the honest teaching baseline.

## Three different meanings of “better hashing”

| Area | Question | Current repository evidence | Recent example |
|---|---|---|---|
| hash function / mixer | How are keys converted into reproducible, well-distributed numeric values? | a bounded signed-integer affine mixer with golden buckets; explicitly pedagogical | adaptive selection of weak and robust hash functions |
| hash-table organization | How are collisions, probes, deletion, load, and resizing managed? | linear probing, tombstones, resize/rehash, and separate chaining | elastic/funnel, rainbow, and zombie hashing |
| cryptographic hashing | Can an adversary find collisions, preimages, or denial-of-service keys? | deliberately absent | SHA-family, keyed SipHash-like defenses, password hashing |

These claims are not interchangeable. A table can improve probe complexity
without inventing a new mixer, and a fast non-cryptographic mixer is not a safe
password hash or an automatic defense against adversarial keys.

## Primary-source findings

### Elastic and funnel hashing

Farach-Colton, Krapivin, and Kuszmaul's
[Optimal Bounds for Open Addressing Without Reordering](https://arxiv.org/abs/2501.02305)
(FOCS 2024) studies insert-only open addressing with independently randomized
probe sequences. Elastic hashing is non-greedy and achieves O(1) amortized
expected probe complexity plus O(log epsilon^-1) worst-case expected probe
complexity at load `1-epsilon`, without moving previously inserted items.
Funnel hashing is greedy and disproves Yao's worst-case conjecture with
O(log^2 epsilon^-1) worst-case expected probes. These are probabilistic,
asymptotic results under a specified model; they are not claims about the
quality of one arithmetic hash expression.

### Rainbow hashing

Bender, Kuszmaul, and Zhou's
[Tight Bounds for Classical Open Addressing](https://arxiv.org/abs/2409.11280)
introduces rainbow hashing for dynamic insertions and deletions at load
`1-epsilon`: expected O(1) queries and O(log log epsilon^-1) updates, including
dynamic resizing. This is substantially more machinery than this repository's
single-array linear probing and depends on randomized hashing and compact
metadata. It is unrelated to password-cracking “rainbow tables.”

### Zombie hashing

Chesetti, Shi, Phillips, and Pandey's
[Zombie Hashing: Reanimating Tombstones in a Graveyard](https://users.cs.utah.edu/~jeffp/papers/zombieht.pdf)
(SIGMOD 2025) is an empirical systems design for ordered and vectorized linear
probing at high load. It uses tombstone-like metadata to limit primary
clustering and emphasizes throughput, locality, SIMD, and redistribution
behavior. The existing tombstone demo explains deletion correctness, but it
cannot validate Zombie's hardware-sensitive performance claims.

### Adaptive hashing

Melis's
[Adaptive Hashing: Faster Hash Functions with Fewer Collisions](https://arxiv.org/abs/2602.05925)
adapts the selected hash function online to the observed keys, combining a
cheap common-case function with a robust fallback when collision evidence
shows the current choice is poor. This is a policy and instrumentation result
as well as a mixer result. It would become a strong functional Strategy demo
once maps accept injected hash/equality policies and sw-MLPL can hash general
keys.

### Modern Hashing Made Simple

Bender, Farach-Colton, John Kuszmaul, and William Kuszmaul's
[Modern Hashing Made Simple](https://epubs.siam.org/doi/10.1137/1.9781611977936.33)
(SOSA 2024) is explicitly pedagogical, but its succinct-space guarantee still
assumes bit-level representations and randomized components that current
numeric arrays do not model faithfully. It is an important design reference,
not license to claim its space bound for boxed floating-point values.

## Implementation audit

The paper remains the normative specification for the selected funnel
experiment; this review did not find an author-maintained reference
implementation linked by it. Third-party packages now claim elastic/funnel
implementations, but their assertions and traces should not become golden
fixtures without a line-by-line paper audit. In particular, one published
Python package links a placeholder source URL while claiming the asymptotic
guarantees, which is not sufficient provenance for this repository.

Adaptive hashing does have the author's
[SBCL `adaptive-hash` implementation branch](https://github.com/melisgl/sbcl/tree/adaptive-hash),
including benchmark material. That code is useful future evidence for policy,
collision instrumentation, and fallback behavior, but it is tightly integrated
with SBCL's general-key tables and runtime representation. It reinforces rather
than removes the sw-MLPL gates for injectable policies and general key hashing.

## Why the candidate is gated today

An honest funnel-hashing experiment should implement the paper's partitioned
table and probe distribution, generate reproducible independent probe choices,
run many insertions at controlled `epsilon`, and report successful and
unsuccessful probe distributions against a uniform-probing baseline. Current
sw-MLPL is missing or weak in the following order:

1. **Exact fixed-width integers and bitwise operations.** Hash arithmetic and
   reproducible PRNG state must not silently cross floating-point precision.
   This also unlocks credible modern mixers and packed occupancy metadata.
2. **Seeded standard randomness or a documented splittable PRNG.** The paper's
   independent randomized probe families cannot be replaced by one affine
   deterministic bucket expression while retaining the theorem's meaning.
3. **Scoped transient/COW array builders.** Thousands of insertions currently
   copy full state vectors, so measurements would mostly benchmark immutable
   reconstruction rather than probing.
4. **Monotonic timing and benchmark support.** Probe counts are portable and
   should remain primary; throughput/locality claims for Zombie or adaptive
   hashing additionally need warmup, repeated trials, and elapsed-time APIs.
5. **Packed byte/bit storage and SIMD-oriented operations.** These are required
   before reproducing succinct-space or vectorized-locality claims.
6. **Injected hash/equality Strategy plus general key hashing.** This is needed
   for adaptive hashing and real string/byte keys, but not for the first
   numeric funnel probe experiment.

General UDF fold/scan would make insertion experiments shorter and expose
probe histories cleanly, but recursion can express the semantics; it is an
ergonomic improvement rather than the primary research-validity gate.

## Acceptance plan after gates 1–3

The future demo should solve a high-load numeric registry problem and include:

- deterministic seeded trials and the seed in every result;
- exact implementation notes mapping each table segment and probe phase to the
  paper, with no claim beyond the implemented variant;
- uniform probing and existing linear probing as named baselines;
- successful, unsuccessful, maximum, mean, and percentile probe counts over
  several loads, including retained input/trial state;
- invariants for unique placement, lookup completeness, capacity, termination,
  and no relocation of earlier keys;
- an independent lookup oracle and small golden seeded traces; and
- prominent separation of expected/asymptotic theory from one finite run.

The assessment itself added no executable rows. The subsequent classical Robin
Hood comparison is now available while funnel remains gated, bringing the live
repository to 78 demos, 72 test files, 133 native tests/cases, and 725
documented UDFs.
