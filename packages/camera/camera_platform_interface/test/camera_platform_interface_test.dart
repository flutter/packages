// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_platform_interface/src/method_channel/method_channel_camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$CameraPlatform', () {
    test('$MethodChannelCamera is the default instance', () {
      expect(CameraPlatform.instance, isA<MethodChannelCamera>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        CameraPlatform.instance = ImplementsCameraPlatform();
        // In versions of `package:plugin_platform_interface` prior to fixing
        // https://github.com/flutter/flutter/issues/109339, an attempt to
        // implement a platform interface using `implements` would sometimes
        // throw a `NoSuchMethodError` and other times throw an
        // `AssertionError`.  After the issue is fixed, an `AssertionError` will
        // always be thrown.  For the purpose of this test, we don't really care
        // what exception is thrown, so just allow any exception.
      }, throwsA(anything));
    });

    test('Can be extended', () {
      CameraPlatform.instance = ExtendsCameraPlatform();
    });

    test(
        'Default implementation of availableCameras() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.availableCameras(),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of onCameraInitialized() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.onCameraInitialized(1),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of onResolutionChanged() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.onCameraResolutionChanged(1),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of onCameraClosing() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.onCameraClosing(1),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of onCameraError() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.onCameraError(1),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of onDeviceOrientationChanged() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.onDeviceOrientationChanged(),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of lockCaptureOrientation() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.lockCaptureOrientation(
            1, DeviceOrientation.portraitUp),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of unlockCaptureOrientation() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.unlockCaptureOrientation(1),
        throwsUnimplementedError,
      );
    });

    test('Default implementation of dispose() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.dispose(1),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of createCamera() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.createCamera(
          const CameraDescription(
            name: 'back',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          ),
          ResolutionPreset.low,
        ),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of createCameraWithSettings() should call createCamera() passing parameters',
        () {
      // Arrange
      const CameraDescription cameraDescription = CameraDescription(
        name: 'back',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 0,
      );

      const MediaSettings mediaSettings = MediaSettings(
        resolutionPreset: ResolutionPreset.low,
        fps: 15,
        videoBitrate: 200000,
        audioBitrate: 32000,
        enableAudio: true,
      );

      bool createCameraCalled = false;

      final OverriddenCameraPlatform cameraPlatform = OverriddenCameraPlatform((
        CameraDescription cameraDescriptionArg,
        ResolutionPreset? resolutionPresetArg,
        bool enableAudioArg,
      ) {
        expect(
          cameraDescriptionArg,
          cameraDescription,
          reason: 'should pass camera description',
        );
        expect(
          resolutionPresetArg,
          mediaSettings.resolutionPreset,
          reason: 'should pass resolution preset',
        );
        expect(
          enableAudioArg,
          mediaSettings.enableAudio,
          reason: 'should pass enableAudio',
        );

        createCameraCalled = true;
      });

      // Act & Assert
      cameraPlatform.createCameraWithSettings(
        cameraDescription,
        mediaSettings,
      );

      expect(createCameraCalled, isTrue,
          reason:
              'default implementation of createCameraWithSettings should call createCamera passing parameters');
    });

    test(
        'Default implementation of initializeCamera() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.initializeCamera(1),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of pauseVideoRecording() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.pauseVideoRecording(1),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of prepareForVideoRecording() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.prepareForVideoRecording(),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of resumeVideoRecording() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.resumeVideoRecording(1),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of setFlashMode() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.setFlashMode(1, FlashMode.auto),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of setExposureMode() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.setExposureMode(1, ExposureMode.auto),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of setExposurePoint() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.setExposurePoint(1, null),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of getMinExposureOffset() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.getMinExposureOffset(1),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of getMaxExposureOffset() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.getMaxExposureOffset(1),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of getExposureOffsetStepSize() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.getExposureOffsetStepSize(1),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of setExposureOffset() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.setExposureOffset(1, 2.0),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of setFocusMode() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.setFocusMode(1, FocusMode.auto),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of setFocusPoint() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.setFocusPoint(1, null),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of startVideoRecording() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.startVideoRecording(1),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of stopVideoRecording() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.stopVideoRecording(1),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of takePicture() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.takePicture(1),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of getMaxZoomLevel() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.getMaxZoomLevel(1),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of getMinZoomLevel() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.getMinZoomLevel(1),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of setZoomLevel() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.setZoomLevel(1, 1.0),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of pausePreview() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.pausePreview(1),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of resumePreview() should throw unimplemented error',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        () => cameraPlatform.resumePreview(1),
        throwsUnimplementedError,
      );
    });

    test(
        'Default implementation of supportsImageStreaming() should return false',
        () {
      // Arrange
      final ExtendsCameraPlatform cameraPlatform = ExtendsCameraPlatform();

      // Act & Assert
      expect(
        cameraPlatform.supportsImageStreaming(),
        false,
      );
    });
  });

  group('exports', () {
    test('CameraDescription is exported', () {
      const CameraDescription(
          name: 'abc-123',
          sensorOrientation: 1,
          lensDirection: CameraLensDirection.external);
    });

    test('CameraException is exported', () {
      CameraException('1', 'error');
    });

    test('CameraImageData is exported', () {
      const CameraImageData(
        width: 1,
        height: 1,
        format: CameraImageFormat(ImageFormatGroup.bgra8888, raw: 1),
        planes: <CameraImagePlane>[],
      );
    });

    test('ExposureMode is exported', () {
      // ignore: unnecessary_statements
      ExposureMode.auto;
    });

    test('FlashMode is exported', () {
      // ignore: unnecessary_statements
      FlashMode.auto;
    });

    test('FocusMode is exported', () {
      // ignore: unnecessary_statements
      FocusMode.auto;
    });

    test('ResolutionPreset is exported', () {
      // ignore: unnecessary_statements
      ResolutionPreset.high;
    });

    test('VideoCaptureOptions is exported', () {
      const VideoCaptureOptions(123);
    });
  });
}

class ImplementsCameraPlatform implements CameraPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ExtendsCameraPlatform extends CameraPlatform {}

class OverriddenCameraPlatform extends CameraPlatform {
  OverriddenCameraPlatform(this._onCreateCameraCalled);

  final void Function(
    CameraDescription cameraDescription,
    ResolutionPreset? resolutionPreset,
    bool enableAudio,
  ) _onCreateCameraCalled;

  @override
  Future<int> createCamera(
      CameraDescription cameraDescription, ResolutionPreset? resolutionPreset,
      {bool enableAudio = false}) {
    _onCreateCameraCalled(cameraDescription, resolutionPreset, enableAudio);
    return Future<int>.value(0);
  }
}
