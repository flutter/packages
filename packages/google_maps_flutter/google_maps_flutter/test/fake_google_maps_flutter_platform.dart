// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:stream_transform/stream_transform.dart';

// A dummy implementation of the platform interface for tests.
class FakeGoogleMapsFlutterPlatform extends GoogleMapsFlutterPlatform {
  FakeGoogleMapsFlutterPlatform();

  /// The IDs passed to each call to buildView, in call order.
  List<int> createdIds = <int>[];

  /// A map of creation IDs to fake map instances.
  Map<int, PlatformMapStateRecorder> mapInstances =
      <int, PlatformMapStateRecorder>{};

  PlatformMapStateRecorder get lastCreatedMap => mapInstances[createdIds.last]!;

  /// Whether to add a small delay to async calls to simulate more realistic
  /// async behavior (simulating the platform channel calls most
  /// implementations will do).
  ///
  /// When true, requires tests to `pumpAndSettle` at the end of the test
  /// to avoid exceptions.
  bool simulatePlatformDelay = false;

  /// Whether `dispose` has been called.
  bool disposed = false;

  /// Stream controller to inject events for testing.
  final StreamController<MapEvent<dynamic>> mapEventStreamController =
      StreamController<MapEvent<dynamic>>.broadcast();

  @override
  Future<void> init(int mapId) async {}

  @override
  Future<void> updateMapConfiguration(
    MapConfiguration update, {
    required int mapId,
  }) async {
    mapInstances[mapId]?.mapConfiguration = update;
    await _fakeDelay();
  }

  @override
  Future<void> updateMarkers(
    MarkerUpdates markerUpdates, {
    required int mapId,
  }) async {
    mapInstances[mapId]?.markerUpdates.add(markerUpdates);
    await _fakeDelay();
  }

  @override
  Future<void> updatePolygons(
    PolygonUpdates polygonUpdates, {
    required int mapId,
  }) async {
    mapInstances[mapId]?.polygonUpdates.add(polygonUpdates);
    await _fakeDelay();
  }

  @override
  Future<void> updatePolylines(
    PolylineUpdates polylineUpdates, {
    required int mapId,
  }) async {
    mapInstances[mapId]?.polylineUpdates.add(polylineUpdates);
    await _fakeDelay();
  }

  @override
  Future<void> updateCircles(
    CircleUpdates circleUpdates, {
    required int mapId,
  }) async {
    mapInstances[mapId]?.circleUpdates.add(circleUpdates);
    await _fakeDelay();
  }

  @override
  Future<void> updateHeatmaps(
    HeatmapUpdates heatmapUpdates, {
    required int mapId,
  }) async {
    mapInstances[mapId]?.heatmapUpdates.add(heatmapUpdates);
    await _fakeDelay();
  }

  @override
  Future<void> updateTileOverlays({
    required Set<TileOverlay> newTileOverlays,
    required int mapId,
  }) async {
    mapInstances[mapId]?.tileOverlaySets.add(newTileOverlays);
    await _fakeDelay();
  }

  @override
  Future<void> updateClusterManagers(
    ClusterManagerUpdates clusterManagerUpdates, {
    required int mapId,
  }) async {
    mapInstances[mapId]?.clusterManagerUpdates.add(clusterManagerUpdates);
    await _fakeDelay();
  }

  @override
  Future<void> updateGroundOverlays(
    GroundOverlayUpdates groundOverlayUpdates, {
    required int mapId,
  }) async {
    mapInstances[mapId]?.groundOverlayUpdates.add(groundOverlayUpdates);
    await _fakeDelay();
  }

  @override
  Future<void> clearTileCache(
    TileOverlayId tileOverlayId, {
    required int mapId,
  }) async {}

  @override
  Future<void> animateCamera(
    CameraUpdate cameraUpdate, {
    required int mapId,
  }) async {}

  @override
  Future<void> moveCamera(
    CameraUpdate cameraUpdate, {
    required int mapId,
  }) async {}

  @override
  Future<void> setMapStyle(
    String? mapStyle, {
    required int mapId,
  }) async {}

  @override
  Future<LatLngBounds> getVisibleRegion({
    required int mapId,
  }) async {
    return LatLngBounds(
        southwest: const LatLng(0, 0), northeast: const LatLng(0, 0));
  }

  @override
  Future<ScreenCoordinate> getScreenCoordinate(
    LatLng latLng, {
    required int mapId,
  }) async {
    return const ScreenCoordinate(x: 0, y: 0);
  }

  @override
  Future<LatLng> getLatLng(
    ScreenCoordinate screenCoordinate, {
    required int mapId,
  }) async {
    return const LatLng(0, 0);
  }

  @override
  Future<void> showMarkerInfoWindow(
    MarkerId markerId, {
    required int mapId,
  }) async {}

  @override
  Future<void> hideMarkerInfoWindow(
    MarkerId markerId, {
    required int mapId,
  }) async {}

  @override
  Future<bool> isMarkerInfoWindowShown(
    MarkerId markerId, {
    required int mapId,
  }) async {
    return false;
  }

  @override
  Future<double> getZoomLevel({
    required int mapId,
  }) async {
    return 0.0;
  }

  @override
  Future<Uint8List?> takeSnapshot({
    required int mapId,
  }) async {
    return null;
  }

  @override
  Stream<CameraMoveStartedEvent> onCameraMoveStarted({required int mapId}) {
    return mapEventStreamController.stream.whereType<CameraMoveStartedEvent>();
  }

