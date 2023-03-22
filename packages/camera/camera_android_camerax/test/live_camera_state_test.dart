// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/live_camera_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'live_camera_state_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[TestLiveCameraStateHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LiveCameraState', () {
    tearDown(() => TestLiveCameraStateHostApi.setup(null));

    test('addObserver makes call to add camera state observer', () async {
      final MockTestLiveCameraStateHostApi mockApi =
          MockTestLiveCameraStateHostApi();
      TestLiveCameraStateHostApi.setup(mockApi);
      const int liveCameraStateId = 28;
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final LiveCameraState liveCameraState = LiveCameraState.detached(
        instanceManager: instanceManager,
      );

      instanceManager.addHostCreatedInstance(
        liveCameraState,
        liveCameraStateId,
        onCopy: (_) => LiveCameraState.detached(),
      );

      liveCameraState.addObserver();

      verify(mockApi.addObserver(liveCameraStateId));
    });

    test('removeObservers makes call to remove camera state observers',
        () async {
      final MockTestLiveCameraStateHostApi mockApi =
          MockTestLiveCameraStateHostApi();
      TestLiveCameraStateHostApi.setup(mockApi);
      const int liveCameraStateId = 33;
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final LiveCameraState liveCameraState = LiveCameraState.detached(
        instanceManager: instanceManager,
      );

      instanceManager.addHostCreatedInstance(
        liveCameraState,
        liveCameraStateId,
        onCopy: (_) => LiveCameraState.detached(),
      );

      liveCameraState.removeObservers();

      verify(mockApi.removeObservers(liveCameraStateId));
    });

    test('flutter api create adds LiveCameraState instance to instance manager',
        () async {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final LiveCameraStateFlutterApi flutterApi =
          LiveCameraStateFlutterApiImpl(
        instanceManager: instanceManager,
      );
      const int liveCameraStateId = 90;

      flutterApi.create(liveCameraStateId);

      expect(instanceManager.getInstanceWithWeakReference(liveCameraStateId),
          isA<LiveCameraState>());
    });

    test(
        'flutter api onCameraClosing adds event to expected stream when called',
        () async {
      LiveCameraState.cameraClosingStreamController.stream.listen((bool event) {
        expect(event, isTrue);
      });

      LiveCameraStateFlutterApiImpl().onCameraClosing();
    });
  });
}
