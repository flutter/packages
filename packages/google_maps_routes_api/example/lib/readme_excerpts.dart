// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs, unused_local_variable, avoid_void_async

// #docregion SampleUsage

import 'package:google_maps_routes_api/google_maps_routes_api.dart';

final RoutesService routesService = RoutesService(apiKey: 'GOOGLE_API_KEY');

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
);
// #enddocregion SampleUsage
void main() {}

void customFieldmask() async {
// #docregion CustomFieldmask

  const String fields =
      'status,originIndex,destinationIndex,condition,distanceMeters,duration';

  final ComputeRoutesResponse response =
      await routesService.computeRoute(body, fields: fields);
// #enddocregion CustomFieldmask
}

void customHeaders() async {
// #docregion CustomHeaders

  final Map<String, String> headers = <String, String>{
    'X-Goog-Fieldmask':
        'status,originIndex,destinationIndex,condition,distanceMeters,duration'
  };

  final ComputeRoutesResponse response =
      await routesService.computeRoute(body, headers: headers);
// #enddocregion CustomHeaders
}

void computeRoute() async {
// #docregion SampleUsage

  final ComputeRoutesResponse response = await routesService.computeRoute(body);
// #enddocregion SampleUsage
}
