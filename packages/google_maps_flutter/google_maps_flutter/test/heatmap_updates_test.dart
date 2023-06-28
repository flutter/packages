// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'fake_google_maps_flutter_platform.dart';

Widget _mapWithHeatmaps(Set<Heatmap> heatmaps) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      heatmaps: heatmaps,
    ),
  );
}

void main() {
  late FakeGoogleMapsFlutterPlatform platform;

  setUp(() {
    platform = FakeGoogleMapsFlutterPlatform();
    GoogleMapsFlutterPlatform.instance = platform;
  });

  testWidgets('Initializing a heatmap', (WidgetTester tester) async {
    const Heatmap c1 = Heatmap(heatmapId: HeatmapId('heatmap_1'));
    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{c1}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.heatmapUpdates.last.heatmapsToAdd.length, 1);

    final Heatmap initializedHeatmap =
        map.heatmapUpdates.last.heatmapsToAdd.first;
    expect(initializedHeatmap, equals(c1));
    expect(map.heatmapUpdates.last.heatmapIdsToRemove.isEmpty, true);
    expect(map.heatmapUpdates.last.heatmapsToChange.isEmpty, true);
  });

  testWidgets('Adding a heatmap', (WidgetTester tester) async {
    const Heatmap c1 = Heatmap(heatmapId: HeatmapId('heatmap_1'));
    const Heatmap c2 = Heatmap(heatmapId: HeatmapId('heatmap_2'));

    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{c1}));
    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{c1, c2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.heatmapUpdates.last.heatmapsToAdd.length, 1);

    final Heatmap addedHeatmap = map.heatmapUpdates.last.heatmapsToAdd.first;
    expect(addedHeatmap, equals(c2));

    expect(map.heatmapUpdates.last.heatmapIdsToRemove.isEmpty, true);

    expect(map.heatmapUpdates.last.heatmapsToChange.isEmpty, true);
  });

  testWidgets('Removing a heatmap', (WidgetTester tester) async {
    const Heatmap c1 = Heatmap(heatmapId: HeatmapId('heatmap_1'));

    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{c1}));
    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.heatmapUpdates.last.heatmapIdsToRemove.length, 1);
    expect(
        map.heatmapUpdates.last.heatmapIdsToRemove.first, equals(c1.heatmapId));

    expect(map.heatmapUpdates.last.heatmapsToChange.isEmpty, true);
    expect(map.heatmapUpdates.last.heatmapsToAdd.isEmpty, true);
  });

  testWidgets('Updating a heatmap', (WidgetTester tester) async {
    const Heatmap c1 = Heatmap(heatmapId: HeatmapId('heatmap_1'));
    const Heatmap c2 = Heatmap(heatmapId: HeatmapId('heatmap_1'), radius: 10);

    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{c1}));
    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{c2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.heatmapUpdates.last.heatmapsToChange.length, 1);
    expect(map.heatmapUpdates.last.heatmapsToChange.first, equals(c2));

    expect(map.heatmapUpdates.last.heatmapIdsToRemove.isEmpty, true);
    expect(map.heatmapUpdates.last.heatmapsToAdd.isEmpty, true);
  });

  testWidgets('Updating a heatmap', (WidgetTester tester) async {
    const Heatmap c1 = Heatmap(heatmapId: HeatmapId('heatmap_1'));
    const Heatmap c2 = Heatmap(heatmapId: HeatmapId('heatmap_1'), radius: 10);

    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{c1}));
    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{c2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.heatmapUpdates.last.heatmapsToChange.length, 1);

    final Heatmap update = map.heatmapUpdates.last.heatmapsToChange.first;
    expect(update, equals(c2));
    expect(update.radius, 10);
  });

  testWidgets('Multi Update', (WidgetTester tester) async {
    Heatmap c1 = const Heatmap(heatmapId: HeatmapId('heatmap_1'));
    Heatmap c2 = const Heatmap(heatmapId: HeatmapId('heatmap_2'));
    final Set<Heatmap> prev = <Heatmap>{c1, c2};
    c1 = const Heatmap(heatmapId: HeatmapId('heatmap_1'), dissipating: false);
    c2 = const Heatmap(heatmapId: HeatmapId('heatmap_2'), radius: 10);
    final Set<Heatmap> cur = <Heatmap>{c1, c2};

    await tester.pumpWidget(_mapWithHeatmaps(prev));
    await tester.pumpWidget(_mapWithHeatmaps(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.heatmapUpdates.last.heatmapsToChange, cur);
    expect(map.heatmapUpdates.last.heatmapIdsToRemove.isEmpty, true);
    expect(map.heatmapUpdates.last.heatmapsToAdd.isEmpty, true);
  });

  testWidgets('Multi Update', (WidgetTester tester) async {
    Heatmap c2 = const Heatmap(heatmapId: HeatmapId('heatmap_2'));
    const Heatmap c3 = Heatmap(heatmapId: HeatmapId('heatmap_3'));
    final Set<Heatmap> prev = <Heatmap>{c2, c3};

    // c1 is added, c2 is updated, c3 is removed.
    const Heatmap c1 = Heatmap(heatmapId: HeatmapId('heatmap_1'));
    c2 = const Heatmap(heatmapId: HeatmapId('heatmap_2'), radius: 10);
    final Set<Heatmap> cur = <Heatmap>{c1, c2};

    await tester.pumpWidget(_mapWithHeatmaps(prev));
    await tester.pumpWidget(_mapWithHeatmaps(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.heatmapUpdates.last.heatmapsToChange.length, 1);
    expect(map.heatmapUpdates.last.heatmapsToAdd.length, 1);
    expect(map.heatmapUpdates.last.heatmapIdsToRemove.length, 1);

    expect(map.heatmapUpdates.last.heatmapsToChange.first, equals(c2));
    expect(map.heatmapUpdates.last.heatmapsToAdd.first, equals(c1));
    expect(
        map.heatmapUpdates.last.heatmapIdsToRemove.first, equals(c3.heatmapId));
  });

  testWidgets('Partial Update', (WidgetTester tester) async {
    const Heatmap c1 = Heatmap(heatmapId: HeatmapId('heatmap_1'));
    const Heatmap c2 = Heatmap(heatmapId: HeatmapId('heatmap_2'));
    Heatmap c3 = const Heatmap(heatmapId: HeatmapId('heatmap_3'));
    final Set<Heatmap> prev = <Heatmap>{c1, c2, c3};
    c3 = const Heatmap(heatmapId: HeatmapId('heatmap_3'), radius: 10);
    final Set<Heatmap> cur = <Heatmap>{c1, c2, c3};

    await tester.pumpWidget(_mapWithHeatmaps(prev));
    await tester.pumpWidget(_mapWithHeatmaps(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.heatmapUpdates.last.heatmapsToChange, <Heatmap>{c3});
    expect(map.heatmapUpdates.last.heatmapIdsToRemove.isEmpty, true);
    expect(map.heatmapUpdates.last.heatmapsToAdd.isEmpty, true);
  });
}
