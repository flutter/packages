// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:camera_android_camerax/src/camera_state.dart';
import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/observer.dart';

import 'observer_test.mocks.dart';
import 'test_camerax_library.g.dart';

// TODO(bparrishMines): Move desired test implementations to test file or
// remove .gen_api_impls from filename and follow todos below
// TODO(bparrishMines): Import generated pigeon files (the one in lib and test)
// TODO(bparrishMines): Run build runner

@GenerateMocks(<Type>[TestObserverHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Observer', () {
    tearDown(() {
      TestObserverHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test('HostApi create', () {
      final MockTestObserverHostApi mockApi = MockTestObserverHostApi();
      TestObserverHostApi.setup(mockApi);
      TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final Observer instance = Observer(
        instanceManager: instanceManager,
        onChanged: (Observer<dynamic> instance, value) {},
      );

      verify(mockApi.create(
        instanceManager.getIdentifier(instance),
      ));
    });

    test('onChanged', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      const int instanceIdentifier = 0;
      late final List<Object?> callbackParameters;
      final Observer<CameraState> instance = Observer<CameraState>.detached(
        onChanged: (
          Observer<CameraState> instance,
          CameraState value,
        ) {
          callbackParameters = <Object?>[
            instance,
            value,
          ];
        },
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (Observer<CameraState> original) =>
            Observer<CameraState>.detached(
          onChanged: original.onChanged,
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      final ObserverFlutterApiImpl flutterApi = ObserverFlutterApiImpl(
        instanceManager: instanceManager,
      );

      final CameraStateType cameraStateType = CameraStateType.closed;

      final CameraState value = CameraState.detached(
        // TODO(bparrishMines): This should include the missing params.
        binaryMessenger: null,
        instanceManager: instanceManager,
        type: cameraStateType,
      );
      const int valueIdentifier = 11;
      instanceManager.addHostCreatedInstance(
        value,
        valueIdentifier,
        onCopy: (_) => CameraState.detached(
          // TODO(bparrishMines): This should include the missing params.
          binaryMessenger: null,
          instanceManager: instanceManager,
          type: cameraStateType,
        ),
      );

      flutterApi.onChanged(
        instanceIdentifier,
        valueIdentifier,
      );

      expect(callbackParameters, <Object?>[
        instance,
        value,
      ]);
    });
  });
}
