// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:stream_transform/stream_transform.dart';

import 'google_map_inspector_android.dart';
import 'messages.g.dart';
import 'serialization.dart';

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

/// The possible android map renderer types that can be
/// requested from the native Google Maps SDK.
enum AndroidMapRenderer {
  /// Latest renderer type.
  latest,

  /// Legacy renderer type.
  legacy,

  /// Requests the default map renderer type.
  platformDefault,
}

/// An implementation of [GoogleMapsFlutterPlatform] for Android.
class GoogleMapsFlutterAndroid extends GoogleMapsFlutterPlatform {
  /// Creates a new Android maps implementation instance.
  GoogleMapsFlutterAndroid({
    @visibleForTesting MapsApi Function(int mapId)? apiProvider,
  }) : _apiProvider = apiProvider ?? _productionApiProvider;

  /// Registers the Android implementation of GoogleMapsFlutterPlatform.
  static void registerWith() {
    GoogleMapsFlutterPlatform.instance = GoogleMapsFlutterAndroid();
  }

  final Map<int, MapsApi> _hostMaps = <int, MapsApi>{};

  // A method to create MapsApi instances, which can be overridden for testing.
  final MapsApi Function(int mapId) _apiProvider;

  /// The per-map handlers for callbacks from the host side.
  @visibleForTesting
  final Map<int, HostMapMessageHandler> hostMapHandlers =
      <int, HostMapMessageHandler>{};

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

