// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../google_maps_flutter_web.dart';

/// The web implementation of [GoogleMapsFlutterPlatform].
///
/// This class implements the `package:google_maps_flutter` functionality for the web.
class GoogleMapsPlugin extends GoogleMapsFlutterPlatform {
  /// Registers this class as the default instance of [GoogleMapsFlutterPlatform].
  static void registerWith(Registrar registrar) {
    GoogleMapsFlutterPlatform.instance = GoogleMapsPlugin();
  }

  // A cache of map controllers by map Id.
  Map<int, GoogleMapController> _mapById = <int, GoogleMapController>{};

  /// Allows tests to inject controllers without going through the buildView flow.
  @visibleForTesting
  // ignore: use_setters_to_change_properties
  void debugSetMapById(Map<int, GoogleMapController> mapById) {
    _mapById = mapById;
  }

  // Convenience getter for a stream of events filtered by their mapId.
  Stream<MapEvent<Object?>> _events(int mapId) => _map(mapId).events;

  /// Retrieve a map controller by its mapId.
  GoogleMapController _map(int mapId) {
    final GoogleMapController? controller = _mapById[mapId];
    assert(controller != null,
        'Maps cannot be retrieved before calling buildView!');
    return controller!;
  }

  @override
  Future<void> init(int mapId) async {
    // The internal instance of our controller is initialized eagerly in `buildView`,
    // so we don't have to do anything in this method, which is left intentionally
    // blank.
    assert(_mapById[mapId] != null, 'Must call buildWidget before init!');
  }

  /// Updates the options of a given `mapId`.
  ///
  /// This attempts to merge the new `optionsUpdate` passed in, with the previous
  /// options passed to the map (in other updates, or when creating it).
  @override
  Future<void> updateMapConfiguration(
    MapConfiguration update, {
    required int mapId,
  }) async {
    _map(mapId).updateMapConfiguration(update);
  }

  /// Applies the passed in `markerUpdates` to the `mapId`.
  @override
  Future<void> updateMarkers(
    MarkerUpdates markerUpdates, {
    required int mapId,
  }) async {
    await _map(mapId).updateMarkers(markerUpdates);
  }

  /// Applies the passed in `polygonUpdates` to the `mapId`.
  @override
  Future<void> updatePolygons(
    PolygonUpdates polygonUpdates, {
    required int mapId,
  }) async {
    _map(mapId).updatePolygons(polygonUpdates);
  }

  /// Applies the passed in `polylineUpdates` to the `mapId`.
  @override
  Future<void> updatePolylines(
    PolylineUpdates polylineUpdates, {
    required int mapId,
  }) async {
    _map(mapId).updatePolylines(polylineUpdates);
  }

  /// Applies the passed in `circleUpdates` to the `mapId`.
  @override
  Future<void> updateCircles(
    CircleUpdates circleUpdates, {
    required int mapId,
  }) async {
    _map(mapId).updateCircles(circleUpdates);
  }

  /// Applies the passed in `heatmapUpdates` to the `mapId`.
  @override
  Future<void> updateHeatmaps(
    HeatmapUpdates heatmapUpdates, {
    required int mapId,
  }) async {
    _map(mapId).updateHeatmaps(heatmapUpdates);
  }

  @override
  Future<void> updateTileOverlays({
    required Set<TileOverlay> newTileOverlays,
    required int mapId,
  }) async {
    _map(mapId).updateTileOverlays(newTileOverlays);
  }

  @override
  Future<void> updateClusterManagers(
    ClusterManagerUpdates clusterManagerUpdates, {
    required int mapId,
  }) async {
    _map(mapId).updateClusterManagers(clusterManagerUpdates);
  }

  @override
  Future<void> clearTileCache(
    TileOverlayId tileOverlayId, {
    required int mapId,
  }) async {
    _map(mapId).clearTileCache(tileOverlayId);
  }

  /// Applies the given `cameraUpdate` to the current viewport (with animation).
  @override
  Future<void> animateCamera(
    CameraUpdate cameraUpdate, {
    required int mapId,
  }) async {
    return moveCamera(cameraUpdate, mapId: mapId);
  }

  /// Applies the given `cameraUpdate` to the current viewport.
  @override
  Future<void> moveCamera(
    CameraUpdate cameraUpdate, {
    required int mapId,
  }) async {
    return _map(mapId).moveCamera(cameraUpdate);
  }

  /// Sets the passed-in `mapStyle` to the map.
  ///
  /// This function just adds a 'styles' option to the current map options.
  ///
  /// Subsequent calls to this method override previous calls, you need to
  /// pass full styles.
  @override
  Future<void> setMapStyle(
    String? mapStyle, {
    required int mapId,
  }) async {
    _map(mapId).updateStyles(_mapStyles(mapStyle));
  }

  /// Returns the bounds of the current viewport.
  @override
  Future<LatLngBounds> getVisibleRegion({
    required int mapId,
  }) {
    return _map(mapId).getVisibleRegion();
  }

  /// Returns the screen coordinate (in pixels) of a given `latLng`.
  @override
  Future<ScreenCoordinate> getScreenCoordinate(
    LatLng latLng, {
    required int mapId,
  }) {
    return _map(mapId).getScreenCoordinate(latLng);
  }

  /// Returns the [LatLng] of a [ScreenCoordinate] of the viewport.
  @override
  Future<LatLng> getLatLng(
    ScreenCoordinate screenCoordinate, {
    required int mapId,
  }) {
    return _map(mapId).getLatLng(screenCoordinate);
  }

