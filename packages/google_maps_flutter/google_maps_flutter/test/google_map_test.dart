// Copyright 2013 The Flutter Authors. All rights reserved.
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

  testWidgets('Initial camera position', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.widgetConfiguration.initialCameraPosition,
        const CameraPosition(target: LatLng(10.0, 15.0)));
  });

  testWidgets('Initial camera position change is a no-op',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 16.0)),
        ),
      ),
    );

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.widgetConfiguration.initialCameraPosition,
        const CameraPosition(target: LatLng(10.0, 15.0)));
  });

  testWidgets('Can update compassEnabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          compassEnabled: false,
        ),
      ),
    );

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.mapConfiguration.compassEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    expect(map.mapConfiguration.compassEnabled, true);
  });

  testWidgets('Can update mapToolbarEnabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          mapToolbarEnabled: false,
        ),
      ),
    );

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.mapConfiguration.mapToolbarEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    expect(map.mapConfiguration.mapToolbarEnabled, true);
  });

  testWidgets('Can update cameraTargetBounds', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition:
              const CameraPosition(target: LatLng(10.0, 15.0)),
          cameraTargetBounds: CameraTargetBounds(
            LatLngBounds(
              southwest: const LatLng(10.0, 20.0),
              northeast: const LatLng(30.0, 40.0),
            ),
          ),
        ),
      ),
    );

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(
        map.mapConfiguration.cameraTargetBounds,
        CameraTargetBounds(
          LatLngBounds(
            southwest: const LatLng(10.0, 20.0),
            northeast: const LatLng(30.0, 40.0),
          ),
        ));

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition:
              const CameraPosition(target: LatLng(10.0, 15.0)),
          cameraTargetBounds: CameraTargetBounds(
            LatLngBounds(
              southwest: const LatLng(16.0, 20.0),
              northeast: const LatLng(30.0, 40.0),
            ),
          ),
        ),
      ),
    );

    expect(
        map.mapConfiguration.cameraTargetBounds,
        CameraTargetBounds(
          LatLngBounds(
            southwest: const LatLng(16.0, 20.0),
            northeast: const LatLng(30.0, 40.0),
          ),
        ));
  });

  testWidgets('Can update mapType', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          mapType: MapType.hybrid,
        ),
      ),
    );

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.mapConfiguration.mapType, MapType.hybrid);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          mapType: MapType.satellite,
        ),
      ),
    );

    expect(map.mapConfiguration.mapType, MapType.satellite);
  });

  testWidgets('Can update minMaxZoom', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          minMaxZoomPreference: MinMaxZoomPreference(1.0, 3.0),
        ),
      ),
    );

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.mapConfiguration.minMaxZoomPreference,
        const MinMaxZoomPreference(1.0, 3.0));

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    expect(map.mapConfiguration.minMaxZoomPreference,
        MinMaxZoomPreference.unbounded);
  });

  testWidgets('Can update rotateGesturesEnabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          rotateGesturesEnabled: false,
        ),
      ),
    );

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.mapConfiguration.rotateGesturesEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    expect(map.mapConfiguration.rotateGesturesEnabled, true);
  });

  testWidgets('Can update scrollGesturesEnabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          scrollGesturesEnabled: false,
        ),
      ),
    );

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.mapConfiguration.scrollGesturesEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    expect(map.mapConfiguration.scrollGesturesEnabled, true);
  });

  testWidgets('Can update tiltGesturesEnabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          tiltGesturesEnabled: false,
        ),
      ),
    );

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.mapConfiguration.tiltGesturesEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    expect(map.mapConfiguration.tiltGesturesEnabled, true);
  });

  testWidgets('Can update trackCameraPosition', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.mapConfiguration.trackCameraPosition, false);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition:
              const CameraPosition(target: LatLng(10.0, 15.0)),
          onCameraMove: (CameraPosition position) {},
        ),
      ),
    );

    expect(map.mapConfiguration.trackCameraPosition, true);
  });

  testWidgets('Can update zoomGesturesEnabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          zoomGesturesEnabled: false,
        ),
      ),
    );

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.mapConfiguration.zoomGesturesEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    expect(map.mapConfiguration.zoomGesturesEnabled, true);
  });

  testWidgets('Can update zoomControlsEnabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          zoomControlsEnabled: false,
        ),
      ),
    );

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.mapConfiguration.zoomControlsEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    expect(map.mapConfiguration.zoomControlsEnabled, true);
  });

  testWidgets('Can update myLocationEnabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.mapConfiguration.myLocationEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          myLocationEnabled: true,
        ),
      ),
    );

    expect(map.mapConfiguration.myLocationEnabled, true);
  });

  testWidgets('Can update myLocationButtonEnabled',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.mapConfiguration.myLocationButtonEnabled, true);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          myLocationButtonEnabled: false,
        ),
      ),
    );

    expect(map.mapConfiguration.myLocationButtonEnabled, false);
  });

  testWidgets('Is default padding 0', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.mapConfiguration.padding, EdgeInsets.zero);
  });

  testWidgets('Can update padding', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.mapConfiguration.padding, EdgeInsets.zero);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          padding: EdgeInsets.fromLTRB(10, 20, 30, 40),
        ),
      ),
    );

    expect(map.mapConfiguration.padding,
        const EdgeInsets.fromLTRB(10, 20, 30, 40));

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          padding: EdgeInsets.fromLTRB(50, 60, 70, 80),
        ),
      ),
    );

    expect(map.mapConfiguration.padding,
        const EdgeInsets.fromLTRB(50, 60, 70, 80));
  });

  testWidgets('Can update traffic', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.mapConfiguration.trafficEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          trafficEnabled: true,
        ),
      ),
    );

    expect(map.mapConfiguration.trafficEnabled, true);
  });

  testWidgets('Can update buildings', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
          buildingsEnabled: false,
        ),
      ),
    );

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.mapConfiguration.buildingsEnabled, false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(10.0, 15.0)),
        ),
      ),
    );

    expect(map.mapConfiguration.buildingsEnabled, true);
  });
}
