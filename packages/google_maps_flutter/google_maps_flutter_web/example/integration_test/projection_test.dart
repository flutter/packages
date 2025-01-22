// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// These tests render an app with a small map widget, and use its map controller
// to compute values of the default projection.

// (Tests methods that can't be mocked in `google_maps_controller_test.dart`)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    show GoogleMap, GoogleMapController;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:integration_test/integration_test.dart';

// This value is used when comparing long~num, like LatLng values.
const double _acceptableLatLngDelta = 0.0000000001;

// This value is used when comparing pixel measurements, mostly to gloss over
// browser rounding errors.
const int _acceptablePixelDelta = 1;

/// Test Google Map Controller
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Methods that require a proper Projection', () {
    const LatLng center = LatLng(43.3078, -5.6958);
    const Size size = Size(320, 240);
    const CameraPosition initialCamera = CameraPosition(
      target: center,
      zoom: 14,
    );

    late Completer<GoogleMapController> controllerCompleter;
    late void Function(GoogleMapController) onMapCreated;

    setUp(() {
      controllerCompleter = Completer<GoogleMapController>();
      onMapCreated = (GoogleMapController mapController) {
        controllerCompleter.complete(mapController);
      };
    });

    group('moveCamera', () {
      testWidgets('center can be moved with newLatLngZoom',
          (WidgetTester tester) async {
        await pumpCenteredMap(
          tester,
          initialCamera: initialCamera,
          size: size,
          onMapCreated: onMapCreated,
        );

        final GoogleMapController controller = await controllerCompleter.future;

        await controller.moveCamera(
          CameraUpdate.newLatLngZoom(
            const LatLng(19, 26),
            12,
          ),
        );

        final LatLng coords = await controller.getLatLng(
          ScreenCoordinate(x: size.width ~/ 2, y: size.height ~/ 2),
        );

        expect(await controller.getZoomLevel(), 12);
        expect(coords.latitude, closeTo(19, _acceptableLatLngDelta));
        expect(coords.longitude, closeTo(26, _acceptableLatLngDelta));
      },
          // TODO(bparrishMines): This is failing due to an error being thrown after
          // completion. See https://github.com/flutter/flutter/issues/145149
          skip: true);

      testWidgets('addPadding', (WidgetTester tester) async {
        const LatLng initialMapCenter = LatLng(0, 0);
        const double initialZoomLevel = 5;
        const CameraPosition initialCameraPosition =
            CameraPosition(target: initialMapCenter, zoom: initialZoomLevel);
        final LatLngBounds zeroLatLngBounds = LatLngBounds(
            southwest: const LatLng(0, 0), northeast: const LatLng(0, 0));
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: GoogleMap(
              initialCameraPosition: initialCameraPosition,
              onMapCreated: onMapCreated,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final GoogleMapController controller = await controllerCompleter.future;

        final LatLngBounds firstVisibleRegion =
            await controller.getVisibleRegion();

        expect(firstVisibleRegion, isNotNull);
        expect(firstVisibleRegion.southwest, isNotNull);
        expect(firstVisibleRegion.northeast, isNotNull);
        expect(firstVisibleRegion, isNot(zeroLatLngBounds));
        expect(firstVisibleRegion.contains(initialMapCenter), isTrue);

        const double padding = 0.1;
        await controller.moveCamera(
            CameraUpdate.newLatLngBounds(firstVisibleRegion, padding));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final LatLngBounds secondVisibleRegion =
            await controller.getVisibleRegion();

        expect(secondVisibleRegion, isNotNull);
        expect(secondVisibleRegion, isNot(zeroLatLngBounds));
        expect(
          secondVisibleRegion,
          isNot(firstVisibleRegion),
        );
        expect(secondVisibleRegion.contains(initialMapCenter), isTrue);
        expect(
          secondVisibleRegion.contains(firstVisibleRegion.northeast),
          isTrue,
        );
        expect(
          secondVisibleRegion.contains(firstVisibleRegion.southwest),
          isTrue,
        );
      });
    });

    group('getScreenCoordinate', () {
      testWidgets('target of map is in center of widget',
          (WidgetTester tester) async {
        await pumpCenteredMap(
          tester,
          initialCamera: initialCamera,
          size: size,
          onMapCreated: onMapCreated,
        );

        final GoogleMapController controller = await controllerCompleter.future;

        final ScreenCoordinate screenPosition =
            await controller.getScreenCoordinate(center);

        expect(
          screenPosition.x,
          closeTo(size.width / 2, _acceptablePixelDelta),
        );
        expect(
          screenPosition.y,
          closeTo(size.height / 2, _acceptablePixelDelta),
        );
      });

      testWidgets('NorthWest of visible region corresponds to x:0, y:0',
          (WidgetTester tester) async {
        await pumpCenteredMap(
          tester,
          initialCamera: initialCamera,
          size: size,
          onMapCreated: onMapCreated,
        );
        final GoogleMapController controller = await controllerCompleter.future;

        final LatLngBounds bounds = await controller.getVisibleRegion();
        final LatLng northWest = LatLng(
          bounds.northeast.latitude,
          bounds.southwest.longitude,
        );

        final ScreenCoordinate screenPosition =
            await controller.getScreenCoordinate(northWest);

        expect(screenPosition.x, closeTo(0, _acceptablePixelDelta));
        expect(screenPosition.y, closeTo(0, _acceptablePixelDelta));
      });

      testWidgets(
          'SouthEast of visible region corresponds to x:size.width, y:size.height',
          (WidgetTester tester) async {
        await pumpCenteredMap(
          tester,
          initialCamera: initialCamera,
          size: size,
          onMapCreated: onMapCreated,
        );
        final GoogleMapController controller = await controllerCompleter.future;

        final LatLngBounds bounds = await controller.getVisibleRegion();
        final LatLng southEast = LatLng(
          bounds.southwest.latitude,
          bounds.northeast.longitude,
        );

        final ScreenCoordinate screenPosition =
            await controller.getScreenCoordinate(southEast);

        expect(screenPosition.x, closeTo(size.width, _acceptablePixelDelta));
        expect(screenPosition.y, closeTo(size.height, _acceptablePixelDelta));
      });
    });

    group('getLatLng', () {
      testWidgets('Center of widget is the target of map',
          (WidgetTester tester) async {
        await pumpCenteredMap(
          tester,
          initialCamera: initialCamera,
          size: size,
          onMapCreated: onMapCreated,
        );

        final GoogleMapController controller = await controllerCompleter.future;

        final LatLng coords = await controller.getLatLng(
          ScreenCoordinate(x: size.width ~/ 2, y: size.height ~/ 2),
        );

        expect(
          coords.latitude,
          closeTo(center.latitude, _acceptableLatLngDelta),
        );
        expect(
          coords.longitude,
          closeTo(center.longitude, _acceptableLatLngDelta),
        );
      });

      testWidgets('Top-left of widget is NorthWest bound of map',
          (WidgetTester tester) async {
        await pumpCenteredMap(
          tester,
          initialCamera: initialCamera,
          size: size,
          onMapCreated: onMapCreated,
        );
        final GoogleMapController controller = await controllerCompleter.future;

        final LatLngBounds bounds = await controller.getVisibleRegion();
        final LatLng northWest = LatLng(
          bounds.northeast.latitude,
          bounds.southwest.longitude,
        );

        final LatLng coords = await controller.getLatLng(
          const ScreenCoordinate(x: 0, y: 0),
        );

        expect(
          coords.latitude,
          closeTo(northWest.latitude, _acceptableLatLngDelta),
        );
        expect(
          coords.longitude,
          closeTo(northWest.longitude, _acceptableLatLngDelta),
        );
      });

      testWidgets('Bottom-right of widget is SouthWest bound of map',
          (WidgetTester tester) async {
        await pumpCenteredMap(
          tester,
          initialCamera: initialCamera,
          size: size,
          onMapCreated: onMapCreated,
        );
        final GoogleMapController controller = await controllerCompleter.future;

        final LatLngBounds bounds = await controller.getVisibleRegion();
        final LatLng southEast = LatLng(
          bounds.southwest.latitude,
          bounds.northeast.longitude,
        );

        final LatLng coords = await controller.getLatLng(
          ScreenCoordinate(x: size.width.toInt(), y: size.height.toInt()),
        );

        expect(
          coords.latitude,
          closeTo(southEast.latitude, _acceptableLatLngDelta),
        );
        expect(
          coords.longitude,
          closeTo(southEast.longitude, _acceptableLatLngDelta),
        );
      });
    });
  });
}

