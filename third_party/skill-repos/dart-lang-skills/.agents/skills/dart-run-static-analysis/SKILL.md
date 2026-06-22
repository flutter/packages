---
name: dart-run-static-analysis
description: Execute `dart analyze` to identify warnings and errors, and use `dart fix --apply` to automatically resolve mechanical lint issues. Use during development to ensure code quality and before committing changes.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Fri, 24 Apr 2026 15:09:34 GMT
---
# Analyzing and Fixing Dart Code

## Contents
- [Analysis Configuration](#analysis-configuration)
- [Diagnostic Suppression](#diagnostic-suppression)
- [Workflow: Executing Static Analysis](#workflow-executing-static-analysis)
- [Workflow: Applying Automated Fixes](#workflow-applying-automated-fixes)
- [Examples](#examples)

## Analysis Configuration

Configure the Dart analyzer using the `analysis_options.yaml` file located at the package root.

- **Base Configuration:** Always include a standard rule set (e.g., `package:lints/recommended.yaml` or `package:flutter_lints/flutter.yaml`) using the `include:` directive.
- **Strict Type Checks:** Enable strict type checks under the `analyzer: language:` node to prevent implicit downcasts and dynamic inferences. Set `strict-casts: true`, `strict-inference: true`, and `strict-raw-types: true`.
- **Linter Rules:** Explicitly enable or disable specific rules under the `linter: rules:` node. Use a key-value map (`rule_name: true/false`) when overriding included rules, or a list (`- rule_name`) when defining a fresh set. Do not mix list and map syntax in the same `rules` block.
- **Formatter Configuration:** Configure `dart format` behavior under the `formatter:` node. Set `page_width` (default 80) and `trailing_commas` (`automate` or `preserve`).
- **Analyzer Plugins:** Enable custom diagnostics by adding plugins under the `analyzer: plugins:` node. Ensure the plugin package is added as a `dev_dependency` in `pubspec.yaml`.

## Diagnostic Suppression

When a diagnostic (lint or warning) yields a false positive or applies to generated code, suppress it explicitly.

- **File-level Exclusion:** Use the `analyzer: exclude:` node in `analysis_options.yaml` to exclude entire files or directories (e.g., `**/*.g.dart`) using glob patterns.
- **File-level Suppression:** Add `// ignore_for_file: <diagnostic_code>` at the top of a Dart file to suppress specific diagnostics for the entire file. Use `// ignore_for_file: type=lint` to suppress all linter rules.
- **Line-level Suppression:** Add `// ignore: <diagnostic_code>` on the line directly above the offending code, or appended to the end of the offending line.
- **Pubspec Suppression:** Add `# ignore: <diagnostic_code>` above the offending line in `pubspec.yaml` files (e.g., `# ignore: sort_pub_dependencies`).
- **Plugin Diagnostics:** Prefix the diagnostic code with the plugin name when suppressing plugin-specific issues (e.g., `// ignore: some_plugin/some_code`).

## Workflow: Executing Static Analysis

Use this workflow to identify type-related bugs, style violations, and potential runtime errors.

**Task Progress:**
- [ ] 1. Verify `analysis_options.yaml` exists at the project root.
- [ ] 2. Run the analyzer using the `analyze_files` MCP tool (if available) or the CLI command `dart analyze <target_directory>`.
- [ ] 3. Review the diagnostic output.
- [ ] 4. If info-level issues must be treated as failures, append the `--fatal-infos` flag.
- [ ] 5. Resolve reported errors manually or proceed to the Automated Fixes workflow.

## Workflow: Applying Automated Fixes

Use this workflow to resolve outdated API usages, apply quick fixes, and migrate code (e.g., Dart 3 migrations).

**Task Progress:**
- [ ] 1. Execute a dry run to preview proposed changes using the `dart_fix` MCP tool or CLI command `dart fix --dry-run`.
- [ ] 2. Review the proposed fixes to ensure they align with the intended architecture.
- [ ] 3. If additional fixes are required, verify that the corresponding linter rules are enabled in `analysis_options.yaml`.
- [ ] 4. Apply the fixes using the `dart_fix` MCP tool or CLI command `dart fix --apply`.
- [ ] 5. Format the modified code using the `dart_format` MCP tool or CLI command `dart format .`.
- [ ] 6. Run the static analysis workflow to verify all diagnostics are resolved.

## Examples

### Comprehensive `analysis_options.yaml`

```yaml
include: package:flutter_lints/recommended.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "lib/generated/**"
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    todo: ignore
    invalid_assignment: warning
    missing_return: error

linter:
  rules:
    avoid_shadowing_type_parameters: false
    await_only_futures: true
    use_super_parameters: true

formatter:
  page_width: 100
  trailing_commas: preserve
```

### Inline Diagnostic Suppression

```dart
// Suppress for the entire file
// ignore_for_file: unused_local_variable, dead_code

void processData() {
  // Suppress for a specific line
  // ignore: invalid_assignment
  int x = '';
  
  const y = 10; // ignore: constant_identifier_names
}
```
