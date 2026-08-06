# Factory Method and Abstract Factory Acceptance

Status date: 2026-08-06. Both patterns run on the current sw-MLPL 0.20.0
binary without a language change.

## Executable evidence

- `fulfillment_factory_method.mlpl` passes either
  `:u:create_economy_order` or `:u:create_expedited_order` to one unchanged
  `u:prepare_fulfillment` workflow. The constructor validates and creates the
  product; the client only consumes the common product record.
- `analytics_abstract_factory.mlpl` passes one of two fixed records containing
  `create_worker` and `create_store` UDF references. The unchanged provisioning
  client creates related products and rejects an incoherent mixed family.
- `test_fulfillment_factories.mlpl` supplies three named mlplunit tests for
  constructor substitutability, coherent families, retained inputs, invalid
  IDs/capacities, and mixed-family rejection.

Both demos use zero explicit loops. Their records are immutable values, and
neither demo requires allocation APIs, a borrow checker, or application-visible
manual memory management.

## What works today

The required language surface is small and sufficient:

```text
:u:create_economy_order
call(constructor, order_id, units)
{create_worker: :u:create_local_worker,
 create_store: :u:create_local_store}
call(factory.create_worker, capacity)
```

This is genuine delegation: adding another compatible constructor does not
require editing the client workflow. A fixed Abstract Factory record also
expresses a coherent family of construction behaviors without OO inheritance.

## Honest limits and sw-MLPL improvements

These limits do not block the current examples:

1. General/dynamic collections of callable values would enable runtime-sized
   factory registries. Dense numeric arrays cannot represent such a registry.
2. Modules with explicit exports and private helpers would package families,
   hide constructors, and replace repository-relative `include` boundaries.
3. Record update/spread and destructuring would reduce product-derivation
   boilerplate.
4. Composition, pipes, partial binding, or closures would make multi-stage
   creation workflows more concise.
5. Invalid callable arity currently produces a hard runtime diagnostic rather
   than a catchable Result, so callable-shape validation cannot be tested as an
   ordinary application error.

The highest-value general language work remains UDF-capable collection
combinators and dynamic collections of callable/general values. Work in this
repository can continue meanwhile with Bridge and fixed-schema delegated
patterns.
