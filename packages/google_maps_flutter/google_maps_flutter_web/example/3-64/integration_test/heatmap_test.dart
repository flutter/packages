// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps/google_maps_visualization.dart' as visualization;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
// ignore: implementation_imports
import 'package:google_maps_flutter_web/src/utils.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late gmaps.Map map;

  setUp(() {
    map = gmaps.Map(createDivElement());
  });

  group('HeatmapsController', () {
    late HeatmapsController controller;

    const heatmapPoints = <WeightedLatLng>[
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
      WeightedLatLng(LatLng(37.785, -122.435)),
    ];

    setUp(() {
      controller = HeatmapsController();
      controller.bindToMap(123, map);
    });

    testWidgets('addHeatmaps', (WidgetTester tester) async {
      final heatmaps = <Heatmap>{
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
      final heatmaps = <Heatmap>{
        const Heatmap(
          heatmapId: HeatmapId('1'),
          data: <WeightedLatLng>[],
          radius: HeatmapRadius.fromPixels(20),
        ),
      };
      controller.addHeatmaps(heatmaps);

      expect(controller.heatmaps[const HeatmapId('1')]!.heatmap!.data.array.toDart, hasLength(0));

      final updatedHeatmaps = <Heatmap>{
        const Heatmap(
          heatmapId: HeatmapId('1'),
          data: <WeightedLatLng>[WeightedLatLng(LatLng(0, 0))],
          radius: HeatmapRadius.fromPixels(20),
        ),
      };
      controller.changeHeatmaps(updatedHeatmaps);

      expect(controller.heatmaps.length, 1);
      expect(controller.heatmaps[const HeatmapId('1')]!.heatmap!.data.array.toDart, hasLength(1));
    });

    testWidgets('removeHeatmaps', (WidgetTester tester) async {
      final heatmaps = <Heatmap>{
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

      final heatmapIdsToRemove = <HeatmapId>{const HeatmapId('1'), const HeatmapId('3')};

      controller.removeHeatmaps(heatmapIdsToRemove);

      expect(controller.heatmaps.length, 1);
      expect(controller.heatmaps, isNot(contains(const HeatmapId('1'))));
      expect(controller.heatmaps, contains(const HeatmapId('2')));
      expect(controller.heatmaps, isNot(contains(const HeatmapId('3'))));
    });

    testWidgets('Converts colors to CSS', (WidgetTester tester) async {
      final heatmaps = <Heatmap>{
        const Heatmap(
          heatmapId: HeatmapId('1'),
          data: heatmapPoints,
          gradient: HeatmapGradient(<HeatmapGradientColor>[
            HeatmapGradientColor(Color(0xFFFABADA), 0),
          ]),
          radius: HeatmapRadius.fromPixels(20),
        ),
      };

      controller.addHeatmaps(heatmaps);

      final visualization.HeatmapLayer heatmap = controller.heatmaps.values.first.heatmap!;

      expect(
        (heatmap.get('gradient')! as JSArray<JSString>).toDart.map(
          (JSString? value) => value!.toDart,
        ),
        <String>['rgba(250, 186, 218, 0.00)', 'rgba(250, 186, 218, 1.00)'],
      );
    });
  });

  group('headless tests (no map attachment)', () {
    testWidgets('update', (WidgetTester tester) async {
      final heatmap = visualization.HeatmapLayer();

      final controller = HeatmapController(heatmap: heatmap);
      final options = visualization.HeatmapLayerOptions()
        ..data = <gmaps.LatLng>[gmaps.LatLng(0, 0)].toJS;

      expect(heatmap.data.array.toDart, hasLength(0));

      controller.update(options);

      expect(heatmap.data.array.toDart, hasLength(1));
    });

    testWidgets('remove drops gmaps instance', (WidgetTester tester) async {
      final heatmap = visualization.HeatmapLayer();
      final controller = HeatmapController(heatmap: heatmap);

      controller.remove();

      expect(controller.heatmap, isNull);
    });

    testWidgets('cannot call update after remove', (WidgetTester tester) async {
      final heatmap = visualization.HeatmapLayer();
      final controller = HeatmapController(heatmap: heatmap);

      final options = visualization.HeatmapLayerOptions()..dissipating = true;

      controller.remove();

      expect(() {
        controller.update(options);
      }, throwsAssertionError);
    });
  });
}
