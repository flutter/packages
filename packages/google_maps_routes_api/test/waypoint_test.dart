// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_maps_routes_api/src/types/index.dart';
import 'package:test/test.dart';

void main() {
  group('Waypoint', () {
    test('toJson() encodes Waypoint to JSON', () {
      const Waypoint waypoint = Waypoint(
        via: true,
        vehicleStopover: true,
        sideOfRoad: true,
        location: Location(
          latLng: LatLng(37.4165247, -122.0829497),
          heading: 45,
        ),
        placeId: 'ChIJ3Tc00yK6j4ARiu3eO6oqJcs',
      );

      final Map<String, dynamic> expectedJson = <String, dynamic>{
        'via': true,
        'vehicleStopover': true,
        'sideOfRoad': true,
        'location': <String, dynamic>{
          'latLng': <String, dynamic>{
            'latitude': 37.4165247,
            'longitude': -122.0829497,
          },
          'heading': 45,
        },
        'placeId': 'ChIJ3Tc00yK6j4ARiu3eO6oqJcs',
      };

      expect(waypoint.toJson(), equals(expectedJson));
    });
  });
}
