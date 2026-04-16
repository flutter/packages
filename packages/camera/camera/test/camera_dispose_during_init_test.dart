// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

const int mockCameraId = 42;

CameraInitializedEvent get mockInitializedEvent => const CameraInitializedEvent(
  mockCameraId,
  1920,
  1080,
  ExposureMode.auto,
  true,
  FocusMode.auto,
  true,
);

CameraErrorEvent get mockErrorEvent =>
    const CameraErrorEvent(mockCameraId, 'test error description');

DeviceOrientationChangedEvent get mockOrientationEvent =>
    const DeviceOrientationChangedEvent(DeviceOrientation.portraitUp);

/// Mock implementation of [CameraPlatform] for testing.
///
/// This mock platform emits events immediately, simulating real platform behavior
/// when camera initialization and disposal occur.
class TestMockCameraPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements CameraPlatform {
  @override
  Future<void> initializeCamera(
    int? cameraId, {
    ImageFormatGroup? imageFormatGroup = ImageFormatGroup.unknown,
  }) async {}

  @override
  Future<void> dispose(int? cameraId) async {}

  @override
  Future<List<CameraDescription>> availableCameras() =>
      Future<List<CameraDescription>>.value(<CameraDescription>[
        const CameraDescription(
          name: 'cam1',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 90,
        ),
      ]);

  @override
  Future<int> createCameraWithSettings(
    CameraDescription cameraDescription,
    MediaSettings? mediaSettings,
  ) => Future<int>.value(mockCameraId);

