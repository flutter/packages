# Agent Guide for camera_android_camerax

This document provides context, architectural details, and core workflows
for making high quality contributions to the `camera_android_camerax` package.

## Architectural Overview

The `camera_android_camerax` package is the Android platform implementation
of the (camera)[../camera] plugin, using the (**Android Jetpack CameraX**)[https://developer.android.com/jetpack/androidx/releases/camera] library.

### ProxyApi Binding System

This plugin utilizes (**Pigeon's ProxyApi**)[../../pigeon] to bind Dart objects directly
to native Android CameraX Java/Kotlin objects.

- **Pigeon Definition**: The API surfaces are defined in
  [pigeons/camerax_library.dart](pigeons/camerax_library.dart).
- **Generated Code**:
  - Dart proxy classes:
    [lib/src/camerax_library.g.dart](lib/src/camerax_library.g.dart)
  - Kotlin proxy classes:
    [android/src/main/java/io/flutter/plugins/camerax/CameraXLibrary.g.kt](android/src/main/java/io/flutter/plugins/camerax/CameraXLibrary.g.kt)
- **Plugin Entry Point**:
  [lib/src/android_camera_camerax.dart](lib/src/android_camera_camerax.dart)
  implements `CameraPlatform` using the generated proxy classes.

## Required Steps Before Making Any Changes

Before working, run the
[check-readiness skill](.agents/skills/check-readiness/SKILL.md)
to ensure your environment has all the expected tooling.

## Required Steps After Making Any Changes

1. **Regenerate Code (if applicable)**:
   - If you modified
     [pigeons/camerax_library.dart](pigeons/camerax_library.dart),
     run the Pigeon generation command under
     [Code Generation](#code-generation).
   - If you modified any classes that are mocked or added new mocks,
     run the Mockito generation command under
     [Code Generation](#code-generation).
2. **Verify Tests**:
   - Ensure you have added or updated unit tests to cover your changes.
   - Run and pass all tests (see [Running Tests](#running-tests) for details):
     - Dart unit tests.
     - Android native unit tests.
     - Integration tests.
3. **Static Analysis**:
   - Run the
     [dart-run-static-analysis skill](.agents/skills/dart-run-static-analysis/SKILL.md)
     to analyze the code and apply automated fixes.

## Code Generation

When you modify the Pigeon API
[pigeons/camerax_library.dart](pigeons/camerax_library.dart),
you must regenerate the respective code to update the Dart proxy class
[lib/src/camerax_library.g.dart](lib/src/camerax_library.g.dart)
and the Kotlin proxy class
[android/src/main/java/io/flutter/plugins/camerax/CameraXLibrary.g.kt](android/src/main/java/io/flutter/plugins/camerax/CameraXLibrary.g.kt).
Run from this directory:

```bash
dart run pigeon --input pigeons/camerax_library.dart
```

Because tests in this package use mockito for mocking, you must also
regenerate the Mockito mocks that are used for unit testing any changes
you make by running in this directory:

```bash
dart run build_runner build -d
```

For more in-depth guidance on creating or updating mocks, refer to the
[dart-generate-test-mocks skill](.agents/skills/dart-generate-test-mocks/SKILL.md).

## Running Tests

When you make a change, add a test if other similar code has tests(either a Dart unit test,
Android native unit test, or a Flutter integration test). Regardless of
whether you add a test or not, all tests must pass after you make changes.
How to run the tests:

### Dart Unit Tests

Dart unit tests are located in [test/](./test/).
To run them from this directory:

```bash
dart run ../../../script/tool/bin/flutter_plugin_tools.dart dart-test --packages=camera_android_camerax
```

### Android Native Unit Tests

Android unit tests are located in [android/src/test/](./android/src/test/).
To run them from this directory:

```bash
dart run ../../../script/tool/bin/flutter_plugin_tools.dart native-test --android --packages=camera_android_camerax
```

### Flutter Integration Tests

Integration tests are located in
[example/integration_test/integration_test.dart](./example/integration_test/integration_test.dart).
For guidance on writing new integration tests or using MCP to explore
UI flows interactively, refer to the
[flutter-add-integration-test skill](.agents/skills/flutter-add-integration-test/SKILL.md).
They require an Android emulator or physical device to be connected.
To check if this is true, run `flutter devices` and verify that an
Android device/emulator is listed. If not, prompt the user to start one.
If so, run from this directory:

```bash
dart run ../../../script/tool/bin/flutter_plugin_tools.dart integration-test --android --packages=camera_android_camerax
```

## Required Steps Before Pushing

You must run the
[pre-push skill](.agents/skills/pre-push-skill/SKILL.md)
immediately whenever:

- The user asks to push changes.
- The user asks if you or they are ready to push.
- The user wants to validate that local changes are ready to become
  a pull request.
- It is the final step when you are ready to make a PR and consider
  an issue solved.

This skill will execute all the required pre-push checks (tests and
checks for static analysis, licenses, and formatting) for the
`flutter/packages` repository.

## Agent Coding and Review Guidelines

- **Communication and Code Review**: When receiving code review feedback,
  do not be overly accommodating or blindly agree with the user if the
  feedback seems technically questionable. Instead, use the
  [receiving-code-review skill](.agents/skills/receiving-code-review/SKILL.md)
  to apply technical rigor and verify the suggestions. Be direct if you
  believe the feedback is incorrect.
- **Code Quality and Complexity**: Do not produce low-quality or overly
  complex code. For complex features, propose using the `/grill-me` or
  `/plan` slash commands to create a design plan before writing code.
  Enforce strict minimum test coverage and cognitive complexity standards.
  Use the
  [dart-add-unit-test skill](.agents/skills/dart-add-unit-test/SKILL.md)
  and
  [dart-collect-coverage skill](.agents/skills/dart-collect-coverage/SKILL.md)
  to ensure high coverage.
- **Duplicate Code**: Avoid duplicating code, especially constant strings.
  Instead of duplicating, look for existing patterns in adjacent code
  and extract shared values into constants.