// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: library_private_types_in_public_api

part of google_maps_flutter;

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

  /// State map of the stream subscriptions for this controller, used internally.
  ///
  /// The map stores a [StreamSubscription] as key and a [bool] as value.
  /// Each [StreamSubscription] represents a subscription to an event from the native side.
  /// The corresponding [bool] indicates whether the subscription has been cancelled `true` or not `false`.
  ///
  /// This map allows for efficient management of subscriptions, facilitating operations
  /// like mass cancellation during controller disposal.
  ///
  /// This field is private to prevent external mutation. Access is provided through
  /// the [streamSubscriptionsState] getter, which returns an unmodifiable view of this map.
  final Map<StreamSubscription<dynamic>, bool> _streamSubscriptionsState =
      <StreamSubscription<dynamic>, bool>{};

  /// Returns an unmodifiable view of the map that holds the active StreamSubscriptions
  /// and their corresponding states.
  ///
  /// This getter provides a way to inspect the current state of active StreamSubscriptions
  /// in the [GoogleMapController] class without allowing any outside mutations.
  ///
  /// The map contains [StreamSubscription] instances as keys, and [bool] as values.
  /// A value of `true` indicates that the subscription is active and `false` indicates it is disposed.
  ///
  /// This is useful in situations where the need arises to monitor or debug the
  /// lifecycle of various StreamSubscriptions handled within this class.
  Map<StreamSubscription<dynamic>, bool> get streamSubscriptionsState =>
      Map<StreamSubscription<dynamic>, bool>.unmodifiable(
          _streamSubscriptionsState);

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

  /// The state object of the [GoogleMap] widget.
  ///
  /// This instance holds important properties and methods that are essential for
  /// the behavior and state of the [GoogleMap] widget.
  final _GoogleMapState _googleMapState;

  /// Subscribes to the various event streams from the [GoogleMapsFlutterPlatform] for a specific map.
  ///
  /// This method takes the `mapId` as an argument and uses it to subscribe to the various streams available from the [GoogleMapsFlutterPlatform].
  /// It only subscribes to the streams if the corresponding callback from the widget is not null. This includes streams for camera movements,
  /// marker taps, marker drag events, info window taps, polyline taps, polygon taps, circle taps, map taps, and map long presses.
  ///
  /// Each subscription is added to [_streamSubscriptionsState] for lifecycle management.
  ///
  /// - [mapId] is the identifier of the map for which to initiate the streams.
  void _connectStreams(int mapId) {
    if (_googleMapState.widget.onCameraMoveStarted != null) {
      _addSubscription(
        GoogleMapsFlutterPlatform.instance
            .onCameraMoveStarted(mapId: mapId)
            .listen((_) => _googleMapState.widget.onCameraMoveStarted!()),
      );
    }
    if (_googleMapState.widget.onCameraMove != null) {
      _addSubscription(
        GoogleMapsFlutterPlatform.instance.onCameraMove(mapId: mapId).listen(
              (CameraMoveEvent e) =>
                  _googleMapState.widget.onCameraMove!(e.value),
            ),
      );
    }
    if (_googleMapState.widget.onCameraIdle != null) {
      _addSubscription(
        GoogleMapsFlutterPlatform.instance
            .onCameraIdle(mapId: mapId)
            .listen((_) => _googleMapState.widget.onCameraIdle!()),
      );
    }

    _addSubscription(
      GoogleMapsFlutterPlatform.instance
          .onMarkerTap(mapId: mapId)
          .listen((MarkerTapEvent e) => _googleMapState.onMarkerTap(e.value)),
    );

    _addSubscription(
      GoogleMapsFlutterPlatform.instance.onMarkerDragStart(mapId: mapId).listen(
            (MarkerDragStartEvent e) =>
                _googleMapState.onMarkerDragStart(e.value, e.position),
          ),
    );

    _addSubscription(
      GoogleMapsFlutterPlatform.instance.onMarkerDrag(mapId: mapId).listen(
            (MarkerDragEvent e) =>
                _googleMapState.onMarkerDrag(e.value, e.position),
          ),
    );

    _addSubscription(
      GoogleMapsFlutterPlatform.instance.onMarkerDragEnd(mapId: mapId).listen(
            (MarkerDragEndEvent e) =>
                _googleMapState.onMarkerDragEnd(e.value, e.position),
          ),
    );

    _addSubscription(
      GoogleMapsFlutterPlatform.instance.onInfoWindowTap(mapId: mapId).listen(
            (InfoWindowTapEvent e) => _googleMapState.onInfoWindowTap(e.value),
          ),
    );
    _addSubscription(
      GoogleMapsFlutterPlatform.instance.onPolylineTap(mapId: mapId).listen(
            (PolylineTapEvent e) => _googleMapState.onPolylineTap(e.value),
          ),
    );
    _addSubscription(
      GoogleMapsFlutterPlatform.instance.onPolygonTap(mapId: mapId).listen(
            (PolygonTapEvent e) => _googleMapState.onPolygonTap(e.value),
          ),
    );
    _addSubscription(
      GoogleMapsFlutterPlatform.instance
          .onCircleTap(mapId: mapId)
          .listen((CircleTapEvent e) => _googleMapState.onCircleTap(e.value)),
    );
    _addSubscription(
      GoogleMapsFlutterPlatform.instance
          .onTap(mapId: mapId)
          .listen((MapTapEvent e) => _googleMapState.onTap(e.position)),
    );
    _addSubscription(
      GoogleMapsFlutterPlatform.instance.onLongPress(mapId: mapId).listen(
            (MapLongPressEvent e) => _googleMapState.onLongPress(e.position),
          ),
    );
  }

  /// Adds a new stream subscription to the [_streamSubscriptionsState] map.
  ///
  /// The method takes a [StreamSubscription] and sets its status to `false`
  /// in the [_streamSubscriptionsState] map. The `false` status indicates that the subscription
  /// is currently active and has not been canceled yet.
  ///
  /// The [_streamSubscriptionsState] map manages all active stream subscriptions
  /// associated with this instance, which facilitates their lifecycle management
  /// and ensures that they are properly canceled and disposed when necessary.
  ///
  /// [subscription]: A [StreamSubscription] that will be managed by the [_streamSubscriptionsState] map.
  void _addSubscription(StreamSubscription<dynamic> subscription) {
    _streamSubscriptionsState[subscription] = false;
  }

  /// Updates configuration options of the map user interface.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateMapConfiguration(MapConfiguration update) {
    return GoogleMapsFlutterPlatform.instance
        .updateMapConfiguration(update, mapId: mapId);
  }

  /// Updates marker configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateMarkers(MarkerUpdates markerUpdates) {
    return GoogleMapsFlutterPlatform.instance
        .updateMarkers(markerUpdates, mapId: mapId);
  }

  /// Updates polygon configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updatePolygons(PolygonUpdates polygonUpdates) {
    return GoogleMapsFlutterPlatform.instance
        .updatePolygons(polygonUpdates, mapId: mapId);
  }

  /// Updates polyline configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updatePolylines(PolylineUpdates polylineUpdates) {
    return GoogleMapsFlutterPlatform.instance
        .updatePolylines(polylineUpdates, mapId: mapId);
  }

  /// Updates circle configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateCircles(CircleUpdates circleUpdates) {
    return GoogleMapsFlutterPlatform.instance
        .updateCircles(circleUpdates, mapId: mapId);
  }

  /// Updates tile overlays configuration.
  ///
  /// Change listeners are notified once the update has been made on the
  /// platform side.
  ///
  /// The returned [Future] completes after listeners have been notified.
  Future<void> _updateTileOverlays(Set<TileOverlay> newTileOverlays) {
    return GoogleMapsFlutterPlatform.instance
        .updateTileOverlays(newTileOverlays: newTileOverlays, mapId: mapId);
  }

  /// Clears the tile cache so that all tiles will be requested again from the
  /// [TileProvider].
  ///
  /// The current tiles from this tile overlay will also be
  /// cleared from the map after calling this method. The API maintains a small
  /// in-memory cache of tiles. If you want to cache tiles for longer, you
  /// should implement an on-disk cache.
  Future<void> clearTileCache(TileOverlayId tileOverlayId) async {
    return GoogleMapsFlutterPlatform.instance
        .clearTileCache(tileOverlayId, mapId: mapId);
  }

  /// Starts an animated change of the map camera position.
  ///
  /// The returned [Future] completes after the change has been started on the
  /// platform side.
  Future<void> animateCamera(CameraUpdate cameraUpdate) {
    return GoogleMapsFlutterPlatform.instance
        .animateCamera(cameraUpdate, mapId: mapId);
  }

  /// Changes the map camera position.
  ///
  /// The returned [Future] completes after the change has been made on the
  /// platform side.
  Future<void> moveCamera(CameraUpdate cameraUpdate) {
    return GoogleMapsFlutterPlatform.instance
        .moveCamera(cameraUpdate, mapId: mapId);
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
  Future<void> setMapStyle(String? mapStyle) {
    return GoogleMapsFlutterPlatform.instance
        .setMapStyle(mapStyle, mapId: mapId);
  }

  /// Return [LatLngBounds] defining the region that is visible in a map.
  Future<LatLngBounds> getVisibleRegion() {
    return GoogleMapsFlutterPlatform.instance.getVisibleRegion(mapId: mapId);
  }

  /// Return [ScreenCoordinate] of the [LatLng] in the current map view.
  ///
  /// A projection is used to translate between on screen location and geographic coordinates.
  /// Screen location is in screen pixels (not display pixels) with respect to the top left corner
  /// of the map, not necessarily of the whole screen.
  Future<ScreenCoordinate> getScreenCoordinate(LatLng latLng) {
    return GoogleMapsFlutterPlatform.instance
        .getScreenCoordinate(latLng, mapId: mapId);
  }

  /// Returns [LatLng] corresponding to the [ScreenCoordinate] in the current map view.
  ///
  /// Returned [LatLng] corresponds to a screen location. The screen location is specified in screen
  /// pixels (not display pixels) relative to the top left of the map, not top left of the whole screen.
  Future<LatLng> getLatLng(ScreenCoordinate screenCoordinate) {
    return GoogleMapsFlutterPlatform.instance
        .getLatLng(screenCoordinate, mapId: mapId);
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
    return GoogleMapsFlutterPlatform.instance
        .showMarkerInfoWindow(markerId, mapId: mapId);
  }

  /// Programmatically hide the Info Window for a [Marker].
  ///
  /// The `markerId` must match one of the markers on the map.
  /// An invalid `markerId` triggers an "Invalid markerId" error.
  ///
  /// * See also:
  ///   * [showMarkerInfoWindow] to show the Info Window.
  ///   * [isMarkerInfoWindowShown] to check if the Info Window is showing.
  Future<void> hideMarkerInfoWindow(MarkerId markerId) {
    return GoogleMapsFlutterPlatform.instance
        .hideMarkerInfoWindow(markerId, mapId: mapId);
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
    return GoogleMapsFlutterPlatform.instance
        .isMarkerInfoWindowShown(markerId, mapId: mapId);
  }

  /// Returns the current zoom level of the map
  Future<double> getZoomLevel() {
    return GoogleMapsFlutterPlatform.instance.getZoomLevel(mapId: mapId);
  }

  /// Returns the image bytes of the map
  Future<Uint8List?> takeSnapshot() {
    return GoogleMapsFlutterPlatform.instance.takeSnapshot(mapId: mapId);
  }

  /// Disposes of the platform resources
  void dispose() {
    for (final StreamSubscription<dynamic> subscription
        in _streamSubscriptionsState.keys) {
      subscription.cancel().then((void value) {
        _streamSubscriptionsState[subscription] = true;
      });
    }
    _streamSubscriptionsState.clear();
    GoogleMapsFlutterPlatform.instance.dispose(mapId: mapId);
  }
}
