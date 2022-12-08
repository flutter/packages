// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_maps_routes_api/src/types/location.dart';
import 'package:google_maps_routes_api/src/types/polyline.dart';
import 'package:test/test.dart';

void main() {
  group('Polyline', () {
    test('fromJson() correctly decodes a JSON object to a Polyline', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'encodedPolyline': 'encoded_polyline_string',
        'geoJsonLinestring': <String, dynamic>{
          'type': 'LineString',
          'coordinates': <List<double>>[
            <double>[37.4224764, -122.0842499],
            <double>[37.4223456, -122.0845678],
          ],
        },
      };

      final Polyline? polyline = Polyline.fromJson(json);
      expect(polyline?.encodedPolyline, equals('encoded_polyline_string'));
      expect(polyline?.geoJsonLinestring, isA<GeoJsonLinestring>());
    });

    test('toJson() correctly encodes a Polyline to a JSON object', () {
      const Polyline polyline = Polyline(
        encodedPolyline: 'encoded_polyline_string',
        geoJsonLinestring: GeoJsonLinestring(
          type: 'LineString',
          coordinates: <LatLng>[
            LatLng(37.4224764, -122.0842499),
            LatLng(37.4223456, -122.0845678),
          ],
        ),
      );

      final Map<String, dynamic> expectedJson = <String, dynamic>{
        'encodedPolyline': 'encoded_polyline_string',
        'geoJsonLinestring': <String, dynamic>{
          'type': 'LineString',
          'coordinates': <List<double>>[
            <double>[-122.0842499, 37.4224764],
            <double>[-122.0845678, 37.4223456],
          ],
        },
      };

      expect(polyline.toJson(), equals(expectedJson));
    });
  });
  group('geoJsonLinestring', () {
    test('fromJson() correctly decodes a JSON object to a Polyline', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'encodedPolyline': 'encoded_polyline_string',
        'geoJsonLinestring': <String, dynamic>{
          'type': 'LineString',
          'coordinates': <List<double>>[
            <double>[-122.0842499, 37.4224764],
            <double>[-122.0845678, 37.4223456],
          ],
        },
      };

      final Polyline? polyline = Polyline.fromJson(json);
      expect(polyline?.encodedPolyline, equals('encoded_polyline_string'));
      expect(polyline?.geoJsonLinestring, isA<GeoJsonLinestring>());
    });

    test('toJson() correctly encodes a Polyline to a JSON object', () {
      const Polyline polyline = Polyline(
        encodedPolyline: 'encoded_polyline_string',
        geoJsonLinestring: GeoJsonLinestring(
          type: 'LineString',
          coordinates: <LatLng>[
            LatLng(37.4224764, -122.0842499),
            LatLng(37.4223456, -122.0845678),
          ],
        ),
      );

      final Map<String, dynamic> expectedJson = <String, dynamic>{
        'encodedPolyline': 'encoded_polyline_string',
        'geoJsonLinestring': <String, dynamic>{
          'type': 'LineString',
          'coordinates': <List<double>>[
            <double>[-122.0842499, 37.4224764],
            <double>[-122.0845678, 37.4223456],
          ],
        },
      };

      expect(polyline.toJson(), equals(expectedJson));
    });
  });
}
