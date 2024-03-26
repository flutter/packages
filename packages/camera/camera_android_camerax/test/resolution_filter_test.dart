// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/resolution_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'resolution_filter_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[
  TestResolutionFilterHostApi,
  TestInstanceManagerHostApi,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ResolutionFilter', () {
    tearDown(() {
      TestResolutionFilterHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test(
        'detached ResolutionFilter.onePreferredSize constructor does not make call to Host API createWithOnePreferredSize',
        () {
      final MockTestResolutionFilterHostApi mockApi =
          MockTestResolutionFilterHostApi();
      TestResolutionFilterHostApi.setup(mockApi);
      TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      const double preferredWidth = 270;
      const double preferredHeight = 720;
      const Size preferredResolution = Size(preferredWidth, preferredHeight);

      ResolutionFilter.onePreferredSizeDetached(
        preferredResolution: preferredResolution,
        instanceManager: instanceManager,
      );

      verifyNever(mockApi.createWithOnePreferredSize(
        argThat(isA<int>()),
        argThat(isA<ResolutionInfo>()
            .having(
                (ResolutionInfo size) => size.width, 'width', preferredWidth)
            .having((ResolutionInfo size) => size.height, 'height',
                preferredHeight)),
      ));
    });

    test('HostApi createWithOnePreferredSize creates expected ResolutionFilter',
        () {
      final MockTestResolutionFilterHostApi mockApi =
          MockTestResolutionFilterHostApi();
      TestResolutionFilterHostApi.setup(mockApi);
      TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      const double preferredWidth = 890;
      const double preferredHeight = 980;
      const Size preferredResolution = Size(preferredWidth, preferredHeight);

      final ResolutionFilter instance = ResolutionFilter.onePreferredSize(
        preferredResolution: preferredResolution,
        instanceManager: instanceManager,
      );
      verify(mockApi.createWithOnePreferredSize(
        instanceManager.getIdentifier(instance),
        argThat(isA<ResolutionInfo>()
            .having(
                (ResolutionInfo size) => size.width, 'width', preferredWidth)
            .having((ResolutionInfo size) => size.height, 'height',
                preferredHeight)),
      ));
    });
  });
}
