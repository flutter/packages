# Implementation Plan: Defensive Surface Texture Cleanup in `camera_android_camerax`

## Overview & Executive Summary

When tearing down or rapidly re-navigating between camera views (e.g. pushing a second camera preview route over an existing one and popping back, or disposing during initialization), `camera_android_camerax` throws an uncaught `java.lang.IllegalStateException`:
```
java.lang.IllegalStateException: releaseFlutterSurfaceTexture() cannot be called if the flutterSurfaceProducer for the camera preview has not yet been initialized.
```

While concurrent multi-camera streaming is unsupported by design in the Flutter camera plugin, resource disposal and lifecycle teardown must be defensive and idempotent. Calling `releaseSurfaceProvider()` on an uninitialized or already-released `Preview` instance must safely no-op rather than crashing the native JVM with an unhandled exception.

---

## 1. Problem Analysis & Code Pointers

### 1.1 Native Code: `PreviewProxyApi.java` & Legacy `PreviewHostApiImpl.java`

Surface management for the camera preview in CameraX is handled by [PreviewProxyApi.java](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/android/src/main/java/io/flutter/plugins/camerax/PreviewProxyApi.java).

- **The Failing Check** ([PreviewProxyApi.java:L84-93](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/android/src/main/java/io/flutter/plugins/camerax/PreviewProxyApi.java#L84-L93)):
  ```java
  @Override
  public void releaseSurfaceProvider(@NonNull Preview pigeonInstance) {
    final TextureRegistry.SurfaceProducer surfaceProducer = surfaceProducers.remove(pigeonInstance);
    if (surfaceProducer != null) {
      surfaceProducer.release();
      return;
    }
    throw new IllegalStateException(
        "releaseFlutterSurfaceTexture() cannot be called if the flutterSurfaceProducer for the"
            + " camera preview has not yet been initialized.");
  }
  ```
- **Origin of the Error Message**:
  Notice the error message refers to `releaseFlutterSurfaceTexture()` and `flutterSurfaceProducer`. Prior to the ProxyApi migration (commit `2fcc4032dd8b`), this logic resided in `PreviewHostApiImpl.java:L155-163`:
  ```java
  public void releaseFlutterSurfaceTexture() {
    if (flutterSurfaceProducer != null) {
      flutterSurfaceProducer.release();
      return;
    }
    throw new IllegalStateException(
        "releaseFlutterSurfaceTexture() cannot be called if the flutterSurfaceProducer for the camera preview has not yet been initialized.");
  }
  ```
  When migrated to `PreviewProxyApi.java`, the method was renamed to `releaseSurfaceProvider(@NonNull Preview pigeonInstance)`, but retained the strict assertion check and legacy exception text.
- **Related Host Check** ([PreviewProxyApi.java:L96-104](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/android/src/main/java/io/flutter/plugins/camerax/PreviewProxyApi.java#L96-L104)):
  ```java
  @Override
  public boolean surfaceProducerHandlesCropAndRotation(@NonNull Preview pigeonInstance) {
    final TextureRegistry.SurfaceProducer surfaceProducer = surfaceProducers.get(pigeonInstance);
    if (surfaceProducer != null) {
      return surfaceProducer.handlesCropAndRotation();
    }
    throw new IllegalStateException(
        "surfaceProducerHandlesCropAndRotation() cannot be called if the flutterSurfaceProducer for"
            + " the camera preview has not yet been initialized.");
  }
  ```
  If queried when uninitialized or already released, this method also throws an `IllegalStateException`.
- **Dispatcher Failure Mode**:
  In Pigeon's generated Kotlin dispatcher ([CameraXLibrary.g.kt:L3327-3342](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/android/src/main/java/io/flutter/plugins/camerax/CameraXLibrary.g.kt#L3327-L3342)), uncaught runtime exceptions in `api.releaseSurfaceProvider(...)` are not caught and bubble up to the platform channel layer as unhandled errors, crashing the process or rejecting the platform channel future with a `PlatformException`.

### 1.2 Dart Lifecycle & Call Sites

In [android_camera_camerax.dart](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/lib/src/android_camera_camerax.dart):

1. **Singleton Plugin Architecture**:
   - `AndroidCameraCameraX` implements `CameraPlatform` and is instantiated as a singleton (`CameraPlatform.instance = AndroidCameraCameraX()`).
   - The plugin stores camera state in instance variables, including [preview](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/lib/src/android_camera_camerax.dart#L49):
     ```dart
     @visibleForTesting
     Preview? preview;
     ```
2. **Camera Initialization** ([android_camera_camerax.dart:L406-410](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/lib/src/android_camera_camerax.dart#L406-L410)):
   ```dart
   preview = Preview(
     resolutionSelector: _presetResolutionSelector,
     targetFpsRange: _targetFpsRange,
   );
   _flutterSurfaceTextureId = await preview!.setSurfaceProvider(systemServicesManager);
   ```
3. **Camera Disposal** ([android_camera_camerax.dart:L515-521](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/lib/src/android_camera_camerax.dart#L515-L521)):
   ```dart
   @override
   Future<void> dispose(int cameraId) async {
     await preview?.releaseSurfaceProvider();
     await liveCameraState?.removeObservers();
     await processCameraProvider?.unbindAll();
     await imageAnalysis?.clearAnalyzer();
     await deviceOrientationManager.stopListeningForDeviceOrientationChange();
     ...
   }
   ```

### 1.3 Why the Exception Triggers in Real Flows

The exception occurs under multiple realistic app lifecycle scenarios:

1. **Stacked Route Navigation (The User's Repro)**:
   - **Screen A** initializes `CameraController A`. In `AndroidCameraCameraX`, `preview` is assigned `Preview A`. Native `setSurfaceProvider` records `Preview A -> SurfaceProducer A` in `surfaceProducers`.
   - **Screen B** is pushed over Screen A and initializes `CameraController B`. In `AndroidCameraCameraX`, `preview` is overwritten with `Preview B`. Native records `Preview B -> SurfaceProducer B`.
   - User pops Screen B (Back button). `CameraController B.dispose()` executes `dispose(cameraId)`. Dart calls `preview?.releaseSurfaceProvider()` on `Preview B`. Native releases `SurfaceProducer B` and removes `Preview B` from `surfaceProducers`.
   - User pops Screen A. `CameraController A.dispose()` executes `dispose(cameraId)`. Because `AndroidCameraCameraX.preview` was overwritten by Screen B, it still points to `Preview B`! Dart calls `preview?.releaseSurfaceProvider()` on `Preview B` a second time.
   - Native looks up `Preview B` in `surfaceProducers`. It was already removed! Native throws `IllegalStateException`.
2. **Rapid Route Pops / Aborted Initialization**:
   - If a screen is pushed and immediately popped before `createCameraWithSettings` / `setSurfaceProvider` completes, the widget unmount calls `controller.dispose()`.
   - If `preview` was instantiated or if a prior preview reference was held, calling `releaseSurfaceProvider()` before `setSurfaceProvider` completes throws `IllegalStateException`.
3. **Double / Redundant Disposal**:
   - Calling `dispose()` multiple times on a controller or camera instance causes subsequent calls to fail because the cleanup was not idempotent.

---

## 2. Proposed Solution: Defensive & Idempotent Teardown

### 2.1 Native Implementation (`PreviewProxyApi.java`)

Surface cleanup should be **safe, idempotent, and non-fatal**. If `surfaceProducer` is `null` (not yet created, or already removed and released), `releaseSurfaceProvider` should safely no-op and optionally log a debug message.

Similarly, `surfaceProducerHandlesCropAndRotation` should defensively return `false` if called when `surfaceProducer` is null, rather than crashing.

#### Code Changes in `android/src/main/java/io/flutter/plugins/camerax/PreviewProxyApi.java`

```java
package io.flutter.plugins.camerax;

import android.hardware.camera2.CaptureRequest;
import android.util.Log;
import android.util.Range;
import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.OptIn;
import androidx.camera.camera2.interop.Camera2Interop;
import androidx.camera.camera2.interop.ExperimentalCamera2Interop;
import androidx.camera.core.Preview;
import androidx.camera.core.ResolutionInfo;
import androidx.camera.core.SurfaceRequest;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import io.flutter.view.TextureRegistry;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Executors;

class PreviewProxyApi extends PigeonApiPreview {
  private static final String TAG = "PreviewProxyApi";

  // Stores the SurfaceProducer when it is used as a SurfaceProvider for a Preview.
  private final Map<Preview, TextureRegistry.SurfaceProducer> surfaceProducers = new HashMap<>();

  ...

  @Override
  public void releaseSurfaceProvider(@NonNull Preview pigeonInstance) {
    final TextureRegistry.SurfaceProducer surfaceProducer = surfaceProducers.remove(pigeonInstance);
    if (surfaceProducer == null) {
      Log.d(
          TAG,
          "releaseSurfaceProvider() called for a Preview whose SurfaceProducer is null or already released.");
      return;
    }
    surfaceProducer.release();
  }

  @Override
  public boolean surfaceProducerHandlesCropAndRotation(@NonNull Preview pigeonInstance) {
    final TextureRegistry.SurfaceProducer surfaceProducer = surfaceProducers.get(pigeonInstance);
    if (surfaceProducer == null) {
      Log.d(
          TAG,
          "surfaceProducerHandlesCropAndRotation() called for a Preview whose SurfaceProducer is null or already released.");
      return false;
    }
    return surfaceProducer.handlesCropAndRotation();
  }
```

### 2.2 Surface & Producer Lifecycle & Synchronization Analysis

1. **Thread Concurrency**:
   - `setSurfaceProvider`, `releaseSurfaceProvider`, and `surfaceProducerHandlesCropAndRotation` are Pigeon-dispatched methods called exclusively on Android's main (UI) thread.
   - The surface frame callback in `request.provideSurface` runs asynchronously on a single-thread executor (`Executors.newSingleThreadExecutor()`), but only interacts with `flutterSurface.release()` and `systemServicesManager.onCameraError(...)`. It does not mutate `surfaceProducers`.
   - Therefore, `surfaceProducers.remove(pigeonInstance)` on the main thread is thread-safe.
2. **Surface Producer Cleanup on Engine**:
   - Calling `surfaceProducer.release()` triggers the Flutter engine to free texture memory and de-register callbacks.
   - Calling it once and removing it from `surfaceProducers` ensures `surfaceProducer.release()` is never called twice on the same producer.
3. **Dart State Tracking in `AndroidCameraCameraX`**:
   - In Dart, `AndroidCameraCameraX.dispose(int cameraId)` invokes `await preview?.releaseSurfaceProvider();`.
   - Because native `releaseSurfaceProvider` is made idempotent, subsequent calls on the same `Preview` instance simply no-op.
   - Note on Dart `preview = null`: In existing unit tests (`test/android_camera_camerax_test.dart:L1968`), tests assert `verify(camera.preview!.releaseSurfaceProvider())` *after* `await camera.dispose(...)`. Nulling `preview` inside `dispose` would break those existing tests unless they are refactored to retain a local reference. Keeping `preview` as-is while guaranteeing native idempotency ensures 100% backward compatibility with existing tests and third-party callers.

---

## 3. Comprehensive Testing Plan

### 3.1 Native Unit Tests (`android/src/test/java/io/flutter/plugins/camerax/PreviewTest.java`)

Add unit tests covering uninitialized and redundant disposal in [PreviewTest.java](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/android/src/test/java/io/flutter/plugins/camerax/PreviewTest.java):

1. **`releaseSurfaceProvider_noopWhenSurfaceProducerNull`**:
   - Verify calling `releaseSurfaceProvider` on a `Preview` whose surface provider was never set completes silently without throwing `IllegalStateException`.
   ```java
   @Test
   public void releaseSurfaceProvider_noopWhenSurfaceProducerNull() {
     final PigeonApiPreview api = new TestProxyApiRegistrar().getPigeonApiPreview();
     final Preview instance = mock(Preview.class);

     // Should safely no-op and not throw IllegalStateException.
     api.releaseSurfaceProvider(instance);
   }
   ```
2. **`releaseSurfaceProvider_isIdempotentWhenCalledMultipleTimes`**:
   - Verify that calling `releaseSurfaceProvider` repeatedly on the same `Preview` releases the `SurfaceProducer` exactly once and safely no-ops on subsequent calls.
   ```java
   @Test
   public void releaseSurfaceProvider_isIdempotentWhenCalledMultipleTimes() {
     final TextureRegistry mockTextureRegistry = mock(TextureRegistry.class);
     final TextureRegistry.SurfaceProducer mockSurfaceProducer =
         mock(TextureRegistry.SurfaceProducer.class);
     when(mockSurfaceProducer.id()).thenReturn(0L);
     when(mockTextureRegistry.createSurfaceProducer()).thenReturn(mockSurfaceProducer);
     final PigeonApiPreview api =
         new TestProxyApiRegistrar() {
           @NonNull
           @Override
           TextureRegistry getTextureRegistry() {
             return mockTextureRegistry;
           }
         }.getPigeonApiPreview();

     final Preview instance = mock(Preview.class);
     final SystemServicesManager systemServicesManager = mock(SystemServicesManager.class);
     api.setSurfaceProvider(instance, systemServicesManager);

     // First call releases producer.
     api.releaseSurfaceProvider(instance);
     verify(mockSurfaceProducer, times(1)).release();

     // Subsequent call should safely no-op without throwing.
     api.releaseSurfaceProvider(instance);
     verify(mockSurfaceProducer, times(1)).release();
   }
   ```
3. **`surfaceProducerHandlesCropAndRotation_returnsFalseWhenSurfaceProducerNull`**:
   - Verify calling `surfaceProducerHandlesCropAndRotation` when `surfaceProducer` is null returns `false` without throwing.
   ```java
   @Test
   public void surfaceProducerHandlesCropAndRotation_returnsFalseWhenSurfaceProducerNull() {
     final PigeonApiPreview api = new TestProxyApiRegistrar().getPigeonApiPreview();
     final Preview instance = mock(Preview.class);

     assertFalse(api.surfaceProducerHandlesCropAndRotation(instance));
   }
   ```

### 3.2 Dart Unit Tests (`test/android_camera_camerax_test.dart`)

Add Dart unit tests in [test/android_camera_camerax_test.dart](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/test/android_camera_camerax_test.dart):

1. **Disposing when `preview == null`**:
   - Verify that calling `camera.dispose(cameraId)` when `camera.preview` is null completes normally without exceptions.
2. **Disposing multiple times sequentially**:
   - Verify that calling `await camera.dispose(1); await camera.dispose(1);` completes cleanly and triggers the expected mock invocations without throwing platform channel exceptions.
3. **Disposing partially-initialized camera**:
   - Simulate a failure during `createCameraWithSettings` after `preview` is instantiated but before `setSurfaceProvider` completes; verify that calling `dispose()` does not propagate unhandled errors.

### 3.3 Integration Tests (`example/integration_test/integration_test.dart`)

Add end-to-end integration tests to test real Android lifecycle behavior on devices/emulators:

1. **Rapid Initialize & Dispose Test**:
   - Create a `CameraController`, call `initialize()`, and immediately call `dispose()` without awaiting preview rendering.
   - Verify no crash or unhandled `PlatformException` is thrown.
2. **Route Push & Pop Simulation Test**:
   - Initialize `controllerA`.
   - Initialize `controllerB`.
   - Call `controllerB.dispose()`.
   - Call `controllerA.dispose()`.
   - Verify that both controllers dispose without `IllegalStateException`.
3. **Re-initialization After Rapid Teardown**:
   - After disposing in the scenarios above, instantiate a new `CameraController`, call `initialize()`, and verify the preview starts running successfully.
4. **Adherence to [TESTING.md](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/TESTING.md)**:
   - Ensure any video recording tests maintain the mandatory 4-second delay before stopping recording to prevent CI flakiness.

---

## 4. PR Verification Standards (`flutter/packages`)

All changes must conform to the strict repository standards documented in [AGENTS.md](file:///Users/camillesimon/packages/AGENTS.md) and package-specific [AGENTS.md](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/AGENTS.md).

### 4.1 Verification Commands

Execute the following commands from the repository root:

```bash
export REPO_ROOT=$(pwd)

# 1. Format code (Google Java Format for Java, dart format for Dart)
dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart format --packages camera_android_camerax

# 2. Static analysis
dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart analyze --packages camera_android_camerax

# 3. Dart unit tests
dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart dart-test --packages camera_android_camerax

# 4. Native Android unit tests (JUnit / Robolectric)
dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart native-test --android --packages camera_android_camerax --no-integration

# 5. Repository validation & publish check
dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart validate --packages camera_android_camerax
dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart publish-check --packages camera_android_camerax
```

### 4.2 CHANGELOG and Semantic Versioning

- **Version Bump**:
  - Current version in [pubspec.yaml](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/pubspec.yaml#L5): `0.7.4+7`.
  - Because this is a bug fix that does not alter public Dart APIs, a minimal patch bump is required: `0.7.4+8`.
- **Tooling Command**:
  ```bash
  dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart update-release-info \
    --version=minimal \
    --base-branch=origin/main \
    --changelog="Fixes unhandled IllegalStateException during surface provider cleanup."
  ```
- **CHANGELOG Style**:
  - Use active voice, clear concise description.
  - Matches previous entries in [CHANGELOG.md](file:///Users/camillesimon/packages/packages/camera/camera_android_camerax/CHANGELOG.md).

### 4.3 Presubmit Checklist

- [ ] Native unit tests added in `android/src/test/java/io/flutter/plugins/camerax/PreviewTest.java` for all modified native logic.
- [ ] Dart tests in `test/android_camera_camerax_test.dart` pass without warnings.
- [ ] No hardcoded `/` path separators in unit/integration test assertions (use `package:path`).
- [ ] `flutter_plugin_tools format` applied across both Dart and Java files.
- [ ] `flutter_plugin_tools analyze`, `dart-test`, and `native-test` all report green.
- [ ] `pubspec.yaml` version and `CHANGELOG.md` properly updated.
