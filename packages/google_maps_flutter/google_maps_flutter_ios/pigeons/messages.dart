// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  objcHeaderOut: 'ios/Classes/messages.g.h',
  objcSourceOut: 'ios/Classes/messages.g.m',
  objcOptions: ObjcOptions(prefix: 'FGM'),
  copyrightHeader: 'pigeons/copyright.txt',
))

/// Pigeon equivalent of MapType
enum PlatformMapType {
  none,
  normal,
  satellite,
  terrain,
  hybrid,
}

/// Pigeon representatation of a CameraPosition.
class PlatformCameraPosition {
  PlatformCameraPosition({
    required this.bearing,
    required this.target,
    required this.tilt,
    required this.zoom,
  });

  final double bearing;
  final PlatformLatLng target;
  final double tilt;
  final double zoom;
}

/// Pigeon representation of a CameraUpdate.
class PlatformCameraUpdate {
  PlatformCameraUpdate(this.json);

  /// The update data, as JSON. This should only be set from
  /// CameraUpdate.toJson, and the native code must interpret it according to the
  /// internal implementation details of the CameraUpdate class.
  // TODO(stuartmorgan): Update the google_maps_platform_interface CameraUpdate
  //  class to provide a structured representation of an update. Currently it
  //  uses JSON as its only state, so there is no way to preserve structure.
  //  This wrapper class exists as a placeholder for now to at least provide
  //  type safety in the top-level call's arguments.
  final Object json;
}

/// Pigeon equivalent of the Circle class.
class PlatformCircle {
  PlatformCircle(this.json);

  /// The circle data, as JSON. This should only be set from
  /// Circle.toJson, and the native code must interpret it according to the
  /// internal implementation details of that method.
  // TODO(stuartmorgan): Replace this with structured data. This exists only to
  //  allow incremental migration to Pigeon.
  final Object json;
}

/// Pigeon equivalent of the Heatmap class.
class PlatformHeatmap {
  PlatformHeatmap(this.json);

  /// The heatmap data, as JSON. This should only be set from
  /// Heatmap.toJson, and the native code must interpret it according to the
  /// internal implementation details of that method.
  // TODO(stuartmorgan): Replace this with structured data. This exists only to
  //  allow incremental migration to Pigeon.
  final Object json;
}

/// Pigeon equivalent of Cluster.
class PlatformCluster {
  PlatformCluster({
    required this.clusterManagerId,
    required this.position,
    required this.bounds,
    required this.markerIds,
  });

  final String clusterManagerId;
  final PlatformLatLng position;
  final PlatformLatLngBounds bounds;
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats the entries as non-nullable.
  final List<String?> markerIds;
}

/// Pigeon equivalent of the ClusterManager class.
class PlatformClusterManager {
  PlatformClusterManager({required this.identifier});

  final String identifier;
}

/// Pigeon equivalent of the Marker class.
class PlatformMarker {
  PlatformMarker(this.json);

  /// The marker data, as JSON. This should only be set from
  /// Marker.toJson, and the native code must interpret it according to the
  /// internal implementation details of that method.
  // TODO(stuartmorgan): Replace this with structured data. This exists only to
  //  allow incremental migration to Pigeon.
  final Object json;
}

/// Pigeon equivalent of the Polygon class.
class PlatformPolygon {
  PlatformPolygon(this.json);

  /// The polygon data, as JSON. This should only be set from
  /// Polygon.toJson, and the native code must interpret it according to the
  /// internal implementation details of that method.
  // TODO(stuartmorgan): Replace this with structured data. This exists only to
  //  allow incremental migration to Pigeon.
  final Object json;
}

/// Pigeon equivalent of the Polyline class.
class PlatformPolyline {
  PlatformPolyline(this.json);

  /// The polyline data, as JSON. This should only be set from
  /// Polyline.toJson, and the native code must interpret it according to the
  /// internal implementation details of that method.
  // TODO(stuartmorgan): Replace this with structured data. This exists only to
  //  allow incremental migration to Pigeon.
  final Object json;
}

/// Pigeon equivalent of the Tile class.
class PlatformTile {
  PlatformTile({required this.width, required this.height, required this.data});

  final int width;
  final int height;
  final Uint8List? data;
}

/// Pigeon equivalent of the TileOverlay class.
class PlatformTileOverlay {
  PlatformTileOverlay(this.json);

