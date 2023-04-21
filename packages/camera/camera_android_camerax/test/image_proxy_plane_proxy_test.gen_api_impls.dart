// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';

import 'image_proxy_plane_proxy_test.mocks.dart';

// TODO(bparrishMines): Move desired test implementations to test file or
// remove .gen_api_impls from filename and follow todos below
// TODO(bparrishMines): Import generated pigeon files (the one in lib and test)
// TODO(bparrishMines): Run build runner

// @GenerateMocks(
//     <Type>[TestImageProxyPlaneProxyHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImageProxyPlaneProxy', () {
    setUp(() {});

    tearDown(() {
      TestImageProxyPlaneProxyHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test('getRowStride', () async {
      final MockTestImageProxyPlaneProxyHostApi mockApi =
          MockTestImageProxyPlaneProxyHostApi();
      TestImageProxyPlaneProxyHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ImageProxyPlaneProxy instance = ImageProxyPlaneProxy.detached(
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (ImageProxyPlaneProxy original) =>
            ImageProxyPlaneProxy.detached(
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      final dynamic result = dynamic.detached(
        // TODO(bparrishMines): This should include the missing params.
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int resultIdentifier = 1;
      instanceManager.addHostCreatedInstance(
        result,
        resultIdentifier,
        onCopy: (dynamic original) {
          return dynamic.detached(
            // TODO(bparrishMines): This should include the missing params.
            binaryMessenger: null,
            instanceManager: instanceManager,
          );
        },
      );
      when(mockApi.getRowStride(
        instanceIdentifier,
      )).thenAnswer((_) {
        return Future<int>.value(resultIdentifier);
      });

      expect(await instance.getRowStride(), result);

      verify(mockApi.getRowStride(
        instanceIdentifier,
      ));
    });

    test('getPixelStride', () async {
      final MockTestImageProxyPlaneProxyHostApi mockApi =
          MockTestImageProxyPlaneProxyHostApi();
      TestImageProxyPlaneProxyHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ImageProxyPlaneProxy instance = ImageProxyPlaneProxy.detached(
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (ImageProxyPlaneProxy original) =>
            ImageProxyPlaneProxy.detached(
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      final int result = 0;
      when(mockApi.getPixelStride(
        instanceIdentifier,
      )).thenAnswer((_) {
        return Future<int>.value(result);
      });

      expect(await instance.getPixelStride(), result);

      verify(mockApi.getPixelStride(
        instanceIdentifier,
      ));
    });

    test('getRowStride', () async {
      final MockTestImageProxyPlaneProxyHostApi mockApi =
          MockTestImageProxyPlaneProxyHostApi();
      TestImageProxyPlaneProxyHostApi.setup(mockApi);

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final ImageProxyPlaneProxy instance = ImageProxyPlaneProxy.detached(
        binaryMessenger: null,
        instanceManager: instanceManager,
      );
      const int instanceIdentifier = 0;
      instanceManager.addHostCreatedInstance(
        instance,
        instanceIdentifier,
        onCopy: (ImageProxyPlaneProxy original) =>
            ImageProxyPlaneProxy.detached(
          binaryMessenger: null,
          instanceManager: instanceManager,
        ),
      );

      final int result = 0;
      when(mockApi.getRowStride(
        instanceIdentifier,
      )).thenAnswer((_) {
        return Future<int>.value(result);
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

      final ImageProxyPlaneProxyFlutterApiImpl api =
          ImageProxyPlaneProxyFlutterApiImpl(
        instanceManager: instanceManager,
      );

      const int instanceIdentifier = 0;

      api.create(
        instanceIdentifier,
      );

      expect(
        instanceManager.getInstanceWithWeakReference(instanceIdentifier),
        isA<ImageProxyPlaneProxy>(),
      );
    });
  });
}
