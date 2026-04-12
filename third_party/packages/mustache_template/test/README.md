# Test Structure

## Specifications

`mustache_test.dart` and `mustache_specs.dart` generate tests for all mustache specifications,
except for those disabled by `mustache_test.dart`'s `unsupportedSpecs` constant.
`dart test mustache_test.dart` runs all of the generated tests.

Each generated specification file contains the mustache commit hash from which it was generated,
and the date when it was generated.

### Updating specifications

From the package root, run `dart run tool/download_spec.dart` to pull new definitions from the
mustache repository into `test/specs/`.

## Features

Standalone or handwritten tests regarding template output go in `feature_test.dart`.

## Parser

Tests for the template language parser go in `parser_test.dart`.
