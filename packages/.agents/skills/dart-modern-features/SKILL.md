---
name: dart-modern-features
description: |-
  Guidelines for using modern Dart features (v3.0 - v3.10) such as Records,
  Pattern Matching, Switch Expressions, Extension Types, Class Modifiers,
  Wildcards, Null-Aware Elements, and Dot Shorthands.
---

# Dart Modern Features

## 1. When to use this skill

Use this skill when:
- Writing or reviewing Dart code targeting Dart 3.0 or later.
- Refactoring legacy Dart code to use modern, concise, and safe features.
- Looking for idiomatic ways to handle multiple return values, deep data
  extraction, or exhaustive checking.

## Discovery

To find candidates for modernization:

### Switch Expressions
Search for switch statements where every case assigns to the same variable
or returns:
- **Regex**: `switch\s*\([^)]+\)\s*\{\s*case`

### Pattern Matching Candidates
Search for manual map or JSON property extraction and type checking:
- **Regex**: `containsKey\(['"][^'"]+['"]\)`
- **Regex**: `json\[['"][^'"]+['"]\]\s+is\s+`

### Null-Aware Elements
Search for collection `if` statements checking for null:
- **Regex**: `if\s*\(\w+\s*!=\s*null\)\s*\w+`

### Digit Separators
Search for long numbers without separators:
- **Regex**: `\b\d{6,}\b` (Matches numbers with 6 or more digits).

## 2. Features

### Records
Use records as anonymous, immutable, aggregate structures to bundle multiple
objects without defining a custom class. Prefer them for returning multiple
values from a function or grouping related data temporarily.

**Avoid:**
Creating a dedicated class for simple multiple-value returns.
```dart
class UserResult {
  final String name;
  final int age;
  UserResult(this.name, this.age);
}

UserResult fetchUser() {
  return UserResult('Alice', 42);
}
```

**Prefer:**
Using records to bundle types seamlessly on the fly.
```dart
(String, int) fetchUser() {
  return ('Alice', 42);
}

void main() {
  var user = fetchUser();
  print(user.$1); // Alice
}
```

### Patterns and Pattern Matching
Use patterns to destructure complex data into local variables and match against
specific shapes or values. Use them in `switch`, `if-case`, or variable
declarations to unpack data directly.

**Avoid:**
Manually checking types, nulls, and keys for data extraction.
```dart
void processJson(Map<String, dynamic> json) {
  if (json.containsKey('name') && json['name'] is String &&
      json.containsKey('age') && json['age'] is int) {
    String name = json['name'];
    int age = json['age'];
    print('$name is $age years old.');
  }
}
```

**Prefer:**
Combining type-checking, validation, and assignment into a single statement.
```dart
void processJson(Map<String, dynamic> json) {
  if (json case {'name': String name, 'age': int age}) {
    print('$name is $age years old.');
  }
}
```

### Switch Expressions
Use switch expressions to return a value directly, eliminating bulky `case` and
`break` statements.

**Avoid:**
Using switch statements where every branch simply returns or assigns a value.
```dart
String describeStatus(int code) {
  switch (code) {
    case 200:
      return 'Success';
    case 404:
      return 'Not Found';
    default:
      return 'Unknown';
  }
}
```

**Prefer:**
Returning the evaluated expression directly using the `=>` syntax.
```dart
String describeStatus(int code) => switch (code) {
  200 => 'Success',
  404 => 'Not Found',
  _ => 'Unknown',
};
```

### Class Modifiers
Use class modifiers (`sealed`, `final`, `base`, `interface`) to restrict how
classes can be used outside their defines library. Prefer `sealed` for defining
closed families of subtypes to enable exhaustive checking.

**Avoid:**
Using open `abstract` classes when the set of subclasses is known and fixed.
```dart
abstract class Result {}

class Success extends Result {}
class Failure extends Result {}

String handle(Result r) {
  if (r is Success) return 'OK';
  if (r is Failure) return 'Error';
  return 'Unknown';
}
```

**Prefer:**
Using `sealed` to guarantee to the compiler that all cases are covered.
```dart
sealed class Result {}

class Success extends Result {}
class Failure extends Result {}

String handle(Result r) => switch(r) {
  Success() => 'OK',
  Failure() => 'Error',
};
```

### Extension Types
Use extension types for a zero-cost wrapper around an existing type. Use them to
restrict operations or add custom behavior without runtime overhead.

**Avoid:**
Allocating new wrapper objects just for domain-specific logic or type safety.
```dart
class Id {
  final int value;
  Id(this.value);
  bool get isValid => value > 0;
}
```

**Prefer:**
Using extension types which compile down to the underlying type at runtime.
```dart
extension type Id(int value) {
  bool get isValid => value > 0;
}
```

### Digit Separators
Use underscores (`_`) in number literals strictly to improve visual readability
of large numeric values.

**Avoid:**
Long number literals that are difficult to read at a glance.
```dart
const int oneMillion = 1000000;
```

**Prefer:**
Using underscores to separate thousands or other groupings.
```dart
const int oneMillion = 1_000_000;
```

### Wildcard Variables
Use wildcards (`_`) as non-binding variables or parameters to explicitly signal
that a value is intentionally unused.

**Avoid:**
Inventing clunky, distinct variable names to avoid "unused variable" warnings.
```dart
void handleEvent(String ignoredName, int status) {
  print('Status: $status');
}
```

**Prefer:**
Explicitly dropping the binding with an underscore.
```dart
void handleEvent(String _, int status) {
  print('Status: $status');
}
```

### Null-Aware Elements
Use null-aware elements (`?`) inside collection literals to conditionally
include items only if they evaluate to a non-null value.

**Avoid:**
Using collection `if` statements for simple null checks.
```dart
var names = [
  'Alice',
  if (optionalName != null) optionalName,
  'Charlie'
];
```

**Prefer:**
Using the `?` prefix inline.
```dart
var names = ['Alice', ?optionalName, 'Charlie'];
```

### Dot Shorthands
Use dot shorthands to omit the explicit type name when it can be confidently
inferred from context, such as with enums or static fields.

**Avoid:**
Fully qualifying type names when the type is obvious from the context.
```dart
LogLevel currentLevel = LogLevel.info;
```

**Prefer:**
Reducing visual noise with inferred shorthand.
```dart
LogLevel currentLevel = .info;
```

## Related Skills

- **[dart-best-practices]**: General code
  style and foundational Dart idioms that predate or complement the modern
  syntax features.

[dart-best-practices]: https://github.com/kevmoo/dash_skills/blob/main/.agent/skills/dart-best-practices/SKILL.md
