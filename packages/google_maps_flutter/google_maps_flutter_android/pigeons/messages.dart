// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  javaOptions: JavaOptions(package: 'io.flutter.plugins.googlemaps'),
  javaOut: 'android/src/main/java/io/flutter/plugins/googlemaps/Messages.java',
  copyrightHeader: 'pigeons/copyright.txt',
))

// Pigeon equivalent of the Java MapsInitializer.Renderer.
enum PlatformRendererType { legacy, latest }

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
  final Map<String?, Object?> json;
}

/// Pigeon equivalent of the Heatmap class.
class PlatformHeatmap {
  PlatformHeatmap(this.json);

  /// The heatmap data, as JSON. This should only be set from
  /// Heatmap.toJson, and the native code must interpret it according to the
  /// internal implementation details of that method.
  // TODO(stuartmorgan): Replace this with structured data. This exists only to
  //  allow incremental migration to Pigeon.
  final Map<String?, Object?> json;
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
  final Map<String?, Object?> json;
}

/// Pigeon equivalent of the Polygon class.
class PlatformPolygon {
  PlatformPolygon(this.json);

  /// The polygon data, as JSON. This should only be set from
  /// Polygon.toJson, and the native code must interpret it according to the
  /// internal implementation details of that method.
  // TODO(stuartmorgan): Replace this with structured data. This exists only to
  //  allow incremental migration to Pigeon.
  final Map<String?, Object?> json;
}

/// Pigeon equivalent of the Polyline class.
class PlatformPolyline {
  PlatformPolyline(this.json);

  /// The polyline data, as JSON. This should only be set from
  /// Polyline.toJson, and the native code must interpret it according to the
  /// internal implementation details of that method.
  // TODO(stuartmorgan): Replace this with structured data. This exists only to
  //  allow incremental migration to Pigeon.
  final Map<String?, Object?> json;
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
  final Map<String?, Object?> json;
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

/// Pigeon equivalent of MapConfiguration.
class PlatformMapConfiguration {
  PlatformMapConfiguration({required this.json});

  /// The configuration options, as JSON. This should only be set from
  /// _jsonForMapConfiguration, and the native code must interpret it according
  /// to the internal implementation details of that method.
  // TODO(stuartmorgan): Replace this with structured data. This exists only to
  //  allow incremental migration to Pigeon.
  final Map<String?, Object?> json;
}

/// Pigeon representation of an x,y coordinate.
class PlatformPoint {
  PlatformPoint({required this.x, required this.y});

  final int x;
  final int y;
}

/// Pigeon equivalent of native TileOverlay properties.
class PlatformTileLayer {
  PlatformTileLayer({
    required this.visible,
    required this.fadeIn,
    required this.transparency,
    required this.zIndex,
  });

  final bool visible;
  final bool fadeIn;
  final double transparency;
  final double zIndex;
}

/// Possible outcomes of launching a URL.
class PlatformZoomRange {
  PlatformZoomRange({required this.min, required this.max});

  final double min;
  final double max;
}

/// Interface for non-test interactions with the native SDK.
///
/// For test-only state queries, see [MapsInspectorApi].
@HostApi()
abstract class MapsApi {
  /// Returns once the map instance is available.
  @async
  void waitForMap();

  /// Updates the map's configuration options.
  ///
  /// Only non-null configuration values will result in updates; options with
  /// null values will remain unchanged.
  void updateMapConfiguration(PlatformMapConfiguration configuration);

  /// Updates the set of circles on the map.
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats the entries as non-nullable.
  void updateCircles(List<PlatformCircle?> toAdd,
      List<PlatformCircle?> toChange, List<String?> idsToRemove);

  /// Updates the set of heatmaps on the map.
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats the entries as non-nullable.
  void updateHeatmaps(List<PlatformHeatmap?> toAdd,
      List<PlatformHeatmap?> toChange, List<String?> idsToRemove);

  /// Updates the set of custer managers for clusters on the map.
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats the entries as non-nullable.
  void updateClusterManagers(
      List<PlatformClusterManager?> toAdd, List<String?> idsToRemove);

  /// Updates the set of markers on the map.
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats the entries as non-nullable.
  void updateMarkers(List<PlatformMarker?> toAdd,
      List<PlatformMarker?> toChange, List<String?> idsToRemove);

  /// Updates the set of polygonss on the map.
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats the entries as non-nullable.
  void updatePolygons(List<PlatformPolygon?> toAdd,
      List<PlatformPolygon?> toChange, List<String?> idsToRemove);

  /// Updates the set of polylines on the map.
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats the entries as non-nullable.
  void updatePolylines(List<PlatformPolyline?> toAdd,
      List<PlatformPolyline?> toChange, List<String?> idsToRemove);

