// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  group('PointOfInterest', () {
    test('constructor with all named parameters', () {
      const poi = PointOfInterest(
        position: LatLng(10.0, 20.0),
        name: 'Test Name',
        placeId: 'test_id',
      );
      expect(poi.position, const LatLng(10.0, 20.0));
      expect(poi.name, 'Test Name');
      expect(poi.placeId, 'test_id');
    });

    test('constructor with null name (Web support)', () {
      const poi = PointOfInterest(
        position: LatLng(10.0, 20.0),
        placeId: 'test_id',
      );
      expect(poi.name, isNull);
    });

    test('equality', () {
      const poi1 = PointOfInterest(
        position: LatLng(10.0, 20.0),
        name: 'A',
        placeId: 'ID',
      );
      const poi2 = PointOfInterest(
        position: LatLng(10.0, 20.0),
        name: 'A',
        placeId: 'ID',
      );
      const poi3 = PointOfInterest(
        position: LatLng(10.1, 20.0),
        name: 'A',
        placeId: 'ID',
      );

      expect(poi1, poi2);
      expect(poi1, isNot(poi3));
    });

    test('hashCode', () {
      const poi1 = PointOfInterest(
        position: LatLng(10.0, 20.0),
        name: 'A',
        placeId: 'ID',
      );
      const poi2 = PointOfInterest(
        position: LatLng(10.0, 20.0),
        name: 'A',
        placeId: 'ID',
      );

      expect(poi1.hashCode, poi2.hashCode);
    });
  });
}
