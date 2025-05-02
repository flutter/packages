// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

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
  bool supportsGettingGroundOverlayInfo() => true;

  @override
  Future<GroundOverlay?> getGroundOverlayInfo(GroundOverlayId groundOverlayId,
      {required int mapId}) async {
    final PlatformGroundOverlay? groundOverlayInfo =
        await _inspectorProvider(mapId)!
            .getGroundOverlayInfo(groundOverlayId.value);

    if (groundOverlayInfo == null) {
      return null;
    }

    // Create dummy image to represent the image of the ground overlay.
    final BytesMapBitmap dummyImage = BytesMapBitmap(
      Uint8List.fromList(<int>[0]),
      bitmapScaling: MapBitmapScaling.none,
    );

    final PlatformLatLng? position = groundOverlayInfo.position;
    final PlatformLatLngBounds? bounds = groundOverlayInfo.bounds;

    if (position != null) {
      return GroundOverlay.fromPosition(
        groundOverlayId: groundOverlayId,
        position: LatLng(position.latitude, position.longitude),
        image: dummyImage,
        width: groundOverlayInfo.width,
        height: groundOverlayInfo.height,
        zIndex: groundOverlayInfo.zIndex,
        bearing: groundOverlayInfo.bearing,
        transparency: groundOverlayInfo.transparency,
        visible: groundOverlayInfo.visible,
        clickable: groundOverlayInfo.clickable,
        anchor:
            Offset(groundOverlayInfo.anchor!.x, groundOverlayInfo.anchor!.y),
      );
    } else if (bounds != null) {
      return GroundOverlay.fromBounds(
        groundOverlayId: groundOverlayId,
        bounds: LatLngBounds(
            southwest:
                LatLng(bounds.southwest.latitude, bounds.southwest.longitude),
            northeast:
                LatLng(bounds.northeast.latitude, bounds.northeast.longitude)),
        image: dummyImage,
        zIndex: groundOverlayInfo.zIndex,
        bearing: groundOverlayInfo.bearing,
        transparency: groundOverlayInfo.transparency,
        visible: groundOverlayInfo.visible,
        clickable: groundOverlayInfo.clickable,
      );
    }
    return null;
  }

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

  @override
  bool supportsGettingGameraPosition() => true;

  @override
  Future<CameraPosition> getCameraPosition({required int mapId}) async {
    final PlatformCameraPosition cameraPosition =
        await _inspectorProvider(mapId)!.getCameraPosition();
    return CameraPosition(
      target: LatLng(
        cameraPosition.target.latitude,
        cameraPosition.target.longitude,
      ),
      bearing: cameraPosition.bearing,
      tilt: cameraPosition.tilt,
      zoom: cameraPosition.zoom,
    );
  }
}
