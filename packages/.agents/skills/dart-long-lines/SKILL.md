---
name: dart-long-lines
description: |-
  Guidelines for handling long lines in Dart code to adhere to the 80-column
  rule. The `lines_longer_than_80_chars` lint.
license: Apache-2.0
---

# Dart Long Lines

## 1. When to use this skill

Use this skill when:
-   Writing Dart code that might exceed the 80-column limit.
-   Refactoring code to comply with the `lines_longer_than_80_chars` lint.
    Reference: https://dart.dev/tools/linter-rules/lines_longer_than_80_chars

## Discovery

To find lines that exceed the limit:

### Automated Analysis
The most reliable way to find long lines is to use the Dart analyzer:
- **Command**: `dart analyze`
- **Lint**: `lines_longer_than_80_chars`

### Manual Search
To search for long lines using regex:
- **Regex**: `^.{81,}$` (Matches any line with 81 or more characters).

## 2. Guidelines

### Format First
Always run `dart format` before manually breaking long lines. The formatter
often automatically fixes long lines, especially in generated code, and
applies standard Dart styling rules.

### Code Comments
Break long code comments (`//`) cleanly at word boundaries to ensure lines do
not exceed 80 characters. Maintain tight formatting and avoid unnecessary
vertical space.

### Documentation Comments (`///`)
-   Apply the same line-breaking rules as for code comments.
-   Avoid breaking markdown link blocks like `[name]` or
    `[text](http://example.com)` across lines. Place them on their own line if
    they exceed the limit.
-   Start doc comments with a single summary sentence, followed by a blank line
    before the rest of the comment. It is okay to break this first sentence
    across multiple lines to fit the 80-column limit.
-   Avoid unresolved references or dangling sentences.

### Long Strings
-   Use adjacent string literals (e.g., `'part 1 ' 'part 2'`) to break long
    strings. Break at word boundaries.
-   If a single-line string contains newline characters (`\n`) or if there are
    consecutive `print` statements, consider migrating to a multi-line string
    literal (`'''`).

### Format and Analyze After Changes
-   Run `dart format` and `dart analyze` after making changes.
-   Be aware that splitting strings may trigger new lints (e.g.,
    `prefer_single_quotes` if a double-quoted string is split into parts that
    no longer contain single quotes).

## 3. Examples

### Documentation Comment Link
**Avoid:**
```dart
/// This is a long doc comment that contains a link to [a very long
/// URL](http://example.com/very/long/url/that/exceeds/eighty/chars).
```

**Prefer:**
```dart
/// This is a long doc comment that contains a link to [a very long URL][ref].
///
/// [ref]: http://example.com/very/long/url/that/exceeds/eighty/chars
```

### Adjacent String Literals
**Prefer:**
```dart
final longString = 'This is a very long string that needs to be broken '
    'across multiple lines to stay under the limit.';
```

### Multi-line String Migration
**Avoid:**
```dart
print('This is line 1\nThis is line 2 that is also quite long\nThis is line 3 which makes the whole thing exceed eighty characters');
```

**Prefer:**
```dart
print('''This is line 1
This is line 2 that is also quite long
This is line 3 which makes the whole thing exceed eighty characters''');
```

