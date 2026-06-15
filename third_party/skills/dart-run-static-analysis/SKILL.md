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

- **File-level Exclusion:** Use the `analyzer: exclude:` node in `analysis_options.yaml` to exclude enti

