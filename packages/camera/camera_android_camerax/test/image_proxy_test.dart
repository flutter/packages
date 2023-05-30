// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

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
    tearDown(() {
      TestImageProxyHostApi.setup(null);
    });

    test('getPlanes', () async {
      final MockTestImageProxyHostApi mockApi = MockTestImageProxyHostApi();
      TestImageProxyHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ImageProxy instance = ImageProxy.detached(
          instanceManager: instanceManager, format: 2, height: 7, width: 10);
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(instance, instanceIdentifier,
          onCopy: (ImageProxy original) => ImageProxy.detached(
              instanceManager: instanceManager,
              format: original.format,
              height: original.height,
              width: original.width));
      final PlaneProxy planeProxy = PlaneProxy.detached(
          instanceManager: instanceManager,
          buffer: Uint8List(3),
          pixelStride: 3,
          rowStride: 20);
      const int planeProxyIdentifier = 48;
      instanceManager.addHostCreatedInstance(planeProxy, planeProxyIdentifier,
          onCopy: (PlaneProxy original) => PlaneProxy.detached(
              instanceManager: instanceManager,
              buffer: original.buffer,
              pixelStride: original.pixelStride,
              rowStride: original.rowStride));

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

    test('close', () async {
      final MockTestImageProxyHostApi mockApi = MockTestImageProxyHostApi();
      TestImageProxyHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ImageProxy instance = ImageProxy.detached(
          instanceManager: instanceManager, format: 2, height: 7, width: 10);
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(instance, instanceIdentifier,
          onCopy: (ImageProxy original) => ImageProxy.detached(
              instanceManager: instanceManager,
              format: original.format,
              height: original.height,
              width: original.width));

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
      const int format = 9;
      const int height = 55;
      const int width = 11;

      api.create(
        instanceIdentifier,
        format,
        height,
        width,
      );

      final ImageProxy imageProxy =
          instanceManager.getInstanceWithWeakReference(instanceIdentifier)!;

      expect(imageProxy.format, equals(format));
      expect(imageProxy.height, equals(height));
      expect(imageProxy.width, equals(width));
    });
  });
}
