---
name: flutter-lints-setup-and-usage
description: Set up and use the flutter_lints package to enforce recommended Dart and Flutter lint rules across apps, packages, and plugins.
---

# Setting Up and Using flutter_lints

`flutter_lints` contains the official set of recommended lints for Flutter apps, packages, and plugins to encourage good coding practices and prevent common bugs. It builds on top of the core Dart [`lints`](https://pub.dev/packages/lints) package.

## 1. Installation

Add `flutter_lints` as a `dev_dependency` in your project's `pubspec.yaml`:

```bash
flutter pub add dev:flutter_lints
```

Or manually in `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_lints: ^6.0.0
```

## 2. Configure `analysis_options.yaml`

Create or update the `analysis_options.yaml` file at the root of your project (alongside `pubspec.yaml`) to include the recommended rule set:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Enable additional rules or disable specific rules for your project:
    # avoid_print: false
    # prefer_single_quotes: true
```

## 3. Running the Analyzer

Run static analysis from the command line to check your project against the configured lint rules:

```bash
flutter analyze
```

Or using the Dart CLI:

```bash
dart analyze
```

## 4. Suppressing Rules When Necessary

### File-level suppression
To ignore a specific lint rule for an entire Dart file, add an `ignore_for_file` comment at the top of the file:

```dart
// ignore_for_file: avoid_print
```

### Line-level suppression
To ignore a specific lint rule for a single line or statement, add an `ignore` comment directly above the line:

```dart
// ignore: avoid_print
print('Debug output');
```
