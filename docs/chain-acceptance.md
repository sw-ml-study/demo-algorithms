# Fixed Functional Chain of Responsibility Acceptance

Status date: 2026-08-06. A fixed nested Chain runs on current sw-MLPL 0.20.0.

`purchase_approval.mlpl` nests team, manager, and terminal handler records.
Each record contains a callable UDF and environment; nonterminal environments
contain the next handler. A handler independently accepts or delegates the
unchanged request. The returned trace proves first-acceptance short circuit and
delegation order. Invalid and terminal-unhandled requests return Result errors.

There is no central opcode switch selecting handler behavior, so this is honest
Chain evidence. It is deliberately fixed-schema: constructing a runtime-sized
chain still requires a dynamic callable/general-value collection. Expressing
that chain without explicit recursion also requires a short-circuit UDF fold.

Observer and Mediator fixed-schema experiments now pass. Singleton remains
gated on evaluate-once modules, private binding, and explicit identity
semantics.
