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

  test('moveCamera calls through', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    final CameraUpdate update = CameraUpdate.scrollBy(10, 20);
    await maps.moveCamera(update, mapId: mapId);

    final VerificationResult verification = verify(api.moveCamera(captureAny));
    final PlatformCameraUpdate passedUpdate =
        verification.captured[0] as PlatformCameraUpdate;
    expect(passedUpdate.json, update.toJson());
  });

  test('animateCamera calls through', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    final CameraUpdate update = CameraUpdate.scrollBy(10, 20);
    await maps.animateCamera(update, mapId: mapId);

    final VerificationResult verification =
        verify(api.animateCamera(captureAny));
    final PlatformCameraUpdate passedUpdate =
        verification.captured[0] as PlatformCameraUpdate;
    expect(passedUpdate.json, update.toJson());
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
    const MapConfiguration config = MapConfiguration(
      compassEnabled: true,
      liteModeEnabled: false,
      mapType: MapType.terrain,
    );
    await maps.updateMapConfiguration(config, mapId: mapId);

    final VerificationResult verification =
        verify(api.updateMapConfiguration(captureAny));
    final PlatformMapConfiguration passedConfig =
        verification.captured[0] as PlatformMapConfiguration;
    final Map<String, Object?> passedConfigJson =
        passedConfig.json as Map<String, Object?>;
    // Each set option should be present.
    expect(passedConfigJson['compassEnabled'], true);
    expect(passedConfigJson['liteModeEnabled'], false);
    expect(passedConfigJson['mapType'], MapType.terrain.index);
    // Spot-check that unset options are not be present.
    expect(passedConfigJson['myLocationEnabled'], isNull);
    expect(passedConfigJson['cameraTargetBounds'], isNull);
    expect(passedConfigJson['padding'], isNull);
  });

  test('updateMapOptions passes expected arguments', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    // Set some arbitrary options.
    final Map<String, Object?> config = <String, Object?>{
      'compassEnabled': true,
      'liteModeEnabled': false,
      'mapType': MapType.terrain.index,
    };
    await maps.updateMapOptions(config, mapId: mapId);

    final VerificationResult verification =
        verify(api.updateMapConfiguration(captureAny));
    final PlatformMapConfiguration passedConfig =
        verification.captured[0] as PlatformMapConfiguration;
    final Map<String, Object?> passedConfigJson =
        passedConfig.json as Map<String, Object?>;
    // Each set option should be present.
    expect(passedConfigJson['compassEnabled'], true);
    expect(passedConfigJson['liteModeEnabled'], false);
    expect(passedConfigJson['mapType'], MapType.terrain.index);
    // Spot-check that unset options are not be present.
    expect(passedConfigJson['myLocationEnabled'], isNull);
    expect(passedConfigJson['cameraTargetBounds'], isNull);
    expect(passedConfigJson['padding'], isNull);
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
    final List<PlatformCircle?> toAdd =
        verification.captured[0] as List<PlatformCircle?>;
    final List<PlatformCircle?> toChange =
        verification.captured[1] as List<PlatformCircle?>;
    final List<String?> toRemove = verification.captured[2] as List<String?>;
    // Object one should be removed.
    expect(toRemove.length, 1);
    expect(toRemove.first, object1.circleId.value);
    // Object two should be changed.
    expect(toChange.length, 1);
    expect(toChange.first?.json, object2new.toJson());
    // Object 3 should be added.
    expect(toAdd.length, 1);
    expect(toAdd.first?.json, object3.toJson());
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
    final List<PlatformClusterManager?> toAdd =
        verification.captured[0] as List<PlatformClusterManager?>;
    final List<String?> toRemove = verification.captured[1] as List<String?>;
    // Object one should be removed.
    expect(toRemove.length, 1);
    expect(toRemove.first, object1.clusterManagerId.value);
    // Unlike other map object types, changes are not possible for cluster
    // managers, since they have no non-ID properties.
    // Object 3 should be added.
    expect(toAdd.length, 1);
    expect(toAdd.first?.identifier, object3.clusterManagerId.value);
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
    final List<PlatformMarker?> toAdd =
        verification.captured[0] as List<PlatformMarker?>;
    final List<PlatformMarker?> toChange =
        verification.captured[1] as List<PlatformMarker?>;
    final List<String?> toRemove = verification.captured[2] as List<String?>;
    // Object one should be removed.
    expect(toRemove.length, 1);
    expect(toRemove.first, object1.markerId.value);
    // Object two should be changed.
    expect(toChange.length, 1);
    expect(toChange.first?.json, object2new.toJson());
    // Object 3 should be added.
    expect(toAdd.length, 1);
    expect(toAdd.first?.json, object3.toJson());
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
    final List<PlatformPolygon?> toAdd =
        verification.captured[0] as List<PlatformPolygon?>;
    final List<PlatformPolygon?> toChange =
        verification.captured[1] as List<PlatformPolygon?>;
    final List<String?> toRemove = verification.captured[2] as List<String?>;
    // Object one should be removed.
    expect(toRemove.length, 1);
    expect(toRemove.first, object1.polygonId.value);
    // Object two should be changed.
    expect(toChange.length, 1);
    expect(toChange.first?.json, object2new.toJson());
    // Object 3 should be added.
    expect(toAdd.length, 1);
    expect(toAdd.first?.json, object3.toJson());
  });

  test('updatePolylines passes expected arguments', () async {
    const int mapId = 1;
    final (GoogleMapsFlutterAndroid maps, MockMapsApi api) =
        setUpMockMap(mapId: mapId);

    const Polyline object1 = Polyline(polylineId: PolylineId('1'));
    const Polyline object2old = Polyline(polylineId: PolylineId('2'));
    final Polyline object2new = object2old.copyWith(widthParam: 42);
    const Polyline object3 = Polyline(polylineId: PolylineId('3'));
    await maps.updatePolylines(
        PolylineUpdates.from(
            <Polyline>{object1, object2old}, <Polyline>{object2new, object3}),
        mapId: mapId);

    final VerificationResult verification =
        verify(api.updatePolylines(captureAny, captureAny, captureAny));
    final List<PlatformPolyline?> toAdd =
        verification.captured[0] as List<PlatformPolyline?>;
    final List<PlatformPolyline?> toChange =
        verification.captured[1] as List<PlatformPolyline?>;
    final List<String?> toRemove = verification.captured[2] as List<String?>;
    // Object one should be removed.
    expect(toRemove.length, 1);
    expect(toRemove.first, object1.polylineId.value);
    // Object two should be changed.
    expect(toChange.length, 1);
    expect(toChange.first?.json, object2new.toJson());
    // Object 3 should be added.
    expect(toAdd.length, 1);
    expect(toAdd.first?.json, object3.toJson());
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
    final List<PlatformTileOverlay?> toAdd =
        verification.captured[0] as List<PlatformTileOverlay?>;
    final List<PlatformTileOverlay?> toChange =
        verification.captured[1] as List<PlatformTileOverlay?>;
    final List<String?> toRemove = verification.captured[2] as List<String?>;
    // Object one should be removed.
    expect(toRemove.length, 1);
    expect(toRemove.first, object1.tileOverlayId.value);
    // Object two should be changed.
    expect(toChange.length, 1);
    expect(toChange.first?.json, object2new.toJson());
    // Object 3 should be added.
    expect(toAdd.length, 1);
    expect(toAdd.first?.json, object3.toJson());
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
            const StandardMessageCodec codec = StandardMessageCodec();
            final ByteData byteData = ByteData.sublistView(paramsUint8List);
            final Map<String, dynamic> creationParams =
                Map<String, dynamic>.from(
                    codec.decodeMessage(byteData) as Map<dynamic, dynamic>);
            if (creationParams.containsKey('options')) {
              final Map<String, dynamic> options = Map<String, dynamic>.from(
                  creationParams['options'] as Map<dynamic, dynamic>);
              if (options.containsKey('cloudMapId')) {
                passedCloudMapIdCompleter
                    .complete(options['cloudMapId'] as String);
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