  /// The tile overlay data, as JSON. This should only be set from
  /// TileOverlay.toJson, and the native code must interpret it according to the
  /// internal implementation details of that method.
  // TODO(stuartmorgan): Replace this with structured data. This exists only to
  //  allow incremental migration to Pigeon.
  final Object json;
}

/// Pigeon equivalent of Flutter's EdgeInsets.
class PlatformEdgeInsets {
  PlatformEdgeInsets({
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
  });

  final double top;
  final double bottom;
  final double left;
  final double right;
}

/// Pigeon equivalent of LatLng.
class PlatformLatLng {
  PlatformLatLng({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

/// Pigeon equivalent of LatLngBounds.
class PlatformLatLngBounds {
  PlatformLatLngBounds({required this.northeast, required this.southwest});

  final PlatformLatLng northeast;
  final PlatformLatLng southwest;
}

/// Pigeon equivalent of CameraTargetBounds.
///
/// As with the Dart version, it exists to distinguish between not setting a
/// a target, and having an explicitly unbounded target (null [bounds]).
class PlatformCameraTargetBounds {
  PlatformCameraTargetBounds({required this.bounds});

  final PlatformLatLngBounds? bounds;
}

/// Information passed to the platform view creation.
class PlatformMapViewCreationParams {
  PlatformMapViewCreationParams({
    required this.initialCameraPosition,
    required this.mapConfiguration,
    required this.initialCircles,
    required this.initialMarkers,
    required this.initialPolygons,
    required this.initialPolylines,
    required this.initialHeatmaps,
    required this.initialTileOverlays,
    required this.initialClusterManagers,
  });

  final PlatformCameraPosition initialCameraPosition;
  final PlatformMapConfiguration mapConfiguration;
  // TODO(stuartmorgan): Make the generic types non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats the entries as non-nullable.
  final List<PlatformCircle?> initialCircles;
  final List<PlatformMarker?> initialMarkers;
  final List<PlatformPolygon?> initialPolygons;
  final List<PlatformPolyline?> initialPolylines;
  final List<PlatformHeatmap?> initialHeatmaps;
  final List<PlatformTileOverlay?> initialTileOverlays;
  final List<PlatformClusterManager?> initialClusterManagers;
}

/// Pigeon equivalent of MapConfiguration.
class PlatformMapConfiguration {
  PlatformMapConfiguration({
    required this.compassEnabled,
    required this.cameraTargetBounds,
    required this.mapType,
    required this.minMaxZoomPreference,
    required this.rotateGesturesEnabled,
    required this.scrollGesturesEnabled,
    required this.tiltGesturesEnabled,
    required this.trackCameraPosition,
    required this.zoomGesturesEnabled,
    required this.myLocationEnabled,
    required this.myLocationButtonEnabled,
    required this.padding,
    required this.indoorViewEnabled,
    required this.trafficEnabled,
    required this.buildingsEnabled,
    required this.cloudMapId,
    required this.style,
  });

  final bool? compassEnabled;
  final PlatformCameraTargetBounds? cameraTargetBounds;
  final PlatformMapType? mapType;
  final PlatformZoomRange? minMaxZoomPreference;
  final bool? rotateGesturesEnabled;
  final bool? scrollGesturesEnabled;
  final bool? tiltGesturesEnabled;
  final bool? trackCameraPosition;
  final bool? zoomGesturesEnabled;
  final bool? myLocationEnabled;
  final bool? myLocationButtonEnabled;
  final PlatformEdgeInsets? padding;
  final bool? indoorViewEnabled;
  final bool? trafficEnabled;
  final bool? buildingsEnabled;
  final String? cloudMapId;
  final String? style;
}

/// Pigeon representation of an x,y coordinate.
class PlatformPoint {
  PlatformPoint({required this.x, required this.y});

  final double x;
  final double y;
}

/// Pigeon equivalent of GMSTileLayer properties.
class PlatformTileLayer {
  PlatformTileLayer({
    required this.visible,
    required this.fadeIn,
    required this.opacity,
    required this.zIndex,
  });

  final bool visible;
  final bool fadeIn;
  final double opacity;
  final int zIndex;
}

/// Pigeon equivalent of MinMaxZoomPreference.
class PlatformZoomRange {
  PlatformZoomRange({required this.min, required this.max});

  final double? min;
  final double? max;
}

/// Interface for non-test interactions with the native SDK.
///
/// For test-only state queries, see [MapsInspectorApi].
@HostApi()
abstract class MapsApi {
  /// Returns once the map instance is available.
  void waitForMap();

  /// Updates the map's configuration options.
  ///
  /// Only non-null configuration values will result in updates; options with
  /// null values will remain unchanged.
  @ObjCSelector('updateWithMapConfiguration:')
  void updateMapConfiguration(PlatformMapConfiguration configuration);

  /// Updates the set of circles on the map.
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats the entries as non-nullable.
  @ObjCSelector('updateCirclesByAdding:changing:removing:')
  void updateCircles(List<PlatformCircle?> toAdd,
      List<PlatformCircle?> toChange, List<String?> idsToRemove);

  /// Updates the set of heatmaps on the map.
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats the entries as non-nullable.
  @ObjCSelector('updateHeatmapsByAdding:changing:removing:')
  void updateHeatmaps(List<PlatformHeatmap?> toAdd,
      List<PlatformHeatmap?> toChange, List<String?> idsToRemove);

  /// Updates the set of custer managers for clusters on the map.
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats the entries as non-nullable.
  @ObjCSelector('updateClusterManagersByAdding:removing:')
  void updateClusterManagers(
      List<PlatformClusterManager?> toAdd, List<String?> idsToRemove);

  /// Updates the set of markers on the map.
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats the entries as non-nullable.
  @ObjCSelector('updateMarkersByAdding:changing:removing:')
  void updateMarkers(List<PlatformMarker?> toAdd,
      List<PlatformMarker?> toChange, List<String?> idsToRemove);

  /// Updates the set of polygonss on the map.
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats the entries as non-nullable.
  @ObjCSelector('updatePolygonsByAdding:changing:removing:')
  void updatePolygons(List<PlatformPolygon?> toAdd,
      List<PlatformPolygon?> toChange, List<String?> idsToRemove);

  /// Updates the set of polylines on the map.
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats the entries as non-nullable.
  @ObjCSelector('updatePolylinesByAdding:changing:removing:')
  void updatePolylines(List<PlatformPolyline?> toAdd,
      List<PlatformPolyline?> toChange, List<String?> idsToRemove);

  /// Updates the set of tile overlays on the map.
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats the entries as non-nullable.
  @ObjCSelector('updateTileOverlaysByAdding:changing:removing:')
  void updateTileOverlays(List<PlatformTileOverlay?> toAdd,
      List<PlatformTileOverlay?> toChange, List<String?> idsToRemove);

  /// Gets the screen coordinate for the given map location.
  @ObjCSelector('screenCoordinatesForLatLng:')
  PlatformPoint getScreenCoordinate(PlatformLatLng latLng);

  /// Gets the map location for the given screen coordinate.
  @ObjCSelector('latLngForScreenCoordinate:')
  PlatformLatLng getLatLng(PlatformPoint screenCoordinate);

  /// Gets the map region currently displayed on the map.
  @ObjCSelector('visibleMapRegion')
  PlatformLatLngBounds getVisibleRegion();

  /// Moves the camera according to [cameraUpdate] immediately, with no
  /// animation.
  @ObjCSelector('moveCameraWithUpdate:')
  void moveCamera(PlatformCameraUpdate cameraUpdate);

  /// Moves the camera according to [cameraUpdate], animating the update.
  @ObjCSelector('animateCameraWithUpdate:')
  void animateCamera(PlatformCameraUpdate cameraUpdate);

  /// Gets the current map zoom level.
  @ObjCSelector('currentZoomLevel')
  double getZoomLevel();

  /// Show the info window for the marker with the given ID.
  @ObjCSelector('showInfoWindowForMarkerWithIdentifier:')
  void showInfoWindow(String markerId);

  /// Hide the info window for the marker with the given ID.
  @ObjCSelector('hideInfoWindowForMarkerWithIdentifier:')
  void hideInfoWindow(String markerId);

  /// Returns true if the marker with the given ID is currently displaying its
  /// info window.
  @ObjCSelector('isShowingInfoWindowForMarkerWithIdentifier:')
  bool isInfoWindowShown(String markerId);

  /// Sets the style to the given map style string, where an empty string
  /// indicates that the style should be cleared.
  ///
  /// If there was an error setting the style, such as an invalid style string,
  /// returns the error message.
  @ObjCSelector('setStyle:')
  String? setStyle(String style);

  /// Returns the error string from the last attempt to set the map style, if
  /// any.
  ///
  /// This allows checking asynchronously for initial style failures, as there
  /// is no way to return failures from map initialization.
  @ObjCSelector('lastStyleError')
  String? getLastStyleError();

  /// Clears the cache of tiles previously requseted from the tile provider.
  @ObjCSelector('clearTileCacheForOverlayWithIdentifier:')
  void clearTileCache(String tileOverlayId);

  /// Takes a snapshot of the map and returns its image data.
  Uint8List? takeSnapshot();
}

/// Interface for calls from the native SDK to Dart.
@FlutterApi()
abstract class MapsCallbackApi {
  /// Called when the map camera starts moving.
  @ObjCSelector('didStartCameraMoveWithCompletion')
  void onCameraMoveStarted();

  /// Called when the map camera moves.
  @ObjCSelector('didMoveCameraToPosition:')
  void onCameraMove(PlatformCameraPosition cameraPosition);

  /// Called when the map camera stops moving.
  @ObjCSelector('didIdleCameraWithCompletion')
  void onCameraIdle();

  /// Called when the map, not a specifc map object, is tapped.
  @ObjCSelector('didTapAtPosition:')
  void onTap(PlatformLatLng position);

  /// Called when the map, not a specifc map object, is long pressed.
  @ObjCSelector('didLongPressAtPosition:')
  void onLongPress(PlatformLatLng position);

  /// Called when a marker is tapped.
  @ObjCSelector('didTapMarkerWithIdentifier:')
  void onMarkerTap(String markerId);

  /// Called when a marker drag starts.
  @ObjCSelector('didStartDragForMarkerWithIdentifier:atPosition:')
  void onMarkerDragStart(String markerId, PlatformLatLng position);

  /// Called when a marker drag updates.
  @ObjCSelector('didDragMarkerWithIdentifier:atPosition:')
  void onMarkerDrag(String markerId, PlatformLatLng position);

  /// Called when a marker drag ends.
  @ObjCSelector('didEndDragForMarkerWithIdentifier:atPosition:')
  void onMarkerDragEnd(String markerId, PlatformLatLng position);

  /// Called when a marker's info window is tapped.
  @ObjCSelector('didTapInfoWindowOfMarkerWithIdentifier:')
  void onInfoWindowTap(String markerId);

  /// Called when a circle is tapped.
  @ObjCSelector('didTapCircleWithIdentifier:')
  void onCircleTap(String circleId);

  /// Called when a marker cluster is tapped.
  @ObjCSelector('didTapCluster:')
  void onClusterTap(PlatformCluster cluster);

  /// Called when a polygon is tapped.
  @ObjCSelector('didTapPolygonWithIdentifier:')
  void onPolygonTap(String polygonId);

  /// Called when a polyline is tapped.
  @ObjCSelector('didTapPolylineWithIdentifier:')
  void onPolylineTap(String polylineId);

  /// Called to get data for a map tile.
  @async
  @ObjCSelector('tileWithOverlayIdentifier:location:zoom:')
  PlatformTile getTileOverlayTile(
      String tileOverlayId, PlatformPoint location, int zoom);
}

/// Dummy interface to force generation of the platform view creation params,
/// which are not used in any Pigeon calls, only the platform view creation
/// call made internally by Flutter.
@HostApi()
abstract class MapsPlatformViewApi {
  // This is never actually called.
  void createView(PlatformMapViewCreationParams? type);
}

/// Inspector API only intended for use in integration tests.
@HostApi()
abstract class MapsInspectorApi {
  bool areBuildingsEnabled();
  bool areRotateGesturesEnabled();
  bool areScrollGesturesEnabled();
  bool areTiltGesturesEnabled();
  bool areZoomGesturesEnabled();
  bool isCompassEnabled();
  bool isMyLocationButtonEnabled();
  bool isTrafficEnabled();
  @ObjCSelector('tileOverlayWithIdentifier:')
  PlatformTileLayer? getTileOverlayInfo(String tileOverlayId);
  @ObjCSelector('heatmapWithIdentifier:')
  PlatformHeatmap? getHeatmapInfo(String heatmapId);
  @ObjCSelector('zoomRange')
  PlatformZoomRange getZoomRange();
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats the entries as non-nullable.
  @ObjCSelector('clustersWithIdentifier:')
  List<PlatformCluster?> getClusters(String clusterManagerId);
}