  /// Returns the handler for [mapId], creating it if it doesn't already exist.
  @visibleForTesting
  HostMapMessageHandler ensureHandlerInitialized(int mapId) {
    HostMapMessageHandler? handler = hostMapHandlers[mapId];
    if (handler == null) {
      handler = HostMapMessageHandler(
        mapId,
        _mapEventStreamController,
        tileOverlayProvider: (TileOverlayId tileOverlayId) {
          final Map<TileOverlayId, TileOverlay>? tileOverlaysForMap =
              _tileOverlays[mapId];
          return tileOverlaysForMap?[tileOverlayId];
        },
      );
      hostMapHandlers[mapId] = handler;
    }
    return handler;
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
    ensureHandlerInitialized(mapId);
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

  @override
  Stream<ClusterTapEvent> onClusterTap({required int mapId}) {
    return _events(mapId).whereType<ClusterTapEvent>();
  }

  @override
  Future<void> updateMapConfiguration(
    MapConfiguration configuration, {
    required int mapId,
  }) {
    return _hostApi(mapId).updateMapConfiguration(
        _platformMapConfigurationFromMapConfiguration(configuration));
  }

  @override
  Future<void> updateMapOptions(
    Map<String, dynamic> optionsUpdate, {
    required int mapId,
  }) {
    return _hostApi(mapId).updateMapConfiguration(
        _platformMapConfigurationFromOptionsJson(optionsUpdate));
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
  Future<void> updateHeatmaps(
    HeatmapUpdates heatmapUpdates, {
    required int mapId,
  }) {
    return _hostApi(mapId).updateHeatmaps(
      heatmapUpdates.heatmapsToAdd.map(_platformHeatmapFromHeatmap).toList(),
      heatmapUpdates.heatmapsToChange.map(_platformHeatmapFromHeatmap).toList(),
      heatmapUpdates.heatmapIdsToRemove
          .map((HeatmapId id) => id.value)
          .toList(),
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
  Future<void> updateClusterManagers(
    ClusterManagerUpdates clusterManagerUpdates, {
    required int mapId,
  }) {
    return _hostApi(mapId).updateClusterManagers(
      clusterManagerUpdates.clusterManagersToAdd
          .map(_platformClusterManagerFromClusterManager)
          .toList(),
      clusterManagerUpdates.clusterManagerIdsToRemove
          .map((ClusterManagerId id) => id.value)
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
    final bool success = await _hostApi(mapId).setStyle(mapStyle ?? '');
    if (!success) {
      throw const MapStyleException(_setStyleFailureMessage);
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
  Future<String?> getStyleError({required int mapId}) async {
    return (await _hostApi(mapId).didLastStyleSucceed())
        ? null
        : _setStyleFailureMessage;
  }

  /// Set [GoogleMapsFlutterPlatform] to use [AndroidViewSurface] to build the
  /// Google Maps widget.
  ///
  /// See https://pub.dev/packages/google_maps_flutter_android#display-mode
  /// for more information.
  ///
  /// Currently defaults to false, but the default is subject to change.
  bool useAndroidViewSurface = false;

  /// Requests Google Map Renderer with [AndroidMapRenderer] type.
  ///
  /// See https://pub.dev/packages/google_maps_flutter_android#map-renderer
  /// for more information.
  ///
  /// The renderer must be requested before creating GoogleMap instances as the
  /// renderer can be initialized only once per application context.
  /// Throws a [PlatformException] if method is called multiple times.
  ///
  /// The returned [Future] completes after renderer has been initialized.
  /// Initialized [AndroidMapRenderer] type is returned.
  Future<AndroidMapRenderer> initializeWithRenderer(
      AndroidMapRenderer? rendererType) async {
    PlatformRendererType? preferredRenderer;
    switch (rendererType) {
      case AndroidMapRenderer.latest:
        preferredRenderer = PlatformRendererType.latest;
      case AndroidMapRenderer.legacy:
        preferredRenderer = PlatformRendererType.legacy;
      case AndroidMapRenderer.platformDefault:
      case null:
        preferredRenderer = null;
    }

    final MapsInitializerApi hostApi = MapsInitializerApi();
    final PlatformRendererType initializedRenderer =
        await hostApi.initializeWithPreferredRenderer(preferredRenderer);

    return switch (initializedRenderer) {
      PlatformRendererType.latest => AndroidMapRenderer.latest,
      PlatformRendererType.legacy => AndroidMapRenderer.legacy,
    };
  }

  Widget _buildView(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required PlatformMapConfiguration mapConfiguration,
    required MapWidgetConfiguration widgetConfiguration,
    MapObjects mapObjects = const MapObjects(),
  }) {
    final PlatformMapViewCreationParams creationParams =
        PlatformMapViewCreationParams(
      initialCameraPosition: _platformCameraPositionFromCameraPosition(
          widgetConfiguration.initialCameraPosition),
      mapConfiguration: mapConfiguration,
      initialMarkers:
          mapObjects.markers.map(_platformMarkerFromMarker).toList(),
      initialPolygons:
          mapObjects.polygons.map(_platformPolygonFromPolygon).toList(),
      initialPolylines:
          mapObjects.polylines.map(_platformPolylineFromPolyline).toList(),
      initialCircles:
          mapObjects.circles.map(_platformCircleFromCircle).toList(),
      initialHeatmaps:
          mapObjects.heatmaps.map(_platformHeatmapFromHeatmap).toList(),
      initialTileOverlays: mapObjects.tileOverlays
          .map(_platformTileOverlayFromTileOverlay)
          .toList(),
      initialClusterManagers: mapObjects.clusterManagers
          .map(_platformClusterManagerFromClusterManager)
          .toList(),
    );

    const String viewType = 'plugins.flutter.dev/google_maps_android';
    if (useAndroidViewSurface) {
      return PlatformViewLink(
        viewType: viewType,
        surfaceFactory: (
          BuildContext context,
          PlatformViewController controller,
        ) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: widgetConfiguration.gestureRecognizers,
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          final AndroidViewController controller =
              PlatformViewsService.initExpensiveAndroidView(
            id: params.id,
            viewType: viewType,
            layoutDirection: widgetConfiguration.textDirection,
            creationParams: creationParams,
            creationParamsCodec: MapsApi.pigeonChannelCodec,
            onFocus: () => params.onFocusChanged(true),
          );
          controller.addOnPlatformViewCreatedListener(
            params.onPlatformViewCreated,
          );
          controller.addOnPlatformViewCreatedListener(
            onPlatformViewCreated,
          );

          controller.create();
          return controller;
        },
      );
    } else {
      return AndroidView(
        viewType: viewType,
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: widgetConfiguration.gestureRecognizers,
        layoutDirection: widgetConfiguration.textDirection,
        creationParams: creationParams,
        creationParamsCodec: MapsApi.pigeonChannelCodec,
      );
    }
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
      mapConfiguration:
          _platformMapConfigurationFromMapConfiguration(mapConfiguration),
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
    Set<ClusterManager> clusterManagers = const <ClusterManager>{},
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
          clusterManagers: clusterManagers,
          tileOverlays: tileOverlays),
      mapConfiguration: _platformMapConfigurationFromOptionsJson(mapOptions),
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
    Set<ClusterManager> clusterManagers = const <ClusterManager>{},
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
      clusterManagers: clusterManagers,
      gestureRecognizers: gestureRecognizers,
      mapOptions: mapOptions,
    );
  }

  @override
  @visibleForTesting
  void enableDebugInspection() {
    GoogleMapsInspectorPlatform.instance = GoogleMapsInspectorAndroid(
        (int mapId) =>
            MapsInspectorApi(messageChannelSuffix: mapId.toString()));
  }

  /// Converts a Pigeon [PlatformCluster] to the corresponding [Cluster].
  static Cluster clusterFromPlatformCluster(PlatformCluster cluster) {
    return Cluster(
        ClusterManagerId(cluster.clusterManagerId),
        cluster.markerIds
            // See comment in messages.dart for why the force unwrap is okay.
            .map((String? markerId) => MarkerId(markerId!))
            .toList(),
        position: _latLngFromPlatformLatLng(cluster.position),
        bounds: _latLngBoundsFromPlatformLatLngBounds(cluster.bounds));
  }

  static PlatformLatLng _platformLatLngFromLatLng(LatLng latLng) {
    return PlatformLatLng(
        latitude: latLng.latitude, longitude: latLng.longitude);
  }

  static PlatformOffset _platformOffsetFromOffset(Offset offset) {
    return PlatformOffset(dx: offset.dx, dy: offset.dy);
  }

  static ScreenCoordinate _screenCoordinateFromPlatformPoint(
      PlatformPoint point) {
    return ScreenCoordinate(x: point.x, y: point.y);
  }

  static PlatformPoint _platformPointFromScreenCoordinate(
      ScreenCoordinate coordinate) {
    return PlatformPoint(x: coordinate.x, y: coordinate.y);
  }

  static PlatformCircle _platformCircleFromCircle(Circle circle) {
    return PlatformCircle(
      consumeTapEvents: circle.consumeTapEvents,
      fillColor: circle.fillColor.value,
      strokeColor: circle.strokeColor.value,
      visible: circle.visible,
      strokeWidth: circle.strokeWidth,
      zIndex: circle.zIndex.toDouble(),
      center: _platformLatLngFromLatLng(circle.center),
      radius: circle.radius,
      circleId: circle.circleId.value,
    );
  }

  static PlatformHeatmap _platformHeatmapFromHeatmap(Heatmap heatmap) {
    return PlatformHeatmap(json: serializeHeatmap(heatmap));
  }

  static PlatformClusterManager _platformClusterManagerFromClusterManager(
      ClusterManager clusterManager) {
    return PlatformClusterManager(
        identifier: clusterManager.clusterManagerId.value);
  }

  static PlatformInfoWindow _platformInfoWindowFromInfoWindow(
      InfoWindow window) {
    return PlatformInfoWindow(
        title: window.title,
        snippet: window.snippet,
        anchor: _platformOffsetFromOffset(window.anchor));
  }

  static PlatformMarker _platformMarkerFromMarker(Marker marker) {
    return PlatformMarker(
      alpha: marker.alpha,
      anchor: _platformOffsetFromOffset(marker.anchor),
      consumeTapEvents: marker.consumeTapEvents,
      draggable: marker.draggable,
      flat: marker.flat,
      icon: marker.icon.toJson(),
      infoWindow: _platformInfoWindowFromInfoWindow(marker.infoWindow),
      position: _platformLatLngFromLatLng(marker.position),
      rotation: marker.rotation,
      visible: marker.visible,
      zIndex: marker.zIndex,
      markerId: marker.markerId.value,
      clusterManagerId: marker.clusterManagerId?.value,
    );
  }

  static PlatformPolygon _platformPolygonFromPolygon(Polygon polygon) {
    final List<PlatformLatLng?> points =
        polygon.points.map(_platformLatLngFromLatLng).toList();
    final List<List<PlatformLatLng?>?> holes =
        polygon.holes.map((List<LatLng> hole) {
      return hole.map(_platformLatLngFromLatLng).toList();
    }).toList();
    return PlatformPolygon(
      polygonId: polygon.polygonId.value,
      fillColor: polygon.fillColor.value,
      geodesic: polygon.geodesic,
      consumesTapEvents: polygon.consumeTapEvents,
      points: points,
      holes: holes,
      strokeColor: polygon.strokeColor.value,
      strokeWidth: polygon.strokeWidth,
      zIndex: polygon.zIndex,
      visible: polygon.visible,
    );
  }

  static PlatformPolyline _platformPolylineFromPolyline(Polyline polyline) {
    final List<PlatformLatLng?> points =
        polyline.points.map(_platformLatLngFromLatLng).toList();
    final List<Object?> pattern = polyline.patterns.map((PatternItem item) {
      return item.toJson();
    }).toList();
    return PlatformPolyline(
      polylineId: polyline.polylineId.value,
      consumesTapEvents: polyline.consumeTapEvents,
      color: polyline.color.value,
      startCap: polyline.startCap.toJson(),
      endCap: polyline.endCap.toJson(),
      geodesic: polyline.geodesic,
      visible: polyline.visible,
      width: polyline.width,
      zIndex: polyline.zIndex,
      points: points,
      jointType: polyline.jointType.value,
      patterns: pattern,
    );
  }

  static PlatformTileOverlay _platformTileOverlayFromTileOverlay(
      TileOverlay tileOverlay) {
    // This cast is not ideal, but the Java code already assumes this format.
    // See the TODOs at the top of this file and on the 'json' field in
    // messages.dart.
    return PlatformTileOverlay(
        json: tileOverlay.toJson() as Map<String, Object?>);
  }
}

/// Callback handler for map events from the platform host.
@visibleForTesting
class HostMapMessageHandler implements MapsCallbackApi {
  /// Creates a new handler that listens for events from map [mapId], and
  /// broadcasts them to [streamController].
  HostMapMessageHandler(
    this.mapId,
    this.streamController, {
    required this.tileOverlayProvider,
  }) {
    MapsCallbackApi.setUp(this, messageChannelSuffix: mapId.toString());
  }

  /// Removes the handler for native messages.
  void dispose() {
    MapsCallbackApi.setUp(null, messageChannelSuffix: mapId.toString());
  }

  /// The map ID this handler listens for events from.
  final int mapId;

  /// The controller used to broadcast map events coming from the
  /// host platform.
  final StreamController<MapEvent<Object?>> streamController;

  /// The callback to get a tile overlay for the corresponding map.
  final TileOverlay? Function(TileOverlayId tileOverlayId) tileOverlayProvider;

  @override
  Future<PlatformTile> getTileOverlayTile(
    String tileOverlayId,
    PlatformPoint location,
    int zoom,
  ) async {
    final TileOverlay? tileOverlay =
        tileOverlayProvider(TileOverlayId(tileOverlayId));
    final TileProvider? tileProvider = tileOverlay?.tileProvider;
    final Tile tile = tileProvider == null
        ? TileProvider.noTile
        : await tileProvider.getTile(location.x, location.y, zoom);
    return _platformTileFromTile(tile);
  }

  @override
  void onCameraIdle() {
    streamController.add(CameraIdleEvent(mapId));
  }

  @override
  void onCameraMove(PlatformCameraPosition cameraPosition) {
    streamController.add(CameraMoveEvent(
      mapId,
      CameraPosition(
        target: _latLngFromPlatformLatLng(cameraPosition.target),
        bearing: cameraPosition.bearing,
        tilt: cameraPosition.tilt,
        zoom: cameraPosition.zoom,
      ),
    ));
  }

  @override
  void onCameraMoveStarted() {
    streamController.add(CameraMoveStartedEvent(mapId));
  }

  @override
  void onCircleTap(String circleId) {
    streamController.add(CircleTapEvent(mapId, CircleId(circleId)));
  }

  @override
  void onClusterTap(PlatformCluster cluster) {
    streamController.add(ClusterTapEvent(
      mapId,
      Cluster(
        ClusterManagerId(cluster.clusterManagerId),
        // See comment in messages.dart for why this is force-unwrapped.
        cluster.markerIds.map((String? id) => MarkerId(id!)).toList(),
        position: _latLngFromPlatformLatLng(cluster.position),
        bounds: _latLngBoundsFromPlatformLatLngBounds(cluster.bounds),
      ),
    ));
  }

  @override
  void onInfoWindowTap(String markerId) {
    streamController.add(InfoWindowTapEvent(mapId, MarkerId(markerId)));
  }

  @override
  void onLongPress(PlatformLatLng position) {
    streamController
        .add(MapLongPressEvent(mapId, _latLngFromPlatformLatLng(position)));
  }

  @override
  void onMarkerDrag(String markerId, PlatformLatLng position) {
    streamController.add(MarkerDragEvent(
        mapId, _latLngFromPlatformLatLng(position), MarkerId(markerId)));
  }

  @override
  void onMarkerDragStart(String markerId, PlatformLatLng position) {
    streamController.add(MarkerDragStartEvent(
        mapId, _latLngFromPlatformLatLng(position), MarkerId(markerId)));
  }

  @override
  void onMarkerDragEnd(String markerId, PlatformLatLng position) {
    streamController.add(MarkerDragEndEvent(
        mapId, _latLngFromPlatformLatLng(position), MarkerId(markerId)));
  }

  @override
  void onMarkerTap(String markerId) {
    streamController.add(MarkerTapEvent(mapId, MarkerId(markerId)));
  }

  @override
  void onPolygonTap(String polygonId) {
    streamController.add(PolygonTapEvent(mapId, PolygonId(polygonId)));
  }

  @override
  void onPolylineTap(String polylineId) {
    streamController.add(PolylineTapEvent(mapId, PolylineId(polylineId)));
  }

  @override
  void onTap(PlatformLatLng position) {
    streamController
        .add(MapTapEvent(mapId, _latLngFromPlatformLatLng(position)));
  }
}

LatLng _latLngFromPlatformLatLng(PlatformLatLng latLng) {
  return LatLng(latLng.latitude, latLng.longitude);
}

LatLngBounds _latLngBoundsFromPlatformLatLngBounds(
    PlatformLatLngBounds bounds) {
  return LatLngBounds(
      southwest: _latLngFromPlatformLatLng(bounds.southwest),
      northeast: _latLngFromPlatformLatLng(bounds.northeast));
}

PlatformTile _platformTileFromTile(Tile tile) {
  return PlatformTile(width: tile.width, height: tile.height, data: tile.data);
}

PlatformLatLng _platformLatLngFromLatLng(LatLng latLng) {
  return PlatformLatLng(latitude: latLng.latitude, longitude: latLng.longitude);
}

PlatformLatLngBounds? _platformLatLngBoundsFromLatLngBounds(
    LatLngBounds? bounds) {
  if (bounds == null) {
    return null;
  }
  return PlatformLatLngBounds(
      northeast: _platformLatLngFromLatLng(bounds.northeast),
      southwest: _platformLatLngFromLatLng(bounds.southwest));
}

PlatformCameraTargetBounds? _platformCameraTargetBoundsFromCameraTargetBounds(
    CameraTargetBounds? bounds) {
  return bounds == null
      ? null
      : PlatformCameraTargetBounds(
          bounds: _platformLatLngBoundsFromLatLngBounds(bounds.bounds));
}

PlatformMapType? _platformMapTypeFromMapType(MapType? type) {
  switch (type) {
    case null:
      return null;
    case MapType.none:
      return PlatformMapType.none;
    case MapType.normal:
      return PlatformMapType.normal;
    case MapType.satellite:
      return PlatformMapType.satellite;
    case MapType.terrain:
      return PlatformMapType.terrain;
    case MapType.hybrid:
      return PlatformMapType.hybrid;
  }
  // The enum comes from a different package, which could get a new value at
  // any time, so provide a fallback that ensures this won't break when used
  // with a version that contains new values. This is deliberately outside
  // the switch rather than a `default` so that the linter will flag the
  // switch as needing an update.
  // ignore: dead_code
  return PlatformMapType.normal;
}

PlatformZoomRange? _platformZoomRangeFromMinMaxZoomPreference(
    MinMaxZoomPreference? zoomPref) {
  return zoomPref == null
      ? null
      : PlatformZoomRange(min: zoomPref.minZoom, max: zoomPref.maxZoom);
}

PlatformEdgeInsets? _platformEdgeInsetsFromEdgeInsets(EdgeInsets? insets) {
  return insets == null
      ? null
      : PlatformEdgeInsets(
          top: insets.top,
          bottom: insets.bottom,
          left: insets.left,
          right: insets.right);
}

PlatformMapConfiguration _platformMapConfigurationFromMapConfiguration(
    MapConfiguration config) {
  return PlatformMapConfiguration(
    compassEnabled: config.compassEnabled,
    cameraTargetBounds: _platformCameraTargetBoundsFromCameraTargetBounds(
        config.cameraTargetBounds),
    mapType: _platformMapTypeFromMapType(config.mapType),
    minMaxZoomPreference:
        _platformZoomRangeFromMinMaxZoomPreference(config.minMaxZoomPreference),
    mapToolbarEnabled: config.mapToolbarEnabled,
    rotateGesturesEnabled: config.rotateGesturesEnabled,
    scrollGesturesEnabled: config.scrollGesturesEnabled,
    tiltGesturesEnabled: config.tiltGesturesEnabled,
    trackCameraPosition: config.trackCameraPosition,
    zoomControlsEnabled: config.zoomControlsEnabled,
    zoomGesturesEnabled: config.zoomGesturesEnabled,
    myLocationEnabled: config.myLocationEnabled,
    myLocationButtonEnabled: config.myLocationButtonEnabled,
    padding: _platformEdgeInsetsFromEdgeInsets(config.padding),
    indoorViewEnabled: config.indoorViewEnabled,
    trafficEnabled: config.trafficEnabled,
    buildingsEnabled: config.buildingsEnabled,
    liteModeEnabled: config.liteModeEnabled,
    cloudMapId: config.cloudMapId,
    style: config.style,
  );
}

// For supporting the deprecated updateMapOptions API.
PlatformMapConfiguration _platformMapConfigurationFromOptionsJson(
    Map<String, Object?> options) {
  // All of these hard-coded values and structures come from
  // google_maps_flutter_platform_interface/lib/src/types/utils/map_configuration_serialization.dart
  // to support this legacy API that relied on cross-package magic strings.
  final List<double>? padding =
      (options['padding'] as List<Object?>?)?.cast<double>();
  final int? mapType = options['mapType'] as int?;
  return PlatformMapConfiguration(
    compassEnabled: options['compassEnabled'] as bool?,
    cameraTargetBounds: _platformCameraTargetBoundsFromCameraTargetBoundsJson(
        options['cameraTargetBounds']),
    mapType: mapType == null ? null : _platformMapTypeFromMapTypeIndex(mapType),
    minMaxZoomPreference: _platformZoomRangeFromMinMaxZoomPreferenceJson(
        options['minMaxZoomPreference']),
    mapToolbarEnabled: options['mapToolbarEnabled'] as bool?,
    rotateGesturesEnabled: options['rotateGesturesEnabled'] as bool?,
    scrollGesturesEnabled: options['scrollGesturesEnabled'] as bool?,
    tiltGesturesEnabled: options['tiltGesturesEnabled'] as bool?,
    trackCameraPosition: options['trackCameraPosition'] as bool?,
    zoomControlsEnabled: options['zoomControlsEnabled'] as bool?,
    zoomGesturesEnabled: options['zoomGesturesEnabled'] as bool?,
    myLocationEnabled: options['myLocationEnabled'] as bool?,
    myLocationButtonEnabled: options['myLocationButtonEnabled'] as bool?,
    padding: padding == null
        ? null
        : PlatformEdgeInsets(
            top: padding[0],
            left: padding[1],
            bottom: padding[2],
            right: padding[3]),
    indoorViewEnabled: options['indoorEnabled'] as bool?,
    trafficEnabled: options['trafficEnabled'] as bool?,
    buildingsEnabled: options['buildingsEnabled'] as bool?,
    liteModeEnabled: options['liteModeEnabled'] as bool?,
    cloudMapId: options['cloudMapId'] as String?,
    style: options['style'] as String?,
  );
}

PlatformCameraPosition _platformCameraPositionFromCameraPosition(
    CameraPosition position) {
  return PlatformCameraPosition(
      bearing: position.bearing,
      target: _platformLatLngFromLatLng(position.target),
      tilt: position.tilt,
      zoom: position.zoom);
}

PlatformMapType _platformMapTypeFromMapTypeIndex(int index) {
  // This is inherently fragile, but see comment in updateMapOptions.
  return switch (index) {
    0 => PlatformMapType.none,
    1 => PlatformMapType.normal,
    2 => PlatformMapType.satellite,
    3 => PlatformMapType.terrain,
    4 => PlatformMapType.hybrid,
    // For a new, unsupported type, just use normal.
    _ => PlatformMapType.normal,
  };
}

PlatformLatLng _platformLatLngFromLatLngJson(Object latLngJson) {
  // See `LatLng.toJson`.
  final List<double> list = (latLngJson as List<Object?>).cast<double>();
  return PlatformLatLng(latitude: list[0], longitude: list[1]);
}

PlatformLatLngBounds? _platformLatLngBoundsFromLatLngBoundsJson(
    Object? boundsJson) {
  if (boundsJson == null) {
    return null;
  }
  // See `LatLngBounds.toJson`.
  final List<Object> boundsList = (boundsJson as List<Object?>).cast<Object>();
  return PlatformLatLngBounds(
      southwest: _platformLatLngFromLatLngJson(boundsList[0]),
      northeast: _platformLatLngFromLatLngJson(boundsList[1]));
}

PlatformCameraTargetBounds?
    _platformCameraTargetBoundsFromCameraTargetBoundsJson(Object? targetJson) {
  if (targetJson == null) {
    return null;
  }
  // See `CameraTargetBounds.toJson`.
  return PlatformCameraTargetBounds(
      bounds: _platformLatLngBoundsFromLatLngBoundsJson(
          (targetJson as List<Object?>)[0]));
}

PlatformZoomRange? _platformZoomRangeFromMinMaxZoomPreferenceJson(
    Object? zoomPrefsJson) {
  if (zoomPrefsJson == null) {
    return null;
  }
  // See `MinMaxZoomPreference.toJson`.
  final List<double?> minMaxZoom =
      (zoomPrefsJson as List<Object?>).cast<double?>();
  return PlatformZoomRange(min: minMaxZoom[0], max: minMaxZoom[1]);
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

/// Thrown to indicate that a platform interaction failed to initialize renderer.
class AndroidMapRendererException implements Exception {
  /// Creates a [AndroidMapRendererException] with an optional human-readable
  /// error message.
  AndroidMapRendererException([this.message]);

  /// A human-readable error message, possibly null.
  final String? message;

  @override
  String toString() => 'AndroidMapRendererException($message)';
}

/// The error message to use for style failures. Unlike iOS, Android does not
/// provide an API to get style failure information, it's just logged to the
/// console, so there's no platform call needed.
const String _setStyleFailureMessage =
    'Unable to set the map style. Please check console logs for errors.';
