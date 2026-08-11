---
name: dart-collect-coverage
description: Collect coverage using the coverage packge and create an LCOV report
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Fri, 24 Apr 2026 15:14:32 GMT
---
# Implementing Dart and Flutter Test Coverage

## Contents
- [Testing Fundamentals](#testing-fundamentals)
- [Coverage Directives](#coverage-directives)
- [Workflow: Configuring and Generating Coverage Reports](#workflow-configuring-and-generating-coverage-reports)
- [Workflow: Advanced Manual Coverage Collection](#workflow-advanced-manual-coverage-collection)
- [Examples](#examples)

## Testing Fundamentals

Structure your test suites using the standard Dart testing paradigms. Use `package:test` for Dart projects and `flutter_test` for Flutter projects.

- **Unit Tests:** Verify individual functions, methods, or classes.
- **Component/Widget Tests:** Verify component behavior, layout, and interaction using mock objects (`package:mockito`).
- **Integration Tests:** Verify entire app flows on simulated or real devices.

## Coverage Directives

Exclude specific lines, blocks, or entire files from coverage metrics using inline comments. Pass the `--check-ignore` flag during formatting to enforce these directives.

- Ignore a single line: `// coverage:ignore-line`
- Ignore a block of code: `// coverage:ignore-start` and `// coverage:ignore-end`
- Ignore an entire file: `// coverage:ignore-file`

## Workflow: Configuring and Generating Coverage Reports

Follow this sequential workflow to add the coverage package, execute tests, and generate an LCOV report.

**Task Progress Checklist:**
- [ ] 1. Add `coverage` as a `dev_dependency`.
- [ ] 2. Execute the automated coverage script.
- [ ] 3. Validate the LCOV output.

### 1. Add Dependencies
Add the `coverage` package as a `dev_dependency` to your project. Do not add it to standard dependencies.

If working in a standard Dart project:
```bash
dart pub add dev:coverage
```

If working in a Flutter project:
```bash
flutter pub add dev:coverage
```

### 2. Collect Coverage and Generate LCOV
Use the bundled `test_with_coverage` script. This script automatically runs all tests, collects the JSON coverage data from the Dart VM, and formats it into an LCOV report.

```bash
dart run coverage:test_with_coverage
```
*Note: If working within a Dart workspace (monorepo), specify the test directories explicitly (e.g., `dart run coverage:test_with_coverage -- pkgs/foo/test pkgs/bar/test`).*

### 3. Feedback Loop: Validate Output
**Run validator -> review errors -> fix:**
1. Verify that the `coverage/` directory was created in the project root.
2. Ensure `coverage/coverage.json` (raw data) and `coverage/lcov.info` (formatted report) exist.
3. If coverage is missing for specific files, ensure they are imported and executed by your test files, or add `// coverage:ignore-file` if they are intentionally excluded.

## Workflow: Advanced Manual Coverage Collection

If you require granular control over the VM service, isolate pausing, or need branch/function-level coverage, use the manual collection workflow.

**Task Progress Checklist:**
- [ ] 1. Run tests with VM service enabled.
- [ ] 2. Collect raw JSON coverage.
- [ ] 3. Format JSON to LCOV.

### 1. Run Tests with VM Service
Execute tests while pausing isolates on exit and exposing the VM service on a specific port (e.g., 8181).

```bash
dart run --pause-isolates-on-exit --disable-service-auth-codes --enable-vm-service=8181 test &
```

### 2. Collect Raw Coverage
Extract the coverage data from the running VM service and output it to a JSON file.

```bash
dart run coverage:collect_coverage --wait-paused --uri=http://127.0.0.1:8181/ -o coverage/coverage.json --resume-isolates
```
*Optional: Append `--function-coverage` and `--branch-coverage` to gather deeper metrics (requires Dart VM 2.17.0+).*

### 3. Format to LCOV
Convert the raw JSON data into the standard LCOV format.

```bash
dart run coverage:format_coverage --packages=.dart_tool/package_config.json --lcov -i coverage/coverage.json -o coverage/lcov.info --check-ignore
```

## Examples

### Example: `pubspec.yaml` Configuration
Ensure your `pubspec.yaml` reflects the `coverage` package strictly under `dev_dependencies`.

```yaml
name: my_dart_app
environment:
  sdk: ^3.0.0

dependencies:
  path: ^1.8.0

dev_dependencies:
  test: ^1.24.0
  coverage: ^1.15.0
```

### Example: Applying Ignore Directives
Use ignore directives to prevent generated code or untestable edge cases from lowering coverage scores.

```dart
// coverage:ignore-file
import 'package:meta/meta.dart';

class SystemConfig {
  final String env;

  SystemConfig(this.env);

  // coverage:ignore-start
  void legacyInit() {
    print('Deprecated initialization');
  }
  // coverage:ignore-end

  bool isProduction() {
    if (env == 'prod') return true;
    return false; // coverage:ignore-line
  }
}
```
