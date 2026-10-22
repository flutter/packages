// Copyright 2013 The Flutter Authors
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
    platform = FakeGoogleMapsFlutterPlatform();
    GoogleMapsFlutterPlatform.instance = platform;
  });

  testWidgets('onPointOfInterestTap callback receives place ID from platform event', (
    WidgetTester tester,
  ) async {
    PointOfInterestId? tappedPointOfInterestId;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(target: LatLng(0.0, 0.0)),
          onPointOfInterestTap: (PointOfInterestId pointOfInterestId) {
            tappedPointOfInterestId = pointOfInterestId;
          },
        ),
      ),
    );

    await tester.pump();

    expect(platform.createdIds, isNotEmpty);
    final int mapId = platform.createdIds.first;

    platform.mapEventStreamController.add(
      PointOfInterestTapEvent(mapId, const PointOfInterestId('place-123')),
    );

    await tester.pump();

    expect(tappedPointOfInterestId, const PointOfInterestId('place-123'));
  });
}
