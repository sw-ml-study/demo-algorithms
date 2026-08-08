# General-purpose serialization acceptance

This specification separates what the current sw-MLPL runtime can demonstrate
from host-side facilities that happen to serialize traces, sessions, or models.
Those host facilities are not general MLPL value codecs.

## Current capability audit (2026-08-07)

Audited read-only through sw-MLPL source and `mlpl-repl 0.20.0` build
`2c7806a4`, with mlplunit `a06191f`.

The current runtime has numeric arrays of arbitrary rank, strings, string
lists, nested records, Results, callable references, and deterministic record
field order (`BTreeMap`). It exposes deterministic `to_json`, typed
`parse_json`, total `type_of`, sandboxed text I/O, and sandboxed raw-byte I/O.
Bytes are rank-1 numeric arrays whose cells are validated as integer
`0..=255`; they are not a distinct runtime byte-buffer kind.

Missing today are a distinct byte-buffer kind, TOML codecs, a typed native
value format, streaming APIs, decode budgets, shared-reference
tables, and complete policies for higher-rank arrays, Results, non-finite
numbers, and non-data values. File I/O is sandboxed path I/O rather than a
scoped streaming capability.

Two deliberately bounded executable baselines now exist.
`demos/serialization/json_delivery_dispatch.mlpl` reads an external JSON
configuration inside the source sandbox, decodes it to a record/vector,
validates capacity policy, and solves a delivery-prefix planning problem. It
uses `has_field`/`record_get` for Result-safe required fields, optional defaults,
version rejection, additive unknown fields, and `type_of` root validation.

`demos/serialization/json_dispatch_roundtrip.mlpl` deterministically encodes a
validated plan, writes and reloads it, proves structural equality, and removes
the artifact. `demos/serialization/binary_device_command.mlpl` packs a compact
versioned/checksummed command, persists its exact bytes, validates it, and
removes the artifact.

`demos/serialization/sensor_grid_envelope.mlpl` frames a numeric scalar or
array as a versioned numeric vector carrying rank, dimensions, payload length,
and a position-sensitive checksum. It solves shape loss across a
numeric-vector-only application channel and round-trips meaningful shaped
sensor data. It is an application-defined in-memory envelope—not JSON, TOML,
raw bytes, cryptographic integrity, or durable storage.

## Acceptance fixtures

These fixtures define completion. Each codec must return `Result`; malformed
external data must not terminate evaluation.

| ID | Acceptance behavior | JSON | TOML | Native binary |
|---|---|---:|---:|---:|
| SER-001 | scalar number, boolean policy, UTF-8 string, empty value | required | required | required |
| SER-002 | rank-0, vector, matrix, rank-4 array preserve values and dimensions | metadata wrapper | metadata wrapper | intrinsic |
| SER-003 | exact numeric element type is preserved or explicitly reported as lossy | wrapper/policy | wrapper/policy | required |
| SER-004 | nested records round-trip with deterministic field emission | required | required | required |
| SER-005 | tagged variants and Results retain discriminant and payload | explicit object | explicit table | intrinsic |
| SER-006 | document/schema version and application metadata survive round-trip | required | required | required |
| SER-007 | unknown optional fields are tolerated; unknown required fields fail with a path | required | required | required |
| SER-008 | malformed, truncated, oversized, too-deep, non-finite, and unsupported values return path-aware errors | required | required | required |
| SER-009 | decode limits cap bytes, collection length, depth, and shared-reference count before allocation | required | required | required |
| SER-010 | chunked encoder/decoder handles tokens split at every boundary and reports finalization errors | required | required | required |
| SER-011 | native header fixes magic, format version, integer widths, byte order, lengths, and checksum policy | n/a | n/a | required |
| SER-012 | little/big-endian golden files decode identically; encoder byte order is selectable or canonical | n/a | n/a | required |
| SER-013 | repeated/shared immutable nodes use an optional reference table; unsupported cycles fail deterministically | n/a | n/a | required |
| SER-014 | application codec/migration functions are passed as first-class callables and errors retain field paths | required | required | required |
| SER-015 | UTF-8 text and arbitrary bytes are distinct; invalid UTF-8 remains representable as bytes | required | required | required |
| SER-016 | file operations are sandbox/capability checked and partial writes cannot masquerade as success | required | required | required |

Current partial acceptance: ordinary scalar/vector/string/record JSON values
round-trip deterministically; schema versioning, additive fields, missing-field
Results, root-kind checks, sandbox containment, and exact numeric-byte file
round trips execute. Higher-rank arrays do not parse back, encoded Results
decode as records and byte cells are numeric values. Atomic replacement now
satisfies the one-shot torn-write portion of SER-016; error budgets remain open.

JSON objects and TOML tables must emit keys in lexical order by default so
golden files, hashes, and diffs are reproducible. Decoders must not rely on
input order. JSON cannot intrinsically distinguish every numeric type, shape,
or variant, and TOML has similar limits; a documented wrapper/schema is
required instead of pretending those formats preserve MLPL values directly.

## Prioritized sw-MLPL changes

1. **Tighten the JSON codec:** deterministic `to_json` and `parse_json` have
   landed. Define non-finite-number behavior, higher-rank wrappers, semantic
   Result decoding, decode limits, and path-aware schema errors.
2. **Tighten bytes:** raw byte I/O and atomic replacement have landed using
   validated numeric arrays. Add a distinct byte-buffer kind or explicit
   refinement and Result-based cell validation.
3. **Type/shape metadata:** expose stable numeric type descriptors and standard
   wrappers that retain scalar-vs-array rank, dimensions, non-finite policy,
   record types, Results, and tagged variants through text codecs.
4. **TOML codec:** parse/encode configuration values with the same error,
   ordering, schema, and callable-policy conventions as JSON.
5. **Versioned native value format:** specify canonical header, lengths,
   endian handling, exact numeric payloads, deterministic records, variants,
   metadata, integrity checks, and compatibility rules.
6. **Streaming and resource capabilities:** incremental codec state plus scoped
   readers/writers, size/depth budgets, and guaranteed
   cleanup on every Result path.
7. **Application-defined codecs and migrations:** callable field/type policies,
   version migrations, and tagged extension points. First-class UDF references
   already provide the delegation primitive; codec APIs must preserve nested
   error paths.
8. **Shared references and cycles:** optional object/reference tables for
   immutable structural sharing. Cycles remain legal and application-managed;
   codecs may require an explicit cycle policy and must reject unsupported
   cycles without hanging. Cycle collection is not a prerequisite.

The first three items have the highest general-purpose payoff. Streaming and
reference graphs matter, but should build on stable one-shot representations.

## Repository boundary

This repository covers application configuration, graphs, event logs, and
general values. Quantized tensors, model weights, SafeTensors-like formats,
and conversion among ML encodings belong in the separate future
`demo-sw-mlpl` repository. They should reuse the eventual bytes, numeric type,
shape, endian, metadata, and codec foundations defined here rather than drive
this general-purpose demo taxonomy.