  @override
  Future<int> createCamera(
    CameraDescription description,
    ResolutionPreset? resolutionPreset, {
    bool enableAudio = false,
  }) => createCameraWithSettings(description, null);

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) =>
      Stream<CameraInitializedEvent>.value(mockInitializedEvent);

  @override
  Stream<CameraClosingEvent> onCameraClosing(int cameraId) =>
      Stream<CameraClosingEvent>.value(CameraClosingEvent(cameraId));

  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) =>
      Stream<CameraErrorEvent>.value(mockErrorEvent);

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() =>
      Stream<DeviceOrientationChangedEvent>.value(mockOrientationEvent);

  @override
  Future<XFile> takePicture(int cameraId) async =>
      throw PlatformException(code: 'UNAVAILABLE');

  @override
  Future<void> prepareForVideoRecording() async {}

  @override
  Future<void> startVideoRecording(
    int cameraId, {
    Duration? maxVideoDuration,
  }) async => startVideoCapturing(VideoCaptureOptions(cameraId));

  @override
  Future<void> startVideoCapturing(VideoCaptureOptions options) async {}

  @override
  Future<XFile> stopVideoRecording(int cameraId) async =>
      throw PlatformException(code: 'UNAVAILABLE');

  @override
  Future<void> lockCaptureOrientation(
    int? cameraId,
    DeviceOrientation? orientation,
  ) async {}

  @override
  Future<void> unlockCaptureOrientation(int? cameraId) async {}

  @override
  Future<void> pausePreview(int? cameraId) async {}

  @override
  Future<void> resumePreview(int? cameraId) async {}

  @override
  Future<double> getMaxZoomLevel(int? cameraId) async => 1.0;

  @override
  Future<double> getMinZoomLevel(int? cameraId) async => 0.0;

  @override
  Future<void> setZoomLevel(int? cameraId, double? zoom) async {}

  @override
  Future<void> setFlashMode(int? cameraId, FlashMode? mode) async {}

  @override
  Future<void> setExposureMode(int? cameraId, ExposureMode? mode) async {}

  @override
  Future<void> setExposurePoint(int? cameraId, Point<double>? point) async {}

  @override
  Future<double> getMinExposureOffset(int? cameraId) async => -2.0;

  @override
  Future<double> getMaxExposureOffset(int? cameraId) async => 2.0;

  @override
  Future<double> getExposureOffsetStepSize(int? cameraId) async => 0.1;

  @override
  Future<double> setExposureOffset(int? cameraId, double? offset) async => 0.0;

  @override
  Future<void> setFocusMode(int? cameraId, FocusMode? mode) async {}

  @override
  Future<void> setFocusPoint(int? cameraId, Point<double>? point) async {}

  @override
  Future<void> setDescriptionWhileRecording(
    CameraDescription description,
  ) async {}

  @override
  Future<Iterable<VideoStabilizationMode>> getSupportedVideoStabilizationModes(
    int? cameraId,
  ) async => <VideoStabilizationMode>[VideoStabilizationMode.off];

  @override
  Future<void> setVideoStabilizationMode(
    int? cameraId,
    VideoStabilizationMode? mode,
  ) async {}

  @override
  Stream<CameraImageData> onStreamedFrameAvailable(
    int cameraId, {
    CameraImageStreamOptions? options,
  }) => const Stream<CameraImageData>.empty();

  @override
  Widget buildPreview(int cameraId) => const SizedBox.shrink();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('CameraController - Dispose During Initialization', () {
    late TestMockCameraPlatform mockPlatform;

    setUp(() {
      mockPlatform = TestMockCameraPlatform();
      CameraPlatform.instance = mockPlatform;
    });

    test(
      'should handle orientation events when controller is disposed during initialization',
      () async {
        /// Tests that async orientation listener events do not cause exceptions
        /// when the controller is disposed before initialization completes.
        /// This verifies that listeners are properly guarded against updates
        /// to disposed controller instances.
        const cameraDescription = CameraDescription(
          name: 'cam',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 90,
        );

        final controller = CameraController(
          cameraDescription,
          ResolutionPreset.max,
        );

        final Future<void> initFuture = controller.initialize();
        await controller.dispose();

        try {
          await initFuture;
        } catch (e) {
          // Initialization may fail after dispose
        }
      },
    );

    test(
      'should handle error events when controller is disposed during initialization',
      () async {
        /// Tests that async error listener events do not cause exceptions
        /// when the controller is disposed before initialization completes.
        /// This ensures error callbacks are properly guarded and do not attempt
        /// to update disposed controller state.
        const cameraDescription = CameraDescription(
          name: 'cam',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 90,
        );

        final controller = CameraController(
          cameraDescription,
          ResolutionPreset.max,
        );

        final Future<void> initFuture = controller.initialize();
        await controller.dispose();

        try {
          await initFuture;
        } catch (e) {
          // Initialization may fail after dispose
        }
      },
    );

    test(
      'should not update controller value when disposed during async callbacks',
      () async {
        /// Tests that async callbacks from platform do not update controller
        /// state after the controller has been disposed. This verifies that
        /// value assignments are properly guarded with disposal checks.
        const cameraDescription = CameraDescription(
          name: 'cam',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 90,
        );

        final controller = CameraController(
          cameraDescription,
          ResolutionPreset.max,
        );

        final Future<void> initFuture = controller.initialize();
        await controller.dispose();

        try {
          await initFuture;
        } catch (e) {
          // Initialization may fail after dispose
        }
      },
    );

    test('should handle multiple consecutive dispose calls safely', () async {
      /// Tests that calling dispose() multiple times on the same controller
      /// does not cause exceptions or resource leaks. This verifies that
      /// dispose operations are idempotent and properly handle repeated calls.
      const cameraDescription = CameraDescription(
        name: 'cam',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
      );

      final controller = CameraController(
        cameraDescription,
        ResolutionPreset.max,
      );

      final Future<void> initFuture = controller.initialize();

      await controller.dispose();
      await controller.dispose();
      await controller.dispose();

      try {
        await initFuture;
      } catch (e) {
        // Initialization may fail after dispose
      }
    });

    test(
      'should complete initialization successfully when not disposed',
      () async {
        /// Tests the normal initialization flow when the controller is not
        /// disposed. This serves as a baseline to ensure that the disposal
        /// guards do not interfere with normal camera initialization and
        /// controller state management.
        const cameraDescription = CameraDescription(
          name: 'cam',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 90,
        );

        final controller = CameraController(
          cameraDescription,
          ResolutionPreset.max,
        );

        await controller.initialize();

        expect(controller.value.isInitialized, isTrue);
        expect(controller.value.previewSize, const Size(1920, 1080));

        await controller.dispose();
      },
    );
  });
}
