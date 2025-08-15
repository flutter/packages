// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'fake_google_maps_flutter_platform.dart';

Widget _mapWithPolygons(Set<Polygon> polygons) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      polygons: polygons,
    ),
  );
}

List<LatLng> _rectPoints({
  required double size,
  LatLng center = const LatLng(0, 0),
}) {
  final double halfSize = size / 2;

  return <LatLng>[
    LatLng(center.latitude + halfSize, center.longitude + halfSize),
    LatLng(center.latitude - halfSize, center.longitude + halfSize),
    LatLng(center.latitude - halfSize, center.longitude - halfSize),
    LatLng(center.latitude + halfSize, center.longitude - halfSize),
  ];
}

Polygon _polygonWithPointsAndHole(PolygonId polygonId) {
  _rectPoints(size: 1);
  return Polygon(
    polygonId: polygonId,
    points: _rectPoints(size: 1),
    holes: <List<LatLng>>[_rectPoints(size: 0.5)],
  );
}

void main() {
  late FakeGoogleMapsFlutterPlatform platform;

  setUp(() {
    platform = FakeGoogleMapsFlutterPlatform();
    GoogleMapsFlutterPlatform.instance = platform;
  });

  testWidgets('Initializing a polygon', (WidgetTester tester) async {
    const Polygon p1 = Polygon(polygonId: PolygonId('polygon_1'));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.polygonUpdates.last.polygonsToAdd.length, 1);

    final Polygon initializedPolygon =
        map.polygonUpdates.last.polygonsToAdd.first;
    expect(initializedPolygon, equals(p1));
    expect(map.polygonUpdates.last.polygonIdsToRemove.isEmpty, true);
    expect(map.polygonUpdates.last.polygonsToChange.isEmpty, true);
  });

  testWidgets('Adding a polygon', (WidgetTester tester) async {
    const Polygon p1 = Polygon(polygonId: PolygonId('polygon_1'));
    const Polygon p2 = Polygon(polygonId: PolygonId('polygon_2'));

    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1, p2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.polygonUpdates.last.polygonsToAdd.length, 1);

    final Polygon addedPolygon = map.polygonUpdates.last.polygonsToAdd.first;
    expect(addedPolygon, equals(p2));

    expect(map.polygonUpdates.last.polygonIdsToRemove.isEmpty, true);

    expect(map.polygonUpdates.last.polygonsToChange.isEmpty, true);
  });

  testWidgets('Removing a polygon', (WidgetTester tester) async {
    const Polygon p1 = Polygon(polygonId: PolygonId('polygon_1'));

    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.polygonUpdates.last.polygonIdsToRemove.length, 1);
    expect(
        map.polygonUpdates.last.polygonIdsToRemove.first, equals(p1.polygonId));

    expect(map.polygonUpdates.last.polygonsToChange.isEmpty, true);
    expect(map.polygonUpdates.last.polygonsToAdd.isEmpty, true);
  });

  testWidgets('Updating a polygon', (WidgetTester tester) async {
    const Polygon p1 = Polygon(polygonId: PolygonId('polygon_1'));
    const Polygon p2 =
        Polygon(polygonId: PolygonId('polygon_1'), geodesic: true);

    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.polygonUpdates.last.polygonsToChange.length, 1);
    expect(map.polygonUpdates.last.polygonsToChange.first, equals(p2));

    expect(map.polygonUpdates.last.polygonIdsToRemove.isEmpty, true);
    expect(map.polygonUpdates.last.polygonsToAdd.isEmpty, true);
  });

  testWidgets('Mutate a polygon', (WidgetTester tester) async {
    final List<LatLng> points = <LatLng>[const LatLng(0.0, 0.0)];
    final Polygon p1 = Polygon(
      polygonId: const PolygonId('polygon_1'),
      points: points,
    );
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));

    p1.points.add(const LatLng(1.0, 1.0));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.polygonUpdates.last.polygonsToChange.length, 1);
    expect(map.polygonUpdates.last.polygonsToChange.first, equals(p1));

    expect(map.polygonUpdates.last.polygonIdsToRemove.isEmpty, true);
    expect(map.polygonUpdates.last.polygonsToAdd.isEmpty, true);
  });

  testWidgets('Multi Update', (WidgetTester tester) async {
    Polygon p1 = const Polygon(polygonId: PolygonId('polygon_1'));
    Polygon p2 = const Polygon(polygonId: PolygonId('polygon_2'));
    final Set<Polygon> prev = <Polygon>{p1, p2};
    p1 = const Polygon(polygonId: PolygonId('polygon_1'), visible: false);
    p2 = const Polygon(polygonId: PolygonId('polygon_2'), geodesic: true);
    final Set<Polygon> cur = <Polygon>{p1, p2};

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.polygonUpdates.last.polygonsToChange, cur);
    expect(map.polygonUpdates.last.polygonIdsToRemove.isEmpty, true);
    expect(map.polygonUpdates.last.polygonsToAdd.isEmpty, true);
  });

  testWidgets('Multi Update', (WidgetTester tester) async {
    Polygon p2 = const Polygon(polygonId: PolygonId('polygon_2'));
    const Polygon p3 = Polygon(polygonId: PolygonId('polygon_3'));
    final Set<Polygon> prev = <Polygon>{p2, p3};

    // p1 is added, p2 is updated, p3 is removed.
    const Polygon p1 = Polygon(polygonId: PolygonId('polygon_1'));
    p2 = const Polygon(polygonId: PolygonId('polygon_2'), geodesic: true);
    final Set<Polygon> cur = <Polygon>{p1, p2};

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.polygonUpdates.last.polygonsToChange.length, 1);
    expect(map.polygonUpdates.last.polygonsToAdd.length, 1);
    expect(map.polygonUpdates.last.polygonIdsToRemove.length, 1);

    expect(map.polygonUpdates.last.polygonsToChange.first, equals(p2));
    expect(map.polygonUpdates.last.polygonsToAdd.first, equals(p1));
    expect(
        map.polygonUpdates.last.polygonIdsToRemove.first, equals(p3.polygonId));
  });

  testWidgets('Partial Update', (WidgetTester tester) async {
    const Polygon p1 = Polygon(polygonId: PolygonId('polygon_1'));
    const Polygon p2 = Polygon(polygonId: PolygonId('polygon_2'));
    Polygon p3 = const Polygon(polygonId: PolygonId('polygon_3'));
    final Set<Polygon> prev = <Polygon>{p1, p2, p3};
    p3 = const Polygon(polygonId: PolygonId('polygon_3'), geodesic: true);
    final Set<Polygon> cur = <Polygon>{p1, p2, p3};

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.polygonUpdates.last.polygonsToChange, <Polygon>{p3});
    expect(map.polygonUpdates.last.polygonIdsToRemove.isEmpty, true);
    expect(map.polygonUpdates.last.polygonsToAdd.isEmpty, true);
  });

  testWidgets('Update non platform related attr', (WidgetTester tester) async {
    Polygon p1 = const Polygon(polygonId: PolygonId('polygon_1'));
    final Set<Polygon> prev = <Polygon>{p1};
    p1 = Polygon(polygonId: const PolygonId('polygon_1'), onTap: () {});
    final Set<Polygon> cur = <Polygon>{p1};

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.polygonUpdates.last.polygonsToChange.isEmpty, true);
    expect(map.polygonUpdates.last.polygonIdsToRemove.isEmpty, true);
    expect(map.polygonUpdates.last.polygonsToAdd.isEmpty, true);
  });

  testWidgets('Initializing a polygon with points and hole',
      (WidgetTester tester) async {
    final Polygon p1 = _polygonWithPointsAndHole(const PolygonId('polygon_1'));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.polygonUpdates.last.polygonsToAdd.length, 1);

    final Polygon initializedPolygon =
        map.polygonUpdates.last.polygonsToAdd.first;
    expect(initializedPolygon, equals(p1));
    expect(map.polygonUpdates.last.polygonIdsToRemove.isEmpty, true);
    expect(map.polygonUpdates.last.polygonsToChange.isEmpty, true);
  });

  testWidgets('Adding a polygon with points and hole',
      (WidgetTester tester) async {
    const Polygon p1 = Polygon(polygonId: PolygonId('polygon_1'));
    final Polygon p2 = _polygonWithPointsAndHole(const PolygonId('polygon_2'));

    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1, p2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.polygonUpdates.last.polygonsToAdd.length, 1);

    final Polygon addedPolygon = map.polygonUpdates.last.polygonsToAdd.first;
    expect(addedPolygon, equals(p2));

    expect(map.polygonUpdates.last.polygonIdsToRemove.isEmpty, true);

    expect(map.polygonUpdates.last.polygonsToChange.isEmpty, true);
  });

  testWidgets('Removing a polygon with points and hole',
      (WidgetTester tester) async {
    final Polygon p1 = _polygonWithPointsAndHole(const PolygonId('polygon_1'));

    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.polygonUpdates.last.polygonIdsToRemove.length, 1);
    expect(
        map.polygonUpdates.last.polygonIdsToRemove.first, equals(p1.polygonId));

    expect(map.polygonUpdates.last.polygonsToChange.isEmpty, true);
    expect(map.polygonUpdates.last.polygonsToAdd.isEmpty, true);
  });

  testWidgets('Updating a polygon by adding points and hole',
      (WidgetTester tester) async {
    const Polygon p1 = Polygon(polygonId: PolygonId('polygon_1'));
    final Polygon p2 = _polygonWithPointsAndHole(const PolygonId('polygon_1'));

    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.polygonUpdates.last.polygonsToChange.length, 1);
    expect(map.polygonUpdates.last.polygonsToChange.first, equals(p2));

    expect(map.polygonUpdates.last.polygonIdsToRemove.isEmpty, true);
    expect(map.polygonUpdates.last.polygonsToAdd.isEmpty, true);
  });

  testWidgets('Mutate a polygon with points and holes',
      (WidgetTester tester) async {
    final Polygon p1 = Polygon(
      polygonId: const PolygonId('polygon_1'),
      points: _rectPoints(size: 1),
      holes: <List<LatLng>>[_rectPoints(size: 0.5)],
    );
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));

    p1.points
      ..clear()
      ..addAll(_rectPoints(size: 2));
    p1.holes
      ..clear()
      ..addAll(<List<LatLng>>[_rectPoints(size: 1)]);
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.polygonUpdates.last.polygonsToChange.length, 1);
    expect(map.polygonUpdates.last.polygonsToChange.first, equals(p1));

    expect(map.polygonUpdates.last.polygonIdsToRemove.isEmpty, true);
    expect(map.polygonUpdates.last.polygonsToAdd.isEmpty, true);
  });

  testWidgets('Multi Update polygons with points and hole',
      (WidgetTester tester) async {
    Polygon p1 = const Polygon(polygonId: PolygonId('polygon_1'));
    Polygon p2 = Polygon(
      polygonId: const PolygonId('polygon_2'),
      points: _rectPoints(size: 2),
      holes: <List<LatLng>>[_rectPoints(size: 1)],
    );
    final Set<Polygon> prev = <Polygon>{p1, p2};
    p1 = const Polygon(polygonId: PolygonId('polygon_1'), visible: false);
    p2 = p2.copyWith(
      pointsParam: _rectPoints(size: 5),
      holesParam: <List<LatLng>>[_rectPoints(size: 2)],
    );
    final Set<Polygon> cur = <Polygon>{p1, p2};

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.polygonUpdates.last.polygonsToChange, cur);
    expect(map.polygonUpdates.last.polygonIdsToRemove.isEmpty, true);
    expect(map.polygonUpdates.last.polygonsToAdd.isEmpty, true);
  });

  testWidgets('Multi Update polygons with points and hole',
      (WidgetTester tester) async {
    Polygon p2 = Polygon(
      polygonId: const PolygonId('polygon_2'),
      points: _rectPoints(size: 2),
      holes: <List<LatLng>>[_rectPoints(size: 1)],
    );
    const Polygon p3 = Polygon(polygonId: PolygonId('polygon_3'));
    final Set<Polygon> prev = <Polygon>{p2, p3};

    // p1 is added, p2 is updated, p3 is removed.
    final Polygon p1 = _polygonWithPointsAndHole(const PolygonId('polygon_1'));
    p2 = p2.copyWith(
      pointsParam: _rectPoints(size: 5),
      holesParam: <List<LatLng>>[_rectPoints(size: 3)],
    );
    final Set<Polygon> cur = <Polygon>{p1, p2};

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.polygonUpdates.last.polygonsToChange.length, 1);
    expect(map.polygonUpdates.last.polygonsToAdd.length, 1);
    expect(map.polygonUpdates.last.polygonIdsToRemove.length, 1);

    expect(map.polygonUpdates.last.polygonsToChange.first, equals(p2));
    expect(map.polygonUpdates.last.polygonsToAdd.first, equals(p1));
    expect(
        map.polygonUpdates.last.polygonIdsToRemove.first, equals(p3.polygonId));
  });

  testWidgets('Partial Update polygons with points and hole',
      (WidgetTester tester) async {
    final Polygon p1 = _polygonWithPointsAndHole(const PolygonId('polygon_1'));
    const Polygon p2 = Polygon(polygonId: PolygonId('polygon_2'));
    Polygon p3 = Polygon(
      polygonId: const PolygonId('polygon_3'),
      points: _rectPoints(size: 2),
      holes: <List<LatLng>>[_rectPoints(size: 1)],
    );
    final Set<Polygon> prev = <Polygon>{p1, p2, p3};
    p3 = p3.copyWith(
      pointsParam: _rectPoints(size: 5),
      holesParam: <List<LatLng>>[_rectPoints(size: 3)],
    );
    final Set<Polygon> cur = <Polygon>{p1, p2, p3};

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.polygonUpdates.last.polygonsToChange, <Polygon>{p3});
    expect(map.polygonUpdates.last.polygonIdsToRemove.isEmpty, true);
    expect(map.polygonUpdates.last.polygonsToAdd.isEmpty, true);
  });

  testWidgets('multi-update with delays', (WidgetTester tester) async {
    platform.simulatePlatformDelay = true;

    const Polygon p1 = Polygon(polygonId: PolygonId('polygon_1'));
    const Polygon p2 = Polygon(polygonId: PolygonId('polygon_2'));
    const Polygon p3 =
        Polygon(polygonId: PolygonId('polygon_3'), strokeWidth: 1);
    const Polygon p3updated =
        Polygon(polygonId: PolygonId('polygon_3'), strokeWidth: 2);

    // First remove one and add another, then update the new one.
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1, p2}));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1, p3}));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1, p3updated}));

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
}
