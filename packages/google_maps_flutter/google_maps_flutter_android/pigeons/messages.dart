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

/// Pigeon equivalent of MapType
enum PlatformMapType {
  none,
  normal,
  satellite,
  terrain,
  hybrid,
}

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
  PlatformCameraUpdate({required this.cameraUpdate});

  /// This Object shall be any of the below classes prefixed with
  /// PlatformCameraUpdate. Each such class represents a different type of
  /// camera update, and each holds a different set of data, preventing the
  /// use of a single unified class. Pigeon does not support inheritance, which
  /// prevents a more strict type bound.
  /// See https://github.com/flutter/flutter/issues/117819.
  final Object cameraUpdate;
}

/// Pigeon equivalent of NewCameraPosition
class PlatformCameraUpdateNewCameraPosition {
  PlatformCameraUpdateNewCameraPosition(this.cameraPosition);
  final PlatformCameraPosition cameraPosition;
}

/// Pigeon equivalent of NewLatLng
class PlatformCameraUpdateNewLatLng {
  PlatformCameraUpdateNewLatLng(this.latLng);
  final PlatformLatLng latLng;
}

/// Pigeon equivalent of NewLatLngBounds
class PlatformCameraUpdateNewLatLngBounds {
  PlatformCameraUpdateNewLatLngBounds(this.bounds, this.padding);
  final PlatformLatLngBounds bounds;
  final double padding;
}

/// Pigeon equivalent of NewLatLngZoom
class PlatformCameraUpdateNewLatLngZoom {
  PlatformCameraUpdateNewLatLngZoom(this.latLng, this.zoom);
  final PlatformLatLng latLng;
  final double zoom;
}

/// Pigeon equivalent of ScrollBy
class PlatformCameraUpdateScrollBy {
  PlatformCameraUpdateScrollBy(this.dx, this.dy);
  final double dx;
  final double dy;
}

/// Pigeon equivalent of ZoomBy
class PlatformCameraUpdateZoomBy {
  PlatformCameraUpdateZoomBy(this.amount, [this.focus]);
  final double amount;
  final PlatformDoublePair? focus;
}

/// Pigeon equivalent of ZoomIn/ZoomOut
class PlatformCameraUpdateZoom {
  PlatformCameraUpdateZoom(this.out);
  final bool out;
}

/// Pigeon equivalent of ZoomTo
class PlatformCameraUpdateZoomTo {
  PlatformCameraUpdateZoomTo(this.zoom);
  final double zoom;
}

/// Pigeon equivalent of the Circle class.
class PlatformCircle {
  PlatformCircle({
    required this.circleId,
    required this.center,
    this.consumeTapEvents = false,
    this.fillColor = 0x00000000,
    this.strokeColor = 0xFF000000,
    this.visible = true,
    this.strokeWidth = 10,
    this.zIndex = 0.0,
    this.radius = 0,
  });

  final bool consumeTapEvents;
  final int fillColor;
  final int strokeColor;
  final bool visible;
  final int strokeWidth;
  final double zIndex;
  final PlatformLatLng center;
  final double radius;
  final String circleId;
}

/// Pigeon equivalent of the Heatmap class.
class PlatformHeatmap {
  PlatformHeatmap(this.json);

  /// The heatmap data, as JSON. This should only be set from
  /// Heatmap.toJson, and the native code must interpret it according to the
  /// internal implementation details of that method.
  // TODO(stuartmorgan): Replace this with structured data. This exists only to
  //  allow incremental migration to Pigeon.
  final Map<String, Object?> json;
}

/// Pigeon equivalent of the ClusterManager class.
class PlatformClusterManager {
  PlatformClusterManager({required this.identifier});

  final String identifier;
}

/// Pair of double values, such as for an offset or size.
class PlatformDoublePair {
  PlatformDoublePair(this.x, this.y);

  final double x;
  final double y;
}

/// Pigeon equivalent of the InfoWindow class.
class PlatformInfoWindow {
  PlatformInfoWindow({
    required this.anchor,
    this.title,
    this.snippet,
  });

  final String? title;
  final String? snippet;
  final PlatformDoublePair anchor;
}

