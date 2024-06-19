// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_platform_interface/src/types/types.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ground overlay id tests', () {
    test('equality', () async {
      const GroundOverlayId id1 = GroundOverlayId('1');
      const GroundOverlayId id2 = GroundOverlayId('1');
      const GroundOverlayId id3 = GroundOverlayId('2');
      expect(id1, id2);
      expect(id1, isNot(id3));
    });

    test('toString', () async {
      const GroundOverlayId id1 = GroundOverlayId('1');
      expect(id1.toString(), 'GroundOverlayId(1)');
    });
  });

  group('ground overlay tests', () {
    test('GroundOverlay.fromPosition toJson returns correct format', () async {
      const GroundOverlay groundOverlay = GroundOverlay.fromPosition(
        groundOverlayId: GroundOverlayId('id'),
        position: LatLng(32.0, 32.0),
        width: 200,
      );
      final Object json = groundOverlay.toJson();
      expect(json, <String, Object>{
        'groundOverlayId': 'id',
        'clickable': false,
        'transparency': 0.0,
        'bearing': 0.0,
        'visible': true,
        'zIndex': 0,
        'anchor': <double>[0.0, 0.0],
        'width': 200.0,
        'position': <double>[32.0, 32.0]
      });

      final GroundOverlay groundOverlayAllOptions = GroundOverlay.fromPosition(
        groundOverlayId: const GroundOverlayId('id'),
        position: const LatLng(32.0, 32.0),
        width: 200,
        height: 100,
        clickable: true,
        zIndex: 2,
        onTap: () {},
        visible: false,
        bitmap: BitmapDescriptor.defaultMarker,
        bearing: 1.0,
        anchor: const Offset(0.5, 0.5),
        opacity: 0.7,
      );
      final Object jsonAllOptions = groundOverlayAllOptions.toJson();
      expect(jsonAllOptions, <String, Object>{
        'groundOverlayId': 'id',
        'clickable': true,
        'transparency': 0.30000000000000004,
        'bearing': 1.0,
        'visible': false,
        'zIndex': 2,
        'height': 100.0,
        'anchor': <double>[0.5, 0.5],
        'bitmap': <String>['defaultMarker'],
        'width': 200.0,
        'position': <double>[32.0, 32.0]
      });
    });

    test('GroundOverlay.fromBounds toJson returns correct format', () async {
      final GroundOverlay groundOverlay = GroundOverlay.fromBounds(
        LatLngBounds(
          southwest: const LatLng(32.0, 33.0),
          northeast: const LatLng(33.0, 32.0),
        ),
        groundOverlayId: const GroundOverlayId('id'),
      );
      final Object json = groundOverlay.toJson();
      expect(json, <String, Object>{
        'groundOverlayId': 'id',
        'clickable': false,
        'transparency': 0.0,
        'bearing': 0.0,
        'visible': true,
        'zIndex': 0,
        'anchor': <double>[0.0, 0.0],
        'bounds': <Object>[
          <double>[32.0, 33.0],
          <double>[33.0, 32.0],
        ]
      });
    });

    test('invalid opacity throws', () async {
      expect(
        () => GroundOverlay.fromPosition(
          position: const LatLng(32.0, 32.0),
          width: 200,
          groundOverlayId: const GroundOverlayId('id1'),
          opacity: -0.1,
        ),
        throwsAssertionError,
      );
      expect(
        () => GroundOverlay.fromPosition(
          position: const LatLng(32.0, 32.0),
          width: 200,
          groundOverlayId: const GroundOverlayId('id2'),
          opacity: 1.2,
        ),
        throwsAssertionError,
      );
    });

    test('equality', () async {
      const GroundOverlay groundOverlay1 = GroundOverlay.fromPosition(
        position: LatLng(32.0, 32.0),
        width: 200,
        groundOverlayId: GroundOverlayId('idEquality1'),
        opacity: 0.5,
      );
      const GroundOverlay groundOverlay2 = GroundOverlay.fromPosition(
        position: LatLng(32.0, 32.0),
        width: 200,
        groundOverlayId: GroundOverlayId('idEquality1'),
        opacity: 0.5,
      );
      const GroundOverlay groundOverlay3 = GroundOverlay.fromPosition(
        position: LatLng(33.0, 33.0),
        width: 300,
        groundOverlayId: GroundOverlayId('idEquality2'),
        opacity: 0.7,
      );

      expect(groundOverlay1, equals(groundOverlay2));
      expect(groundOverlay1, isNot(equals(groundOverlay3)));
    });

    test('clone', () {
      const GroundOverlay original = GroundOverlay.fromPosition(
        position: LatLng(32.0, 32.0),
        width: 200,
        groundOverlayId: GroundOverlayId('idClone'),
        opacity: 0.5,
      );
      final GroundOverlay clone = original.clone();

      // Check if the clone is equal to the original
      expect(clone, equals(original));
      // Check if the clone is not the same instance as the original
      expect(identical(clone, original), isFalse);
    });

    test('hashCode', () {
      const GroundOverlay groundOverlay1 = GroundOverlay.fromPosition(
        position: LatLng(32.0, 32.0),
        width: 200,
        groundOverlayId: GroundOverlayId('idHashCode'),
        opacity: 0.5,
      );
      const GroundOverlay groundOverlay2 = GroundOverlay.fromPosition(
        position: LatLng(32.0, 32.0),
        width: 200,
        groundOverlayId: GroundOverlayId('idHashCode'),
        opacity: 0.5,
      );
      const GroundOverlay groundOverlay3 = GroundOverlay.fromPosition(
        position: LatLng(33.0, 33.0),
        width: 300,
        groundOverlayId: GroundOverlayId('idDifferent'),
        opacity: 0.7,
      );

      expect(groundOverlay1.hashCode, equals(groundOverlay2.hashCode));
      expect(groundOverlay1.hashCode, isNot(equals(groundOverlay3.hashCode)));
      expect(groundOverlay1.hashCode, equals(groundOverlay1.hashCode));
    });
  });
}
