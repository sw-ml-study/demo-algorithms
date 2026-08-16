set shell := ["sh", "-cu"]

# Show the repository's task recipes.
default:
    @just --list

# Run every registered problem-solving demo.
demos:
    ./scripts/run-all

# Run all tests, or pass a file/directory/filter through to mlplunit.
tests *args:
    ./scripts/run-tests {{args}}

# Run tests in TAP format, optionally with a file/directory/filter.
tap *args:
    ./scripts/run-tests --format tap {{args}}

# List native tests discovered by mlplunit.
list-tests:
    ./scripts/run-tests --list

# Exercise the shell harness, including expected failure propagation.
harness:
    ./tests/test-harness

# Audit catalogs, UDF doc strings, and shared-source mlplunit adoption.
audit:
    ./scripts/validate-catalog catalog/demos.tsv
    ./scripts/validate-catalog catalog/tests.tsv
    ./scripts/check-repository-ownership
    ./scripts/check-docstrings
    ./scripts/check-mlplunit-adoption

# Enforce unique catalog authority after the sibling migration is complete.
boundary-final:
    ./scripts/check-repository-ownership --final ../demo-data-structures

# Run the complete local validation gate.
check: audit harness ownership-tests demos tests

# Exercise missing and overlapping repository-ownership rules.
ownership-tests:
    ./tests/test-repository-ownership
