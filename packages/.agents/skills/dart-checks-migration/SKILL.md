---
name: dart-checks-migration
description: |-
  Replace the usage of `expect` and similar functions from `package:matcher`
  to `package:checks` equivalents.
license: Apache-2.0
---

# Dart Checks Migration

## When to use this skill
Use this skill when:
- Migrating existing test files from `package:matcher` to `package:checks`.
- A user specifically asks for "modern checks" or similar.

## The Workflow

1.  **Analysis**:
    - Use `grep` to identify files using `expect` or `package:matcher`.
    - Review custom matchers; these may require manual migration.
2.  **Tools & Dependencies**:
    - Ensure `dev_dependencies` includes `checks`.
    - Run `dart pub add --dev checks` if missing.
3.  **Discovery**:
    - Use the **Strategies for Discovery** below to find candidates.
4.  **Replacement**:
    - Add `import 'package:checks/checks.dart';`.
    - Apply the **Common Patterns** below.
    - **Final Step**: Replace `import 'package:test/test.dart';` with
      `import 'package:test/scaffolding.dart';` ONLY after all `expect` calls
      are replaced. This ensures incremental progress.
5.  **Verification**:
    - Ensure the code analyzes cleanly.
    - Ensure tests pass.

## Strategies for Discovery

To find candidates for migration, use the following search strategies:

### Files using Legacy Matchers
Search for test files that import `package:test/test.dart` or use `expect`:
- **Search Query**: `import 'package:test/test.dart';`
- **Regex**: `expect\(`

### Specific Matchers to Target
Search for specific matchers that are easy to migrate:
- **Regex**: `expect\(.*,\s*equals\(`
- **Regex**: `expect\(.*,\s*isNull\)`
- **Regex**: `expect\(.*,\s*isTrue\)`
- **Regex**: `expect\(.*,\s*isFalse\)`
- **Regex**: `expect\(.*,\s*throwsA`

## Common Patterns

| Legacy `expect` | Modern `check` |
| :--- | :--- |
| `expect(a, equals(b))` | `check(a).equals(b)` |
| `expect(a, isTrue)` | `check(a).isTrue()` |
| `expect(a, isFalse)` | `check(a).isFalse()` |
| `expect(a, isNull)` | `check(a).isNull()` |
| `expect(a, isNotNull)` | `check(a).isNotNull()` |
| `expect(() => fn(), throwsA<T>())` | `check(() => fn()).throws<T>()` |
| `expect(list, hasLength(n))` | `check(list).length.equals(n)` |
| `expect(a, closeTo(b, delta))` | `check(a).isA<num>().isCloseTo(b, delta)` |
| `expect(a, greaterThan(b))` | `check(a).isGreaterThan(b)` |
| `expect(a, lessThan(b))` | `check(a).isLessThan(b)` |
| `expect(list, isEmpty)` | `check(list).isEmpty()` |
| `expect(list, isNotEmpty)` | `check(list).isNotEmpty()` |
| `expect(list, contains(item))` | `check(list).contains(item)` |
| `expect(map, equals(otherMap))` | `check(map).deepEquals(otherMap)` |
| `expect(list, equals(otherList))` | `check(list).deepEquals(otherList)` |
| `expect(future, completes)` | `await check(future).completes()` |
| `expect(stream, emitsInOrder(...))` | `await check(stream).withQueue.inOrder(...)` |

### Async & Futures (CRITICAL)

- **Checking async functions:**
  `check(() => asyncFunc()).throws<T>()` causes **FALSE POSITIVES** because the
  closure returns a `Future`, which is a value, so it "completes normally"
  (as a Future).
  **Correct Usage:**
  ```dart
  await check(asyncFunc()).throws<T>();
  ```

- **Chaining on void returns:**
  Many async check methods (like `throws`) return `Future<void>`. You cannot
  chain directly on them. Use cascades or callbacks.
  **Wrong:**
  ```dart
  await check(future)
      .throws<Error>()
      .has((e) => e.message, 'message')
      .equals('foo');
  ```
  **Correct:**
  ```dart
  await check(future).throws<Error>(
      (it) => it.has((e) => e.message, 'message').equals('foo'));
  ```

## Complex Examples

*Deep Verification with `isA` and `having`:*

**Legacy:**
```dart
expect(() => foo(), throwsA(isA<ArgumentError>()
    .having((e) => e.message, 'message', contains('MSG'))));
```

**Modern:**
```dart
check(() => foo())
    .throws<ArgumentError>()
    .has((e) => e.message, 'message')
    .contains('MSG');
```

*Property Extraction:*

**Legacy:**
```dart
expect(obj.prop, equals(value)); // When checking multiple props
```

**Modern:**
```dart
check(obj)
  ..has((e) => e.prop, 'prop').equals(value)
  ..has((e) => e.other, 'other').equals(otherValue);
```

*One-line Cascades:*
Since checks often return `void`, use cascades for multiple assertions on the
same subject.
```dart
check(it)..isGreaterThan(10)..isLessThan(20);
```

## Constraints

- **Scope**: Only modify files in `test/` (and `pubspec.yaml`).
- **Correctness**: One failing test is unacceptable. If a test fails after
  migration and you cannot fix it immediately, REVERT that specific change.
- **Type Safety**: `package:checks` is stricter about types than `matcher`.
  You may need to add explicit `as T` casts or `isA<T>()` checks in the chain.

## Related Skills

- **[dart-test-fundamentals]**: Core
  concepts for structuring tests, lifecycles, and configuration.
- **[dart-matcher-best-practices]**:
  Best practices for the traditional `package:matcher` that is being migrated
  away from.

[dart-test-fundamentals]: https://github.com/kevmoo/dash_skills/blob/main/.agent/skills/dart-test-fundamentals/SKILL.md
[dart-matcher-best-practices]: https://github.com/kevmoo/dash_skills/blob/main/.agent/skills/dart-matcher-best-practices/SKILL.md
