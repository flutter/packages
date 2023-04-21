// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';

import 'image_proxy_test.mocks.dart';

// TODO(bparrishMines): Move desired test implementations to test file or
// remove .gen_api_impls from filename and follow todos below
// TODO(bparrishMines): Import generated pigeon files (the one in lib and test)
// TODO(bparrishMines): Run build runner

// @GenerateMocks(<Type>[TestImageProxyHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImageProxy', () {
    setUp(() {});

    tearDown(() {
      TestImageProxyHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test('getPlanes', () async {
      final MockTestImageProxyHostApi mockApi = MockTestImageProxyHostApi();
      TestImageProxyHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ImageProxy instance = ImageProxy.detached(
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (ImageProxy original) => ImageProxy.detached(
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      final List result = <dynamic>[];
      when(mockApi.getPlanes(
        instanceIdentifier,
      )).thenAnswer((_) {
        return Future<List>.value(result);
      });

      expect(await instance.getPlanes(), result);

      verify(mockApi.getPlanes(
        instanceIdentifier,
      ));
    });

    test('getFormat', () async {
      final MockTestImageProxyHostApi mockApi = MockTestImageProxyHostApi();
      TestImageProxyHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ImageProxy instance = ImageProxy.detached(
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (ImageProxy original) => ImageProxy.detached(
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      final int result = 0;
      when(mockApi.getFormat(
        instanceIdentifier,
      )).thenAnswer((_) {
        return Future<int>.value(result);
      });

      expect(await instance.getFormat(), result);

      verify(mockApi.getFormat(
        instanceIdentifier,
      ));
    });

    test('getHeight', () async {
      final MockTestImageProxyHostApi mockApi = MockTestImageProxyHostApi();
      TestImageProxyHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ImageProxy instance = ImageProxy.detached(
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (ImageProxy original) => ImageProxy.detached(
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      final int result = 0;
      when(mockApi.getHeight(
        instanceIdentifier,
      )).thenAnswer((_) {
        return Future<int>.value(result);
      });

      expect(await instance.getHeight(), result);

      verify(mockApi.getHeight(
        instanceIdentifier,
      ));
    });

    test('getWidth', () async {
      final MockTestImageProxyHostApi mockApi = MockTestImageProxyHostApi();
      TestImageProxyHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ImageProxy instance = ImageProxy.detached(
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (ImageProxy original) => ImageProxy.detached(
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      final int result = 0;
      when(mockApi.getWidth(
        instanceIdentifier,
      )).thenAnswer((_) {
        return Future<int>.value(result);
      });

      expect(await instance.getWidth(), result);

      verify(mockApi.getWidth(
        instanceIdentifier,
      ));
    });

    test('close', () async {
      final MockTestImageProxyHostApi mockApi = MockTestImageProxyHostApi();
      TestImageProxyHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ImageProxy instance = ImageProxy.detached(
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (ImageProxy original) => ImageProxy.detached(
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      await instance.close();

      verify(mockApi.close(
        instanceIdentifier,
      ));
    });

    test('FlutterAPI create', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ImageProxyFlutterApiImpl api = ImageProxyFlutterApiImpl(
        instanceManager: instanceManager,
      );

      const int instanceIdentifier = 0;

      api.create(
        instanceIdentifier,
      );

      expect(
        instanceManager.getInstanceWithWeakReference(instanceIdentifier),
        isA<ImageProxy>(),
      );
    });
  });
}
