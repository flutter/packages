// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/instance_manager.dart';
import 'package:camera_android_camerax/src/zoom_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'test_camerax_library.g.dart';
import 'zoom_state_test.mocks.dart';

@GenerateMocks(<Type>[TestInstanceManagerHostApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks the call to clear the native InstanceManager.
  TestInstanceManagerHostApi.setup(MockTestInstanceManagerHostApi());

  group('ZoomState', () {
    test('flutterApi create makes call to create expected ZoomState', () {
      final InstanceManager instanceManager = InstanceManager(
        onWeakReferenceRemoved: (_) {},
      );
      final ZoomStateFlutterApiImpl flutterApi = ZoomStateFlutterApiImpl(
        instanceManager: instanceManager,
      );
      const int zoomStateIdentifier = 68;
      const double minZoomRatio = 0;
      const double maxZoomRatio = 1;

      flutterApi.create(zoomStateIdentifier, minZoomRatio, maxZoomRatio);

      final ZoomState instance = instanceManager
          .getInstanceWithWeakReference(zoomStateIdentifier)! as ZoomState;
      expect(instance.minZoomRatio, equals(minZoomRatio));
      expect(instance.maxZoomRatio, equals(maxZoomRatio));
    });
  });
}
