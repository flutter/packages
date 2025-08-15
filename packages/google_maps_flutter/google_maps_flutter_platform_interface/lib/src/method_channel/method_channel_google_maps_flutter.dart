// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../google_maps_flutter_platform_interface.dart';
import '../types/tile_overlay_updates.dart';
import '../types/utils/map_configuration_serialization.dart';
import 'serialization.dart';

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

/// An implementation of [GoogleMapsFlutterPlatform] that uses [MethodChannel] to communicate with the native code.
///
/// The `google_maps_flutter` plugin code itself never talks to the native code directly. It delegates
/// all those calls to an instance of a class that extends the GoogleMapsFlutterPlatform.
///
/// The architecture above allows for platforms that communicate differently with the native side
/// (like web) to have a common interface to extend.
///
/// This is the instance that runs when the native side talks to your Flutter app through MethodChannels,
/// like the Android and iOS platforms.
class MethodChannelGoogleMapsFlutter extends GoogleMapsFlutterPlatform {
  // Keep a collection of id -> channel
  // Every method call passes the int mapId
  final Map<int, MethodChannel> _channels = <int, MethodChannel>{};

  /// Accesses the MethodChannel associated to the passed mapId.
  MethodChannel channel(int mapId) {
    final MethodChannel? channel = _channels[mapId];
    if (channel == null) {
      throw UnknownMapIDError(mapId);
    }
    return channel;
  }

  // Keep a collection of mapId to a map of TileOverlays.
  final Map<int, Map<TileOverlayId, TileOverlay>> _tileOverlays =
      <int, Map<TileOverlayId, TileOverlay>>{};

  /// Returns the channel for [mapId], creating it if it doesn't already exist.
  @visibleForTesting
  MethodChannel ensureChannelInitialized(int mapId) {
    MethodChannel? channel = _channels[mapId];
    if (channel == null) {
      channel = MethodChannel('plugins.flutter.io/google_maps_$mapId');
      channel.setMethodCallHandler(
          (MethodCall call) => _handleMethodCall(call, mapId));
      _channels[mapId] = channel;
    }
    return channel;
  }

