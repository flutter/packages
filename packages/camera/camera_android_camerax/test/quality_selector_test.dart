// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camera_info.dart';
import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/fallback_strategy.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/quality_selector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'quality_selector_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[
  CameraInfo,
  FallbackStrategy,
  TestQualitySelectorHostApi,
  TestInstanceManagerHostApi
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QualitySelector', () {
    tearDown(() {
      TestQualitySelectorHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test('detached constructor does not make call to create on the Java side',
        () {
      final MockTestQualitySelectorHostApi mockApi =
          MockTestQualitySelectorHostApi();
      TestQualitySelectorHostApi.setup(mockApi);
      TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      QualitySelector.detached(
        qualityList: <VideoQualityData>[
          VideoQualityData(quality: VideoQuality.UHD)
        ],
        fallbackStrategy: MockFallbackStrategy(),
        instanceManager: instanceManager,
      );

      verifyNever(mockApi.create(
          argThat(isA<int>()), argThat(isA<List<int>>()), argThat(isA<int>())));
    });

    test('single quality constructor calls create on the Java side', () {
      final MockTestQualitySelectorHostApi mockApi =
          MockTestQualitySelectorHostApi();
      TestQualitySelectorHostApi.setup(mockApi);
      TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      const VideoQuality videoQuality = VideoQuality.FHD;
      final VideoQualityData quality = VideoQualityData(quality: videoQuality);
      final FallbackStrategy fallbackStrategy = MockFallbackStrategy();
      const int fallbackStrategyIdentifier = 9;

      instanceManager.addHostCreatedInstance(
        fallbackStrategy,
        fallbackStrategyIdentifier,
        onCopy: (_) => MockFallbackStrategy(),
      );

      final QualitySelector instance = QualitySelector.from(
        quality: quality,
        fallbackStrategy: fallbackStrategy,
        instanceManager: instanceManager,
      );

      final VerificationResult verificationResult = verify(mockApi.create(
        instanceManager.getIdentifier(instance),
        captureAny,
        fallbackStrategyIdentifier,
      ));
      final List<VideoQualityData?> videoQualityData =
          verificationResult.captured.single as List<VideoQualityData?>;
      expect(videoQualityData.length, equals(1));
      expect(videoQualityData.first!.quality, equals(videoQuality));
    });

    test('quality list constructor calls create on the Java side', () {
      final MockTestQualitySelectorHostApi mockApi =
          MockTestQualitySelectorHostApi();
      TestQualitySelectorHostApi.setup(mockApi);
      TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final List<VideoQualityData> qualityList = <VideoQualityData>[
        VideoQualityData(quality: VideoQuality.FHD),
        VideoQualityData(quality: VideoQuality.highest),
      ];

      final FallbackStrategy fallbackStrategy = MockFallbackStrategy();

      const int fallbackStrategyIdentifier = 9;
      instanceManager.addHostCreatedInstance(
        fallbackStrategy,
        fallbackStrategyIdentifier,
        onCopy: (_) => MockFallbackStrategy(),
      );

      final QualitySelector instance = QualitySelector.fromOrderedList(
        qualityList: qualityList,
        fallbackStrategy: fallbackStrategy,
        instanceManager: instanceManager,
      );

      final VerificationResult verificationResult = verify(mockApi.create(
        instanceManager.getIdentifier(instance),
        captureAny,
        fallbackStrategyIdentifier,
      ));
      final List<VideoQualityData?> videoQualityData =
          verificationResult.captured.single as List<VideoQualityData?>;
      expect(videoQualityData.length, equals(2));
      expect(videoQualityData.first!.quality, equals(VideoQuality.FHD));
      expect(videoQualityData.last!.quality, equals(VideoQuality.highest));
    });

    test('getResolution returns expected resolution info', () async {
      final MockTestQualitySelectorHostApi mockApi =
          MockTestQualitySelectorHostApi();
      TestQualitySelectorHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final QualitySelector instance = QualitySelector.detached(
        instanceManager: instanceManager,
        qualityList: <VideoQualityData>[
          VideoQualityData(quality: VideoQuality.HD)
        ],
        fallbackStrategy: MockFallbackStrategy(),
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (QualitySelector original) => QualitySelector.detached(
          qualityList: original.qualityList,
          fallbackStrategy: original.fallbackStrategy,
          instanceManager: instanceManager,
        ),
      );

      final CameraInfo cameraInfo = MockCameraInfo();
      const int cameraInfoIdentifier = 6;
      instanceManager.addHostCreatedInstance(
        cameraInfo,
        cameraInfoIdentifier,
        onCopy: (_) => MockCameraInfo(),
      );

      const VideoQuality quality = VideoQuality.FHD;
      final ResolutionInfo expectedResult =
          ResolutionInfo(width: 34, height: 23);

      when(mockApi.getResolution(
        cameraInfoIdentifier,
        quality,
      )).thenAnswer((_) {
        return expectedResult;
      });

      final ResolutionInfo result = await QualitySelector.getResolution(
          cameraInfo, quality,
          instanceManager: instanceManager);

      expect(result.width, expectedResult.width);
      expect(result.height, expectedResult.height);

      verify(mockApi.getResolution(
        cameraInfoIdentifier,
        quality,
      ));
    });
  });
}
