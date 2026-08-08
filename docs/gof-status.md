# Gang of Four Status and sw-MLPL Feature Priorities

Status date: 2026-08-07. All 90 demos and 170 native tests pass with
`mlpl-repl` 0.20.0 build commit `0904bfcf`. Twenty-two of 23 GoF patterns have
honest executable evidence; Singleton alone is gated.

## All 23 patterns

| Pattern | Evidence class | Executable evidence or exact gate |
|---|---|---|
| Abstract Factory | constrained fixed schema | related constructor UDFs in fixed records |
| Builder | constrained immutable stages | retained storage-plan drafts and final validation |
| Factory Method | preferred functional | injected fulfillment constructor |
| Prototype | value-oriented | retained immutable transit variants |
| Singleton | gated | evaluate-once module, private constructor/binding, stable export identity/lifecycle |
| Adapter | value-oriented | edge-list to CSR compatibility boundary |
| Bridge | constrained fixed protocol | two abstractions and direct/scaled implementations |
| Composite | closed tag | recursive expression part-whole tree |
| Decorator | constrained explicit environment | nested delegated quote wrappers |
| Facade | constrained boundary | simplified delivery interface; privacy conventional |
| Flyweight | value-oriented numeric | shared intrinsic table plus lightweight IDs |
| Proxy | constrained explicit state | protection Proxy with returned state/effects |
| Chain of Responsibility | constrained fixed nesting | handler-local short-circuit delegation |
| Command | constrained fixed schema | executable account command records |
| Interpreter | closed tag | arithmetic tree meaning and Result policy |
| Iterator | constrained explicit state | immutable collection/index cursor |
| Mediator | constrained fixed participants | decoupled inventory/billing coordination |
| Memento | value-oriented | immutable room-plan snapshots/history |
| Observer | constrained fixed subscribers | independent subscriber states/effects |
| State | closed tag | pure transitions plus effects-as-data |
| Strategy | preferred functional | injected scoring policies |
| Template Method | constrained fixed steps | invariant staged workflow with step UDFs |
| Visitor | constrained fixed algebra | evaluation/counting algebras over one tree |

The classification is part of the result. Fixed fields do not claim dynamic
registration, and closed tags do not claim open node/state families.

## Singleton acceptance test

Do not create a fake global or rename textual `include` as Singleton. A future
sw-MLPL implementation passes only when a demo can prove:

1. a module is evaluated once even when imported through two clients;
2. construction is private and clients receive only an exported immutable
   service/capability;
3. both clients observe the same documented module identity or lifecycle token;
4. initialization order and duplicate/cyclic imports have deterministic errors;
5. tests cannot bypass the private constructor through the public namespace.

The latest exact module and fixture contract is maintained in
[module-singleton-acceptance-contract.md](module-singleton-acceptance-contract.md).

## Ranked sw-MLPL changes

| Rank | Change | Bang for buck and demos improved/unlocked |
|---|---|---|
| 1 | UDF-capable `map`, `filter`, short-circuit `fold`, `scan`, `unfold`, `zip`, `partition`, `flat_map` | Replaces bespoke recursion; upgrades Iterator, Chain, Observer, Mediator, Visitor, Composite/Interpreter and many algorithms |
| 2 | Dynamic collections of callable/general values | Enables runtime chains, subscriptions, participant/factory registries, heterogeneous Command histories, general maps |
| 3 | Evaluate-once modules, imports, exports, privacy | Unlocks Singleton and preferred Facade/Proxy/Memento boundaries; removes relative-include packaging |
| 4 | Record update/spread, destructuring, lenses | Low implementation/user complexity; removes pervasive immutable record rebuilding in Builder, State, trees, caches |
| 5 | Tagged variants and pattern matching | Makes open error/event/tree/command shapes safe; upgrades closed Composite, Interpreter, State, Visitor |
| 6 | Composition, pipes, partial binding, closures or explicit-environment helpers | Simplifies Template Method, Decorator, Strategy and pipelines; callable core already works |
| 7 | Persistent/COW sharing plus diagnostics and scoped transients | Preserves pure APIs while fixing physical copy costs for vectors, maps, trees, graphs and histories |
| 8 | String sequences, bytes/files, JSON/TOML and versioned binary serialization | Unlocks text algorithms, parsers, real configuration/data interchange; quant formats remain for the ML demo repository |
| 9 | Catchable callable shape/arity diagnostics | Lets dynamic protocols reject incompatible UDFs as Result data instead of hard runtime failure |

These changes require no `malloc/free` API or borrow checker. Cycles remain
application-managed; advisory compile/lint detection should document them
without banning valid cyclic structures.
