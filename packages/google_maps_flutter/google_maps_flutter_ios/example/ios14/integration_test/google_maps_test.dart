// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:integration_test/integration_test.dart';
import 'package:maps_example_dart/example_google_map.dart';

import 'resources/icon_image_base64.dart';

const LatLng _kInitialMapCenter = LatLng(0, 0);
const double _kInitialZoomLevel = 5;
const CameraPosition _kInitialCameraPosition = CameraPosition(
  target: _kInitialMapCenter,
  zoom: _kInitialZoomLevel,
);
const String _kCloudMapId = '000000000000000'; // Dummy map ID.

// The tolerance value for floating-point comparisons in the tests.
// This value was selected as the minimum possible value that the test passes.
// There are multiple float conversions and calculations when data is converted
// between Dart and platform implementations.
const double _floatTolerance = 1e-6;
const double _kTestCameraZoomLevel = 10;
const double _kTestZoomByAmount = 2;
const LatLng _kTestMapCenter = LatLng(65, 25.5);
const CameraPosition _kTestCameraPosition = CameraPosition(
  target: _kTestMapCenter,
  zoom: _kTestCameraZoomLevel,
  bearing: 1.0,
  tilt: 1.0,
);
final LatLngBounds _testCameraBounds = LatLngBounds(
    northeast: const LatLng(50, -65), southwest: const LatLng(28.5, -123));
