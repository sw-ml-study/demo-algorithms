# Functional GoF Baseline Closeout

Status date: 2026-08-06. Verified with `mlpl-repl` 0.20.0 build commit
`185003e3` and mlplunit 0.1.0 commit `3e344763`.

## Outcome

Twenty-two honest pattern baselines are executable: Adapter, Prototype, Flyweight,
Memento, closed Composite, closed Interpreter, closed State, and explicit
Iterator, plus preferred functional Strategy, Factory Method, and fixed-record
Abstract Factory, fixed-protocol Bridge, functional Template Method, Decorator,
protection Proxy, fixed-schema Command, fixed-algebra Visitor, and constrained
Builder, constrained Facade, fixed nested Chain, fixed Observer, and fixed
Mediator. Twenty-one pattern mini-apps and seventeen focused test files share production
sources where definitions are new; Composite/Interpreter deliberately reuse
the established expression-tree source. Every pattern demo uses zero explicit
loops and zero target loops.

| Pattern evidence | Intent demonstrated | Boundaries and retention | Logical/current cost | Honest limit |
|---|---|---|---|---|
| Adapter | pure compatibility boundary from edge list to target-only CSR protocol | parity, zero-cost/isolated routes, invalid stops, retained source | O(VE); growing CSR copies | static schemas; modules would add privacy |
| Prototype | derive configured graph variants from a value | sibling independence, replacement/extension, retained prototypes | O(E)+O(V); affected vectors copied | no observable physical-sharing claim |
| Flyweight | separate intrinsic table from IDs and extrinsic quantities | repeated IDs, empty/invalid inputs, retained table | O(uses); growing output copies | no runtime interning/identity claim |
| Memento | originator edits separate from caretaker capture/restore/undo | multiple snapshots, two-step undo, shape/index errors, retained histories | O(state) access; O(history*state) copying | flat numeric state; no private representation |
| Composite | recursive part-whole expression structure | leaves/parts/whole, traversal, logical subtree reuse, retained part | O(nodes), O(height); nested records may copy | closed node family |
| Interpreter | assign arithmetic meaning and Result policy | deterministic tags, unknown/malformed/division errors | O(nodes), O(height) | central closed dispatch |
| State | state-dependent transitions returning effects-as-data | ownership, invalid event/transition, retained states, separate effect boundary | O(1) transition, O(effects) summary | central closed state/event dispatch |
| Iterator | independent immutable traversal state | empty/singleton/dynamic, exhaustion, independent cursors, stopped-item retention | O(items); growing accepted-output copies | explicit protocol, not general combinators |
| Strategy | inject interchangeable scoring behavior into one unchanged client | three policies, stable ties, deterministic calls, retained inputs | O(services); scalar candidate state | UDF folds/composition remain ergonomic improvements |
| Factory Method | inject product construction into one unchanged fulfillment workflow | two constructors, invalid requests, retained inputs | O(1); constant records | modules would package constructors |
| Abstract Factory | create coherent related products from a family record | two families, invalid capacity, mixed-family rejection | O(1); constant records | fixed fields; no dynamic registry/privacy |
| Bridge | vary usage/budget abstractions independently from direct/scaled meter implementations | parity, invalid readings/budgets, encoding mismatch, retained vectors | O(samples); constant result records | fixed protocol fields; no module boundary |
| Template Method | preserve prepare/analyze/publish order while substituting step sets | two workflows, stage ordering, errors, retention, effects-as-data | O(readings); normalized vector copies | explicit calls instead of composition/pipe |
| Decorator | wrap a quote protocol with surcharge and insurance layers | delegation order, invalid configuration, retained request | O(layers); growing accounting vector | explicit nested environments instead of closures/binding |
| Proxy | preserve inventory target protocol while controlling access | authorization, delegated errors, retained state/data, ordered effects | O(1); small copied records/vectors | no private module/capability boundary |
| Command | carry executable account behavior with arguments/environment | two commands, validation, retention, effects | O(1); constant records | no heterogeneous dynamic history |
| Visitor | apply evaluation and counting algebras to one expression tree | algebra substitution, retained tree, tag/division errors | O(nodes), O(height) | fixed tree/algebra schema; no generic fold |
| Builder | assemble a storage plan through retained validated drafts | required/optional stages, order, invalid/incomplete builds | O(1) per stage; full small-record rebuild | no record update/pipe/lens ergonomics |
| Facade | simplify delivery validation/pricing/fleet coordination | subsystem tests, propagated errors, retention, effects-as-data | O(fleet); constant result | include does not enforce private boundary |
| Chain | delegate purchase approval until first acceptance | short circuit, delegation trace, unhandled/invalid errors | O(visited handlers); growing trace | fixed nested schema, no runtime-sized chain |
| Observer | notify independent inventory/audit subscribers | independent states, errors, retention, ordered effects | O(subscribers), fixed at two | no dynamic subscription collection/fold |
| Mediator | coordinate inventory and billing participants | participant errors, retention, effects, no direct coupling | O(1), fixed at two | no dynamic registry/general state map |

## All 23 patterns: evidence and gates

Cluster names refer to the prioritized feature groups below.