  @override
  Future<void> init(int mapId) {
    final MethodChannel channel = ensureChannelInitialized(mapId);
    return channel.invokeMethod<void>('map#waitForMap');
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
      case 'cluster#onTap':
        final Map<String, Object?> arguments = _getArgumentDictionary(call);
        final ClusterManagerId clusterManagerId =
            ClusterManagerId(arguments['clusterManagerId']! as String);
        final LatLng position = LatLng.fromJson(arguments['position'])!;

        final Map<String, List<dynamic>> latLngData =
            (arguments['bounds']! as Map<dynamic, dynamic>).map(
                (dynamic key, dynamic object) =>
                    MapEntry<String, List<dynamic>>(
                        key as String, object as List<dynamic>));

        final LatLngBounds bounds = LatLngBounds(
            northeast: LatLng.fromJson(latLngData['northeast'])!,
            southwest: LatLng.fromJson(latLngData['southwest'])!);

        final List<MarkerId> markerIds =
            (arguments['markerIds']! as List<dynamic>)
                .map((dynamic markerId) => MarkerId(markerId as String))
                .toList();

        _mapEventStreamController.add(ClusterTapEvent(
          mapId,
          Cluster(
            clusterManagerId,
            markerIds,
            position: position,
            bounds: bounds,
          ),
        ));
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
  Future<void> updateMapOptions(
    Map<String, dynamic> optionsUpdate, {
    required int mapId,
  }) {
    return channel(mapId).invokeMethod<void>(
      'map#update',
      <String, dynamic>{
        'options': optionsUpdate,
      },
    );
  }

  @override
  Future<void> updateMarkers(
    MarkerUpdates markerUpdates, {
    required int mapId,
  }) {
    return channel(mapId).invokeMethod<void>(
      'markers#update',
      markerUpdates.toJson(),
    );
  }

  @override
  Future<void> updatePolygons(
    PolygonUpdates polygonUpdates, {
    required int mapId,
  }) {
    return channel(mapId).invokeMethod<void>(
      'polygons#update',
      polygonUpdates.toJson(),
    );
  }

  @override
  Future<void> updatePolylines(
    PolylineUpdates polylineUpdates, {
    required int mapId,
  }) {
    return channel(mapId).invokeMethod<void>(
      'polylines#update',
      polylineUpdates.toJson(),
    );
  }

  @override
  Future<void> updateCircles(
    CircleUpdates circleUpdates, {
    required int mapId,
  }) {
    return channel(mapId).invokeMethod<void>(
      'circles#update',
      circleUpdates.toJson(),
    );
  }

  @override
  Future<void> updateHeatmaps(
    HeatmapUpdates heatmapUpdates, {
    required int mapId,
  }) {
    return channel(mapId).invokeMethod<void>(
      'heatmaps#update',
      serializeMapsObjectUpdates(heatmapUpdates, serializeHeatmap),
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
    final TileOverlayUpdates updates =
        TileOverlayUpdates.from(previousSet, newTileOverlays);
    _tileOverlays[mapId] = keyTileOverlayId(newTileOverlays);
    return channel(mapId).invokeMethod<void>(
      'tileOverlays#update',
      updates.toJson(),
    );
  }

  @override
  Future<void> updateClusterManagers(
    ClusterManagerUpdates clusterManagerUpdates, {
    required int mapId,
  }) {
    return channel(mapId).invokeMethod<void>(
      'clusterManagers#update',
      clusterManagerUpdates.toJson(),
    );
  }

  @override
  Future<void> clearTileCache(
    TileOverlayId tileOverlayId, {
    required int mapId,
  }) {
    return channel(mapId)
        .invokeMethod<void>('tileOverlays#clearTileCache', <String, Object>{
      'tileOverlayId': tileOverlayId.value,
    });
  }

  @override
  Future<void> animateCamera(
    CameraUpdate cameraUpdate, {
    required int mapId,
  }) {
    return channel(mapId).invokeMethod<void>('camera#animate', <String, Object>{
      'cameraUpdate': cameraUpdate.toJson(),
    });
  }

  @override
  Future<void> moveCamera(
    CameraUpdate cameraUpdate, {
    required int mapId,
  }) {
    return channel(mapId).invokeMethod<void>('camera#move', <String, dynamic>{
      'cameraUpdate': cameraUpdate.toJson(),
    });
  }

  @override
  Future<void> setMapStyle(
    String? mapStyle, {
    required int mapId,
  }) async {
    final List<dynamic> successAndError = (await channel(mapId)
        .invokeMethod<List<dynamic>>('map#setStyle', mapStyle))!;
    final bool success = successAndError[0] as bool;
    if (!success) {
      throw MapStyleException(successAndError[1] as String);
    }
  }

  @override
  Future<LatLngBounds> getVisibleRegion({
    required int mapId,
  }) async {
    final Map<String, dynamic> latLngBounds = (await channel(mapId)
        .invokeMapMethod<String, dynamic>('map#getVisibleRegion'))!;
    final LatLng southwest = LatLng.fromJson(latLngBounds['southwest'])!;
    final LatLng northeast = LatLng.fromJson(latLngBounds['northeast'])!;

    return LatLngBounds(northeast: northeast, southwest: southwest);
  }

  @override
  Future<ScreenCoordinate> getScreenCoordinate(
    LatLng latLng, {
    required int mapId,
  }) async {
    final Map<String, int> point = (await channel(mapId)
        .invokeMapMethod<String, int>(
            'map#getScreenCoordinate', latLng.toJson()))!;

    return ScreenCoordinate(x: point['x']!, y: point['y']!);
  }

  @override
  Future<LatLng> getLatLng(
    ScreenCoordinate screenCoordinate, {
    required int mapId,
  }) async {
    final List<dynamic> latLng = (await channel(mapId)
        .invokeMethod<List<dynamic>>(
            'map#getLatLng', screenCoordinate.toJson()))!;
    return LatLng(latLng[0] as double, latLng[1] as double);
  }

  @override
  Future<void> showMarkerInfoWindow(
    MarkerId markerId, {
    required int mapId,
  }) {
    return channel(mapId).invokeMethod<void>(
        'markers#showInfoWindow', <String, String>{'markerId': markerId.value});
  }

  @override
  Future<void> hideMarkerInfoWindow(
    MarkerId markerId, {
    required int mapId,
  }) {
    return channel(mapId).invokeMethod<void>(
        'markers#hideInfoWindow', <String, String>{'markerId': markerId.value});
  }

  @override
  Future<bool> isMarkerInfoWindowShown(
    MarkerId markerId, {
    required int mapId,
  }) async {
    return (await channel(mapId).invokeMethod<bool>('markers#isInfoWindowShown',
        <String, String>{'markerId': markerId.value}))!;
  }

  @override
  Future<double> getZoomLevel({
    required int mapId,
  }) async {
    return (await channel(mapId).invokeMethod<double>('map#getZoomLevel'))!;
  }

  @override
  Future<Uint8List?> takeSnapshot({
    required int mapId,
  }) {
    return channel(mapId).invokeMethod<Uint8List>('map#takeSnapshot');
  }

  /// Set [GoogleMapsFlutterPlatform] to use [AndroidViewSurface] to build the Google Maps widget.
  ///
  /// This implementation uses hybrid composition to render the Google Maps
  /// Widget on Android. This comes at the cost of some performance on Android
  /// versions below 10. See
  /// https://docs.flutter.dev/platform-integration/android/platform-views#performance for more
  /// information.
  ///
  /// If set to true, the google map widget should be built with
  /// [buildViewWithTextDirection] instead of [buildView].
  ///
  /// Defaults to false.
  bool useAndroidViewSurface = false;

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
      'heatmapsToAdd': serializeHeatmapSet(mapObjects.heatmaps),
      'tileOverlaysToAdd': serializeTileOverlaySet(mapObjects.tileOverlays),
    };

    if (defaultTargetPlatform == TargetPlatform.android) {
      if (useAndroidViewSurface) {
        return PlatformViewLink(
          viewType: 'plugins.flutter.io/google_maps',
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
            final SurfaceAndroidViewController controller =
                PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: 'plugins.flutter.io/google_maps',
              layoutDirection: widgetConfiguration.textDirection,
              creationParams: creationParams,
              creationParamsCodec: const StandardMessageCodec(),
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
          viewType: 'plugins.flutter.io/google_maps',
          onPlatformViewCreated: onPlatformViewCreated,
          gestureRecognizers: widgetConfiguration.gestureRecognizers,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        );
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'plugins.flutter.io/google_maps',
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: widgetConfiguration.gestureRecognizers,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return Text(
        '$defaultTargetPlatform is not yet supported by the maps plugin');
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
      mapOptions: jsonForMapConfiguration(mapConfiguration),
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
}
