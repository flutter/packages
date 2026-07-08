## Fix NullPointerException on backgrounding during active video recording
The `NullPointerException` occurs because the Flutter-side state representing an active recording becomes desynced from the Native CameraX state when the app goes into the background.

When an app using the `camera` plugin is backgrounded, the `CameraController` automatically calls `dispose()` to tear down the camera resources. This invokes `processCameraProvider?.unbindAll()` in the `camera_android_camerax` plugin. Unbinding the `VideoCapture` use case natively finalizes any ongoing video recording.

However, the `dispose` method on the Dart side does not clear the `recording` and `pendingRecording` objects. When the app is resumed, the singleton `AndroidCameraCameraX` still thinks the previous recording is active (`recording != null`). When the user tries to start a new recording, `startVideoCapturing` returns silently. When they click the "Stop" button, `stopVideoRecording` attempts to stop the old recording by calling `await recording!.close()`. Since the Native CameraX `Recorder` was already finalized, this throws a `java.lang.NullPointerException`.

## User Review Required
No major architectural shifts or breaking changes are introduced. This is a straightforward bug fix to clean up internal state during teardown.

## Open Questions
None. The root cause and fix are well understood.

---

## Proposed Changes

### camera_android_camerax package
We will update `dispose()` to clean up the video recording state so it correctly aligns with native behavior upon teardown. We'll also add a unit test and an integration test to prevent regressions.

#### [MODIFY] android_camera_camerax.dart
Add state cleanup for `recording`, `pendingRecording`, and `videoOutputPath` in the `dispose` method.

```diff
   /// Releases the resources of the accessed camera with ID [cameraId].
   @override
   Future<void> dispose(int cameraId) async {
     await preview?.releaseSurfaceProvider();
     await liveCameraState?.removeObservers();
     await processCameraProvider?.unbindAll();
     await imageAnalysis?.clearAnalyzer();
     await deviceOrientationManager.stopListeningForDeviceOrientationChange();
+    recording = null;
+    pendingRecording = null;
+    videoOutputPath = null;
   }
```

#### [MODIFY] android_camera_camerax_test.dart
Add assertions in the `dispose` test to ensure that the recording state variables are properly nullified when `dispose()` completes.

```diff
   test(
       'dispose releases Flutter surface texture, removes camera state observers, and unbinds all use cases',
       () async {
+    // Setup mock recording state
+    camera.recording = MockRecording();
+    camera.pendingRecording = MockPendingRecording();
+    camera.videoOutputPath = 'test/path.mp4';
+
     await camera.dispose(3);
 
     verify(mockPreview.releaseSurfaceProvider());
     verify(mockLiveCameraState.removeObservers());
     verify(mockProcessCameraProvider.unbindAll());
     verify(mockImageAnalysis.clearAnalyzer());
     verify(mockDeviceOrientationManager
         .stopListeningForDeviceOrientationChange());
+
+    // Verify state is cleared
+    expect(camera.recording, isNull);
+    expect(camera.pendingRecording, isNull);
+    expect(camera.videoOutputPath, isNull);
   });
```

#### [MODIFY] example/integration_test/integration_test.dart
Add a test mimicking the app lifecycle pause/resume while recording.

```dart
    testWidgets(
        'video recording state is cleared after camera is disposed (simulating backgrounding)',
        (WidgetTester tester) async {
      // 1. Initialize camera
      // 2. Start video recording
      // 3. Call cameraController.dispose() (this happens when app backgrounds)
      // 4. Re-initialize a new cameraController (this happens when app resumes)
      // 5. Start a new video recording
      // 6. Stop the new video recording
      // 7. Assert that no exceptions are thrown and the XFile is returned.
    });
```

## Verification Plan
Verification ensures the app gracefully handles backgrounding during recordings and cleanly starts new recordings upon resume.

### Automated Tests
Run the following commands to ensure all tests pass:
```bash
dart run ../../../script/tool/bin/flutter_plugin_tools.dart dart-test --packages=camera_android_camerax
dart run ../../../script/tool/bin/flutter_plugin_tools.dart integration-test --android --packages=camera_android_camerax
```

### Manual Verification
1. Run the example app (`example/lib/main.dart`) on an Android device.
2. Click the video camera icon to start recording a new video.
3. Background the app (e.g., navigate to the home screen).
4. Resume the app.
5. Click the video camera icon to start recording a new video.
6. Click the stop icon to stop recording.
7. Verify the app does not crash, the recording preview is displayed, and the second video is successfully saved to the device.
