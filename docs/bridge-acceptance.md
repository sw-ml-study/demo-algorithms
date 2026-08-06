# Functional Bridge Acceptance

Status date: 2026-08-06. Functional Bridge runs on the current sw-MLPL 0.20.0
binary without a language change.

## Executable evidence

`energy_meter_reporting.mlpl` solves a representation-boundary problem: one
reporting service must read direct whole-unit samples and scaled integer
samples. A fixed implementation record supplies `total` and `peak` UDF
references plus an encoding identifier. The usage-summary and budget-status
abstractions invoke that protocol without knowing its arithmetic.

The example demonstrates both independent dimensions required by Bridge:

- the same usage abstraction runs with direct and scaled implementations;
- usage-summary and budget-status abstractions run over the same implementation.

`test_energy_meter_bridge.mlpl` contains three named mlplunit tests covering
implementation parity, abstraction variation, retained input vectors, empty or
negative readings, invalid scale/budget, and mismatched encodings. The demo has
zero explicit loops; recursive validation is O(samples), while curated numeric
reductions calculate total and peak.

## Current protocol

```text
direct_meter = {
  encoding: 1,
  total: :u:direct_total,
  peak: :u:direct_peak
}
summary = u:energy_usage_summary(data, direct_meter)?
```

This is delegation rather than an encoding tag switch inside the abstraction.
Adding another implementation with the same fixed fields does not require
editing either reporting abstraction.

## Honest limits and sw-MLPL improvements

The example exposes several nonblocking improvements:

1. Modules, explicit exports, and private helpers would make the protocol a
   real library boundary rather than an `include` convention.
2. Dynamic collections of callable/general values would support runtime-sized
   implementation registries and discovery.
3. Composition, pipes, partial binding, and explicit environments/closures
   would simplify construction of richer abstractions and adapters.
4. Record update/spread and destructuring would improve protocol evolution.
5. A wrong callable arity/type is a hard runtime diagnostic, not a catchable
   Result, so protocol-shape failures cannot yet be handled as application data.

None of those blocks fixed-schema Bridge. Work can continue with Template
Method and explicit-environment Decorator/Proxy while UDF-capable collection
combinators and dynamic general-value collections remain the most valuable
language gates for Chain, Observer, Mediator, and other dynamic patterns.
