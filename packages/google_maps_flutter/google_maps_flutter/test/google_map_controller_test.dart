// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'fake_google_maps_flutter_platform.dart';

void main() {
  late FakeGoogleMapsFlutterPlatform platform;

  setUp(() {
    platform = FakeGoogleMapsFlutterPlatform();
    GoogleMapsFlutterPlatform.instance = platform;
  });

  testWidgets('onMapCreated is called with controller', (
    WidgetTester tester,
  ) async {
    GoogleMapController? controller;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(target: LatLng(0.0, 0.0)),
          onMapCreated: (GoogleMapController value) => controller = value,
        ),
      ),
    );

    expect(controller, isNotNull);
    await expectLater(controller?.getZoomLevel(), isNotNull);
  });

  testWidgets('controller throws when used after dispose', (
    WidgetTester tester,
  ) async {
    GoogleMapController? controller;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(target: LatLng(0.0, 0.0)),
          onMapCreated: (GoogleMapController value) => controller = value,
        ),
      ),
    );

    // Now dispose of the map...
    await tester.pumpWidget(Container());

    await expectLater(
      () => controller?.getZoomLevel(),
      throwsA(isA<StateError>()),
    );
  });
}
