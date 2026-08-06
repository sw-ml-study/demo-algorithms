# Builder Acceptance and Remaining GoF Gates

Status date: 2026-08-06. Constrained functional Builder runs on the current
sw-MLPL 0.20.0 binary. Five GoF patterns do not yet have dedicated executable
evidence in this repository.

## Builder evidence

`storage_plan.mlpl` assembles a replicated-storage plan through pure
`with_capacity`, `with_replicas`, and optional `with_backup` transformations,
then calls a distinct validated `build` operation. Required-stage flags prevent
incomplete products. Every draft is immutable and retained for inspection.

This differs from Factory Method: Factory Method injects one constructor into
an unchanged client, while Builder incrementally accumulates configuration and
separates staged assembly from final product validation.

The implementation is verbose because each transformation reconstructs the
whole record. Record update/spread, lenses, and a data pipe would improve
ergonomics but are not semantic blockers.

## Remaining five-pattern matrix

| Pattern | Honest work possible today | Smallest missing gate |
|---|---|---|
| Facade | Yes: one public orchestration function can provide a simplified interface over tested subsystem functions; privacy remains conventional | Modules/private exports for a preferred enforceable boundary |
| Singleton | No honest module-scoped identity/lifecycle claim from textual `include` or a global variable | Evaluate-once modules, private binding, explicit immutable export/identity semantics |
| Chain of Responsibility | A fixed nested chain may be possible with callable handler/environment records; a dynamic chain is not | Dynamic callable/general-value collection plus short-circuit UDF fold |
| Observer | A fixed subscriber record could be called explicitly, but does not establish dynamic subscription | Dynamic callable collection, UDF fold, general subscriber state/effect values; modules for boundary |
| Mediator | Fixed callable participant fields may permit a constrained case, but central opcode routing alone is insufficient | Callable participant registry, UDF fold, nested/general map state and variants |

## Priority

1. Build the constrained Facade next and label lack of enforced privacy.
2. Prototype a fixed nested Chain only if delegation and short-circuit behavior
   can be shown without a central handler opcode switch.
3. Keep Singleton gated until modules exist; an `include` file is source reuse,
   not evaluate-once identity.
4. Treat dynamic Chain, Observer, and Mediator as primary acceptance consumers
   for UDF-capable folds and dynamic callable/general-value collections.

This ordering lets repository work continue while preserving strong acceptance
tests for future sw-MLPL features.
