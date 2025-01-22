// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: unnecessary_nullable_for_final_variable_declarations

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  GoogleMapsFlutterPlatform.instance.enableDebugInspection();
  final GoogleMapsFlutterPlatform plugin = GoogleMapsFlutterPlatform.instance;
  final GoogleMapsInspectorPlatform inspector =
      GoogleMapsInspectorPlatform.instance!;

  const LatLng mapCenter = LatLng(20, 20);
  const CameraPosition initialCameraPosition =
      CameraPosition(target: mapCenter);

  group('MarkersController', () {
    const int testMapId = 33930;

    testWidgets('Marker clustering', (WidgetTester tester) async {
      const ClusterManagerId clusterManagerId = ClusterManagerId('cluster 1');

      final Set<ClusterManager> clusterManagers = <ClusterManager>{
        const ClusterManager(clusterManagerId: clusterManagerId),
      };

      // Create the marker with clusterManagerId.
      final Set<Marker> initialMarkers = <Marker>{
        const Marker(
            markerId: MarkerId('1'),
            position: mapCenter,
            clusterManagerId: clusterManagerId),
        const Marker(
            markerId: MarkerId('2'),
            position: mapCenter,
            clusterManagerId: clusterManagerId),
      };

      final Completer<int> mapIdCompleter = Completer<int>();

      await _pumpMap(
          tester,
          plugin.buildViewWithConfiguration(
              testMapId, (int id) => mapIdCompleter.complete(id),
              widgetConfiguration: const MapWidgetConfiguration(
                initialCameraPosition: initialCameraPosition,
                textDirection: TextDirection.ltr,
              ),
              mapObjects: MapObjects(
                  clusterManagers: clusterManagers, markers: initialMarkers)));

      final int mapId = await mapIdCompleter.future;
      expect(mapId, equals(testMapId));

      addTearDown(() => plugin.dispose(mapId: mapId));

      final LatLng latlon = await plugin
          .getLatLng(const ScreenCoordinate(x: 0, y: 0), mapId: mapId);
      debugPrint(latlon.toString());

      final List<Cluster> clusters =
          await waitForValueMatchingPredicate<List<Cluster>>(
                  tester,
                  () async => inspector.getClusters(
                      mapId: mapId, clusterManagerId: clusterManagerId),
                  (List<Cluster> clusters) => clusters.isNotEmpty) ??
              <Cluster>[];

      expect(clusters.length, 1);
      expect(clusters[0].markerIds.length, 2);

      // Copy only the first marker with null clusterManagerId.
      // This means that both markers should be removed from the cluster.
      final Set<Marker> updatedMarkers = <Marker>{
        _copyMarkerWithClusterManagerId(initialMarkers.first, null)
      };

      final MarkerUpdates markerUpdates =
          MarkerUpdates.from(initialMarkers, updatedMarkers);
      await plugin.updateMarkers(markerUpdates, mapId: mapId);

      final List<Cluster> updatedClusters =
          await waitForValueMatchingPredicate<List<Cluster>>(
                  tester,
                  () async => inspector.getClusters(
                      mapId: mapId, clusterManagerId: clusterManagerId),
                  (List<Cluster> clusters) => clusters.isNotEmpty) ??
              <Cluster>[];

      expect(updatedClusters.length, 0);
    });
  });
}

// Repeatedly checks an asynchronous value against a test condition, waiting
// one frame between each check, returing the value if it passes the predicate
// before [maxTries] is reached.
//
// Returns null if the predicate is never satisfied.
//
// This is useful for cases where the Maps SDK has some internally
// asynchronous operation that we don't have visibility into (e.g., native UI
// animations).
Future<T?> waitForValueMatchingPredicate<T>(WidgetTester tester,
    Future<T> Function() getValue, bool Function(T) predicate,
    {int maxTries = 100}) async {
  for (int i = 0; i < maxTries; i++) {
    final T value = await getValue();
    if (predicate(value)) {
      return value;
    }
    await tester.pump();
  }
  return null;
}

Marker _copyMarkerWithClusterManagerId(
    Marker marker, ClusterManagerId? clusterManagerId) {
  return Marker(
    markerId: marker.markerId,
    alpha: marker.alpha,
    anchor: marker.anchor,
    consumeTapEvents: marker.consumeTapEvents,
    draggable: marker.draggable,
    flat: marker.flat,
    icon: marker.icon,
    infoWindow: marker.infoWindow,
    position: marker.position,
    rotation: marker.rotation,
    visible: marker.visible,
    zIndex: marker.zIndex,
    onTap: marker.onTap,
    onDragStart: marker.onDragStart,
    onDrag: marker.onDrag,
    onDragEnd: marker.onDragEnd,
    clusterManagerId: clusterManagerId,
  );
}

/// Pumps a [map] widget in [tester] of a certain [size], then waits until it settles.
Future<void> _pumpMap(WidgetTester tester, Widget map,
    [Size size = const Size.square(200)]) async {
  await tester.pumpWidget(_wrapMap(map, size));
  await tester.pumpAndSettle();
}

/// Wraps a [map] in a bunch of widgets so it renders in all platforms.
///
/// An optional [size] can be passed.
Widget _wrapMap(Widget map, [Size size = const Size.square(200)]) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox.fromSize(
          size: size,
          child: map,
        ),
      ),
    ),
  );
}
