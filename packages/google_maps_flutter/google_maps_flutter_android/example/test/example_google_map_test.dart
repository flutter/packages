// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_example/example_google_map.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'fake_google_maps_flutter_platform.dart';

Widget _mapWithObjects({
  Set<Circle> circles = const <Circle>{},
  Set<Marker> markers = const <Marker>{},
  Set<Polygon> polygons = const <Polygon>{},
  Set<Polyline> polylines = const <Polyline>{},
  Set<TileOverlay> tileOverlays = const <TileOverlay>{},
}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: ExampleGoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      circles: circles,
      markers: markers,
      polygons: polygons,
      polylines: polylines,
      tileOverlays: tileOverlays,
    ),
  );
}

void main() {
  late FakeGoogleMapsFlutterPlatform platform;

  setUp(() {
    platform = FakeGoogleMapsFlutterPlatform();
    GoogleMapsFlutterPlatform.instance = platform;
  });

  testWidgets('circle updates with delays', (WidgetTester tester) async {
    platform.simulatePlatformDelay = true;

    const Circle c1 = Circle(circleId: CircleId('circle_1'));
    const Circle c2 = Circle(circleId: CircleId('circle_2'));
    const Circle c3 = Circle(circleId: CircleId('circle_3'), radius: 1);
    const Circle c3updated = Circle(circleId: CircleId('circle_3'), radius: 10);

    // First remove one and add another, then update the new one.
    await tester.pumpWidget(_mapWithObjects(circles: <Circle>{c1, c2}));
    await tester.pumpWidget(_mapWithObjects(circles: <Circle>{c1, c3}));
    await tester.pumpWidget(_mapWithObjects(circles: <Circle>{c1, c3updated}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.circleUpdates.length, 3);

    expect(map.circleUpdates[0].circlesToChange.isEmpty, true);
    expect(map.circleUpdates[0].circlesToAdd, <Circle>{c1, c2});
    expect(map.circleUpdates[0].circleIdsToRemove.isEmpty, true);

    expect(map.circleUpdates[1].circlesToChange.isEmpty, true);
    expect(map.circleUpdates[1].circlesToAdd, <Circle>{c3});
    expect(map.circleUpdates[1].circleIdsToRemove, <CircleId>{c2.circleId});

    expect(map.circleUpdates[2].circlesToChange, <Circle>{c3updated});
    expect(map.circleUpdates[2].circlesToAdd.isEmpty, true);
    expect(map.circleUpdates[2].circleIdsToRemove.isEmpty, true);

    await tester.pumpAndSettle();
  });

  testWidgets('marker updates with delays', (WidgetTester tester) async {
    platform.simulatePlatformDelay = true;

    const Marker m1 = Marker(markerId: MarkerId('marker_1'));
    const Marker m2 = Marker(markerId: MarkerId('marker_2'));
    const Marker m3 = Marker(markerId: MarkerId('marker_3'));
    const Marker m3updated =
        Marker(markerId: MarkerId('marker_3'), draggable: true);

    // First remove one and add another, then update the new one.
    await tester.pumpWidget(_mapWithObjects(markers: <Marker>{m1, m2}));
    await tester.pumpWidget(_mapWithObjects(markers: <Marker>{m1, m3}));
    await tester.pumpWidget(_mapWithObjects(markers: <Marker>{m1, m3updated}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.markerUpdates.length, 3);

    expect(map.markerUpdates[0].markersToChange.isEmpty, true);
    expect(map.markerUpdates[0].markersToAdd, <Marker>{m1, m2});
    expect(map.markerUpdates[0].markerIdsToRemove.isEmpty, true);

    expect(map.markerUpdates[1].markersToChange.isEmpty, true);
    expect(map.markerUpdates[1].markersToAdd, <Marker>{m3});
    expect(map.markerUpdates[1].markerIdsToRemove, <MarkerId>{m2.markerId});

    expect(map.markerUpdates[2].markersToChange, <Marker>{m3updated});
    expect(map.markerUpdates[2].markersToAdd.isEmpty, true);
    expect(map.markerUpdates[2].markerIdsToRemove.isEmpty, true);

    await tester.pumpAndSettle();
  });

  testWidgets('polygon updates with delays', (WidgetTester tester) async {
    platform.simulatePlatformDelay = true;

    const Polygon p1 = Polygon(polygonId: PolygonId('polygon_1'));
    const Polygon p2 = Polygon(polygonId: PolygonId('polygon_2'));
    const Polygon p3 =
        Polygon(polygonId: PolygonId('polygon_3'), strokeWidth: 1);
    const Polygon p3updated =
        Polygon(polygonId: PolygonId('polygon_3'), strokeWidth: 2);

    // First remove one and add another, then update the new one.
    await tester.pumpWidget(_mapWithObjects(polygons: <Polygon>{p1, p2}));
    await tester.pumpWidget(_mapWithObjects(polygons: <Polygon>{p1, p3}));
    await tester
        .pumpWidget(_mapWithObjects(polygons: <Polygon>{p1, p3updated}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.polygonUpdates.length, 3);

    expect(map.polygonUpdates[0].polygonsToChange.isEmpty, true);
    expect(map.polygonUpdates[0].polygonsToAdd, <Polygon>{p1, p2});
    expect(map.polygonUpdates[0].polygonIdsToRemove.isEmpty, true);

    expect(map.polygonUpdates[1].polygonsToChange.isEmpty, true);
    expect(map.polygonUpdates[1].polygonsToAdd, <Polygon>{p3});
    expect(map.polygonUpdates[1].polygonIdsToRemove, <PolygonId>{p2.polygonId});

    expect(map.polygonUpdates[2].polygonsToChange, <Polygon>{p3updated});
    expect(map.polygonUpdates[2].polygonsToAdd.isEmpty, true);
    expect(map.polygonUpdates[2].polygonIdsToRemove.isEmpty, true);

    await tester.pumpAndSettle();
  });

  testWidgets('polyline updates with delays', (WidgetTester tester) async {
    platform.simulatePlatformDelay = true;

    const Polyline p1 = Polyline(polylineId: PolylineId('polyline_1'));
    const Polyline p2 = Polyline(polylineId: PolylineId('polyline_2'));
    const Polyline p3 =
        Polyline(polylineId: PolylineId('polyline_3'), width: 1);
    const Polyline p3updated =
        Polyline(polylineId: PolylineId('polyline_3'), width: 2);

    // First remove one and add another, then update the new one.
    await tester.pumpWidget(_mapWithObjects(polylines: <Polyline>{p1, p2}));
    await tester.pumpWidget(_mapWithObjects(polylines: <Polyline>{p1, p3}));
    await tester
        .pumpWidget(_mapWithObjects(polylines: <Polyline>{p1, p3updated}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.polylineUpdates.length, 3);

    expect(map.polylineUpdates[0].polylinesToChange.isEmpty, true);
    expect(map.polylineUpdates[0].polylinesToAdd, <Polyline>{p1, p2});
    expect(map.polylineUpdates[0].polylineIdsToRemove.isEmpty, true);

    expect(map.polylineUpdates[1].polylinesToChange.isEmpty, true);
    expect(map.polylineUpdates[1].polylinesToAdd, <Polyline>{p3});
    expect(map.polylineUpdates[1].polylineIdsToRemove,
        <PolylineId>{p2.polylineId});

    expect(map.polylineUpdates[2].polylinesToChange, <Polyline>{p3updated});
    expect(map.polylineUpdates[2].polylinesToAdd.isEmpty, true);
    expect(map.polylineUpdates[2].polylineIdsToRemove.isEmpty, true);

    await tester.pumpAndSettle();
  });
}
