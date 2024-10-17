// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:google_maps_flutter_web/src/utils.dart';
import 'package:integration_test/integration_test.dart';

/// Test Markers
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Since onTap/DragEnd events happen asynchronously, we need to store when the event
  // is fired. We use a completer so the test can wait for the future to be completed.
  late Completer<bool> methodCalledCompleter;

  /// This is the future value of the [methodCalledCompleter]. Reinitialized
  /// in the [setUp] method, and completed (as `true`) by [onTap] and [onDragEnd]
  /// when those methods are called from the MarkerController.
  late Future<bool> methodCalled;

  void onTap() {
    methodCalledCompleter.complete(true);
  }

  void onDragStart(gmaps.LatLng _) {
    methodCalledCompleter.complete(true);
  }

  void onDrag(gmaps.LatLng _) {
    methodCalledCompleter.complete(true);
  }

  void onDragEnd(gmaps.LatLng _) {
    methodCalledCompleter.complete(true);
  }

  setUp(() {
    methodCalledCompleter = Completer<bool>();
    methodCalled = methodCalledCompleter.future;
  });

  group('MarkerController', () {
    late gmaps.AdvancedMarkerElement marker;

    setUp(() {
      marker = gmaps.AdvancedMarkerElement();
    });

    testWidgets('onTap gets called', (WidgetTester tester) async {
      MarkerController<gmaps.AdvancedMarkerElement,
          gmaps.AdvancedMarkerElementOptions>(marker: marker, onTap: onTap);

      // Trigger a click event...
      gmaps.event.trigger(
        marker,
        'click',
        gmaps.MapMouseEvent(),
      );

      // The event handling is now truly async. Wait for it...
      expect(await methodCalled, isTrue);
    });

    testWidgets('onDragStart gets called', (WidgetTester tester) async {
      MarkerController<gmaps.AdvancedMarkerElement,
              gmaps.AdvancedMarkerElementOptions>(
          marker: marker, onDragStart: onDragStart);

      // Trigger a drag end event...
      gmaps.event.trigger(
        marker,
        'dragstart',
        gmaps.MapMouseEvent()..latLng = gmaps.LatLng(0, 0),
      );

      expect(await methodCalled, isTrue);
    });

    testWidgets('onDrag gets called', (WidgetTester tester) async {
      MarkerController<gmaps.AdvancedMarkerElement,
          gmaps.AdvancedMarkerElementOptions>(marker: marker, onDrag: onDrag);

      // Trigger a drag end event...
      gmaps.event.trigger(
        marker,
        'drag',
        gmaps.MapMouseEvent()..latLng = gmaps.LatLng(0, 0),
      );

      expect(await methodCalled, isTrue);
    });

    testWidgets('onDragEnd gets called', (WidgetTester tester) async {
      MarkerController<gmaps.AdvancedMarkerElement,
              gmaps.AdvancedMarkerElementOptions>(
          marker: marker, onDragEnd: onDragEnd);

      // Trigger a drag end event...
      gmaps.event.trigger(
        marker,
        'dragend',
        gmaps.MapMouseEvent()..latLng = gmaps.LatLng(0, 0),
      );

      expect(await methodCalled, isTrue);
    });

    testWidgets('update', (WidgetTester tester) async {
      final MarkerController<gmaps.AdvancedMarkerElement,
              gmaps.AdvancedMarkerElementOptions> controller =
          MarkerController<gmaps.AdvancedMarkerElement,
              gmaps.AdvancedMarkerElementOptions>(marker: marker);
      final gmaps.AdvancedMarkerElementOptions options =
          gmaps.AdvancedMarkerElementOptions()
            ..collisionBehavior =
                gmaps.CollisionBehavior.OPTIONAL_AND_HIDES_LOWER_PRIORITY
            ..gmpDraggable = true
            ..position = gmaps.LatLng(42, 54);

      expect(marker.collisionBehavior, gmaps.CollisionBehavior.REQUIRED);
      expect(marker.gmpDraggable, isFalse);

      controller.update(options);

      expect(marker.gmpDraggable, isTrue);
      expect(
        marker.collisionBehavior,
        gmaps.CollisionBehavior.OPTIONAL_AND_HIDES_LOWER_PRIORITY,
      );
      final JSAny? position = marker.position;
      expect(position, isNotNull);
      expect(position is gmaps.LatLngLiteral, isTrue);
      expect((position! as gmaps.LatLngLiteral).lat, equals(42));
      expect((position as gmaps.LatLngLiteral).lng, equals(54));
    });

    testWidgets('infoWindow null, showInfoWindow.',
        (WidgetTester tester) async {
      final MarkerController<gmaps.AdvancedMarkerElement,
              gmaps.AdvancedMarkerElementOptions> controller =
          MarkerController<gmaps.AdvancedMarkerElement,
              gmaps.AdvancedMarkerElementOptions>(marker: marker);

      controller.showInfoWindow();

      expect(controller.infoWindowShown, isFalse);
    });

    testWidgets('showInfoWindow', (WidgetTester tester) async {
      final gmaps.InfoWindow infoWindow = gmaps.InfoWindow();
      final gmaps.Map map = gmaps.Map(createDivElement());
      marker.map = map;
      final MarkerController<gmaps.AdvancedMarkerElement,
              gmaps.AdvancedMarkerElementOptions> controller =
          MarkerController<gmaps.AdvancedMarkerElement,
              gmaps.AdvancedMarkerElementOptions>(
        marker: marker,
        infoWindow: infoWindow,
      );

      controller.showInfoWindow();

      expect(infoWindow.get('map'), map);
      expect(controller.infoWindowShown, isTrue);
    });

    testWidgets('hideInfoWindow', (WidgetTester tester) async {
      final gmaps.InfoWindow infoWindow = gmaps.InfoWindow();
      final gmaps.Map map = gmaps.Map(createDivElement());
      marker.map = map;
      final MarkerController<gmaps.AdvancedMarkerElement,
              gmaps.AdvancedMarkerElementOptions> controller =
          MarkerController<gmaps.AdvancedMarkerElement,
              gmaps.AdvancedMarkerElementOptions>(
        marker: marker,
        infoWindow: infoWindow,
      );

      controller.hideInfoWindow();

      expect(infoWindow.get('map'), isNull);
      expect(controller.infoWindowShown, isFalse);
    });

    group('remove', () {
      late MarkerController<gmaps.AdvancedMarkerElement,
          gmaps.AdvancedMarkerElementOptions> controller;

      setUp(() {
        final gmaps.InfoWindow infoWindow = gmaps.InfoWindow();
        final gmaps.Map map = gmaps.Map(createDivElement());
        marker.map = map;
        controller = MarkerController<gmaps.AdvancedMarkerElement,
                gmaps.AdvancedMarkerElementOptions>(
            marker: marker, infoWindow: infoWindow);
      });

      testWidgets('drops gmaps instance', (WidgetTester tester) async {
        controller.remove();

        expect(controller.marker, isNull);
      });

      testWidgets('cannot call update after remove',
          (WidgetTester tester) async {
        final gmaps.AdvancedMarkerElementOptions options =
            gmaps.AdvancedMarkerElementOptions()..gmpDraggable = true;

        controller.remove();

        expect(() {
          controller.update(options);
        }, throwsAssertionError);
      });

      testWidgets('cannot call showInfoWindow after remove',
          (WidgetTester tester) async {
        controller.remove();

        expect(() {
          controller.showInfoWindow();
        }, throwsAssertionError);
      });

      testWidgets('cannot call hideInfoWindow after remove',
          (WidgetTester tester) async {
        controller.remove();

        expect(() {
          controller.hideInfoWindow();
        }, throwsAssertionError);
      });
    });
  });
}
