// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';

import 'capture_request_options_test.mocks.dart';
import 'test_camerax_library.g.dart';

// TODO(bparrishMines): Move desired test implementations to test file or
// remove .gen_api_impls from filename and follow todos below
// TODO(bparrishMines): Import generated pigeon files (the one in lib and test)
// TODO(bparrishMines): Run build runner

@GenerateMocks(
    <Type>[TestCaptureRequestOptionsHostApi, TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CaptureRequestOptions', () {
    tearDown(() {
      TestCaptureRequestOptionsHostApi.setup(null);
      TestInstanceManagerHostApi.setup(null);
    });

    test('HostApi create', () {
      final MockTestCaptureRequestOptionsHostApi mockApi =
          MockTestCaptureRequestOptionsHostApi();
      TestCaptureRequestOptionsHostApi.setup(mockApi);
      TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      const List options = <dynamic>[];

      final CaptureRequestOptions instance = CaptureRequestOptions(
        options: options,
        instanceManager: instanceManager,
      );

      verify(mockApi.create(
        instanceManager.getIdentifier(instance),
        options,
      ));
    });

    test('FlutterAPI create', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final CaptureRequestOptionsFlutterApiImpl api =
          CaptureRequestOptionsFlutterApiImpl(
        instanceManager: instanceManager,
      );

      const int instanceIdentifier = 0;

      api.create(
        instanceIdentifier,
        <dynamic>[],
      );

      expect(
        instanceManager.getInstanceWithWeakReference(instanceIdentifier),
        isA<CaptureRequestOptions>(),
      );
    });
  });
}
