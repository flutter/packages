// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/pending_recording.dart';
import 'package:camera_android_camerax/src/quality_selector.dart';
import 'package:camera_android_camerax/src/recorder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'recorder_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[
  QualitySelector,
  TestInstanceManagerHostApi,
  TestFallbackStrategyHostApi,
  TestRecorderHostApi,
  TestQualitySelectorHostApi,
  PendingRecording
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('Recorder', () {
    tearDown(() => TestCameraSelectorHostApi.setup(null));

    test('detached create does not call create on the Java side', () async {
      final MockTestRecorderHostApi mockApi = MockTestRecorderHostApi();
      TestRecorderHostApi.setup(mockApi);
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      Recorder.detached(
          instanceManager: instanceManager, aspectRatio: 0, bitRate: 0);

      verifyNever(mockApi.create(argThat(isA<int>()), argThat(isA<int>()),
          argThat(isA<int>()), argThat(isA<int>())));
    }, skip: 'Flaky test: https://github.com/flutter/flutter/issues/164132');

    test('create does call create on the Java side', () async {
      final MockTestRecorderHostApi mockApi = MockTestRecorderHostApi();
      TestRecorderHostApi.setup(mockApi);
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      const int aspectRatio = 1;
      const int bitRate = 2;
      final QualitySelector qualitySelector = MockQualitySelector();
      const int qualitySelectorIdentifier = 33;

      instanceManager.addHostCreatedInstance(
        qualitySelector,
        qualitySelectorIdentifier,
        onCopy: (_) => MockQualitySelector(),
      );

      Recorder(
          instanceManager: instanceManager,
          aspectRatio: aspectRatio,
          bitRate: bitRate,
          qualitySelector: qualitySelector);

      verify(mockApi.create(argThat(isA<int>()), aspectRatio, bitRate,
          qualitySelectorIdentifier));
    });

    test('getDefaultQualitySelector returns expected QualitySelector',
        () async {
      final MockTestQualitySelectorHostApi mockQualitySelectorApi =
          MockTestQualitySelectorHostApi();
      final MockTestFallbackStrategyHostApi mockFallbackStrategyApi =
          MockTestFallbackStrategyHostApi();
      TestQualitySelectorHostApi.setup(mockQualitySelectorApi);
      TestFallbackStrategyHostApi.setup(mockFallbackStrategyApi);

      final QualitySelector defaultQualitySelector =
          Recorder.getDefaultQualitySelector();
      final List<VideoQuality> expectedVideoQualities = <VideoQuality>[
        VideoQuality.FHD,
        VideoQuality.HD,
        VideoQuality.SD
      ];

      expect(defaultQualitySelector.qualityList.length, equals(3));
      for (int i = 0; i < 3; i++) {
        final VideoQuality currentVideoQuality =
            defaultQualitySelector.qualityList[i].quality;
        expect(currentVideoQuality, equals(expectedVideoQualities[i]));
      }

      expect(defaultQualitySelector.fallbackStrategy!.quality,
          equals(VideoQuality.FHD));
      expect(defaultQualitySelector.fallbackStrategy!.fallbackRule,
          equals(VideoResolutionFallbackRule.higherQualityOrLowerThan));

      // Cleanup test Host APIs used only for this test.
      TestQualitySelectorHostApi.setup(null);
      TestFallbackStrategyHostApi.setup(null);
    });

    test('prepareRecording calls prepareRecording on Java side', () async {
      final MockTestRecorderHostApi mockApi = MockTestRecorderHostApi();
      TestRecorderHostApi.setup(mockApi);
      when(mockApi.prepareRecording(0, '/test/path')).thenAnswer((_) => 2);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      const String filePath = '/test/path';
      final Recorder recorder =
          Recorder.detached(instanceManager: instanceManager);
      const int recorderId = 0;
      const int mockPendingRecordingId = 2;

      instanceManager.addHostCreatedInstance(recorder, recorderId,
          onCopy: (_) => Recorder.detached(instanceManager: instanceManager));

      final MockPendingRecording mockPendingRecording = MockPendingRecording();
      instanceManager.addHostCreatedInstance(
          mockPendingRecording, mockPendingRecordingId,
          onCopy: (_) => MockPendingRecording());
      when(mockApi.prepareRecording(recorderId, filePath))
          .thenReturn(mockPendingRecordingId);
      final PendingRecording pendingRecording =
          await recorder.prepareRecording(filePath);
      expect(pendingRecording, mockPendingRecording);
    });

    test(
        'flutterApi create makes call to create Recorder instance with expected identifier',
        () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final RecorderFlutterApiImpl flutterApi = RecorderFlutterApiImpl(
        instanceManager: instanceManager,
      );
      const int recorderId = 0;
      const int aspectRatio = 1;
      const int bitrate = 2;

      flutterApi.create(recorderId, aspectRatio, bitrate);

      expect(instanceManager.getInstanceWithWeakReference(recorderId),
          isA<Recorder>());
      expect(
          (instanceManager.getInstanceWithWeakReference(recorderId)!
                  as Recorder)
              .aspectRatio,
          equals(aspectRatio));
      expect(
          (instanceManager.getInstanceWithWeakReference(0)! as Recorder)
              .bitRate,
          equals(bitrate));
    });
  });
}
