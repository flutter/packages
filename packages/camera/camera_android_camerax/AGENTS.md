# Agent Guide for camera_android_camerax

This document provides context, architectural details, and core workflows for making high quality contributions to the `camera_android_camerax` package.

## Architectural Overview

The `camera_android_camerax` package is the Android platform implementation of the `camera` plugin, using the **Android Jetpack CameraX** library.

### ProxyApi Binding System
This plugin utilizes **Pigeon's ProxyApi** to bind Dart objects directly to native Android CameraX Java/Kotlin objects.
- **Pigeon Definition**: The API surfaces are defined in [pigeons/camerax_library.dart](pigeons/camerax_library.dart).
- **Generated Code**:
  - Dart proxy classes: [lib/src/camerax_library.g.dart](lib/src/camerax_library.g.dart)
  - Kotlin proxy classes: [android/src/main/java/io/flutter/plugins/camerax/CameraXLibrary.g.kt](android/src/main/java/io/flutter/plugins/camerax/CameraXLibrary.g.kt)
- **Plugin Entry Point**: [lib/src/android_camera_camerax.dart](lib/src/android_camera_camerax.dart) implements `CameraPlatform` using the generated proxy classes.

## Required Steps Before Making Any Changes

Before making any changes, run the the [check-readiness skill](.agents/skills/check-readiness/SKILL.md) to ensure your environment has all the required tooling.

## Required Steps After Making Any Changes

1. **Regenerate Code (if applicable)**:
   - If you modified [pigeons/camerax_library.dart](pigeons/camerax_library.dart), run the Pigeon generation command under [Code Generation](#code-generation).
   - If you modified any classes that are mocked or added new mocks, run the Mockito generation command under [Code Generation](#code-generation).
2. **Verify Tests**:
   - Ensure you have added or updated unit tests to cover your changes.
   - Run and pass all tests (see [Running Tests](#running-tests) for details):
     - Dart unit tests.
     - Android native unit tests.
     - Integration tests.
3. **Static Analysis**:
   - Do not rely on ad-hoc or generic commands to check for formatting or lint errors. Always use the [dart-run-static-analysis skill](.agents/skills/dart-run-static-analysis/SKILL.md) during development to analyze the code and apply automated fixes.

## Code Generation

When you modify the Pigeon API [pigeons/camerax_library.dart](pigeons/camerax_library.dart), you must regenerate the respective code to update the Dart proxy class [lib/src/camerax_library.g.dart](lib/src/camerax_library.g.dart) and the Kotlin proxy class [android/src/main/java/io/flutter/plugins/camerax/CameraXLibrary.g.kt](android/src/main/java/io/flutter/plugins/camerax/CameraXLibrary.g.kt). Run from this directory:

```bash
dart run pigeon --input pigeons/camerax_library.dart
```

Because test in this package use `mockito` for mocking, you must also regenerate the Mockito mocks that are used for unit testing any changes you make. So, also run from this directory:

```bash
dart run build_runner build -d
```

## Running Tests

When you make a change, add a test if you can (either a Dart unit test, Android native unit test, or Flutter integration tests). Regardless of if tests are added or not, all tests must pass after you make changes. How to run the tests:

### Dart Unit Tests
Dart unit tests are located in [test/](./test/).
To run them from this directory:
```bash
dart run ../../../script/tool/bin/flutter_plugin_tools.dart dart-test --packages=camera_android_camerax
```

### Android Native Unit Tests
Android unit tests are located in [android/src/test/](./android/src/test/) and run using Robolectric.
To run them from this directory:
```bash
dart run ../../../script/tool/bin/flutter_plugin_tools.dart native-test --android --packages=camera_android_camerax
```

### Flutter Integration Tests
Integration tests are located in [example/integration_test/integration_test.dart](./example/integration_test/integration_test.dart).
With an emulator or physical device connected, run from this directory:
```bash
dart run ../../../script/tool/bin/flutter_plugin_tools.dart integration-test --android --packages=camera_android_camerax
```

## Required Steps Before Pushing

You MUST read and follow the [pre-push skill](.agents/skills/pre-push-skill/SKILL.md) immediately whenever:
- The user asks to push changes.
- The user asks if you or they are ready to push.
- The user wants to validate that local changes are ready to become a pull request.
- It is the final step when you are ready to make a PR and consider an issue solved.

This skill will execute all the required pre-push checks (e.g., tests, publish checks, license formatting) for the `flutter/packages` repository.

## Agent Coding and Review Guidelines

- **Communication and Code Review**: When receiving code review feedback, DO NOT be overly accommodating or blindly agree with the user if the feedback seems technically questionable. Instead, use the [receiving-code-review skill](.agents/skills/receiving-code-review/SKILL.md) to apply technical rigor and verify the suggestions. Be direct if you believe the feedback is incorrect.
- **Code Quality and Complexity**: Do not produce low-quality or overly complex code. For complex features, propose using the `/grill-me` or `/plan` slash commands to create a design plan before writing code. Enforce strict minimum test coverage and cognitive complexity standards. Use the [dart-add-unit-test skill](.agents/skills/dart-add-unit-test/SKILL.md) and [dart-collect-coverage skill](.agents/skills/dart-collect-coverage/SKILL.md) to ensure high coverage.
- **Duplicate Code**: Avoid duplicating code, especially constant strings. Instead of duplicating, look for existing patterns in adjacent code and extract shared values into constants.