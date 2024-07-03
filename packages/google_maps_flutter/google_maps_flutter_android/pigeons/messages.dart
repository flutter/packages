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

  /// Gets the screen coordinate for the given map location.
  PlatformPoint getScreenCoordinate(PlatformLatLng latLng);

  /// Gets the map location for the given screen coordinate.
  PlatformLatLng getLatLng(PlatformPoint screenCoordinate);

  /// Gets the map region currently displayed on the map.
  PlatformLatLngBounds getVisibleRegion();

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
