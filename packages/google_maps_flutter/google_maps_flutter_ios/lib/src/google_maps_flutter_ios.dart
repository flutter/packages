// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:stream_transform/stream_transform.dart';

import 'google_map_inspector_ios.dart';
import 'messages.g.dart';

// TODO(stuartmorgan): Remove the dependency on platform interface toJson
// methods. Channel serialization details should all be package-internal.

/// The non-test implementation of `_apiProvider`.
MapsApi _productionApiProvider(int mapId) {
  return MapsApi(messageChannelSuffix: mapId.toString());
}

/// Error thrown when an unknown map ID is provided to a method channel API.
class UnknownMapIDError extends Error {
  /// Creates an assertion error with the provided [mapId] and optional
  /// [message].
  UnknownMapIDError(this.mapId, [this.message]);

  /// The unknown ID.
  final int mapId;

  /// Message describing the assertion error.
  final Object? message;

  @override
  String toString() {
    if (message != null) {
      return 'Unknown map ID $mapId: ${Error.safeToString(message)}';
    }
    return 'Unknown map ID $mapId';
  }
}

/// An implementation of [GoogleMapsFlutterPlatform] for iOS.
class GoogleMapsFlutterIOS extends GoogleMapsFlutterPlatform {
  /// Creates a new Android maps implementation instance.
  GoogleMapsFlutterIOS({
    @visibleForTesting MapsApi Function(int mapId)? apiProvider,
  }) : _apiProvider = apiProvider ?? _productionApiProvider;

  /// Registers the iOS implementation of GoogleMapsFlutterPlatform.
  static void registerWith() {
    GoogleMapsFlutterPlatform.instance = GoogleMapsFlutterIOS();
  }

  // Keep a collection of id -> channel
  // Every method call passes the int mapId
  final Map<int, MethodChannel> _channels = <int, MethodChannel>{};

  final Map<int, MapsApi> _hostMaps = <int, MapsApi>{};

  // A method to create MapsApi instances, which can be overridden for testing.
  final MapsApi Function(int mapId) _apiProvider;

  /// Accesses the MapsApi associated to the passed mapId.
  MapsApi _hostApi(int mapId) {
    final MapsApi? api = _hostMaps[mapId];
    if (api == null) {
      throw UnknownMapIDError(mapId);
    }
    return api;
  }

  // Keep a collection of mapId to a map of TileOverlays.
  final Map<int, Map<TileOverlayId, TileOverlay>> _tileOverlays =
      <int, Map<TileOverlayId, TileOverlay>>{};

  /// Returns the channel for [mapId], creating it if it doesn't already exist.
  @visibleForTesting
  MethodChannel ensureChannelInitialized(int mapId) {
    MethodChannel? channel = _channels[mapId];
    if (channel == null) {
      channel = MethodChannel('plugins.flutter.dev/google_maps_ios_$mapId');
      channel.setMethodCallHandler(
          (MethodCall call) => _handleMethodCall(call, mapId));
      _channels[mapId] = channel;
    }
    return channel;
  }

  /// Returns the API instance for [mapId], creating it if it doesn't already
  /// exist.
  @visibleForTesting
  MapsApi ensureApiInitialized(int mapId) {
    MapsApi? api = _hostMaps[mapId];
    if (api == null) {
      api = _apiProvider(mapId);
      _hostMaps[mapId] ??= api;
    }
    return api;
  }

  @override
  Future<void> init(int mapId) {
    ensureChannelInitialized(mapId);
    final MapsApi hostApi = ensureApiInitialized(mapId);
    return hostApi.waitForMap();
  }

  @override
  void dispose({required int mapId}) {
    // Noop!
  }

  // The controller we need to broadcast the different events coming
  // from handleMethodCall.
  //
  // It is a `broadcast` because multiple controllers will connect to
  // different stream views of this Controller.
  final StreamController<MapEvent<Object?>> _mapEventStreamController =
      StreamController<MapEvent<Object?>>.broadcast();

  // Returns a filtered view of the events in the _controller, by mapId.
  Stream<MapEvent<Object?>> _events(int mapId) =>
      _mapEventStreamController.stream
          .where((MapEvent<Object?> event) => event.mapId == mapId);

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

