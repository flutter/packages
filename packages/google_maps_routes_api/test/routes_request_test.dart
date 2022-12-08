// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_maps_routes_api/src/types/index.dart';
import 'package:test/test.dart';

void main() {
  group('ComputeRoutesRequest', () {
    test('toJson() encodes ComputeRoutesRequest to JSON', () {
      final ComputeRoutesRequest request = ComputeRoutesRequest(
        origin: const Waypoint(
          location: Location(
            latLng: LatLng(0.0, 0.0),
          ),
        ),
        destination: const Waypoint(
          location: Location(
            latLng: LatLng(1.0, 1.0),
          ),
        ),
        intermediates: <Waypoint>[
          const Waypoint(
            location: Location(
              latLng: LatLng(2.0, 2.0),
            ),
          ),
          const Waypoint(
            location: Location(
              latLng: LatLng(3.0, 3.0),
            ),
          ),
        ],
        travelMode: RouteTravelMode.DRIVE,
        routingPreference: RoutingPreference.TRAFFIC_AWARE,
        polylineQuality: PolylineQuality.HIGH_QUALITY,
        polylineEncoding: PolylineEncoding.ENCODED_POLYLINE,
        departureTime: '2020-01-01T00:00:00Z',
        computeAlternativeRoutes: true,
        routeModifiers: const RouteModifiers(
          avoidFerries: true,
          avoidHighways: true,
          avoidTolls: true,
        ),
        languageCode: 'en-US',
        units: Units.METRIC,
        requestedReferenceRoutes: ReferenceRoute.FUEL_EFFICIENT,
      );

      final Map<String, dynamic> expectedJson = <String, dynamic>{
        'origin': <String, dynamic>{
          'location': <String, dynamic>{
            'latLng': <String, double>{
              'latitude': 0.0,
              'longitude': 0.0,
            }
          }
        },
        'destination': <String, dynamic>{
          'location': <String, dynamic>{
            'latLng': <String, double>{
              'latitude': 1.0,
              'longitude': 1.0,
            }
          }
        },
        'intermediates': <Map<String, dynamic>>[
          <String, dynamic>{
            'location': <String, dynamic>{
              'latLng': <String, double>{
                'latitude': 2.0,
                'longitude': 2.0,
              }
            }
          },
          <String, dynamic>{
            'location': <String, dynamic>{
              'latLng': <String, double>{
                'latitude': 3.0,
                'longitude': 3.0,
              }
            }
          },
        ],
        'travelMode': 'DRIVE',
        'routingPreference': 'TRAFFIC_AWARE',
        'polylineQuality': 'HIGH_QUALITY',
        'polylineEncoding': 'ENCODED_POLYLINE',
        'departureTime': '2020-01-01T00:00:00Z',
        'computeAlternativeRoutes': true,
        'routeModifiers': <String, dynamic>{
          'avoidFerries': true,
          'avoidHighways': true,
          'avoidTolls': true,
        },
        'languageCode': 'en-US',
        'units': 'METRIC',
        'requestedReferenceRoutes': 'FUEL_EFFICIENT',
      };

      expect(request.toJson(), equals(expectedJson));
    });
  });
}
