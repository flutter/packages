// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web/web.dart';

import 'resources/tile16_base64.dart';

class NoTileProvider implements TileProvider {
  const NoTileProvider();

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async => TileProvider.noTile;
}

class TestTileProvider implements TileProvider {
  const TestTileProvider();

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async =>
      Tile(16, 16, const Base64Decoder().convert(tile16Base64));
}

/// Test Overlays
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('TileOverlayController', () {
    const TileOverlayId id = TileOverlayId('');

    testWidgets('minimal initialization', (WidgetTester tester) async {
      final TileOverlayController controller = TileOverlayController(
        tileOverlay: const TileOverlay(tileOverlayId: id),
      );

      final gmaps.Size size = controller.gmMapType.tileSize!;
      expect(size.width, TileOverlayController.logicalTileSize);
      expect(size.height, TileOverlayController.logicalTileSize);
      expect(
        controller.gmMapType.getTile!(gmaps.Point(0, 0), 0, document),
        null,
      );
    });

    testWidgets('produces image tiles', (WidgetTester tester) async {
      final TileOverlayController controller = TileOverlayController(
        tileOverlay: const TileOverlay(
          tileOverlayId: id,
          tileProvider: TestTileProvider(),
        ),
      );

      final HTMLImageElement img =
          controller.gmMapType.getTile!(gmaps.Point(0, 0), 0, document)!
              as HTMLImageElement;
      expect(img.naturalWidth, 0);
      expect(img.naturalHeight, 0);
      expect(img.hidden, true);

      await img.onLoad.first;

      await img.decode().toDart;

      expect(img.hidden, false);
      expect(img.naturalWidth, 16);
      expect(img.naturalHeight, 16);
    });

    testWidgets('update', (WidgetTester tester) async {
      final TileOverlayController controller = TileOverlayController(
        tileOverlay: const TileOverlay(
          tileOverlayId: id,
          tileProvider: NoTileProvider(),
        ),
      );
      {
        final HTMLImageElement img =
            controller.gmMapType.getTile!(gmaps.Point(0, 0), 0, document)!
                as HTMLImageElement;
        await null; // let `getTile` `then` complete
        expect(
          img.src,
          isEmpty,
          reason: 'The NoTileProvider never updates the img src',
        );
      }

      controller.update(const TileOverlay(
        tileOverlayId: id,
        tileProvider: TestTileProvider(),
      ));
      {
        final HTMLImageElement img =
            controller.gmMapType.getTile!(gmaps.Point(0, 0), 0, document)!
                as HTMLImageElement;

        await img.onLoad.first;

        expect(
          img.src,
          isNotEmpty,
          reason: 'The img `src` should eventually become the Blob URL.',
        );
      }

      controller.update(const TileOverlay(tileOverlayId: id));
      {
        expect(
          controller.gmMapType.getTile!(gmaps.Point(0, 0), 0, document),
          null,
          reason: 'Setting a null tileProvider should work.',
        );
      }
    });
  });
}
