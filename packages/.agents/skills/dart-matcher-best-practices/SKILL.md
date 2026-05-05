---
name: dart-matcher-best-practices
description: |-
  Best practices for using `expect` and `package:matcher`.
  Focuses on readable assertions, proper matcher selection, and avoiding
  common pitfalls.
license: Apache-2.0
---

# Dart Matcher Best Practices

## When to use this skill

Use this skill when:
- Writing assertions using `expect` and `package:matcher`.
- Migrating legacy manual checks to cleaner matchers.
- Debugging confusing test failures.

## Discovery

To find candidates for improving matcher usage, search for suboptimal patterns:

### Suboptimal Length Checks
Search for length checks that should use `hasLength`:
- **Regex**: `expect\([^,]+.length,\s*`

### Suboptimal Boolean Checks
Search for checks on boolean properties that have specific matchers:
- **Regex**: `expect\([^,]+.isEmpty,\s*(true|equals\(true\))`
- **Regex**: `expect\([^,]+.isNotEmpty,\s*(true|equals\(true\))`
- **Regex**: `expect\([^,]+.contains\(.*\),\s*(true|equals\(true\))`

### Suboptimal Map Lookups
Search for manual map lookups instead of `containsPair`:
- **Regex**: `expect\([^,]+\[.*\],\s*`

## Core Matchers

### 1. Collections (`hasLength`, `contains`, `isEmpty`, `unorderedEquals`, `containsPair`)

- **`hasLength(n)`**:
  - Prefer `expect(list, hasLength(n))` over `expect(list.length, n)`.
  - Gives better error messages on failure (shows actual list content).

- **`isEmpty` / `isNotEmpty`**:
  - Prefer `expect(list, isEmpty)` over `expect(list.isEmpty, true)`.
  - Prefer `expect(list, isNotEmpty)` over `expect(list.isNotEmpty, true)`.

- **`contains(item)`**:
  - Verify existence without manual iteration.
  - Prefer over `expect(list.contains(item), true)`.

- **`unorderedEquals(items)`**:
  - Verify contents regardless of order.
  - Prefer over `expect(list, containsAll(items))`.

- **`containsPair(key, value)`**:
  - Verify a map contains a specific key-value pair.
  - Prefer over checking `expect(map[key], value)` or
    `expect(map.containsKey(key), true)`.

### 2. Type Checks (`isA<T>` and `TypeMatcher<T>`)

- **`isA<T>()`**:
  - Prefer for inline assertions: `expect(obj, isA<Type>())`.
  - More concise and readable than `TypeMatcher<Type>()`.
  - Allows chaining constraints using `.having()`.

- **`TypeMatcher<T>`**:
  - Prefer when defining top-level reusable matchers.
  - **Use `const`**: `const isMyType = TypeMatcher<MyType>();`
  - Chaining `.having()` works here too, but the resulting matcher is not `const`.

### 3. Object Properties (`having`)

Use `.having()` on `isA<T>()` or other TypeMatchers to check properties.

- **Descriptive Names**: Use meaningful parameter names in the closure (e.g.,
  `(e) => e.message`) instead of generic ones like `p0` to improve readability.

```dart
expect(person, isA<Person>()
    .having((p) => p.name, 'name', 'Alice')
    .having((p) => p.age, 'age', greaterThan(18)));
```

This provides detailed failure messages indicating exactly which property
failed.

### 4. Async Assertions

- **`completion(matcher)`**:
  - Wait for a future to complete and check its value.
  - **Prefer `await expectLater(...)`** to ensure the future completes before
    the test continues.
  - `await expectLater(future, completion(equals(42)))`.

- **`throwsA(matcher)`**:
  - Check that a future or function throws an exception.
  - `await expectLater(future, throwsA(isA<StateError>()))`.
  - `expect(() => function(), throwsA(isA<ArgumentError>()))` (synchronous
    function throwing is fine with `expect`).

### 5. Using `expectLater`

Use `await expectLater(...)` when testing async behavior to ensure proper
sequencing.

```dart
// GOOD: Waits for future to complete before checking side effects
await expectLater(future, completion(equals(42)));
expect(sideEffectState, equals('done'));

// BAD: Side effect check might run before future completes
expect(future, completion(equals(42)));
expect(sideEffectState, equals('done')); // Race condition!
```

## Principles

1.  **Readable Failures**: Choose matchers that produce clear error messages.
2.  **Avoid Manual Logic**: Don't use `if` statements or `for` loops for
    assertions; let matchers handle it.
3.  **Specific Matchers**: Use the most specific matcher available (e.g.,
    `containsPair` for maps instead of checking keys manually).

## Related Skills

- **[dart-test-fundamentals]**: Core
  concepts for structuring tests, lifecycles, and configuration.
- **[dart-checks-migration]**: Use this
  skill if you are migrating tests from `package:matcher` to modern
  `package:checks`.

[dart-test-fundamentals]: https://github.com/kevmoo/dash_skills/blob/main/.agent/skills/dart-test-fundamentals/SKILL.md
[dart-checks-migration]: https://github.com/kevmoo/dash_skills/blob/main/.agent/skills/dart-checks-migration/SKILL.md
