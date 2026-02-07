// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:google_maps_flutter_web/src/utils.dart';
import 'package:integration_test/integration_test.dart';

@JS()
@anonymous
extension type FakeIconMouseEvent._(JSObject _) implements JSObject {
  external factory FakeIconMouseEvent({
    gmaps.LatLng? latLng,
    String? placeId,
    JSFunction? stop,
  });
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('POI Tap Events', () {
    late GoogleMapController controller;
    late StreamController<MapEvent<Object?>> stream;
    late gmaps.Map map;

    setUp(() {
      stream = StreamController<MapEvent<Object?>>.broadcast();
      map = gmaps.Map(createDivElement());

      controller = GoogleMapController(
        mapId: 1,
        streamController: stream,
        widgetConfiguration: const MapWidgetConfiguration(
          initialCameraPosition: CameraPosition(target: LatLng(0, 0)),
          textDirection: TextDirection.ltr,
        ),
      );

      controller.debugSetOverrides(createMap: (_, __) => map);
      controller.init();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('Emits MapPoiTapEvent when clicking a POI', (
      WidgetTester tester,
    ) async {
      final latLng = gmaps.LatLng(10, 20);
      bool? stopCalled = false;

      final event = FakeIconMouseEvent(
        latLng: latLng,
        placeId: 'test_place_id',
        stop: (() {
          stopCalled = true;
        }).toJS,
      );
      gmaps.event.trigger(map, 'click', event as JSAny);

      final MapEvent<Object?> emittedEvent = await stream.stream.first;

      expect(emittedEvent, isA<MapPoiTapEvent>());
      final poiEvent = emittedEvent as MapPoiTapEvent;

      expect(poiEvent.mapId, 1);
      expect(poiEvent.value.placeId, 'test_place_id');
      expect(poiEvent.value.position.latitude, 10);
      expect(poiEvent.value.position.longitude, 20);

      expect(stopCalled, isTrue);
    });

    testWidgets('Emits MapTapEvent when clicking (no POI)', (
      WidgetTester tester,
    ) async {
      final latLng = gmaps.LatLng(30, 40);
      final event = gmaps.MapMouseEvent()..latLng = latLng;

      gmaps.event.trigger(map, 'click', event);

      final MapEvent<Object?> emittedEvent = await stream.stream.first;

      expect(emittedEvent, isA<MapTapEvent>());
      final tapEvent = emittedEvent as MapTapEvent;

      expect(tapEvent.mapId, 1);
      expect(tapEvent.position.latitude, 30);
      expect(tapEvent.position.longitude, 40);

      expect(emittedEvent, isNot(isA<MapPoiTapEvent>()));
    });
  });
}
