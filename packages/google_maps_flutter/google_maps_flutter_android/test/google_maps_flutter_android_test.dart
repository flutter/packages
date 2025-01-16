// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_android/src/messages.g.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'google_maps_flutter_android_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[MockSpec<MapsApi>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  (GoogleMapsFlutterAndroid, MockMapsApi) setUpMockMap({required int mapId}) {
    final MockMapsApi api = MockMapsApi();
    final GoogleMapsFlutterAndroid maps =
        GoogleMapsFlutterAndroid(apiProvider: (_) => api);
    maps.ensureApiInitialized(mapId);
    return (maps, api);
  }

  test('registers instance', () async {
    GoogleMapsFlutterAndroid.registerWith();
    expect(GoogleMapsFlutterPlatform.instance, isA<GoogleMapsFlutterAndroid>());
  });

  test('init calls waitForMap', () async {
    final MockMapsApi api = MockMapsApi();
    final GoogleMapsFlutterAndroid maps =
        GoogleMapsFlutterAndroid(apiProvider: (_) => api);

    await maps.init(1);

    verify(api.waitForMap());
  });

  test('getScreenCoordinate converts and passes values correctly', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    // Arbitrary values that are all different from each other.
    const LatLng latLng = LatLng(10, 20);
    const ScreenCoordinate expectedCoord = ScreenCoordinate(x: 30, y: 40);
    when(api.getScreenCoordinate(any)).thenAnswer(
        (_) async => PlatformPoint(x: expectedCoord.x, y: expectedCoord.y));

    final ScreenCoordinate coord =
        await maps.getScreenCoordinate(latLng, mapId: mapId);
    expect(coord, expectedCoord);
    final VerificationResult verification =
        verify(api.getScreenCoordinate(captureAny));
    final PlatformLatLng passedLatLng =
        verification.captured[0] as PlatformLatLng;
    expect(passedLatLng.latitude, latLng.latitude);
    expect(passedLatLng.longitude, latLng.longitude);
  });

  test('getLatLng converts and passes values correctly', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    // Arbitrary values that are all different from each other.
    const LatLng expectedLatLng = LatLng(10, 20);
    const ScreenCoordinate coord = ScreenCoordinate(x: 30, y: 40);
    when(api.getLatLng(any)).thenAnswer((_) async => PlatformLatLng(
        latitude: expectedLatLng.latitude,
        longitude: expectedLatLng.longitude));

    final LatLng latLng = await maps.getLatLng(coord, mapId: mapId);
    expect(latLng, expectedLatLng);
    final VerificationResult verification = verify(api.getLatLng(captureAny));
    final PlatformPoint passedCoord = verification.captured[0] as PlatformPoint;
    expect(passedCoord.x, coord.x);
    expect(passedCoord.y, coord.y);
  });

  test('getVisibleRegion converts and passes values correctly', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    // Arbitrary values that are all different from each other.
    final LatLngBounds expectedBounds = LatLngBounds(
        southwest: const LatLng(10, 20), northeast: const LatLng(30, 40));
    when(api.getVisibleRegion()).thenAnswer((_) async => PlatformLatLngBounds(
        southwest: PlatformLatLng(
            latitude: expectedBounds.southwest.latitude,
            longitude: expectedBounds.southwest.longitude),
        northeast: PlatformLatLng(
            latitude: expectedBounds.northeast.latitude,
            longitude: expectedBounds.northeast.longitude)));

    final LatLngBounds bounds = await maps.getVisibleRegion(mapId: mapId);
    expect(bounds, expectedBounds);
  });

  test('moveCamera calls through with expected scrollBy', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    final CameraUpdate update = CameraUpdate.scrollBy(10, 20);
    await maps.moveCamera(update, mapId: mapId);

    final VerificationResult verification = verify(api.moveCamera(captureAny));
    final PlatformCameraUpdate passedUpdate =
        verification.captured[0] as PlatformCameraUpdate;
    final PlatformCameraUpdateScrollBy scroll =
        passedUpdate.cameraUpdate as PlatformCameraUpdateScrollBy;
    update as CameraUpdateScrollBy;
    expect(scroll.dx, update.dx);
    expect(scroll.dy, update.dy);
  });

  test('animateCamera calls through with expected scrollBy', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    final CameraUpdate update = CameraUpdate.scrollBy(10, 20);
    await maps.animateCamera(update, mapId: mapId);

    final VerificationResult verification =
        verify(api.animateCamera(captureAny));
    final PlatformCameraUpdate passedUpdate =
        verification.captured[0] as PlatformCameraUpdate;
    final PlatformCameraUpdateScrollBy scroll =
        passedUpdate.cameraUpdate as PlatformCameraUpdateScrollBy;
    update as CameraUpdateScrollBy;
    expect(scroll.dx, update.dx);
    expect(scroll.dy, update.dy);
  });

  test('getZoomLevel passes values correctly', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    const double expectedZoom = 4.2;
    when(api.getZoomLevel()).thenAnswer((_) async => expectedZoom);

    final double zoom = await maps.getZoomLevel(mapId: mapId);
    expect(zoom, expectedZoom);
  });

  test('showInfoWindow calls through', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    const String markedId = 'a_marker';
    await maps.showMarkerInfoWindow(const MarkerId(markedId), mapId: mapId);

    verify(api.showInfoWindow(markedId));
  });

  test('hideInfoWindow calls through', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    const String markedId = 'a_marker';
    await maps.hideMarkerInfoWindow(const MarkerId(markedId), mapId: mapId);

    verify(api.hideInfoWindow(markedId));
  });

  test('isInfoWindowShown calls through', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    const String markedId = 'a_marker';
    when(api.isInfoWindowShown(markedId)).thenAnswer((_) async => true);

    expect(
        await maps.isMarkerInfoWindowShown(const MarkerId(markedId),
            mapId: mapId),
        true);
  });

  test('takeSnapshot calls through', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    final Uint8List fakeSnapshot = Uint8List(10);
    when(api.takeSnapshot()).thenAnswer((_) async => fakeSnapshot);

    expect(await maps.takeSnapshot(mapId: mapId), fakeSnapshot);
  });

  test('clearTileCache calls through', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    const String tileOverlayId = 'overlay';
    await maps.clearTileCache(const TileOverlayId(tileOverlayId), mapId: mapId);

    verify(api.clearTileCache(tileOverlayId));
  });

  test('updateMapConfiguration passes expected arguments', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    // Set some arbitrary options.
    final CameraTargetBounds cameraBounds = CameraTargetBounds(LatLngBounds(
        southwest: const LatLng(10, 20), northeast: const LatLng(30, 40)));
    final MapConfiguration config = MapConfiguration(
      compassEnabled: true,
      mapType: MapType.terrain,
      cameraTargetBounds: cameraBounds,
    );
    await maps.updateMapConfiguration(config, mapId: mapId);

    final VerificationResult verification =
        verify(api.updateMapConfiguration(captureAny));
    final PlatformMapConfiguration passedConfig =
        verification.captured[0] as PlatformMapConfiguration;
    // Each set option should be present.
    expect(passedConfig.compassEnabled, true);
    expect(passedConfig.mapType, PlatformMapType.terrain);
    expect(passedConfig.cameraTargetBounds?.bounds?.northeast.latitude,
        cameraBounds.bounds?.northeast.latitude);
    expect(passedConfig.cameraTargetBounds?.bounds?.northeast.longitude,
        cameraBounds.bounds?.northeast.longitude);
    expect(passedConfig.cameraTargetBounds?.bounds?.southwest.latitude,
        cameraBounds.bounds?.southwest.latitude);
    expect(passedConfig.cameraTargetBounds?.bounds?.southwest.longitude,
        cameraBounds.bounds?.southwest.longitude);
    // Spot-check that unset options are not be present.
    expect(passedConfig.myLocationEnabled, isNull);
    expect(passedConfig.minMaxZoomPreference, isNull);
    expect(passedConfig.padding, isNull);
  });

  test('updateMapOptions passes expected arguments', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    // Set some arbitrary options.
    final CameraTargetBounds cameraBounds = CameraTargetBounds(LatLngBounds(
        southwest: const LatLng(10, 20), northeast: const LatLng(30, 40)));
    final Map<String, Object?> config = <String, Object?>{
      'compassEnabled': true,
      'mapType': MapType.terrain.index,
      'cameraTargetBounds': cameraBounds.toJson(),
    };
    await maps.updateMapOptions(config, mapId: mapId);

    final VerificationResult verification =
        verify(api.updateMapConfiguration(captureAny));
    final PlatformMapConfiguration passedConfig =
        verification.captured[0] as PlatformMapConfiguration;
    // Each set option should be present.
    expect(passedConfig.compassEnabled, true);
    expect(passedConfig.mapType, PlatformMapType.terrain);
    expect(passedConfig.cameraTargetBounds?.bounds?.northeast.latitude,
        cameraBounds.bounds?.northeast.latitude);
    expect(passedConfig.cameraTargetBounds?.bounds?.northeast.longitude,
        cameraBounds.bounds?.northeast.longitude);
    expect(passedConfig.cameraTargetBounds?.bounds?.southwest.latitude,
        cameraBounds.bounds?.southwest.latitude);
    expect(passedConfig.cameraTargetBounds?.bounds?.southwest.longitude,
        cameraBounds.bounds?.southwest.longitude);
    // Spot-check that unset options are not be present.
    expect(passedConfig.myLocationEnabled, isNull);
    expect(passedConfig.minMaxZoomPreference, isNull);
    expect(passedConfig.padding, isNull);
  });

  test('updateCircles passes expected arguments', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    const Circle object1 = Circle(circleId: CircleId('1'));
    const Circle object2old = Circle(circleId: CircleId('2'));
    final Circle object2new = object2old.copyWith(radiusParam: 42);
    const Circle object3 = Circle(circleId: CircleId('3'));
    await maps.updateCircles(
        CircleUpdates.from(
            <Circle>{object1, object2old}, <Circle>{object2new, object3}),
        mapId: mapId);

    final VerificationResult verification =
        verify(api.updateCircles(captureAny, captureAny, captureAny));
    final List<PlatformCircle> toAdd =
        verification.captured[0] as List<PlatformCircle>;
    final List<PlatformCircle> toChange =
        verification.captured[1] as List<PlatformCircle>;
    final List<String> toRemove = verification.captured[2] as List<String>;
    // Object one should be removed.
    expect(toRemove.length, 1);
    expect(toRemove.first, object1.circleId.value);
    // Object two should be changed.
    {
      expect(toChange.length, 1);
      final PlatformCircle firstChanged = toChange.first;
      expect(firstChanged.consumeTapEvents, object2new.consumeTapEvents);
      expect(firstChanged.fillColor, object2new.fillColor.value);
      expect(firstChanged.strokeColor, object2new.strokeColor.value);
      expect(firstChanged.visible, object2new.visible);
      expect(firstChanged.strokeWidth, object2new.strokeWidth);
      expect(firstChanged.zIndex, object2new.zIndex.toDouble());
      expect(firstChanged.center.latitude, object2new.center.latitude);
      expect(firstChanged.center.longitude, object2new.center.longitude);
      expect(firstChanged.radius, object2new.radius);
      expect(firstChanged.circleId, object2new.circleId.value);
    }
    // Object 3 should be added.
    {
      expect(toAdd.length, 1);
      final PlatformCircle firstAdded = toAdd.first;
      expect(firstAdded.consumeTapEvents, object3.consumeTapEvents);
      expect(firstAdded.fillColor, object3.fillColor.value);
      expect(firstAdded.strokeColor, object3.strokeColor.value);
      expect(firstAdded.visible, object3.visible);
      expect(firstAdded.strokeWidth, object3.strokeWidth);
      expect(firstAdded.zIndex, object3.zIndex.toDouble());
      expect(firstAdded.center.latitude, object3.center.latitude);
      expect(firstAdded.center.longitude, object3.center.longitude);
      expect(firstAdded.radius, object3.radius);
      expect(firstAdded.circleId, object3.circleId.value);
    }
  });

  test('updateClusterManagers passes expected arguments', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    const ClusterManager object1 =
        ClusterManager(clusterManagerId: ClusterManagerId('1'));
    const ClusterManager object3 =
        ClusterManager(clusterManagerId: ClusterManagerId('3'));
    await maps.updateClusterManagers(
        ClusterManagerUpdates.from(
            <ClusterManager>{object1}, <ClusterManager>{object3}),
        mapId: mapId);

    final VerificationResult verification =
        verify(api.updateClusterManagers(captureAny, captureAny));
    final List<PlatformClusterManager> toAdd =
        verification.captured[0] as List<PlatformClusterManager>;
    final List<String> toRemove = verification.captured[1] as List<String>;
    // Object one should be removed.
    expect(toRemove.length, 1);
    expect(toRemove.first, object1.clusterManagerId.value);
    // Unlike other map object types, changes are not possible for cluster
    // managers, since they have no non-ID properties.
    // Object 3 should be added.
    expect(toAdd.length, 1);
    expect(toAdd.first.identifier, object3.clusterManagerId.value);
  });

  test('updateMarkers passes expected arguments', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    const Marker object1 = Marker(markerId: MarkerId('1'));
    const Marker object2old = Marker(markerId: MarkerId('2'));
    final Marker object2new = object2old.copyWith(rotationParam: 42);
    const Marker object3 = Marker(markerId: MarkerId('3'));
    await maps.updateMarkers(
        MarkerUpdates.from(
            <Marker>{object1, object2old}, <Marker>{object2new, object3}),
        mapId: mapId);

    final VerificationResult verification =
        verify(api.updateMarkers(captureAny, captureAny, captureAny));
    final List<PlatformMarker> toAdd =
        verification.captured[0] as List<PlatformMarker>;
    final List<PlatformMarker> toChange =
        verification.captured[1] as List<PlatformMarker>;
    final List<String> toRemove = verification.captured[2] as List<String>;
    // Object one should be removed.
    expect(toRemove.length, 1);
    expect(toRemove.first, object1.markerId.value);
    // Object two should be changed.
    {
      expect(toChange.length, 1);
      final PlatformMarker firstChanged = toChange.first;
      expect(firstChanged.alpha, object2new.alpha);
      expect(firstChanged.anchor.x, object2new.anchor.dx);
      expect(firstChanged.anchor.y, object2new.anchor.dy);
      expect(firstChanged.consumeTapEvents, object2new.consumeTapEvents);
      expect(firstChanged.draggable, object2new.draggable);
      expect(firstChanged.flat, object2new.flat);
      expect(
          firstChanged.icon.bitmap.runtimeType,
          GoogleMapsFlutterAndroid.platformBitmapFromBitmapDescriptor(
                  object2new.icon)
              .bitmap
              .runtimeType);
      expect(firstChanged.infoWindow.title, object2new.infoWindow.title);
      expect(firstChanged.infoWindow.snippet, object2new.infoWindow.snippet);
      expect(firstChanged.infoWindow.anchor.x, object2new.infoWindow.anchor.dx);
      expect(firstChanged.infoWindow.anchor.y, object2new.infoWindow.anchor.dy);
      expect(firstChanged.position.latitude, object2new.position.latitude);
      expect(firstChanged.position.longitude, object2new.position.longitude);
      expect(firstChanged.rotation, object2new.rotation);
      expect(firstChanged.visible, object2new.visible);
      expect(firstChanged.zIndex, object2new.zIndex);
      expect(firstChanged.markerId, object2new.markerId.value);
      expect(firstChanged.clusterManagerId, object2new.clusterManagerId?.value);
    }
    // Object 3 should be added.
    {
      expect(toAdd.length, 1);
      final PlatformMarker firstAdded = toAdd.first;
      expect(firstAdded.alpha, object3.alpha);
      expect(firstAdded.anchor.x, object3.anchor.dx);
      expect(firstAdded.anchor.y, object3.anchor.dy);
      expect(firstAdded.consumeTapEvents, object3.consumeTapEvents);
      expect(firstAdded.draggable, object3.draggable);
      expect(firstAdded.flat, object3.flat);
      expect(
          firstAdded.icon.bitmap.runtimeType,
          GoogleMapsFlutterAndroid.platformBitmapFromBitmapDescriptor(
                  object3.icon)
              .bitmap
              .runtimeType);
      expect(firstAdded.infoWindow.title, object3.infoWindow.title);
      expect(firstAdded.infoWindow.snippet, object3.infoWindow.snippet);
      expect(firstAdded.infoWindow.anchor.x, object3.infoWindow.anchor.dx);
      expect(firstAdded.infoWindow.anchor.y, object3.infoWindow.anchor.dy);
      expect(firstAdded.position.latitude, object3.position.latitude);
      expect(firstAdded.position.longitude, object3.position.longitude);
      expect(firstAdded.rotation, object3.rotation);
      expect(firstAdded.visible, object3.visible);
      expect(firstAdded.zIndex, object3.zIndex);
      expect(firstAdded.markerId, object3.markerId.value);
      expect(firstAdded.clusterManagerId, object3.clusterManagerId?.value);
    }
  });

  test('updatePolygons passes expected arguments', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    const Polygon object1 = Polygon(polygonId: PolygonId('1'));
    const Polygon object2old = Polygon(polygonId: PolygonId('2'));
    final Polygon object2new = object2old.copyWith(strokeWidthParam: 42);
    const Polygon object3 = Polygon(polygonId: PolygonId('3'));
    await maps.updatePolygons(
        PolygonUpdates.from(
            <Polygon>{object1, object2old}, <Polygon>{object2new, object3}),
        mapId: mapId);

    final VerificationResult verification =
        verify(api.updatePolygons(captureAny, captureAny, captureAny));
    final List<PlatformPolygon> toAdd =
        verification.captured[0] as List<PlatformPolygon>;
    final List<PlatformPolygon> toChange =
        verification.captured[1] as List<PlatformPolygon>;
    final List<String> toRemove = verification.captured[2] as List<String>;
    // Object one should be removed.
    expect(toRemove.length, 1);
    expect(toRemove.first, object1.polygonId.value);
    void expectPolygon(PlatformPolygon actual, Polygon expected) {
      expect(actual.polygonId, expected.polygonId.value);
      expect(actual.consumesTapEvents, expected.consumeTapEvents);
      expect(actual.fillColor, expected.fillColor.value);
      expect(actual.geodesic, expected.geodesic);
      expect(actual.points.length, expected.points.length);
      for (final (int i, PlatformLatLng? point) in actual.points.indexed) {
        expect(point?.latitude, expected.points[i].latitude);
        expect(point?.longitude, expected.points[i].longitude);
      }
      expect(actual.holes.length, expected.holes.length);
      for (final (int i, List<PlatformLatLng>? hole) in actual.holes.indexed) {
        final List<LatLng> expectedHole = expected.holes[i];
        for (final (int j, PlatformLatLng? point) in hole!.indexed) {
          expect(point?.latitude, expectedHole[j].latitude);
          expect(point?.longitude, expectedHole[j].longitude);
        }
      }
      expect(actual.visible, expected.visible);
      expect(actual.strokeColor, expected.strokeColor.value);
      expect(actual.strokeWidth, expected.strokeWidth);
      expect(actual.zIndex, expected.zIndex);
    }

    // Object two should be changed.
    expect(toChange.length, 1);
    expectPolygon(toChange.first, object2new);
    // Object 3 should be added.
    expect(toAdd.length, 1);
    expectPolygon(toAdd.first, object3);
  });

  test('updatePolylines passes expected arguments', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    const Polyline object1 = Polyline(polylineId: PolylineId('1'));
    const Polyline object2old = Polyline(polylineId: PolylineId('2'));
    final Polyline object2new = object2old.copyWith(
        widthParam: 42, startCapParam: Cap.squareCap, endCapParam: Cap.buttCap);
    final Cap customCap =
        Cap.customCapFromBitmap(BitmapDescriptor.defaultMarker, refWidth: 15);
    final Polyline object3 = Polyline(
        polylineId: const PolylineId('3'),
        startCap: customCap,
        endCap: Cap.roundCap);
    await maps.updatePolylines(
        PolylineUpdates.from(
            <Polyline>{object1, object2old}, <Polyline>{object2new, object3}),
        mapId: mapId);

    final VerificationResult verification =
        verify(api.updatePolylines(captureAny, captureAny, captureAny));
    final List<PlatformPolyline> toAdd =
        verification.captured[0] as List<PlatformPolyline>;
    final List<PlatformPolyline> toChange =
        verification.captured[1] as List<PlatformPolyline>;
    final List<String> toRemove = verification.captured[2] as List<String>;
    void expectPolyline(PlatformPolyline actual, Polyline expected) {
      expect(actual.polylineId, expected.polylineId.value);
      expect(actual.consumesTapEvents, expected.consumeTapEvents);
      expect(actual.color, expected.color.value);
      expect(actual.geodesic, expected.geodesic);
      expect(
          actual.jointType, platformJointTypeFromJointType(expected.jointType));
      expect(actual.visible, expected.visible);
      expect(actual.width, expected.width);
      expect(actual.zIndex, expected.zIndex);
      expect(actual.points.length, expected.points.length);
      for (final (int i, PlatformLatLng? point) in actual.points.indexed) {
        expect(point?.latitude, actual.points[i].latitude);
        expect(point?.longitude, actual.points[i].longitude);
      }
      expect(actual.patterns.length, expected.patterns.length);
      for (final (int i, PlatformPatternItem? pattern)
          in actual.patterns.indexed) {
        expect(pattern?.encode(),
            platformPatternItemFromPatternItem(expected.patterns[i]).encode());
      }
      final PlatformCap expectedStartCap =
          GoogleMapsFlutterAndroid.platformCapFromCap(expected.startCap);
      final PlatformCap expectedEndCap =
          GoogleMapsFlutterAndroid.platformCapFromCap(expected.endCap);
      expect(actual.startCap.type, expectedStartCap.type);
      expect(actual.startCap.refWidth, expectedStartCap.refWidth);
      expect(actual.startCap.bitmapDescriptor?.bitmap.runtimeType,
          expectedStartCap.bitmapDescriptor?.bitmap.runtimeType);
      expect(actual.endCap.type, expectedEndCap.type);
      expect(actual.endCap.refWidth, expectedEndCap.refWidth);
      expect(actual.endCap.bitmapDescriptor?.bitmap.runtimeType,
          expectedEndCap.bitmapDescriptor?.bitmap.runtimeType);
    }

    // Object one should be removed.
    expect(toRemove.length, 1);
    expect(toRemove.first, object1.polylineId.value);
    // Object two should be changed.
    expect(toChange.length, 1);
    expectPolyline(toChange.first, object2new);
    // Object 3 should be added.
    expect(toAdd.length, 1);
    expectPolyline(toAdd.first, object3);
  });

  test('updateTileOverlays passes expected arguments', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    const TileOverlay object1 = TileOverlay(tileOverlayId: TileOverlayId('1'));
    const TileOverlay object2old =
        TileOverlay(tileOverlayId: TileOverlayId('2'));
    final TileOverlay object2new = object2old.copyWith(zIndexParam: 42);
    const TileOverlay object3 = TileOverlay(tileOverlayId: TileOverlayId('3'));
    // Pre-set the initial state, since this update method doesn't take the old
    // state.
    await maps.updateTileOverlays(
        newTileOverlays: <TileOverlay>{object1, object2old}, mapId: mapId);
    clearInteractions(api);

    await maps.updateTileOverlays(
        newTileOverlays: <TileOverlay>{object2new, object3}, mapId: mapId);

    final VerificationResult verification =
        verify(api.updateTileOverlays(captureAny, captureAny, captureAny));
    final List<PlatformTileOverlay> toAdd =
        verification.captured[0] as List<PlatformTileOverlay>;
    final List<PlatformTileOverlay> toChange =
        verification.captured[1] as List<PlatformTileOverlay>;
    final List<String> toRemove = verification.captured[2] as List<String>;
    void expectTileOverlay(PlatformTileOverlay actual, TileOverlay expected) {
      expect(actual.tileOverlayId, expected.tileOverlayId.value);
      expect(actual.fadeIn, expected.fadeIn);
      expect(actual.transparency, expected.transparency);
      expect(actual.zIndex, expected.zIndex);
      expect(actual.visible, expected.visible);
      expect(actual.tileSize, expected.tileSize);
    }

    // Object one should be removed.
    expect(toRemove.length, 1);
    expect(toRemove.first, object1.tileOverlayId.value);
    // Object two should be changed.
    expect(toChange.length, 1);
    expectTileOverlay(toChange.first, object2new);
    // Object 3 should be added.
    expect(toAdd.length, 1);
    expectTileOverlay(toAdd.first, object3);
  });

  test('markers send drag event to correct streams', () async {
    const int mapId = 1;
    const String dragStartId = 'drag-start-marker';
    const String dragId = 'drag-marker';
    const String dragEndId = 'drag-end-marker';
    final PlatformLatLng fakePosition =
        PlatformLatLng(latitude: 1.0, longitude: 1.0);

    final GoogleMapsFlutterAndroid maps = GoogleMapsFlutterAndroid();
    final HostMapMessageHandler callbackHandler =
        maps.ensureHandlerInitialized(mapId);

    final StreamQueue<MarkerDragStartEvent> markerDragStartStream =
        StreamQueue<MarkerDragStartEvent>(maps.onMarkerDragStart(mapId: mapId));
    final StreamQueue<MarkerDragEvent> markerDragStream =
        StreamQueue<MarkerDragEvent>(maps.onMarkerDrag(mapId: mapId));
    final StreamQueue<MarkerDragEndEvent> markerDragEndStream =
        StreamQueue<MarkerDragEndEvent>(maps.onMarkerDragEnd(mapId: mapId));

    // Simulate messages from the native side.
    callbackHandler.onMarkerDragStart(dragStartId, fakePosition);
    callbackHandler.onMarkerDrag(dragId, fakePosition);
    callbackHandler.onMarkerDragEnd(dragEndId, fakePosition);

    expect((await markerDragStartStream.next).value.value, equals(dragStartId));
    expect((await markerDragStream.next).value.value, equals(dragId));
    expect((await markerDragEndStream.next).value.value, equals(dragEndId));
  });

  test('markers send tap events to correct stream', () async {
    const int mapId = 1;
    const String objectId = 'object-id';

    final GoogleMapsFlutterAndroid maps = GoogleMapsFlutterAndroid();
    final HostMapMessageHandler callbackHandler =
        maps.ensureHandlerInitialized(mapId);

    final StreamQueue<MarkerTapEvent> stream =
        StreamQueue<MarkerTapEvent>(maps.onMarkerTap(mapId: mapId));

    // Simulate message from the native side.
    callbackHandler.onMarkerTap(objectId);

    expect((await stream.next).value.value, equals(objectId));
  });

  test('circles send tap events to correct stream', () async {
    const int mapId = 1;
    const String objectId = 'object-id';

    final GoogleMapsFlutterAndroid maps = GoogleMapsFlutterAndroid();
    final HostMapMessageHandler callbackHandler =
        maps.ensureHandlerInitialized(mapId);

    final StreamQueue<CircleTapEvent> stream =
        StreamQueue<CircleTapEvent>(maps.onCircleTap(mapId: mapId));

    // Simulate message from the native side.
    callbackHandler.onCircleTap(objectId);

    expect((await stream.next).value.value, equals(objectId));
  });

  test('clusters send tap events to correct stream', () async {
    const int mapId = 1;
    const String managerId = 'manager-id';
    final PlatformLatLng fakePosition =
        PlatformLatLng(latitude: 10, longitude: 20);
    final PlatformLatLngBounds fakeBounds = PlatformLatLngBounds(
        southwest: PlatformLatLng(latitude: 30, longitude: 40),
        northeast: PlatformLatLng(latitude: 50, longitude: 60));
    const List<String> markerIds = <String>['marker-1', 'marker-2'];
    final PlatformCluster cluster = PlatformCluster(
        clusterManagerId: managerId,
        position: fakePosition,
        bounds: fakeBounds,
        markerIds: markerIds);

    final GoogleMapsFlutterAndroid maps = GoogleMapsFlutterAndroid();
    final HostMapMessageHandler callbackHandler =
        maps.ensureHandlerInitialized(mapId);

    final StreamQueue<ClusterTapEvent> stream =
        StreamQueue<ClusterTapEvent>(maps.onClusterTap(mapId: mapId));

    // Simulate message from the native side.
    callbackHandler.onClusterTap(cluster);

    final Cluster eventValue = (await stream.next).value;
    expect(eventValue.clusterManagerId.value, managerId);
    expect(eventValue.position.latitude, fakePosition.latitude);
    expect(eventValue.position.longitude, fakePosition.longitude);
    expect(eventValue.bounds.southwest.latitude, fakeBounds.southwest.latitude);
    expect(
        eventValue.bounds.southwest.longitude, fakeBounds.southwest.longitude);
    expect(eventValue.bounds.northeast.latitude, fakeBounds.northeast.latitude);
    expect(
        eventValue.bounds.northeast.longitude, fakeBounds.northeast.longitude);
    expect(eventValue.markerIds.length, markerIds.length);
    expect(eventValue.markerIds.first.value, markerIds.first);
  });

  test('polygons send tap events to correct stream', () async {
    const int mapId = 1;
    const String objectId = 'object-id';

    final GoogleMapsFlutterAndroid maps = GoogleMapsFlutterAndroid();
    final HostMapMessageHandler callbackHandler =
        maps.ensureHandlerInitialized(mapId);

    final StreamQueue<PolygonTapEvent> stream =
        StreamQueue<PolygonTapEvent>(maps.onPolygonTap(mapId: mapId));

    // Simulate message from the native side.
    callbackHandler.onPolygonTap(objectId);

    expect((await stream.next).value.value, equals(objectId));
  });

  test('polylines send tap events to correct stream', () async {
    const int mapId = 1;
    const String objectId = 'object-id';

    final GoogleMapsFlutterAndroid maps = GoogleMapsFlutterAndroid();
    final HostMapMessageHandler callbackHandler =
        maps.ensureHandlerInitialized(mapId);

    final StreamQueue<PolylineTapEvent> stream =
        StreamQueue<PolylineTapEvent>(maps.onPolylineTap(mapId: mapId));

    // Simulate message from the native side.
    callbackHandler.onPolylineTap(objectId);

    expect((await stream.next).value.value, equals(objectId));
  });

  test(
    'Does not use PlatformViewLink when using TLHC',
    () async {
      final GoogleMapsFlutterAndroid maps = GoogleMapsFlutterAndroid();
      maps.useAndroidViewSurface = false;
      final Widget widget = maps.buildViewWithConfiguration(1, (int _) {},
          widgetConfiguration: const MapWidgetConfiguration(
              initialCameraPosition:
                  CameraPosition(target: LatLng(0, 0), zoom: 1),
              textDirection: TextDirection.ltr));

      expect(widget, isA<AndroidView>());
    },
  );

  test('moveCamera calls through with expected newCameraPosition', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    const LatLng latLng = LatLng(10.0, 20.0);
    const CameraPosition position = CameraPosition(target: latLng);
    final CameraUpdate update = CameraUpdate.newCameraPosition(position);
    await maps.moveCamera(update, mapId: mapId);

    final VerificationResult verification = verify(api.moveCamera(captureAny));
    final PlatformCameraUpdate passedUpdate =
        verification.captured[0] as PlatformCameraUpdate;
    final PlatformCameraUpdateNewCameraPosition typedUpdate =
        passedUpdate.cameraUpdate as PlatformCameraUpdateNewCameraPosition;
    update as CameraUpdateNewCameraPosition;
    expect(typedUpdate.cameraPosition.target.latitude,
        update.cameraPosition.target.latitude);
    expect(typedUpdate.cameraPosition.target.longitude,
        update.cameraPosition.target.longitude);
  });

  test('moveCamera calls through with expected newLatLng', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    const LatLng latLng = LatLng(10.0, 20.0);
    final CameraUpdate update = CameraUpdate.newLatLng(latLng);
    await maps.moveCamera(update, mapId: mapId);

    final VerificationResult verification = verify(api.moveCamera(captureAny));
    final PlatformCameraUpdate passedUpdate =
        verification.captured[0] as PlatformCameraUpdate;
    final PlatformCameraUpdateNewLatLng typedUpdate =
        passedUpdate.cameraUpdate as PlatformCameraUpdateNewLatLng;
    update as CameraUpdateNewLatLng;
    expect(typedUpdate.latLng.latitude, update.latLng.latitude);
    expect(typedUpdate.latLng.longitude, update.latLng.longitude);
  });

  test('moveCamera calls through with expected newLatLngBounds', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    final LatLngBounds latLng = LatLngBounds(
        northeast: const LatLng(10.0, 20.0),
        southwest: const LatLng(9.0, 21.0));
    final CameraUpdate update = CameraUpdate.newLatLngBounds(latLng, 1.0);
    await maps.moveCamera(update, mapId: mapId);

    final VerificationResult verification = verify(api.moveCamera(captureAny));
    final PlatformCameraUpdate passedUpdate =
        verification.captured[0] as PlatformCameraUpdate;
    final PlatformCameraUpdateNewLatLngBounds typedUpdate =
        passedUpdate.cameraUpdate as PlatformCameraUpdateNewLatLngBounds;
    update as CameraUpdateNewLatLngBounds;
    expect(typedUpdate.bounds.northeast.latitude,
        update.bounds.northeast.latitude);
    expect(typedUpdate.bounds.northeast.longitude,
        update.bounds.northeast.longitude);
    expect(typedUpdate.bounds.southwest.latitude,
        update.bounds.southwest.latitude);
    expect(typedUpdate.bounds.southwest.longitude,
        update.bounds.southwest.longitude);
    expect(typedUpdate.padding, update.padding);
  });

  test('moveCamera calls through with expected newLatLngZoom', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    const LatLng latLng = LatLng(10.0, 20.0);
    final CameraUpdate update = CameraUpdate.newLatLngZoom(latLng, 2.0);
    await maps.moveCamera(update, mapId: mapId);

    final VerificationResult verification = verify(api.moveCamera(captureAny));
    final PlatformCameraUpdate passedUpdate =
        verification.captured[0] as PlatformCameraUpdate;
    final PlatformCameraUpdateNewLatLngZoom typedUpdate =
        passedUpdate.cameraUpdate as PlatformCameraUpdateNewLatLngZoom;
    update as CameraUpdateNewLatLngZoom;
    expect(typedUpdate.latLng.latitude, update.latLng.latitude);
    expect(typedUpdate.latLng.longitude, update.latLng.longitude);
    expect(typedUpdate.zoom, update.zoom);
  });

  test('moveCamera calls through with expected zoomBy', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    const Offset focus = Offset(10.0, 20.0);
    final CameraUpdate update = CameraUpdate.zoomBy(2.0, focus);
    await maps.moveCamera(update, mapId: mapId);

    final VerificationResult verification = verify(api.moveCamera(captureAny));
    final PlatformCameraUpdate passedUpdate =
        verification.captured[0] as PlatformCameraUpdate;
    final PlatformCameraUpdateZoomBy typedUpdate =
        passedUpdate.cameraUpdate as PlatformCameraUpdateZoomBy;
    update as CameraUpdateZoomBy;
    expect(typedUpdate.focus?.x, update.focus?.dx);
    expect(typedUpdate.focus?.y, update.focus?.dy);
    expect(typedUpdate.amount, update.amount);
  });

  test('moveCamera calls through with expected zoomTo', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    final CameraUpdate update = CameraUpdate.zoomTo(2.0);
    await maps.moveCamera(update, mapId: mapId);

    final VerificationResult verification = verify(api.moveCamera(captureAny));
    final PlatformCameraUpdate passedUpdate =
        verification.captured[0] as PlatformCameraUpdate;
    final PlatformCameraUpdateZoomTo typedUpdate =
        passedUpdate.cameraUpdate as PlatformCameraUpdateZoomTo;
    update as CameraUpdateZoomTo;
    expect(typedUpdate.zoom, update.zoom);
  });

  test('moveCamera calls through with expected zoomIn', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    final CameraUpdate update = CameraUpdate.zoomIn();
    await maps.moveCamera(update, mapId: mapId);

    final VerificationResult verification = verify(api.moveCamera(captureAny));
    final PlatformCameraUpdate passedUpdate =
        verification.captured[0] as PlatformCameraUpdate;
    final PlatformCameraUpdateZoom typedUpdate =
        passedUpdate.cameraUpdate as PlatformCameraUpdateZoom;
    expect(typedUpdate.out, false);
  });

  test('moveCamera calls through with expected zoomOut', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    final CameraUpdate update = CameraUpdate.zoomOut();
    await maps.moveCamera(update, mapId: mapId);

    final VerificationResult verification = verify(api.moveCamera(captureAny));
    final PlatformCameraUpdate passedUpdate =
        verification.captured[0] as PlatformCameraUpdate;
    final PlatformCameraUpdateZoom typedUpdate =
        passedUpdate.cameraUpdate as PlatformCameraUpdateZoom;
    expect(typedUpdate.out, true);
  });

  test('MapBitmapScaling to PlatformMapBitmapScaling', () {
    expect(
        GoogleMapsFlutterAndroid.platformMapBitmapScalingFromScaling(
            MapBitmapScaling.auto),
        PlatformMapBitmapScaling.auto);
    expect(
        GoogleMapsFlutterAndroid.platformMapBitmapScalingFromScaling(
            MapBitmapScaling.none),
        PlatformMapBitmapScaling.none);
  });

  test('DefaultMarker bitmap to PlatformBitmap', () {
    final BitmapDescriptor bitmap = BitmapDescriptor.defaultMarkerWithHue(10.0);
    final PlatformBitmap platformBitmap =
        GoogleMapsFlutterAndroid.platformBitmapFromBitmapDescriptor(bitmap);
    expect(platformBitmap.bitmap, isA<PlatformBitmapDefaultMarker>());
    final PlatformBitmapDefaultMarker typedBitmap =
        platformBitmap.bitmap as PlatformBitmapDefaultMarker;
    expect(typedBitmap.hue, 10.0);
  });

  test('BytesMapBitmap bitmap to PlatformBitmap', () {
    final Uint8List data = Uint8List.fromList(<int>[1, 2, 3, 4]);
    final BytesMapBitmap bitmap = BitmapDescriptor.bytes(data,
        imagePixelRatio: 2.0, width: 100.0, height: 200.0);
    final PlatformBitmap platformBitmap =
        GoogleMapsFlutterAndroid.platformBitmapFromBitmapDescriptor(bitmap);
    expect(platformBitmap.bitmap, isA<PlatformBitmapBytesMap>());
    final PlatformBitmapBytesMap typedBitmap =
        platformBitmap.bitmap as PlatformBitmapBytesMap;
    expect(typedBitmap.byteData, data);
    expect(typedBitmap.bitmapScaling, PlatformMapBitmapScaling.auto);
    expect(typedBitmap.imagePixelRatio, 2.0);
    expect(typedBitmap.width, 100.0);
    expect(typedBitmap.height, 200.0);
  });

  test('AssetMapBitmap bitmap to PlatformBitmap', () {
    const String assetName = 'fake_asset_name';
    final AssetMapBitmap bitmap = AssetMapBitmap(assetName,
        imagePixelRatio: 2.0, width: 100.0, height: 200.0);
    final PlatformBitmap platformBitmap =
        GoogleMapsFlutterAndroid.platformBitmapFromBitmapDescriptor(bitmap);
    expect(platformBitmap.bitmap, isA<PlatformBitmapAssetMap>());
    final PlatformBitmapAssetMap typedBitmap =
        platformBitmap.bitmap as PlatformBitmapAssetMap;
    expect(typedBitmap.assetName, assetName);
    expect(typedBitmap.bitmapScaling, PlatformMapBitmapScaling.auto);
    expect(typedBitmap.imagePixelRatio, 2.0);
    expect(typedBitmap.width, 100.0);
    expect(typedBitmap.height, 200.0);
  });

  test('Cap to PlatformCap', () {
    expect(GoogleMapsFlutterAndroid.platformCapFromCap(Cap.buttCap).encode(),
        PlatformCap(type: PlatformCapType.buttCap).encode());
    expect(GoogleMapsFlutterAndroid.platformCapFromCap(Cap.roundCap).encode(),
        PlatformCap(type: PlatformCapType.roundCap).encode());
    expect(GoogleMapsFlutterAndroid.platformCapFromCap(Cap.squareCap).encode(),
        PlatformCap(type: PlatformCapType.squareCap).encode());

    const BitmapDescriptor bitmap = BitmapDescriptor.defaultMarker;
    const CustomCap customCap = CustomCap(bitmap, refWidth: 15.0);
    final PlatformCap platformCap =
        GoogleMapsFlutterAndroid.platformCapFromCap(customCap);
    expect(platformCap.type, PlatformCapType.customCap);
    expect(customCap.refWidth, 15.0);
  });

  testWidgets('Use PlatformViewLink when using surface view',
      (WidgetTester tester) async {
    final GoogleMapsFlutterAndroid maps = GoogleMapsFlutterAndroid();
    maps.useAndroidViewSurface = true;

    final Widget widget = maps.buildViewWithConfiguration(1, (int _) {},
        widgetConfiguration: const MapWidgetConfiguration(
            initialCameraPosition:
                CameraPosition(target: LatLng(0, 0), zoom: 1),
            textDirection: TextDirection.ltr));

    expect(widget, isA<PlatformViewLink>());
  });

  testWidgets('Defaults to AndroidView', (WidgetTester tester) async {
    final GoogleMapsFlutterAndroid maps = GoogleMapsFlutterAndroid();

    final Widget widget = maps.buildViewWithConfiguration(1, (int _) {},
        widgetConfiguration: const MapWidgetConfiguration(
            initialCameraPosition:
                CameraPosition(target: LatLng(0, 0), zoom: 1),
            textDirection: TextDirection.ltr));

    expect(widget, isA<AndroidView>());
  });

  testWidgets('cloudMapId is passed', (WidgetTester tester) async {
    const String cloudMapId = '000000000000000'; // Dummy map ID.
    final Completer<String> passedCloudMapIdCompleter = Completer<String>();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.platform_views,
      (MethodCall methodCall) async {
        if (methodCall.method == 'create') {
          final Map<String, dynamic> args = Map<String, dynamic>.from(
              methodCall.arguments as Map<dynamic, dynamic>);
          if (args.containsKey('params')) {
            final Uint8List paramsUint8List = args['params'] as Uint8List;
            final ByteData byteData = ByteData.sublistView(paramsUint8List);
            final PlatformMapViewCreationParams? creationParams =
                MapsApi.pigeonChannelCodec.decodeMessage(byteData)
                    as PlatformMapViewCreationParams?;
            if (creationParams != null) {
              final String? passedMapId =
                  creationParams.mapConfiguration.cloudMapId;
              if (passedMapId != null) {
                passedCloudMapIdCompleter.complete(passedMapId);
              }
            }
          }
        }
        return 0;
      },
    );

    final GoogleMapsFlutterAndroid maps = GoogleMapsFlutterAndroid();

    await tester.pumpWidget(maps.buildViewWithConfiguration(1, (int id) {},
        widgetConfiguration: const MapWidgetConfiguration(
            initialCameraPosition:
                CameraPosition(target: LatLng(0, 0), zoom: 1),
            textDirection: TextDirection.ltr),
        mapConfiguration: const MapConfiguration(cloudMapId: cloudMapId)));

    expect(
      await passedCloudMapIdCompleter.future,
      cloudMapId,
      reason: 'Should pass cloudMapId on PlatformView creation message',
    );
  });
}
