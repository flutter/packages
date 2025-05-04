// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'fake_google_maps_flutter_platform.dart';

Widget _mapWithMarkers(Set<GroundOverlay> groundOverlays) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      groundOverlays: groundOverlays,
    ),
  );
}

void main() {
  final LatLngBounds kGroundOverlayBounds = LatLngBounds(
    southwest: const LatLng(37.77483, -122.41942),
    northeast: const LatLng(37.78183, -122.39105),
  );

  late FakeGoogleMapsFlutterPlatform platform;

  setUp(() {
    platform = FakeGoogleMapsFlutterPlatform();
    GoogleMapsFlutterPlatform.instance = platform;
  });

  testWidgets('Initializing a groundOverlay', (WidgetTester tester) async {
    final GroundOverlay go1 = GroundOverlay.fromBounds(
      groundOverlayId: const GroundOverlayId('go_1'),
      bounds: kGroundOverlayBounds,
      image: AssetMapBitmap(
        'assets/red_square.png',
        imagePixelRatio: 1.0,
        bitmapScaling: MapBitmapScaling.none,
      ),
      transparency: 0.7,
      bearing: 10,
      zIndex: 10,
    );

    final GroundOverlay go2 = GroundOverlay.fromPosition(
      groundOverlayId: const GroundOverlayId('go_2'),
      position: kGroundOverlayBounds.northeast,
      width: 100,
      height: 100,
      anchor: const Offset(0.1, 0.2),
      image: AssetMapBitmap(
        'assets/red_square.png',
        imagePixelRatio: 1.0,
        bitmapScaling: MapBitmapScaling.none,
      ),
      transparency: 0.7,
      bearing: 10,
      zIndex: 10,
      zoomLevel: 14.0,
    );

    await tester.pumpWidget(_mapWithMarkers(<GroundOverlay>{go1, go2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.groundOverlayUpdates.last.groundOverlaysToAdd.length, 2);

    final Set<GroundOverlay> initializedGroundOverlays =
        map.groundOverlayUpdates.last.groundOverlaysToAdd;

    expect(initializedGroundOverlays.first, equals(go1));
    expect(initializedGroundOverlays.last, equals(go2));
    expect(
        map.groundOverlayUpdates.last.groundOverlayIdsToRemove.isEmpty, true);
    expect(map.groundOverlayUpdates.last.groundOverlaysToChange.isEmpty, true);
  });

  testWidgets('Adding a groundOverlay', (WidgetTester tester) async {
    final GroundOverlay go1 = GroundOverlay.fromBounds(
      groundOverlayId: const GroundOverlayId('go_1'),
      bounds: kGroundOverlayBounds,
      image: AssetMapBitmap(
        'assets/red_square.png',
        imagePixelRatio: 1.0,
        bitmapScaling: MapBitmapScaling.none,
      ),
      transparency: 0.7,
      bearing: 10,
      zIndex: 10,
    );

    final GroundOverlay go2 = GroundOverlay.fromPosition(
      groundOverlayId: const GroundOverlayId('go_2'),
      position: kGroundOverlayBounds.northeast,
      width: 100,
      height: 100,
      anchor: const Offset(0.1, 0.2),
      image: AssetMapBitmap(
        'assets/red_square.png',
        imagePixelRatio: 1.0,
        bitmapScaling: MapBitmapScaling.none,
      ),
      transparency: 0.7,
      bearing: 10,
      zIndex: 10,
      zoomLevel: 14.0,
    );

    await tester.pumpWidget(_mapWithMarkers(<GroundOverlay>{go1}));
    await tester.pumpWidget(_mapWithMarkers(<GroundOverlay>{go1, go2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.groundOverlayUpdates.last.groundOverlaysToAdd.length, 1);

    final GroundOverlay addedMarker =
        map.groundOverlayUpdates.last.groundOverlaysToAdd.first;
    expect(addedMarker, equals(go2));

    expect(
        map.groundOverlayUpdates.last.groundOverlayIdsToRemove.isEmpty, true);

    expect(map.groundOverlayUpdates.last.groundOverlaysToChange.isEmpty, true);
  });

  testWidgets('Removing a groundOverlay', (WidgetTester tester) async {
    final GroundOverlay go1 = GroundOverlay.fromBounds(
      groundOverlayId: const GroundOverlayId('go_1'),
      bounds: kGroundOverlayBounds,
      image: AssetMapBitmap(
        'assets/red_square.png',
        imagePixelRatio: 1.0,
        bitmapScaling: MapBitmapScaling.none,
      ),
      transparency: 0.7,
      bearing: 10,
      zIndex: 10,
    );

    await tester.pumpWidget(_mapWithMarkers(<GroundOverlay>{go1}));
    await tester.pumpWidget(_mapWithMarkers(<GroundOverlay>{}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.groundOverlayUpdates.last.groundOverlayIdsToRemove.length, 1);
    expect(map.groundOverlayUpdates.last.groundOverlayIdsToRemove.first,
        equals(go1.groundOverlayId));

    expect(map.groundOverlayUpdates.last.groundOverlaysToChange.isEmpty, true);
    expect(map.groundOverlayUpdates.last.groundOverlaysToAdd.isEmpty, true);
  });

  testWidgets('Updating a groundOverlay', (WidgetTester tester) async {
    final GroundOverlay go1 = GroundOverlay.fromBounds(
      groundOverlayId: const GroundOverlayId('go_1'),
      bounds: kGroundOverlayBounds,
      image: AssetMapBitmap(
        'assets/red_square.png',
        imagePixelRatio: 1.0,
        bitmapScaling: MapBitmapScaling.none,
      ),
      transparency: 0.7,
      bearing: 10,
      zIndex: 10,
    );

    final GroundOverlay go2 = go1.copyWith(visibleParam: false);

    await tester.pumpWidget(_mapWithMarkers(<GroundOverlay>{go1}));
    await tester.pumpWidget(_mapWithMarkers(<GroundOverlay>{go2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.groundOverlayUpdates.last.groundOverlaysToChange.length, 1);
    expect(map.groundOverlayUpdates.last.groundOverlaysToChange.first,
        equals(go2));

    expect(
        map.groundOverlayUpdates.last.groundOverlayIdsToRemove.isEmpty, true);
    expect(map.groundOverlayUpdates.last.groundOverlaysToAdd.isEmpty, true);
  });

  testWidgets('Multi Update', (WidgetTester tester) async {
    GroundOverlay go1 = GroundOverlay.fromBounds(
      groundOverlayId: const GroundOverlayId('go_1'),
      bounds: kGroundOverlayBounds,
      image: AssetMapBitmap(
        'assets/red_square.png',
        imagePixelRatio: 1.0,
        bitmapScaling: MapBitmapScaling.none,
      ),
      transparency: 0.7,
      bearing: 10,
      zIndex: 10,
    );

    GroundOverlay go2 = GroundOverlay.fromPosition(
      groundOverlayId: const GroundOverlayId('go_2'),
      position: kGroundOverlayBounds.northeast,
      width: 100,
      height: 100,
      anchor: const Offset(0.1, 0.2),
      image: AssetMapBitmap(
        'assets/red_square.png',
        imagePixelRatio: 1.0,
        bitmapScaling: MapBitmapScaling.none,
      ),
      transparency: 0.7,
      bearing: 10,
      zIndex: 10,
      zoomLevel: 14.0,
    );

    final Set<GroundOverlay> prev = <GroundOverlay>{go1, go2};
    go1 = go1.copyWith(visibleParam: false);
    go2 = go2.copyWith(clickableParam: false);
    final Set<GroundOverlay> cur = <GroundOverlay>{go1, go2};

    await tester.pumpWidget(_mapWithMarkers(prev));
    await tester.pumpWidget(_mapWithMarkers(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.groundOverlayUpdates.last.groundOverlaysToChange, cur);
    expect(
        map.groundOverlayUpdates.last.groundOverlayIdsToRemove.isEmpty, true);
    expect(map.groundOverlayUpdates.last.groundOverlaysToAdd.isEmpty, true);
  });

  testWidgets('Multi Update', (WidgetTester tester) async {
    final GroundOverlay go1 = GroundOverlay.fromBounds(
      groundOverlayId: const GroundOverlayId('go_1'),
      bounds: kGroundOverlayBounds,
      image: AssetMapBitmap(
        'assets/red_square.png',
        imagePixelRatio: 1.0,
        bitmapScaling: MapBitmapScaling.none,
      ),
      transparency: 0.7,
      bearing: 10,
      zIndex: 10,
    );

    GroundOverlay go2 = GroundOverlay.fromPosition(
      groundOverlayId: const GroundOverlayId('go_2'),
      position: kGroundOverlayBounds.northeast,
      width: 100,
      height: 100,
      anchor: const Offset(0.1, 0.2),
      image: AssetMapBitmap(
        'assets/red_square.png',
        imagePixelRatio: 1.0,
        bitmapScaling: MapBitmapScaling.none,
      ),
      transparency: 0.7,
      bearing: 10,
      zIndex: 10,
      zoomLevel: 14.0,
    );

    final GroundOverlay go3 = GroundOverlay.fromPosition(
      groundOverlayId: const GroundOverlayId('go_3'),
      position: kGroundOverlayBounds.southwest,
      width: 100,
      height: 100,
      anchor: const Offset(0.1, 0.2),
      image: AssetMapBitmap(
        'assets/red_square.png',
        imagePixelRatio: 1.0,
        bitmapScaling: MapBitmapScaling.none,
      ),
      transparency: 0.7,
      bearing: 10,
      zIndex: 10,
      zoomLevel: 14.0,
    );

    final Set<GroundOverlay> prev = <GroundOverlay>{go2, go3};

    // go1 is added, go2 is updated, go3 is removed.
    go2 = go2.copyWith(clickableParam: false);
    final Set<GroundOverlay> cur = <GroundOverlay>{go1, go2};

    await tester.pumpWidget(_mapWithMarkers(prev));
    await tester.pumpWidget(_mapWithMarkers(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.groundOverlayUpdates.last.groundOverlaysToChange.length, 1);
    expect(map.groundOverlayUpdates.last.groundOverlaysToAdd.length, 1);
    expect(map.groundOverlayUpdates.last.groundOverlayIdsToRemove.length, 1);

    expect(map.groundOverlayUpdates.last.groundOverlaysToChange.first,
        equals(go2));
    expect(
        map.groundOverlayUpdates.last.groundOverlaysToAdd.first, equals(go1));
    expect(map.groundOverlayUpdates.last.groundOverlayIdsToRemove.first,
        equals(go3.groundOverlayId));
  });

  testWidgets('Partial Update', (WidgetTester tester) async {
    final GroundOverlay go1 = GroundOverlay.fromBounds(
      groundOverlayId: const GroundOverlayId('go_1'),
      bounds: kGroundOverlayBounds,
      image: AssetMapBitmap(
        'assets/red_square.png',
        imagePixelRatio: 1.0,
        bitmapScaling: MapBitmapScaling.none,
      ),
      transparency: 0.7,
      bearing: 10,
      zIndex: 10,
    );

    final GroundOverlay go2 = GroundOverlay.fromPosition(
      groundOverlayId: const GroundOverlayId('go_2'),
      position: kGroundOverlayBounds.northeast,
      width: 100,
      height: 100,
      anchor: const Offset(0.1, 0.2),
      image: AssetMapBitmap(
        'assets/red_square.png',
        imagePixelRatio: 1.0,
        bitmapScaling: MapBitmapScaling.none,
      ),
      transparency: 0.7,
      bearing: 10,
      zIndex: 10,
      zoomLevel: 14.0,
    );

    GroundOverlay go3 = GroundOverlay.fromPosition(
      groundOverlayId: const GroundOverlayId('go_3'),
      position: kGroundOverlayBounds.southwest,
      width: 100,
      height: 100,
      anchor: const Offset(0.1, 0.2),
      image: AssetMapBitmap(
        'assets/red_square.png',
        imagePixelRatio: 1.0,
        bitmapScaling: MapBitmapScaling.none,
      ),
      transparency: 0.7,
      bearing: 10,
      zIndex: 10,
      zoomLevel: 14.0,
    );
    final Set<GroundOverlay> prev = <GroundOverlay>{go1, go2, go3};
    go3 = go3.copyWith(visibleParam: false);
    final Set<GroundOverlay> cur = <GroundOverlay>{go1, go2, go3};

    await tester.pumpWidget(_mapWithMarkers(prev));
    await tester.pumpWidget(_mapWithMarkers(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.groundOverlayUpdates.last.groundOverlaysToChange,
        <GroundOverlay>{go3});
    expect(
        map.groundOverlayUpdates.last.groundOverlayIdsToRemove.isEmpty, true);
    expect(map.groundOverlayUpdates.last.groundOverlaysToAdd.isEmpty, true);
  });

  testWidgets('Update non platform related attr', (WidgetTester tester) async {
    GroundOverlay go1 = GroundOverlay.fromBounds(
      groundOverlayId: const GroundOverlayId('go_1'),
      bounds: kGroundOverlayBounds,
      image: AssetMapBitmap(
        'assets/red_square.png',
        imagePixelRatio: 1.0,
        bitmapScaling: MapBitmapScaling.none,
      ),
      transparency: 0.7,
      bearing: 10,
      zIndex: 10,
    );
    final Set<GroundOverlay> prev = <GroundOverlay>{go1};
    go1 = go1.copyWith(
      onTapParam: () {},
    );
    final Set<GroundOverlay> cur = <GroundOverlay>{go1};

    await tester.pumpWidget(_mapWithMarkers(prev));
    await tester.pumpWidget(_mapWithMarkers(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.groundOverlayUpdates.last.groundOverlaysToChange.isEmpty, true);
    expect(
        map.groundOverlayUpdates.last.groundOverlayIdsToRemove.isEmpty, true);
    expect(map.groundOverlayUpdates.last.groundOverlaysToAdd.isEmpty, true);
  });

  testWidgets('multi-update with delays', (WidgetTester tester) async {
    platform.simulatePlatformDelay = true;

    final GroundOverlay go1 = GroundOverlay.fromBounds(
      groundOverlayId: const GroundOverlayId('go_1'),
      bounds: kGroundOverlayBounds,
      image: AssetMapBitmap(
        'assets/red_square.png',
        imagePixelRatio: 1.0,
        bitmapScaling: MapBitmapScaling.none,
      ),
      transparency: 0.7,
      bearing: 10,
      zIndex: 10,
    );

    final GroundOverlay go2 = GroundOverlay.fromPosition(
      groundOverlayId: const GroundOverlayId('go_2'),
      position: kGroundOverlayBounds.northeast,
      width: 100,
      height: 100,
      anchor: const Offset(0.1, 0.2),
      image: AssetMapBitmap(
        'assets/red_square.png',
        imagePixelRatio: 1.0,
        bitmapScaling: MapBitmapScaling.none,
      ),
      transparency: 0.7,
      bearing: 10,
      zIndex: 10,
      zoomLevel: 14.0,
    );

    final GroundOverlay go3 = GroundOverlay.fromPosition(
      groundOverlayId: const GroundOverlayId('go_3'),
      position: kGroundOverlayBounds.southwest,
      width: 100,
      height: 100,
      anchor: const Offset(0.1, 0.2),
      image: AssetMapBitmap(
        'assets/red_square.png',
        imagePixelRatio: 1.0,
        bitmapScaling: MapBitmapScaling.none,
      ),
      transparency: 0.7,
      bearing: 10,
      zIndex: 10,
      zoomLevel: 14.0,
    );

    final GroundOverlay go3updated = go3.copyWith(visibleParam: false);

    // First remove one and add another, then update the new one.
    await tester.pumpWidget(_mapWithMarkers(<GroundOverlay>{go1, go2}));
    await tester.pumpWidget(_mapWithMarkers(<GroundOverlay>{go1, go3}));
    await tester.pumpWidget(_mapWithMarkers(<GroundOverlay>{go1, go3updated}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.groundOverlayUpdates.length, 3);

    expect(map.groundOverlayUpdates[0].groundOverlaysToChange.isEmpty, true);
    expect(map.groundOverlayUpdates[0].groundOverlaysToAdd,
        <GroundOverlay>{go1, go2});
    expect(map.groundOverlayUpdates[0].groundOverlayIdsToRemove.isEmpty, true);

    expect(map.groundOverlayUpdates[1].groundOverlaysToChange.isEmpty, true);
    expect(
        map.groundOverlayUpdates[1].groundOverlaysToAdd, <GroundOverlay>{go3});
    expect(map.groundOverlayUpdates[1].groundOverlayIdsToRemove,
        <GroundOverlayId>{go2.groundOverlayId});

    expect(map.groundOverlayUpdates[2].groundOverlaysToChange,
        <GroundOverlay>{go3updated});
    expect(map.groundOverlayUpdates[2].groundOverlaysToAdd.isEmpty, true);
    expect(map.groundOverlayUpdates[2].groundOverlayIdsToRemove.isEmpty, true);

    await tester.pumpAndSettle();
  });
}
