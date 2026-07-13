## Fix NullPointerException on backgrounding during active video recording
The `NullPointerException` occurs because the Flutter-side state representing an active recording becomes desynced from the Native CameraX state when the app goes into the background.

When an app using the `camera` plugin is backgrounded, the `CameraController` automatically calls `dispose()` to tear down the camera resources. This invokes `processCameraProvider?.unbindAll()` in the `camera_android_camerax` plugin. 

**Native Cleanup Clarity:**
When `processCameraProvider?.unbindAll()` is called natively, CameraX unbinds the `VideoCapture` use case. This action inherently stops any active recording on the native side. CameraX gracefully finalizes the recording and saves the video file to the disk without corrupting it. No hanging `Recording` instances are left behind natively.

However, the `dispose` method on the Dart side does not clear the `recording` and `pendingRecording` objects. When the app is resumed, the singleton `AndroidCameraCameraX` still thinks the previous recording is active (`recording != null`). When the user tries to start a new recording, `startVideoCapturing` returns silently. When they click the "Stop" button, `stopVideoRecording` attempts to stop the old recording by calling `await recording!.close()`. Since the Native CameraX `Recorder` was already finalized, this throws a `java.lang.NullPointerException`.

## User Review Required
No major architectural shifts or breaking changes are introduced. This is a straightforward bug fix to clean up internal state during teardown.

## Open Questions
None. The root cause and fix are well understood.

---

## Proposed Changes

### camera_android_camerax package
We will update `dispose()` to clean up the video recording state so it correctly aligns with native behavior upon teardown. 

**Why `dispose()`?**
`dispose()` is called when the camera needs to be fully torn down—either because the app is backgrounding or the user is switching to a different camera (e.g., front to back). Since `AndroidCameraCameraX` operates as a singleton, failing to clear the recording state during `dispose()` means the next camera initialized will erroneously think a recording is still active. Clearing the state in `dispose()` guarantees a clean slate for the next camera session, regardless of the trigger (backgrounding, camera switching, or hot restart).

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
Add a Flutter integration test mimicking the app lifecycle pause/resume while recording. (Flutter integration tests run on devices using Espresso underneath).

```dart
    testWidgets(
        'video recording state is cleared after camera is disposed',
        (WidgetTester tester) async {
      final CameraController cameraController = CameraController(
        cameras[0],
        ResolutionPreset.low,
      );
      await cameraController.initialize();
      await cameraController.startVideoRecording();

      // Dispose the controller, which simulates what the example app does
      // when the AppLifecycleState becomes inactive (e.g. backgrounding).
      await cameraController.dispose();

      // Create a new controller (simulating app resume)
      final CameraController newController = CameraController(
        cameras[0],
        ResolutionPreset.low,
      );
      await newController.initialize();

      // Attempt to start a new recording. This should not throw or silently fail.
      await newController.startVideoRecording();
      
      // Stop it, ensuring no NPE is thrown by the native side.
      final XFile file = await newController.stopVideoRecording();
      expect(file, isNotNull);
      
      await newController.dispose();
    });
```

## Verification Plan
Verification ensures the app gracefully handles backgrounding during recordings and cleanly starts new recordings upon resume.

### Automated Tests (What I can do autonomously)
As an AI agent, I am unable to launch a local Android Emulator or connect to a physical Android device, meaning I cannot run integration tests (`integration-test`) or manual UI verification myself. However, I can compile the application to ensure it builds correctly, and I can run all local unit tests.

I will run the following commands:
```bash
# Verify the example APK builds successfully without errors
cd example/android && ./gradlew assembleDebug

# Run unit tests to verify the Dart logic works as expected
dart run ../../../script/tool/bin/flutter_plugin_tools.dart dart-test --packages=camera_android_camerax
```

### Manual Verification (What requires human interaction/devices)
Because I do not have access to an emulator or physical device, a human developer is needed to run the integration tests and verify the UI on a device.

1. Run the integration test on an attached device:
```bash
dart run ../../../script/tool/bin/flutter_plugin_tools.dart integration-test --android --packages=camera_android_camerax
```
2. Run the example app (`example/lib/main.dart`) on an Android device.
3. Click the video camera icon to start recording a new video.
4. Background the app (e.g., navigate to the home screen).
5. Resume the app.
6. Click the video camera icon to start recording a new video.
7. Click the stop icon to stop recording.
8. Verify the app does not crash, the recording preview is displayed, and the second video is successfully saved to the device.
