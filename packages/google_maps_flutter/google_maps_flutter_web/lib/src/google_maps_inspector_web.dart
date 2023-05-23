// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import '../google_maps_flutter_web.dart';

/// This platform implementation allows inspecting the running maps.
class GoogleMapsInspectorWeb extends GoogleMapsInspectorPlatform {
  /// Build an "inspector" that is able to look into maps.
  GoogleMapsInspectorWeb();

  GoogleMapController _map(int mapId) =>
      (GoogleMapsFlutterPlatform.instance as GoogleMapsPlugin).map(mapId);

  @override
  Future<bool> areBuildingsEnabled({required int mapId}) async {
    return false; // Not supported on the web
  }

  @override
  Future<bool> areRotateGesturesEnabled({required int mapId}) async {
    return false;
  }

  @override
  Future<bool> areScrollGesturesEnabled({required int mapId}) async {
    return _map(mapId).options.gestureHandling != 'none';
  }

  @override
  Future<bool> areTiltGesturesEnabled({required int mapId}) async {
    return false;
  }

  @override
  Future<bool> areZoomControlsEnabled({required int mapId}) async {
    return _map(mapId).options.zoomControl ?? false;
  }

  @override
  Future<bool> areZoomGesturesEnabled({required int mapId}) async {
    return _map(mapId).options.gestureHandling != 'none';
  }

  @override
  Future<MinMaxZoomPreference> getMinMaxZoomLevels({required int mapId}) async {
    return MinMaxZoomPreference(
      _map(mapId).options.minZoom?.toDouble(),
      _map(mapId).options.maxZoom?.toDouble(),
    );
  }

  @override
  Future<TileOverlay?> getTileOverlayInfo(TileOverlayId tileOverlayId,
      {required int mapId}) async {
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
    return _map(mapId).trafficLayer != null;
  }
}
