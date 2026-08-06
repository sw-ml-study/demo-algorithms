# Functional Strategy Acceptance

Status date: 2026-08-06. Strategy is no longer blocked.

The locally built `mlpl-repl` 0.20.0 identifies build commit `185003e3`.
The adjacent sw-MLPL checkout was inspected read-only at `758d7ff`; it had two
unrelated untracked documentation files. Current syntax supports:

```mlpl
policy = :u:score_lowest_cost;
policies = {economy: :u:score_lowest_cost, urgent: :u:score_fastest};
score = call(policies.economy, cost, duration);
```

`shipping_service_policy.mlpl` is the acceptance case. One unchanged selector
receives a function reference and is run with economy, urgent, and balanced
policies. Tests prove different selected services, stable ties, deterministic
calls, policy references stored in a record, retained inputs, and malformed
service handling. This is genuine substitutability rather than a numeric tag
switch.

## What changed in the blocker analysis

Named UDF references, passing/returning references, record fields containing
references, and uniform `call(f, args...)` are shipped. They no longer block
Strategy. They also make focused acceptance work possible now for Factory
Method, Abstract Factory with fixed record fields, Bridge, explicit-environment
Decorator/Proxy, fixed-schema Command, Template Method, and a Visitor algebra
over an existing closed tree.

## Remaining sw-MLPL features needed

Ordered by current leverage:

1. **UDF-capable collection combinators.** `reduce` currently accepts only a
   curated set of builtin references. General `map`, `filter`, `fold`,
   short-circuit fold, `scan`, `unfold`, `zip`, `partition`, and `flat_map`
   should invoke builtin and UDF references uniformly. This blocks the
   preferred dynamic Chain, Observer, Iterator, Mediator, and many refactors.
2. **Dynamic collections of callable/general values.** Function references
   work in record fields, but dense numeric arrays are not sequences of
   callables. A nested/general vector or suitable registry/map is needed for a
   runtime-sized handler/subscriber/command collection.
3. **Composition and binding.** `compose`, pipe/application syntax, partial
   binding, and either closures or explicit environment helpers make
   Decorator, Proxy, Template Method, lenses, and pipelines concise. Passing
   named functions works already, so these improve composition rather than
   basic delegation.
4. **Record update/spread, destructuring, and variants/pattern matching.** The
   first two remain high-return ergonomic work; variants open closed State,
   Composite, Interpreter, and Command data without unsafe tag conventions.
5. **Modules beyond include.** Namespaces, private helpers, explicit exports,
   and evaluate-once identity are needed for Facade, module Singleton, private
   Memento, and clean protocol boundaries.
6. **Efficient persistent/general data.** COW/persistent vectors, nested values,
   maps, and sharing diagnostics improve dynamic histories and registries while
   retaining pure value semantics. No user-visible allocation, borrow checker,
   or mandatory cycle collector is required.

One diagnostic refinement was observed: `call` arity/type failures are runtime
errors rather than Result values a Strategy client can catch with `?`. Clear
referent-aware diagnostics already exist; a future safe-call/Result adapter
would help applications treat dynamically supplied policy mismatches as data.

## Work that can proceed without further sw-MLPL changes

- Factory Method and Abstract Factory using named references and fixed records
  (now complete; see [factory-acceptance.md](factory-acceptance.md));
- Bridge using a fixed record of implementation functions;
- Template Method using named step references and explicit sequential calls;
- Decorator and Proxy using named wrappers plus explicit environment records;
- fixed-schema Command records;
- Visitor with a fixed function-algebra record over the existing expression
  tree;
- more non-pattern algorithms and data structures already listed as current.

The combined Factory Method/Abstract Factory acceptance case now passes.
Bridge now passes too; see [bridge-acceptance.md](bridge-acceptance.md).
In parallel, keep the dynamic
Chain/Observer acceptance specifications ready for UDF-capable folds and
general callable collections.
