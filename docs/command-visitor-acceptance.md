# Functional Command and Visitor Acceptance

Status date: 2026-08-06. Fixed-schema Command and fixed-algebra Visitor both
run on the current sw-MLPL 0.20.0 binary.

## Command evidence

`account_commands.mlpl` represents each request as a record containing an
`execute` UDF reference, immutable numeric argument, and explicit environment.
One invoker runs deposit and withdrawal values uniformly. Each execution
returns a new account state and numeric effects; the earlier state remains
observable.

This is executable behavior carried as data, not an opcode switch. It does not
claim a heterogeneous dynamic command history: dense numeric arrays cannot
store arbitrary command records or callable values. Such histories need a
general-value collection and preferably variants/pattern matching.

## Visitor evidence

`expression_visitors.mlpl` keeps the existing closed numeric expression tree
unchanged while passing either an evaluation algebra or a node-count algebra
to one recursive postorder traversal. The algebra records supply callable
`literal` and `combine` operations. Tests prove operation substitution, tree
retention, and propagation of missing-tree, invalid-tag, and division errors.

This is a constrained but honest functional Visitor: adding another operation
requires only another algebra record. Adding a new node family still requires
changing the closed traversal/schema.

## Remaining sw-MLPL improvements

Neither focused example is blocked. Preferred general forms would benefit
from:

1. dynamic collections of callable/general values for heterogeneous Command
   histories and runtime operation registries;
2. a UDF-capable generic tree fold so Visitor traversal is reusable rather
   than pattern-specific recursion;
3. tagged variants and pattern matching for safe open-ended argument/node
   shapes;
4. modules/private exports for invoker, receiver, and tree boundaries;
5. composition, partial binding/closures, and record update ergonomics;
6. catchable Result diagnostics for invalid callable shape/arity.

The remaining GoF matrix should now be reassessed individually. Dynamic Chain,
Observer, and Mediator still share the clearest fold/dynamic-callable gates;
Facade and module Singleton chiefly depend on real module boundaries, while
Builder now has a constrained explicit-update baseline; see
[builder-remaining-gates.md](builder-remaining-gates.md).