final ValueVariant<CameraUpdateType> _cameraUpdateTypeVariants =
    ValueVariant<CameraUpdateType>(CameraUpdateType.values.toSet());

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  GoogleMapsFlutterPlatform.instance.enableDebugInspection();

  testWidgets('testCompassToggle', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        compassEnabled: false,
        onMapCreated: (ExampleGoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    ));

    final int mapId = await mapIdCompleter.future;
    final GoogleMapsInspectorPlatform inspector =
        GoogleMapsInspectorPlatform.instance!;
    bool compassEnabled = await inspector.isCompassEnabled(mapId: mapId);
    expect(compassEnabled, false);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (ExampleGoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
        },
      ),
    ));

    compassEnabled = await inspector.isCompassEnabled(mapId: mapId);
    expect(compassEnabled, true);
  });

  testWidgets('testMapToolbar returns false', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (ExampleGoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    ));

    final int mapId = await mapIdCompleter.future;
    final GoogleMapsInspectorPlatform inspector =
        GoogleMapsInspectorPlatform.instance!;
    final bool mapToolbarEnabled =
        await inspector.isMapToolbarEnabled(mapId: mapId);
    // This is only supported on Android, so should always return false.
    expect(mapToolbarEnabled, false);
  });

  testWidgets('updateMinMaxZoomLevels', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<ExampleGoogleMapController> controllerCompleter =
        Completer<ExampleGoogleMapController>();

    const MinMaxZoomPreference initialZoomLevel = MinMaxZoomPreference(4, 8);
    const MinMaxZoomPreference finalZoomLevel = MinMaxZoomPreference(6, 10);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        minMaxZoomPreference: initialZoomLevel,
        onMapCreated: (ExampleGoogleMapController c) async {
          controllerCompleter.complete(c);
        },
      ),
    ));

    final ExampleGoogleMapController controller =
        await controllerCompleter.future;
    final GoogleMapsInspectorPlatform inspector =
        GoogleMapsInspectorPlatform.instance!;

    MinMaxZoomPreference zoomLevel =
        await inspector.getMinMaxZoomLevels(mapId: controller.mapId);
    expect(zoomLevel, equals(initialZoomLevel));

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        minMaxZoomPreference: finalZoomLevel,
        onMapCreated: (ExampleGoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
        },
      ),
    ));

    zoomLevel = await inspector.getMinMaxZoomLevels(mapId: controller.mapId);
    expect(zoomLevel, equals(finalZoomLevel));
  });

  testWidgets('testZoomGesturesEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        zoomGesturesEnabled: false,
        onMapCreated: (ExampleGoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    ));

    final int mapId = await mapIdCompleter.future;
    final GoogleMapsInspectorPlatform inspector =
        GoogleMapsInspectorPlatform.instance!;
    bool zoomGesturesEnabled =
        await inspector.areZoomGesturesEnabled(mapId: mapId);
    expect(zoomGesturesEnabled, false);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (ExampleGoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
        },
      ),
    ));

    zoomGesturesEnabled = await inspector.areZoomGesturesEnabled(mapId: mapId);
    expect(zoomGesturesEnabled, true);
  });

  testWidgets('testZoomControlsEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (ExampleGoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    ));

    final int mapId = await mapIdCompleter.future;
    final GoogleMapsInspectorPlatform inspector =
        GoogleMapsInspectorPlatform.instance!;
    final bool zoomControlsEnabled =
        await inspector.areZoomControlsEnabled(mapId: mapId);

    /// Zoom Controls functionality is not available on iOS at the moment.
    expect(zoomControlsEnabled, false);
  });

  testWidgets('testRotateGesturesEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        rotateGesturesEnabled: false,
        onMapCreated: (ExampleGoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    ));

    final int mapId = await mapIdCompleter.future;
    final GoogleMapsInspectorPlatform inspector =
        GoogleMapsInspectorPlatform.instance!;
    bool rotateGesturesEnabled =
        await inspector.areRotateGesturesEnabled(mapId: mapId);
    expect(rotateGesturesEnabled, false);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (ExampleGoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
        },
      ),
    ));

    rotateGesturesEnabled =
        await inspector.areRotateGesturesEnabled(mapId: mapId);
    expect(rotateGesturesEnabled, true);
  });

  testWidgets('testTiltGesturesEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        tiltGesturesEnabled: false,
        onMapCreated: (ExampleGoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    ));

    final int mapId = await mapIdCompleter.future;
    final GoogleMapsInspectorPlatform inspector =
        GoogleMapsInspectorPlatform.instance!;
    bool tiltGesturesEnabled =
        await inspector.areTiltGesturesEnabled(mapId: mapId);
    expect(tiltGesturesEnabled, false);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (ExampleGoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
        },
      ),
    ));

    tiltGesturesEnabled = await inspector.areTiltGesturesEnabled(mapId: mapId);
    expect(tiltGesturesEnabled, true);
  });

  testWidgets('testScrollGesturesEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        scrollGesturesEnabled: false,
        onMapCreated: (ExampleGoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    ));

    final int mapId = await mapIdCompleter.future;
    final GoogleMapsInspectorPlatform inspector =
        GoogleMapsInspectorPlatform.instance!;
    bool scrollGesturesEnabled =
        await inspector.areScrollGesturesEnabled(mapId: mapId);
    expect(scrollGesturesEnabled, false);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (ExampleGoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
        },
      ),
    ));

    scrollGesturesEnabled =
        await inspector.areScrollGesturesEnabled(mapId: mapId);
    expect(scrollGesturesEnabled, true);
  });

  testWidgets('testInitialCenterLocationAtCenter', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));

    final Completer<ExampleGoogleMapController> mapControllerCompleter =
        Completer<ExampleGoogleMapController>();
    final Key key = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ExampleGoogleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          onMapCreated: (ExampleGoogleMapController controller) {
            mapControllerCompleter.complete(controller);
          },
        ),
      ),
    );
    final ExampleGoogleMapController mapController =
        await mapControllerCompleter.future;

    await tester.pumpAndSettle();

    // TODO(cyanglaz): Remove this after we added `mapRendered` callback, and `mapControllerCompleter.complete(controller)` above should happen
    // in `mapRendered`.
    // https://github.com/flutter/flutter/issues/54758
    await Future<void>.delayed(const Duration(seconds: 1));

    final ScreenCoordinate coordinate =
        await mapController.getScreenCoordinate(_kInitialCameraPosition.target);
    final Rect rect = tester.getRect(find.byKey(key));
    expect(coordinate.x, (rect.center.dx - rect.topLeft.dx).round());
    expect(coordinate.y, (rect.center.dy - rect.topLeft.dy).round());

    await tester.binding.setSurfaceSize(null);
  },
      // TODO(stuartmorgan): Re-enable; see https://github.com/flutter/flutter/issues/139825
      skip: true);

  testWidgets('testGetVisibleRegion', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final LatLngBounds zeroLatLngBounds = LatLngBounds(
        southwest: const LatLng(0, 0), northeast: const LatLng(0, 0));

    final Completer<ExampleGoogleMapController> mapControllerCompleter =
        Completer<ExampleGoogleMapController>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (ExampleGoogleMapController controller) {
          mapControllerCompleter.complete(controller);
        },
      ),
    ));
    await tester.pumpAndSettle();

    final ExampleGoogleMapController mapController =
        await mapControllerCompleter.future;

    final LatLngBounds firstVisibleRegion =
        await mapController.getVisibleRegion();

    expect(firstVisibleRegion, isNotNull);
    expect(firstVisibleRegion.southwest, isNotNull);
    expect(firstVisibleRegion.northeast, isNotNull);
    expect(firstVisibleRegion, isNot(zeroLatLngBounds));
    expect(firstVisibleRegion.contains(_kInitialMapCenter), isTrue);

    // Making a new `LatLngBounds` about (10, 10) distance south west to the `firstVisibleRegion`.
    // The size of the `LatLngBounds` is 10 by 10.
    final LatLng southWest = LatLng(firstVisibleRegion.southwest.latitude - 20,
        firstVisibleRegion.southwest.longitude - 20);
    final LatLng northEast = LatLng(firstVisibleRegion.southwest.latitude - 10,
        firstVisibleRegion.southwest.longitude - 10);
    final LatLng newCenter = LatLng(
      (northEast.latitude + southWest.latitude) / 2,
      (northEast.longitude + southWest.longitude) / 2,
    );

    expect(firstVisibleRegion.contains(northEast), isFalse);
    expect(firstVisibleRegion.contains(southWest), isFalse);

    final LatLngBounds latLngBounds =
        LatLngBounds(southwest: southWest, northeast: northEast);

    // TODO(iskakaushik): non-zero padding is needed for some device configurations
    // https://github.com/flutter/flutter/issues/30575
    const double padding = 0;
    await mapController
        .moveCamera(CameraUpdate.newLatLngBounds(latLngBounds, padding));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final LatLngBounds secondVisibleRegion =
        await mapController.getVisibleRegion();

    expect(secondVisibleRegion, isNotNull);
    expect(secondVisibleRegion.southwest, isNotNull);
    expect(secondVisibleRegion.northeast, isNotNull);
    expect(secondVisibleRegion, isNot(zeroLatLngBounds));

    expect(firstVisibleRegion, isNot(secondVisibleRegion));
    expect(secondVisibleRegion.contains(newCenter), isTrue);
  },
      // TODO(stuartmorgan): Re-enable; see https://github.com/flutter/flutter/issues/139825
      skip: true);

  testWidgets('testTraffic', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        trafficEnabled: true,
        onMapCreated: (ExampleGoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    ));

    final int mapId = await mapIdCompleter.future;
    final GoogleMapsInspectorPlatform inspector =
        GoogleMapsInspectorPlatform.instance!;
    bool isTrafficEnabled = await inspector.isTrafficEnabled(mapId: mapId);
    expect(isTrafficEnabled, true);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (ExampleGoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
        },
      ),
    ));

    isTrafficEnabled = await inspector.isTrafficEnabled(mapId: mapId);
    expect(isTrafficEnabled, false);
  });

  testWidgets('testBuildings', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (ExampleGoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    ));

    final int mapId = await mapIdCompleter.future;
    final GoogleMapsInspectorPlatform inspector =
        GoogleMapsInspectorPlatform.instance!;
    final bool isBuildingsEnabled =
        await inspector.areBuildingsEnabled(mapId: mapId);
    expect(isBuildingsEnabled, true);
  });

  testWidgets('testMyLocationButtonToggle', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (ExampleGoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    ));

    final int mapId = await mapIdCompleter.future;
    final GoogleMapsInspectorPlatform inspector =
        GoogleMapsInspectorPlatform.instance!;
    bool myLocationButtonEnabled =
        await inspector.isMyLocationButtonEnabled(mapId: mapId);
    expect(myLocationButtonEnabled, true);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        myLocationButtonEnabled: false,
        onMapCreated: (ExampleGoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
        },
      ),
    ));

    myLocationButtonEnabled =
        await inspector.isMyLocationButtonEnabled(mapId: mapId);
    expect(myLocationButtonEnabled, false);
  });

  testWidgets('testMyLocationButton initial value false',
      (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        myLocationButtonEnabled: false,
        onMapCreated: (ExampleGoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    ));

    final int mapId = await mapIdCompleter.future;
    final GoogleMapsInspectorPlatform inspector =
        GoogleMapsInspectorPlatform.instance!;
    final bool myLocationButtonEnabled =
        await inspector.isMyLocationButtonEnabled(mapId: mapId);
    expect(myLocationButtonEnabled, false);
  });

  testWidgets('testMyLocationButton initial value true',
      (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<int> mapIdCompleter = Completer<int>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (ExampleGoogleMapController controller) {
          mapIdCompleter.complete(controller.mapId);
        },
      ),
    ));

    final int mapId = await mapIdCompleter.future;
    final GoogleMapsInspectorPlatform inspector =
        GoogleMapsInspectorPlatform.instance!;
    final bool myLocationButtonEnabled =
        await inspector.isMyLocationButtonEnabled(mapId: mapId);
    expect(myLocationButtonEnabled, true);
  });

  testWidgets('testSetMapStyle valid Json String', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<ExampleGoogleMapController> controllerCompleter =
        Completer<ExampleGoogleMapController>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (ExampleGoogleMapController controller) {
          controllerCompleter.complete(controller);
        },
      ),
    ));

    final ExampleGoogleMapController controller =
        await controllerCompleter.future;
    const String mapStyle =
        '[{"elementType":"geometry","stylers":[{"color":"#242f3e"}]}]';
    await GoogleMapsFlutterPlatform.instance
        .setMapStyle(mapStyle, mapId: controller.mapId);
  });

  testWidgets('testSetMapStyle invalid Json String',
      (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<ExampleGoogleMapController> controllerCompleter =
        Completer<ExampleGoogleMapController>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (ExampleGoogleMapController controller) {
          controllerCompleter.complete(controller);
        },
      ),
    ));

    final ExampleGoogleMapController controller =
        await controllerCompleter.future;

    try {
      await GoogleMapsFlutterPlatform.instance
          .setMapStyle('invalid_value', mapId: controller.mapId);
      fail('expected MapStyleException');
    } on MapStyleException catch (e) {
      expect(e.cause, isNotNull);
      expect(await controller.getStyleError(), isNotNull);
    }
  });

  testWidgets('testSetMapStyle null string', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<ExampleGoogleMapController> controllerCompleter =
        Completer<ExampleGoogleMapController>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (ExampleGoogleMapController controller) {
          controllerCompleter.complete(controller);
        },
      ),
    ));

    final ExampleGoogleMapController controller =
        await controllerCompleter.future;
    await GoogleMapsFlutterPlatform.instance
        .setMapStyle(null, mapId: controller.mapId);
  });

  testWidgets('testGetLatLng', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<ExampleGoogleMapController> controllerCompleter =
        Completer<ExampleGoogleMapController>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (ExampleGoogleMapController controller) {
          controllerCompleter.complete(controller);
        },
      ),
    ));

    final ExampleGoogleMapController controller =
        await controllerCompleter.future;

    await tester.pumpAndSettle();
    // TODO(cyanglaz): Remove this after we added `mapRendered` callback, and `mapControllerCompleter.complete(controller)` above should happen
    // in `mapRendered`.
    // https://github.com/flutter/flutter/issues/54758
    await Future<void>.delayed(const Duration(seconds: 1));

    final LatLngBounds visibleRegion = await controller.getVisibleRegion();
    final LatLng topLeft =
        await controller.getLatLng(const ScreenCoordinate(x: 0, y: 0));
    final LatLng northWest = LatLng(
      visibleRegion.northeast.latitude,
      visibleRegion.southwest.longitude,
    );

    expect(topLeft, northWest);
  });

  testWidgets('testGetZoomLevel', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<ExampleGoogleMapController> controllerCompleter =
        Completer<ExampleGoogleMapController>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (ExampleGoogleMapController controller) {
          controllerCompleter.complete(controller);
        },
      ),
    ));

    final ExampleGoogleMapController controller =
        await controllerCompleter.future;

    await tester.pumpAndSettle();
    // TODO(cyanglaz): Remove this after we added `mapRendered` callback, and `mapControllerCompleter.complete(controller)` above should happen
    // in `mapRendered`.
    // https://github.com/flutter/flutter/issues/54758
    await Future<void>.delayed(const Duration(seconds: 1));

    double zoom = await controller.getZoomLevel();
    expect(zoom, _kInitialZoomLevel);

    await controller.moveCamera(CameraUpdate.zoomTo(7));
    await tester.pumpAndSettle();
    zoom = await controller.getZoomLevel();
    expect(zoom, equals(7));
  },
      // TODO(stuartmorgan): Re-enable; see https://github.com/flutter/flutter/issues/139825
      skip: true);

  testWidgets('testScreenCoordinate', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<ExampleGoogleMapController> controllerCompleter =
        Completer<ExampleGoogleMapController>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (ExampleGoogleMapController controller) {
          controllerCompleter.complete(controller);
        },
      ),
    ));
    final ExampleGoogleMapController controller =
        await controllerCompleter.future;

    await tester.pumpAndSettle();
    // TODO(cyanglaz): Remove this after we added `mapRendered` callback, and `mapControllerCompleter.complete(controller)` above should happen
    // in `mapRendered`.
    // https://github.com/flutter/flutter/issues/54758
    await Future<void>.delayed(const Duration(seconds: 1));

    final LatLngBounds visibleRegion = await controller.getVisibleRegion();
    final LatLng northWest = LatLng(
      visibleRegion.northeast.latitude,
      visibleRegion.southwest.longitude,
    );
    final ScreenCoordinate topLeft =
        await controller.getScreenCoordinate(northWest);
    expect(topLeft, const ScreenCoordinate(x: 0, y: 0));
  },
      // TODO(stuartmorgan): Re-enable; see https://github.com/flutter/flutter/issues/139825
      skip: true);

  testWidgets('testResizeWidget', (WidgetTester tester) async {
    final Completer<ExampleGoogleMapController> controllerCompleter =
        Completer<ExampleGoogleMapController>();
    final ExampleGoogleMap map = ExampleGoogleMap(
      initialCameraPosition: _kInitialCameraPosition,
      onMapCreated: (ExampleGoogleMapController controller) async {
        controllerCompleter.complete(controller);
      },
    );
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: MaterialApp(
            home: Scaffold(
                body: SizedBox(height: 100, width: 100, child: map)))));
    final ExampleGoogleMapController controller =
        await controllerCompleter.future;

    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: MaterialApp(
            home: Scaffold(
                body: SizedBox(height: 400, width: 400, child: map)))));

    await tester.pumpAndSettle();
    // TODO(cyanglaz): Remove this after we added `mapRendered` callback, and `mapControllerCompleter.complete(controller)` above should happen
    // in `mapRendered`.
    // https://github.com/flutter/flutter/issues/54758
    await Future<void>.delayed(const Duration(seconds: 1));

    // Simple call to make sure that the app hasn't crashed.
    final LatLngBounds bounds1 = await controller.getVisibleRegion();
    final LatLngBounds bounds2 = await controller.getVisibleRegion();
    expect(bounds1, bounds2);
  });

  testWidgets('testToggleInfoWindow', (WidgetTester tester) async {
    const Marker marker = Marker(
        markerId: MarkerId('marker'),
        infoWindow: InfoWindow(title: 'InfoWindow'));
    final Set<Marker> markers = <Marker>{marker};

    final Completer<ExampleGoogleMapController> controllerCompleter =
        Completer<ExampleGoogleMapController>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
        markers: markers,
        onMapCreated: (ExampleGoogleMapController googleMapController) {
          controllerCompleter.complete(googleMapController);
        },
      ),
    ));

    final ExampleGoogleMapController controller =
        await controllerCompleter.future;

    bool iwVisibleStatus =
        await controller.isMarkerInfoWindowShown(marker.markerId);
    expect(iwVisibleStatus, false);

    await controller.showMarkerInfoWindow(marker.markerId);
    iwVisibleStatus = await controller.isMarkerInfoWindowShown(marker.markerId);
    expect(iwVisibleStatus, true);

    await controller.hideMarkerInfoWindow(marker.markerId);
    iwVisibleStatus = await controller.isMarkerInfoWindowShown(marker.markerId);
    expect(iwVisibleStatus, false);
  });

  testWidgets('testTakeSnapshot', (WidgetTester tester) async {
    final Completer<ExampleGoogleMapController> controllerCompleter =
        Completer<ExampleGoogleMapController>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ExampleGoogleMap(
          initialCameraPosition: _kInitialCameraPosition,
          onMapCreated: (ExampleGoogleMapController controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 3));

    final ExampleGoogleMapController controller =
        await controllerCompleter.future;
    final Uint8List? bytes = await controller.takeSnapshot();
    expect(bytes?.isNotEmpty, true);
  },
      // TODO(stuartmorgan): Re-enable; see https://github.com/flutter/flutter/issues/139825
      skip: true);

  testWidgets(
    'set tileOverlay correctly',
    (WidgetTester tester) async {
      final Completer<int> mapIdCompleter = Completer<int>();
      final TileOverlay tileOverlay1 = TileOverlay(
        tileOverlayId: const TileOverlayId('tile_overlay_1'),
        tileProvider: _DebugTileProvider(),
        zIndex: 2,
        transparency: 0.2,
      );

      final TileOverlay tileOverlay2 = TileOverlay(
        tileOverlayId: const TileOverlayId('tile_overlay_2'),
        tileProvider: _DebugTileProvider(),
        zIndex: 1,
        visible: false,
        transparency: 0.3,
        fadeIn: false,
      );
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ExampleGoogleMap(
            initialCameraPosition: _kInitialCameraPosition,
            tileOverlays: <TileOverlay>{tileOverlay1, tileOverlay2},
            onMapCreated: (ExampleGoogleMapController controller) {
              mapIdCompleter.complete(controller.mapId);
            },
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final int mapId = await mapIdCompleter.future;
      final GoogleMapsInspectorPlatform inspector =
          GoogleMapsInspectorPlatform.instance!;

      final TileOverlay tileOverlayInfo1 = (await inspector
          .getTileOverlayInfo(tileOverlay1.mapsId, mapId: mapId))!;
      final TileOverlay tileOverlayInfo2 = (await inspector
          .getTileOverlayInfo(tileOverlay2.mapsId, mapId: mapId))!;

      expect(tileOverlayInfo1.visible, isTrue);
      expect(tileOverlayInfo1.fadeIn, isTrue);
      expect(
          tileOverlayInfo1.transparency, moreOrLessEquals(0.2, epsilon: 0.001));
      expect(tileOverlayInfo1.zIndex, 2);

      expect(tileOverlayInfo2.visible, isFalse);
      expect(tileOverlayInfo2.fadeIn, isFalse);
      expect(
          tileOverlayInfo2.transparency, moreOrLessEquals(0.3, epsilon: 0.001));
      expect(tileOverlayInfo2.zIndex, 1);
    },
  );

  testWidgets(
    'update tileOverlays correctly',
    (WidgetTester tester) async {
      final Completer<int> mapIdCompleter = Completer<int>();
      final Key key = GlobalKey();
      final TileOverlay tileOverlay1 = TileOverlay(
        tileOverlayId: const TileOverlayId('tile_overlay_1'),
        tileProvider: _DebugTileProvider(),
        zIndex: 2,
        transparency: 0.2,
      );

      final TileOverlay tileOverlay2 = TileOverlay(
        tileOverlayId: const TileOverlayId('tile_overlay_2'),
        tileProvider: _DebugTileProvider(),
        zIndex: 3,
        transparency: 0.5,
      );
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ExampleGoogleMap(
            key: key,
            initialCameraPosition: _kInitialCameraPosition,
            tileOverlays: <TileOverlay>{tileOverlay1, tileOverlay2},
            onMapCreated: (ExampleGoogleMapController controller) {
              mapIdCompleter.complete(controller.mapId);
            },
          ),
        ),
      );

      final int mapId = await mapIdCompleter.future;
      final GoogleMapsInspectorPlatform inspector =
          GoogleMapsInspectorPlatform.instance!;

      final TileOverlay tileOverlay1New = TileOverlay(
        tileOverlayId: const TileOverlayId('tile_overlay_1'),
        tileProvider: _DebugTileProvider(),
        zIndex: 1,
        visible: false,
        transparency: 0.3,
        fadeIn: false,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ExampleGoogleMap(
            key: key,
            initialCameraPosition: _kInitialCameraPosition,
            tileOverlays: <TileOverlay>{tileOverlay1New},
            onMapCreated: (ExampleGoogleMapController controller) {
              fail('update: OnMapCreated should get called only once.');
            },
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      final TileOverlay tileOverlayInfo1 = (await inspector
          .getTileOverlayInfo(tileOverlay1.mapsId, mapId: mapId))!;
      final TileOverlay? tileOverlayInfo2 =
          await inspector.getTileOverlayInfo(tileOverlay2.mapsId, mapId: mapId);

      expect(tileOverlayInfo1.visible, isFalse);
      expect(tileOverlayInfo1.fadeIn, isFalse);
      expect(
          tileOverlayInfo1.transparency, moreOrLessEquals(0.3, epsilon: 0.001));
      expect(tileOverlayInfo1.zIndex, 1);

      expect(tileOverlayInfo2, isNull);
    },
  );

  testWidgets(
    'remove tileOverlays correctly',
    (WidgetTester tester) async {
      final Completer<int> mapIdCompleter = Completer<int>();
      final Key key = GlobalKey();
      final TileOverlay tileOverlay1 = TileOverlay(
        tileOverlayId: const TileOverlayId('tile_overlay_1'),
        tileProvider: _DebugTileProvider(),
        zIndex: 2,
        transparency: 0.2,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ExampleGoogleMap(
            key: key,
            initialCameraPosition: _kInitialCameraPosition,
            tileOverlays: <TileOverlay>{tileOverlay1},
            onMapCreated: (ExampleGoogleMapController controller) {
              mapIdCompleter.complete(controller.mapId);
            },
          ),
        ),
      );

      final int mapId = await mapIdCompleter.future;
      final GoogleMapsInspectorPlatform inspector =
          GoogleMapsInspectorPlatform.instance!;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ExampleGoogleMap(
            key: key,
            initialCameraPosition: _kInitialCameraPosition,
            onMapCreated: (ExampleGoogleMapController controller) {
              fail('OnMapCreated should get called only once.');
            },
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));
      final TileOverlay? tileOverlayInfo1 =
          await inspector.getTileOverlayInfo(tileOverlay1.mapsId, mapId: mapId);

      expect(tileOverlayInfo1, isNull);
    },
  );

  testWidgets('marker clustering', (WidgetTester tester) async {
    final Key key = GlobalKey();
    const int clusterManagersAmount = 2;
    const int markersPerClusterManager = 5;
    final Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
    final Set<ClusterManager> clusterManagers = <ClusterManager>{};

    for (int i = 0; i < clusterManagersAmount; i++) {
      final ClusterManagerId clusterManagerId =
          ClusterManagerId('cluster_manager_$i');
      final ClusterManager clusterManager =
          ClusterManager(clusterManagerId: clusterManagerId);
      clusterManagers.add(clusterManager);
    }

    for (final ClusterManager cm in clusterManagers) {
      for (int i = 0; i < markersPerClusterManager; i++) {
        final MarkerId markerId =
            MarkerId('${cm.clusterManagerId.value}_marker_$i');
        final Marker marker = Marker(
            markerId: markerId,
            clusterManagerId: cm.clusterManagerId,
            position: LatLng(
                _kInitialMapCenter.latitude + i, _kInitialMapCenter.longitude));
        markers[markerId] = marker;
      }
    }

    final Completer<ExampleGoogleMapController> controllerCompleter =
        Completer<ExampleGoogleMapController>();

    final GoogleMapsInspectorPlatform inspector =
        GoogleMapsInspectorPlatform.instance!;

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        clusterManagers: clusterManagers,
        markers: Set<Marker>.of(markers.values),
        onMapCreated: (ExampleGoogleMapController googleMapController) {
          controllerCompleter.complete(googleMapController);
        },
      ),
    ));

    final ExampleGoogleMapController controller =
        await controllerCompleter.future;

    for (final ClusterManager cm in clusterManagers) {
      final List<Cluster> clusters = await inspector.getClusters(
          mapId: controller.mapId, clusterManagerId: cm.clusterManagerId);
      final int markersAmountForClusterManager = clusters
          .map<int>((Cluster cluster) => cluster.count)
          .reduce((int value, int element) => value + element);
      expect(markersAmountForClusterManager, markersPerClusterManager);
    }

    // Remove markers from clusterManagers and test that clusterManagers are empty.
    for (final MapEntry<MarkerId, Marker> entry in markers.entries) {
      markers[entry.key] = _copyMarkerWithClusterManagerId(entry.value, null);
    }
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          clusterManagers: clusterManagers,
          markers: Set<Marker>.of(markers.values)),
    ));

    for (final ClusterManager cm in clusterManagers) {
      final List<Cluster> clusters = await inspector.getClusters(
          mapId: controller.mapId, clusterManagerId: cm.clusterManagerId);
      expect(clusters.length, 0);
    }
  });

  testWidgets('testSetStyleMapId', (WidgetTester tester) async {
    final Key key = GlobalKey();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        cloudMapId: _kCloudMapId,
      ),
    ));
  });

  testWidgets('getStyleError reports last error', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<ExampleGoogleMapController> controllerCompleter =
        Completer<ExampleGoogleMapController>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        style: '[[[this is an invalid style',
        onMapCreated: (ExampleGoogleMapController controller) {
          controllerCompleter.complete(controller);
        },
      ),
    ));

    final ExampleGoogleMapController controller =
        await controllerCompleter.future;
    final String? error = await controller.getStyleError();
    expect(error, isNotNull);
  });

  testWidgets('getStyleError returns null for a valid style',
      (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<ExampleGoogleMapController> controllerCompleter =
        Completer<ExampleGoogleMapController>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        // An empty array is the simplest valid style.
        style: '[]',
        onMapCreated: (ExampleGoogleMapController controller) {
          controllerCompleter.complete(controller);
        },
      ),
    ));

    final ExampleGoogleMapController controller =
        await controllerCompleter.future;
    final String? error = await controller.getStyleError();
    expect(error, isNull);
  });

  testWidgets('markerWithAssetMapBitmap', (WidgetTester tester) async {
    final Set<Marker> markers = <Marker>{
      Marker(
          markerId: const MarkerId('1'),
          icon: AssetMapBitmap(
            'assets/red_square.png',
            imagePixelRatio: 1.0,
          )),
    };
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
        markers: markers,
      ),
    ));

    await tester.pumpAndSettle();
  });

  testWidgets('markerWithAssetMapBitmapCreate', (WidgetTester tester) async {
    final ImageConfiguration imageConfiguration = ImageConfiguration(
      devicePixelRatio: tester.view.devicePixelRatio,
    );
    final Set<Marker> markers = <Marker>{
      Marker(
          markerId: const MarkerId('1'),
          icon: await AssetMapBitmap.create(
            imageConfiguration,
            'assets/red_square.png',
          )),
    };
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
        markers: markers,
      ),
    ));

    await tester.pumpAndSettle();
  });

  testWidgets('markerWithBytesMapBitmap', (WidgetTester tester) async {
    final Uint8List bytes = const Base64Decoder().convert(iconImageBase64);
    final Set<Marker> markers = <Marker>{
      Marker(
        markerId: const MarkerId('1'),
        icon: BytesMapBitmap(
          bytes,
          imagePixelRatio: tester.view.devicePixelRatio,
        ),
      ),
    };

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
        markers: markers,
      ),
    ));

    await tester.pumpAndSettle();
  });

  testWidgets('markerWithLegacyAsset', (WidgetTester tester) async {
    //tester.view.devicePixelRatio = 2.0;
    const ImageConfiguration imageConfiguration = ImageConfiguration(
      devicePixelRatio: 2.0,
      size: Size(100, 100),
    );
    final Set<Marker> markers = <Marker>{
      Marker(
          markerId: const MarkerId('1'),
          // Intentionally testing the deprecated code path.
          // ignore: deprecated_member_use
          icon: await BitmapDescriptor.fromAssetImage(
            imageConfiguration,
            'assets/red_square.png',
          )),
    };
    final Completer<ExampleGoogleMapController> controllerCompleter =
        Completer<ExampleGoogleMapController>();
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
        markers: markers,
        onMapCreated: (ExampleGoogleMapController controller) =>
            controllerCompleter.complete(controller),
      ),
    ));

    await controllerCompleter.future;
  });

  testWidgets('markerWithLegacyBytes', (WidgetTester tester) async {
    tester.view.devicePixelRatio = 2.0;
    final Uint8List bytes = const Base64Decoder().convert(iconImageBase64);
    // Intentionally testing the deprecated code path.
    // ignore: deprecated_member_use
    final BitmapDescriptor icon = BitmapDescriptor.fromBytes(
      bytes,
    );

    final Set<Marker> markers = <Marker>{
      Marker(markerId: const MarkerId('1'), icon: icon),
    };
    final Completer<ExampleGoogleMapController> controllerCompleter =
        Completer<ExampleGoogleMapController>();
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ExampleGoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
        markers: markers,
        onMapCreated: (ExampleGoogleMapController controller) =>
            controllerCompleter.complete(controller),
      ),
    ));
    await controllerCompleter.future;
  });

  group('GroundOverlay', () {
    final LatLngBounds kGroundOverlayBounds = LatLngBounds(
      southwest: const LatLng(37.77483, -122.41942),
      northeast: const LatLng(37.78183, -122.39105),
    );

    final GroundOverlay groundOverlayBounds1 = GroundOverlay.fromBounds(
      groundOverlayId: const GroundOverlayId('bounds_1'),
      bounds: kGroundOverlayBounds,
      image: AssetMapBitmap(
        'assets/red_square.png',
        imagePixelRatio: 1.0,
        bitmapScaling: MapBitmapScaling.none,
      ),
    );

    final GroundOverlay groundOverlayPosition1 = GroundOverlay.fromPosition(
        groundOverlayId: const GroundOverlayId('position_1'),
        position: kGroundOverlayBounds.northeast,
        width: 100,
        height: 100,
        anchor: const Offset(0.1, 0.2),
        zoomLevel: 14.0,
        image: AssetMapBitmap(
          'assets/red_square.png',
          imagePixelRatio: 1.0,
          bitmapScaling: MapBitmapScaling.none,
        ));

    void expectGroundOverlayEquals(
        GroundOverlay source, GroundOverlay response) {
      expect(response.groundOverlayId, source.groundOverlayId);
      expect(
        response.transparency,
        moreOrLessEquals(source.transparency, epsilon: _floatTolerance),
      );
      expect(
        response.bearing,
        moreOrLessEquals(source.bearing, epsilon: _floatTolerance),
      );

      // Only test bounds if it was given in the original object
      if (source.bounds != null) {
        expect(response.bounds, source.bounds);
      }

      // Only test position if it was given in the original object
      if (source.position != null) {
        expect(response.position, source.position);
      }

      expect(response.clickable, source.clickable);
      expect(response.zIndex, source.zIndex);
      expect(response.zoomLevel, source.zoomLevel);
      expect(
        response.anchor?.dx,
        moreOrLessEquals(source.anchor!.dx, epsilon: _floatTolerance),
      );
      expect(
        response.anchor?.dy,
        moreOrLessEquals(source.anchor!.dy, epsilon: _floatTolerance),
      );
    }

    testWidgets('set ground overlays correctly', (WidgetTester tester) async {
      final Completer<int> mapIdCompleter = Completer<int>();
      final GroundOverlay groundOverlayBounds2 = GroundOverlay.fromBounds(
        groundOverlayId: const GroundOverlayId('bounds_2'),
        bounds: groundOverlayBounds1.bounds!,
        image: groundOverlayBounds1.image,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ExampleGoogleMap(
            initialCameraPosition: _kInitialCameraPosition,
            groundOverlays: <GroundOverlay>{
              groundOverlayBounds1,
              groundOverlayBounds2,
              groundOverlayPosition1,
            },
            onMapCreated: (ExampleGoogleMapController controller) {
              mapIdCompleter.complete(controller.mapId);
            },
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final int mapId = await mapIdCompleter.future;
      final GoogleMapsInspectorPlatform inspector =
          GoogleMapsInspectorPlatform.instance!;

      if (inspector.supportsGettingGroundOverlayInfo()) {
        final GroundOverlay groundOverlayBoundsInfo1 = (await inspector
            .getGroundOverlayInfo(groundOverlayBounds1.mapsId, mapId: mapId))!;
        final GroundOverlay groundOverlayBoundsInfo2 = (await inspector
            .getGroundOverlayInfo(groundOverlayBounds2.mapsId, mapId: mapId))!;
        final GroundOverlay groundOverlayPositionInfo1 =
            (await inspector.getGroundOverlayInfo(groundOverlayPosition1.mapsId,
                mapId: mapId))!;

        expectGroundOverlayEquals(
          groundOverlayBounds1,
          groundOverlayBoundsInfo1,
        );
        expectGroundOverlayEquals(
          groundOverlayBounds2,
          groundOverlayBoundsInfo2,
        );
        expectGroundOverlayEquals(
          groundOverlayPosition1,
          groundOverlayPositionInfo1,
        );
      }
    });

    testWidgets('update ground overlays correctly',
        (WidgetTester tester) async {
      final Completer<int> mapIdCompleter = Completer<int>();
      final Key key = GlobalKey();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ExampleGoogleMap(
            key: key,
            initialCameraPosition: _kInitialCameraPosition,
            groundOverlays: <GroundOverlay>{
              groundOverlayBounds1,
              groundOverlayPosition1
            },
            onMapCreated: (ExampleGoogleMapController controller) {
              mapIdCompleter.complete(controller.mapId);
            },
          ),
        ),
      );

      final int mapId = await mapIdCompleter.future;
      final GoogleMapsInspectorPlatform inspector =
          GoogleMapsInspectorPlatform.instance!;

      final GroundOverlay groundOverlayBounds1New =
          groundOverlayBounds1.copyWith(
        bearingParam: 10,
        clickableParam: false,
        transparencyParam: 0.5,
        visibleParam: false,
        zIndexParam: 10,
      );

      final GroundOverlay groundOverlayPosition1New =
          groundOverlayPosition1.copyWith(
        bearingParam: 10,
        clickableParam: false,
        transparencyParam: 0.5,
        visibleParam: false,
        zIndexParam: 10,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ExampleGoogleMap(
            key: key,
            initialCameraPosition: _kInitialCameraPosition,
            groundOverlays: <GroundOverlay>{
              groundOverlayBounds1New,
              groundOverlayPosition1New
            },
            onMapCreated: (ExampleGoogleMapController controller) {
              fail('update: OnMapCreated should get called only once.');
            },
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      if (inspector.supportsGettingGroundOverlayInfo()) {
        final GroundOverlay groundOverlayBounds1Info = (await inspector
            .getGroundOverlayInfo(groundOverlayBounds1.mapsId, mapId: mapId))!;
        final GroundOverlay groundOverlayPosition1Info =
            (await inspector.getGroundOverlayInfo(groundOverlayPosition1.mapsId,
                mapId: mapId))!;

        expectGroundOverlayEquals(
          groundOverlayBounds1New,
          groundOverlayBounds1Info,
        );
        expectGroundOverlayEquals(
          groundOverlayPosition1New,
          groundOverlayPosition1Info,
        );
      }
    });

    testWidgets('remove ground overlays correctly',
        (WidgetTester tester) async {
      final Completer<int> mapIdCompleter = Completer<int>();
      final Key key = GlobalKey();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ExampleGoogleMap(
            key: key,
            initialCameraPosition: _kInitialCameraPosition,
            groundOverlays: <GroundOverlay>{
              groundOverlayBounds1,
              groundOverlayPosition1
            },
            onMapCreated: (ExampleGoogleMapController controller) {
              mapIdCompleter.complete(controller.mapId);
            },
          ),
        ),
      );

      final int mapId = await mapIdCompleter.future;
      final GoogleMapsInspectorPlatform inspector =
          GoogleMapsInspectorPlatform.instance!;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ExampleGoogleMap(
            key: key,
            initialCameraPosition: _kInitialCameraPosition,
            onMapCreated: (ExampleGoogleMapController controller) {
              fail('OnMapCreated should get called only once.');
            },
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      if (inspector.supportsGettingGroundOverlayInfo()) {
        final GroundOverlay? groundOverlayBounds1Info = await inspector
            .getGroundOverlayInfo(groundOverlayBounds1.mapsId, mapId: mapId);
        final GroundOverlay? groundOverlayPositionInfo = await inspector
            .getGroundOverlayInfo(groundOverlayPosition1.mapsId, mapId: mapId);

        expect(groundOverlayBounds1Info, isNull);
        expect(groundOverlayPositionInfo, isNull);
      }
    });
  });

  testWidgets(
    'testAnimateCameraWithoutDuration',
    (WidgetTester tester) async {
      final Key key = GlobalKey();
      final Completer<ExampleGoogleMapController> controllerCompleter =
          Completer<ExampleGoogleMapController>();
      final GoogleMapsInspectorPlatform inspector =
          GoogleMapsInspectorPlatform.instance!;

      /// Completer to track when the camera has come to rest.
      Completer<void>? cameraIdleCompleter;

      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: ExampleGoogleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          onCameraIdle: () {
            if (cameraIdleCompleter != null &&
                !cameraIdleCompleter.isCompleted) {
              cameraIdleCompleter.complete();
            }
          },
          onMapCreated: (ExampleGoogleMapController controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ));

      final ExampleGoogleMapController controller =
          await controllerCompleter.future;

      await tester.pumpAndSettle();
      // TODO(cyanglaz): Remove this after we added `mapRendered` callback, and
      // `mapControllerCompleter.complete(controller)` above should happen in
      // `mapRendered`.
      // https://github.com/flutter/flutter/issues/54758
      await Future<void>.delayed(const Duration(seconds: 1));

      // Create completer for camera idle event.
      cameraIdleCompleter = Completer<void>();

      final CameraUpdate cameraUpdate =
          _getCameraUpdateForType(_cameraUpdateTypeVariants.currentValue!);
      await controller.animateCamera(cameraUpdate);

      // Immediately after calling animateCamera, check that the camera hasn't
      // reached its final position. This relies on the assumption that the
      // camera move is animated and won't complete instantly.
      final CameraPosition beforeFinishedPosition =
          await inspector.getCameraPosition(mapId: controller.mapId);

      await _checkCameraUpdateByType(
          _cameraUpdateTypeVariants.currentValue!,
          beforeFinishedPosition,
          null,
          controller,
          (Matcher matcher) => isNot(matcher));

      // Wait for the animation to complete (onCameraIdle).
      expect(cameraIdleCompleter.isCompleted, isFalse);
      await cameraIdleCompleter.future;

      // After onCameraIdle event, the camera should be at the final position.
      final CameraPosition afterFinishedPosition =
          await inspector.getCameraPosition(mapId: controller.mapId);
      await _checkCameraUpdateByType(
          _cameraUpdateTypeVariants.currentValue!,
          afterFinishedPosition,
          beforeFinishedPosition,
          controller,
          (Matcher matcher) => matcher);

      await tester.pumpAndSettle();
    },
    variant: _cameraUpdateTypeVariants,
    // Hanging in CI, https://github.com/flutter/flutter/issues/166139
    skip: true,
  );

  /// Tests animating the camera with specified durations to verify timing
  /// behavior.
  ///
  /// This test checks two scenarios: short and long animation durations.
  /// It uses a midpoint duration to ensure the short animation completes in
  /// less time and the long animation takes more time than that midpoint.
  /// This ensures that the animation duration is respected by the platform and
  /// that the default camera animation duration does not affect the test
  /// results.
  testWidgets(
    'testAnimateCameraWithDuration',
    (WidgetTester tester) async {
      final Key key = GlobalKey();
      final Completer<ExampleGoogleMapController> controllerCompleter =
          Completer<ExampleGoogleMapController>();
      final GoogleMapsInspectorPlatform inspector =
          GoogleMapsInspectorPlatform.instance!;

      /// Completer to track when the camera has come to rest.
      Completer<void>? cameraIdleCompleter;

      const int shortCameraAnimationDurationMS = 200;
      const int longCameraAnimationDurationMS = 1000;

      /// Calculate the midpoint duration of the animation test, which will
      /// serve as a reference to verify that animations complete more quickly
      /// with shorter durations and more slowly with longer durations.
      const int animationDurationMiddlePoint =
          (shortCameraAnimationDurationMS + longCameraAnimationDurationMS) ~/ 2;

      // Stopwatch to measure the time taken for the animation to complete.
      final Stopwatch stopwatch = Stopwatch();

      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: ExampleGoogleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          onCameraIdle: () {
            if (cameraIdleCompleter != null &&
                !cameraIdleCompleter.isCompleted) {
              stopwatch.stop();
              cameraIdleCompleter.complete();
            }
          },
          onMapCreated: (ExampleGoogleMapController controller) {
            controllerCompleter.complete(controller);
          },
        ),
      ));

      final ExampleGoogleMapController controller =
          await controllerCompleter.future;

      await tester.pumpAndSettle();
      // TODO(cyanglaz): Remove this after we added `mapRendered` callback, and
      // `mapControllerCompleter.complete(controller)` above should happen in
      // `mapRendered`.
      // https://github.com/flutter/flutter/issues/54758
      await Future<void>.delayed(const Duration(seconds: 1));

      // Create completer for camera idle event.
      cameraIdleCompleter = Completer<void>();

      // Start stopwatch to check the time taken for the animation to complete.
      // Stopwatch is stopped on camera idle callback.
      stopwatch.reset();
      stopwatch.start();

      // First phase with shorter animation duration.
      final CameraUpdate cameraUpdateShort =
          _getCameraUpdateForType(_cameraUpdateTypeVariants.currentValue!);
      await controller.animateCamera(
        cameraUpdateShort,
        duration: const Duration(milliseconds: shortCameraAnimationDurationMS),
      );

      // Wait for the animation to complete (onCameraIdle).
      expect(cameraIdleCompleter.isCompleted, isFalse);
      await cameraIdleCompleter.future;

      // For short animation duration, check that the animation is completed
      // faster than the midpoint benchmark.
      expect(stopwatch.elapsedMilliseconds,
          lessThan(animationDurationMiddlePoint));

      // Reset camera to initial position before testing long duration.
      await controller
          .moveCamera(CameraUpdate.newCameraPosition(_kInitialCameraPosition));
      await tester.pumpAndSettle();

      // Create completer for camera idle event.
      cameraIdleCompleter = Completer<void>();

      // Start stopwatch to check the time taken for the animation to complete.
      // Stopwatch is stopped on camera idle callback.
      stopwatch.reset();
      stopwatch.start();

      // Second phase with longer animation duration.
      final CameraUpdate cameraUpdateLong =
          _getCameraUpdateForType(_cameraUpdateTypeVariants.currentValue!);
      await controller.animateCamera(
        cameraUpdateLong,
        duration: const Duration(milliseconds: longCameraAnimationDurationMS),
      );

      // Immediately after calling animateCamera, check that the camera hasn't
      // reached its final position. This relies on the assumption that the
      // camera move is animated and won't complete instantly.
      final CameraPosition beforeFinishedPosition =
          await inspector.getCameraPosition(mapId: controller.mapId);

      await _checkCameraUpdateByType(
          _cameraUpdateTypeVariants.currentValue!,
          beforeFinishedPosition,
          null,
          controller,
          (Matcher matcher) => isNot(matcher));

      // Wait for the animation to complete (onCameraIdle).
      expect(cameraIdleCompleter.isCompleted, isFalse);
      await cameraIdleCompleter.future;

      // For longer animation duration, check that the animation is completed
      // slower than the midpoint benchmark.
      expect(stopwatch.elapsedMilliseconds,
          greaterThan(animationDurationMiddlePoint));

      // Camera should be at the final position.
      final CameraPosition afterFinishedPosition =
          await inspector.getCameraPosition(mapId: controller.mapId);
      await _checkCameraUpdateByType(
          _cameraUpdateTypeVariants.currentValue!,
          afterFinishedPosition,
          beforeFinishedPosition,
          controller,
          (Matcher matcher) => matcher);

      await tester.pumpAndSettle();
    },
    variant: _cameraUpdateTypeVariants,
    // Hanging in CI, https://github.com/flutter/flutter/issues/166139
    skip: true,
  );
}

