# Fix Torch State Retention on Camera Switch in camera_android_camerax

## Goal Description

The `camera_android_camerax` package fails to retain the torch state when switching between cameras. Specifically, if the torch is turned on while using the rear camera, and the user switches to the front camera (which typically does not support torch) and then back to the rear camera, the torch does not turn back on automatically. Furthermore, attempting to turn it on again after switching back fails because the internal state (`torchEnabled`) still thinks it is on, causing an early return.

This plan proposes to fix this by automatically restoring the torch state when a camera is initialized, if the torch was previously enabled.

## User Review Required

> [!NOTE]
> The proposed solution will attempt to turn on the torch automatically when switching back to a camera that supports it, if it was on before switching. If a camera does not support torch (like most front cameras), the attempt to turn it on will fail silently during the automatic restore process to avoid spamming the error stream.

## Open Questions

None.

## Proposed Changes

### camera_android_camerax

Summary of changes to retain and restore torch state across camera switches.

---

#### [MODIFY] [android_camera_camerax.dart](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/lib/src/android_camera_camerax.dart)

- Modify `initializeCamera` to call `_enableTorchMode(true, isRestore: true)` if `torchEnabled` is true, after the camera use cases are bound and camera info is updated.
- Modify `_enableTorchMode` to accept an optional `isRestore` boolean parameter (defaulting to `false`). If `isRestore` is true and the operation fails (e.g., because the current camera doesn't have a flash unit), the error should not be added to `cameraErrorStreamController`.

## Verification Plan

### Automated Tests

I will add unit tests in `android_camera_camerax_test.dart` to verify:
1. `setFlashMode` with `FlashMode.torch` sets `torchEnabled` to true.
2. `initializeCamera` attempts to restore torch state if `torchEnabled` is true.
3. `_enableTorchMode` handles failures silently when `isRestore` is true.

Run tests using:
```bash
dart test test/android_camera_camerax_test.dart
```

### Manual Verification

Since I cannot easily test on physical devices with different camera configurations here, I will rely on the unit tests and mocking the CameraX behavior to ensure the logic works as expected.
