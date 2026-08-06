# Functional Facade Acceptance

Status date: 2026-08-06. Constrained functional Facade runs on the current
sw-MLPL 0.20.0 binary.

`delivery_booking.mlpl` gives callers one `book_delivery` operation instead of
requiring them to coordinate request validation, price calculation, and fleet
allocation. The Facade propagates subsystem Result errors, returns boundary
effects as numeric data, and retains request/fleet inputs. Each subsystem
function remains independently testable.

This establishes Facade intent: a simpler interface coordinates a more complex
subsystem. The current limitation is enforcement, not semantics. `include`
textually shares every helper and cannot make subsystem operations private.
Modules with explicit exports/private bindings are required for the preferred
library boundary.

The fixed nested Chain experiment is next. It must demonstrate callable
delegation and short-circuit acceptance without a central handler opcode
switch. Dynamic Chain remains gated on a callable/general-value sequence and a
short-circuit UDF fold.