  Future<dynamic> _handleMethodCall(MethodCall call, int mapId) async {
    switch (call.method) {
      case 'camera#onMoveStarted':
        _mapEventStreamController.add(CameraMoveStartedEvent(mapId));
      case 'camera#onMove':
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        _mapEventStreamController.add(CameraMoveEvent(
          mapId,
          CameraPosition.fromMap(arguments['position'])!,
        ));
      case 'camera#onIdle':
        _mapEventStreamController.add(CameraIdleEvent(mapId));
      case 'marker#onTap':
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        _mapEventStreamController.add(MarkerTapEvent(
          mapId,
          MarkerId(arguments['markerId']! as String),
        ));
      case 'marker#onDragStart':
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        _mapEventStreamController.add(MarkerDragStartEvent(
          mapId,
          LatLng.fromJson(arguments['position'])!,
          MarkerId(arguments['markerId']! as String),
        ));
      case 'marker#onDrag':
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        _mapEventStreamController.add(MarkerDragEvent(
          mapId,
          LatLng.fromJson(arguments['position'])!,
          MarkerId(arguments['markerId']! as String),
        ));
      case 'marker#onDragEnd':
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        _mapEventStreamController.add(MarkerDragEndEvent(
          mapId,
          LatLng.fromJson(arguments['position'])!,
          MarkerId(arguments['markerId']! as String),
        ));
      case 'infoWindow#onTap':
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        _mapEventStreamController.add(InfoWindowTapEvent(
          mapId,
          MarkerId(arguments['markerId']! as String),
        ));
      case 'polyline#onTap':
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        _mapEventStreamController.add(PolylineTapEvent(
          mapId,
          PolylineId(arguments['polylineId']! as String),
        ));
      case 'polygon#onTap':
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        _mapEventStreamController.add(PolygonTapEvent(
          mapId,
          PolygonId(arguments['polygonId']! as String),
        ));
      case 'circle#onTap':
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        _mapEventStreamController.add(CircleTapEvent(
          mapId,
          CircleId(arguments['circleId']! as String),
        ));
      case 'map#onTap':
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        _mapEventStreamController.add(MapTapEvent(
          mapId,
          LatLng.fromJson(arguments['position'])!,
        ));
      case 'map#onLongPress':
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        _mapEventStreamController.add(MapLongPressEvent(
          mapId,
          LatLng.fromJson(arguments['position'])!,
        ));
      case 'tileOverlay#getTile':
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        final Map<TileOverlayId, TileOverlay>? tileOverlaysForThisMap =
            _tileOverlays[mapId];
        final String tileOverlayId = arguments['tileOverlayId']! as String;
        final TileOverlay? tileOverlay =
            tileOverlaysForThisMap?[TileOverlayId(tileOverlayId)];
        final TileProvider? tileProvider = tileOverlay?.tileProvider;
        if (tileProvider == null) {
          return TileProvider.noTile.toJson();
        }
        final Tile tile = await tileProvider.getTile(
          arguments['x']! as int,
          arguments['y']! as int,
          arguments['zoom'] as int?,
        );
        return tile.toJson();
      default:
        throw MissingPluginException();
    }
  }

  /// Returns the arguments of [call] as typed string-keyed Map.
  ///
  /// This does not do any type validation, so is only safe to call if the
  /// arguments are known to be a map.
  Map<String, Object?> _getArgumentDictionary(MethodCall call) {
    return (call.arguments as Map<Object?, Object?>).cast<String, Object?>();
  }

  @override
  Future<void> updateMapConfiguration(
    MapConfiguration configuration, {
    required int mapId,
  }) {
    return updateMapOptions(_jsonForMapConfiguration(configuration),
        mapId: mapId);
  }

  @override
  Future<void> updateMapOptions(
    Map<String, dynamic> optionsUpdate, {
    required int mapId,
  }) {
    return _hostApi(mapId)
        .updateMapConfiguration(PlatformMapConfiguration(json: optionsUpdate));
  }

  @override
  Future<void> updateMarkers(
    MarkerUpdates markerUpdates, {
    required int mapId,
  }) {
    return _hostApi(mapId).updateMarkers(
      markerUpdates.markersToAdd.map(_platformMarkerFromMarker).toList(),
      markerUpdates.markersToChange.map(_platformMarkerFromMarker).toList(),
      markerUpdates.markerIdsToRemove.map((MarkerId id) => id.value).toList(),
    );
  }

  @override
  Future<void> updatePolygons(
    PolygonUpdates polygonUpdates, {
    required int mapId,
  }) {
    return _hostApi(mapId).updatePolygons(
      polygonUpdates.polygonsToAdd.map(_platformPolygonFromPolygon).toList(),
      polygonUpdates.polygonsToChange.map(_platformPolygonFromPolygon).toList(),
      polygonUpdates.polygonIdsToRemove
          .map((PolygonId id) => id.value)
          .toList(),
    );
  }

