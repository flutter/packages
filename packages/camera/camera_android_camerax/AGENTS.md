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

All changes you make require at least a unit test in the respective language where you make changes (Dart or Android/Java). Furthermore, all tests must pass after you make changes (Dart unit tests, Android native unit tests, Flutter integration tests).
Details on running each of these below.

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
