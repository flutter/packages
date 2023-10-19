// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'fake_google_maps_flutter_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeGoogleMapsFlutterPlatform platform;

  setUp(() {
    // Use a mock platform so we never need to hit the MethodChannel code.
    platform = FakeGoogleMapsFlutterPlatform();
    GoogleMapsFlutterPlatform.instance = platform;
  });

  testWidgets('_webOnlyMapCreationId increments with each GoogleMap widget', (
    WidgetTester tester,
  ) async {
    // Inject two map widgets...
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(43.362, -5.849),
              ),
            ),
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(47.649, -122.350),
              ),
            ),
          ],
        ),
      ),
    );

    // Verify that each one was created with a different _webOnlyMapCreationId.
    expect(platform.createdIds.length, 2);
    expect(platform.createdIds[0], 0);
    expect(platform.createdIds[1], 1);
  });

  testWidgets('Calls platform.dispose when GoogleMap is disposed of', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(43.3608, -5.8702),
      ),
    ));

    // Now dispose of the map...
    await tester.pumpWidget(Container());

    expect(platform.disposed, true);
  });
}