  /// Updates the set of tile overlays on the map.
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats the entries as non-nullable.
  void updateTileOverlays(List<PlatformTileOverlay?> toAdd,
      List<PlatformTileOverlay?> toChange, List<String?> idsToRemove);

  /// Gets the screen coordinate for the given map location.
  PlatformPoint getScreenCoordinate(PlatformLatLng latLng);

  /// Gets the map location for the given screen coordinate.
  PlatformLatLng getLatLng(PlatformPoint screenCoordinate);

  /// Gets the map region currently displayed on the map.
  PlatformLatLngBounds getVisibleRegion();

  /// Moves the camera according to [cameraUpdate] immediately, with no
  /// animation.
  void moveCamera(PlatformCameraUpdate cameraUpdate);

  /// Moves the camera according to [cameraUpdate], animating the update.
  void animateCamera(PlatformCameraUpdate cameraUpdate);

  /// Gets the current map zoom level.
  double getZoomLevel();

  /// Show the info window for the marker with the given ID.
  void showInfoWindow(String markerId);

  /// Hide the info window for the marker with the given ID.
  void hideInfoWindow(String markerId);

  /// Returns true if the marker with the given ID is currently displaying its
  /// info window.
  bool isInfoWindowShown(String markerId);

  /// Sets the style to the given map style string, where an empty string
  /// indicates that the style should be cleared.
  ///
  /// Returns false if there was an error setting the style, such as an invalid
  /// style string.
  bool setStyle(String style);

  /// Returns true if the last attempt to set a style, either via initial map
  /// style or setMapStyle, succeeded.
  ///
  /// This allows checking asynchronously for initial style failures, as there
  /// is no way to return failures from map initialization.
  bool didLastStyleSucceed();

  /// Clears the cache of tiles previously requseted from the tile provider.
  void clearTileCache(String tileOverlayId);

  /// Takes a snapshot of the map and returns its image data.
  @async
  Uint8List takeSnapshot();
}

@FlutterApi()
abstract class MapsCallbackApi {
  /// Called when the map camera starts moving.
  void onCameraMoveStarted();

  /// Called when the map camera moves.
  void onCameraMove(PlatformCameraPosition cameraPosition);

  /// Called when the map camera stops moving.
  void onCameraIdle();

  /// Called when the map, not a specifc map object, is tapped.
  void onTap(PlatformLatLng position);

  /// Called when the map, not a specifc map object, is long pressed.
  void onLongPress(PlatformLatLng position);

  /// Called when a marker is tapped.
  void onMarkerTap(String markerId);

  /// Called when a marker drag starts.
  void onMarkerDragStart(String markerId, PlatformLatLng position);

  /// Called when a marker drag updates.
  void onMarkerDrag(String markerId, PlatformLatLng position);

  /// Called when a marker drag ends.
  void onMarkerDragEnd(String markerId, PlatformLatLng position);

  /// Called when a marker's info window is tapped.
  void onInfoWindowTap(String markerId);

  /// Called when a circle is tapped.
  void onCircleTap(String circleId);

  /// Called when a marker cluster is tapped.
  void onClusterTap(PlatformCluster cluster);

  /// Called when a polygon is tapped.
  void onPolygonTap(String polygonId);

  /// Called when a polyline is tapped.
  void onPolylineTap(String polylineId);

  /// Called to get data for a map tile.
  @async
  PlatformTile getTileOverlayTile(
      String tileOverlayId, PlatformPoint location, int zoom);
}

/// Interface for global SDK initialization.
@HostApi()
abstract class MapsInitializerApi {
  /// Initializes the Google Maps SDK with the given renderer preference.
  ///
  /// A null renderer preference will result in the default renderer.
  ///
  /// Calling this more than once in the lifetime of an application will result
  /// in an error.
  @async
  PlatformRendererType initializeWithPreferredRenderer(
      PlatformRendererType? type);
}

/// Inspector API only intended for use in integration tests.
@HostApi()
abstract class MapsInspectorApi {
  bool areBuildingsEnabled();
  bool areRotateGesturesEnabled();
  bool areZoomControlsEnabled();
  bool areScrollGesturesEnabled();
  bool areTiltGesturesEnabled();
  bool areZoomGesturesEnabled();
  bool isCompassEnabled();
  bool? isLiteModeEnabled();
  bool isMapToolbarEnabled();
  bool isMyLocationButtonEnabled();
  bool isTrafficEnabled();
  PlatformTileLayer? getTileOverlayInfo(String tileOverlayId);
  PlatformZoomRange getZoomRange();
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The consuming code treats the entries as non-nullable.
  List<PlatformCluster?> getClusters(String clusterManagerId);
}
