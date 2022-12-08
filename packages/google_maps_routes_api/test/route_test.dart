// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:google_maps_routes_api/src/types/index.dart';
import 'package:test/test.dart';

void main() {
  group('Route', () {
    test('fromJson() correctly decodes JSON', () async {
      final File jsonFile = File('test/mocks/route.json');
      final String jsonString = await jsonFile.readAsString();
      final Route? route = Route.fromJson(json.decode(jsonString));

      expect(route?.distanceMeters, 773);
      expect(route?.routeLabels, <RouteLabel>[RouteLabel.DEFAULT_ROUTE]);
      expect(route?.duration, '149s');
      expect(route?.staticDuration, '149s');
      expect(route?.polyline?.geoJsonLinestring?.coordinates.length, 6);
      expect(route?.description, 'Huff Ave and Plymouth St');
      expect(route?.viewport, isA<Viewport>());
      expect(route?.legs?.length, 1);
      expect(route?.legs?.first, isA<RouteLeg>());
    });

    test('toJson() correctly encodes Route to JSON', () async {
      const Route route = Route(
        distanceMeters: 773,
        duration: '149s',
        staticDuration: '149s',
        description: 'Huff Ave and Plymouth St',
        routeLabels: <RouteLabel>[RouteLabel.DEFAULT_ROUTE],
      );

      // Load expected JSON
      final File jsonFile = File('test/mocks/expected_route.json');
      final String expectedJson = await jsonFile.readAsString();

      expect(route.toJson(), json.decode(expectedJson));
    });
  });
  group('Viewport', () {
    test('fromJson() correctly decodes JSON', () async {
      final Map<String, dynamic> jsonData = <String, dynamic>{
        'low': <String, dynamic>{
          'latitude': 37.4165247,
          'longitude': -122.0829497,
        },
        'high': <String, dynamic>{
          'latitude': 37.419733799999996,
          'longitude': -122.07938779999999,
        }
      };
      final Viewport? viewport = Viewport.fromJson(jsonData);

      expect(viewport?.low.latitude, 37.4165247);
      expect(viewport?.low.longitude, -122.0829497);
      expect(viewport?.high.latitude, 37.419733799999996);
      expect(viewport?.high.longitude, -122.07938779999999);
    });

    test('toJson() correctly encodes Viewport to JSON', () async {
      const Viewport viewport = Viewport(
        low: LatLng(37.4165247, -122.0829497),
        high: LatLng(37.419733799999996, -122.07938779999999),
      );

      final Map<String, dynamic> expectedJson = <String, dynamic>{
        'low': <String, dynamic>{
          'latitude': 37.4165247,
          'longitude': -122.0829497,
        },
        'high': <String, dynamic>{
          'latitude': 37.419733799999996,
          'longitude': -122.07938779999999,
        }
      };

      // Convert Viewport to JSON and compare it to the expected JSON.
      expect(viewport.toJson(), expectedJson);
    });
  });
}