/// Pigeon equivalent of the Marker class.
class PlatformMarker {
  PlatformMarker({
    required this.markerId,
    required this.icon,
    this.alpha = 1.0,
    required this.anchor,
    this.consumeTapEvents = false,
    this.draggable = false,
    this.flat = false,
    required this.infoWindow,
    required this.position,
    this.rotation = 0.0,
    this.visible = true,
    this.zIndex = 0.0,
    this.clusterManagerId,
    this.collisionBehavior = PlatformMarkerCollisionBehavior.required,
  });

  final double alpha;
  final PlatformDoublePair anchor;
  final bool consumeTapEvents;
  final bool draggable;
  final bool flat;

  final PlatformBitmap icon;
  final PlatformInfoWindow infoWindow;
  final PlatformLatLng position;
  final double rotation;
  final bool visible;
  final double zIndex;
  final String markerId;
  final String? clusterManagerId;

  final PlatformMarkerCollisionBehavior collisionBehavior;
}

enum PlatformMarkerCollisionBehavior {
  required,
  optionalAndHidesLowerPriority,
  requiredAndHidesOptional,
}

/// Pigeon equivalent of the Polygon class.
class PlatformPolygon {
  PlatformPolygon({
    required this.polygonId,
    required this.consumesTapEvents,
    required this.fillColor,
    required this.geodesic,
    required this.points,
    required this.holes,
    required this.visible,
    required this.strokeColor,
    required this.strokeWidth,
    required this.zIndex,
  });

  final String polygonId;
  final bool consumesTapEvents;
  final int fillColor;
  final bool geodesic;
  final List<PlatformLatLng> points;
  final List<List<PlatformLatLng>> holes;
  final bool visible;
  final int strokeColor;
  final int strokeWidth;
  final int zIndex;
}

/// Join types for polyline joints.
enum PlatformJointType {
  mitered,
  bevel,
  round,
}

/// Pigeon equivalent of the Polyline class.
class PlatformPolyline {
  PlatformPolyline({
    required this.polylineId,
    required this.consumesTapEvents,
    required this.color,
    required this.geodesic,
    required this.jointType,
    required this.patterns,
    required this.points,
    required this.startCap,
    required this.endCap,
    required this.visible,
    required this.width,
    required this.zIndex,
  });

  final String polylineId;
  final bool consumesTapEvents;
  final int color;
  final bool geodesic;

  /// The joint type.
  final PlatformJointType jointType;

  /// The pattern data, as a list of pattern items.
  final List<PlatformPatternItem> patterns;
  final List<PlatformLatLng> points;

  /// The cap at the start and end vertex of a polyline.
  /// See https://developers.google.com/maps/documentation/android-sdk/reference/com/google/android/libraries/maps/model/Cap.
  final PlatformCap startCap;
  final PlatformCap endCap;

  final bool visible;
  final int width;
  final int zIndex;
}

/// Enumeration of possible types of PlatformCap, corresponding to the
/// subclasses of Cap in the Google Maps Android SDK.
/// See https://developers.google.com/maps/documentation/android-sdk/reference/com/google/android/libraries/maps/model/Cap.
enum PlatformCapType {
  buttCap,
  roundCap,
  squareCap,
  customCap,
}

/// Pigeon equivalent of Cap from the platform interface.
/// https://github.com/flutter/packages/blob/main/packages/google_maps_flutter/google_maps_flutter_platform_interface/lib/src/types/cap.dart
class PlatformCap {
  PlatformCap({required this.type, this.bitmapDescriptor, this.refWidth});

  final PlatformCapType type;

  final PlatformBitmap? bitmapDescriptor;
  final double? refWidth;
}

/// Enumeration of possible types for PatternItem.
enum PlatformPatternItemType {
  dot,
  dash,
  gap,
}

/// Pigeon equivalent of the PatternItem class.
class PlatformPatternItem {
  PlatformPatternItem({required this.type, this.length});

  final PlatformPatternItemType type;
  final double? length;
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
  PlatformTileOverlay({
    required this.tileOverlayId,
    required this.fadeIn,
    required this.transparency,
    required this.zIndex,
    required this.visible,
    required this.tileSize,
  });

