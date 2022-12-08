// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:google_maps_routes_api/google_maps_routes_api.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('computeRoutes', () {
    final RoutesService routesService = RoutesService(apiKey: '12345');
    const Waypoint origin = Waypoint(
      location: Location(
        latLng: LatLng(37.419734, -122.0827784),
      ),
    );
    const Waypoint destination = Waypoint(
      location: Location(
        latLng: LatLng(37.417670, -122.079595),
      ),
    );
    final ComputeRoutesRequest body = ComputeRoutesRequest(
      origin: origin,
      destination: destination,
      travelMode: RouteTravelMode.DRIVE,
      polylineEncoding: PolylineEncoding.GEO_JSON_LINESTRING,
    );
    setUp(() {
      routesService.client = MockClient((Request request) async {
        final File jsonFile =
            File('test/mocks/mock_compute_routes_response.json');
        final String jsonString = await jsonFile.readAsString();
        return Response(jsonString, 200);
      });
    });

    test('correctly fetches and parses JSON response', () async {
      final ComputeRoutesResponse response =
          await routesService.computeRoute(body);

      final File jsonFile =
          File('test/mocks/mock_compute_routes_response.json');
      final String expectedJson = await jsonFile.readAsString();
      expect(response.toJson(), equals(json.decode(expectedJson)));
    });

    test('throws an exception when status != 200', () async {
      routesService.client = MockClient((Request request) async {
        final Map<String, dynamic> error = <String, dynamic>{
          'error': <String, dynamic>{
            'code': 400,
            'message': 'Invalid JSON payload received. Unexpected token.',
            'status': 'INVALID_ARGUMENT'
          }
        };

        return Response(json.encode(error), 400);
      });

      expect(routesService.computeRoute(body), throwsA(isA<Exception>()));
    });

    test('correctly uses default fieldmask and headers', () async {
      routesService.client = MockClient((Request request) async {
        expect(
            request.headers,
            equals(<String, String>{
              'X-Goog-Api-Key': '12345',
              'X-Goog-Fieldmask': 'routes.duration, routes.distanceMeters',
              'Content-Type': 'application/json; charset=utf-8'
            }));
        final File jsonFile =
            File('test/mocks/mock_compute_routes_response.json');
        final String jsonString = await jsonFile.readAsString();
        return Response(jsonString, 200);
      });

      await routesService.computeRoute(body);
    });

    test('correctly overrides fieldmask and adds additional headers', () async {
      const String fields =
          'routes.legs,routes.duration,routes.distanceMeters,routes.polyline,routes.warnings,routes.description,routes.viewport,routes.routeLabels';

      final Map<String, String> headers = <String, String>{
        'X-Goog-Request-Reason': 'test'
      };

      routesService.client = MockClient((Request request) async {
        expect(
            request.headers,
            equals(<String, String>{
              'X-Goog-Api-Key': '12345',
              'X-Goog-Fieldmask':
                  'routes.legs,routes.duration,routes.distanceMeters,routes.polyline,routes.warnings,routes.description,routes.viewport,routes.routeLabels',
              'Content-Type': 'application/json; charset=utf-8',
              'X-Goog-Request-Reason': 'test'
            }));
        final File jsonFile =
            File('test/mocks/mock_compute_routes_response.json');
        final String jsonString = await jsonFile.readAsString();
        return Response(jsonString, 200);
      });

      await routesService.computeRoute(body, fields: fields, headers: headers);
    });
  });

  group('computeRouteMatrix', () {
    final RoutesService routesService = RoutesService(apiKey: '12345');
    final List<RouteMatrixOrigin> origins = <RouteMatrixOrigin>[
      RouteMatrixOrigin(
        waypoint: const Waypoint(
          location: Location(
            latLng: LatLng(37.420761, -122.081356),
          ),
        ),
      ),
      RouteMatrixOrigin(
        waypoint: const Waypoint(
          location: Location(
            latLng: LatLng(37.403184, -122.097371),
          ),
        ),
      ),
    ];
    final List<RouteMatrixDestination> destinations = <RouteMatrixDestination>[
      RouteMatrixDestination(
        waypoint: const Waypoint(
          location: Location(
            latLng: LatLng(37.420761, -122.081356),
          ),
        ),
      ),
      RouteMatrixDestination(
        waypoint: const Waypoint(
          location: Location(
            latLng: LatLng(37.383047, -122.044651),
          ),
        ),
      ),
    ];

    final ComputeRouteMatrixRequest body = ComputeRouteMatrixRequest(
      origins: origins,
      destinations: destinations,
      travelMode: RouteTravelMode.DRIVE,
      routingPreference: RoutingPreference.TRAFFIC_AWARE,
    );

    setUp(() {
      routesService.client = MockClient((Request request) async {
        final File jsonFile =
            File('test/mocks/mock_compute_route_matrix_response.json');
        final String jsonString = await jsonFile.readAsString();
        return Response(jsonString, 200);
      });
    });
    test('correctly fetches and parses JSON response', () async {
      final File jsonFile =
          File('test/mocks/mock_compute_route_matrix_response.json');
      final String expectedJson = await jsonFile.readAsString();

      final List<RouteMatrixElement> response =
          await routesService.computeRouteMatrix(body);

      expect(response.map((RouteMatrixElement matrix) => matrix.toJson()),
          equals(json.decode(expectedJson)));
    });

    test('throws an exception when status != 200', () async {
      routesService.client = MockClient((Request request) async {
        final Map<String, dynamic> error = <String, dynamic>{
          'error': <String, dynamic>{
            'code': 400,
            'message': 'Invalid JSON payload received. Unexpected token.',
            'status': 'INVALID_ARGUMENT'
          }
        };

        return Response(json.encode(error), 400);
      });

      expect(routesService.computeRouteMatrix(body), throwsA(isA<Exception>()));
    });

    test('correctly uses default fieldmask and headers', () async {
      routesService.client = MockClient((Request request) async {
        expect(
            request.headers,
            equals(<String, String>{
              'X-Goog-Api-Key': '12345',
              'X-Goog-Fieldmask': 'duration, distanceMeters',
              'Content-Type': 'application/json; charset=utf-8'
            }));
        final File jsonFile =
            File('test/mocks/mock_compute_route_matrix_response.json');
        final String jsonString = await jsonFile.readAsString();
        return Response(jsonString, 200);
      });

      await routesService.computeRouteMatrix(body);
    });

    test('correctly overrides fieldmask and adds additional headers', () async {
      const String fields =
          'originIndex,destinationIndex,duration,distanceMeters,status,condition';

      final Map<String, String> headers = <String, String>{
        'X-Goog-Request-Reason': 'test'
      };

      routesService.client = MockClient((Request request) async {
        expect(
            request.headers,
            equals(<String, String>{
              'X-Goog-Api-Key': '12345',
              'X-Goog-Fieldmask':
                  'originIndex,destinationIndex,duration,distanceMeters,status,condition',
              'Content-Type': 'application/json; charset=utf-8',
              'X-Goog-Request-Reason': 'test'
            }));
        final File jsonFile =
            File('test/mocks/mock_compute_route_matrix_response.json');
        final String jsonString = await jsonFile.readAsString();
        return Response(jsonString, 200);
      });

      await routesService.computeRouteMatrix(body,
          fields: fields, headers: headers);
    });
  });
}
