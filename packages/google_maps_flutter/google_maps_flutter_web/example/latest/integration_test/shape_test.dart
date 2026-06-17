// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:integration_test/integration_test.dart';

/// Test Shapes (Circle, Polygon, Polyline)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Since onTap events happen asynchronously, we need to store when the event
  // is fired. We use a completer so the test can wait for the future to be completed.
  late Completer<bool> methodCalledCompleter;

  /// This is the future value of the [methodCalledCompleter]. Reinitialized
  /// in the [setUp] method, and completed (as `true`) by [onTap], when it gets
  /// called by the corresponding Shape Controller.
  late Future<bool> methodCalled;

  void onTap() {
    methodCalledCompleter.complete(true);
  }

  setUp(() {
    methodCalledCompleter = Completer<bool>();
    methodCalled = methodCalledCompleter.future;
  });

  group('CircleController', () {
    late gmaps.Circle circle;

    setUp(() {
      circle = gmaps.Circle(gmaps.CircleOptions());
    });

    testWidgets('onTap gets called', (WidgetTester tester) async {
      CircleController(circle: circle, consumeTapEvents: true, onTap: onTap);

      // Trigger a click event...
      gmaps.event.trigger(circle, 'click', gmaps.MapMouseEvent());

      // The event handling is now truly async. Wait for it...
      expect(await methodCalled, isTrue);
    });

    testWidgets('update', (WidgetTester tester) async {
      final controller = CircleController(circle: circle);
      final options = gmaps.CircleOptions()..draggable = true;

      expect(circle.isDraggableDefined(), isFalse);

      controller.update(options);

      expect(circle.draggable, isTrue);
    });

    group('remove', () {
      late CircleController controller;

      setUp(() {
        controller = CircleController(circle: circle);
      });

      testWidgets('drops gmaps instance', (WidgetTester tester) async {
        controller.remove();

        expect(controller.circle, isNull);
      });

      testWidgets('cannot call update after remove', (WidgetTester tester) async {
        final options = gmaps.CircleOptions()..draggable = true;

        controller.remove();

        expect(() {
          controller.update(options);
        }, throwsAssertionError);
      });
    });
  });

  group('PolygonController', () {
    late gmaps.Polygon polygon;

    setUp(() {
      polygon = gmaps.Polygon();
    });

    testWidgets('onTap gets called', (WidgetTester tester) async {
      PolygonController(polygon: polygon, consumeTapEvents: true, onTap: onTap);

      // Trigger a click event...
      gmaps.event.trigger(polygon, 'click', gmaps.MapMouseEvent());

      // The event handling is now truly async. Wait for it...
      expect(await methodCalled, isTrue);
    });

    testWidgets('update', (WidgetTester tester) async {
      final controller = PolygonController(polygon: polygon);
      final options = gmaps.PolygonOptions()..draggable = true;

      expect(polygon.isDraggableDefined(), isFalse);

      controller.update(options);

      expect(polygon.draggable, isTrue);
    });

    group('remove', () {
      late PolygonController controller;

      setUp(() {
        controller = PolygonController(polygon: polygon);
      });

      testWidgets('drops gmaps instance', (WidgetTester tester) async {
        controller.remove();

        expect(controller.polygon, isNull);
      });

      testWidgets('cannot call update after remove', (WidgetTester tester) async {
        final options = gmaps.PolygonOptions()..draggable = true;

        controller.remove();

        expect(() {
          controller.update(options);
        }, throwsAssertionError);
      });
    });

    group('onEdited', () {
      late gmaps.Polygon editablePolygon;

      setUp(() {
        editablePolygon = gmaps.Polygon(
          gmaps.PolygonOptions()
            ..editable = true
            ..paths = <JSArray<gmaps.LatLng>>[
              <gmaps.LatLng>[gmaps.LatLng(0, 0), gmaps.LatLng(1, 0), gmaps.LatLng(1, 1)].toJS,
              <gmaps.LatLng>[
                gmaps.LatLng(0.1, 0.1),
                gmaps.LatLng(0.2, 0.1),
                gmaps.LatLng(0.2, 0.2),
              ].toJS,
            ].toJS,
        );
      });

      testWidgets('fires onEdited on setAt with outer path and holes', (WidgetTester tester) async {
        final completer = Completer<({List<gmaps.LatLng> outer, List<List<gmaps.LatLng>> holes})>();
        PolygonController(
          polygon: editablePolygon,
          onEdited: (List<gmaps.LatLng> outer, List<List<gmaps.LatLng>> holes) {
            if (!completer.isCompleted) {
              completer.complete((outer: outer, holes: holes));
            }
          },
        );

        editablePolygon.paths.getAt(0).setAt(0, gmaps.LatLng(5, 5));

        final ({List<gmaps.LatLng> outer, List<List<gmaps.LatLng>> holes}) result =
            await completer.future;
        expect(result.outer, hasLength(3));
        expect(result.outer.first.lat, 5);
        expect(result.outer.first.lng, 5);
        expect(result.holes, hasLength(1));
        expect(result.holes.first, hasLength(3));
      });

      testWidgets('fires onEdited when a hole path is mutated', (WidgetTester tester) async {
        final completer = Completer<({List<gmaps.LatLng> outer, List<List<gmaps.LatLng>> holes})>();
        PolygonController(
          polygon: editablePolygon,
          onEdited: (List<gmaps.LatLng> outer, List<List<gmaps.LatLng>> holes) {
            if (!completer.isCompleted) {
              completer.complete((outer: outer, holes: holes));
            }
          },
        );

        editablePolygon.paths.getAt(1).setAt(0, gmaps.LatLng(0.9, 0.9));

        final ({List<gmaps.LatLng> outer, List<List<gmaps.LatLng>> holes}) result =
            await completer.future;
        expect(result.outer, hasLength(3));
        expect(result.holes, hasLength(1));
        expect(result.holes.first.first.lat, 0.9);
        expect(result.holes.first.first.lng, 0.9);
      });

      testWidgets('fires onEdited on insertAt', (WidgetTester tester) async {
        final completer = Completer<List<gmaps.LatLng>>();
        PolygonController(
          polygon: editablePolygon,
          onEdited: (List<gmaps.LatLng> outer, List<List<gmaps.LatLng>> holes) {
            if (!completer.isCompleted) {
              completer.complete(outer);
            }
          },
        );

        editablePolygon.paths.getAt(0).insertAt(0, gmaps.LatLng(9, 9));

        final List<gmaps.LatLng> result = await completer.future;
        expect(result, hasLength(4));
        expect(result.first.lat, 9);
      });

      testWidgets('fires onEdited on removeAt', (WidgetTester tester) async {
        final completer = Completer<List<gmaps.LatLng>>();
        PolygonController(
          polygon: editablePolygon,
          onEdited: (List<gmaps.LatLng> outer, List<List<gmaps.LatLng>> holes) {
            if (!completer.isCompleted) {
              completer.complete(outer);
            }
          },
        );

        editablePolygon.paths.getAt(0).removeAt(0);

        final List<gmaps.LatLng> result = await completer.future;
        expect(result, hasLength(2));
      });

      testWidgets('remove cancels onEdited subscriptions', (WidgetTester tester) async {
        var callCount = 0;
        final controller = PolygonController(
          polygon: editablePolygon,
          onEdited: (List<gmaps.LatLng> outer, List<List<gmaps.LatLng>> holes) {
            callCount++;
          },
        );

        controller.remove();
        editablePolygon.paths.getAt(0).setAt(0, gmaps.LatLng(7, 7));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(callCount, 0);
      });
    });
  });

  group('PolylineController', () {
    late gmaps.Polyline polyline;

    setUp(() {
      polyline = gmaps.Polyline();
    });

    testWidgets('onTap gets called', (WidgetTester tester) async {
      PolylineController(polyline: polyline, consumeTapEvents: true, onTap: onTap);

      // Trigger a click event...
      gmaps.event.trigger(polyline, 'click', gmaps.MapMouseEvent());

      // The event handling is now truly async. Wait for it...
      expect(await methodCalled, isTrue);
    });

    testWidgets('update', (WidgetTester tester) async {
      final controller = PolylineController(polyline: polyline);
      final options = gmaps.PolylineOptions()..draggable = true;

      expect(polyline.isDraggableDefined(), isFalse);

      controller.update(options);

      expect(polyline.draggable, isTrue);
    });

    group('remove', () {
      late PolylineController controller;

      setUp(() {
        controller = PolylineController(polyline: polyline);
      });

      testWidgets('drops gmaps instance', (WidgetTester tester) async {
        controller.remove();

        expect(controller.line, isNull);
      });

      testWidgets('cannot call update after remove', (WidgetTester tester) async {
        final options = gmaps.PolylineOptions()..draggable = true;

        controller.remove();

        expect(() {
          controller.update(options);
        }, throwsAssertionError);
      });
    });

    group('onEdited', () {
      late gmaps.Polyline editablePolyline;

      setUp(() {
        editablePolyline = gmaps.Polyline(
          gmaps.PolylineOptions()
            ..editable = true
            ..path = <gmaps.LatLng>[gmaps.LatLng(0, 0), gmaps.LatLng(1, 1)].toJS,
        );
      });

      testWidgets('fires onEdited on setAt with updated path', (WidgetTester tester) async {
        final completer = Completer<List<gmaps.LatLng>>();
        PolylineController(
          polyline: editablePolyline,
          onEdited: (List<gmaps.LatLng> path) {
            if (!completer.isCompleted) {
              completer.complete(path);
            }
          },
        );

        editablePolyline.path.setAt(0, gmaps.LatLng(2, 2));

        final List<gmaps.LatLng> result = await completer.future;
        expect(result, hasLength(2));
        expect(result.first.lat, 2);
        expect(result.first.lng, 2);
      });

      testWidgets('fires onEdited on insertAt with updated path', (WidgetTester tester) async {
        final completer = Completer<List<gmaps.LatLng>>();
        PolylineController(
          polyline: editablePolyline,
          onEdited: (List<gmaps.LatLng> path) {
            if (!completer.isCompleted) {
              completer.complete(path);
            }
          },
        );

        editablePolyline.path.insertAt(0, gmaps.LatLng(9, 9));

        final List<gmaps.LatLng> result = await completer.future;
        expect(result, hasLength(3));
        expect(result.first.lat, 9);
      });

      testWidgets('fires onEdited on removeAt with updated path', (WidgetTester tester) async {
        final completer = Completer<List<gmaps.LatLng>>();
        PolylineController(
          polyline: editablePolyline,
          onEdited: (List<gmaps.LatLng> path) {
            if (!completer.isCompleted) {
              completer.complete(path);
            }
          },
        );

        editablePolyline.path.removeAt(0);

        final List<gmaps.LatLng> result = await completer.future;
        expect(result, hasLength(1));
        expect(result.first.lat, 1);
      });

      testWidgets('remove cancels onEdited subscriptions', (WidgetTester tester) async {
        var callCount = 0;
        final controller = PolylineController(
          polyline: editablePolyline,
          onEdited: (List<gmaps.LatLng> path) {
            callCount++;
          },
        );

        controller.remove();
        editablePolyline.path.setAt(0, gmaps.LatLng(3, 3));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(callCount, 0);
      });
    });
  });
}
