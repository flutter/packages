// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library google_maps_routes_api;

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'src/types/index.dart';
export 'src/types/index.dart';

/// A service used to calculate routes and route matrixes using
/// Google Routes API REST endpoints.
class RoutesService {
  /// Creates the [RoutesService].
  RoutesService({required this.apiKey});

  /// HTTP client for making the requests.
  http.Client client = http.Client();

  /// Google API key used for the requests.
  final String apiKey;

  static const String _routesApiUrl = 'https://routes.googleapis.com/';

  /// Calculates a primary [Route] along with optional alternate routes, given a
  /// set of terminal and intermediate [Waypoint] objects.
  ///
  /// POST https://routes.googleapis.com/directions/v2:computeRoutes
  ///
  /// You can provide the response field mask by using the [fields] parameter.
  ///
  /// Default field mask if no [fields] are given is:
  /// 'routes.duration, routes.distanceMeters'
  ///
  /// You can also provide additional [headers] and [queryParams] for the
  /// request.
  ///
  /// See the available URL query params and headers:
  /// https://cloud.google.com/apis/docs/system-parameters
  ///
  /// Detailed documentation about how to construct the field paths:
  /// https://github.com/protocolbuffers/protobuf/blob/main/src/google/protobuf/field_mask.proto
  Future<ComputeRoutesResponse> computeRoute(
    ComputeRoutesRequest body, {
    String? fields,
    Map<String, String>? headers,
    List<String>? queryParams,
  }) async {
    try {
      String url = '$_routesApiUrl/directions/v2:computeRoutes';
      if (queryParams != null && queryParams.isNotEmpty) {
        url += '?${queryParams.join("&")}';
      }
      final Map<String, String> defaultHeaders = <String, String>{
        'X-Goog-Api-Key': apiKey,
        'X-Goog-Fieldmask': fields ?? 'routes.duration, routes.distanceMeters',
        'Content-Type': 'application/json',
      };

      final http.Response response = await client.post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: <String, String>{...defaultHeaders, ...?headers},
      );

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      final ComputeRoutesResponse? result =
          ComputeRoutesResponse.fromJson(json.decode(response.body));
      return Future<ComputeRoutesResponse>.value(result);
    } catch (error) {
      rethrow;
    }
  }

  /// Computes a route matrix for a given set of origins and destinations.
  ///
  /// POST https://routes.googleapis.com/distanceMatrix/v2:computeRouteMatrix
  ///
  /// You can provide the response field mask by using the [fields] parameter.
  ///
  /// Default field mask if no [fields] are given is:
  /// 'duration, distanceMeters'
  ///
  /// You can also provide additional [headers] and [queryParams] for the
  /// request.
  ///
  /// See the available URL query params and headers:
  /// https://cloud.google.com/apis/docs/system-parameters
  ///
  /// Detailed documentation about how to construct the field paths:
  /// https://github.com/protocolbuffers/protobuf/blob/main/src/google/protobuf/field_mask.proto
  Future<List<RouteMatrixElement>> computeRouteMatrix(
    ComputeRouteMatrixRequest body, {
    String? fields,
    Map<String, String>? headers,
    List<String>? queryParams,
  }) async {
    try {
      String url = '$_routesApiUrl/distanceMatrix/v2:computeRouteMatrix';

      if (queryParams != null && queryParams.isNotEmpty) {
        url += '?${queryParams.join("&")}';
      }

      final Map<String, String> defaultHeaders = <String, String>{
        'X-Goog-Api-Key': apiKey,
        'X-Goog-Fieldmask': fields ?? 'duration, distanceMeters',
        'Content-Type': 'application/json',
      };

      final http.Response response = await client.post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: <String, String>{...defaultHeaders, ...?headers},
      );

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }

      final List<RouteMatrixElement> result = List<RouteMatrixElement>.from(
        (json.decode(response.body) as List<dynamic>).map(
          (dynamic model) => RouteMatrixElement.fromJson(model),
        ),
      );
      return Future<List<RouteMatrixElement>>.value(result);
    } catch (error) {
      rethrow;
    }
  }
}
