// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camera_state.dart';
import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/observer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'observer_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[TestObserverHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('Observer', () {
    tearDown(() {
      TestObserverHostApi.setup(null);
    });

    test('HostApi create makes call to create Observer instance', () {
      final MockTestObserverHostApi mockApi = MockTestObserverHostApi();
      TestObserverHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final Observer<dynamic> instance = Observer<dynamic>(
        instanceManager: instanceManager,
        onChanged: (Object value) {},
      );

      verify(mockApi.create(
        instanceManager.getIdentifier(instance),
      ));
    });

    test(
        'HostAPI create makes Observer instance that throws assertion error if onChanged receives unexpected parameter type',
        () {
      final MockTestObserverHostApi mockApi = MockTestObserverHostApi();
      TestObserverHostApi.setup(mockApi);

      final Observer<String> cameraStateObserver =
          Observer<String>.detached(onChanged: (Object value) {});

      expect(
          () => cameraStateObserver.onChanged(
              CameraState.detached(type: CameraStateType.pendingOpen)),
          throwsAssertionError);
    });

    test(
        'FlutterAPI onChanged makes call with expected parameter to Observer instance onChanged callback',
        () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      const int instanceIdentifier = 0;
      late final Object? callbackParameter;
      final Observer<CameraState> instance = Observer<CameraState>.detached(
        onChanged: (Object value) {
          callbackParameter = value;
        },
        instanceManager: instanceManager,
      );
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (Observer<CameraState> original) =>
            Observer<CameraState>.detached(
          onChanged: original.onChanged,
          instanceManager: instanceManager,
        ),
      );

      final ObserverFlutterApiImpl flutterApi = ObserverFlutterApiImpl(
        instanceManager: instanceManager,
      );

      const CameraStateType cameraStateType = CameraStateType.closed;

      final CameraState value = CameraState.detached(
        instanceManager: instanceManager,
        type: cameraStateType,
      );
      const int valueIdentifier = 11;
      instanceManager.addHostCreatedInstance(
        value,
        valueIdentifier,
        onCopy: (_) => CameraState.detached(
          instanceManager: instanceManager,
          type: cameraStateType,
        ),
      );

      flutterApi.onChanged(
        instanceIdentifier,
        valueIdentifier,
      );

      expect(callbackParameter, value);
    });
  });
}
