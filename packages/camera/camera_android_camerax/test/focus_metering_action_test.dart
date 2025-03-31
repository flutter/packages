// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/focus_metering_action.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/metering_point.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'focus_metering_action_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[
  MeteringPoint,
  TestFocusMeteringActionHostApi,
  TestInstanceManagerHostApi
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('FocusMeteringAction', () {
    tearDown(() => TestCameraHostApi.setup(null));

    test('detached create does not call create on the Java side', () {
      final MockTestFocusMeteringActionHostApi mockApi =
          MockTestFocusMeteringActionHostApi();
      TestFocusMeteringActionHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      FocusMeteringAction.detached(
        meteringPointInfos: <(MeteringPoint, int?)>[
          (MockMeteringPoint(), FocusMeteringAction.flagAwb)
        ],
        instanceManager: instanceManager,
      );

      verifyNever(mockApi.create(argThat(isA<int>()), argThat(isA<List<int>>()),
          argThat(isA<bool?>())));
    }, skip: 'Flaky test: https://github.com/flutter/flutter/issues/164132');

    test('create calls create on the Java side', () {
      final MockTestFocusMeteringActionHostApi mockApi =
          MockTestFocusMeteringActionHostApi();
      TestFocusMeteringActionHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final MeteringPoint mockMeteringPoint1 = MockMeteringPoint();
      const int mockMeteringPoint1Mode = FocusMeteringAction.flagAe;
      const int mockMeteringPoint1Id = 7;
      final MeteringPoint mockMeteringPoint2 = MockMeteringPoint();
      const int mockMeteringPoint2Mode = FocusMeteringAction.flagAwb;
      const int mockMeteringPoint2Id = 17;
      final List<(MeteringPoint meteringPoint, int? meteringMode)>
          meteringPointInfos =
          <(MeteringPoint meteringPoint, int? meteringMode)>[
        (mockMeteringPoint1, mockMeteringPoint1Mode),
        (mockMeteringPoint2, mockMeteringPoint2Mode)
      ];
      const bool disableAutoCancel = true;

      instanceManager
          .addHostCreatedInstance(mockMeteringPoint1, mockMeteringPoint1Id,
              onCopy: (MeteringPoint original) {
        return MockMeteringPoint();
      });
      instanceManager
          .addHostCreatedInstance(mockMeteringPoint2, mockMeteringPoint2Id,
              onCopy: (MeteringPoint original) {
        return MockMeteringPoint();
      });

      final FocusMeteringAction instance = FocusMeteringAction(
        meteringPointInfos: meteringPointInfos,
        disableAutoCancel: disableAutoCancel,
        instanceManager: instanceManager,
      );

      final VerificationResult verificationResult = verify(mockApi.create(
          argThat(equals(instanceManager.getIdentifier(instance))),
          captureAny,
          argThat(equals(disableAutoCancel))));
      final List<MeteringPointInfo?> captureMeteringPointInfos =
          verificationResult.captured.single as List<MeteringPointInfo?>;
      expect(captureMeteringPointInfos.length, equals(2));
      expect(captureMeteringPointInfos[0]!.meteringPointId,
          equals(mockMeteringPoint1Id));
      expect(
          captureMeteringPointInfos[0]!.meteringMode, mockMeteringPoint1Mode);
      expect(captureMeteringPointInfos[1]!.meteringPointId,
          equals(mockMeteringPoint2Id));
      expect(
          captureMeteringPointInfos[1]!.meteringMode, mockMeteringPoint2Mode);
    });
  });
}