  @override
  Future<void> updatePolylines(
    PolylineUpdates polylineUpdates, {
    required int mapId,
  }) {
    return _hostApi(mapId).updatePolylines(
      polylineUpdates.polylinesToAdd
          .map(_platformPolylineFromPolyline)
          .toList(),
      polylineUpdates.polylinesToChange
          .map(_platformPolylineFromPolyline)
          .toList(),
      polylineUpdates.polylineIdsToRemove
          .map((PolylineId id) => id.value)
          .toList(),
    );
  }

  @override
  Future<void> updateCircles(
    CircleUpdates circleUpdates, {
    required int mapId,
  }) {
    return _hostApi(mapId).updateCircles(
      circleUpdates.circlesToAdd.map(_platformCircleFromCircle).toList(),
      circleUpdates.circlesToChange.map(_platformCircleFromCircle).toList(),
      circleUpdates.circleIdsToRemove.map((CircleId id) => id.value).toList(),
    );
  }

  @override
  Future<void> updateTileOverlays({
    required Set<TileOverlay> newTileOverlays,
    required int mapId,
  }) {
    final Map<TileOverlayId, TileOverlay>? currentTileOverlays =
        _tileOverlays[mapId];
    final Set<TileOverlay> previousSet = currentTileOverlays != null
        ? currentTileOverlays.values.toSet()
        : <TileOverlay>{};
    final _TileOverlayUpdates updates =
        _TileOverlayUpdates.from(previousSet, newTileOverlays);
    _tileOverlays[mapId] = keyTileOverlayId(newTileOverlays);
    return _hostApi(mapId).updateTileOverlays(
      updates.tileOverlaysToAdd
          .map(_platformTileOverlayFromTileOverlay)
          .toList(),
      updates.tileOverlaysToChange
          .map(_platformTileOverlayFromTileOverlay)
          .toList(),
      updates.tileOverlayIdsToRemove
          .map((TileOverlayId id) => id.value)
          .toList(),
    );
  }

  @override
  Future<void> clearTileCache(
    TileOverlayId tileOverlayId, {
    required int mapId,
  }) {
    return _hostApi(mapId).clearTileCache(tileOverlayId.value);
  }

  @override
  Future<void> animateCamera(
    CameraUpdate cameraUpdate, {
    required int mapId,
  }) {
    return _hostApi(mapId)
        .animateCamera(PlatformCameraUpdate(json: cameraUpdate.toJson()));
  }

  @override
  Future<void> moveCamera(
    CameraUpdate cameraUpdate, {
    required int mapId,
  }) {
    return _hostApi(mapId)
        .moveCamera(PlatformCameraUpdate(json: cameraUpdate.toJson()));
  }

  @override
  Future<void> setMapStyle(
    String? mapStyle, {
    required int mapId,
  }) async {
    final String? errorDescription =
        await _hostApi(mapId).setStyle(mapStyle ?? '');
    if (errorDescription != null) {
      throw MapStyleException(errorDescription);
    }
  }

  @override
  Future<LatLngBounds> getVisibleRegion({
    required int mapId,
  }) async {
    return _latLngBoundsFromPlatformLatLngBounds(
        await _hostApi(mapId).getVisibleRegion());
  }

  @override
  Future<ScreenCoordinate> getScreenCoordinate(
    LatLng latLng, {
    required int mapId,
  }) async {
    return _screenCoordinateFromPlatformPoint(await _hostApi(mapId)
        .getScreenCoordinate(_platformLatLngFromLatLng(latLng)));
  }

  @override
  Future<LatLng> getLatLng(
    ScreenCoordinate screenCoordinate, {
    required int mapId,
  }) async {
    return _latLngFromPlatformLatLng(await _hostApi(mapId)
        .getLatLng(_platformPointFromScreenCoordinate(screenCoordinate)));
  }

  @override
  Future<void> showMarkerInfoWindow(
    MarkerId markerId, {
    required int mapId,
  }) {
    return _hostApi(mapId).showInfoWindow(markerId.value);
  }

  @override
  Future<void> hideMarkerInfoWindow(
    MarkerId markerId, {
    required int mapId,
  }) {
    return _hostApi(mapId).hideInfoWindow(markerId.value);
  }

  @override
  Future<bool> isMarkerInfoWindowShown(
    MarkerId markerId, {
    required int mapId,
  }) {
    return _hostApi(mapId).isInfoWindowShown(markerId.value);
  }