  @override
  Stream<CameraMoveEvent> onCameraMove({required int mapId}) {
    return mapEventStreamController.stream.whereType<CameraMoveEvent>();
  }

  @override
  Stream<CameraIdleEvent> onCameraIdle({required int mapId}) {
    return mapEventStreamController.stream.whereType<CameraIdleEvent>();
  }

  @override
  Stream<MarkerTapEvent> onMarkerTap({required int mapId}) {
    return mapEventStreamController.stream.whereType<MarkerTapEvent>();
  }

  @override
  Stream<InfoWindowTapEvent> onInfoWindowTap({required int mapId}) {
    return mapEventStreamController.stream.whereType<InfoWindowTapEvent>();
  }

  @override
  Stream<MarkerDragStartEvent> onMarkerDragStart({required int mapId}) {
    return mapEventStreamController.stream.whereType<MarkerDragStartEvent>();
  }

  @override
  Stream<MarkerDragEvent> onMarkerDrag({required int mapId}) {
    return mapEventStreamController.stream.whereType<MarkerDragEvent>();
  }

  @override
  Stream<MarkerDragEndEvent> onMarkerDragEnd({required int mapId}) {
    return mapEventStreamController.stream.whereType<MarkerDragEndEvent>();
  }

  @override
  Stream<PolylineTapEvent> onPolylineTap({required int mapId}) {
    return mapEventStreamController.stream.whereType<PolylineTapEvent>();
  }

  @override
  Stream<PolygonTapEvent> onPolygonTap({required int mapId}) {
    return mapEventStreamController.stream.whereType<PolygonTapEvent>();
  }

  @override
  Stream<CircleTapEvent> onCircleTap({required int mapId}) {
    return mapEventStreamController.stream.whereType<CircleTapEvent>();
  }

  @override
  Stream<MapTapEvent> onTap({required int mapId}) {
    return mapEventStreamController.stream.whereType<MapTapEvent>();
  }

  @override
  Stream<MapLongPressEvent> onLongPress({required int mapId}) {
    return mapEventStreamController.stream.whereType<MapLongPressEvent>();
  }

  @override
  Stream<ClusterTapEvent> onClusterTap({required int mapId}) {
    return mapEventStreamController.stream.whereType<ClusterTapEvent>();
  }

  @override
  Stream<GroundOverlayTapEvent> onGroundOverlayTap({required int mapId}) {
    return mapEventStreamController.stream.whereType<GroundOverlayTapEvent>();
  }

  @override
  void dispose({required int mapId}) {
    disposed = true;
  }

  @override
  Widget buildViewWithConfiguration(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required MapWidgetConfiguration widgetConfiguration,
    MapObjects mapObjects = const MapObjects(),
    MapConfiguration mapConfiguration = const MapConfiguration(),
  }) {
    final PlatformMapStateRecorder? instance = mapInstances[creationId];
    if (instance == null) {
      createdIds.add(creationId);
      mapInstances[creationId] = PlatformMapStateRecorder(
          widgetConfiguration: widgetConfiguration,
          mapConfiguration: mapConfiguration,
          mapObjects: mapObjects);
      onPlatformViewCreated(creationId);
    }
    return Container();
  }

  Future<void> _fakeDelay() async {
    if (!simulatePlatformDelay) {
      return;
    }
    return Future<void>.delayed(const Duration(microseconds: 1));
  }
}

/// A fake implementation of a native map, which stores all the updates it is
/// sent for inspection in tests.
class PlatformMapStateRecorder {
  PlatformMapStateRecorder({
    required this.widgetConfiguration,
    this.mapObjects = const MapObjects(),
    this.mapConfiguration = const MapConfiguration(),
  }) {
    clusterManagerUpdates.add(ClusterManagerUpdates.from(
        const <ClusterManager>{}, mapObjects.clusterManagers));
    groundOverlayUpdates.add(GroundOverlayUpdates.from(
        const <GroundOverlay>{}, mapObjects.groundOverlays));
    markerUpdates.add(MarkerUpdates.from(const <Marker>{}, mapObjects.markers));
    polygonUpdates
        .add(PolygonUpdates.from(const <Polygon>{}, mapObjects.polygons));
    polylineUpdates
        .add(PolylineUpdates.from(const <Polyline>{}, mapObjects.polylines));
    circleUpdates.add(CircleUpdates.from(const <Circle>{}, mapObjects.circles));
    heatmapUpdates
        .add(HeatmapUpdates.from(const <Heatmap>{}, mapObjects.heatmaps));
    tileOverlaySets.add(mapObjects.tileOverlays);
  }

  MapWidgetConfiguration widgetConfiguration;
  MapObjects mapObjects;
  MapConfiguration mapConfiguration;

  final List<MarkerUpdates> markerUpdates = <MarkerUpdates>[];
  final List<PolygonUpdates> polygonUpdates = <PolygonUpdates>[];
  final List<PolylineUpdates> polylineUpdates = <PolylineUpdates>[];
  final List<CircleUpdates> circleUpdates = <CircleUpdates>[];
  final List<HeatmapUpdates> heatmapUpdates = <HeatmapUpdates>[];
  final List<Set<TileOverlay>> tileOverlaySets = <Set<TileOverlay>>[];
  final List<ClusterManagerUpdates> clusterManagerUpdates =
      <ClusterManagerUpdates>[];
  final List<GroundOverlayUpdates> groundOverlayUpdates =
      <GroundOverlayUpdates>[];
}
