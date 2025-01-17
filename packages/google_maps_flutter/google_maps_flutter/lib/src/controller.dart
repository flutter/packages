// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: library_private_types_in_public_api

part of '../google_maps_flutter.dart';

/// Exception for map state errors when calling a function
/// of the map when it's not mounted.
class MapStateException implements Exception {
  /// Creates a new instance of [MapStateException].
  MapStateException(this.message);

  /// Error message describing the exception.
  final String message;

  @override
  String toString() => 'MapStateException: $message';
}

/// Controller for a single GoogleMap instance running on the host platform.
class GoogleMapController {
  GoogleMapController._(
    this._googleMapState, {
    required this.mapId,
  }) {
    _connectStreams(mapId);
  }

  /// The mapId for this controller
  final int mapId;

  /// Initialize control of a [GoogleMap] with [id].
  ///
  /// Mainly for internal use when instantiating a [GoogleMapController] passed
  /// in [GoogleMap.onMapCreated] callback.
  static Future<GoogleMapController> init(
    int id,
    CameraPosition initialCameraPosition,
    _GoogleMapState googleMapState,
  ) async {
    await GoogleMapsFlutterPlatform.instance.init(id);
    return GoogleMapController._(
      googleMapState,
      mapId: id,
    );
  }

  final _GoogleMapState _googleMapState;

  void _connectStreams(int mapId) {
    if (_googleMapState.widget.onCameraMoveStarted != null) {
      GoogleMapsFlutterPlatform.instance
          .onCameraMoveStarted(mapId: mapId)
          .listen((_) => _googleMapState.widget.onCameraMoveStarted!());
    }
    if (_googleMapState.widget.onCameraMove != null) {
      GoogleMapsFlutterPlatform.instance.onCameraMove(mapId: mapId).listen(
          (CameraMoveEvent e) => _googleMapState.widget.onCameraMove!(e.value));
    }
    if (_googleMapState.widget.onCameraIdle != null) {
      GoogleMapsFlutterPlatform.instance
          .onCameraIdle(mapId: mapId)
          .listen((_) => _googleMapState.widget.onCameraIdle!());
    }
    GoogleMapsFlutterPlatform.instance
        .onMarkerTap(mapId: mapId)
        .listen((MarkerTapEvent e) => _googleMapState.onMarkerTap(e.value));
    GoogleMapsFlutterPlatform.instance.onMarkerDragStart(mapId: mapId).listen(
        (MarkerDragStartEvent e) =>
            _googleMapState.onMarkerDragStart(e.value, e.position));
    GoogleMapsFlutterPlatform.instance.onMarkerDrag(mapId: mapId).listen(
        (MarkerDragEvent e) =>
            _googleMapState.onMarkerDrag(e.value, e.position));
    GoogleMapsFlutterPlatform.instance.onMarkerDragEnd(mapId: mapId).listen(
        (MarkerDragEndEvent e) =>
            _googleMapState.onMarkerDragEnd(e.value, e.position));
    GoogleMapsFlutterPlatform.instance.onInfoWindowTap(mapId: mapId).listen(
        (InfoWindowTapEvent e) => _googleMapState.onInfoWindowTap(e.value));
    GoogleMapsFlutterPlatform.instance
        .onPolylineTap(mapId: mapId)
        .listen((PolylineTapEvent e) => _googleMapState.onPolylineTap(e.value));
    GoogleMapsFlutterPlatform.instance
        .onPolygonTap(mapId: mapId)
        .listen((PolygonTapEvent e) => _googleMapState.onPolygonTap(e.value));
    GoogleMapsFlutterPlatform.instance
        .onCircleTap(mapId: mapId)
        .listen((CircleTapEvent e) => _googleMapState.onCircleTap(e.value));
    GoogleMapsFlutterPlatform.instance
        .onTap(mapId: mapId)
        .listen((MapTapEvent e) => _googleMapState.onTap(e.position));
    GoogleMapsFlutterPlatform.instance.onLongPress(mapId: mapId).listen(
        (MapLongPressEvent e) => _googleMapState.onLongPress(e.position));
    GoogleMapsFlutterPlatform.instance
        .onClusterTap(mapId: mapId)
        .listen((ClusterTapEvent e) => _googleMapState.onClusterTap(e.value));
  }

