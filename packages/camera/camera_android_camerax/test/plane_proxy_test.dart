// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/plane_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'plane_proxy_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[TestPlaneProxyHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('PlaneProxy', () {
    setUp(() {});

    tearDown(() {
      TestPlaneProxyHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test('getRowStride', () async {
      final MockTestPlaneProxyHostApi mockApi = MockTestPlaneProxyHostApi();
      TestPlaneProxyHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final PlaneProxy instance = PlaneProxy.detached(
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (PlaneProxy original) => PlaneProxy.detached(
          instanceManager: instanceManager,
        ),
      );

      final Uint8List result = Uint8List(0);
      when(mockApi.getBuffer(
        instanceIdentifier,
      )).thenAnswer((_) {
        return result;
      });

      expect(await instance.getBuffer(), result);

      verify(mockApi.getBuffer(
        instanceIdentifier,
      ));
    });

    test('getPixelStride', () async {
      final MockTestPlaneProxyHostApi mockApi = MockTestPlaneProxyHostApi();
      TestPlaneProxyHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final PlaneProxy instance = PlaneProxy.detached(
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (PlaneProxy original) => PlaneProxy.detached(
          instanceManager: instanceManager,
        ),
      );

      const int result = 39;
      when(mockApi.getPixelStride(
        instanceIdentifier,
      )).thenAnswer((_) {
        return result;
      });

      expect(await instance.getPixelStride(), result);

      verify(mockApi.getPixelStride(
        instanceIdentifier,
      ));
    });

    test('getRowStride', () async {
      final MockTestPlaneProxyHostApi mockApi = MockTestPlaneProxyHostApi();
      TestPlaneProxyHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final PlaneProxy instance = PlaneProxy.detached(
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (PlaneProxy original) => PlaneProxy.detached(
          instanceManager: instanceManager,
        ),
      );

      const int result = 0;
      when(mockApi.getRowStride(
        instanceIdentifier,
      )).thenAnswer((_) {
        return result;
      });

      expect(await instance.getRowStride(), result);

      verify(mockApi.getRowStride(
        instanceIdentifier,
      ));
    });

    test('FlutterAPI create', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final PlaneProxyFlutterApiImpl api = PlaneProxyFlutterApiImpl(
        instanceManager: instanceManager,
      );

      const int instanceIdentifier = 0;

      api.create(
        instanceIdentifier,
      );

      expect(
        instanceManager.getInstanceWithWeakReference(instanceIdentifier),
        isA<PlaneProxy>(),
      );
    });
  });
}
