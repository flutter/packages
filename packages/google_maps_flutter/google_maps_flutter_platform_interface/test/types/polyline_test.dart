// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart' show Colors;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$Polyline', () {
    test('constructor defaults', () {
      const polyline = Polyline(polylineId: PolylineId('ABC123'));

      expect(polyline.consumeTapEvents, equals(false));
      expect(polyline.color, equals(Colors.black));
      expect(polyline.geodesic, equals(false));
      expect(polyline.visible, equals(true));
      expect(polyline.width, equals(10));
      expect(polyline.zIndex, equals(0));
      expect(polyline.points, equals(const <LatLng>[]));
      expect(polyline.patterns, equals(const <PatternItem>[]));
      expect(polyline.onTap, isNull);
      expect(polyline.editable, equals(false));
      expect(polyline.onEdited, isNull);
    });

    test('construct with editable', () {
      const polyline = Polyline(polylineId: PolylineId('ABC123'), editable: true);

      expect(polyline.editable, equals(true));
    });

    test('toJson includes editable', () {
      const polyline = Polyline(polylineId: PolylineId('ABC123'), editable: true);

      final json = polyline.toJson() as Map<String, Object>;
      expect(json['editable'], equals(true));
    });

    test('toJson excludes editable when false', () {
      const polyline = Polyline(polylineId: PolylineId('ABC123'));

      final json = polyline.toJson() as Map<String, Object>;
      expect(json['editable'], equals(false));
    });

    test('clone', () {
      const polyline = Polyline(polylineId: PolylineId('ABC123'), editable: true);
      final Polyline clone = polyline.clone();

      expect(identical(clone, polyline), isFalse);
      expect(clone, equals(polyline));
      expect(clone.editable, equals(true));
    });

    test('copyWith editable', () {
      const polyline = Polyline(polylineId: PolylineId('ABC123'));
      final Polyline copy = polyline.copyWith(editableParam: true);

      expect(copy.polylineId, equals(const PolylineId('ABC123')));
      expect(copy.editable, equals(true));
    });

    test('copyWith onEdited', () {
      const polyline = Polyline(polylineId: PolylineId('ABC123'));
      final log = <String>[];
      final Polyline copy = polyline.copyWith(
        onEditedParam: (List<LatLng> points) {
          log.add('onEdited');
        },
      );

      copy.onEdited!(<LatLng>[const LatLng(1.0, 2.0)]);
      expect(log, contains('onEdited'));
    });

    test('equality includes editable', () {
      const p1 = Polyline(polylineId: PolylineId('ABC123'));
      const p2 = Polyline(polylineId: PolylineId('ABC123'), editable: true);

      expect(p1, isNot(equals(p2)));
    });

    test('equality ignores onEdited', () {
      final p1 = Polyline(
        polylineId: const PolylineId('ABC123'),
        editable: true,
        onEdited: (List<LatLng> points) {},
      );
      final p2 = Polyline(
        polylineId: const PolylineId('ABC123'),
        editable: true,
        onEdited: (List<LatLng> points) {},
      );

      expect(p1, equals(p2));
    });
  });
}
