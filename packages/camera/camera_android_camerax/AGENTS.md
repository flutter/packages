# Agent Guide for camera_android_camerax

This document provides context, architectural details, and core workflows for contributing to the `camera_android_camerax` package.

For general repository-wide guidelines (including environment setup, versioning, formatting, and general testing patterns), refer to the main [AGENTS.md](../../../AGENTS.md).

## 1. Architectural Overview

The `camera_android_camerax` package is the Android platform implementation of the `camera` plugin, using the **Android Jetpack CameraX** library.

### ProxyApi Binding System
This plugin utilizes **Pigeon's ProxyApi** to bind Dart objects directly to native Android CameraX Java/Kotlin objects.
- **Pigeon Definition**: The API surfaces are defined in [pigeons/camerax_library.dart](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/pigeons/camerax_library.dart).
- **Generated Code**:
  - Dart proxy classes: [lib/src/camerax_library.g.dart](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/lib/src/camerax_library.g.dart)
  - Kotlin proxy classes: [android/src/main/java/io/flutter/plugins/camerax/CameraXLibrary.g.kt](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/android/src/main/java/io/flutter/plugins/camerax/CameraXLibrary.g.kt)
- **Plugin Entry Point**: [lib/src/android_camera_camerax.dart](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/lib/src/android_camera_camerax.dart) implements `CameraPlatform` using the generated proxy classes.

## 2. Code Generation

When you modify the Pigeon API definition or any mocked files, you must regenerate the respective code.

### Regenerating Pigeon Bindings
If you modify [pigeons/camerax_library.dart](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/pigeons/camerax_library.dart), run:
```bash
# Run from this directory
dart run pigeon --input pigeons/camerax_library.dart
```

### Regenerating Mockito Mocks
Tests in this package use `mockito` for mocking. If you add new classes to mock or modify existing mocked classes, run:
```bash
# Run from this directory
dart run build_runner build -d
```

## 3. Running Tests

All changes must pass all three levels of tests: Dart unit tests, Android native unit tests, and integration tests.

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
# From this directory
dart run ../../../script/tool/bin/flutter_plugin_tools.dart native-test --android --packages=camera_android_camerax
```

### Integration Tests
Integration tests are located in [example/integration_test/integration_test.dart](./example/integration_test/integration_test.dart).

#### Running Integration Tests
With an emulator or physical device connected, run from this directory:
```bash
dart run ../../../script/tool/bin/flutter_plugin_tools.dart integration-test --android --packages=camera_android_camerax
```
