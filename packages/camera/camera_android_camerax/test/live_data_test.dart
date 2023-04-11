// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:camera_android_camerax/src/camerax_library.g.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/live_data.dart';
import 'package:camera_android_camerax/src/observer.dart';

import 'live_data_test.mocks.dart';
import 'test_camerax_library.g.dart';

// TODO(bparrishMines): Move desired test implementations to test file or
// remove .gen_api_impls from filename and follow todos below
// TODO(bparrishMines): Import generated pigeon files (the one in lib and test)
// TODO(bparrishMines): Run build runner

@GenerateMocks(<Type>[TestLiveDataHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LiveData', () {
    tearDown(() {
      TestLiveDataHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test('observe', () async {
      final MockTestLiveDataHostApi mockApi = MockTestLiveDataHostApi();
      TestLiveDataHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final LiveData instance = LiveData.detached(
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (LiveData original) => LiveData.detached(
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      final Observer observer = Observer.detached(
        // TODO(bparrishMines): This should include the missing params.
        binaryMessenger: null,
        instanceManager: instanceManager,
        onChanged: (Observer<dynamic> instance, value) {},
      );
      const int observerIdentifier = 20;
      instanceManager.addHostCreatedInstance(
        observer,
        observerIdentifier,
        onCopy: (_) => Observer.detached(
          // TODO(bparrishMines): This should include the missing params.
          binaryMessenger: null,
          instanceManager: instanceManager,
          onChanged: (Observer<dynamic> instance, value) {},
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

    test('removeObservers', () async {
      final MockTestLiveDataHostApi mockApi = MockTestLiveDataHostApi();
      TestLiveDataHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final LiveData instance = LiveData.detached(
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (LiveData original) => LiveData.detached(
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      await instance.removeObservers();

      verify(mockApi.removeObservers(
        instanceIdentifier,
      ));
    });

    test('FlutterAPI create', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final LiveDataFlutterApiImpl api = LiveDataFlutterApiImpl(
        instanceManager: instanceManager,
      );

      const int instanceIdentifier = 0;

      api.create(
        instanceIdentifier,
      );

      expect(
        instanceManager.getInstanceWithWeakReference(instanceIdentifier),
        isA<LiveData>(),
      );
    });
  });
}
