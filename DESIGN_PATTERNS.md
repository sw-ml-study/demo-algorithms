# The 23 GoF Patterns, Functionally Reframed for sw-MLPL

## Position

The goal is coverage of the ideas in all 23 Gang of Four patterns, not a
simulation of classes, inheritance, virtual methods, or mutable object graphs.
In sw-MLPL, prefer:

- function values for behavior;
- records for immutable configuration and state;
- composition and pipelines for assembly;
- delegation to narrow function protocols;
- folds/unfolds and state transitions for iteration;
- Results for failure;
- persistent values for snapshots, undo, and sharing semantics.

A pattern demo succeeds only if it preserves the pattern's intent: variability,
decoupling, lifecycle, notification, traversal, or state transition. Merely
naming a record “Factory” does not count.

Current status is assessed against the locally verified `mlpl-repl` 0.20.0
build identifying commit `185003e3` (2026-08-06). Named UDF references and
uniform `call` now work, including references stored in records. Strategy is
executable. Dynamic callable collections, UDF-capable folds/combinators,
composition/binding, variants, and modules still gate preferred forms. Closed
hard-coded branches are not presented as successful delegated patterns.

The current executable-baseline audit now has twenty-two patterns with honest
evidence, while Singleton remains module-gated. See
[docs/gof-baseline-report.md](docs/gof-baseline-report.md)
for the full 23-pattern matrix, evidence, costs, and priorities.

## Creational patterns

| Pattern | Functional sw-MLPL interpretation | Today | Needed for preferred demo |
|---|---|---|---|
| Abstract Factory | `analytics_abstract_factory.mlpl` supplies coherent worker/storage constructor families | Executable with fixed records | Modules/general registries enable extensible discovery and privacy |
| Builder | `storage_plan.mlpl` applies pure staged transformations and a final validated build | Executable constrained baseline | Record update/spread, pipes, lenses improve ergonomics |
| Factory Method | `fulfillment_factory_method.mlpl` injects economy or expedited construction into one workflow | Executable preferred baseline | Modules improve constructor packaging |
| Prototype | `event_transit_service.mlpl` derives graph variants through pure transformations | Executable, constrained ergonomics | Record update/spread and lenses improve clarity; structural sharing improves cost |
| Singleton | Module-scoped immutable value or explicit dependency passed once; avoid hidden global state | Sole gated pattern; no fake baseline | Evaluate-once modules, private construction/binding, explicit immutable export identity/lifecycle |

Creational acceptance scenario: construct several graph representations from
the same edge input. Factories choose dense/CSR storage; a builder configures
validation and capacity; prototype derives a modified graph without changing
the original. No ML domain is needed.

## Structural patterns

| Pattern | Functional sw-MLPL interpretation | Today | Needed for preferred demo |
|---|---|---|---|
| Adapter | `transit_departure_board.mlpl` converts an edge-list feed to a renamed CSR route-index protocol | Executable now for statically known schemas | Modules add protocol privacy; record update/destructuring improve clarity |
| Bridge | `energy_meter_reporting.mlpl` varies reporting abstractions independently from direct/scaled implementations | Executable with fixed protocol records | Modules/dynamic registries improve discovery and boundaries |
| Composite | `shipping_cost_expression.mlpl` recursively composes literal/operator records | Constrained, executable closed baseline | Numeric tagged trees work; open node families and a generic fold require tagged unions/pattern matching, UDFs/protocols, and modules |
| Decorator | `shipping_quote_layers.mlpl` delegates through nested quote services and adds accounting | Executable with explicit environments | Closures/binding/composition improve construction |
| Facade | `delivery_booking.mlpl` composes validation, pricing, allocation, and effects | Executable constrained baseline | Modules/private exports enforce the preferred boundary |
| Flyweight | `shipment_manifest.mlpl` separates one intrinsic type table from per-order IDs/quantities | Executable now numerically | Efficient sharing/COW and diagnostics strengthen it; strings are not assumed |
| Proxy | `inventory_access_proxy.mlpl` authorizes and delegates while returning state/effects | Executable protection Proxy | Modules/capabilities improve the boundary |

Structural acceptance scenario: an arithmetic-expression tree. Adapter
normalizes input arrays, Composite folds the tree, Decorator adds validation,
Bridge selects an evaluator, Flyweight stores repeated numeric constants by
index, and Facade exposes one `evaluate` pipeline.

