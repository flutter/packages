// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_platform_interface/src/types/utils/map_configuration_serialization.dart';

const String _kMapId = '000000000000000'; // Dummy map ID.

void main() {
  test('empty serialization', () async {
    const MapConfiguration config = MapConfiguration();

    final Map<String, Object> json = jsonForMapConfiguration(config);

    expect(json.isEmpty, true);
  });

  test('complete serialization', () async {
    final MapConfiguration config = MapConfiguration(
      compassEnabled: false,
      mapToolbarEnabled: false,
      cameraTargetBounds: CameraTargetBounds(
        LatLngBounds(
          northeast: const LatLng(30, 20),
          southwest: const LatLng(10, 40),
        ),
      ),
      mapType: MapType.normal,
      minMaxZoomPreference: const MinMaxZoomPreference(1.0, 10.0),
      rotateGesturesEnabled: false,
      scrollGesturesEnabled: false,
      tiltGesturesEnabled: false,
      trackCameraPosition: false,
      zoomControlsEnabled: false,
      zoomGesturesEnabled: false,
      liteModeEnabled: false,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      padding: const EdgeInsets.all(5.0),
      indoorViewEnabled: false,
      trafficEnabled: false,
      buildingsEnabled: false,
      mapId: _kMapId,
      cloudMapId: _kMapId,
    );

    final Map<String, Object> json = jsonForMapConfiguration(config);

    // This uses literals instead of toJson() for the expectations on
    // sub-objects, because if the serialization of any of those objects were
    // ever to change MapConfiguration would need to update to serialize those
    // objects manually to preserve the format, in order to avoid breaking
    // implementations.
    expect(json, <String, Object>{
      'compassEnabled': false,
      'mapToolbarEnabled': false,
      'cameraTargetBounds': <Object>[
        <Object>[
          <double>[10.0, 40.0],
          <double>[30.0, 20.0],
        ],
      ],
      'mapType': 1,
      'minMaxZoomPreference': <double>[1.0, 10.0],
      'rotateGesturesEnabled': false,
      'scrollGesturesEnabled': false,
      'tiltGesturesEnabled': false,
      'zoomControlsEnabled': false,
      'zoomGesturesEnabled': false,
      'liteModeEnabled': false,
      'trackCameraPosition': false,
      'myLocationEnabled': false,
      'myLocationButtonEnabled': false,
      'padding': <double>[5.0, 5.0, 5.0, 5.0],
      'indoorEnabled': false,
      'trafficEnabled': false,
      'buildingsEnabled': false,
      'mapId': _kMapId,
      'cloudMapId': _kMapId,
    });
  });

  test('mapId preferred over cloudMapId', () {
    const MapConfiguration config = MapConfiguration(
      mapId: 'map-id',
      cloudMapId: 'cloud-map-id',
    );
    final Map<String, Object> json = jsonForMapConfiguration(config);
    expect(json, <String, Object>{'mapId': 'map-id', 'cloudMapId': 'map-id'});
  });

  test('mapId falls back to cloudMapId', () {
    const MapConfiguration config = MapConfiguration(
      cloudMapId: 'cloud-map-id',
    );
    final Map<String, Object> json = jsonForMapConfiguration(config);
    expect(json, <String, Object>{
      'mapId': 'cloud-map-id',
      'cloudMapId': 'cloud-map-id',
    });
  });
}
