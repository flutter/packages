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

  Future<void> sendPlatformMessage(
      int mapId, String method, Map<dynamic, dynamic> data) async {
    final ByteData byteData =
        const StandardMethodCodec().encodeMethodCall(MethodCall(method, data));
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage('plugins.flutter.dev/google_maps_android_$mapId',
            byteData, (ByteData? data) {});
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

  test('markers send drag event to correct streams', () async {
    const int mapId = 1;
    final Map<dynamic, dynamic> jsonMarkerDragStartEvent = <dynamic, dynamic>{
      'mapId': mapId,
      'markerId': 'drag-start-marker',
      'position': <double>[1.0, 1.0]
    };
    final Map<dynamic, dynamic> jsonMarkerDragEvent = <dynamic, dynamic>{
      'mapId': mapId,
      'markerId': 'drag-marker',
      'position': <double>[1.0, 1.0]
    };
    final Map<dynamic, dynamic> jsonMarkerDragEndEvent = <dynamic, dynamic>{
      'mapId': mapId,
      'markerId': 'drag-end-marker',
      'position': <double>[1.0, 1.0]
    };

    final GoogleMapsFlutterAndroid maps = GoogleMapsFlutterAndroid();
    maps.ensureChannelInitialized(mapId);

    final StreamQueue<MarkerDragStartEvent> markerDragStartStream =
        StreamQueue<MarkerDragStartEvent>(maps.onMarkerDragStart(mapId: mapId));
    final StreamQueue<MarkerDragEvent> markerDragStream =
        StreamQueue<MarkerDragEvent>(maps.onMarkerDrag(mapId: mapId));
    final StreamQueue<MarkerDragEndEvent> markerDragEndStream =
        StreamQueue<MarkerDragEndEvent>(maps.onMarkerDragEnd(mapId: mapId));

    await sendPlatformMessage(
        mapId, 'marker#onDragStart', jsonMarkerDragStartEvent);
    await sendPlatformMessage(mapId, 'marker#onDrag', jsonMarkerDragEvent);
    await sendPlatformMessage(
        mapId, 'marker#onDragEnd', jsonMarkerDragEndEvent);

    expect((await markerDragStartStream.next).value.value,
        equals('drag-start-marker'));
    expect((await markerDragStream.next).value.value, equals('drag-marker'));
    expect((await markerDragEndStream.next).value.value,
        equals('drag-end-marker'));
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
