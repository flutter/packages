# Walkthrough - Fix Torch State Retention

I have implemented the changes to fix the torch state retention issue in the `camera_android_camerax` package. However, I encountered a permission error when trying to run the tests and commands in my environment. I need you to run the tests to verify the changes.

## Changes Made

### Pigeon Layer
- Added `bool hasFlashUnit()` to `CameraInfo` in `pigeons/camerax_library.dart`.
- Ran Pigeon generator to update generated Dart and Kotlin files.

### Native Layer (Android)
- Implemented `hasFlashUnit` in `CameraInfoProxyApi.java` to delegate to CameraX's `CameraInfo.hasFlashUnit()`.

### Dart Layer
- Replaced `torchEnabled` with a map `torchEnabledPerCamera` in `android_camera_camerax.dart` to track torch state per camera.
- Added `_currentCameraDescription` to track the active camera.
- Updated `setFlashMode` to check `hasFlashUnit` before enabling torch and to use the map.
- Updated `_updateCameraInfoAndLiveCameraState` to restore torch state when a camera becomes active.
- Renamed `isRestore` to `addErrorToStream` in `_enableTorchMode`.

### Tests
- Added unit tests in `android_camera_camerax_test.dart` for:
    - `setFlashMode` throwing exception if no flash unit.
    - Restoring torch state to ON/OFF on initialization.
    - Handling failures silently during restore.
- **Fixed pre-existing Mockito issue**: Replaced a `when` call inside a stub response with `FakeCaptureRequestOptions` to fix "Cannot call `when` within a stub response" error that was causing 52 tests to fail.

## What Needs to be Tested

Please run the following commands from the package directory (`packages/camera/camera_android_camerax`) to verify the changes:

1. **Run Unit Tests**:
   ```bash
   dart run ../../../script/tool/bin/flutter_plugin_tools.dart dart-test --packages=camera_android_camerax
   ```
   (Or run `dart test test/android_camera_camerax_test.dart` directly).

2. **Run Health Checks**:
   ```bash
   dart run ../../../script/tool/bin/flutter_plugin_tools.dart format --package=camera_android_camerax
   dart run ../../../script/tool/bin/flutter_plugin_tools.dart analyze --package=camera_android_camerax
   ```

3. **Manual Verification**:
   Follow the steps in the implementation plan to test with an emulator if possible.
