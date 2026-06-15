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

### 2. Collect Coverag

