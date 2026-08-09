# sw-MLPL typed-native serialization unblock record

## Status

Resolved on 2026-08-09. Typed-native binary serialization was blocked by a
missing runtime capability in the upstream `sw-mlpl` repository. Source and
the local `mlpl-repl 0.20.0` release binary now identify commit `7f6dee4d`.

That binary ships `to_native(value)` and `parse_native(bytes[, limits])` using
deterministic canonical-little-endian MLPB v1. The downstream adoption is
executable in `tests/serialization/test_native_value_codec.mlpl` and
`demos/serialization/native_recovery_snapshot.mlpl`.

This document refines the native-binary requirements in
[serialization-acceptance.md](serialization-acceptance.md), especially
SER-001 through SER-016 and the native-specific SER-011 through SER-013.

## Why this originally required upstream work

Raw byte I/O is only a transport. An MLPL application can manually construct a
numeric byte array, but it cannot inspect and faithfully encode every runtime
value property required by a native object format. In particular, the current
language surface does not expose a complete, stable contract for numeric element
types, runtime value tags, allocation-aware decoding, or reference identity.

An application-specific packet in this repository would demonstrate only that
packet. It would not prove native MLPL serialization and must not be presented as
such.

Repository boundaries also require language changes to happen upstream.
`demo-algorithms` consumes an explicitly selected `mlpl-repl` binary and must
not modify `../sw-mlpl` without a separately authorized upstream task.

## Owning repository

The sibling `../sw-mlpl` repository must implement the unblock because it owns:

- the MLPL runtime value representation;
- numeric array shape and element-type metadata;
- records, Results, and future variant discriminants;
- allocation and decoder resource enforcement;
- builtin registration and evaluation semantics;
- `mlpl-repl` language documentation and compatibility behavior.

`demo-algorithms` owns the downstream acceptance demos, application helpers,
fixtures, catalog entries, and capability documentation after the runtime API
ships.

## Shipped upstream API

The shipped composable contract is:

```mlpl
bytes = to_native(value)?;
value = parse_native(bytes, limits)?;
```

`to_native` has no options argument in version 1 because its output is
canonical little-endian and currently needs no flags. Both operations return
`Result`. Malformed or unsupported external data returns `err(...)`, while
programmer misuse of the limits record follows the documented hard-error
convention.

The encoder result must be directly accepted by `write_bytes` and
`write_atomic`. The decoder input must be directly obtainable from
`read_bytes`, without an intervening text conversion.

## Shipped wire-format behavior and retained requirements

### Canonical header

The format must define:

- fixed magic bytes;
- a format version;
- canonical encoder byte order or an explicit byte-order field;
- fixed widths and signedness for header integers;
- payload and collection length encoding;
- checksum or integrity policy, including what bytes it covers;
- rules for rejecting unsupported versions and invalid flags.

The decoder must validate lengths and resource budgets before allocating the
declared payload.

### Lossless value tags

Version 1 must define tags and payload rules for the data values it claims to
support:

- scalar numbers;
- rank-0, rank-1, and higher-rank numeric arrays;
- exact array dimensions;
- stable numeric element types, or an explicit documented loss policy;
- UTF-8 strings;
- arbitrary bytes distinct from UTF-8 text;
- string lists;
- nested records with deterministic field ordering;
- `ok` and `err` Results with their discriminants and payloads;
- versioned extension space for future variants and value kinds.

Unsupported runtime values such as callables, models, tokenizers, generation
state, or device tensors must return a specific `Err`; they must not be silently
coerced or partially serialized.

### Safe decoding and diagnostics

The decoder must enforce, before unsafe recursion or allocation:

- `max_bytes`;
- `max_depth`;
- `max_elements`;
- collection-length and record-field limits;
- `max_references` when reference tables are supported.

Malformed, truncated, oversized, too-deep, non-finite, unsupported, or
internally inconsistent input must return `Err`. Nested failures should retain a
field/index path so applications can identify the failing value.

### Compatibility and migration

The upstream contract must specify:

- deterministic output for equal values;
- predictable rejection of unsupported format versions;
- optional-field and extension-tag rules;
- compatibility expectations between runtime releases;
- an application migration/delegation mechanism that preserves nested error
  paths;
- canonical golden files that detect accidental format drift.

If both little- and big-endian payloads are supported, golden files for both
must decode to equal MLPL values. If the encoder is canonical-endian only, that
choice must be fixed in the format rather than inherited from the host.

### Shared references and cycles

A minimal version 1 may deterministically reject cycles and unsupported shared
identity. It must not hang, recurse without a bound, or duplicate data while
claiming identity preservation.

A later optional reference table should:

- assign stable entry IDs;
- preserve repeated immutable nodes where supported;
- validate references before use;
- enforce `max_references` before allocation;
- retain an explicit cycle policy.

Cycle collection is not a prerequisite for the initial codec.

## Upstream verification contract

The `sw-mlpl` implementation should include:

- round trips for every supported value kind;
- scalar, empty, singleton, vector, matrix, and rank-4 fixtures;
- exact shape and numeric-type assertions;
- nested record and Result fixtures;
- deterministic and golden-byte assertions;
- truncated and corrupt header/payload cases;
- invalid tag, version, length, and checksum cases;
- byte, depth, element, collection, and reference-budget boundaries;
- cross-endian fixtures where applicable;
- explicit rejection tests for unsupported runtime values and cycles.

This readiness condition is satisfied by source and release binary `7f6dee4d`.

## Downstream adoption performed after upstream shipped

The `typed-native-codec-adoption` AgentRail saga performs these steps:

1. Add failing conformance tests against the documented native-codec API.
2. Add thin, single-purpose persistence helpers around the upstream builtins
   and atomic byte I/O.
3. Add a problem-solving snapshot or event-log mini-application.
4. Exercise scalar, empty, singleton, vector, matrix, rank-4, nested-record,
   Result, malformed, truncated, unsupported, and over-budget cases.
5. Add and document canonical golden binary fixtures.
6. Update the demo/test catalogs, README, capability report, plan, and the
   SER-001 through SER-016 acceptance matrix.
7. Run the complete `just check` pre-commit gate.
8. Commit the implementation and in-progress AgentRail state.
9. Run `agentrail complete`, commit the resulting completion metadata, and push
   both commits.
10. Verify that the local branch and remote branch resolve to the same commit.

## Secondary blockers

These are related upstream gaps, but they need not all block a minimal native
codec if version 1 rejects unsupported cases explicitly and safely:

- TOML tagged-envelope mode;
- general user-defined variants;
- exact stable numeric-type descriptors;
- shared-reference tables and `max_references`;
- streaming encoders/decoders and scoped stream capabilities;
- fully path-aware schema and migration errors.

The immediate unblock—the versioned, Result-returning, resource-bounded native
byte codec—is complete. The items above remain follow-ups and do not invalidate
the executable MLPB v1 baseline.
