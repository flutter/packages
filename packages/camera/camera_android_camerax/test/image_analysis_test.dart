// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data' show Uint8List;

import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/image_analysis.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart'
    show CameraImageData, CameraImageFormat, CameraImagePlane, ImageFormatGroup;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'image_analysis_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[TestImageAnalysisHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('ImageAnalysis', () {
    tearDown(() => TestImageAnalysisHostApi.setup(null));

    test('detached create does not call create on the Java side', () async {
      final MockTestImageAnalysisHostApi mockApi = MockTestImageAnalysisHostApi();
      TestImageAnalysisHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      ImageAnalysis.detached(
        instanceManager: instanceManager,
        targetResolution: ResolutionInfo(width: 50, height: 10),
      );

      verifyNever(mockApi.create(argThat(isA<int>()),
          argThat(isA<ResolutionInfo>())));
    });

    test('create calls create on the Java side', () async {
      final MockTestImageAnalysisHostApi mockApi = MockTestImageAnalysisHostApi();
      TestImageAnalysisHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      const int targetResolutionWidth = 10;
      const int targetResolutionHeight = 50;
      ImageAnalysis(
        instanceManager: instanceManager,
        targetResolution: ResolutionInfo(
            width: targetResolutionWidth, height: targetResolutionHeight),
      );

      final VerificationResult createVerification = verify(mockApi.create(
          argThat(isA<int>()), captureAny));
      final ResolutionInfo capturedResolutionInfo =
          createVerification.captured.single as ResolutionInfo;
      expect(capturedResolutionInfo.width, equals(targetResolutionWidth));
      expect(capturedResolutionInfo.height, equals(targetResolutionHeight));
    });

    test('setAnalyzer makes call to set analyzer on ImageAnalysis instance',
        () async {
      final MockTestImageAnalysisHostApi mockApi = MockTestImageAnalysisHostApi();
      TestImageAnalysisHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final ImageAnalysis imageAnalysis = ImageAnalysis.detached(
        instanceManager: instanceManager,
      );
      const int imageAnalysisIdentifier = 99;
      instanceManager.addHostCreatedInstance(
        imageAnalysis,
        imageAnalysisIdentifier,
        onCopy: (_) => ImageAnalysis.detached(),
      );

      imageAnalysis.setAnalyzer();

      verify(mockApi.setAnalyzer(imageAnalysisIdentifier));
    });

    test('clearAnalyzer makes call to set analyzer on ImageAnalysis instance',
        () async {
      final MockTestImageAnalysisHostApi mockApi = MockTestImageAnalysisHostApi();
      TestImageAnalysisHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final ImageAnalysis imageAnalysis = ImageAnalysis.detached(
        instanceManager: instanceManager,
      );
      const int imageAnalysisIdentifier = 59;
      instanceManager.addHostCreatedInstance(
        imageAnalysis,
        imageAnalysisIdentifier,
        onCopy: (_) => ImageAnalysis.detached(),
      );

      imageAnalysis.clearAnalyzer();

      verify(mockApi.clearAnalyzer(imageAnalysisIdentifier));
    });

    test('flutterApi onImageAnalyzed adds event with image information to expected stream', () async {
      final ImageAnalysisFlutterApiImpl flutterApi =
          ImageAnalysisFlutterApiImpl();
      
      // Fake image information for testing.
      const int bytesPerRow = 5;
      const int bytesPerPixel = 1;
      final Uint8List bytes = Uint8List(50);
      final List<ImagePlaneInformation> imagePlanesInformation = <ImagePlaneInformation>[
        ImagePlaneInformation(
          bytesPerRow: bytesPerRow,
          bytesPerPixel: bytesPerPixel,
          bytes: bytes,
        )];
      const int width = 5;
      const int height = 10;
      const int format = 35;
      final ImageInformation imageInformation =
        ImageInformation(
          width: width,
          height: height,
          format: format,
          imagePlanesInformation: imagePlanesInformation,
        );

      ImageAnalysis.onStreamedFrameAvailableStreamController.stream
          .listen((CameraImageData cameraImageData) {
        expect(cameraImageData.format!.group, equals(ImageFormatGroup.yuv420));
        expect(cameraImageData.planes.first, isNotNull);
        expect(cameraImageData.planes.first!.bytes, equals(bytes));
        expect(cameraImageData.planes.first!.bytesPerRow, equals(bytesPerRow));
        expect(cameraImageData.planes.first!.bytesPerPixel, equals(bytesPerPixel));
        expect(cameraImageData.format!.raw, equals(format));
        expect(cameraImageData.height, equals(height));
        expect(cameraImageData.width, equals(width));
      });

      flutterApi.onImageAnalyzed(imageInformation);
    });
  });
}
