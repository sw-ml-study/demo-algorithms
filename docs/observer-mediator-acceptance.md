# Fixed Functional Observer and Mediator Acceptance

Status date: 2026-08-06. Fixed-schema Observer and Mediator run on current
sw-MLPL 0.20.0.

`sale_observers.mlpl` invokes independent inventory and audit subscriber UDFs
with one event. Each returns its own immutable state and effects; prior states
remain observable. This is honest fixed Observer evidence, but not dynamic
subscription. Dynamic Observer needs a callable/general-value collection and a
UDF fold over subscriber states/effects.

`order_mediator.mlpl` coordinates callable inventory reservation and billing
transitions. Participants receive only request, state, and environment and
never invoke one another. The Mediator owns sequencing and combines immutable
states/effects. Dynamic Mediator still needs a callable participant registry,
general state map, folds, variants, and module boundaries.

Singleton is now the only GoF pattern without executable evidence. It remains
intentionally gated: textual include or a global value cannot establish
evaluate-once module identity, private construction, or controlled lifecycle.
