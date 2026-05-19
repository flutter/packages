---
name: dart-test-coverage
description: |-
  Understand and improve test coverage in a Dart package.
  Helps agents run coverage, interpret results, and identify missed lines.
---

# Dart Test Coverage

Guidelines for running and interpreting test coverage in Dart packages.

## When to use this skill
- When asked to "check test coverage" or "improve coverage".
- When you need to identify which parts of a library are untested.

## Discovery

To find areas lacking test coverage:

### Run Coverage Analysis
Follow the workflow to generate and interpret coverage data:
1. **Run Tests with Coverage**: `dart test --coverage=.dart_tool/coverage`
2. **Interpret Results**: Use the script or `format_coverage` as described in
   the **Interpreting Results** section to identify specific files and missed
   lines.

## How to use this skill (The Workflow)
1.  Ensure tests pass by running `dart test`.
2.  Collect coverage by running `dart test --coverage=.dart_tool/coverage`.
3.  Interpret the results using the provided script or standard tools.
4.  Add tests to cover missed lines.

## Running Coverage
Run the following command to collect coverage in JSON format:
```bash
dart test --coverage=.dart_tool/coverage
```

> [!NOTE]
> We use `.dart_tool/coverage` as the output directory because `.dart_tool`
> is typically already ignored in `.gitignore` files.

> [!TIP]
> For projects with complex conditional logic, you can pass the
> `--branch-coverage` flag to `dart test` to collect branch-level coverage.

## Interpreting Results

### Option 1: Use the custom interpreter script
This repository includes a zero-dependency script that parses the raw JSON
output and provides a summary of covered percentage and missed lines.

Run it from the project root (adjust path to script as needed):
```bash
dart run .agent/skills/dart-test-coverage/scripts/interpret_coverage.dart .dart_tool/coverage <package_name>
```
Replace `<package_name>` with the name from `pubspec.yaml`.

Example Output:
```
package:my_pkg/src/file.dart: 50.0% (2/4 lines)
  Missed lines: 3, 4
```

### Option 2: Use package:coverage
If `package:test` is installed, `package:coverage` is likely available as a
transitive dependency. You can use its `format_coverage` tool.

To get a human-readable "pretty print" of the coverage:
```bash
dart run coverage:format_coverage --in=.dart_tool/coverage --out=stdout --pretty-print --report-on=lib
```
This will output the file content with hit counts on the left (e.g., `0|` for
missed lines).

## Best Practices for Reporting Results
When presenting coverage results to the user, follow these guidelines:
1.  **State the high-level percentage first** to give immediate context.
2.  **Identify specific files and missed lines** clearly.
3.  **Translate line numbers to code**: Don't just say "lines 3-6 are missed".
    Look at the source file and tell the user which functions or blocks are
    untested (e.g., "The `divide` function is missing coverage").
4.  **Propose concrete fixes**: Provide example test code that the user can
    immediately apply to cover the missed lines.
5.  **Use tables for multi-file summaries**: When reporting on multiple files,
    use a markdown table with columns for File, Coverage %, and Missed Lines
    to make the summary easy to scan.

## Constraints
- ALWAYS verify that tests pass before collecting coverage.
- DO NOT commit the `.dart_tool/coverage` directory.
- Focus coverage improvements on `lib/` files, not `test/` or generated files.
