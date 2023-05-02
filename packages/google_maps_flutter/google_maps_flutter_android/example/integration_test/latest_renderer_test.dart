// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:integration_test/integration_test.dart';

import 'google_maps_tests.dart' show googleMapsTests;

void main() {
  late AndroidMapRenderer initializedRenderer;
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final GoogleMapsFlutterAndroid instance =
        GoogleMapsFlutterPlatform.instance as GoogleMapsFlutterAndroid;
    initializedRenderer =
        await instance.initializeWithRenderer(AndroidMapRenderer.latest);
  });

  testWidgets('initialized with latest renderer', (WidgetTester _) async {
    // There is no guarantee that the server will return the latest renderer
    // even when requested, so there's no way to deterministically test that.
    // Instead, just test that the request succeeded and returned a valid
    // value.
    expect(
        initializedRenderer == AndroidMapRenderer.latest ||
            initializedRenderer == AndroidMapRenderer.legacy,
        true);
  });

  testWidgets('throws PlatformException on multiple renderer initializations',
      (WidgetTester _) async {
    final GoogleMapsFlutterAndroid instance =
        GoogleMapsFlutterPlatform.instance as GoogleMapsFlutterAndroid;
    expect(
        () async => instance.initializeWithRenderer(AndroidMapRenderer.latest),
        throwsA(isA<PlatformException>().having((PlatformException e) => e.code,
            'code', 'Renderer already initialized')));
  });

  // Run tests.
  googleMapsTests();
}