| Pattern | Current evidence | Preferred status | Smallest next gate |
|---|---|---|---|
| Abstract Factory | local/remote constructor records create compatible product families | executable with fixed records | modules/general registries improve discovery/privacy |
| Builder | staged storage-plan transformations retain every draft | executable constrained baseline | record update/spread and pipes improve clarity |
| Factory Method | economy/expedited constructors injected into one workflow | executable preferred baseline | modules improve packaging |
| Prototype | retained transit graph variants | executable, ergonomic/cost constraints | C1 record updates/lenses; C2 sharing for efficiency |
| Singleton | a global/service locator is intentionally rejected | blocked as module pattern | D: module-private immutable binding and explicit export |
| Adapter | edge-list to target-only CSR route index | executable | D modules for privacy only |
| Bridge | direct/scaled meter protocol records serve two reporting abstractions | executable with fixed records | modules/dynamic registries improve boundary/discovery |
| Composite | numeric expression part-whole tree | executable closed baseline | A+B+C1: UDF algebra/fold plus variants for open form |
| Decorator | surcharge/insurance services recursively delegate through one quote protocol | executable with explicit environments | closures/binding/composition improve construction |
| Facade | delivery booking composes three tested subsystems behind one operation | executable constrained baseline | modules/private exports for enforceable boundary |
| Flyweight | shared numeric shipment table plus IDs/quantities | executable | C2 persistent/COW storage and diagnostics improve cost evidence |
| Proxy | protection Proxy authorizes then delegates through the inventory protocol | executable with explicit state/effects | modules/capabilities improve boundary privacy |
| Chain of Responsibility | purchase handlers independently accept or delegate through successors | executable fixed nested baseline; dynamic blocked | dynamic callable sequence and short-circuit UDF fold |
| Command | deposit/withdraw values carry callable payload, arguments, environment | executable fixed schema | general-value collections/variants for heterogeneous history |
| Interpreter | numeric arithmetic tag evaluator | executable closed baseline | A+B+C1: UDF algebra/fold and variants; strings only for parser domain |
| Iterator | immutable collection/index cursor | executable explicit baseline | A+B: UDF-capable fold/scan/unfold/each |
| Mediator | order mediator coordinates callable participants without direct calls | executable fixed baseline; dynamic blocked | callable registry, fold, nested/map state, variants |
| Memento | numeric room-plan snapshot history | executable | D privacy and C2 persistent storage for general form |
| Observer | sale notifier invokes two callable subscribers and returns states/effects | executable fixed baseline; dynamic blocked | dynamic callable collection, fold, general subscriber state/effects |
| State | immutable incident workflow plus effects | executable closed baseline | A+C1: transition function table/variants; B for histories |
| Strategy | economy/urgent/balanced UDFs injected into one selector | executable preferred baseline | B: UDF fold/composition simplifies client |
| Template Method | audit/capacity step records run through one staged skeleton | executable with explicit calls | composition/pipe and modules improve ergonomics |
| Visitor | evaluation/counting algebras are injected into one recursive traversal | executable fixed algebra | generic UDF fold, variants, modules for preferred open form |

## Prioritized feature clusters

1. **B — reusable traversal (highest remaining architectural gate):** UDF-capable `map`, `filter`, short-circuit `fold`, `scan`, `unfold`, `zip`, `partition`, and `flat_map`.
2. **E — dynamic callable/general-value collections:** runtime-sized chains,
   subscribers, participant/factory registries, and heterogeneous histories.
3. **D — library/effect boundaries:** evaluate-once modules, namespaces,
   exports, privacy, and capability boundaries. This is Singleton's exact gate.
4. **C1 — low-hanging value ergonomics:** general pure point/gather/slice
   update, record update/spread, destructuring, and lenses.
5. **C2 — safe open values:** tagged variants and pattern matching, followed
   by general maps and nested value improvements.
6. **A — behavior ergonomics (callable core shipped):** named UDFs can now be
   quoted/stored/passed and invoked uniformly. Strategy proves it. Composition,
   pipe, partial binding, and explicit environments/closures remain ergonomic
   follow-ons for Decorator, Proxy, and Template Method.
7. **Persistent efficiency:** COW/persistent storage, sharing diagnostics, and
   scoped transients without exposing allocation or ownership.
8. **General domains later:** mature strings, bytes/files, and serialization enable
   parsers and text-oriented examples, but are not prerequisites for the
   numeric functional core or first-class delegation.

9. **Callable diagnostics:** turn wrong UDF shape/arity into catchable Result
data for dynamic protocol validation.

## Why opcode approximations do not complete blocked patterns

A numeric tag can select a known branch and is useful for closed baselines.
It does not let an application supply new behavior without editing the client.
Therefore a tag switch does not establish substitutability for Strategy,
executable payloads for Command, handler sequences for Chain, subscriber
delegation for Observer, or independently extensible operations for Visitor.
The repository retains closed Composite, Interpreter, and State examples
because their limits are explicit and independently tested; it will not rename
the same mechanism to claim completion of the other patterns.

## Recommended next acceptance step

Strategy, Factory Method, fixed-record Abstract Factory, fixed-protocol Bridge,
Template Method, explicit-environment Decorator, protection Proxy, fixed-schema
Command, fixed-algebra Visitor, constrained Builder/Facade, fixed nested Chain,
fixed Observer, and fixed Mediator are complete. Singleton requires a real
module identity/privacy boundary. Dynamic Chain, Observer, and Mediator remain
gated on folds and/or callable collections.
In parallel, add a UDF-capable fold when available and use it to refactor Iterator and implement
dynamic Chain of Responsibility.

## Reproduction

```sh
./scripts/run-all
./scripts/run-tests
./scripts/run-tests --format tap
./scripts/check-docstrings
./scripts/check-mlplunit-adoption
./tests/test-harness
```

At the latest refresh these commands report 69 passing demos, 104/104 passing native
tests/cases from 63 files, 586/586 documented user functions, and agreement
between catalogs and the shared-source audit.
