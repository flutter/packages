# Fix Torch State Retention on Camera Switch in camera_android_camerax

## Goal Description

The `camera_android_camerax` package fails to retain the torch state when switching between cameras. Specifically, if the torch is turned on while using the rear camera, and the user switches to the front camera (which typically does not support torch) and then back to the rear camera, the torch does not turn back on automatically. Furthermore, attempting to turn it on again after switching back fails because the internal state (`torchEnabled`) still thinks it is on, causing an early return.

This plan proposes to fix this by tracking torch state per camera and restoring it when a camera becomes active, after verifying that the camera supports flash.

## User Review Required

> [!IMPORTANT]
> **Multi-Camera Support**: To prevent out-of-sync issues in complex camera switching cases (e.g., devices with more than 2 cameras), I propose changing `torchEnabled` from a single boolean to a map `_torchEnabledPerCamera = <String, bool>{}` keyed by the camera name (from `CameraDescription.name`). This ensures torch state is isolated per camera.
>
> **New Mapping**: Instead of tracking a single active camera, I will maintain a map `_cameraIdToCameraName = <int, String>{}` to map `cameraId` (texture ID) to the camera name. This is required because some methods (like `initializeCamera`) only receive a `cameraId` and need to know which camera name it corresponds to in order to use it as a key in `_torchEnabledPerCamera`. This approach is more robust than relying on a "current" camera state.

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

## Test-Driven Development Workflow

We will strictly follow Test-Driven Development (TDD) for this implementation as described in the TDD skill.
1. **RED**: Write a minimal failing test in `test/android_camera_camerax_test.dart` or relevant Java test file.
2. **Verify RED**: Run the test and verify it fails with the expected message.
3. **GREEN**: Write the minimal production code to make the test pass.
4. **Verify GREEN**: Run the test and verify it passes.
5. **REFACTOR**: Clean up the code while keeping the tests green.

*The Iron Law: No production code without a failing test first.*

## Proposed Changes

### camera_android_camerax

Summary of changes to retain and restore torch state across camera switches. Following TDD, we will implement these by first writing tests in `test/android_camera_camerax_test.dart` and relevant Java test files to reproduce the missing behavior or test the new functionality, and then writing the minimal code to pass the tests.

---

#### [MODIFY] [pigeons/camerax_library.dart](pigeons/camerax_library.dart)

- Add `bool hasFlashUnit();` to `abstract class CameraInfo`.
- Run the Pigeon generator to update generated files.
- The version of pigeon should not change.

#### [MODIFY] [android/src/main/java/io/flutter/plugins/camerax/CameraInfoProxyApi.java](android/src/main/java/io/flutter/plugins/camerax/CameraInfoProxyApi.java)

- Implement `hasFlashUnit(CameraInfo pigeonInstance)` to return `pigeonInstance.hasFlashUnit()`.
- New methods in `CameraInfoProxyApi` need to include a `CameraInfoProxyTest` for the new method.

#### [MODIFY] [lib/src/android_camera_camerax.dart](lib/src/android_camera_camerax.dart)

- Add `Map<int, String> _cameraIdToCameraName = {};` to map `cameraId` (texture ID) to camera name.
- Update `_cameraIdToCameraName` in `createCameraWithSettings` with the created camera's ID and name.
- Replace `torchEnabled` boolean with `Map<String, bool> _torchEnabledPerCamera = {};`.
- Update `setFlashMode` to use `_torchEnabledPerCamera` keyed by the camera name retrieved from `_cameraIdToCameraName[cameraId]`. If mode is `FlashMode.torch`, check `await cameraInfo!.hasFlashUnit()` first and throw a `CameraException` with error code `torchNotSupported` if false. Also ensure native errors from `CameraControl.enableTorch()` are surfaced.
- Create a `_restoreTorchState` method that takes `cameraId`, retrieves the camera name from `_cameraIdToCameraName[cameraId]`, checks if `_torchEnabledPerCamera[cameraName]` is true and `await cameraInfo!.hasFlashUnit()` is true, and if so, calls `_enableTorchMode(true)`.
- Call `_restoreTorchState` in `initializeCamera` (after `cameraControl` is initialized) and `setDescriptionWhileRecording` as appropriate.

