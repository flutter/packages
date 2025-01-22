// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'google_maps_flutter_android.dart';
import 'messages.g.dart';

/// An Android of implementation of [GoogleMapsInspectorPlatform].
@visibleForTesting
class GoogleMapsInspectorAndroid extends GoogleMapsInspectorPlatform {
  /// Creates an inspector API instance for a given map ID from
  /// [inspectorProvider].
  GoogleMapsInspectorAndroid(
      MapsInspectorApi? Function(int mapId) inspectorProvider)
      : _inspectorProvider = inspectorProvider;

  final MapsInspectorApi? Function(int mapId) _inspectorProvider;

  @override
  Future<bool> areBuildingsEnabled({required int mapId}) async {
    return _inspectorProvider(mapId)!.areBuildingsEnabled();
  }

  @override
  Future<bool> areRotateGesturesEnabled({required int mapId}) async {
    return _inspectorProvider(mapId)!.areRotateGesturesEnabled();
  }

  @override
  Future<bool> areScrollGesturesEnabled({required int mapId}) async {
    return _inspectorProvider(mapId)!.areScrollGesturesEnabled();
  }

  @override
  Future<bool> areTiltGesturesEnabled({required int mapId}) async {
    return _inspectorProvider(mapId)!.areTiltGesturesEnabled();
  }

  @override
  Future<bool> areZoomControlsEnabled({required int mapId}) async {
    return _inspectorProvider(mapId)!.areZoomControlsEnabled();
  }

  @override
  Future<bool> areZoomGesturesEnabled({required int mapId}) async {
    return _inspectorProvider(mapId)!.areZoomGesturesEnabled();
  }

  @override
  Future<MinMaxZoomPreference> getMinMaxZoomLevels({required int mapId}) async {
    final PlatformZoomRange zoomLevels =
        await _inspectorProvider(mapId)!.getZoomRange();
    return MinMaxZoomPreference(zoomLevels.min, zoomLevels.max);
  }

  @override
  Future<TileOverlay?> getTileOverlayInfo(TileOverlayId tileOverlayId,
      {required int mapId}) async {
    final PlatformTileLayer? tileInfo = await _inspectorProvider(mapId)!
        .getTileOverlayInfo(tileOverlayId.value);
    if (tileInfo == null) {
      return null;
    }
    return TileOverlay(
      tileOverlayId: tileOverlayId,
      fadeIn: tileInfo.fadeIn,
      transparency: tileInfo.transparency,
      visible: tileInfo.visible,
      // The plugin's API only allows setting integer z-index values, so this
      // should never actually lose information.
      zIndex: tileInfo.zIndex.round(),
    );
  }

  @override
  bool supportsGettingHeatmapInfo() => false;

  @override
  Future<bool> isCompassEnabled({required int mapId}) async {
    return _inspectorProvider(mapId)!.isCompassEnabled();
  }

  @override
  Future<bool> isLiteModeEnabled({required int mapId}) async {
    // Null indicates "unspecified"; interpret that as not enabled.
    return (await _inspectorProvider(mapId)!.isLiteModeEnabled()) ?? false;
  }

  @override
  Future<bool> isMapToolbarEnabled({required int mapId}) async {
    return _inspectorProvider(mapId)!.isMapToolbarEnabled();
  }

  @override
  Future<bool> isMyLocationButtonEnabled({required int mapId}) async {
    return _inspectorProvider(mapId)!.isMyLocationButtonEnabled();
  }

  @override
  Future<bool> isTrafficEnabled({required int mapId}) async {
    return _inspectorProvider(mapId)!.isTrafficEnabled();
  }

  @override
  Future<List<Cluster>> getClusters({
    required int mapId,
    required ClusterManagerId clusterManagerId,
  }) async {
    return (await _inspectorProvider(mapId)!
            .getClusters(clusterManagerId.value))
        // See comment in messages.dart for why the force unwrap is okay.
        .map((PlatformCluster? cluster) =>
            GoogleMapsFlutterAndroid.clusterFromPlatformCluster(cluster!))
        .toList();
  }
}