  @override
  Future<double> getZoomLevel({
    required int mapId,
  }) {
    return _hostApi(mapId).getZoomLevel();
  }

  @override
  Future<Uint8List?> takeSnapshot({
    required int mapId,
  }) {
    return _hostApi(mapId).takeSnapshot();
  }

  @override
  Future<String?> getStyleError({required int mapId}) {
    return _hostApi(mapId).getLastStyleError();
  }

  Widget _buildView(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required MapWidgetConfiguration widgetConfiguration,
    MapObjects mapObjects = const MapObjects(),
    Map<String, dynamic> mapOptions = const <String, dynamic>{},
  }) {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'initialCameraPosition':
          widgetConfiguration.initialCameraPosition.toMap(),
      'options': mapOptions,
      'markersToAdd': serializeMarkerSet(mapObjects.markers),
      'polygonsToAdd': serializePolygonSet(mapObjects.polygons),
      'polylinesToAdd': serializePolylineSet(mapObjects.polylines),
      'circlesToAdd': serializeCircleSet(mapObjects.circles),
      'tileOverlaysToAdd': serializeTileOverlaySet(mapObjects.tileOverlays),
    };

    return UiKitView(
      viewType: 'plugins.flutter.dev/google_maps_ios',
      onPlatformViewCreated: onPlatformViewCreated,
      gestureRecognizers: widgetConfiguration.gestureRecognizers,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  @override
  Widget buildViewWithConfiguration(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required MapWidgetConfiguration widgetConfiguration,
    MapConfiguration mapConfiguration = const MapConfiguration(),
    MapObjects mapObjects = const MapObjects(),
  }) {
    return _buildView(
      creationId,
      onPlatformViewCreated,
      widgetConfiguration: widgetConfiguration,
      mapObjects: mapObjects,
      mapOptions: _jsonForMapConfiguration(mapConfiguration),
    );
  }

  @override
  Widget buildViewWithTextDirection(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required CameraPosition initialCameraPosition,
    required TextDirection textDirection,
    Set<Marker> markers = const <Marker>{},
    Set<Polygon> polygons = const <Polygon>{},
    Set<Polyline> polylines = const <Polyline>{},
    Set<Circle> circles = const <Circle>{},
    Set<TileOverlay> tileOverlays = const <TileOverlay>{},
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
    Map<String, dynamic> mapOptions = const <String, dynamic>{},
  }) {
    return _buildView(
      creationId,
      onPlatformViewCreated,
      widgetConfiguration: MapWidgetConfiguration(
          initialCameraPosition: initialCameraPosition,
          textDirection: textDirection),
      mapObjects: MapObjects(
          markers: markers,
          polygons: polygons,
          polylines: polylines,
          circles: circles,
          tileOverlays: tileOverlays),
      mapOptions: mapOptions,
    );
  }

  @override
  Widget buildView(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required CameraPosition initialCameraPosition,
    Set<Marker> markers = const <Marker>{},
    Set<Polygon> polygons = const <Polygon>{},
    Set<Polyline> polylines = const <Polyline>{},
    Set<Circle> circles = const <Circle>{},
    Set<TileOverlay> tileOverlays = const <TileOverlay>{},
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
    Map<String, dynamic> mapOptions = const <String, dynamic>{},
  }) {
    return buildViewWithTextDirection(
      creationId,
      onPlatformViewCreated,
      initialCameraPosition: initialCameraPosition,
      textDirection: TextDirection.ltr,
      markers: markers,
      polygons: polygons,
      polylines: polylines,
      circles: circles,
      tileOverlays: tileOverlays,
      gestureRecognizers: gestureRecognizers,
      mapOptions: mapOptions,
    );
  }

  @override
  @visibleForTesting
  void enableDebugInspection() {
    GoogleMapsInspectorPlatform.instance = GoogleMapsInspectorIOS((int mapId) =>
        MapsInspectorApi(messageChannelSuffix: mapId.toString()));
  }

  static LatLng _latLngFromPlatformLatLng(PlatformLatLng latLng) {
    return LatLng(latLng.latitude, latLng.longitude);
  }

  static PlatformLatLng _platformLatLngFromLatLng(LatLng latLng) {
    return PlatformLatLng(
        latitude: latLng.latitude, longitude: latLng.longitude);
  }

  static ScreenCoordinate _screenCoordinateFromPlatformPoint(
      PlatformPoint point) {
    return ScreenCoordinate(x: point.x.round(), y: point.y.round());
  }

  static PlatformPoint _platformPointFromScreenCoordinate(
      ScreenCoordinate coordinate) {
    return PlatformPoint(
        x: coordinate.x.toDouble(), y: coordinate.y.toDouble());
  }

  static LatLngBounds _latLngBoundsFromPlatformLatLngBounds(
      PlatformLatLngBounds bounds) {
    return LatLngBounds(
        southwest: _latLngFromPlatformLatLng(bounds.southwest),
        northeast: _latLngFromPlatformLatLng(bounds.northeast));
  }

  static PlatformCircle _platformCircleFromCircle(Circle circle) {
    return PlatformCircle(json: circle.toJson());
  }

  static PlatformMarker _platformMarkerFromMarker(Marker marker) {
    return PlatformMarker(json: marker.toJson());
  }

  static PlatformPolygon _platformPolygonFromPolygon(Polygon polygon) {
    return PlatformPolygon(json: polygon.toJson());
  }

  static PlatformPolyline _platformPolylineFromPolyline(Polyline polyline) {
    return PlatformPolyline(json: polyline.toJson());
  }

  static PlatformTileOverlay _platformTileOverlayFromTileOverlay(
      TileOverlay tileOverlay) {
    return PlatformTileOverlay(json: tileOverlay.toJson());
  }
}

