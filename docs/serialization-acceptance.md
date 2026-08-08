# General-purpose serialization acceptance

This specification separates what the current sw-MLPL runtime can demonstrate
from host-side facilities that happen to serialize traces, sessions, or models.
Those host facilities are not general MLPL value codecs.

## Current capability audit (2026-08-08)

Audited through sw-MLPL source and `mlpl-repl 0.20.0` build `533b69f8`,
with mlplunit `a06191f`.

The current runtime has numeric arrays of arbitrary rank, strings, string
lists, nested records, Results, callable references, and deterministic record
field order (`BTreeMap`). It exposes deterministic Result-based `to_json` and
`to_toml`, typed Result-based `parse_json` and `parse_toml`, total `type_of`,
sandboxed text I/O, and sandboxed raw-byte I/O.
Bytes are ordinary rank-1 numeric arrays whose cells are validated as integer
`0..=255`; this is the accepted language contract, not a temporary stand-in.

TOML support is deliberately a configuration subset: basic strings, finite
numbers, booleans mapped to numeric `1`/`0`, homogeneous numeric/string arrays,
and nested table records. Inline tables, arrays of tables, datetime values,
literal/multiline strings, dotted-key assignments, higher-rank arrays, and
Results are outside that subset. Both parsers always enforce a default depth
ceiling and accept explicit `max_depth`/`max_bytes` budgets; over-budget input
returns `Err` before unsafe recursion or oversized parsing. Malformed option
records are hard programmer errors, distinct from untrusted-data failures.
The shell harness executes both sides of that boundary: explicit depth-budget
violations are inspected with `is_err` and exit successfully, while negative
or non-record option fixtures must terminate evaluation with the documented
diagnostic. This prevents later parser changes from silently conflating data
rejection with API misuse.
Missing today are a typed native value format, streaming APIs, collection and
shared-reference-count budgets, shared-reference tables, and complete policies
for higher-rank arrays and semantic Result decoding. File I/O is sandboxed path
I/O rather than a scoped streaming capability.

Two deliberately bounded executable baselines now exist.
`demos/serialization/json_delivery_dispatch.mlpl` reads an external JSON
configuration inside the source sandbox, decodes it to a record/vector,
validates capacity policy, and solves a delivery-prefix planning problem. It
uses `has_field`/`record_get` for Result-safe required fields, optional defaults,
version rejection, additive unknown fields, and `type_of` root validation.

`demos/serialization/json_dispatch_roundtrip.mlpl` deterministically encodes a
validated plan, writes and reloads it, proves structural equality, and removes
the artifact. `demos/serialization/toml_delivery_dispatch.mlpl` parses an
external TOML policy and delegates to the same format-neutral validator and
planner. `demos/serialization/toml_dispatch_roundtrip.mlpl` proves sorted
encoding, atomic replacement, decode, validation, and cleanup for the supported
configuration subset. `demos/serialization/binary_device_command.mlpl` packs a
compact versioned/checksummed command, persists its exact bytes, validates it,
and removes the artifact.

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
and supported TOML configuration records round-trip deterministically; schema
versioning, additive fields, missing-field Results, root-kind checks, sandbox
containment, exact numeric-byte file round trips, and explicit text byte/depth
budgets execute. Higher-rank arrays do not parse back, encoded JSON Results
decode as records, TOML rejects Results, and byte cells use the documented
numeric-array policy.
Atomic replacement satisfies the one-shot torn-write portion of SER-016;
unsupported/non-finite JSON values and invalid byte cells return Err. SER-009
is partial: byte and recursive depth ceilings have landed, while collection
length and future shared-reference-count budgets remain open.

JSON objects and TOML tables must emit keys in lexical order by default so
golden files, hashes, and diffs are reproducible. Decoders must not rely on
input order. JSON cannot intrinsically distinguish every numeric type, shape,
or variant, and TOML has similar limits; a documented wrapper/schema is
required instead of pretending those formats preserve MLPL values directly.

## Prioritized sw-MLPL changes

1. **Tighten the JSON codec:** Result-returning deterministic `to_json` and
   `parse_json` have landed, including safe non-finite rejection. Add
   higher-rank wrappers, semantic Result decoding, collection limits, and
   path-aware schema errors. Byte/depth decode budgets have landed.
2. **Byte follow-ons:** numeric byte arrays, Result-based validation, raw I/O,
   and atomic replacement have landed. Future work is streaming/budget policy,
   not a distinct byte-buffer type.
3. **Type/shape metadata:** expose stable numeric type descriptors and standard
   wrappers that retain scalar-vs-array rank and dimensions,
   record types, Results, and tagged variants through text codecs.
4. **TOML follow-ons:** the deterministic Result-based configuration subset
   has landed with byte/depth decode budgets. Add path-aware field errors,
   collection limits, shared type/shape wrappers, and only those wider TOML
   forms justified by application demos.
5. **Versioned native value format:** specify canonical header, lengths,
   endian handling, exact numeric payloads, deterministic records, variants,
   metadata, integrity checks, and compatibility rules.
6. **Streaming and resource capabilities:** incremental codec state plus scoped
   readers/writers, collection/reference budgets, and guaranteed
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
