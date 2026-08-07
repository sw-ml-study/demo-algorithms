# General-purpose serialization acceptance

This specification separates what the current sw-MLPL runtime can demonstrate
from host-side facilities that happen to serialize traces, sessions, or models.
Those host facilities are not general MLPL value codecs.

## Current capability audit (2026-08-06)

The current runtime has numeric arrays of arbitrary rank, strings, string
lists, nested records, Results, callable references, and deterministic record
field order (`BTreeMap`). It also exposes sandboxed `read_text` and
`write_text`, and byte tokenization maps strings to numeric values in
`[0,255]`. These are useful prerequisites, but they do not constitute a
general serialization layer.

Missing today are a raw byte-vector value/type contract, byte-oriented file
I/O, JSON and TOML value codecs, a native value format, streaming codec APIs,
schema migration hooks, shared-reference tables, and a policy for values that
cannot be serialized (callables, models, tokenizers, generation state, and
device handles). Text file I/O is sandboxed path I/O rather than a scoped file
capability, so it cannot yet demonstrate resource-safe streaming.

The executable baseline is therefore deliberately smaller:
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

JSON objects and TOML tables must emit keys in lexical order by default so
golden files, hashes, and diffs are reproducible. Decoders must not rely on
input order. JSON cannot intrinsically distinguish every numeric type, shape,
or variant, and TOML has similar limits; a documented wrapper/schema is
required instead of pretending those formats preserve MLPL values directly.

## Prioritized sw-MLPL changes

1. **Text codec foundation:** complete string indexing/slicing/comparison and
   add `parse_json`/`encode_json` over ordinary values with deterministic keys,
   limits, and path-aware Result errors. This immediately unlocks configuration,
   graph snapshots, event logs, and conversion demos.
2. **Bytes as a distinct contract:** add byte vectors (or an exact `u8` array
   type), UTF-8 encode/decode Results, and sandboxed/capability-based
   `read_bytes`/atomic `write_bytes`. Numeric arrays must not silently stand in
   for arbitrary bytes.
3. **Type/shape metadata:** expose stable numeric type descriptors and standard
   wrappers that retain scalar-vs-array rank, dimensions, non-finite policy,
   record types, Results, and tagged variants through text codecs.
4. **TOML codec:** parse/encode configuration values with the same error,
   ordering, schema, and callable-policy conventions as JSON.
5. **Versioned native value format:** specify canonical header, lengths,
   endian handling, exact numeric payloads, deterministic records, variants,
   metadata, integrity checks, and compatibility rules.
6. **Streaming and resource capabilities:** incremental codec state plus scoped
   readers/writers, size/depth budgets, atomic replacement, and guaranteed
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
