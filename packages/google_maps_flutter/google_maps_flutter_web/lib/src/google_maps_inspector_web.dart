// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

/// Function that gets the [MapConfiguration] for a given `mapId`.
typedef ConfigurationProvider = MapConfiguration Function(int mapId);

/// This platform implementation allows inspecting the running maps.
class GoogleMapsInspectorWeb extends GoogleMapsInspectorPlatform {
  /// Build an "inspector" that is able to look into maps.
  GoogleMapsInspectorWeb(ConfigurationProvider configurationProvider)
      : _configurationProvider = configurationProvider;

  final ConfigurationProvider _configurationProvider;

  @override
  Future<bool> areBuildingsEnabled({required int mapId}) async {
    return false; // Not supported on the web
  }

  @override
  Future<bool> areRotateGesturesEnabled({required int mapId}) async {
    return false; // Not supported on the web
  }

  @override
  Future<bool> areScrollGesturesEnabled({required int mapId}) async {
    return _configurationProvider(mapId).scrollGesturesEnabled ?? false;
  }

  @override
  Future<bool> areTiltGesturesEnabled({required int mapId}) async {
    return false; // Not supported on the web
  }

  @override
  Future<bool> areZoomControlsEnabled({required int mapId}) async {
    return _configurationProvider(mapId).zoomControlsEnabled ?? false;
  }

  @override
  Future<bool> areZoomGesturesEnabled({required int mapId}) async {
    return _configurationProvider(mapId).zoomGesturesEnabled ?? false;
  }

  @override
  Future<MinMaxZoomPreference> getMinMaxZoomLevels({required int mapId}) async {
    final MapConfiguration config = _configurationProvider(mapId);
    assert(config.minMaxZoomPreference != null);

    return config.minMaxZoomPreference!;
  }

  @override
  Future<TileOverlay?> getTileOverlayInfo(
    TileOverlayId tileOverlayId, {
    required int mapId,
  }) async {
    return null; // Custom tiles not supported on the web
  }

  @override
  Future<bool> isCompassEnabled({required int mapId}) async {
    return false; // There's no compass on the web
  }

  @override
  Future<bool> isLiteModeEnabled({required int mapId}) async {
    return false; // There's no lite mode on the web
  }

  @override
  Future<bool> isMapToolbarEnabled({required int mapId}) async {
    return false; // There's no Map Toolbar on the web
  }

  @override
  Future<bool> isMyLocationButtonEnabled({required int mapId}) async {
    return false; // My Location widget not supported on the web
  }

  @override
  Future<bool> isTrafficEnabled({required int mapId}) async {
    return _configurationProvider(mapId).trafficEnabled ?? false;
  }
}