class _DebugTileProvider implements TileProvider {
  _DebugTileProvider() {
    boxPaint.isAntiAlias = true;
    boxPaint.color = Colors.blue;
    boxPaint.strokeWidth = 2.0;
    boxPaint.style = PaintingStyle.stroke;
  }

  static const int width = 100;
  static const int height = 100;
  static final Paint boxPaint = Paint();
  static const TextStyle textStyle = TextStyle(
    color: Colors.red,
    fontSize: 20,
  );

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final TextSpan textSpan = TextSpan(
      text: '$x,$y',
      style: textStyle,
    );
    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      maxWidth: width.toDouble(),
    );
    textPainter.paint(canvas, Offset.zero);
    canvas.drawRect(
        Rect.fromLTRB(0, 0, width.toDouble(), width.toDouble()), boxPaint);
    final ui.Picture picture = recorder.endRecording();
    final Uint8List byteData = await picture
        .toImage(width, height)
        .then((ui.Image image) =>
            image.toByteData(format: ui.ImageByteFormat.png))
        .then((ByteData? byteData) => byteData!.buffer.asUint8List());
    return Tile(width, height, byteData);
  }
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

CameraUpdate _getCameraUpdateForType(CameraUpdateType type) {
  return switch (type) {
    CameraUpdateType.newCameraPosition =>
      CameraUpdate.newCameraPosition(_kTestCameraPosition),
    CameraUpdateType.newLatLng => CameraUpdate.newLatLng(_kTestMapCenter),
    CameraUpdateType.newLatLngBounds =>
      CameraUpdate.newLatLngBounds(_testCameraBounds, 0),
    CameraUpdateType.newLatLngZoom =>
      CameraUpdate.newLatLngZoom(_kTestMapCenter, _kTestCameraZoomLevel),
    CameraUpdateType.scrollBy => CameraUpdate.scrollBy(10, 10),
    CameraUpdateType.zoomBy =>
      CameraUpdate.zoomBy(_kTestZoomByAmount, const Offset(1, 1)),
    CameraUpdateType.zoomTo => CameraUpdate.zoomTo(_kTestCameraZoomLevel),
    CameraUpdateType.zoomIn => CameraUpdate.zoomIn(),
    CameraUpdateType.zoomOut => CameraUpdate.zoomOut(),
  };
}

