# Fix Torch State Retention on Camera Switch in camera_android_camerax

## Goal Description

The `camera_android_camerax` package fails to retain the torch state when switching between cameras. Specifically, if the torch is turned on while using the rear camera, and the user switches to the front camera (which typically does not support torch) and then back to the rear camera, the torch does not turn back on automatically. Furthermore, attempting to turn it on again after switching back fails because the internal state (`torchEnabled`) still thinks it is on, causing an early return.

This plan proposes to fix this by tracking torch state per camera and restoring it when a camera becomes active.

## User Review Required

> [!IMPORTANT]
> **Multi-Camera Support**: To prevent out-of-sync issues in complex camera switching cases (e.g., devices with more than 2 cameras), I propose changing `torchEnabled` from a single boolean to a map `_torchEnabledPerCamera = <String, bool>{}` keyed by the camera name (from `CameraDescription.name`). This ensures torch state is isolated per camera.

> [!NOTE]
> **CameraX Expectations**: CameraX expects developers to check `CameraInfo.hasFlashUnit()` before calling `CameraControl.enableTorch()`. If called on a camera without flash, it fails. Since `hasFlashUnit()` is not currently exposed to Dart via Pigeon in this package, I propose two options:
> - **Option A (Simpler)**: Attempt to restore torch state automatically during camera initialization and let it fail silently if the camera does not support it (by not adding the error to the stream during restore).
> - **Option B (Ideal)**: Expose `hasFlashUnit()` via Pigeon and check it before attempting to restore torch.
>
> I am proceeding with **Option A** in this plan for simplicity, as it doesn't require modifying Pigeon files, but I will document the choice. Please let me know if you prefer Option B.

## Open Questions

None.

## Prerequisites

Before making any code changes, run the following command to ensure dependencies are up to date:
```bash
dart run ../../../script/tool/bin/flutter_plugin_tools.dart fetch-deps --packages=camera_android_camerax
```

## Proposed Changes

### camera_android_camerax

Summary of changes to retain and restore torch state across camera switches.

---

#### [MODIFY] [android_camera_camerax.dart](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/lib/src/android_camera_camerax.dart)

- Add `_currentCameraDescription` instance variable to track active camera.
- Update `_currentCameraDescription` in `createCameraWithSettings` and `setDescriptionWhileRecording`.
- Replace `torchEnabled` boolean with `Map<String, bool> _torchEnabledPerCamera = {};`.
- Update `setFlashMode` to use `_torchEnabledPerCamera` keyed by `_currentCameraDescription.name`.
- Modify `_enableTorchMode` to accept an optional `isRestore` boolean parameter (defaulting to `false`). If `isRestore` is true and the operation fails, the error should not be added to `cameraErrorStreamController`. `isRestore` is true when called during automatic restoration.
- In `_updateCameraInfoAndLiveCameraState`, add logic to restore torch state: if `_torchEnabledPerCamera[_currentCameraDescription.name]` is true, call `_enableTorchMode(true, isRestore: true)`. This method is called by both `initializeCamera` and `setDescriptionWhileRecording`, handling both switching scenarios.

## Verification Plan

### Automated Tests

I will add unit tests in `android_camera_camerax_test.dart` to verify:
1. `setFlashMode` with `FlashMode.torch` sets torch state for that camera.
2. `_updateCameraInfoAndLiveCameraState` attempts to restore torch state if enabled for that camera.
3. `_enableTorchMode` handles failures silently when `isRestore` is true.

Run tests using:
```bash
dart test test/android_camera_camerax_test.dart
```

Additionally, run the following commands to ensure codebase health:
```bash
# Format and Analyze
dart run ../../../script/tool/bin/flutter_plugin_tools.dart format --package=camera_android_camerax
dart run ../../../script/tool/bin/flutter_plugin_tools.dart analyze --package=camera_android_camerax

# Run tests via tool
dart run ../../../script/tool/bin/flutter_plugin_tools.dart dart-test --package=camera_android_camerax

# Additional checks
dart run ../../../script/tool/bin/flutter_plugin_tools.dart fix --packages=camera_android_camerax
dart run ../../../script/tool/bin/flutter_plugin_tools.dart gradle-check --packages=camera_android_camerax
dart run ../../../script/tool/bin/flutter_plugin_tools.dart license-check --packages=camera_android_camerax
dart run ../../../script/tool/bin/flutter_plugin_tools.dart publish-check --packages=camera_android_camerax
dart run ../../../script/tool/bin/flutter_plugin_tools.dart pubspec-check --packages=camera_android_camerax
dart run ../../../script/tool/bin/flutter_plugin_tools.dart readme-check --packages=camera_android_camerax
dart run ../../../script/tool/bin/flutter_plugin_tools.dart version-check --packages=camera_android_camerax
```

### Manual Verification

Since I cannot easily test on physical devices with different camera configurations here, I will rely on the unit tests and mocking the CameraX behavior to ensure the logic works as expected.
