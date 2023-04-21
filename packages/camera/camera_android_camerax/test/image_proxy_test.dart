// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/image_proxy.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/plane_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'image_proxy_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[TestImageProxyHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

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
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (ImageProxy original) => ImageProxy.detached(
          instanceManager: instanceManager,
        ),
      );
      final PlaneProxy planeProxy =
          PlaneProxy.detached(instanceManager: instanceManager);
      const int planeProxyIdentifier = 48;
      instanceManager.addHostCreatedInstance(planeProxy, planeProxyIdentifier,
          onCopy: (PlaneProxy original) =>
              PlaneProxy.detached(instanceManager: instanceManager));

      final List<int> result = <int>[planeProxyIdentifier];
      when(mockApi.getPlanes(
        instanceIdentifier,
      )).thenAnswer((_) {
        return result;
      });

      final List<PlaneProxy> planes = await instance.getPlanes();
      expect(planes[0], equals(planeProxy));

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
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (ImageProxy original) => ImageProxy.detached(
          instanceManager: instanceManager,
        ),
      );

      const int result = 0;
      when(mockApi.getFormat(
        instanceIdentifier,
      )).thenAnswer((_) {
        return result;
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
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (ImageProxy original) => ImageProxy.detached(
          instanceManager: instanceManager,
        ),
      );

      const int result = 0;
      when(mockApi.getHeight(
        instanceIdentifier,
      )).thenAnswer((_) {
        return result;
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
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (ImageProxy original) => ImageProxy.detached(
          instanceManager: instanceManager,
        ),
      );

      const int result = 0;
      when(mockApi.getWidth(
        instanceIdentifier,
      )).thenAnswer((_) {
        return result;
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
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (ImageProxy original) => ImageProxy.detached(
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
