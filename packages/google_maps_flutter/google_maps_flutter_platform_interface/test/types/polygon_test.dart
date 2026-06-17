// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart' show Colors;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$Polygon', () {
    test('constructor defaults', () {
      const polygon = Polygon(polygonId: PolygonId('ABC123'));

      expect(polygon.consumeTapEvents, equals(false));
      expect(polygon.fillColor, equals(Colors.black));
      expect(polygon.geodesic, equals(false));
      expect(polygon.visible, equals(true));
      expect(polygon.strokeWidth, equals(10));
      expect(polygon.zIndex, equals(0));
      expect(polygon.points, equals(const <LatLng>[]));
      expect(polygon.holes, equals(const <List<LatLng>>[]));
      expect(polygon.onTap, isNull);
      expect(polygon.editable, equals(false));
      expect(polygon.onEdited, isNull);
    });

    test('construct with editable', () {
      const polygon = Polygon(polygonId: PolygonId('ABC123'), editable: true);

      expect(polygon.editable, equals(true));
    });

    test('toJson includes editable', () {
      const polygon = Polygon(polygonId: PolygonId('ABC123'), editable: true);

      final json = polygon.toJson() as Map<String, Object>;
      expect(json['editable'], equals(true));
    });

    test('clone', () {
      const polygon = Polygon(polygonId: PolygonId('ABC123'), editable: true);
      final Polygon clone = polygon.clone();

      expect(identical(clone, polygon), isFalse);
      expect(clone, equals(polygon));
      expect(clone.editable, equals(true));
    });

    test('copyWith editable', () {
      const polygon = Polygon(polygonId: PolygonId('ABC123'));
      final Polygon copy = polygon.copyWith(editableParam: true);

      expect(copy.polygonId, equals(const PolygonId('ABC123')));
      expect(copy.editable, equals(true));
    });

    test('copyWith onEdited', () {
      const polygon = Polygon(polygonId: PolygonId('ABC123'));
      final log = <String>[];
      final Polygon copy = polygon.copyWith(
        onEditedParam: (List<LatLng> points, List<List<LatLng>> holes) {
          log.add('onEdited');
        },
      );

      copy.onEdited!(<LatLng>[const LatLng(1.0, 2.0)], <List<LatLng>>[]);
      expect(log, contains('onEdited'));
    });

    test('onEdited callback receives holes', () {
      List<LatLng>? receivedPoints;
      List<List<LatLng>>? receivedHoles;
      final polygon = Polygon(
        polygonId: const PolygonId('ABC123'),
        editable: true,
        onEdited: (List<LatLng> points, List<List<LatLng>> holes) {
          receivedPoints = points;
          receivedHoles = holes;
        },
      );

      final testPoints = <LatLng>[const LatLng(0, 0), const LatLng(1, 1), const LatLng(0, 1)];
      final testHoles = <List<LatLng>>[
        <LatLng>[const LatLng(0.2, 0.2), const LatLng(0.4, 0.4), const LatLng(0.2, 0.4)],
      ];

      polygon.onEdited!(testPoints, testHoles);

      expect(receivedPoints, equals(testPoints));
      expect(receivedHoles, equals(testHoles));
    });

    test('equality includes editable', () {
      const p1 = Polygon(polygonId: PolygonId('ABC123'));
      const p2 = Polygon(polygonId: PolygonId('ABC123'), editable: true);

      expect(p1, isNot(equals(p2)));
    });

    test('equality ignores onEdited', () {
      final p1 = Polygon(
        polygonId: const PolygonId('ABC123'),
        editable: true,
        onEdited: (List<LatLng> points, List<List<LatLng>> holes) {},
      );
      final p2 = Polygon(
        polygonId: const PolygonId('ABC123'),
        editable: true,
        onEdited: (List<LatLng> points, List<List<LatLng>> holes) {},
      );

      expect(p1, equals(p2));
    });
  });
}
