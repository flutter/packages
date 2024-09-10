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

const List<WeightedLatLng> _heatmapPoints = <WeightedLatLng>[
  WeightedLatLng(LatLng(37.782, -122.447)),
  WeightedLatLng(LatLng(37.782, -122.445)),
  WeightedLatLng(LatLng(37.782, -122.443)),
  WeightedLatLng(LatLng(37.782, -122.441)),
  WeightedLatLng(LatLng(37.782, -122.439)),
  WeightedLatLng(LatLng(37.782, -122.437)),
  WeightedLatLng(LatLng(37.782, -122.435)),
  WeightedLatLng(LatLng(37.785, -122.447)),
  WeightedLatLng(LatLng(37.785, -122.445)),
  WeightedLatLng(LatLng(37.785, -122.443)),
  WeightedLatLng(LatLng(37.785, -122.441)),
  WeightedLatLng(LatLng(37.785, -122.439)),
  WeightedLatLng(LatLng(37.785, -122.437)),
  WeightedLatLng(LatLng(37.785, -122.435))
];

void main() {
  late FakeGoogleMapsFlutterPlatform platform;

  setUp(() {
    platform = FakeGoogleMapsFlutterPlatform();
    GoogleMapsFlutterPlatform.instance = platform;
  });

  testWidgets('Initializing a heatmap', (WidgetTester tester) async {
    const Heatmap h1 = Heatmap(
      heatmapId: HeatmapId('heatmap_1'),
      data: _heatmapPoints,
      radius: HeatmapRadius.fromPixels(20),
    );
    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{h1}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.heatmapUpdates.last.heatmapsToAdd.length, 1);

    final Heatmap initializedHeatmap =
        map.heatmapUpdates.last.heatmapsToAdd.first;
    expect(initializedHeatmap, equals(h1));
    expect(map.heatmapUpdates.last.heatmapIdsToRemove.isEmpty, true);
    expect(map.heatmapUpdates.last.heatmapsToChange.isEmpty, true);
  });

  testWidgets('Adding a heatmap', (WidgetTester tester) async {
    const Heatmap h1 = Heatmap(
      heatmapId: HeatmapId('heatmap_1'),
      data: _heatmapPoints,
      radius: HeatmapRadius.fromPixels(20),
    );
    const Heatmap h2 = Heatmap(
      heatmapId: HeatmapId('heatmap_2'),
      data: _heatmapPoints,
      radius: HeatmapRadius.fromPixels(20),
    );

    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{h1}));
    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{h1, h2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.heatmapUpdates.last.heatmapsToAdd.length, 1);

    final Heatmap addedHeatmap = map.heatmapUpdates.last.heatmapsToAdd.first;
    expect(addedHeatmap, equals(h2));

    expect(map.heatmapUpdates.last.heatmapIdsToRemove.isEmpty, true);

    expect(map.heatmapUpdates.last.heatmapsToChange.isEmpty, true);
  });

  testWidgets('Removing a heatmap', (WidgetTester tester) async {
    const Heatmap h1 = Heatmap(
      heatmapId: HeatmapId('heatmap_1'),
      data: _heatmapPoints,
      radius: HeatmapRadius.fromPixels(20),
    );

    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{h1}));
    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.heatmapUpdates.last.heatmapIdsToRemove.length, 1);
    expect(
        map.heatmapUpdates.last.heatmapIdsToRemove.first, equals(h1.heatmapId));

    expect(map.heatmapUpdates.last.heatmapsToChange.isEmpty, true);
    expect(map.heatmapUpdates.last.heatmapsToAdd.isEmpty, true);
  });

  testWidgets('Updating a heatmap', (WidgetTester tester) async {
    const Heatmap h1 = Heatmap(
      heatmapId: HeatmapId('heatmap_1'),
      data: _heatmapPoints,
      radius: HeatmapRadius.fromPixels(20),
    );
    const Heatmap h2 = Heatmap(
      heatmapId: HeatmapId('heatmap_1'),
      data: _heatmapPoints,
      radius: HeatmapRadius.fromPixels(10),
    );

    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{h1}));
    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{h2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.heatmapUpdates.last.heatmapsToChange.length, 1);
    expect(map.heatmapUpdates.last.heatmapsToChange.first, equals(h2));

    expect(map.heatmapUpdates.last.heatmapIdsToRemove.isEmpty, true);
    expect(map.heatmapUpdates.last.heatmapsToAdd.isEmpty, true);
  });

  testWidgets('Updating a heatmap', (WidgetTester tester) async {
    const Heatmap h1 = Heatmap(
      heatmapId: HeatmapId('heatmap_1'),
      data: _heatmapPoints,
      radius: HeatmapRadius.fromPixels(20),
    );
    const Heatmap h2 = Heatmap(
      heatmapId: HeatmapId('heatmap_1'),
      data: _heatmapPoints,
      radius: HeatmapRadius.fromPixels(10),
    );

    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{h1}));
    await tester.pumpWidget(_mapWithHeatmaps(<Heatmap>{h2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.heatmapUpdates.last.heatmapsToChange.length, 1);

    final Heatmap update = map.heatmapUpdates.last.heatmapsToChange.first;
    expect(update, equals(h2));
    expect(update.radius.radius, 10);
  });

  testWidgets('Multi Update', (WidgetTester tester) async {
    Heatmap h1 = const Heatmap(
      heatmapId: HeatmapId('heatmap_1'),
      data: _heatmapPoints,
      radius: HeatmapRadius.fromPixels(20),
    );
    Heatmap h2 = const Heatmap(
      heatmapId: HeatmapId('heatmap_2'),
      data: _heatmapPoints,
      radius: HeatmapRadius.fromPixels(20),
    );
    final Set<Heatmap> prev = <Heatmap>{h1, h2};
    h1 = const Heatmap(
      heatmapId: HeatmapId('heatmap_1'),
      data: _heatmapPoints,
      dissipating: false,
      radius: HeatmapRadius.fromPixels(20),
    );
    h2 = const Heatmap(
      heatmapId: HeatmapId('heatmap_2'),
      data: _heatmapPoints,
      radius: HeatmapRadius.fromPixels(10),
    );
    final Set<Heatmap> cur = <Heatmap>{h1, h2};

    await tester.pumpWidget(_mapWithHeatmaps(prev));
    await tester.pumpWidget(_mapWithHeatmaps(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.heatmapUpdates.last.heatmapsToChange, cur);
    expect(map.heatmapUpdates.last.heatmapIdsToRemove.isEmpty, true);
    expect(map.heatmapUpdates.last.heatmapsToAdd.isEmpty, true);
  });

  testWidgets('Multi Update', (WidgetTester tester) async {
    Heatmap h2 = const Heatmap(
      heatmapId: HeatmapId('heatmap_2'),
      data: _heatmapPoints,
      radius: HeatmapRadius.fromPixels(20),
    );
    const Heatmap h3 = Heatmap(
      heatmapId: HeatmapId('heatmap_3'),
      data: _heatmapPoints,
      radius: HeatmapRadius.fromPixels(20),
    );
    final Set<Heatmap> prev = <Heatmap>{h2, h3};

    // h1 is added, h2 is updated, h3 is removed.
    const Heatmap h1 = Heatmap(
      heatmapId: HeatmapId('heatmap_1'),
      data: _heatmapPoints,
      radius: HeatmapRadius.fromPixels(20),
    );
    h2 = const Heatmap(
      heatmapId: HeatmapId('heatmap_2'),
      data: _heatmapPoints,
      radius: HeatmapRadius.fromPixels(10),
    );
    final Set<Heatmap> cur = <Heatmap>{h1, h2};

    await tester.pumpWidget(_mapWithHeatmaps(prev));
    await tester.pumpWidget(_mapWithHeatmaps(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.heatmapUpdates.last.heatmapsToChange.length, 1);
    expect(map.heatmapUpdates.last.heatmapsToAdd.length, 1);
    expect(map.heatmapUpdates.last.heatmapIdsToRemove.length, 1);

    expect(map.heatmapUpdates.last.heatmapsToChange.first, equals(h2));
    expect(map.heatmapUpdates.last.heatmapsToAdd.first, equals(h1));
    expect(
        map.heatmapUpdates.last.heatmapIdsToRemove.first, equals(h3.heatmapId));
  });

  testWidgets('Partial Update', (WidgetTester tester) async {
    const Heatmap h1 = Heatmap(
      heatmapId: HeatmapId('heatmap_1'),
      data: _heatmapPoints,
      radius: HeatmapRadius.fromPixels(20),
    );
    const Heatmap h2 = Heatmap(
      heatmapId: HeatmapId('heatmap_2'),
      data: _heatmapPoints,
      radius: HeatmapRadius.fromPixels(20),
    );
    Heatmap h3 = const Heatmap(
      heatmapId: HeatmapId('heatmap_3'),
      data: _heatmapPoints,
      radius: HeatmapRadius.fromPixels(20),
    );
    final Set<Heatmap> prev = <Heatmap>{h1, h2, h3};
    h3 = const Heatmap(
      heatmapId: HeatmapId('heatmap_3'),
      data: _heatmapPoints,
      radius: HeatmapRadius.fromPixels(10),
    );
    final Set<Heatmap> cur = <Heatmap>{h1, h2, h3};

    await tester.pumpWidget(_mapWithHeatmaps(prev));
    await tester.pumpWidget(_mapWithHeatmaps(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.heatmapUpdates.last.heatmapsToChange, <Heatmap>{h3});
    expect(map.heatmapUpdates.last.heatmapIdsToRemove.isEmpty, true);
    expect(map.heatmapUpdates.last.heatmapsToAdd.isEmpty, true);
  });
}
