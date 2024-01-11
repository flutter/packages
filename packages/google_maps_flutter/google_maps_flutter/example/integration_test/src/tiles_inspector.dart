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
