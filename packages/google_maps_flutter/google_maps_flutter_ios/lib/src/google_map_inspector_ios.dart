// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'google_maps_flutter_ios.dart';
import 'messages.g.dart';
import 'serialization.dart';

/// An Android of implementation of [GoogleMapsInspectorPlatform].
@visibleForTesting
class GoogleMapsInspectorIOS extends GoogleMapsInspectorPlatform {
  /// Creates an inspector API instance for a given map ID from
  /// [inspectorProvider].
  GoogleMapsInspectorIOS(
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
    // Does not exist on iOS.
    return false;
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
      transparency: 1.0 - tileInfo.opacity,
      visible: tileInfo.visible,
      zIndex: tileInfo.zIndex,
    );
  }

  @override
  bool supportsGettingHeatmapInfo() => true;

  @override
  Future<Heatmap?> getHeatmapInfo(HeatmapId heatmapId,
      {required int mapId}) async {
    final PlatformHeatmap? heatmapInfo =
        await _inspectorProvider(mapId)!.getHeatmapInfo(heatmapId.value);
    if (heatmapInfo == null) {
      return null;
    }

    final Map<String, Object?> json =
        (heatmapInfo.json as Map<Object?, Object?>).cast<String, Object?>();
    return Heatmap(
      heatmapId: heatmapId,
      data: (json['data']! as List<Object?>)
          .map(deserializeWeightedLatLng)
          .whereType<WeightedLatLng>()
          .toList(),
      gradient: deserializeHeatmapGradient(json['gradient']),
      opacity: json['opacity']! as double,
      radius: HeatmapRadius.fromPixels(json['radius']! as int),
      minimumZoomIntensity: json['minimumZoomIntensity']! as int,
      maximumZoomIntensity: json['maximumZoomIntensity']! as int,
    );
  }

  @override
  Future<bool> isCompassEnabled({required int mapId}) async {
    return _inspectorProvider(mapId)!.isCompassEnabled();
  }

  @override
  Future<bool> isLiteModeEnabled({required int mapId}) async {
    // Does not exist on iOS.
    return false;
  }

  @override
  Future<bool> isMapToolbarEnabled({required int mapId}) async {
    // Does not exist on iOS.
    return false;
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
            GoogleMapsFlutterIOS.clusterFromPlatformCluster(cluster!))
        .toList();
  }
}
