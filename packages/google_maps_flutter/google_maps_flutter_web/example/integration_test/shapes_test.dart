// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps/google_maps_geometry.dart' as geometry;
import 'package:google_maps/google_maps_visualization.dart' as visualization;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
// ignore: implementation_imports
import 'package:google_maps_flutter_web/src/utils.dart';
import 'package:integration_test/integration_test.dart';

// This value is used when comparing the results of
// converting from a byte value to a double between 0 and 1.
// (For Color opacity values, for example)
const double _acceptableDelta = 0.01;

/// Test Shapes (Circle, Polygon, Polyline)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late gmaps.Map map;

  setUp(() {
    map = gmaps.Map(createDivElement());
  });

  group('CirclesController', () {
    late StreamController<MapEvent<Object?>> events;
    late CirclesController controller;

    setUp(() {
      events = StreamController<MapEvent<Object?>>();
      controller = CirclesController(stream: events);
      controller.bindToMap(123, map);
    });

    testWidgets('addCircles', (WidgetTester tester) async {
      final Set<Circle> circles = <Circle>{
        const Circle(circleId: CircleId('1')),
        const Circle(circleId: CircleId('2')),
      };

      controller.addCircles(circles);

      expect(controller.circles.length, 2);
      expect(controller.circles, contains(const CircleId('1')));
      expect(controller.circles, contains(const CircleId('2')));
      expect(controller.circles, isNot(contains(const CircleId('66'))));
    });

    testWidgets('changeCircles', (WidgetTester tester) async {
      final Set<Circle> circles = <Circle>{
        const Circle(circleId: CircleId('1')),
      };
      controller.addCircles(circles);

      expect(controller.circles[const CircleId('1')]?.circle?.visible, isTrue);

      final Set<Circle> updatedCircles = <Circle>{
        const Circle(circleId: CircleId('1'), visible: false),
      };
      controller.changeCircles(updatedCircles);

      expect(controller.circles.length, 1);
      expect(controller.circles[const CircleId('1')]?.circle?.visible, isFalse);
    });

    testWidgets('removeCircles', (WidgetTester tester) async {
      final Set<Circle> circles = <Circle>{
        const Circle(circleId: CircleId('1')),
        const Circle(circleId: CircleId('2')),
        const Circle(circleId: CircleId('3')),
      };

      controller.addCircles(circles);

      expect(controller.circles.length, 3);

      // Remove some circles...
      final Set<CircleId> circleIdsToRemove = <CircleId>{
        const CircleId('1'),
        const CircleId('3'),
      };

      controller.removeCircles(circleIdsToRemove);

      expect(controller.circles.length, 1);
      expect(controller.circles, isNot(contains(const CircleId('1'))));
      expect(controller.circles, contains(const CircleId('2')));
      expect(controller.circles, isNot(contains(const CircleId('3'))));
    });

    testWidgets('Converts colors to CSS', (WidgetTester tester) async {
      final Set<Circle> circles = <Circle>{
        const Circle(
          circleId: CircleId('1'),
          fillColor: Color(0x7FFABADA),
          strokeColor: Color(0xFFC0FFEE),
        ),
      };

      controller.addCircles(circles);

      final gmaps.Circle circle = controller.circles.values.first.circle!;

      expect((circle.get('fillColor')! as JSString).toDart, '#fabada');
      expect((circle.get('fillOpacity')! as JSNumber).toDartDouble,
          closeTo(0.5, _acceptableDelta));
      expect((circle.get('strokeColor')! as JSString).toDart, '#c0ffee');
      expect((circle.get('strokeOpacity')! as JSNumber).toDartDouble,
          closeTo(1, _acceptableDelta));
    });
  });

  group('PolygonsController', () {
    late StreamController<MapEvent<Object?>> events;
    late PolygonsController controller;

    setUp(() {
      events = StreamController<MapEvent<Object?>>();
      controller = PolygonsController(stream: events);
      controller.bindToMap(123, map);
    });

    testWidgets('addPolygons', (WidgetTester tester) async {
      final Set<Polygon> polygons = <Polygon>{
        const Polygon(polygonId: PolygonId('1')),
        const Polygon(polygonId: PolygonId('2')),
      };

      controller.addPolygons(polygons);

      expect(controller.polygons.length, 2);
      expect(controller.polygons, contains(const PolygonId('1')));
      expect(controller.polygons, contains(const PolygonId('2')));
      expect(controller.polygons, isNot(contains(const PolygonId('66'))));
    });

    testWidgets('changePolygons', (WidgetTester tester) async {
      final Set<Polygon> polygons = <Polygon>{
        const Polygon(polygonId: PolygonId('1')),
      };
      controller.addPolygons(polygons);

      expect(
          controller.polygons[const PolygonId('1')]?.polygon?.visible, isTrue);

      // Update the polygon
      final Set<Polygon> updatedPolygons = <Polygon>{
        const Polygon(polygonId: PolygonId('1'), visible: false),
      };
      controller.changePolygons(updatedPolygons);

      expect(controller.polygons.length, 1);
      expect(
          controller.polygons[const PolygonId('1')]?.polygon?.visible, isFalse);
    });

    testWidgets('removePolygons', (WidgetTester tester) async {
      final Set<Polygon> polygons = <Polygon>{
        const Polygon(polygonId: PolygonId('1')),
        const Polygon(polygonId: PolygonId('2')),
        const Polygon(polygonId: PolygonId('3')),
      };

      controller.addPolygons(polygons);

      expect(controller.polygons.length, 3);

      // Remove some polygons...
      final Set<PolygonId> polygonIdsToRemove = <PolygonId>{
        const PolygonId('1'),
        const PolygonId('3'),
      };

      controller.removePolygons(polygonIdsToRemove);

      expect(controller.polygons.length, 1);
      expect(controller.polygons, isNot(contains(const PolygonId('1'))));
      expect(controller.polygons, contains(const PolygonId('2')));
      expect(controller.polygons, isNot(contains(const PolygonId('3'))));
    });

    testWidgets('Converts colors to CSS', (WidgetTester tester) async {
      final Set<Polygon> polygons = <Polygon>{
        const Polygon(
          polygonId: PolygonId('1'),
          fillColor: Color(0x7FFABADA),
          strokeColor: Color(0xFFC0FFEE),
        ),
      };

      controller.addPolygons(polygons);

      final gmaps.Polygon polygon = controller.polygons.values.first.polygon!;

      expect((polygon.get('fillColor')! as JSString).toDart, '#fabada');
      expect((polygon.get('fillOpacity')! as JSNumber).toDartDouble,
          closeTo(0.5, _acceptableDelta));
      expect((polygon.get('strokeColor')! as JSString).toDart, '#c0ffee');
      expect((polygon.get('strokeOpacity')! as JSNumber).toDartDouble,
          closeTo(1, _acceptableDelta));
    });

    testWidgets('Handle Polygons with holes', (WidgetTester tester) async {
      final Set<Polygon> polygons = <Polygon>{
        const Polygon(
          polygonId: PolygonId('BermudaTriangle'),
          points: <LatLng>[
            LatLng(25.774, -80.19),
            LatLng(18.466, -66.118),
            LatLng(32.321, -64.757),
          ],
          holes: <List<LatLng>>[
            <LatLng>[
              LatLng(28.745, -70.579),
              LatLng(29.57, -67.514),
              LatLng(27.339, -66.668),
            ],
          ],
        ),
      };

      controller.addPolygons(polygons);

      expect(controller.polygons.length, 1);
      expect(controller.polygons, contains(const PolygonId('BermudaTriangle')));
      expect(controller.polygons, isNot(contains(const PolygonId('66'))));
    });

    testWidgets('Polygon with hole has a hole', (WidgetTester tester) async {
      final Set<Polygon> polygons = <Polygon>{
        const Polygon(
          polygonId: PolygonId('BermudaTriangle'),
          points: <LatLng>[
            LatLng(25.774, -80.19),
            LatLng(18.466, -66.118),
            LatLng(32.321, -64.757),
          ],
          holes: <List<LatLng>>[
            <LatLng>[
              LatLng(28.745, -70.579),
              LatLng(29.57, -67.514),
              LatLng(27.339, -66.668),
            ],
          ],
        ),
      };

      controller.addPolygons(polygons);

      final gmaps.Polygon? polygon = controller.polygons.values.first.polygon;
      final gmaps.LatLng pointInHole = gmaps.LatLng(28.632, -68.401);

      expect(geometry.poly.containsLocation(pointInHole, polygon!), false);
    });

    testWidgets('Hole Path gets reversed to display correctly',
        (WidgetTester tester) async {
      final Set<Polygon> polygons = <Polygon>{
        const Polygon(
          polygonId: PolygonId('BermudaTriangle'),
          points: <LatLng>[
            LatLng(25.774, -80.19),
            LatLng(18.466, -66.118),
            LatLng(32.321, -64.757),
          ],
          holes: <List<LatLng>>[
            <LatLng>[
              LatLng(27.339, -66.668),
              LatLng(29.57, -67.514),
              LatLng(28.745, -70.579),
            ],
          ],
        ),
      };

      controller.addPolygons(polygons);

      final gmaps.MVCArray<gmaps.MVCArray<gmaps.LatLng?>?> paths =
          controller.polygons.values.first.polygon!.paths;

      expect(paths.getAt(1)?.getAt(0)?.lat, 28.745);
      expect(paths.getAt(1)?.getAt(1)?.lat, 29.57);
      expect(paths.getAt(1)?.getAt(2)?.lat, 27.339);
    });
  });

  group('PolylinesController', () {
    late StreamController<MapEvent<Object?>> events;
    late PolylinesController controller;

    setUp(() {
      events = StreamController<MapEvent<Object?>>();
      controller = PolylinesController(stream: events);
      controller.bindToMap(123, map);
    });

    testWidgets('addPolylines', (WidgetTester tester) async {
      final Set<Polyline> polylines = <Polyline>{
        const Polyline(polylineId: PolylineId('1')),
        const Polyline(polylineId: PolylineId('2')),
      };

      controller.addPolylines(polylines);

      expect(controller.lines.length, 2);
      expect(controller.lines, contains(const PolylineId('1')));
      expect(controller.lines, contains(const PolylineId('2')));
      expect(controller.lines, isNot(contains(const PolylineId('66'))));
    });

    testWidgets('changePolylines', (WidgetTester tester) async {
      final Set<Polyline> polylines = <Polyline>{
        const Polyline(polylineId: PolylineId('1')),
      };
      controller.addPolylines(polylines);

      expect(controller.lines[const PolylineId('1')]?.line?.visible, isTrue);

      final Set<Polyline> updatedPolylines = <Polyline>{
        const Polyline(polylineId: PolylineId('1'), visible: false),
      };
      controller.changePolylines(updatedPolylines);

      expect(controller.lines.length, 1);
      expect(controller.lines[const PolylineId('1')]?.line?.visible, isFalse);
    });

    testWidgets('removePolylines', (WidgetTester tester) async {
      final Set<Polyline> polylines = <Polyline>{
        const Polyline(polylineId: PolylineId('1')),
        const Polyline(polylineId: PolylineId('2')),
        const Polyline(polylineId: PolylineId('3')),
      };

      controller.addPolylines(polylines);

      expect(controller.lines.length, 3);

      // Remove some polylines...
      final Set<PolylineId> polylineIdsToRemove = <PolylineId>{
        const PolylineId('1'),
        const PolylineId('3'),
      };

      controller.removePolylines(polylineIdsToRemove);

      expect(controller.lines.length, 1);
      expect(controller.lines, isNot(contains(const PolylineId('1'))));
      expect(controller.lines, contains(const PolylineId('2')));
      expect(controller.lines, isNot(contains(const PolylineId('3'))));
    });

    testWidgets('Converts colors to CSS', (WidgetTester tester) async {
      final Set<Polyline> lines = <Polyline>{
        const Polyline(
          polylineId: PolylineId('1'),
          color: Color(0x7FFABADA),
        ),
      };

      controller.addPolylines(lines);

      final gmaps.Polyline line = controller.lines.values.first.line!;

      expect((line.get('strokeColor')! as JSString).toDart, '#fabada');
      expect((line.get('strokeOpacity')! as JSNumber).toDartDouble,
          closeTo(0.5, _acceptableDelta));
    });
  });

  group('HeatmapsController', () {
    late HeatmapsController controller;

    const List<WeightedLatLng> heatmapPoints = <WeightedLatLng>[
      WeightedLatLng(LatLng(37.782, -122.447)),
      WeightedLatLng(LatLng(37.782, -122.445)),
      WeightedLatLng(LatLng(37.782, -122.443)),
      WeightedLatLng(LatLng(37.782, -122.441)),
      WeightedLatLng(LatLng(37.782, -122.439)),
      WeightedLatLng(LatLng(37.782, -122.437)),
      WeightedLatLng(LatLng(37.782, -122.435)),
      WeightedLatLng(LatLng(37.785, -122.447)),
      WeightedLatLng(LatLng(37.785, -122.445)),
      WeightedLatLng(LatLng(37.785, -122.443)),
      WeightedLatLng(LatLng(37.785, -122.441)),
      WeightedLatLng(LatLng(37.785, -122.439)),
      WeightedLatLng(LatLng(37.785, -122.437)),
      WeightedLatLng(LatLng(37.785, -122.435))
    ];

    setUp(() {
      controller = HeatmapsController();
      controller.bindToMap(123, map);
    });

    testWidgets('addHeatmaps', (WidgetTester tester) async {
      final Set<Heatmap> heatmaps = <Heatmap>{
        const Heatmap(
          heatmapId: HeatmapId('1'),
          data: heatmapPoints,
          radius: HeatmapRadius.fromPixels(20),
        ),
        const Heatmap(
          heatmapId: HeatmapId('2'),
          data: heatmapPoints,
          radius: HeatmapRadius.fromPixels(20),
        ),
      };

      controller.addHeatmaps(heatmaps);

      expect(controller.heatmaps.length, 2);
      expect(controller.heatmaps, contains(const HeatmapId('1')));
      expect(controller.heatmaps, contains(const HeatmapId('2')));
      expect(controller.heatmaps, isNot(contains(const HeatmapId('66'))));
    });

    testWidgets('changeHeatmaps', (WidgetTester tester) async {
      final Set<Heatmap> heatmaps = <Heatmap>{
        const Heatmap(
          heatmapId: HeatmapId('1'),
          data: <WeightedLatLng>[],
          radius: HeatmapRadius.fromPixels(20),
        ),
      };
      controller.addHeatmaps(heatmaps);

      expect(
        controller.heatmaps[const HeatmapId('1')]?.heatmap?.data,
        hasLength(0),
      );

      final Set<Heatmap> updatedHeatmaps = <Heatmap>{
        const Heatmap(
          heatmapId: HeatmapId('1'),
          data: <WeightedLatLng>[WeightedLatLng(LatLng(0, 0))],
          radius: HeatmapRadius.fromPixels(20),
        ),
      };
      controller.changeHeatmaps(updatedHeatmaps);

      expect(controller.heatmaps.length, 1);
      expect(
        controller.heatmaps[const HeatmapId('1')]?.heatmap?.data,
        hasLength(1),
      );
    });

    testWidgets('removeHeatmaps', (WidgetTester tester) async {
      final Set<Heatmap> heatmaps = <Heatmap>{
        const Heatmap(
          heatmapId: HeatmapId('1'),
          data: heatmapPoints,
          radius: HeatmapRadius.fromPixels(20),
        ),
        const Heatmap(
          heatmapId: HeatmapId('2'),
          data: heatmapPoints,
          radius: HeatmapRadius.fromPixels(20),
        ),
        const Heatmap(
          heatmapId: HeatmapId('3'),
          data: heatmapPoints,
          radius: HeatmapRadius.fromPixels(20),
        ),
      };

      controller.addHeatmaps(heatmaps);

      expect(controller.heatmaps.length, 3);

      // Remove some polylines...
      final Set<HeatmapId> heatmapIdsToRemove = <HeatmapId>{
        const HeatmapId('1'),
        const HeatmapId('3'),
      };

      controller.removeHeatmaps(heatmapIdsToRemove);

      expect(controller.heatmaps.length, 1);
      expect(controller.heatmaps, isNot(contains(const HeatmapId('1'))));
      expect(controller.heatmaps, contains(const HeatmapId('2')));
      expect(controller.heatmaps, isNot(contains(const HeatmapId('3'))));
    });

    testWidgets('Converts colors to CSS', (WidgetTester tester) async {
      final Set<Heatmap> heatmaps = <Heatmap>{
        const Heatmap(
          heatmapId: HeatmapId('1'),
          data: heatmapPoints,
          gradient: HeatmapGradient(
            <HeatmapGradientColor>[HeatmapGradientColor(Color(0xFFFABADA), 0)],
          ),
          radius: HeatmapRadius.fromPixels(20),
        ),
      };

      controller.addHeatmaps(heatmaps);

      final visualization.HeatmapLayer heatmap =
          controller.heatmaps.values.first.heatmap!;

      expect(
        heatmap.get('gradient'),
        <String>['rgba(250, 186, 218, 0.00)', 'rgba(250, 186, 218, 1.00)'],
      );
    });
  });
}