## Verification Plan

To make commands easier to read, you can use an alias:
```bash
alias tool="dart run ../../../script/tool/bin/flutter_plugin_tools.dart"
```

### Automated Tests

I will add unit tests in `android_camera_camerax_test.dart` to verify:
1. `setFlashMode` with `FlashMode.torch` sets torch state for that camera.
2. `_restoreTorchState` attempts to restore torch state to ON if enabled for that camera and flash is available.
3. `_restoreTorchState` does not attempt to turn on torch if not enabled for that camera.
4. `setDescriptionWhileRecording` restores torch state as expected when switching cameras.


Run tests using:
```bash
tool dart-test --package=camera_android_camerax
```

## Grill Session Answers

**Question 1:** The plan proposes using a map `_torchEnabledPerCamera` to track torch state per camera. Why is this approach preferred over simply resetting the state on switch or querying CameraX?
**Answer:** It allows retaining the desired torch state for each camera independently, enabling automatic restoration when switching back to a camera that supported it, which matches user expectations.

**Question 2:** The plan proposes adding `_currentCameraDescription` to track the active camera because some methods only receive a `cameraId`. Would it be better to maintain a map from `cameraId` (texture ID) to camera name instead, or do you prefer tracking the full `CameraDescription`?
**Answer:** I prefer maintaining a map from `cameraId` to camera name to be more robust and avoid relying on a "current" camera state.

**Question 3:** The plan proposes throwing a specific `CameraException` if the user tries to turn on torch on a camera without flash. What specific error code and message should we use, and should we also handle failures from `CameraControl.enableTorch()` itself?
**Answer:** Use a specific error code like `torchNotSupported` when `hasFlashUnit()` is false, and also handle failures from `enableTorch` by surfacing the native error.

**Question 4:** The plan proposes calling `_restoreTorchState` in `createCameraWithSettings`. However, `cameraControl` is not initialized until `initializeCamera`. Should we call `_restoreTorchState` in `initializeCamera` instead?
**Answer:** Yes, call `_restoreTorchState` in `initializeCamera` after `cameraControl` is initialized, to ensure we don't get null pointer or uninitialized variable errors.

### Manual Verification

1. **Example App**: Build and run the example app to check behavior visually. **Explicitly test switching between all 3 cameras** (Main, Ultrawide, and Front) to ensure torch state is handled correctly.
2. **Integration Tests**: Run `flutter test` in `example/integration_test` to ensure nothing broke.
3. **Emulator Testing**:
    - Start emulator: `../../Library/Android/sdk/emulator/emulator -avd Pixel_9_API_36` (or `Pixel_9` or other available AVD). *Note: This path assumes execution from the repository root.*
    - Run example app: `flutter run example`
    - Check torch state via adb: `adb shell dumpsys media.camera | grep -i "torch"`
    - Ensure emulator has camera flash enabled in settings if testing actual toggle.


### Required Checks for Completion

- Versions of dependencies should not change unless a feature from a newer version is required.
- Run `tool format --packages=camera_android_camerax` and `tool analyze --packages=camera_android_camerax` after every code edit.
- Run `tool fix --packages=camera_android_camerax` if errors are found in analyze before attempting any other mitigations.
- Run tests after each test case added and after finishing a unit of code work using `tool dart-test --packages=camera_android_camerax`.
- Run `tool gradle-check --packages=camera_android_camerax` after touching `build.gradle` files.
- Run `tool license-check --packages=camera_android_camerax` after getting new files to their final state.
- When completely done, run:
    - `tool readme-check --packages=camera_android_camerax`
    - `tool version-check --packages=camera_android_camerax`
    - `tool pubspec-check --packages=camera_android_camerax --allow-dependencies=../../../script/configs/allowed_unpinned_deps.yaml`
- After completing all the above checks and considering the work done, run the `/comprehensive-code-review` skill on the changes. Review the generated feedback, address any items that are agreed to be valid improvements, and then re-run the list of required checks to ensure no new issues were introduced.
- Finally, run `tool publish-check --packages=camera_android_camerax`.

> [!IMPORTANT]
> If any of the above commands fail, the task is NOT complete. You must fix any errors found and re-run the checks until they all pass.