  /// Updates configuration options of the map user interface.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateMapConfiguration(MapConfiguration update) {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance
          .updateMapConfiguration(update, mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method _updateMapConfiguration on an unmounted GoogleMap instance.');
    }
  }

  /// Updates marker configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateMarkers(MarkerUpdates markerUpdates) {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance
          .updateMarkers(markerUpdates, mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method _updateMarkers on an unmounted GoogleMap instance.');
    }
  }

  /// Updates cluster manager configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateClusterManagers(
      ClusterManagerUpdates clusterManagerUpdates) {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance
          .updateClusterManagers(clusterManagerUpdates, mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method _updateClusterManagers on an unmounted GoogleMap instance.');
    }
  }

  /// Updates polygon configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updatePolygons(PolygonUpdates polygonUpdates) {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance
          .updatePolygons(polygonUpdates, mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method _updatePolygons on an unmounted GoogleMap instance.');
    }
  }

  /// Updates polyline configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updatePolylines(PolylineUpdates polylineUpdates) {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance
          .updatePolylines(polylineUpdates, mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method _updatePolylines on an unmounted GoogleMap instance.');
    }
  }

  /// Updates circle configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateCircles(CircleUpdates circleUpdates) {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance
          .updateCircles(circleUpdates, mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method _updateCircles on an unmounted GoogleMap instance.');
    }
  }

  /// Updates heatmap configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateHeatmaps(HeatmapUpdates heatmapUpdates) {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance
          .updateHeatmaps(heatmapUpdates, mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method _updateHeatmaps on an unmounted GoogleMap instance.');
    }
  }

  /// Updates tile overlays configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateTileOverlays(Set<TileOverlay> newTileOverlays) {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance
          .updateTileOverlays(newTileOverlays: newTileOverlays, mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method _updateTileOverlays on an unmounted GoogleMap instance.');
    }
  }

  /// Clears the tile cache so that all tiles will be requested again from the
  /// [TileProvider].
  ///
  /// The current tiles from this tile overlay will also be
  /// cleared from the map after calling this method. The API maintains a small
  /// in-memory cache of tiles. If you want to cache tiles for longer, you
  /// should implement an on-disk cache.
  Future<void> clearTileCache(TileOverlayId tileOverlayId) async {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance
          .clearTileCache(tileOverlayId, mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method clearTileCache on an unmounted GoogleMap instance.');
    }
  }

  /// Starts an animated change of the map camera position.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  Future<void> animateCamera(CameraUpdate cameraUpdate) {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance
          .animateCamera(cameraUpdate, mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method animateCamera on an unmounted GoogleMap instance.');
    }
  }

  /// Changes the map camera position.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> moveCamera(CameraUpdate cameraUpdate) {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance
          .moveCamera(cameraUpdate, mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method moveCamera on an unmounted GoogleMap instance.');
    }
  }

  /// Sets the styling of the base map.
  ///
  /// Set to `null` to clear any previous custom styling.
  ///
  /// If problems were detected with the [mapStyle], including un-parsable
  /// styling JSON, unrecognized feature type, unrecognized element type, or
  /// invalid styler keys: [MapStyleException] is thrown and the current
  /// style is left unchanged.
  ///
  /// The style string can be generated using [map style tool](https://mapstyle.withgoogle.com/).
  /// Also, refer [iOS](https://developers.google.com/maps/documentation/ios-sdk/style-reference)
  /// and [Android](https://developers.google.com/maps/documentation/android-sdk/style-reference)
  /// style reference for more information regarding the supported styles.
  @Deprecated('Use GoogleMap.style instead.')
  Future<void> setMapStyle(String? mapStyle) {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance
          .setMapStyle(mapStyle, mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method setMapStyle on an unmounted GoogleMap instance.');
    }
  }

  /// Returns the last style error, if any.
  Future<String?> getStyleError() {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance.getStyleError(mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method getStyleError on an unmounted GoogleMap instance.');
    }
  }

  /// Return [LatLngBounds] defining the region that is visible in a map.
  Future<LatLngBounds> getVisibleRegion() {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance.getVisibleRegion(mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method getVisibleRegion on an unmounted GoogleMap instance.');
    }
  }

  /// Return [ScreenCoordinate] of the [LatLng] in the current map view.
  ///
  /// A projection is used to translate between on screen location and geographic coordinates.
  /// Screen location is in screen pixels (not display pixels) with respect to the top left corner
  /// of the map, not necessarily of the whole screen.
  Future<ScreenCoordinate> getScreenCoordinate(LatLng latLng) {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance
          .getScreenCoordinate(latLng, mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method getScreenCoordinate on an unmounted GoogleMap instance.');
    }
  }

  /// Returns [LatLng] corresponding to the [ScreenCoordinate] in the current map view.
  ///
  /// Returned [LatLng] corresponds to a screen location. The screen location is specified in screen
  /// pixels (not display pixels) relative to the top left of the map, not top left of the whole screen.
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate) {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance
          .getLatLng(screenCoordinate, mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method getLatLng on an unmounted GoogleMap instance.');
    }
  }

  /// Programmatically show the Info Window for a [Marker].
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [hideMarkerInfoWindow] to hide the Info Window.
  ///   * [isMarkerInfoWindowShown] to check if the Info Window is showing.
  Future<void> showMarkerInfoWindow(MarkerId markerId) {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance
          .showMarkerInfoWindow(markerId, mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method showMarkerInfoWindow on an unmounted GoogleMap instance.');
    }
  }

  /// Programmatically hide the Info Window for a [Marker].
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [showMarkerInfoWindow] to show the Info Window.
  ///   * [isMarkerInfoWindowShown] to check if the Info Window is showing.
  ///
  Future<void> hideMarkerInfoWindow(MarkerId markerId) {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance
          .hideMarkerInfoWindow(markerId, mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method hideMarkerInfoWindow on an unmounted GoogleMap instance.');
    }
  }

  /// Returns `true` when the [InfoWindow] is showing, `false` otherwise.
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [showMarkerInfoWindow] to show the Info Window.
  ///   * [hideMarkerInfoWindow] to hide the Info Window.
  Future<bool> isMarkerInfoWindowShown(MarkerId markerId) {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance
          .isMarkerInfoWindowShown(markerId, mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method isMarkerInfoWindowShown on an unmounted GoogleMap instance.');
    }
  }

  /// Returns the current zoom level of the map
  Future<double> getZoomLevel() {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance.getZoomLevel(mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method getZoomLevel on an unmounted GoogleMap instance.');
    }
  }

  /// Returns the image bytes of the map
  Future<Uint8List?> takeSnapshot() {
    if (_googleMapState.mounted) {
      return GoogleMapsFlutterPlatform.instance.takeSnapshot(mapId: mapId);
    } else {
      throw MapStateException(
          'Cannot call method takeSnapshot on an unmounted GoogleMap instance.');
    }
  }

  /// Disposes of the platform resources
  void dispose() {
    GoogleMapsFlutterPlatform.instance.dispose(mapId: mapId);
  }
}