Map<String, Object> _jsonForMapConfiguration(MapConfiguration config) {
  final EdgeInsets? padding = config.padding;
  return <String, Object>{
    if (config.compassEnabled != null) 'compassEnabled': config.compassEnabled!,
    if (config.mapToolbarEnabled != null)
      'mapToolbarEnabled': config.mapToolbarEnabled!,
    if (config.cameraTargetBounds != null)
      'cameraTargetBounds': config.cameraTargetBounds!.toJson(),
    if (config.mapType != null) 'mapType': config.mapType!.index,
    if (config.minMaxZoomPreference != null)
      'minMaxZoomPreference': config.minMaxZoomPreference!.toJson(),
    if (config.rotateGesturesEnabled != null)
      'rotateGesturesEnabled': config.rotateGesturesEnabled!,
    if (config.scrollGesturesEnabled != null)
      'scrollGesturesEnabled': config.scrollGesturesEnabled!,
    if (config.tiltGesturesEnabled != null)
      'tiltGesturesEnabled': config.tiltGesturesEnabled!,
    if (config.zoomControlsEnabled != null)
      'zoomControlsEnabled': config.zoomControlsEnabled!,
    if (config.zoomGesturesEnabled != null)
      'zoomGesturesEnabled': config.zoomGesturesEnabled!,
    if (config.liteModeEnabled != null)
      'liteModeEnabled': config.liteModeEnabled!,
    if (config.trackCameraPosition != null)
      'trackCameraPosition': config.trackCameraPosition!,
    if (config.myLocationEnabled != null)
      'myLocationEnabled': config.myLocationEnabled!,
    if (config.myLocationButtonEnabled != null)
      'myLocationButtonEnabled': config.myLocationButtonEnabled!,
    if (padding != null)
      'padding': <double>[
        padding.top,
        padding.left,
        padding.bottom,
        padding.right,
      ],
    if (config.indoorViewEnabled != null)
      'indoorEnabled': config.indoorViewEnabled!,
    if (config.trafficEnabled != null) 'trafficEnabled': config.trafficEnabled!,
    if (config.buildingsEnabled != null)
      'buildingsEnabled': config.buildingsEnabled!,
    if (config.cloudMapId != null) 'cloudMapId': config.cloudMapId!,
    if (config.style != null) 'style': config.style!,
  };
}

/// Update specification for a set of [TileOverlay]s.
// TODO(stuartmorgan): Fix the missing export of this class in the platform
// interface, and remove this copy.
class _TileOverlayUpdates extends MapsObjectUpdates<TileOverlay> {
  /// Computes [TileOverlayUpdates] given previous and current [TileOverlay]s.
  _TileOverlayUpdates.from(super.previous, super.current)
      : super.from(objectName: 'tileOverlay');

  /// Set of TileOverlays to be added in this update.
  Set<TileOverlay> get tileOverlaysToAdd => objectsToAdd;

  /// Set of TileOverlayIds to be removed in this update.
  Set<TileOverlayId> get tileOverlayIdsToRemove =>
      objectIdsToRemove.cast<TileOverlayId>();

  /// Set of TileOverlays to be changed in this update.
  Set<TileOverlay> get tileOverlaysToChange => objectsToChange;
}