  final String tileOverlayId;
  final bool fadeIn;
  final double transparency;
  final int zIndex;
  final bool visible;
  final int tileSize;
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
  final List<String> markerIds;
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
    required this.markerType,
  });

  final PlatformCameraPosition initialCameraPosition;
  final PlatformMapConfiguration mapConfiguration;
  final List<PlatformCircle> initialCircles;
  final List<PlatformMarker> initialMarkers;
  final List<PlatformPolygon> initialPolygons;
  final List<PlatformPolyline> initialPolylines;
  final List<PlatformHeatmap> initialHeatmaps;
  final List<PlatformTileOverlay> initialTileOverlays;
  final List<PlatformClusterManager> initialClusterManagers;
  fina PlatformMarkerType markerType;
}

enum PlatformMarkerType {
marker, advancedMarker,}

/// Pigeon equivalent of MapConfiguration.
class PlatformMapConfiguration {
  PlatformMapConfiguration({
    required this.compassEnabled,
    required this.cameraTargetBounds,
    required this.mapType,
    required this.minMaxZoomPreference,
    required this.mapToolbarEnabled,
    required this.rotateGesturesEnabled,
    required this.scrollGesturesEnabled,
    required this.tiltGesturesEnabled,
    required this.trackCameraPosition,
    required this.zoomControlsEnabled,
    required this.zoomGesturesEnabled,
    required this.myLocationEnabled,
    required this.myLocationButtonEnabled,
    required this.padding,
    required this.indoorViewEnabled,
    required this.trafficEnabled,
    required this.buildingsEnabled,
    required this.liteModeEnabled,
    required this.mapId,
    required this.style,
  });

  final bool? compassEnabled;
  final PlatformCameraTargetBounds? cameraTargetBounds;
  final PlatformMapType? mapType;
  final PlatformZoomRange? minMaxZoomPreference;
  final bool? mapToolbarEnabled;
  final bool? rotateGesturesEnabled;
  final bool? scrollGesturesEnabled;
  final bool? tiltGesturesEnabled;
  final bool? trackCameraPosition;
  final bool? zoomControlsEnabled;
  final bool? zoomGesturesEnabled;
  final bool? myLocationEnabled;
  final bool? myLocationButtonEnabled;
  final PlatformEdgeInsets? padding;
  final bool? indoorViewEnabled;
  final bool? trafficEnabled;
  final bool? buildingsEnabled;
  final bool? liteModeEnabled;
  final String? mapId;
  final String? style;
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

  final double? min;
  final double? max;
}

/// Pigeon equivalent of [BitmapDescriptor]. As there are multiple disjoint
/// types of [BitmapDescriptor], [PlatformBitmap] contains a single field which
/// may hold the pigeon equivalent type of any of them.
class PlatformBitmap {
  PlatformBitmap({required this.bitmap});

  /// One of [PlatformBitmapAssetMap], [PlatformBitmapAsset],
  /// [PlatformBitmapAssetImage], [PlatformBitmapBytesMap],
  /// [PlatformBitmapBytes], or [PlatformBitmapDefaultMarker].
  /// As Pigeon does not currently support data class inheritance, this
  /// approach allows for the different bitmap implementations to be valid
  /// argument and return types of the API methods. See
  /// https://github.com/flutter/flutter/issues/117819.
  final Object bitmap;
}

/// Pigeon equivalent of [DefaultMarker]. See
/// https://developers.google.com/maps/documentation/android-sdk/reference/com/google/android/libraries/maps/model/BitmapDescriptorFactory#defaultMarker(float)
class PlatformBitmapDefaultMarker {
  PlatformBitmapDefaultMarker({this.hue});

  final double? hue;
}

/// Pigeon equivalent of [BytesBitmap]. See
/// https://developers.google.com/maps/documentation/android-sdk/reference/com/google/android/libraries/maps/model/BitmapDescriptorFactory#fromBitmap(android.graphics.Bitmap)
class PlatformBitmapBytes {
  PlatformBitmapBytes({required this.byteData, this.size});