// Pumps a CenteredMap Widget into a given tester, with some parameters
Future<void> pumpCenteredMap(
  WidgetTester tester, {
  required CameraPosition initialCamera,
  Size? size,
  void Function(GoogleMapController)? onMapCreated,
}) async {
  await tester.pumpWidget(
    CenteredMap(
      initialCamera: initialCamera,
      size: size ?? const Size(320, 240),
      onMapCreated: onMapCreated,
    ),
  );

  // This is needed to kick-off the rendering of the JS Map flutter widget
  await tester.pump();
}

/// Renders a Map widget centered on the screen.
/// This depends in `package:google_maps_flutter` to work.
class CenteredMap extends StatelessWidget {
  const CenteredMap({
    required this.initialCamera,
    required this.size,
    required this.onMapCreated,
    super.key,
  });

  /// A function that receives the [GoogleMapController] of the Map widget once initialized.
  final void Function(GoogleMapController)? onMapCreated;

  /// The size of the rendered map widget.
  final Size size;

  /// The initial camera position (center + zoom level) of the Map widget.
  final CameraPosition initialCamera;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox.fromSize(
            size: size,
            child: GoogleMap(
              initialCameraPosition: initialCamera,
              onMapCreated: onMapCreated,
            ),
          ),
        ),
      ),
    );
  }
}
