// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:integration_test/integration_test.dart';

import 'resources/icon_image_base64.dart';
import 'shared.dart';

/// Integration Tests that only need a standard [GoogleMapController].
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  runTests();
}

void runTests() {
  testWidgets('testInitialCenterLocationAtCenter', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));

    final Completer<GoogleMapController> mapControllerCompleter =
        Completer<GoogleMapController>();
    final Key key = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          key: key,
          initialCameraPosition: kInitialCameraPosition,
          onMapCreated: (GoogleMapController controller) {
            mapControllerCompleter.complete(controller);
          },
        ),
      ),
    );
    final GoogleMapController mapController =
        await mapControllerCompleter.future;

    await tester.pumpAndSettle();

    // TODO(cyanglaz): Remove this after we added `mapRendered` callback, and `mapControllerCompleter.complete(controller)` above should happen
    // in `mapRendered`.
    // https://github.com/flutter/flutter/issues/54758
    await Future<void>.delayed(const Duration(seconds: 1));

    final ScreenCoordinate coordinate =
        await mapController.getScreenCoordinate(kInitialCameraPosition.target);
    final Rect rect = tester.getRect(find.byKey(key));
    if (isIOS || isWeb) {
      // On iOS, the coordinate value from the GoogleMapSdk doesn't include the devicePixelRatio`.
      // So we don't need to do the conversion like we did below for other platforms.
      expect(coordinate.x, (rect.center.dx - rect.topLeft.dx).round());
      expect(coordinate.y, (rect.center.dy - rect.topLeft.dy).round());
    } else {
      expect(
          coordinate.x,
          ((rect.center.dx - rect.topLeft.dx) * tester.view.devicePixelRatio)
              .round());
      expect(
          coordinate.y,
          ((rect.center.dy - rect.topLeft.dy) * tester.view.devicePixelRatio)
              .round());
    }
    await tester.binding.setSurfaceSize(null);
  },
      // Android doesn't like the layout required for the web, so we skip web in this test.
      // The equivalent web test already exists here:
      // https://github.com/flutter/packages/blob/c43cc13498a1a1c4f3d1b8af2add9ce7c15bd6d0/packages/google_maps_flutter/google_maps_flutter_web/example/integration_test/projection_test.dart#L78
      skip: isWeb ||
          // TODO(stuartmorgan): Re-enable; see https://github.com/flutter/flutter/issues/139825
          isIOS);

  testWidgets('testGetVisibleRegion', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final LatLngBounds zeroLatLngBounds = LatLngBounds(
        southwest: const LatLng(0, 0), northeast: const LatLng(0, 0));

    final Completer<GoogleMapController> mapControllerCompleter =
        Completer<GoogleMapController>();

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          mapControllerCompleter.complete(controller);
        },
      ),
    );
    await tester.pumpAndSettle();
    final GoogleMapController mapController =
        await mapControllerCompleter.future;

    // Wait for the visible region to be non-zero.
    final LatLngBounds firstVisibleRegion =
        await waitForValueMatchingPredicate<LatLngBounds>(
                tester,
                () => mapController.getVisibleRegion(),
                (LatLngBounds bounds) => bounds != zeroLatLngBounds) ??
            zeroLatLngBounds;
    expect(firstVisibleRegion, isNot(zeroLatLngBounds));
    expect(firstVisibleRegion.contains(kInitialMapCenter), isTrue);

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

    expect(secondVisibleRegion, isNot(zeroLatLngBounds));

    expect(firstVisibleRegion, isNot(secondVisibleRegion));
    expect(secondVisibleRegion.contains(newCenter), isTrue);
  },
      // TODO(stuartmorgan): Re-enable; see https://github.com/flutter/flutter/issues/139825
      skip: isIOS);

  testWidgets('testSetMapStyle valid Json String', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          controllerCompleter.complete(controller);
        },
      ),
    );
    final GoogleMapController controller = await controllerCompleter.future;

    const String mapStyle =
        '[{"elementType":"geometry","stylers":[{"color":"#242f3e"}]}]';
    // Intentionally testing the deprecated code path.
    // ignore: deprecated_member_use
    await controller.setMapStyle(mapStyle);
  });

  testWidgets('testSetMapStyle invalid Json String',
      (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          controllerCompleter.complete(controller);
        },
      ),
    );
    final GoogleMapController controller = await controllerCompleter.future;

    try {
      // Intentionally testing the deprecated code path.
      // ignore: deprecated_member_use
      await controller.setMapStyle('invalid_value');
      fail('expected MapStyleException');
    } on MapStyleException catch (e) {
      expect(e.cause, isNotNull);
    }
  });

  testWidgets('testSetMapStyle null string', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          controllerCompleter.complete(controller);
        },
      ),
    );
    final GoogleMapController controller = await controllerCompleter.future;

    // Intentionally testing the deprecated code path.
    // ignore: deprecated_member_use
    await controller.setMapStyle(null);
  });

  testWidgets('testGetLatLng', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          controllerCompleter.complete(controller);
        },
      ),
    );
    final GoogleMapController controller = await controllerCompleter.future;

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
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          controllerCompleter.complete(controller);
        },
      ),
    );
    final GoogleMapController controller = await controllerCompleter.future;

    await tester.pumpAndSettle();
    // TODO(cyanglaz): Remove this after we added `mapRendered` callback, and `mapControllerCompleter.complete(controller)` above should happen
    // in `mapRendered`.
    // https://github.com/flutter/flutter/issues/54758
    await Future<void>.delayed(const Duration(seconds: 1));

    double zoom = await controller.getZoomLevel();
    expect(zoom, kInitialZoomLevel);

    await controller.moveCamera(CameraUpdate.zoomTo(7));
    await tester.pumpAndSettle();
    zoom = await controller.getZoomLevel();
    expect(zoom, equals(7));
  },
      // TODO(stuartmorgan): Re-enable; see https://github.com/flutter/flutter/issues/139825
      skip: isIOS);

  testWidgets('testScreenCoordinate', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          controllerCompleter.complete(controller);
        },
      ),
    );
    final GoogleMapController controller = await controllerCompleter.future;

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
      skip: isIOS);

  testWidgets('testResizeWidget', (WidgetTester tester) async {
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await pumpMap(
      tester,
      GoogleMap(
        initialCameraPosition: kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) async {
          controllerCompleter.complete(controller);
        },
      ),
      const Size(100, 100),
    );
    final GoogleMapController controller = await controllerCompleter.future;

    await pumpMap(
      tester,
      GoogleMap(
        initialCameraPosition: kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) async {
          // fail!
          fail('The map should not get recreated!');
          // controllerCompleter.complete(controller);
        },
      ),
      const Size(400, 400),
    );

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

    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await pumpMap(
      tester,
      GoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
        markers: markers,
        onMapCreated: (GoogleMapController googleMapController) {
          controllerCompleter.complete(googleMapController);
        },
      ),
    );
    final GoogleMapController controller = await controllerCompleter.future;

    await tester.pumpAndSettle();

    // TODO(mossmana): Adding this delay addresses
    // https://github.com/flutter/flutter/issues/131783. It may be related
    // to https://github.com/flutter/flutter/issues/54758 and should be
    // re-evaluated when that issue is fixed.
    await Future<void>.delayed(const Duration(seconds: 1));

    bool iwVisibleStatus =
        await controller.isMarkerInfoWindowShown(marker.markerId);
    expect(iwVisibleStatus, false);

    await controller.showMarkerInfoWindow(marker.markerId);
    // The Maps SDK doesn't always return true for whether it is shown
    // immediately after showing it, so wait for it to report as shown.
    iwVisibleStatus = await waitForValueMatchingPredicate<bool>(
            tester,
            () => controller.isMarkerInfoWindowShown(marker.markerId),
            (bool visible) => visible) ??
        false;
    expect(iwVisibleStatus, true);

    await controller.hideMarkerInfoWindow(marker.markerId);
    iwVisibleStatus = await controller.isMarkerInfoWindowShown(marker.markerId);
    expect(iwVisibleStatus, false);
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
    await pumpMap(
      tester,
      GoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
        markers: markers,
      ),
    );
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
    await pumpMap(
      tester,
      GoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
        markers: markers,
      ),
    );
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
    await pumpMap(
      tester,
      GoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
        markers: markers,
      ),
    );
  });

  testWidgets('markerWithLegacyAsset', (WidgetTester tester) async {
    tester.view.devicePixelRatio = 2.0;
    final ImageConfiguration imageConfiguration = ImageConfiguration(
      devicePixelRatio: tester.view.devicePixelRatio,
      size: const Size(100, 100),
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
    await pumpMap(
      tester,
      GoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
        markers: markers,
      ),
    );

    await tester.pumpAndSettle();
  });

  testWidgets('markerWithLegacyBytes', (WidgetTester tester) async {
    tester.view.devicePixelRatio = 2.0;
    final Uint8List bytes = const Base64Decoder().convert(iconImageBase64);
    final Set<Marker> markers = <Marker>{
      Marker(
          markerId: const MarkerId('1'),
          // Intentionally testing the deprecated code path.
          // ignore: deprecated_member_use
          icon: BitmapDescriptor.fromBytes(
            bytes,
            size: const Size(100, 100),
          )),
    };
    await pumpMap(
      tester,
      GoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
        markers: markers,
      ),
    );

    await tester.pumpAndSettle();
  });

  testWidgets('testTakeSnapshot', (WidgetTester tester) async {
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await pumpMap(
      tester,
      GoogleMap(
        initialCameraPosition: kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          controllerCompleter.complete(controller);
        },
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 3));
    final GoogleMapController controller = await controllerCompleter.future;

    final Uint8List? bytes = await controller.takeSnapshot();
    expect(bytes?.isNotEmpty, true);
  },
      // TODO(cyanglaz): un-skip the test when we can test this on CI with API key enabled.
      // https://github.com/flutter/flutter/issues/57057
      // https://github.com/flutter/flutter/issues/139825
      skip: isAndroid || isWeb || isIOS);

  testWidgets(
    'testCloudMapId',
    (WidgetTester tester) async {
      final Completer<int> mapIdCompleter = Completer<int>();
      final Key key = GlobalKey();

      await pumpMap(
        tester,
        GoogleMap(
          key: key,
          initialCameraPosition: kInitialCameraPosition,
          onMapCreated: (GoogleMapController controller) {
            mapIdCompleter.complete(controller.mapId);
          },
          cloudMapId: kCloudMapId,
        ),
      );
      await tester.pumpAndSettle();

      // Await mapIdCompleter to finish to make sure map can be created with cloudMapId
      await mapIdCompleter.future;
    },
  );

  testWidgets('getStyleError reports last error', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await pumpMap(
      tester,
      GoogleMap(
        key: key,
        initialCameraPosition: kInitialCameraPosition,
        style: '[[[this is an invalid style',
        onMapCreated: (GoogleMapController controller) {
          controllerCompleter.complete(controller);
        },
      ),
    );

    final GoogleMapController controller = await controllerCompleter.future;
    final String? error = await controller.getStyleError();
    expect(error, isNotNull);
  });
}

/// Repeatedly checks an asynchronous value against a test condition.
///
/// This function waits one frame between each check, returning the value if it
/// passes the predicate before [maxTries] is reached.
///
/// Returns null if the predicate is never satisfied.
///
/// This is useful for cases where the Maps SDK has some internally
/// asynchronous operation that we don't have visibility into (e.g., native UI
/// animations).
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
