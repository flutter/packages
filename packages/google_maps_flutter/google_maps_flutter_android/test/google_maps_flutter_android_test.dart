// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> log;

  setUp(() async {
    log = <String>[];
  });

  /// Initializes a map with the given ID and canned responses, logging all
  /// calls to [log].
  void configureMockMap(
    GoogleMapsFlutterAndroid maps, {
    required int mapId,
    required Future<dynamic>? Function(MethodCall call) handler,
  }) {
    final MethodChannel channel = maps.ensureChannelInitialized(mapId);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) {
        log.add(methodCall.method);
        return handler(methodCall);
      },
    );
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

  // Calls each method that uses invokeMethod with a return type other than
  // void to ensure that the casting/nullability handling succeeds.
  //
  // TODO(stuartmorgan): Remove this once there is real test coverage of
  // each method, since that would cover this issue.
  test('non-void invokeMethods handle types correctly', () async {
    const int mapId = 0;
    final GoogleMapsFlutterAndroid maps = GoogleMapsFlutterAndroid();
    configureMockMap(maps, mapId: mapId,
        handler: (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'map#getLatLng':
          return <dynamic>[1.0, 2.0];
        case 'markers#isInfoWindowShown':
          return true;
        case 'map#getZoomLevel':
          return 2.5;
        case 'map#takeSnapshot':
          return null;
      }
    });

    await maps.getLatLng(const ScreenCoordinate(x: 0, y: 0), mapId: mapId);
    await maps.isMarkerInfoWindowShown(const MarkerId(''), mapId: mapId);
    await maps.getZoomLevel(mapId: mapId);
    await maps.takeSnapshot(mapId: mapId);
    // Check that all the invokeMethod calls happened.
    expect(log, <String>[
      'map#getLatLng',
      'markers#isInfoWindowShown',
      'map#getZoomLevel',
      'map#takeSnapshot',
    ]);
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
