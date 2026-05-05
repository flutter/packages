---
name: dart-doc-validation
description: |-
  Best practices for validating Dart documentation comments.
  Covers using `dart doc` to catch unresolved references and macros.
license: Apache-2.0
---

# Dart Doc Validation

## 1. When to use this skill

Use this skill when:
-   Writing or updating documentation comments (`///`) in Dart code.
-   Checking for broken documentation links, references, or macros.
-   Preparing a package for publishing to pub.dev.

## Discovery

To find documentation issues:

### Missing Lint
Verify if the `comment_references` lint is enabled:
- **Target**: `analysis_options.yaml`
- **Search Query**: `comment_references`

### Automated Validation
Run the documentation generator to surface warnings:
- **Command**: `dart doc -o $(mktemp -d)`
- **Keywords to look for**: `warning:`, `unresolved doc reference`,
  `undefined macro`

## 2. Best Practices

### Enable the doc validation lint

In your `analysis_options.yaml`, enable the `comment_references` lint.

```yaml
linter:
  rules:
    - comment_references
```

### Validating Documentation Locally

Use the `dart doc` command with a temporary output directory to validate
documentation comments without polluting the local project workspace.

This command parses all documentation comments and reports warnings such as:
-   `warning: unresolved doc reference`
-   `warning: undefined macro`

**Command to run:**

```bash
dart doc -o $(mktemp -d)
```

*This will work on Mac and Linux.*

This ensures that the generated HTML files are stored in a temporary location
and don't clutter the package directory, while still surfacing all validation
warnings in the terminal output.

**Browsing the docs:**

Our docs use features designed to be run on a web server. If you want to browse
the generated docs locally, install the `dhttpd` package.


```shell
pub global activate dhttpd
TMP_DIR=$(mktemp -d) && dart doc -o "$TMP_DIR" &&  dhttpd --path "$TMP_DIR"
```

*(Or use another HTTP server, such as `python3 -m http.server`.)*


### Fixing Common Warnings

-   **Unresolved doc reference**: Ensure that any identifier wrapped in square
    brackets (`[Identifier]`) correctly points to an existing class, method,
    property, or parameter in the current scope or imported libraries.
-   **Undefined macro**: If using `{@macro macro_name}`, ensure that the
    template `{@template macro_name}` is defined in the same file or a file
    that is imported and visible to the documentation generator.
