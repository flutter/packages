// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/plane_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'plane_proxy_test.mocks.dart';
import 'test_camerax_library.g.dart';

@GenerateMocks(<Type>[TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('PlaneProxy', () {
    test('FlutterAPI create', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final PlaneProxyFlutterApiImpl api = PlaneProxyFlutterApiImpl(
        instanceManager: instanceManager,
      );

      const int instanceIdentifier = 0;
      final Uint8List buffer = Uint8List(1);
      const int pixelStride = 3;
      const int rowStride = 6;

      api.create(instanceIdentifier, buffer, pixelStride, rowStride);

      final PlaneProxy planeProxy =
          instanceManager.getInstanceWithWeakReference(instanceIdentifier)!;

      expect(planeProxy.buffer, equals(buffer));
      expect(planeProxy.pixelStride, equals(pixelStride));
      expect(planeProxy.rowStride, equals(rowStride));
    });
  });
}