Future<void> _checkCameraUpdateByType(
  CameraUpdateType type,
  CameraPosition currentPosition,
  CameraPosition? oldPosition,
  ExampleGoogleMapController controller,
  Matcher Function(Matcher matcher) wrapMatcher,
) async {
  // As the target might differ a bit from the expected target, a threshold is
  // used.
  const double latLngThreshold = 0.05;

  switch (type) {
    case CameraUpdateType.newCameraPosition:
      expect(currentPosition.bearing,
          wrapMatcher(equals(_kTestCameraPosition.bearing)));
      expect(
          currentPosition.zoom, wrapMatcher(equals(_kTestCameraPosition.zoom)));
      expect(
          currentPosition.tilt, wrapMatcher(equals(_kTestCameraPosition.tilt)));
      expect(
          currentPosition.target.latitude,
          wrapMatcher(
              closeTo(_kTestCameraPosition.target.latitude, latLngThreshold)));
      expect(
          currentPosition.target.longitude,
          wrapMatcher(
              closeTo(_kTestCameraPosition.target.longitude, latLngThreshold)));
    case CameraUpdateType.newLatLng:
      expect(currentPosition.target.latitude,
          wrapMatcher(closeTo(_kTestMapCenter.latitude, latLngThreshold)));
      expect(currentPosition.target.longitude,
          wrapMatcher(closeTo(_kTestMapCenter.longitude, latLngThreshold)));
    case CameraUpdateType.newLatLngBounds:
      final LatLngBounds bounds = await controller.getVisibleRegion();
      expect(
          bounds.northeast.longitude,
          wrapMatcher(
              closeTo(_testCameraBounds.northeast.longitude, latLngThreshold)));
      expect(
          bounds.southwest.longitude,
          wrapMatcher(
              closeTo(_testCameraBounds.southwest.longitude, latLngThreshold)));
    case CameraUpdateType.newLatLngZoom:
      expect(currentPosition.target.latitude,
          wrapMatcher(closeTo(_kTestMapCenter.latitude, latLngThreshold)));
      expect(currentPosition.target.longitude,
          wrapMatcher(closeTo(_kTestMapCenter.longitude, latLngThreshold)));
      expect(currentPosition.zoom, wrapMatcher(equals(_kTestCameraZoomLevel)));
    case CameraUpdateType.scrollBy:
      // For scrollBy, just check that the location has changed.
      if (oldPosition != null) {
        expect(currentPosition.target.latitude,
            isNot(equals(oldPosition.target.latitude)));
        expect(currentPosition.target.longitude,
            isNot(equals(oldPosition.target.longitude)));
      }
    case CameraUpdateType.zoomBy:
      expect(currentPosition.zoom,
          wrapMatcher(equals(_kInitialZoomLevel + _kTestZoomByAmount)));
    case CameraUpdateType.zoomTo:
      expect(currentPosition.zoom, wrapMatcher(equals(_kTestCameraZoomLevel)));
    case CameraUpdateType.zoomIn:
      expect(currentPosition.zoom, wrapMatcher(equals(_kInitialZoomLevel + 1)));
    case CameraUpdateType.zoomOut:
      expect(currentPosition.zoom, wrapMatcher(equals(_kInitialZoomLevel - 1)));
  }
}
