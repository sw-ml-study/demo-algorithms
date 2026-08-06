# Functional Decorator and Proxy Acceptance

Status date: 2026-08-06. Decorator and a protection Proxy both run on the
current sw-MLPL 0.20.0 binary using named UDF references, fixed protocol
records, and explicit immutable environments.

## Decorator evidence

`shipping_quote_layers.mlpl` starts with a base quote service and nests a
surcharge service followed by an insurance service. Every value has the same
`{fn, environment}` protocol. Each Decorator calls its inner service first,
then returns a new quote containing its added amount, layer count, and numeric
accounting effects. The base function is unchanged.

The focused tests prove base/decorated substitutability, delegation order,
two-layer arithmetic, invalid configurations, and retained requests. This is
actual wrapping, not a numeric tag choosing a central branch.

## Proxy evidence

`inventory_access_proxy.mlpl` gives the real inventory target and its
protection Proxy the same request/environment protocol. The Proxy checks a
required role, delegates authorized requests to the target, and returns an
updated access-count value plus ordered authorization/target effects. Rejected
requests do not delegate. The prior request state and target values remain
observable and unchanged.

This intentionally models state and boundary work as returned data. It does
not claim ambient mutation, identity, transparent network I/O, or a hidden
cache.

## Current constraints and sw-MLPL improvements

Both patterns are executable today, with these ergonomic or boundary limits:

1. Closures or partial binding would capture decorator configuration without
   explicit nested environment records.
2. Composition/pipes would make wrapper construction and delegation chains
   clearer.
3. Modules, private exports, and capability records would enforce the Proxy
   boundary rather than documenting it by convention.
4. Dynamic callable/general-value collections would enable runtime-sized
   decorator stacks and proxy registries.
5. Record update/spread would simplify immutable state and result rebuilding.
6. Wrong callable arity/type is still a hard runtime diagnostic rather than a
   catchable Result.

The principal remaining architectural gates are still UDF-capable collection
combinators and dynamic callable/general-value collections. Fixed-schema
Command and Visitor acceptance experiments can proceed without waiting for
those features.
