// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import '../google_maps_flutter_web.dart';
import 'marker_clustering.dart';

/// Function that gets the [MapConfiguration] for a given `mapId`.
typedef ConfigurationProvider = MapConfiguration Function(int mapId);

/// Function that gets the [ClusterManagersController] for a given `mapId`.
typedef ClusterManagersControllerProvider = ClusterManagersController? Function(
    int mapId);

/// Function that gets the [GroundOverlaysController] for a given `mapId`.
typedef GroundOverlaysControllerProvider = GroundOverlaysController? Function(
    int mapId);

/// This platform implementation allows inspecting the running maps.
class GoogleMapsInspectorWeb extends GoogleMapsInspectorPlatform {
  /// Build an "inspector" that is able to look into maps.
  GoogleMapsInspectorWeb(
    ConfigurationProvider configurationProvider,
    ClusterManagersControllerProvider clusterManagersControllerProvider,
    GroundOverlaysControllerProvider groundOverlaysControllerProvider,
  )   : _configurationProvider = configurationProvider,
        _clusterManagersControllerProvider = clusterManagersControllerProvider,
        _groundOverlaysControllerProvider = groundOverlaysControllerProvider;

  final ConfigurationProvider _configurationProvider;
  final ClusterManagersControllerProvider _clusterManagersControllerProvider;
  final GroundOverlaysControllerProvider _groundOverlaysControllerProvider;

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
  bool supportsGettingGroundOverlayInfo() => true;

  @override
  Future<GroundOverlay?> getGroundOverlayInfo(GroundOverlayId groundOverlayId,
      {required int mapId}) async {
    final gmaps.GroundOverlay? groundOverlay =
        _groundOverlaysControllerProvider(mapId)!
            .getGroundOverlay(groundOverlayId);

    if (groundOverlay == null) {
      return null;
    }

    final JSAny? clickable = groundOverlay.get('clickable');

    return GroundOverlay.fromBounds(
        groundOverlayId: groundOverlayId,
        image: BytesMapBitmap(
          Uint8List.fromList(<int>[0]),
          bitmapScaling: MapBitmapScaling.none,
        ),
        bounds: gmLatLngBoundsTolatLngBounds(groundOverlay.bounds),
        transparency: 1.0 - groundOverlay.opacity,
        visible: groundOverlay.map != null,
        clickable: clickable != null && (clickable as JSBoolean).toDart);
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

  @override
  Future<List<Cluster>> getClusters({
    required int mapId,
    required ClusterManagerId clusterManagerId,
  }) async {
    return _clusterManagersControllerProvider(mapId)
            ?.getClusters(clusterManagerId) ??
        <Cluster>[];
  }
}
