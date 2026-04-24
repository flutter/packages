# Fix Torch State Retention on Camera Switch in camera_android_camerax

## Goal Description

The `camera_android_camerax` package fails to retain the torch state when switching between cameras. Specifically, if the torch is turned on while using the rear camera, and the user switches to the front camera (which typically does not support torch) and then back to the rear camera, the torch does not turn back on automatically. Furthermore, attempting to turn it on again after switching back fails because the internal state (`torchEnabled`) still thinks it is on, causing an early return.

This plan proposes to fix this by tracking torch state per camera and restoring it when a camera becomes active, after verifying that the camera supports flash.

## User Review Required

> [!IMPORTANT]
> **Multi-Camera Support**: To prevent out-of-sync issues in complex camera switching cases (e.g., devices with more than 2 cameras), I propose changing `torchEnabled` from a single boolean to a map `_torchEnabledPerCamera = <String, bool>{}` keyed by the camera name (from `CameraDescription.name`). This ensures torch state is isolated per camera.
>
> **New Variable**: I am adding `_currentCameraDescription` to track the active camera. This is required because some methods (like `initializeCamera`) only receive a `cameraId` (which is the texture ID) and need to know which camera description it corresponds to in order to use its name as a key in `_torchEnabledPerCamera`.

> [!NOTE]
> **CameraX Expectations**: CameraX expects developers to check `CameraInfo.hasFlashUnit()` before calling `CameraControl.enableTorch()`.
> I will incorporate this by:
> 1. Exposing `hasFlashUnit()` via Pigeon in `CameraInfo`.
> 2. Checking it in Dart before attempting to restore torch state, and giving a helpful error if the user tries to turn on torch on a camera without flash.

## Prerequisites

Before making any code changes, run the following command to ensure dependencies are up to date:
```bash
dart run ../../../script/tool/bin/flutter_plugin_tools.dart fetch-deps --packages=camera_android_camerax
```

## Proposed Changes

### camera_android_camerax

Summary of changes to retain and restore torch state across camera switches.

---

#### [MODIFY] [pigeons/camerax_library.dart](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/pigeons/camerax_library.dart)

- Add `bool hasFlashUnit();` to `abstract class CameraInfo`.
- Run the Pigeon generator to update generated files.

#### [MODIFY] [android/src/main/java/io/flutter/plugins/camerax/CameraInfoProxyApi.java](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/android/src/main/java/io/flutter/plugins/camerax/CameraInfoProxyApi.java)

- Implement `hasFlashUnit(CameraInfo pigeonInstance)` to return `pigeonInstance.hasFlashUnit()`.

#### [MODIFY] [lib/src/android_camera_camerax.dart](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/lib/src/android_camera_camerax.dart)

- Add `_currentCameraDescription` instance variable to track the active camera.
- Update `_currentCameraDescription` in `createCameraWithSettings` and `setDescriptionWhileRecording`.
- Replace `torchEnabled` boolean with `Map<String, bool> _torchEnabledPerCamera = {};`.
- Update `setFlashMode` to use `_torchEnabledPerCamera` keyed by `_currentCameraDescription.name`. If mode is `FlashMode.torch`, check `await cameraInfo!.hasFlashUnit()` first and throw a specific `CameraException` if false.
- Modify `_enableTorchMode` to accept an optional `addErrorToStream` boolean parameter (defaulting to `true`). When restoring state, we will pass `false` to avoid spamming the stream if it fails unexpectedly.
- In `_updateCameraInfoAndLiveCameraState`, add logic to restore torch state: if `_torchEnabledPerCamera[_currentCameraDescription.name]` is true, check `await cameraInfo!.hasFlashUnit()`. If true, call `_enableTorchMode(true, addErrorToStream: false)`.

## Verification Plan

To make commands easier to read, you can use an alias:
```bash
alias tool="dart run ../../../script/tool/bin/flutter_plugin_tools.dart"
```

### Automated Tests

I will add unit tests in `android_camera_camerax_test.dart` to verify:
1. `setFlashMode` with `FlashMode.torch` sets torch state for that camera.
2. `_updateCameraInfoAndLiveCameraState` attempts to restore torch state to ON if enabled for that camera and flash is available.
3. `_updateCameraInfoAndLiveCameraState` ensures torch state is OFF if not enabled for that camera.
4. `_enableTorchMode` handles failures by not adding to stream when `addErrorToStream` is false.

Run tests using:
```bash
tool dart-test --package=camera_android_camerax
```

### Codebase Health Guidelines

- Run `tool format --package=camera_android_camerax` and `tool analyze --package=camera_android_camerax` after every code edit.
- Run `tool fix --packages=camera_android_camerax` if errors are found in analyze before attempting any other mitigations.
- Run tests after each test case added and after finishing a unit of code work.
- Run `tool gradle-check --packages=camera_android_camerax` after touching `build.gradle` files.
- Run `tool license-check --packages=camera_android_camerax` after getting new files to their final state.
- When completely done, run `tool readme-check`, `tool version-check`, `tool pubspec-check`.
- Finally, run `tool publish-check`.

### Manual Verification

1. **Example App**: Build and run the example app to check behavior visually.
2. **Integration Tests**: Run `flutter test` in `example/integration_test` to ensure nothing broke.
3. **Emulator Testing**:
    - Start emulator: `../../Library/Android/sdk/emulator/emulator -avd Pixel_9_API_36` (or available AVD).
    - Run example app: `flutter run example`
    - Check torch state via adb: `adb shell dumpsys media.camera | grep -i "torch"`
    - Ensure emulator has camera flash enabled in settings if testing actual toggle.
