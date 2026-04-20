---
name: dart-test-fundamentals
description: |-
  Core concepts and best practices for `package:test`.
  Covers `test`, `group`, lifecycle methods (`setUp`, `tearDown`), and configuration (`dart_test.yaml`).
license: Apache-2.0
---

# Dart Test Fundamentals

## When to use this skill
Use this skill when:
- Writing new test files.
- structuring test suites with `group`.
- Configuring test execution via `dart_test.yaml`.
- Understanding test lifecycle methods.

## Core Concepts

### 1. Test Structure (`test` and `group`)

- **`test`**: The fundamental unit of testing.
  ```dart
  test('description', () {
    // assertions
  });
  ```
- **`group`**: Used to organize tests into logical blocks.
  - Groups can be nested.
  - Descriptions are concatenated (e.g., "Group Description Test Description").
  - Helps scope `setUp` and `tearDown` calls.
  - **Naming**: Use `PascalCase` for groups that correspond to a class name
    (e.g., `group('MyClient', ...)`).
  - **Avoid Single Groups**: Do not wrap all tests in a file with a single
    `group` call if it's the only one.

- **Naming Tests**:
  - Avoid redundant "test" prefixes.
  - Include the expected behavior or outcome in the description (e.g.,
    `'throws StateError'` or `'adds API key to URL'`).
  - Descriptions should read well when concatenated with their group name.

- **Named Parameters Placement**:
  - For `test` and `group` calls, place named parameters (e.g., `testOn`,
    `timeout`, `skip`) immediately after the description string, before the
    callback closure. This improves readability by keeping the test logic last.
    ```dart
    test('description', testOn: 'vm', () {
      // assertions
    });
    ```

### 2. Lifecycle Methods (`setUp`, `tearDown`)

- **`setUp`**: Runs *before* every `test` in the current `group` (and nested
  groups).
- **`tearDown`**: Runs *after* every `test` in the current `group`.
- **`setUpAll`**: Runs *once* before any test in the group.
- **`tearDownAll`**: Runs *once* after all tests in the group.

**Best Practice:**
- Use `setUp` for resetting state to ensure test isolation.
- Avoid sharing mutable state between tests without resetting it.

### 3. Configuration (`dart_test.yaml`)

The `dart_test.yaml` file configures the test runner. Common configurations
include:

#### Platforms
Define where tests run (vm, chrome, node).

```yaml
platforms:
  - vm
  - chrome
```

#### Tags
Categorize tests to run specific subsets.

```yaml
tags:
  integration:
    timeout: 2x
```

Usage in code:
```dart
@Tags(['integration'])
import 'package:test/test.dart';
```

Running tags:
`dart test --tags integration`

#### Timeouts
Set default timeouts for tests.

```yaml
timeouts:
  2x # Double the default timeout
```

### 4. File Naming
- Test files **must** end in `_test.dart` to be picked up by the test runner.
- Place tests in the `test/` directory.

## Common commands

- `dart test`: Run all tests.
- `dart test test/path/to/file_test.dart`: Run a specific file.
- `dart test --name "substring"`: Run tests matching a description.

## Related Skills

`dart-test-fundamentals` is the core skill for structuring and configuring
tests. For writing assertions within those tests, refer to:

- **[dart-matcher-best-practices]**:
  Use this if the project sticks with the traditional
  `package:matcher` (`expect` calls).
- **[dart-checks-migration]**: Use this
  if the project is migrating to the modern `package:checks` (`check` calls).

[dart-matcher-best-practices]: https://github.com/kevmoo/dash_skills/blob/main/.agent/skills/dart-matcher-best-practices/SKILL.md
[dart-checks-migration]: https://github.com/kevmoo/dash_skills/blob/main/.agent/skills/dart-checks-migration/SKILL.md