  /// Shows the [InfoWindow] (if any) of the [Marker] identified by `markerId`.
  ///
  /// See also:
  ///   * [hideMarkerInfoWindow] to hide the info window.
  ///   * [isMarkerInfoWindowShown] to check if the info window is visible/hidden.
  @override
  Future<void> showMarkerInfoWindow(
    MarkerId markerId, {
    required int mapId,
  }) async {
    _map(mapId).showInfoWindow(markerId);
  }

  /// Hides the [InfoWindow] (if any) of the [Marker] identified by `markerId`.
  ///
  /// See also:
  ///   * [showMarkerInfoWindow] to show the info window.
  ///   * [isMarkerInfoWindowShown] to check if the info window is shown.
  @override
  Future<void> hideMarkerInfoWindow(
    MarkerId markerId, {
    required int mapId,
  }) async {
    _map(mapId).hideInfoWindow(markerId);
  }

  /// Returns true if the [InfoWindow] of the [Marker] identified by `markerId` is shown.
  ///
  /// See also:
  ///   * [showMarkerInfoWindow] to show the info window.
  ///   * [hideMarkerInfoWindow] to hide the info window.
  @override
  Future<bool> isMarkerInfoWindowShown(
    MarkerId markerId, {
    required int mapId,
  }) async {
    return _map(mapId).isInfoWindowShown(markerId);
  }

  /// Returns the zoom level of the `mapId`.
  @override
  Future<double> getZoomLevel({
    required int mapId,
  }) {
    return _map(mapId).getZoomLevel();
  }

  // The following are the 11 possible streams of data from the native side
  // into the plugin

  @override
  Stream<CameraMoveStartedEvent> onCameraMoveStarted({required int mapId}) {
    return _events(mapId).whereType<CameraMoveStartedEvent>();
  }

  @override
  Stream<CameraMoveEvent> onCameraMove({required int mapId}) {
    return _events(mapId).whereType<CameraMoveEvent>();
  }

  @override
  Stream<CameraIdleEvent> onCameraIdle({required int mapId}) {
    return _events(mapId).whereType<CameraIdleEvent>();
  }

  @override
  Stream<MarkerTapEvent> onMarkerTap({required int mapId}) {
    return _events(mapId).whereType<MarkerTapEvent>();
  }

  @override
  Stream<InfoWindowTapEvent> onInfoWindowTap({required int mapId}) {
    return _events(mapId).whereType<InfoWindowTapEvent>();
  }

  @override
  Stream<MarkerDragStartEvent> onMarkerDragStart({required int mapId}) {
    return _events(mapId).whereType<MarkerDragStartEvent>();
  }

  @override
  Stream<MarkerDragEvent> onMarkerDrag({required int mapId}) {
    return _events(mapId).whereType<MarkerDragEvent>();
  }

  @override
  Stream<MarkerDragEndEvent> onMarkerDragEnd({required int mapId}) {
    return _events(mapId).whereType<MarkerDragEndEvent>();
  }

  @override
  Stream<PolylineTapEvent> onPolylineTap({required int mapId}) {
    return _events(mapId).whereType<PolylineTapEvent>();
  }

  @override
  Stream<PolygonTapEvent> onPolygonTap({required int mapId}) {
    return _events(mapId).whereType<PolygonTapEvent>();
  }

  @override
  Stream<CircleTapEvent> onCircleTap({required int mapId}) {
    return _events(mapId).whereType<CircleTapEvent>();
  }

  @override
  Stream<MapTapEvent> onTap({required int mapId}) {
    return _events(mapId).whereType<MapTapEvent>();
  }

  @override
  Stream<MapLongPressEvent> onLongPress({required int mapId}) {
    return _events(mapId).whereType<MapLongPressEvent>();
  }

  @override
  Stream<ClusterTapEvent> onClusterTap({required int mapId}) {
    return _events(mapId).whereType<ClusterTapEvent>();
  }

  @override
  Future<String?> getStyleError({required int mapId}) async {
    return _map(mapId).lastStyleError;
  }

  /// Disposes of the current map. It can't be used afterwards!
  @override
  void dispose({required int mapId}) {
    _map(mapId).dispose();
    _mapById.remove(mapId);
  }

  @override
  Widget buildViewWithConfiguration(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required MapWidgetConfiguration widgetConfiguration,
    MapObjects mapObjects = const MapObjects(),
    MapConfiguration mapConfiguration = const MapConfiguration(),
  }) {
    // Bail fast if we've already rendered this map ID...
    if (_mapById[creationId]?.widget != null) {
      return _mapById[creationId]!.widget!;
    }

    final StreamController<MapEvent<Object?>> controller =
        StreamController<MapEvent<Object?>>.broadcast();

    final GoogleMapController mapController = GoogleMapController(
      mapId: creationId,
      streamController: controller,
      widgetConfiguration: widgetConfiguration,
      mapObjects: mapObjects,
      mapConfiguration: mapConfiguration,
    )..init(); // Initialize the controller

    _mapById[creationId] = mapController;

    mapController.events
        .whereType<WebMapReadyEvent>()
        .first
        .then((WebMapReadyEvent event) {
      assert(creationId == event.mapId,
          'Received WebMapReadyEvent for the wrong map');
      // Notify the plugin now that there's a fully initialized controller.
      onPlatformViewCreated.call(event.mapId);
    });

    assert(mapController.widget != null,
        'The widget of a GoogleMapController cannot be null before calling dispose on it.');

    return mapController.widget!;
  }

  /// Populates [GoogleMapsFlutterInspectorPlatform.instance] to allow
  /// inspecting the platform map state.
  @override
  void enableDebugInspection() {
    GoogleMapsInspectorPlatform.instance = GoogleMapsInspectorWeb(
      (int mapId) => _map(mapId).configuration,
      (int mapId) => _map(mapId).clusterManagersController,
    );
  }
}
