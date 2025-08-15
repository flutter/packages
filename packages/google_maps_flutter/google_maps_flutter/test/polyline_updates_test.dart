// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'fake_google_maps_flutter_platform.dart';

Widget _mapWithPolylines(Set<Polyline> polylines) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      polylines: polylines,
    ),
  );
}

void main() {
  late FakeGoogleMapsFlutterPlatform platform;

  setUp(() {
    platform = FakeGoogleMapsFlutterPlatform();
    GoogleMapsFlutterPlatform.instance = platform;
  });

  testWidgets('Initializing a polyline', (WidgetTester tester) async {
    const Polyline p1 = Polyline(polylineId: PolylineId('polyline_1'));
    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p1}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.polylineUpdates.last.polylinesToAdd.length, 1);

    final Polyline initializedPolyline =
        map.polylineUpdates.last.polylinesToAdd.first;
    expect(initializedPolyline, equals(p1));
    expect(map.polylineUpdates.last.polylineIdsToRemove.isEmpty, true);
    expect(map.polylineUpdates.last.polylinesToChange.isEmpty, true);
  });

  testWidgets('Adding a polyline', (WidgetTester tester) async {
    const Polyline p1 = Polyline(polylineId: PolylineId('polyline_1'));
    const Polyline p2 = Polyline(polylineId: PolylineId('polyline_2'));

    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p1}));
    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p1, p2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.polylineUpdates.last.polylinesToAdd.length, 1);

    final Polyline addedPolyline =
        map.polylineUpdates.last.polylinesToAdd.first;
    expect(addedPolyline, equals(p2));

    expect(map.polylineUpdates.last.polylineIdsToRemove.isEmpty, true);

    expect(map.polylineUpdates.last.polylinesToChange.isEmpty, true);
  });

  testWidgets('Removing a polyline', (WidgetTester tester) async {
    const Polyline p1 = Polyline(polylineId: PolylineId('polyline_1'));

    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p1}));
    await tester.pumpWidget(_mapWithPolylines(<Polyline>{}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.polylineUpdates.last.polylineIdsToRemove.length, 1);
    expect(map.polylineUpdates.last.polylineIdsToRemove.first,
        equals(p1.polylineId));

    expect(map.polylineUpdates.last.polylinesToChange.isEmpty, true);
    expect(map.polylineUpdates.last.polylinesToAdd.isEmpty, true);
  });

  testWidgets('Updating a polyline', (WidgetTester tester) async {
    const Polyline p1 = Polyline(polylineId: PolylineId('polyline_1'));
    const Polyline p2 =
        Polyline(polylineId: PolylineId('polyline_1'), geodesic: true);

    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p1}));
    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.polylineUpdates.last.polylinesToChange.length, 1);
    expect(map.polylineUpdates.last.polylinesToChange.first, equals(p2));

    expect(map.polylineUpdates.last.polylineIdsToRemove.isEmpty, true);
    expect(map.polylineUpdates.last.polylinesToAdd.isEmpty, true);
  });

  testWidgets('Updating a polyline', (WidgetTester tester) async {
    const Polyline p1 = Polyline(polylineId: PolylineId('polyline_1'));
    const Polyline p2 =
        Polyline(polylineId: PolylineId('polyline_1'), geodesic: true);

    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p1}));
    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.polylineUpdates.last.polylinesToChange.length, 1);

    final Polyline update = map.polylineUpdates.last.polylinesToChange.first;
    expect(update, equals(p2));
    expect(update.geodesic, true);
  });

  testWidgets('Mutate a polyline', (WidgetTester tester) async {
    final List<LatLng> points = <LatLng>[const LatLng(0.0, 0.0)];
    final Polyline p1 = Polyline(
      polylineId: const PolylineId('polyline_1'),
      points: points,
    );
    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p1}));

    p1.points.add(const LatLng(1.0, 1.0));
    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p1}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.polylineUpdates.last.polylinesToChange.length, 1);
    expect(map.polylineUpdates.last.polylinesToChange.first, equals(p1));

    expect(map.polylineUpdates.last.polylineIdsToRemove.isEmpty, true);
    expect(map.polylineUpdates.last.polylinesToAdd.isEmpty, true);
  });

  testWidgets('Multi Update', (WidgetTester tester) async {
    Polyline p1 = const Polyline(polylineId: PolylineId('polyline_1'));
    Polyline p2 = const Polyline(polylineId: PolylineId('polyline_2'));
    final Set<Polyline> prev = <Polyline>{p1, p2};
    p1 = const Polyline(polylineId: PolylineId('polyline_1'), visible: false);
    p2 = const Polyline(polylineId: PolylineId('polyline_2'), geodesic: true);
    final Set<Polyline> cur = <Polyline>{p1, p2};

    await tester.pumpWidget(_mapWithPolylines(prev));
    await tester.pumpWidget(_mapWithPolylines(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.polylineUpdates.last.polylinesToChange, cur);
    expect(map.polylineUpdates.last.polylineIdsToRemove.isEmpty, true);
    expect(map.polylineUpdates.last.polylinesToAdd.isEmpty, true);
  });

  testWidgets('Multi Update', (WidgetTester tester) async {
    Polyline p2 = const Polyline(polylineId: PolylineId('polyline_2'));
    const Polyline p3 = Polyline(polylineId: PolylineId('polyline_3'));
    final Set<Polyline> prev = <Polyline>{p2, p3};

    // p1 is added, p2 is updated, p3 is removed.
    const Polyline p1 = Polyline(polylineId: PolylineId('polyline_1'));
    p2 = const Polyline(polylineId: PolylineId('polyline_2'), geodesic: true);
    final Set<Polyline> cur = <Polyline>{p1, p2};

    await tester.pumpWidget(_mapWithPolylines(prev));
    await tester.pumpWidget(_mapWithPolylines(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.polylineUpdates.last.polylinesToChange.length, 1);
    expect(map.polylineUpdates.last.polylinesToAdd.length, 1);
    expect(map.polylineUpdates.last.polylineIdsToRemove.length, 1);

    expect(map.polylineUpdates.last.polylinesToChange.first, equals(p2));
    expect(map.polylineUpdates.last.polylinesToAdd.first, equals(p1));
    expect(map.polylineUpdates.last.polylineIdsToRemove.first,
        equals(p3.polylineId));
  });

  testWidgets('Partial Update', (WidgetTester tester) async {
    const Polyline p1 = Polyline(polylineId: PolylineId('polyline_1'));
    const Polyline p2 = Polyline(polylineId: PolylineId('polyline_2'));
    Polyline p3 = const Polyline(polylineId: PolylineId('polyline_3'));
    final Set<Polyline> prev = <Polyline>{p1, p2, p3};
    p3 = const Polyline(polylineId: PolylineId('polyline_3'), geodesic: true);
    final Set<Polyline> cur = <Polyline>{p1, p2, p3};

    await tester.pumpWidget(_mapWithPolylines(prev));
    await tester.pumpWidget(_mapWithPolylines(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.polylineUpdates.last.polylinesToChange, <Polyline>{p3});
    expect(map.polylineUpdates.last.polylineIdsToRemove.isEmpty, true);
    expect(map.polylineUpdates.last.polylinesToAdd.isEmpty, true);
  });

  testWidgets('Update non platform related attr', (WidgetTester tester) async {
    Polyline p1 = const Polyline(polylineId: PolylineId('polyline_1'));
    final Set<Polyline> prev = <Polyline>{p1};
    p1 = Polyline(polylineId: const PolylineId('polyline_1'), onTap: () {});
    final Set<Polyline> cur = <Polyline>{p1};

    await tester.pumpWidget(_mapWithPolylines(prev));
    await tester.pumpWidget(_mapWithPolylines(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.polylineUpdates.last.polylinesToChange.isEmpty, true);
    expect(map.polylineUpdates.last.polylineIdsToRemove.isEmpty, true);
    expect(map.polylineUpdates.last.polylinesToAdd.isEmpty, true);
  });

  testWidgets('multi-update with delays', (WidgetTester tester) async {
    platform.simulatePlatformDelay = true;

    const Polyline p1 = Polyline(polylineId: PolylineId('polyline_1'));
    const Polyline p2 = Polyline(polylineId: PolylineId('polyline_2'));
    const Polyline p3 =
        Polyline(polylineId: PolylineId('polyline_3'), width: 1);
    const Polyline p3updated =
        Polyline(polylineId: PolylineId('polyline_3'), width: 2);

    // First remove one and add another, then update the new one.
    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p1, p2}));
    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p1, p3}));
    await tester.pumpWidget(_mapWithPolylines(<Polyline>{p1, p3updated}));

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
