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
const CameraPosition _kInitialCameraPosition =
    CameraPosition(target: _kInitialMapCenter, zoom: _kInitialZoomLevel);
const String _kCloudMapId = '000000000000000'; // Dummy map ID.

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
