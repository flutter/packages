// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ground overlay updates tests', () {
    test('Correctly set toRemove, toAdd and toChange', () async {
      const GroundOverlay to1 = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id1'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      const GroundOverlay to2 = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id2'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      const GroundOverlay to3 = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id3'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      const GroundOverlay to3Changed = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id3'),
        position: LatLng(32.0, 32.0),
        width: 200,
        opacity: 0.5,
      );
      const GroundOverlay to4 = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id4'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      final Set<GroundOverlay> previous = <GroundOverlay>{to1, to2, to3};
      final Set<GroundOverlay> current = <GroundOverlay>{to2, to3Changed, to4};
      final GroundOverlayUpdates updates =
          GroundOverlayUpdates.from(previous, current);

      final Set<GroundOverlayId> toRemove = <GroundOverlayId>{
        const GroundOverlayId('id1')
      };
      expect(updates.groundOverlayIdsToRemove, toRemove);

      final Set<GroundOverlay> toAdd = <GroundOverlay>{to4};
      expect(updates.groundOverlaysToAdd, toAdd);

      final Set<GroundOverlay> toChange = <GroundOverlay>{to3Changed};
      expect(updates.groundOverlaysToChange, toChange);
    });

    test('toJson', () async {
      const GroundOverlay to1 = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id1'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      const GroundOverlay to2 = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id2'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      const GroundOverlay to3 = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id3'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      const GroundOverlay to3Changed = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id3'),
        position: LatLng(32.0, 32.0),
        width: 200,
        opacity: 0.5,
      );
      const GroundOverlay to4 = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id4'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      final Set<GroundOverlay> previous = <GroundOverlay>{to1, to2, to3};
      final Set<GroundOverlay> current = <GroundOverlay>{to2, to3Changed, to4};
      final GroundOverlayUpdates updates =
          GroundOverlayUpdates.from(previous, current);

      final Object json = updates.toJson();
      expect(json, <String, Object>{
        'groundOverlaysToAdd':
            serializeGroundOverlaySet(updates.groundOverlaysToAdd),
        'groundOverlaysToChange':
            serializeGroundOverlaySet(updates.groundOverlaysToChange),
        'groundOverlayIdsToRemove': updates.groundOverlayIdsToRemove
            .map<String>((GroundOverlayId m) => m.value)
            .toList()
      });
    });

    test('eqaulity', () async {
      const GroundOverlay to1 = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id1'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      const GroundOverlay to2 = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id2'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      const GroundOverlay to3 = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id3'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      const GroundOverlay to3Changed = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id3'),
        position: LatLng(32.0, 32.0),
        width: 200,
        opacity: 0.5,
      );
      const GroundOverlay to4 = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id4'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      final Set<GroundOverlay> previous = <GroundOverlay>{to1, to2, to3};
      final Set<GroundOverlay> current1 = <GroundOverlay>{to2, to3Changed, to4};
      final Set<GroundOverlay> current2 = <GroundOverlay>{to2, to3Changed, to4};
      final Set<GroundOverlay> current3 = <GroundOverlay>{to2, to4};
      final GroundOverlayUpdates updates1 =
          GroundOverlayUpdates.from(previous, current1);
      final GroundOverlayUpdates updates2 =
          GroundOverlayUpdates.from(previous, current2);
      final GroundOverlayUpdates updates3 =
          GroundOverlayUpdates.from(previous, current3);

      expect(updates1, updates2);
      expect(updates1, isNot(updates3));
    });

    test('hashCode', () async {
      const GroundOverlay to1 = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id1'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      const GroundOverlay to2 = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id2'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      const GroundOverlay to3 = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id3'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      const GroundOverlay to3Changed = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id3'),
        position: LatLng(32.0, 32.0),
        width: 200,
        opacity: 0.5,
      );
      const GroundOverlay to4 = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id4'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      final Set<GroundOverlay> previous = <GroundOverlay>{to1, to2, to3};
      final Set<GroundOverlay> current = <GroundOverlay>{to2, to3Changed, to4};
      final GroundOverlayUpdates updates =
          GroundOverlayUpdates.from(previous, current);

      expect(updates.hashCode, equals(updates.hashCode));
    });

    test('toString', () async {
      const GroundOverlay to1 = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id1'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      const GroundOverlay to2 = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id2'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      const GroundOverlay to3 = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id3'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      const GroundOverlay to3Changed = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id3'),
        position: LatLng(32.0, 32.0),
        width: 200,
        opacity: 0.5,
      );
      const GroundOverlay to4 = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id4'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      final Set<GroundOverlay> previous = <GroundOverlay>{to1, to2, to3};
      final Set<GroundOverlay> current = <GroundOverlay>{to2, to3Changed, to4};
      final GroundOverlayUpdates updates =
          GroundOverlayUpdates.from(previous, current);

      expect(
          updates.toString(),
          'GroundOverlayUpdates(add: ${updates.groundOverlaysToAdd}, '
          'remove: ${updates.groundOverlayIdsToRemove}, '
          'change: ${updates.groundOverlaysToChange})');
    });
  });
}
