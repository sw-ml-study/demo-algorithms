# Module and Singleton Acceptance Contract

Audit date: 2026-08-07. Read-only sw-MLPL revision and local binary build:
`0904bfcf` (`mlpl-repl 0.20.0`).

## Current capability

Static `include "path.mlpl"` is shipped and useful. It resolves sandboxed
relative paths, preserves file-aware diagnostics, ignores duplicate loads in
one expansion, and reports an include cycle with its full chain. It is source
splicing: included definitions and bindings enter the caller's shared
environment in include-site order.

Static include is not a module system. The current parser/reference exposes no
module/import declaration, qualified namespace lookup, explicit export list,
private binding, or stable module identity. Duplicate-load suppression during
source expansion does not create an encapsulated evaluate-once module value.
Consequently this repository must keep Singleton gated; a global record or an
included constructor would be bypassable and would mislabel source reuse as
the pattern.

## Minimum module behavior

Syntax may vary, but an acceptable first implementation must provide all of
these observable semantics:

1. A source file declares a stable module identity derived from its canonical
   provider-resolved source ID, not the spelling of one relative path.
2. Importing the same canonical module directly, through two clients, or
   through a diamond dependency evaluates its top-level initialization once
   per script/session environment.
3. Imports bind a qualified namespace or explicit alias. Unqualified helper
   names do not leak into the caller.
4. Modules explicitly export names; non-exported values and UDFs are private
   and cannot be accessed through qualification, reflection, annotation
   lookup, or a conflicting local definition.
5. Exported UDF references remain callable and retain their module environment.
6. Cyclic imports fail before partial initialization escapes, with the full
   canonical import chain and file-aware spans.
7. Initialization order is deterministic and documented for an acyclic graph.
8. A failed initialization is not cached as a successful partial module. The
   retry/session policy is explicit.
9. CLI, `run_script`, mlplunit, web/WASM bundle providers, and compiled paths
   agree on identity, privacy, exports, cycles, and evaluate-once behavior.
10. Separate top-level script runs receive separate module environments unless
    an explicitly documented process-wide module facility is introduced.

Package registries, remote imports, runtime `eval`, version solving, and
mutable global singletons are not required for this first contract.

## Singleton acceptance fixture

Once modules land, this repository should add a small immutable service module:

- a private constructor creates one service/capability record;
- a private initialization marker or runtime-observable initialization event
  proves construction occurs exactly once;
- the module exports only `service()` (or one immutable exported service
  value) and a read-only documented identity/lifecycle token;
- two separate client modules import the service through different dependency
  paths and return the exported token;
- the root imports both clients and proves equal stable tokens plus one
  initialization event;
- attempts to import/call the constructor or read private state are compile or
  load errors;
- duplicate-path spellings resolve to the same canonical module;
- a separate cyclic fixture reports the complete chain without exposing a
  half-initialized service; and
- two isolated `run_script`/mlplunit runs prove the documented per-environment
  lifecycle boundary.

The acceptance test should not require pointer equality. A stable module-owned
identity/lifecycle token and exactly-once initialization are sufficient for an
immutable functional Singleton interpretation.

## Repository refactoring after acceptance

After the fixture passes, refactor one small helper family with observed name
collisions into a qualified module with a minimal export list. Compare error
spans and public surface before expanding adoption. Keep textual include as the
transparent implementation-sharing mechanism until module parity exists on
every execution surface.
