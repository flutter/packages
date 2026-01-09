// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/widgets.dart'
    show Directionality, SizedBox, TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart'
    show
        CameraPosition,
        LatLng,
        MapConfiguration,
        MapEvent,
        MapWidgetConfiguration;
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart'
    show GoogleMapController;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  MapWidgetConfiguration cfg() => const MapWidgetConfiguration(
    initialCameraPosition: CameraPosition(target: LatLng(0, 0), zoom: 1),
    textDirection: TextDirection.ltr,
  );

  testWidgets('cloudMapId present => mapId set & styles omitted', (
    WidgetTester tester,
  ) async {
    const testMapConfig = MapConfiguration(mapId: 'test-cloud-map-id');

    await tester.pumpWidget(
      const Directionality(textDirection: TextDirection.ltr, child: SizedBox()),
    );

    final stream = StreamController<MapEvent<Object?>>();
    addTearDown(() {
      // Stream is closed by controller.dispose()
    });

    gmaps.MapOptions? captured;

    final controller = GoogleMapController(
      mapId: 1, // Internal controller ID
      streamController: stream,
      widgetConfiguration: cfg(),
      mapConfiguration: testMapConfig, // cloudMapId is set here
    );

    controller.debugSetOverrides(
      setOptions: (gmaps.MapOptions options) {
        captured = options;
      },
    );

    final styles = <gmaps.MapTypeStyle>[
      gmaps.MapTypeStyle()
        ..featureType = 'road'
        ..elementType = 'geometry',
    ];

    controller.updateStyles(styles);

    await tester.pump();

    expect(captured, isNotNull);
    expect(captured!.mapId, testMapConfig.mapId);
    expect(
      captured!.styles == null || captured!.styles!.isEmpty,
      isTrue,
      reason: 'When cloudMapId is set, styles must not be applied.',
    );

    controller.dispose();
  });

  testWidgets('no cloudMapId => styles applied', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(textDirection: TextDirection.ltr, child: SizedBox()),
    );

    final stream = StreamController<MapEvent<Object?>>();
    addTearDown(() {
      // Stream is closed by controller.dispose()
    });

    gmaps.MapOptions? captured;
    final controller = GoogleMapController(
      mapId: 2, // Internal controller ID
      streamController: stream,
      widgetConfiguration: cfg(),
    );

    controller.debugSetOverrides(
      setOptions: (gmaps.MapOptions options) {
        captured = options;
      },
    );

    final styles = <gmaps.MapTypeStyle>[
      gmaps.MapTypeStyle()
        ..featureType = 'poi'
        ..elementType = 'labels',
    ];

    controller.updateStyles(styles);

    await tester.pump();

    expect(captured, isNotNull);
    expect(
      captured!.mapId,
      anyOf(isNull, isEmpty),
      reason: 'mapId should be empty/null when no Cloud Map is used.',
    );
    expect(captured!.styles, isNotNull);
    expect(
      captured!.styles,
      isNotEmpty,
      reason: 'When cloudMapId is null, styles should be applied.',
    );

    controller.dispose();
  });
}