  final Uint8List byteData;
  final PlatformDoublePair? size;
}

/// Pigeon equivalent of [AssetBitmap]. See
/// https://developers.google.com/maps/documentation/android-sdk/reference/com/google/android/libraries/maps/model/BitmapDescriptorFactory#public-static-bitmapdescriptor-fromasset-string-assetname
class PlatformBitmapAsset {
  PlatformBitmapAsset({required this.name, this.pkg});

  final String name;
  final String? pkg;
}

/// Pigeon equivalent of [AssetImageBitmap]. See
/// https://developers.google.com/maps/documentation/android-sdk/reference/com/google/android/libraries/maps/model/BitmapDescriptorFactory#public-static-bitmapdescriptor-fromasset-string-assetname
class PlatformBitmapAssetImage {
  PlatformBitmapAssetImage(
      {required this.name, required this.scale, this.size});
  final String name;
  final double scale;
  final PlatformDoublePair? size;
}

/// Pigeon equivalent of [MapBitmapScaling].
enum PlatformMapBitmapScaling {
  auto,
  none,
}

/// Pigeon equivalent of [AssetMapBitmap]. See
/// https://developers.google.com/maps/documentation/android-sdk/reference/com/google/android/libraries/maps/model/BitmapDescriptorFactory#public-static-bitmapdescriptor-fromasset-string-assetname
class PlatformBitmapAssetMap {
  PlatformBitmapAssetMap(
      {required this.assetName,
      required this.bitmapScaling,
      required this.imagePixelRatio,
      this.width,
      this.height});
  final String assetName;
  final PlatformMapBitmapScaling bitmapScaling;
  final double imagePixelRatio;
  final double? width;
  final double? height;
}

/// Pigeon equivalent of [BytesMapBitmap]. See
/// https://developers.google.com/maps/documentation/android-sdk/reference/com/google/android/libraries/maps/model/BitmapDescriptorFactory#public-static-bitmapdescriptor-frombitmap-bitmap-image
class PlatformBitmapBytesMap {
  PlatformBitmapBytesMap(
      {required this.byteData,
      required this.bitmapScaling,
      required this.imagePixelRatio,
      this.width,
      this.height});
  final Uint8List byteData;
  final PlatformMapBitmapScaling bitmapScaling;
  final double imagePixelRatio;
  final double? width;
  final double? height;
}

class PlatformBitmapPinConfig {
  PlatformBitmapPinConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.glyphColor,
    required this.glyphBitmap,
    required this.glyphText,
    required this.glyphTextColor,
  });

  final int? backgroundColor;
  final int? borderColor;
  final int? glyphColor;
  final PlatformBitmap? glyphBitmap;

  final String? glyphText;
  final int? glyphTextColor;
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
  void updateCircles(List<PlatformCircle> toAdd, List<PlatformCircle> toChange,
      List<String> idsToRemove);

  /// Updates the set of heatmaps on the map.
  void updateHeatmaps(List<PlatformHeatmap> toAdd,
      List<PlatformHeatmap> toChange, List<String> idsToRemove);

  /// Updates the set of custer managers for clusters on the map.
  void updateClusterManagers(
      List<PlatformClusterManager> toAdd, List<String> idsToRemove);

  /// Updates the set of markers on the map.
  void updateMarkers(List<PlatformMarker> toAdd, List<PlatformMarker> toChange,
      List<String> idsToRemove);

  /// Updates the set of polygonss on the map.
  void updatePolygons(List<PlatformPolygon> toAdd,
      List<PlatformPolygon> toChange, List<String> idsToRemove);

  /// Updates the set of polylines on the map.
  void updatePolylines(List<PlatformPolyline> toAdd,
      List<PlatformPolyline> toChange, List<String> idsToRemove);

  /// Updates the set of tile overlays on the map.
  void updateTileOverlays(List<PlatformTileOverlay> toAdd,
      List<PlatformTileOverlay> toChange, List<String> idsToRemove);

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

  bool isAdvancedMarkersAvailable();

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
  List<PlatformCluster> getClusters(String clusterManagerId);
}
