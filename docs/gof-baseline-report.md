# Functional GoF Baseline Closeout

Status date: 2026-08-06. Verified with `mlpl-repl` 0.20.0 build commit
`3cc61287` and mlplunit 0.1.0 commit `6f7ac47`.

## Outcome

Eight honest pattern baselines are executable: Adapter, Prototype, Flyweight,
Memento, closed Composite, closed Interpreter, closed State, and explicit
Iterator. Seven pattern mini-apps and seven focused test files share production
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

## All 23 patterns: evidence and gates

Cluster names refer to the prioritized feature groups below.

| Pattern | Current evidence | Preferred status | Smallest next gate |
|---|---|---|---|
| Abstract Factory | none; a tag selecting constructors is not a function family | blocked | A: callable UDF values stored in records |
| Builder | fixed named transformations are possible | constrained, no dedicated baseline | C1: record update/spread; then pipes |
| Factory Method | a tag switch cannot inject construction behavior | blocked | A: callable UDF parameter |
| Prototype | retained transit graph variants | executable, ergonomic/cost constraints | C1 record updates/lenses; C2 sharing for efficiency |
| Singleton | a global/service locator is intentionally rejected | blocked as module pattern | D: module-private immutable binding and explicit export |
| Adapter | edge-list to target-only CSR route index | executable | D modules for privacy only |
| Bridge | fixed representation branches do not decouple abstraction from implementation | blocked | A: injected callable implementation/protocol record |
| Composite | numeric expression part-whole tree | executable closed baseline | A+B+C1: UDF algebra/fold plus variants for open form |
| Decorator | opcode-selected wrappers are not behavior wrapping | blocked | A: higher-order UDFs and closure/explicit environment |
| Facade | one public function can approximate shape but cannot define a library boundary | blocked preferred form | D: modules, private helpers, explicit exports |
| Flyweight | shared numeric shipment table plus IDs/quantities | executable | C2 persistent/COW storage and diagnostics improve cost evidence |
| Proxy | a tag branch is not protocol-substitutable behavior | blocked | A+D: callable protocol plus capability/effect boundary |
| Chain of Responsibility | hard-coded `if` chain is not a sequence of handlers | blocked | A+B: UDF sequence and short-circuit fold |
| Command | numeric event tags lack executable behavior payloads | blocked | A+C1: callable values in command records; variants for arguments |
| Interpreter | numeric arithmetic tag evaluator | executable closed baseline | A+B+C1: UDF algebra/fold and variants; strings only for parser domain |
| Iterator | immutable collection/index cursor | executable explicit baseline | A+B: UDF-capable fold/scan/unfold/each |
| Mediator | central opcode router directly knows all participants | blocked | A+B+C1: function registry, fold, nested/map state |
| Memento | numeric room-plan snapshot history | executable | D privacy and C2 persistent storage for general form |
| Observer | effect vectors exist, but subscribers are not callable/delegated | blocked | A+B+D: UDF subscribers, fold, effect capability boundary |
| State | immutable incident workflow plus effects | executable closed baseline | A+C1: transition function table/variants; B for histories |
| Strategy | tag-selected policy is central dispatch, not substitution | blocked; first acceptance target | A: pass and uniformly invoke one named UDF |
| Template Method | fixed named pipeline cannot accept overridable steps | blocked | A: step functions plus composition/pipe |
| Visitor | another tree tag switch is not an open operation algebra | blocked preferred form | A+B+C1: UDF algebra record, fold, variants |

## Prioritized feature clusters

1. **C1 — low-hanging value ergonomics:** general pure point/gather/slice
   update, record update/spread, and destructuring. These remain the first
   small high-return changes across all algorithms, and make Builder and clean
   Prototype practical.
2. **A — behavior as values:** quote/store/pass named UDFs and invoke builtins
   and UDFs uniformly; then composition, pipe, partial binding, and explicit
   environments/closures. This is the next architectural milestone and the
   gate shared by Strategy, factories, Bridge, Decorator, Proxy, Command,
   Template Method, and much of the remaining matrix.
3. **B — reusable traversal:** UDF-capable `map`, `filter`, `fold`,
   short-circuit fold, `scan`, `unfold`, `zip`, `partition`, and `flat_map`.
   This turns callable behavior into pipelines and unlocks Chain, Observer,
   Visitor, Mediator, and the preferred Iterator vocabulary.
4. **D — library/effect boundaries:** modules with namespaces, exports,
   privacy, and evaluate-once identity; capability records and an outer effect
   interpreter. Static include already shares source, but does not complete
   Facade, module Singleton, private Memento, or effectful Proxy/Observer.
5. **C2 — richer efficient values:** tagged variants/pattern matching, nested
   data, integer maps, COW/persistent structures, and sharing diagnostics.
   These open closed Composite/Interpreter/State forms and improve histories
   without exposing allocation, ownership, or a borrow checker.
6. **General domains later:** mature strings, files, and serialization enable
   parsers and text-oriented examples, but are not prerequisites for the
   numeric functional core or first-class delegation.

The priority distinction matters: record updates are still the best small
ergonomic win, but first-class UDF values plus UDF-capable folds/composition
are the highest-leverage architectural milestone. They replace many unrelated
tag switches with one coherent delegation model.

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

The next feature-gated acceptance demo should be **numeric Strategy**: inject a
named comparator or scoring UDF into an existing sort or routing selector, run
the unchanged client with at least two policies, and test substitutability.
Keep it gated until sw-MLPL can pass and uniformly invoke named UDF values.
Once that works, add a UDF-capable fold and use it to refactor the explicit
Iterator and implement Chain of Responsibility. This sequence gives the
clearest evidence that behavior has truly become data.

## Reproduction

```sh
./scripts/run-all
./scripts/run-tests
./scripts/run-tests --format tap
./scripts/check-docstrings
./scripts/check-mlplunit-adoption
./tests/test-harness
```

At closeout these commands report 55 passing demos, 72/72 passing native
tests/cases from 53 files, 490/490 documented user functions, and agreement
between catalogs and the shared-source audit.
