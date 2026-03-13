# Test Structure

## Specifications
`mustache_test.dart` and `mustache_specs.dart` generate tests for all mustache specifications,
except for those disabled by `mustache_test.dart`'s `UNSUPPORTED_SPECS` constant.
`dart test mustache_test.dart` runs all of the generated tests.

### Updating Specifications
`specs/meta.txt` contains information about the currently-committed specification (commit hash
and pull date).

The `download_spec.sh` script pulls new definitions from the mustache repository and updates the
meta file.

## Features
Standalone or handwritten tests regarding template output go in `feature_test.dart`.

## Parser
Tests for the template language parser go in `parser_test.dart`.