The executable Adapter baseline keeps the departure-board consumer unaware of
edge-list fields: it receives only `{stops, offsets, destinations, minutes}`.
The pure adapter reuses the established CSR conversion, retains the source
graph, and is tested for representation parity and target-only behavior. This
preserves Adapter's compatibility-boundary intent without requiring classes,
inheritance, or first-class functions.

The executable Prototype baseline treats an existing graph value as the
prototype and applies named payload/route transformations to derive independent
observable versions. Tests retain the original and sibling variants. This is
Prototype's configured-copy intent without an OO `clone` method. sw-MLPL does
not currently expose storage identity, so the demo claims semantic value
independence, not physical copying or structural sharing.

The executable Flyweight baseline stores package weights and handling factors
once in an intrinsic numeric table. Order rows carry only a type ID and their
extrinsic quantity. Tests demonstrate repeated-ID reuse and retention of the
table. This preserves Flyweight's state-separation intent without small OO
objects; it does not claim runtime interning, pointer identity, or physically
shared storage because those properties are not observable today.

The executable Memento baseline keeps room-plan transitions in originator
functions and snapshot capture/restore/undo in caretaker functions. Flat
fixed-width numeric snapshots preserve multiple immutable revisions. This
provides Memento's restoration intent without OO objects. Modules could hide
memento representation from the caretaker; persistent storage could reduce
copying. Neither physical sharing nor encapsulation is falsely claimed today.

The pattern-focused shipping quote case separates two claims: Composite is the
recursive literal/operation part-whole structure, while Interpreter assigns
arithmetic meaning and Result policies to its tags. Both are executable and
use zero explicit loops, but remain closed. Adding a node kind or operation
requires editing dispatch. Open delegated Composite/Interpreter/Visitor forms
still require first-class UDFs, tagged variants/pattern matching, folds, and
modules.

## Behavioral patterns

| Pattern | Functional sw-MLPL interpretation | Today | Needed for preferred demo |
|---|---|---|---|
| Chain of Responsibility | `purchase_approval.mlpl` delegates through nested callable handlers until one accepts | Executable fixed nested baseline | Dynamic callable collection and short-circuit UDF fold |
| Command | `account_commands.mlpl` carries executable UDF, numeric arguments, and environment | Executable fixed schema | Heterogeneous dynamic histories need general-value collections/variants |
| Interpreter | `shipping_cost_expression.mlpl` evaluates tags 0–4 with explicit Result errors | Constrained, executable closed baseline | Numeric/tagged AST evaluation works; strings/tokenization and independently extensible operations remain blocked |
| Iterator | `maintenance_budget_iterator.mlpl` uses pure immutable collection/index state with `has_next`/`next` | Executable explicit-state baseline | Preferred fold/scan/unfold/each form needs first-class UDFs and combinators; modules add privacy |
| Mediator | `order_mediator.mlpl` coordinates callable inventory/billing transitions | Executable fixed baseline; dynamic form blocked | Callable registry, UDF fold, nested/general map state, variants |
| Memento | `undo_room_plan.mlpl` separates pure originator edits from caretaker capture/restore/undo | Executable now for homogeneous numeric state | Modules/private mementos, nested history, and structural sharing improve generality |
| Observer | `sale_observers.mlpl` notifies callable subscribers and returns states/effects | Executable fixed baseline; dynamic form blocked | Dynamic callable collection, UDF fold, general subscriber values |
| State | `incident_response_workflow.mlpl` returns immutable `{state,effects}` from closed numeric dispatch | Executable closed baseline | Open/delegated states require first-class function tables, variants, folds, modules, and record update |
| Strategy | `shipping_service_policy.mlpl` injects three scoring UDFs into one unchanged selector | Executable preferred baseline | UDF fold/composition can simplify the recursive client |
| Template Method | `numeric_reporting_workflow.mlpl` fixes stage order while injecting pure step UDFs | Executable with explicit sequential call | Composition/pipes and modules improve ergonomics |
| Visitor | `expression_visitors.mlpl` traverses once through evaluation/counting callable algebras | Executable fixed algebra | Generic UDF fold, variants, modules improve extensibility |

The executable State baseline keeps incident transitions pure and returns
notification/audit descriptions as data for separate boundary interpretation.
Tests establish deterministic transitions, retained prior states, ownership,
and invalid event/state policies. This preserves state-dependent behavior and
explicit effects, but numeric central dispatch is closed: new states or events
require editing it. It is not presented as the preferred open delegated form.

