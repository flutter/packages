// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'fake_google_maps_flutter_platform.dart';

Widget _mapWithTileOverlays(Set<TileOverlay> tileOverlays) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
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

  testWidgets('Initializing a tile overlay', (WidgetTester tester) async {
    const TileOverlay t1 =
        TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_1'));
    await tester.pumpWidget(_mapWithTileOverlays(<TileOverlay>{t1}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.tileOverlaySets.last, equals(<TileOverlay>{t1}));
  });

  testWidgets('Adding a tile overlay', (WidgetTester tester) async {
    const TileOverlay t1 =
        TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_1'));
    const TileOverlay t2 =
        TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_2'));

    await tester.pumpWidget(_mapWithTileOverlays(<TileOverlay>{t1}));
    await tester.pumpWidget(_mapWithTileOverlays(<TileOverlay>{t1, t2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.tileOverlaySets.last, equals(<TileOverlay>{t1, t2}));
  });

  testWidgets('Removing a tile overlay', (WidgetTester tester) async {
    const TileOverlay t1 =
        TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_1'));

    await tester.pumpWidget(_mapWithTileOverlays(<TileOverlay>{t1}));
    await tester.pumpWidget(_mapWithTileOverlays(<TileOverlay>{}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.tileOverlaySets.last, equals(<TileOverlay>{}));
  });

  testWidgets('Updating a tile overlay', (WidgetTester tester) async {
    const TileOverlay t1 =
        TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_1'));
    const TileOverlay t2 =
        TileOverlay(tileOverlayId: TileOverlayId('tile_overlay_1'), zIndex: 10);

    await tester.pumpWidget(_mapWithTileOverlays(<TileOverlay>{t1}));
    await tester.pumpWidget(_mapWithTileOverlays(<TileOverlay>{t2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.tileOverlaySets.last, equals(<TileOverlay>{t2}));
  });
}
