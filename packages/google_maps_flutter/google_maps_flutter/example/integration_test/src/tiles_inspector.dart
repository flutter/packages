// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:integration_test/integration_test.dart';

import 'shared.dart';

/// Integration Tests for the Tiles feature. These also use the [GoogleMapsInspectorPlatform].
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  runTests();
}

void runTests() {
  const double floatTolerance = 1e-6;

  GoogleMapsFlutterPlatform.instance.enableDebugInspection();

  final GoogleMapsInspectorPlatform inspector =
      GoogleMapsInspectorPlatform.instance!;

  group('Tiles', () {
    testWidgets(
      'set tileOverlay correctly',
      (WidgetTester tester) async {
        final Completer<int> mapIdCompleter = Completer<int>();
        final TileOverlay tileOverlay1 = TileOverlay(
          tileOverlayId: const TileOverlayId('tile_overlay_1'),
          tileProvider: _DebugTileProvider(),
          zIndex: 2,
          transparency: 0.2,
        );

        final TileOverlay tileOverlay2 = TileOverlay(
          tileOverlayId: const TileOverlayId('tile_overlay_2'),
          tileProvider: _DebugTileProvider(),
          zIndex: 1,
          visible: false,
          transparency: 0.3,
          fadeIn: false,
        );
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: GoogleMap(
              initialCameraPosition: kInitialCameraPosition,
              tileOverlays: <TileOverlay>{tileOverlay1, tileOverlay2},
              onMapCreated: (GoogleMapController controller) {
                mapIdCompleter.complete(controller.mapId);
              },
            ),
          ),
        );
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final int mapId = await mapIdCompleter.future;

        final TileOverlay tileOverlayInfo1 = (await inspector
            .getTileOverlayInfo(tileOverlay1.mapsId, mapId: mapId))!;
        final TileOverlay tileOverlayInfo2 = (await inspector
            .getTileOverlayInfo(tileOverlay2.mapsId, mapId: mapId))!;

        expect(tileOverlayInfo1.visible, isTrue);
        expect(tileOverlayInfo1.fadeIn, isTrue);
        expect(tileOverlayInfo1.transparency,
            moreOrLessEquals(0.2, epsilon: 0.001));
        expect(tileOverlayInfo1.zIndex, 2);

        expect(tileOverlayInfo2.visible, isFalse);
        expect(tileOverlayInfo2.fadeIn, isFalse);
        expect(tileOverlayInfo2.transparency,
            moreOrLessEquals(0.3, epsilon: 0.001));
        expect(tileOverlayInfo2.zIndex, 1);
      },
    );

    testWidgets(
      'update tileOverlays correctly',
      (WidgetTester tester) async {
        final Completer<int> mapIdCompleter = Completer<int>();
        final Key key = GlobalKey();
        final TileOverlay tileOverlay1 = TileOverlay(
          tileOverlayId: const TileOverlayId('tile_overlay_1'),
          tileProvider: _DebugTileProvider(),
          zIndex: 2,
          transparency: 0.2,
        );

        final TileOverlay tileOverlay2 = TileOverlay(
          tileOverlayId: const TileOverlayId('tile_overlay_2'),
          tileProvider: _DebugTileProvider(),
          zIndex: 3,
          transparency: 0.5,
        );
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: GoogleMap(
              key: key,
              initialCameraPosition: kInitialCameraPosition,
              tileOverlays: <TileOverlay>{tileOverlay1, tileOverlay2},
              onMapCreated: (GoogleMapController controller) {
                mapIdCompleter.complete(controller.mapId);
              },
            ),
          ),
        );

        final int mapId = await mapIdCompleter.future;

        final TileOverlay tileOverlay1New = TileOverlay(
          tileOverlayId: const TileOverlayId('tile_overlay_1'),
          tileProvider: _DebugTileProvider(),
          zIndex: 1,
          visible: false,
          transparency: 0.3,
          fadeIn: false,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: GoogleMap(
              key: key,
              initialCameraPosition: kInitialCameraPosition,
              tileOverlays: <TileOverlay>{tileOverlay1New},
              onMapCreated: (GoogleMapController controller) {
                fail('update: OnMapCreated should get called only once.');
              },
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 3));

        final TileOverlay tileOverlayInfo1 = (await inspector
            .getTileOverlayInfo(tileOverlay1.mapsId, mapId: mapId))!;
        final TileOverlay? tileOverlayInfo2 = await inspector
            .getTileOverlayInfo(tileOverlay2.mapsId, mapId: mapId);

        expect(tileOverlayInfo1.visible, isFalse);
        expect(tileOverlayInfo1.fadeIn, isFalse);
        expect(tileOverlayInfo1.transparency,
            moreOrLessEquals(0.3, epsilon: 0.001));
        expect(tileOverlayInfo1.zIndex, 1);

        expect(tileOverlayInfo2, isNull);
      },
    );

    testWidgets(
      'remove tileOverlays correctly',
      (WidgetTester tester) async {
        final Completer<int> mapIdCompleter = Completer<int>();
        final Key key = GlobalKey();
        final TileOverlay tileOverlay1 = TileOverlay(
          tileOverlayId: const TileOverlayId('tile_overlay_1'),
          tileProvider: _DebugTileProvider(),
          zIndex: 2,
          transparency: 0.2,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: GoogleMap(
              key: key,
              initialCameraPosition: kInitialCameraPosition,
              tileOverlays: <TileOverlay>{tileOverlay1},
              onMapCreated: (GoogleMapController controller) {
                mapIdCompleter.complete(controller.mapId);
              },
            ),
          ),
        );

        final int mapId = await mapIdCompleter.future;

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: GoogleMap(
              key: key,
              initialCameraPosition: kInitialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                fail('OnMapCreated should get called only once.');
              },
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 3));
        final TileOverlay? tileOverlayInfo1 = await inspector
            .getTileOverlayInfo(tileOverlay1.mapsId, mapId: mapId);

        expect(tileOverlayInfo1, isNull);
      },
    );
  }, skip: isWeb /* Tiles not supported on the web */);

  group('Heatmaps', () {
    /// Check that two lists of [WeightedLatLng] are more or less equal.
    void expectHeatmapDataMoreOrLessEquals(
      List<WeightedLatLng> data1,
      List<WeightedLatLng> data2,
    ) {
      expect(data1.length, data2.length);
      for (int i = 0; i < data1.length; i++) {
        final WeightedLatLng wll1 = data1[i];
        final WeightedLatLng wll2 = data2[i];
        expect(wll1.weight, wll2.weight);
        expect(wll1.point.latitude, moreOrLessEquals(wll2.point.latitude));
        expect(wll1.point.longitude, moreOrLessEquals(wll2.point.longitude));
      }
    }

    /// Check that two [HeatmapGradient]s are more or less equal.
    void expectHeatmapGradientMoreOrLessEquals(
      HeatmapGradient? gradient1,
      HeatmapGradient? gradient2,
    ) {
      if (gradient1 == null || gradient2 == null) {
        expect(gradient1, gradient2);
        return;
      }
      expect(gradient2, isNotNull);

      expect(gradient1.colors.length, gradient2.colors.length);
      for (int i = 0; i < gradient1.colors.length; i++) {
        final HeatmapGradientColor color1 = gradient1.colors[i];
        final HeatmapGradientColor color2 = gradient2.colors[i];
        expect(color1.color, color2.color);
        expect(
          color1.startPoint,
          moreOrLessEquals(color2.startPoint, epsilon: floatTolerance),
        );
      }

      expect(gradient1.colorMapSize, gradient2.colorMapSize);
    }

    void expectHeatmapEquals(Heatmap heatmap1, Heatmap heatmap2) {
      expectHeatmapDataMoreOrLessEquals(heatmap1.data, heatmap2.data);
      expectHeatmapGradientMoreOrLessEquals(
          heatmap1.gradient, heatmap2.gradient);

      // Only Android supports `maxIntensity`
      // so the platform value is undefined on others.
      bool canHandleMaxIntensity() {
        return isAndroid;
      }

      // Only iOS supports `minimumZoomIntensity` and `maximumZoomIntensity`
      // so the platform value is undefined on others.
      bool canHandleZoomIntensity() {
        return isIOS;
      }

      if (canHandleMaxIntensity()) {
        expect(heatmap1.maxIntensity, heatmap2.maxIntensity);
      }
      expect(
        heatmap1.opacity,
        moreOrLessEquals(heatmap2.opacity, epsilon: floatTolerance),
      );
      expect(heatmap1.radius, heatmap2.radius);
      if (canHandleZoomIntensity()) {
        expect(heatmap1.minimumZoomIntensity, heatmap2.minimumZoomIntensity);
        expect(heatmap1.maximumZoomIntensity, heatmap2.maximumZoomIntensity);
      }
    }

    const Heatmap heatmap1 = Heatmap(
      heatmapId: HeatmapId('heatmap_1'),
      data: <WeightedLatLng>[
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
        WeightedLatLng(LatLng(37.785, -122.435), weight: 2)
      ],
      dissipating: false,
      gradient: HeatmapGradient(
        <HeatmapGradientColor>[
          HeatmapGradientColor(
            Color.fromARGB(255, 0, 255, 255),
            0.2,
          ),
          HeatmapGradientColor(
            Color.fromARGB(255, 0, 63, 255),
            0.4,
          ),
          HeatmapGradientColor(
            Color.fromARGB(255, 0, 0, 191),
            0.6,
          ),
          HeatmapGradientColor(
            Color.fromARGB(255, 63, 0, 91),
            0.8,
          ),
          HeatmapGradientColor(
            Color.fromARGB(255, 255, 0, 0),
            1,
          ),
        ],
      ),
      maxIntensity: 1,
      opacity: 0.5,
      radius: HeatmapRadius.fromPixels(40),
      minimumZoomIntensity: 1,
      maximumZoomIntensity: 20,
    );

    testWidgets('set heatmap correctly', (WidgetTester tester) async {
      final Completer<int> mapIdCompleter = Completer<int>();
      final Heatmap heatmap2 = Heatmap(
        heatmapId: const HeatmapId('heatmap_2'),
        data: heatmap1.data,
        dissipating: heatmap1.dissipating,
        gradient: heatmap1.gradient,
        maxIntensity: heatmap1.maxIntensity,
        opacity: heatmap1.opacity - 0.1,
        radius: heatmap1.radius,
        minimumZoomIntensity: heatmap1.minimumZoomIntensity,
        maximumZoomIntensity: heatmap1.maximumZoomIntensity,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GoogleMap(
            initialCameraPosition: kInitialCameraPosition,
            heatmaps: <Heatmap>{heatmap1, heatmap2},
            onMapCreated: (GoogleMapController controller) {
              mapIdCompleter.complete(controller.mapId);
            },
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final int mapId = await mapIdCompleter.future;
      final GoogleMapsInspectorPlatform inspector =
          GoogleMapsInspectorPlatform.instance!;

      if (inspector.supportsGettingHeatmapInfo()) {
        final Heatmap heatmapInfo1 =
            (await inspector.getHeatmapInfo(heatmap1.mapsId, mapId: mapId))!;
        final Heatmap heatmapInfo2 =
            (await inspector.getHeatmapInfo(heatmap2.mapsId, mapId: mapId))!;

        expectHeatmapEquals(heatmap1, heatmapInfo1);
        expectHeatmapEquals(heatmap2, heatmapInfo2);
      }
    });

    testWidgets('update heatmaps correctly', (WidgetTester tester) async {
      final Completer<int> mapIdCompleter = Completer<int>();
      final Key key = GlobalKey();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GoogleMap(
            key: key,
            initialCameraPosition: kInitialCameraPosition,
            heatmaps: <Heatmap>{heatmap1},
            onMapCreated: (GoogleMapController controller) {
              mapIdCompleter.complete(controller.mapId);
            },
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final int mapId = await mapIdCompleter.future;
      final GoogleMapsInspectorPlatform inspector =
          GoogleMapsInspectorPlatform.instance!;

      final Heatmap heatmap1New = heatmap1.copyWith(
        dataParam: heatmap1.data.sublist(5),
        dissipatingParam: !heatmap1.dissipating,
        gradientParam: heatmap1.gradient,
        maxIntensityParam: heatmap1.maxIntensity! + 1,
        opacityParam: heatmap1.opacity - 0.1,
        radiusParam: HeatmapRadius.fromPixels(heatmap1.radius.radius + 1),
        minimumZoomIntensityParam: heatmap1.minimumZoomIntensity + 1,
        maximumZoomIntensityParam: heatmap1.maximumZoomIntensity + 1,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GoogleMap(
            key: key,
            initialCameraPosition: kInitialCameraPosition,
            heatmaps: <Heatmap>{heatmap1New},
            onMapCreated: (GoogleMapController controller) {
              fail('update: OnMapCreated should get called only once.');
            },
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      if (inspector.supportsGettingHeatmapInfo()) {
        final Heatmap heatmapInfo1 =
            (await inspector.getHeatmapInfo(heatmap1.mapsId, mapId: mapId))!;

        expectHeatmapEquals(heatmap1New, heatmapInfo1);
      }
    });

    testWidgets('remove heatmaps correctly', (WidgetTester tester) async {
      final Completer<int> mapIdCompleter = Completer<int>();
      final Key key = GlobalKey();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GoogleMap(
            key: key,
            initialCameraPosition: kInitialCameraPosition,
            heatmaps: <Heatmap>{heatmap1},
            onMapCreated: (GoogleMapController controller) {
              mapIdCompleter.complete(controller.mapId);
            },
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final int mapId = await mapIdCompleter.future;
      final GoogleMapsInspectorPlatform inspector =
          GoogleMapsInspectorPlatform.instance!;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GoogleMap(
            key: key,
            initialCameraPosition: kInitialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              fail('OnMapCreated should get called only once.');
            },
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      if (inspector.supportsGettingHeatmapInfo()) {
        final Heatmap? heatmapInfo1 =
            await inspector.getHeatmapInfo(heatmap1.mapsId, mapId: mapId);

        expect(heatmapInfo1, isNull);
      }
    });
  });

  group('GroundOverlay', () {
    final LatLngBounds kGroundOverlayBounds = LatLngBounds(
      southwest: const LatLng(37.77483, -122.41942),
      northeast: const LatLng(37.78183, -122.39105),
    );

    final GroundOverlay groundOverlayBounds1 = GroundOverlay.fromBounds(
      groundOverlayId: const GroundOverlayId('bounds_1'),
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

    final GroundOverlay groundOverlayPosition1 = GroundOverlay.fromPosition(
      groundOverlayId: const GroundOverlayId('position_1'),
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

    void expectGroundOverlayEquals(
        GroundOverlay source, GroundOverlay response) {
      expect(response.groundOverlayId, source.groundOverlayId);
      expect(
        response.transparency,
        moreOrLessEquals(source.transparency, epsilon: floatTolerance),
      );

      // Web does not support bearing.
      if (!isWeb) {
        expect(
          response.bearing,
          moreOrLessEquals(source.bearing, epsilon: floatTolerance),
        );
      }

      // Only test bounds if it was given in the original object.
      if (source.bounds != null) {
        expect(response.bounds, source.bounds);
      }

      // Only test position if it was given in the original object.
      if (source.position != null) {
        expect(response.position, source.position);
      }

      expect(response.clickable, source.clickable);

      // Web does not support zIndex.
      if (!isWeb) {
        expect(response.zIndex, source.zIndex);
      }

      // Only Android supports width and height.
      if (isAndroid) {
        expect(response.width, source.width);
        expect(response.height, source.height);
      }

      // Only iOS supports zoomLevel.
      if (isIOS) {
        expect(response.zoomLevel, source.zoomLevel);
      }

      // Only Android (using position) and iOS supports `anchor`.
      if ((isAndroid && source.position != null) || isIOS) {
        expect(
          response.anchor?.dx,
          moreOrLessEquals(source.anchor!.dx, epsilon: floatTolerance),
        );
        expect(
          response.anchor?.dy,
          moreOrLessEquals(source.anchor!.dy, epsilon: floatTolerance),
        );
      }
    }

    testWidgets('set ground overlays correctly', (WidgetTester tester) async {
      final Completer<int> mapIdCompleter = Completer<int>();
      final GroundOverlay groundOverlayBounds2 = GroundOverlay.fromBounds(
        groundOverlayId: const GroundOverlayId('bounds_2'),
        bounds: groundOverlayBounds1.bounds!,
        image: groundOverlayBounds1.image,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GoogleMap(
            initialCameraPosition: kInitialCameraPosition,
            groundOverlays: <GroundOverlay>{
              groundOverlayBounds1,
              groundOverlayBounds2,
              // Web does not support position-based ground overlays.
              if (!isWeb) groundOverlayPosition1,
            },
            onMapCreated: (GoogleMapController controller) {
              mapIdCompleter.complete(controller.mapId);
            },
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final int mapId = await mapIdCompleter.future;
      final GoogleMapsInspectorPlatform inspector =
          GoogleMapsInspectorPlatform.instance!;

      if (inspector.supportsGettingGroundOverlayInfo()) {
        final GroundOverlay groundOverlayBoundsInfo1 = (await inspector
            .getGroundOverlayInfo(groundOverlayBounds1.mapsId, mapId: mapId))!;
        final GroundOverlay groundOverlayBoundsInfo2 = (await inspector
            .getGroundOverlayInfo(groundOverlayBounds2.mapsId, mapId: mapId))!;

        expectGroundOverlayEquals(
          groundOverlayBounds1,
          groundOverlayBoundsInfo1,
        );
        expectGroundOverlayEquals(
          groundOverlayBounds2,
          groundOverlayBoundsInfo2,
        );

        // Web does not support position-based ground overlays.
        if (!isWeb) {
          final GroundOverlay groundOverlayPositionInfo1 = (await inspector
              .getGroundOverlayInfo(groundOverlayPosition1.mapsId,
                  mapId: mapId))!;
          expectGroundOverlayEquals(
            groundOverlayPosition1,
            groundOverlayPositionInfo1,
          );
        }
      }
    });

    testWidgets('update ground overlays correctly',
        (WidgetTester tester) async {
      final Completer<int> mapIdCompleter = Completer<int>();
      final Key key = GlobalKey();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GoogleMap(
            key: key,
            initialCameraPosition: kInitialCameraPosition,
            groundOverlays: <GroundOverlay>{
              groundOverlayBounds1,
              // Web does not support position-based ground overlays.
              if (!isWeb) groundOverlayPosition1
            },
            onMapCreated: (GoogleMapController controller) {
              mapIdCompleter.complete(controller.mapId);
            },
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final int mapId = await mapIdCompleter.future;
      final GoogleMapsInspectorPlatform inspector =
          GoogleMapsInspectorPlatform.instance!;

      final GroundOverlay groundOverlayBounds1New =
          groundOverlayBounds1.copyWith(
        bearingParam: 10,
        clickableParam: false,
        visibleParam: false,
        transparencyParam: 0.5,
        zIndexParam: 10,
      );

      final GroundOverlay groundOverlayPosition1New =
          groundOverlayPosition1.copyWith(
        bearingParam: 10,
        clickableParam: false,
        visibleParam: false,
        transparencyParam: 0.5,
        zIndexParam: 10,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GoogleMap(
            key: key,
            initialCameraPosition: kInitialCameraPosition,
            groundOverlays: <GroundOverlay>{
              groundOverlayBounds1New,
              // Web does not support position-based ground overlays.
              if (!isWeb) groundOverlayPosition1New
            },
            onMapCreated: (GoogleMapController controller) {
              fail('update: OnMapCreated should get called only once.');
            },
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      if (inspector.supportsGettingGroundOverlayInfo()) {
        final GroundOverlay groundOverlayBounds1Info = (await inspector
            .getGroundOverlayInfo(groundOverlayBounds1.mapsId, mapId: mapId))!;

        expectGroundOverlayEquals(
          groundOverlayBounds1New,
          groundOverlayBounds1Info,
        );

        // Web does not support position-based ground overlays.
        if (!isWeb) {
          final GroundOverlay groundOverlayPosition1Info = (await inspector
              .getGroundOverlayInfo(groundOverlayPosition1.mapsId,
                  mapId: mapId))!;

          expectGroundOverlayEquals(
            groundOverlayPosition1New,
            groundOverlayPosition1Info,
          );
        }
      }
    });

    testWidgets('remove ground overlays correctly',
        (WidgetTester tester) async {
      final Completer<int> mapIdCompleter = Completer<int>();
      final Key key = GlobalKey();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GoogleMap(
            key: key,
            initialCameraPosition: kInitialCameraPosition,
            groundOverlays: <GroundOverlay>{
              groundOverlayBounds1,
              // Web does not support position-based ground overlays.
              if (!isWeb) groundOverlayPosition1
            },
            onMapCreated: (GoogleMapController controller) {
              mapIdCompleter.complete(controller.mapId);
            },
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final int mapId = await mapIdCompleter.future;
      final GoogleMapsInspectorPlatform inspector =
          GoogleMapsInspectorPlatform.instance!;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GoogleMap(
            key: key,
            initialCameraPosition: kInitialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              fail('OnMapCreated should get called only once.');
            },
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      if (inspector.supportsGettingGroundOverlayInfo()) {
        final GroundOverlay? groundOverlayBounds1Info = await inspector
            .getGroundOverlayInfo(groundOverlayBounds1.mapsId, mapId: mapId);
        expect(groundOverlayBounds1Info, isNull);

        // Web does not support position-based ground overlays.
        if (!isWeb) {
          final GroundOverlay? groundOverlayPositionInfo = await inspector
              .getGroundOverlayInfo(groundOverlayPosition1.mapsId,
                  mapId: mapId);
          expect(groundOverlayPositionInfo, isNull);
        }
      }
    });
  });
}

class _DebugTileProvider implements TileProvider {
  _DebugTileProvider() {
    boxPaint.isAntiAlias = true;
    boxPaint.color = Colors.blue;
    boxPaint.strokeWidth = 2.0;
    boxPaint.style = PaintingStyle.stroke;
  }

  static const int width = 100;
  static const int height = 100;
  static final Paint boxPaint = Paint();
  static const TextStyle textStyle = TextStyle(
    color: Colors.red,
    fontSize: 20,
  );

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final TextSpan textSpan = TextSpan(
      text: '$x,$y',
      style: textStyle,
    );
    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      maxWidth: width.toDouble(),
    );
    textPainter.paint(canvas, Offset.zero);
    canvas.drawRect(
        Rect.fromLTRB(0, 0, width.toDouble(), width.toDouble()), boxPaint);
    final ui.Picture picture = recorder.endRecording();
    final Uint8List byteData = await picture
        .toImage(width, height)
        .then((ui.Image image) =>
            image.toByteData(format: ui.ImageByteFormat.png))
        .then((ByteData? byteData) => byteData!.buffer.asUint8List());
    return Tile(width, height, byteData);
  }
}