The executable Iterator baseline gives independent immutable cursors over one
retained numeric collection. A practical budget consumer stops solely through
the iterator protocol and returns the cursor positioned before unconsumed
work. This preserves traversal-state and sequencing intent, but the protocol
is explicit and closed. General reusable fold/scan/unfold/each consumers still
require first-class UDFs and combinators; modules would hide cursor fields.

Behavioral acceptance scenario: a numeric event-processing workflow. Commands
are immutable events, State returns the next model, Chain validates/routes,
Observer derives projections, Memento retains snapshots, and Strategy swaps
ordering or storage policy. Effects should be returned as data and interpreted
only at the outer boundary.

## Capability clusters exposed by all 23

The patterns should drive a small coherent language surface, not 23 bespoke
builtins.

### Cluster A — behavior as values (callable core shipped)

- quote user functions (`:u:f`) and store them in records/collections;
- uniform `call(f, args...)` or direct application of function values;
- composition `compose(f, g)` / `f >> g` and data pipe `x |> f`;
- partial application/bind and closures, or explicit environment records as a
  simpler first step;
- function equality is unnecessary; functions only need to be callable.

Unlocks Strategy, Factory Method, Abstract Factory, Bridge, Decorator, Proxy,
Chain, Command, Observer, Template Method, and Visitor.

### Cluster B — reusable traversal

- `map/each`, `filter`, `fold`, short-circuit fold, `scan`, `unfold`, `zip`,
  `partition`, `flat_map`;
- combinators accept builtins and UDFs uniformly;
- `unfold(seed, step)` returns a dynamically sized sequence and is the pure
  replacement for many producer loops;
- `fold` is the common implementation vocabulary for Composite, Interpreter,
  Visitor, State histories, and collection algorithms.

### Cluster C — composable data

- record update/spread, destructuring, and tagged variants/sum types;
- nested/dynamically sized values and efficient persistent storage;
- general map keyed first by integers, then by mature string values;
- lenses as first-class `{get, put}` function pairs with composition.

### Cluster D — boundaries and loose coupling

- modules/imports, private helpers, explicit exports;
- capability records rather than ambient I/O;
- effects represented as data and executed by a thin outer interpreter;
- dependency direction visible in imports; no global service locator.

## Demo organization

Do not create 23 unrelated toy files. Use three small domains and show several
patterns collaborating within each, plus one focused script per pattern for
discovery:

```text
demos/patterns/
  creational/          # focused minimal examples
  structural/
  behavioral/
  case_studies/
    graph_pipeline/    # factories, builder, adapter, bridge, facade, strategy
    expression_tree/   # composite, interpreter, visitor, flyweight, decorator
    event_workflow/    # command, chain, mediator, memento, observer, state
```

Each pattern page/script records:

- intent from GoF in original terminology;
- functional translation and why inheritance is unnecessary;
- participants as function signatures and immutable data shapes;
- dependency arrows (who knows whom);
- current executable baseline, if honest;
- target composition code;
- exact missing MLPL features;
- explicit-loop count and effect boundary;
- tests of substitutability/decoupling, not just output equality.

## Delivery sequence

1. **Baseline complete:** Adapter, numeric Flyweight, graph Prototype, numeric
   Memento, closed tagged-record Composite/Interpreter/State, and explicit
   Iterator. Label every constrained example honestly.
2. **First-class functions:** Strategy, Factory Method, and fixed-record
   Abstract Factory, Bridge, Template Method, Decorator, Proxy, fixed-schema
   Command, and fixed-algebra Visitor now pass.
3. **Function records and combinators:** Chain, Observer, Iterator, and Mediator.
4. **Record updates + modules:** Builder, Facade, clean Prototype, protocol
   packaging, and reusable lenses.
5. **Nested/persistent data:** open-ended Composite, heterogeneous Command
   history, efficient Memento, and richer interpreters.
6. **Strings later:** only after strings become true sequence values, add
   parser/text variants. String support is not a prerequisite for the numeric
   pattern corpus and must not block the earlier functional core.

## Completion criterion

“All 23 implemented” means every pattern has a runnable problem-solving demo
in its preferred functional form plus a corresponding assertion-based test,
with no hard-coded type switch standing in for open behavior and no OO
machinery added solely to mimic the book's examples. The case studies must
demonstrate that patterns compose without shared mutable state and that
substituting one policy does not require modifying its client.
