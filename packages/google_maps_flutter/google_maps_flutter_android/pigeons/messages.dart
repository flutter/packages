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
  PlatformLatLng({required this.lat, required this.lng});

  final double lat;
  final double lng;
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
