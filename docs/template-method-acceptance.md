# Functional Template Method Acceptance

Status date: 2026-08-06. Template Method runs on the current sw-MLPL 0.20.0
binary using fixed records of named UDF references and explicit `call`.

## Executable evidence

`numeric_reporting_workflow.mlpl` solves a workflow-consistency problem: audit
and capacity reports need different preparation, analysis, and publication
rules, but both must preserve the same processing order. The immutable
`u:run_numeric_report` skeleton always calls:

```text
prepare -> analyze -> publish
```

An audit step record retains whole-unit readings, totals them, and publishes an
audit effect description. A capacity step record decodes scaled readings,
selects their peak, and publishes a capacity effect description. Neither set
changes the workflow skeleton.

`test_numeric_report_template.mlpl` provides three named mlplunit tests for
step-set substitution, invariant stage order, deterministic effects-as-data,
retained inputs, invalid readings/scales, and deliberately misordered steps.
The demo has zero explicit loops; recursive validation is O(readings).

## Why this is Template Method

Classic OO Template Method fixes an algorithm in a base method and lets
subclasses override primitive operations. The functional translation keeps the
algorithm skeleton as an ordinary pure function and supplies primitive
operations explicitly in a record:

```text
steps = {prepare: :u:prepare_whole_readings,
         analyze: :u:analyze_total,
         publish: :u:publish_audit_metric}
u:run_numeric_report(input, steps)
```

Stage-tag validation makes ordering observable and rejects an incoherent step
record through normal Result propagation.

## Honest limits and sw-MLPL improvements

No language change blocks fixed-schema Template Method. These additions would
improve reuse and presentation:

1. Function composition and a data pipe would express the skeleton directly.
2. Partial binding, closures, or explicit environment helpers would configure
   steps without adding fields to every data record.
3. Modules with exports/private helpers would define a true workflow boundary.
4. Record update/spread and destructuring would reduce stage-record rebuilding.
5. Wrong callable arity/type remains a hard runtime error rather than a
   catchable Result, limiting application-level protocol diagnostics.

UDF-capable collection combinators and dynamic callable/general-value
collections remain higher-value gates for dynamic Chain, Observer, and
Mediator. Explicit-environment Decorator and Proxy can proceed today.
