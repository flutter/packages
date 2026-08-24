## Goal Description
The goal is to fix an issue in the `camera_android_camerax` package where rapidly changing the exposure offset (e.g., via a slider) causes the camera preview to freeze and throws an exception: `"Setting exposure compensation index was canceled due to the camera being closed or a new request being submitted."`

### Issue Explanation
When a user slides the exposure slider rapidly, multiple `setExposureOffset` calls are triggered in quick succession. The underlying CameraX Android library handles this by cancelling the previous pending request and processing the newest one. This cancellation surfaces as a `CameraControl.OperationCanceledException` in Java.

The Java Pigeon wrapper (`CameraControlProxyApi.java`) handles this correctly by catching the exception and returning `null` to the Dart side to indicate a benign cancellation.

However, in `android_camera_camerax.dart`, the Dart code misinterprets this `null` return value as a fatal camera error. It does two things:
1. Throws a `CameraException` which crashes the local operation.
2. Adds an error string to the global `cameraErrorStreamController`.

Adding an error to `cameraErrorStreamController` notifies the frontend `CameraController` that the camera has encountered a critical, unrecoverable failure. This is what causes the app's camera preview to freeze and stop responding, as the app tears down the camera session in response to the global error.

Additionally, we identified a secondary bug: when `setExposureOffset` succeeds, it currently returns the integer *index* instead of the calculated double *offset* (which violates the `Camera` platform interface contract).

## Design Decisions
> [!NOTE]
> **Returning gracefully on cancellation instead of throwing an exception:** 
> We have decided not to throw an exception when the operation is canceled. The cancellation is primarily caused by intermediate values being set between the old and desired value as the user rapidly scrubs the slider, which supersedes older requests. The only other relevant situation for a cancellation exception is when the camera is closed, in which case failing to set the exposure offset is not a real error. Returning the requested offset gracefully avoids crashing or cluttering the developer's console when these benign cancellations occur.
> 
> **Returning the correct offset value:** 
> The platform interface for `setExposureOffset` specifies that it should return the rounded offset value that was set (e.g. `3.0`). We will be fixing a bug where it previously returned the raw integer index from CameraX (e.g. `15.0`). The CameraX documentation for `CameraControl.setExposureCompensationIndex(int index)` states that it returns a `ListenableFuture<Integer>`, and that this integer is the index that was actually set. The native Pigeon wrapper in `CameraControlProxyApi.java` correctly returns this integer. However, the Dart code was directly returning `newIndex.toDouble()`, thus returning the index instead of multiplying it by the `exposureOffsetStepSize` (e.g. `15 * 0.2 = 3.0`) as required by the `camera` platform interface.

## Proposed Changes

---

### camera_android_camerax Package
We will update `android_camera_camerax.dart` to handle cancellations gracefully and return the correct offset values. We will also prevent `_startFocusAndMetering` from adding benign cancellations to the global error stream.

#### [MODIFY] `lib/src/android_camera_camerax.dart`
```diff
@@ -751,14 +751,9 @@
       );

       if (newIndex == null) {
-        cameraErrorStreamController.add(
-          'Setting exposure compensation index was canceled due to the camera being closed or a new request being submitted.',
-        );
-        throw CameraException(
-          setExposureOffsetFailedErrorCode,
-          'Setting exposure compensation index was canceled due to the camera being closed or a new request being submitted.',
-        );
+        // Return the requested rounded offset if the operation was cancelled.
+        return roundedExposureCompensationIndex * exposureOffsetStepSize;
       }

-      return newIndex.toDouble();
+      return newIndex * exposureOffsetStepSize;
     } on PlatformException catch (e) {
@@ -1771,9 +1766,6 @@
       );

-      if (result == null) {
-        cameraErrorStreamController.add(
-          'Starting focus and metering was canceled due to the camera being closed or a new request being submitted.',
-        );
-      }

       return result?.isFocusSuccessful ?? false;
```

#### [MODIFY] `test/android_camera_camerax_test.dart`
We will update the tests to reflect the graceful handling of cancellations and the correct return value types.

```diff
@@ -4665,7 +4665,7 @@
-    'setExposureOffset throws exception if exposure compensation could not be set due to camera being closed or newer value being set',
+    'setExposureOffset returns gracefully if exposure compensation could not be set due to camera being closed or newer value being set',
     () async {
       // ...
-      expect(() => camera.setExposureOffset(cameraId, offset), throwsA(isA<CameraException>()));
+      expect(await camera.setExposureOffset(cameraId, offset), equals(5.0));
     },
   );

@@ -4715,11 +4715,11 @@
       when(
         mockCameraControl.setExposureCompensationIndex(expectedExposureCompensationIndex),
       ).thenAnswer(
-        (_) async => Future<int>.value(
-          (expectedExposureCompensationIndex * exposureState.exposureCompensationStep).round(),
-        ),
+        (_) async => Future<int>.value(expectedExposureCompensationIndex),
       );

-      // Exposure index * exposure offset step size = exposure offset, i.e.
-      // 15 * 0.2 = 3.
-      expect(await camera.setExposureOffset(cameraId, offset), equals(3));
+      // Exposure index * exposure offset step size = exposure offset, i.e.
+      // 15 * 0.2 = 3.0
+      expect(await camera.setExposureOffset(cameraId, offset), equals(3.0));
     },
   );
```

We will also add a new test to ensure that cancelling `setFocusPoint` does not push an error to the global `cameraErrorStreamController`.

## Verification Plan

### Automated Tests
The modified and newly added tests in `test/android_camera_camerax_test.dart` will initially fail with the current code, and pass once the proposed changes are implemented. These unit tests ensure we do not regress on video recording state by guaranteeing `cameraErrorStreamController` won't emit false errors that would otherwise tear down the camera pipeline.

I will run the tests using:
```bash
dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart dart-test --packages camera_android_camerax
```

### Manual Verification
The user should manually verify the fix by running the example app:
1. Run the `camera_android_camerax/example` app on an Android device.
2. Tap on "Exposure mode" and drag the slider quickly back and forth.
3. Observe that no exceptions are thrown, and the camera preview does not freeze.

### Repository Standards
I will ensure this PR meets the `flutter/packages` standards by doing the following:
1. Validating the code formatting with `dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart format --packages camera_android_camerax`.
2. Validating static analysis with `dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart analyze --packages camera_android_camerax`.
3. Validating tests with `dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart dart-test --packages camera_android_camerax`.
4. Bumping the patch version and generating a `CHANGELOG.md` entry via `dart run $REPO_ROOT/script/tool/bin/flutter_plugin_tools.dart update-release-info --version=minimal --base-branch=origin/main --changelog="Fix exposure offset slider freezing camera preview and fix setExposureOffset return value."`
5. Ensuring the pre-push checks via `.agents/skills/pre-push-skill/SKILL.md` are green.
