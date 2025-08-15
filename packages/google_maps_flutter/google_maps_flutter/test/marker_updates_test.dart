// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'fake_google_maps_flutter_platform.dart';

Widget _mapWithMarkers(Set<Marker> markers) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      markers: markers,
    ),
  );
}

void main() {
  late FakeGoogleMapsFlutterPlatform platform;

  setUp(() {
    platform = FakeGoogleMapsFlutterPlatform();
    GoogleMapsFlutterPlatform.instance = platform;
  });

  testWidgets('Initializing a marker', (WidgetTester tester) async {
    const Marker m1 = Marker(markerId: MarkerId('marker_1'));
    await tester.pumpWidget(_mapWithMarkers(<Marker>{m1}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.markerUpdates.last.markersToAdd.length, 1);

    final Marker initializedMarker = map.markerUpdates.last.markersToAdd.first;
    expect(initializedMarker, equals(m1));
    expect(map.markerUpdates.last.markerIdsToRemove.isEmpty, true);
    expect(map.markerUpdates.last.markersToChange.isEmpty, true);
  });

  testWidgets('Adding a marker', (WidgetTester tester) async {
    const Marker m1 = Marker(markerId: MarkerId('marker_1'));
    const Marker m2 = Marker(markerId: MarkerId('marker_2'));

    await tester.pumpWidget(_mapWithMarkers(<Marker>{m1}));
    await tester.pumpWidget(_mapWithMarkers(<Marker>{m1, m2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.markerUpdates.last.markersToAdd.length, 1);

    final Marker addedMarker = map.markerUpdates.last.markersToAdd.first;
    expect(addedMarker, equals(m2));

    expect(map.markerUpdates.last.markerIdsToRemove.isEmpty, true);

    expect(map.markerUpdates.last.markersToChange.isEmpty, true);
  });

  testWidgets('Removing a marker', (WidgetTester tester) async {
    const Marker m1 = Marker(markerId: MarkerId('marker_1'));

    await tester.pumpWidget(_mapWithMarkers(<Marker>{m1}));
    await tester.pumpWidget(_mapWithMarkers(<Marker>{}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.markerUpdates.last.markerIdsToRemove.length, 1);
    expect(map.markerUpdates.last.markerIdsToRemove.first, equals(m1.markerId));

    expect(map.markerUpdates.last.markersToChange.isEmpty, true);
    expect(map.markerUpdates.last.markersToAdd.isEmpty, true);
  });

  testWidgets('Updating a marker', (WidgetTester tester) async {
    const Marker m1 = Marker(markerId: MarkerId('marker_1'));
    const Marker m2 = Marker(markerId: MarkerId('marker_1'), alpha: 0.5);

    await tester.pumpWidget(_mapWithMarkers(<Marker>{m1}));
    await tester.pumpWidget(_mapWithMarkers(<Marker>{m2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.markerUpdates.last.markersToChange.length, 1);
    expect(map.markerUpdates.last.markersToChange.first, equals(m2));

    expect(map.markerUpdates.last.markerIdsToRemove.isEmpty, true);
    expect(map.markerUpdates.last.markersToAdd.isEmpty, true);
  });

  testWidgets('Updating a marker', (WidgetTester tester) async {
    const Marker m1 = Marker(markerId: MarkerId('marker_1'));
    const Marker m2 = Marker(
      markerId: MarkerId('marker_1'),
      infoWindow: InfoWindow(snippet: 'changed'),
    );

    await tester.pumpWidget(_mapWithMarkers(<Marker>{m1}));
    await tester.pumpWidget(_mapWithMarkers(<Marker>{m2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.markerUpdates.last.markersToChange.length, 1);

    final Marker update = map.markerUpdates.last.markersToChange.first;
    expect(update, equals(m2));
    expect(update.infoWindow.snippet, 'changed');
  });

  testWidgets('Multi Update', (WidgetTester tester) async {
    Marker m1 = const Marker(markerId: MarkerId('marker_1'));
    Marker m2 = const Marker(markerId: MarkerId('marker_2'));
    final Set<Marker> prev = <Marker>{m1, m2};
    m1 = const Marker(markerId: MarkerId('marker_1'), visible: false);
    m2 = const Marker(markerId: MarkerId('marker_2'), draggable: true);
    final Set<Marker> cur = <Marker>{m1, m2};

    await tester.pumpWidget(_mapWithMarkers(prev));
    await tester.pumpWidget(_mapWithMarkers(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.markerUpdates.last.markersToChange, cur);
    expect(map.markerUpdates.last.markerIdsToRemove.isEmpty, true);
    expect(map.markerUpdates.last.markersToAdd.isEmpty, true);
  });

  testWidgets('Multi Update', (WidgetTester tester) async {
    Marker m2 = const Marker(markerId: MarkerId('marker_2'));
    const Marker m3 = Marker(markerId: MarkerId('marker_3'));
    final Set<Marker> prev = <Marker>{m2, m3};

    // m1 is added, m2 is updated, m3 is removed.
    const Marker m1 = Marker(markerId: MarkerId('marker_1'));
    m2 = const Marker(markerId: MarkerId('marker_2'), draggable: true);
    final Set<Marker> cur = <Marker>{m1, m2};

    await tester.pumpWidget(_mapWithMarkers(prev));
    await tester.pumpWidget(_mapWithMarkers(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.markerUpdates.last.markersToChange.length, 1);
    expect(map.markerUpdates.last.markersToAdd.length, 1);
    expect(map.markerUpdates.last.markerIdsToRemove.length, 1);

    expect(map.markerUpdates.last.markersToChange.first, equals(m2));
    expect(map.markerUpdates.last.markersToAdd.first, equals(m1));
    expect(map.markerUpdates.last.markerIdsToRemove.first, equals(m3.markerId));
  });

  testWidgets('Partial Update', (WidgetTester tester) async {
    const Marker m1 = Marker(markerId: MarkerId('marker_1'));
    const Marker m2 = Marker(markerId: MarkerId('marker_2'));
    Marker m3 = const Marker(markerId: MarkerId('marker_3'));
    final Set<Marker> prev = <Marker>{m1, m2, m3};
    m3 = const Marker(markerId: MarkerId('marker_3'), draggable: true);
    final Set<Marker> cur = <Marker>{m1, m2, m3};

    await tester.pumpWidget(_mapWithMarkers(prev));
    await tester.pumpWidget(_mapWithMarkers(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.markerUpdates.last.markersToChange, <Marker>{m3});
    expect(map.markerUpdates.last.markerIdsToRemove.isEmpty, true);
    expect(map.markerUpdates.last.markersToAdd.isEmpty, true);
  });

  testWidgets('Update non platform related attr', (WidgetTester tester) async {
    Marker m1 = const Marker(markerId: MarkerId('marker_1'));
    final Set<Marker> prev = <Marker>{m1};
    m1 = Marker(
        markerId: const MarkerId('marker_1'),
        onTap: () {},
        onDragEnd: (LatLng latLng) {});
    final Set<Marker> cur = <Marker>{m1};

    await tester.pumpWidget(_mapWithMarkers(prev));
    await tester.pumpWidget(_mapWithMarkers(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.markerUpdates.last.markersToChange.isEmpty, true);
    expect(map.markerUpdates.last.markerIdsToRemove.isEmpty, true);
    expect(map.markerUpdates.last.markersToAdd.isEmpty, true);
  });

  testWidgets('multi-update with delays', (WidgetTester tester) async {
    platform.simulatePlatformDelay = true;

    const Marker m1 = Marker(markerId: MarkerId('marker_1'));
    const Marker m2 = Marker(markerId: MarkerId('marker_2'));
    const Marker m3 = Marker(markerId: MarkerId('marker_3'));
    const Marker m3updated =
        Marker(markerId: MarkerId('marker_3'), draggable: true);

    // First remove one and add another, then update the new one.
    await tester.pumpWidget(_mapWithMarkers(<Marker>{m1, m2}));
    await tester.pumpWidget(_mapWithMarkers(<Marker>{m1, m3}));
    await tester.pumpWidget(_mapWithMarkers(<Marker>{m1, m3updated}));

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
}
