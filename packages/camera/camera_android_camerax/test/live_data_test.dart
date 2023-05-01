// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camera_state.dart';
import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/live_data.dart';
import 'package:camera_android_camerax/src/observer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'live_data_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[TestLiveDataHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LiveData', () {
    tearDown(() {
      TestLiveDataHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test('observe makes call to add observer to LiveData instance', () async {
      final MockTestLiveDataHostApi mockApi = MockTestLiveDataHostApi();
      TestLiveDataHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final LiveData<dynamic> instance = LiveData<dynamic>.detached(
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (LiveData<dynamic> original) => LiveData<dynamic>.detached(
          instanceManager: instanceManager,
        ),
      );

      final Observer<dynamic> observer = Observer<dynamic>.detached(
        instanceManager: instanceManager,
        onChanged: (Object value) {},
      );
      const int observerIdentifier = 20;
      instanceManager.addHostCreatedInstance(
        observer,
        observerIdentifier,
        onCopy: (_) => Observer<dynamic>.detached(
          instanceManager: instanceManager,
          onChanged: (Object value) {},
        ),
      );

      await instance.observe(
        observer,
      );

      verify(mockApi.observe(
        instanceIdentifier,
        observerIdentifier,
      ));
    });

    test(
        'removeObservers makes call to remove observers from LiveData instance',
        () async {
      final MockTestLiveDataHostApi mockApi = MockTestLiveDataHostApi();
      TestLiveDataHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final LiveData<dynamic> instance = LiveData<dynamic>.detached(
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (LiveData<dynamic> original) => LiveData<dynamic>.detached(
          instanceManager: instanceManager,
        ),
      );

      await instance.removeObservers();

      verify(mockApi.removeObservers(
        instanceIdentifier,
      ));
    });

    test(
        'FlutterAPI create makes call to create LiveData<CameraState> instance with expected identifier',
        () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final LiveDataFlutterApiImpl api = LiveDataFlutterApiImpl(
        instanceManager: instanceManager,
      );

      const int instanceIdentifier = 0;

      api.create(
        instanceIdentifier,
        LiveDataSupportedTypeData(value: LiveDataSupportedType.cameraState),
      );

      expect(
        instanceManager.getInstanceWithWeakReference(instanceIdentifier),
        isA<LiveData<CameraState>>(),
      );
    });
  });
}
