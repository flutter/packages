// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/image_capture.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/resolution_selector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'image_capture_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[
  TestImageCaptureHostApi,
  TestInstanceManagerHostApi,
  ResolutionSelector
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('ImageCapture', () {
    tearDown(() => TestImageCaptureHostApi.setup(null));

    test('detached create does not call create on the Java side', () async {
      final MockTestImageCaptureHostApi mockApi = MockTestImageCaptureHostApi();
      TestImageCaptureHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      ImageCapture.detached(
        instanceManager: instanceManager,
        targetFlashMode: ImageCapture.flashModeOn,
        resolutionSelector: MockResolutionSelector(),
      );

      verifyNever(mockApi.create(argThat(isA<int>()), argThat(isA<int>()),
          argThat(isA<ResolutionSelector>())));
    });

    test('create calls create on the Java side', () async {
      final MockTestImageCaptureHostApi mockApi = MockTestImageCaptureHostApi();
      TestImageCaptureHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      const int targetFlashMode = ImageCapture.flashModeAuto;
      final MockResolutionSelector mockResolutionSelector =
          MockResolutionSelector();
      const int mockResolutionSelectorId = 24;

      instanceManager.addHostCreatedInstance(
          mockResolutionSelector, mockResolutionSelectorId,
          onCopy: (ResolutionSelector original) {
        return MockResolutionSelector();
      });

      ImageCapture(
        instanceManager: instanceManager,
        targetFlashMode: targetFlashMode,
        resolutionSelector: mockResolutionSelector,
      );

      verify(mockApi.create(
          argThat(isA<int>()),
          argThat(equals(targetFlashMode)),
          argThat(equals(mockResolutionSelectorId))));
    });

    test('setFlashMode makes call to set flash mode for ImageCapture instance',
        () async {
      final MockTestImageCaptureHostApi mockApi = MockTestImageCaptureHostApi();
      TestImageCaptureHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      const int flashMode = ImageCapture.flashModeOff;
      final ImageCapture imageCapture = ImageCapture.detached(
        instanceManager: instanceManager,
      );
      instanceManager.addHostCreatedInstance(
        imageCapture,
        0,
        onCopy: (_) => ImageCapture.detached(instanceManager: instanceManager),
      );

      await imageCapture.setFlashMode(flashMode);

      verify(mockApi.setFlashMode(
          instanceManager.getIdentifier(imageCapture), flashMode));
    });

    test('takePicture makes call to capture still image', () async {
      final MockTestImageCaptureHostApi mockApi = MockTestImageCaptureHostApi();
      TestImageCaptureHostApi.setup(mockApi);

      const String expectedPicturePath = 'test/path/to/picture';
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final ImageCapture imageCapture = ImageCapture.detached(
        instanceManager: instanceManager,
      );
      instanceManager.addHostCreatedInstance(
        imageCapture,
        0,
        onCopy: (_) => ImageCapture.detached(),
      );

      when(mockApi.takePicture(instanceManager.getIdentifier(imageCapture)))
          .thenAnswer((_) async => expectedPicturePath);
      expect(await imageCapture.takePicture(), equals(expectedPicturePath));
      verify(mockApi.takePicture(instanceManager.getIdentifier(imageCapture)));
    });
  });
}
