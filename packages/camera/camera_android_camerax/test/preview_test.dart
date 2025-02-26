// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/preview.dart';
import 'package:camera_android_camerax/src/resolution_selector.dart';
import 'package:camera_android_camerax/src/surface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'preview_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(
    <Type>[TestInstanceManagerHostApi, TestPreviewHostApi, ResolutionSelector])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('Preview', () {
    tearDown(() => TestPreviewHostApi.setup(null));

    test('detached create does not call create on the Java side', () async {
      final MockTestPreviewHostApi mockApi = MockTestPreviewHostApi();
      TestPreviewHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      Preview.detached(
        instanceManager: instanceManager,
        initialTargetRotation: Surface.rotation90,
        resolutionSelector: MockResolutionSelector(),
      );

      verifyNever(mockApi.create(argThat(isA<int>()), argThat(isA<int>()),
          argThat(isA<ResolutionSelector>())));
    }, skip: 'Flaky test: https://github.com/flutter/flutter/issues/164132');

    test('create calls create on the Java side', () async {
      final MockTestPreviewHostApi mockApi = MockTestPreviewHostApi();
      TestPreviewHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      const int targetRotation = Surface.rotation90;
      final MockResolutionSelector mockResolutionSelector =
          MockResolutionSelector();
      const int mockResolutionSelectorId = 24;

      instanceManager.addHostCreatedInstance(
          mockResolutionSelector, mockResolutionSelectorId,
          onCopy: (ResolutionSelector original) {
        return MockResolutionSelector();
      });

      Preview(
        instanceManager: instanceManager,
        initialTargetRotation: targetRotation,
        resolutionSelector: mockResolutionSelector,
      );

      verify(mockApi.create(
          argThat(isA<int>()),
          argThat(equals(targetRotation)),
          argThat(equals(mockResolutionSelectorId))));
    });

    test(
        'setTargetRotation makes call to set target rotation for Preview instance',
        () async {
      final MockTestPreviewHostApi mockApi = MockTestPreviewHostApi();
      TestPreviewHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      const int targetRotation = Surface.rotation180;
      final Preview preview = Preview.detached(
        instanceManager: instanceManager,
      );
      instanceManager.addHostCreatedInstance(
        preview,
        0,
        onCopy: (_) => Preview.detached(instanceManager: instanceManager),
      );

      await preview.setTargetRotation(targetRotation);

      verify(mockApi.setTargetRotation(
          instanceManager.getIdentifier(preview), targetRotation));
    });

    test(
        'setSurfaceProvider makes call to set surface provider for preview instance',
        () async {
      final MockTestPreviewHostApi mockApi = MockTestPreviewHostApi();
      TestPreviewHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      const int textureId = 8;
      final Preview preview = Preview.detached(
        instanceManager: instanceManager,
      );
      instanceManager.addHostCreatedInstance(
        preview,
        0,
        onCopy: (_) => Preview.detached(),
      );

      when(mockApi.setSurfaceProvider(instanceManager.getIdentifier(preview)))
          .thenReturn(textureId);
      expect(await preview.setSurfaceProvider(), equals(textureId));

      verify(
          mockApi.setSurfaceProvider(instanceManager.getIdentifier(preview)));
    });

    test(
        'releaseFlutterSurfaceTexture makes call to release flutter surface texture entry',
        () async {
      final MockTestPreviewHostApi mockApi = MockTestPreviewHostApi();
      TestPreviewHostApi.setup(mockApi);

      final Preview preview = Preview.detached();

      preview.releaseFlutterSurfaceTexture();

      verify(mockApi.releaseFlutterSurfaceTexture());
    });

    test(
        'getResolutionInfo makes call to get resolution information for preview instance',
        () async {
      final MockTestPreviewHostApi mockApi = MockTestPreviewHostApi();
      TestPreviewHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final Preview preview = Preview.detached(
        instanceManager: instanceManager,
      );
      const int resolutionWidth = 10;
      const int resolutionHeight = 60;
      final ResolutionInfo testResolutionInfo =
          ResolutionInfo(width: resolutionWidth, height: resolutionHeight);

      instanceManager.addHostCreatedInstance(
        preview,
        0,
        onCopy: (_) => Preview.detached(),
      );

      when(mockApi.getResolutionInfo(instanceManager.getIdentifier(preview)))
          .thenReturn(testResolutionInfo);

      final ResolutionInfo previewResolutionInfo =
          await preview.getResolutionInfo();
      expect(previewResolutionInfo.width, equals(resolutionWidth));
      expect(previewResolutionInfo.height, equals(resolutionHeight));

      verify(mockApi.getResolutionInfo(instanceManager.getIdentifier(preview)));
    });
  });
}
