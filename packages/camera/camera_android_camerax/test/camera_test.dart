// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/camera.dart';
import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Camera', () {
    test('flutterApiCreateTest', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final CameraFlutterApiImpl flutterApi = CameraFlutterApiImpl(
        instanceManager: instanceManager,
      );

      // InstanceManagerHostApi.clear() is async. It is called unawaited deep inside of `flutterApi.create(0)`.
      // So `clear()` method body is queued and sometimes runs after test completion and fails.
      // This trick ensures for `InstanceManagerHostApi.clear()` completion.

      Future<Camera> createApi() async {
        flutterApi.create(0);
        return Future<Camera>.sync(
            () => instanceManager.getInstanceWithWeakReference(0)!);
      }

      expectLater(createApi(), completion(isA<Camera>()));
    });
  });
}
