// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/src/types/tile_overlay.dart';
import 'package:google_maps_flutter_platform_interface/src/types/tile_overlay_updates.dart';
import 'package:google_maps_flutter_platform_interface/src/types/utils/tile_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('tile overlay updates tests', () {
    test('Correctly set toRemove, toAdd and toChange', () async {
      const to1 = TileOverlay(tileOverlayId: TileOverlayId('id1'));
      const to2 = TileOverlay(tileOverlayId: TileOverlayId('id2'));
      const to3 = TileOverlay(tileOverlayId: TileOverlayId('id3'));
      const to3Changed = TileOverlay(
        tileOverlayId: TileOverlayId('id3'),
        transparency: 0.5,
      );
      const to4 = TileOverlay(tileOverlayId: TileOverlayId('id4'));
      final previous = <TileOverlay>{to1, to2, to3};
      final current = <TileOverlay>{to2, to3Changed, to4};
      final updates = TileOverlayUpdates.from(previous, current);

      final toRemove = <TileOverlayId>{const TileOverlayId('id1')};
      expect(updates.tileOverlayIdsToRemove, toRemove);

      final toAdd = <TileOverlay>{to4};
      expect(updates.tileOverlaysToAdd, toAdd);

      final toChange = <TileOverlay>{to3Changed};
      expect(updates.tileOverlaysToChange, toChange);
    });

    test('toJson', () async {
      const to1 = TileOverlay(tileOverlayId: TileOverlayId('id1'));
      const to2 = TileOverlay(tileOverlayId: TileOverlayId('id2'));
      const to3 = TileOverlay(tileOverlayId: TileOverlayId('id3'));
      const to3Changed = TileOverlay(
        tileOverlayId: TileOverlayId('id3'),
        transparency: 0.5,
      );
      const to4 = TileOverlay(tileOverlayId: TileOverlayId('id4'));
      final previous = <TileOverlay>{to1, to2, to3};
      final current = <TileOverlay>{to2, to3Changed, to4};
      final updates = TileOverlayUpdates.from(previous, current);

      final Object json = updates.toJson();
      expect(json, <String, Object>{
        'tileOverlaysToAdd': serializeTileOverlaySet(updates.tileOverlaysToAdd),
        'tileOverlaysToChange': serializeTileOverlaySet(
          updates.tileOverlaysToChange,
        ),
        'tileOverlayIdsToRemove': updates.tileOverlayIdsToRemove
            .map<String>((TileOverlayId m) => m.value)
            .toList(),
      });
    });

    test('equality', () async {
      const to1 = TileOverlay(tileOverlayId: TileOverlayId('id1'));
      const to2 = TileOverlay(tileOverlayId: TileOverlayId('id2'));
      const to3 = TileOverlay(tileOverlayId: TileOverlayId('id3'));
      const to3Changed = TileOverlay(
        tileOverlayId: TileOverlayId('id3'),
        transparency: 0.5,
      );
      const to4 = TileOverlay(tileOverlayId: TileOverlayId('id4'));
      final previous = <TileOverlay>{to1, to2, to3};
      final current1 = <TileOverlay>{to2, to3Changed, to4};
      final current2 = <TileOverlay>{to2, to3Changed, to4};
      final current3 = <TileOverlay>{to2, to4};
      final updates1 = TileOverlayUpdates.from(previous, current1);
      final updates2 = TileOverlayUpdates.from(previous, current2);
      final updates3 = TileOverlayUpdates.from(previous, current3);
      expect(updates1, updates2);
      expect(updates1, isNot(updates3));
    });

    test('hashCode', () async {
      const to1 = TileOverlay(tileOverlayId: TileOverlayId('id1'));
      const to2 = TileOverlay(tileOverlayId: TileOverlayId('id2'));
      const to3 = TileOverlay(tileOverlayId: TileOverlayId('id3'));
      const to3Changed = TileOverlay(
        tileOverlayId: TileOverlayId('id3'),
        transparency: 0.5,
      );
      const to4 = TileOverlay(tileOverlayId: TileOverlayId('id4'));
      final previous = <TileOverlay>{to1, to2, to3};
      final current = <TileOverlay>{to2, to3Changed, to4};
      final updates = TileOverlayUpdates.from(previous, current);
      expect(
        updates.hashCode,
        Object.hash(
          Object.hashAll(updates.tileOverlaysToAdd),
          Object.hashAll(updates.tileOverlayIdsToRemove),
          Object.hashAll(updates.tileOverlaysToChange),
        ),
      );
    });

    test('toString', () async {
      const to1 = TileOverlay(tileOverlayId: TileOverlayId('id1'));
      const to2 = TileOverlay(tileOverlayId: TileOverlayId('id2'));
      const to3 = TileOverlay(tileOverlayId: TileOverlayId('id3'));
      const to3Changed = TileOverlay(
        tileOverlayId: TileOverlayId('id3'),
        transparency: 0.5,
      );
      const to4 = TileOverlay(tileOverlayId: TileOverlayId('id4'));
      final previous = <TileOverlay>{to1, to2, to3};
      final current = <TileOverlay>{to2, to3Changed, to4};
      final updates = TileOverlayUpdates.from(previous, current);
      expect(
        updates.toString(),
        'TileOverlayUpdates(add: ${updates.tileOverlaysToAdd}, '
        'remove: ${updates.tileOverlayIdsToRemove}, '
        'change: ${updates.tileOverlaysToChange})',
      );
    });
  });
}
