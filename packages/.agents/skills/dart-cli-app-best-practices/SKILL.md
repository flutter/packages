---
name: dart-cli-app-best-practices
description: |-
  Best practices for creating high-quality, executable Dart CLI applications.
  Covers entrypoint structure, exit code handling, and recommended packages.
license: Apache-2.0
---

# Dart CLI Application Best Practices

## 1. When to use this skill
Use this skill when:
-   Creating a new Dart CLI application.
-   Refactoring an existing CLI entrypoint (`bin/`).
-   Reviewing CLI code for quality and standards.
-   Setting up executable scripts for Linux/Mac.

## 2. Best Practices

### Entrypoint Structure (`bin/`)
Keep the contents of your entrypoint file (e.g., `bin/my_app.dart`) minimal.
This improves testability by decoupling logic from the process runner.

**DO:**
```dart
// bin/my_app.dart
import 'package:my_app/src/entry_point.dart';

Future<void> main(List<String> arguments) async {
  await runApp(arguments);
}
```

**DON'T:**
-   Put complex logic directly in `bin/my_app.dart`.
-   Define classes or heavy functions in the entrypoint.

### Put an `executable` entry in `pubspec.yaml`

List your executables in `pubspec.yaml` to make them available for global
activation and clean invocation via `dart run`.

**DO:**
Add an `executables` section mapping the command name to the Dart file in
`bin/` (excluding the `.dart` extension).

```yaml
executables:
  my_app: # Maps to bin/my_app.dart
  custom_name: main # Maps to bin/main.dart
```

Then run via `dart run my_app` or `dart run custom_name`.

### CONSIDER `#!` for other scripts on *nix systems

This is NOT a hard and fast rule, but it is something to consider.

For CLI tools intended to be run directly on Linux and Mac, add a shebang and
ensure the file is executable.

**DO:**
1.  Add `#!/usr/bin/env dart` to the first line.
2.  Run `chmod +x bin/my_script.dart` to make it executable.

```dart
#!/usr/bin/env dart

void main() => print('Ready to run!');
```

### Process Termination (`exitCode`)
Properly handle process termination to allow for debugging and correct status
reporting.

**DO:**
-   Use the `exitCode` setter to report failure.
-   Allow `main` to complete naturally.
-   Use standard exit codes (sysexits) for clarity (e.g., `64` for bad usage,
    `78` for configuration errors).
    -   See `package:io` `ExitCode` class or FreeBSD sysexits man page.

```dart
import 'dart:io';

void main() {
  if (someFailure) {
    exitCode = 64; // DO!
    return;
  }
}
```

**AVOID:**
-   Calling `exit(code)` directly, as it terminates the VM immediately,
    preventing "pause on exit" debugging and `finally` blocks from running.

### Exception Handling
Uncaught exceptions automatically set a non-zero exit code, but you should
handle expected errors gracefully.

**Example:**
```dart
Future<void> main(List<String> arguments) async {
  try {
    await runApp(arguments);
  } catch (e, stack) {
    print('App crashed!');
    print(e);
    print(stack);
    exitCode = 1; // Explicitly fail
  }
}
```

### Cross-Platform Compatibility (Windows Support)
When writing CLI applications and tests, ensure compatibility with Windows:
- **Paths**: Avoid hardcoding path separators like `/` because Windows uses `\`.
  Use `package:path`'s `p.join` or `p.normalize` to construct paths portably.
- **File Permissions**: When testing file permission errors, remember that
  `chmod` is not available on Windows. Use `icacls` on Windows or appropriate
  mock libraries to simulate permission errors. Never skip tests on Windows
  simply because of permission commands if a Windows equivalent exists.

## Discovery

To find areas to apply these best practices:

### Heavy Entrypoints
Inspect files in `bin/` to see if they contain logic that should be in `lib/`:
- **Target**: Files matching `bin/*.dart`.

### Direct Process Termination
Search for calls to `exit()` instead of setting `exitCode`:
- **Regex**: `\bexit\(`

### Hardcoded Path Separators
Search for hardcoded `/` in strings that appear to be file paths:
- **Regex**: `['"][^'"]+/[^'"]+['"]` (Verify context as this may match URLs).

## 3. Recommended Packages

Use these community-standard packages owned by the [Dart team](https://dart.dev)
to solve common CLI problems:

| Category | Recommended Package | Usage |
| :--- | :--- | :--- |
| **Stack Traces** | [`package:stack_trace`](https://pub.dev/packages/stack_trace) | detailed, cleaner stack traces |
| **Arg Parsing** | [`package:args`](https://pub.dev/packages/args) | standard flag/option parsing |
| **Testing** | [`package:test_process`](https://pub.dev/packages/test_process) | integration testing for CLI apps |
| **Testing** | [`package:test_descriptor`](https://pub.dev/packages/test_descriptor) | file system fixtures for tests |
| **Networking** | [`package:http`](https://pub.dev/packages/http) | standard HTTP client (remember user-agent!) |
| **ANSI Output** | [`package:io`](https://pub.dev/packages/io) | handling ANSI colors and styles |

## 4. Interesting community packages

| Category | Recommended Package | Usage |
| :--- | :--- | :--- |
| **Configuration** | [`package:json_serializable`](https://pub.dev/packages/json_serializable) | strongly typed config objects |
| **CLI Generation** | [`package:build_cli`](https://pub.dev/packages/build_cli) | generate arg parsers from classes |
| **Version Info** | [`package:build_version`](https://pub.dev/packages/build_version) | automatic version injection |
| **Configuration** | [`package:checked_yaml`](https://pub.dev/packages/checked_yaml) | precise YAML parsing with line numbers |

## 5. Conventions

-   **File Caching**: Write cached files to `.dart_tool/[pkg_name]/`.
-   **User-Agent**: Always set a User-Agent header in HTTP requests, including
    version info.
