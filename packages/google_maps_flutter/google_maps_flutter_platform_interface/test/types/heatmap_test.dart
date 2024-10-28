// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$HeatmapRadius', () {
    test('fromPixels', () {
      const HeatmapRadius radius = HeatmapRadius.fromPixels(10);
      expect(radius.radius, 10);
    });

    test('==', () {
      const HeatmapRadius radius1 = HeatmapRadius.fromPixels(10);
      const HeatmapRadius radius2 = HeatmapRadius.fromPixels(10);
      const HeatmapRadius radius3 = HeatmapRadius.fromPixels(20);
      expect(radius1, radius2);
      expect(radius1, isNot(radius3));
    });

    test('hashCode', () {
      const int radius = 10;
      const HeatmapRadius heatmapRadius = HeatmapRadius.fromPixels(radius);
      expect(heatmapRadius.hashCode, radius.hashCode);
    });
  });

  group('$Heatmap', () {
    test('constructor defaults', () {
      const HeatmapId id = HeatmapId('heatmap');
      const List<WeightedLatLng> data = <WeightedLatLng>[
        WeightedLatLng(LatLng(1, 1)),
      ];
      const HeatmapRadius radius = HeatmapRadius.fromPixels(10);
      const Heatmap heatmap = Heatmap(
        heatmapId: id,
        data: data,
        radius: radius,
      );

      expect(heatmap.heatmapId, id);
      expect(heatmap.data, data);
      expect(heatmap.dissipating, true);
      expect(heatmap.gradient, null);
      expect(heatmap.maxIntensity, null);
      expect(heatmap.opacity, 0.7);
      expect(heatmap.radius, radius);
      expect(heatmap.minimumZoomIntensity, 0);
      expect(heatmap.maximumZoomIntensity, 21);

      expect(heatmap.heatmapId, heatmap.mapsId);
    });

    test('construct with values', () {
      const HeatmapId id = HeatmapId('heatmap');
      const List<WeightedLatLng> data = <WeightedLatLng>[
        WeightedLatLng(LatLng(1, 1)),
      ];
      const HeatmapGradient gradient = HeatmapGradient(<HeatmapGradientColor>[
        HeatmapGradientColor(Colors.red, 0.0),
      ]);
      const double maxIntensity = 1.0;
      const double opacity = 0.5;
      const HeatmapRadius radius = HeatmapRadius.fromPixels(10);
      const int minimumZoomIntensity = 1;
      const int maximumZoomIntensity = 20;
      const Heatmap heatmap = Heatmap(
        heatmapId: id,
        data: data,
        dissipating: false,
        gradient: gradient,
        maxIntensity: maxIntensity,
        opacity: opacity,
        radius: radius,
        minimumZoomIntensity: minimumZoomIntensity,
        maximumZoomIntensity: maximumZoomIntensity,
      );

      expect(heatmap.heatmapId, id);
      expect(heatmap.data, data);
      expect(heatmap.dissipating, false);
      expect(heatmap.gradient, gradient);
      expect(heatmap.maxIntensity, maxIntensity);
      expect(heatmap.opacity, opacity);
      expect(heatmap.radius, radius);
      expect(heatmap.minimumZoomIntensity, minimumZoomIntensity);
      expect(heatmap.maximumZoomIntensity, maximumZoomIntensity);
    });

    test('copyWith', () {
      const Heatmap heatmap1 = Heatmap(
        heatmapId: HeatmapId('heatmap'),
        data: <WeightedLatLng>[],
        radius: HeatmapRadius.fromPixels(10),
      );

      const List<WeightedLatLng> data = <WeightedLatLng>[
        WeightedLatLng(LatLng(1, 1)),
      ];
      const HeatmapGradient gradient = HeatmapGradient(<HeatmapGradientColor>[
        HeatmapGradientColor(Colors.red, 0.0),
      ]);
      const double maxIntensity = 1.0;
      const double opacity = 0.5;
      const HeatmapRadius radius = HeatmapRadius.fromPixels(20);
      const int minimumZoomIntensity = 1;
      const int maximumZoomIntensity = 20;

      final Heatmap heatmap2 = heatmap1.copyWith(
        dataParam: data,
        dissipatingParam: false,
        gradientParam: gradient,
        maxIntensityParam: maxIntensity,
        opacityParam: opacity,
        radiusParam: radius,
        minimumZoomIntensityParam: minimumZoomIntensity,
        maximumZoomIntensityParam: maximumZoomIntensity,
      );

      expect(heatmap2.heatmapId, heatmap1.heatmapId);
      expect(heatmap2.data, data);
      expect(heatmap2.dissipating, false);
      expect(heatmap2.gradient, gradient);
      expect(heatmap2.maxIntensity, maxIntensity);
      expect(heatmap2.opacity, opacity);
      expect(heatmap2.radius, radius);
      expect(heatmap2.minimumZoomIntensity, minimumZoomIntensity);
    });

    test('clone', () {
      const Heatmap heatmap1 = Heatmap(
        heatmapId: HeatmapId('heatmap'),
        data: <WeightedLatLng>[],
        radius: HeatmapRadius.fromPixels(10),
      );

      final Heatmap heatmap2 = heatmap1.clone();

      expect(heatmap2, heatmap1);
    });

    test('==', () {
      const HeatmapId id = HeatmapId('heatmap');
      const List<WeightedLatLng> data = <WeightedLatLng>[
        WeightedLatLng(LatLng(1, 1)),
      ];
      const HeatmapRadius radius = HeatmapRadius.fromPixels(10);
      const Heatmap heatmap1 = Heatmap(
        heatmapId: id,
        data: data,
        radius: radius,
      );
      const Heatmap heatmap2 = Heatmap(
        heatmapId: id,
        data: data,
        radius: radius,
      );
      const Heatmap heatmap3 = Heatmap(
        heatmapId: id,
        data: data,
        radius: HeatmapRadius.fromPixels(20),
      );

      expect(heatmap1, heatmap2);
      expect(heatmap1, isNot(heatmap3));
    });

    test('hashCode', () {
      const HeatmapId id = HeatmapId('heatmap');
      const Heatmap heatmap = Heatmap(
        heatmapId: id,
        data: <WeightedLatLng>[],
        radius: HeatmapRadius.fromPixels(10),
      );

      expect(heatmap.hashCode, id.hashCode);
    });
  });

  group('$WeightedLatLng', () {
    test('constructor defaults', () {
      const LatLng point = LatLng(1, 1);
      const WeightedLatLng wll = WeightedLatLng(point);

      expect(wll.point, point);
      expect(wll.weight, 1.0);
    });

    test('construct with values', () {
      const LatLng point = LatLng(1, 1);
      const double weight = 2.0;
      const WeightedLatLng wll = WeightedLatLng(point, weight: weight);

      expect(wll.point, point);
      expect(wll.weight, weight);
    });

    test('toJson', () {
      const LatLng point = LatLng(1, 1);
      const double weight = 2.0;
      const WeightedLatLng wll = WeightedLatLng(point, weight: weight);

      expect(wll.toJson(), <Object>[
        <double>[point.latitude, point.longitude],
        weight,
      ]);
    });

    test('toString', () {
      const LatLng point = LatLng(1, 1);
      const double weight = 2.0;
      const WeightedLatLng wll = WeightedLatLng(point, weight: weight);

      expect(wll.toString(), 'WeightedLatLng($point, $weight)');
    });

    test('==', () {
      const LatLng point = LatLng(1, 1);
      const double weight = 2.0;
      const WeightedLatLng wll1 = WeightedLatLng(point, weight: weight);
      const WeightedLatLng wll2 = WeightedLatLng(point, weight: weight);
      const WeightedLatLng wll3 = WeightedLatLng(point, weight: 3.0);

      expect(wll1, wll2);
      expect(wll1, isNot(wll3));
    });

    test('hashCode', () {
      const LatLng point = LatLng(1, 1);
      const double weight = 2.0;
      const WeightedLatLng wll = WeightedLatLng(point, weight: weight);

      expect(wll.hashCode, Object.hash(point, weight));
    });
  });

  group('$HeatmapGradient', () {
    test('constructor defaults', () {
      const List<HeatmapGradientColor> colors = <HeatmapGradientColor>[
        HeatmapGradientColor(Colors.red, 0.0),
      ];
      const HeatmapGradient gradient = HeatmapGradient(colors);

      expect(gradient.colors, colors);
      expect(gradient.colorMapSize, 256);
    });

    test('construct with values', () {
      const List<HeatmapGradientColor> colors = <HeatmapGradientColor>[
        HeatmapGradientColor(Colors.red, 0.0),
      ];
      const int colorMapSize = 512;
      const HeatmapGradient gradient =
          HeatmapGradient(colors, colorMapSize: colorMapSize);

      expect(gradient.colors, colors);
      expect(gradient.colorMapSize, colorMapSize);
    });

    test('copyWith', () {
      const HeatmapGradient gradient1 = HeatmapGradient(<HeatmapGradientColor>[
        HeatmapGradientColor(Colors.red, 0.0),
      ]);

      const List<HeatmapGradientColor> colors = <HeatmapGradientColor>[
        HeatmapGradientColor(Colors.blue, 0.0),
      ];
      const int colorMapSize = 512;
      final HeatmapGradient gradient2 = gradient1.copyWith(
        colorsParam: colors,
        colorMapSizeParam: colorMapSize,
      );

      expect(gradient2.colors, colors);
      expect(gradient2.colorMapSize, colorMapSize);
    });

    test('clone', () {
      const HeatmapGradient gradient1 = HeatmapGradient(
        <HeatmapGradientColor>[HeatmapGradientColor(Colors.red, 0.0)],
        colorMapSize: 512,
      );

      final HeatmapGradient gradient2 = gradient1.clone();
      expect(gradient2, gradient1);
    });

    test('toJson', () {
      const List<HeatmapGradientColor> colors = <HeatmapGradientColor>[
        HeatmapGradientColor(Colors.red, 0.0),
      ];
      const int colorMapSize = 512;
      const HeatmapGradient gradient =
          HeatmapGradient(colors, colorMapSize: colorMapSize);

      expect(gradient.toJson(), <String, Object?>{
        'colors':
            colors.map((HeatmapGradientColor e) => e.color.value).toList(),
        'startPoints':
            colors.map((HeatmapGradientColor e) => e.startPoint).toList(),
        'colorMapSize': colorMapSize,
      });
    });

    test('==', () {
      const List<HeatmapGradientColor> colors = <HeatmapGradientColor>[
        HeatmapGradientColor(Colors.red, 0.0),
      ];
      const HeatmapGradient gradient1 = HeatmapGradient(colors);
      const HeatmapGradient gradient2 = HeatmapGradient(colors);
      const HeatmapGradient gradient3 = HeatmapGradient(
          <HeatmapGradientColor>[HeatmapGradientColor(Colors.blue, 0.0)],
          colorMapSize: 512);

      expect(gradient1, gradient2);
      expect(gradient1, isNot(gradient3));
    });

    test('hashCode', () {
      const List<HeatmapGradientColor> colors = <HeatmapGradientColor>[
        HeatmapGradientColor(Colors.red, 0.0),
      ];
      const int colorMapSize = 512;
      const HeatmapGradient gradient =
          HeatmapGradient(colors, colorMapSize: colorMapSize);

      expect(gradient.hashCode, Object.hash(colors, colorMapSize));
    });
  });

  group('$HeatmapGradientColor', () {
    test('construct with values', () {
      const Color color = Colors.red;
      const double startPoint = 0.0;
      const HeatmapGradientColor gradientColor =
          HeatmapGradientColor(color, startPoint);

      expect(gradientColor.color, color);
      expect(gradientColor.startPoint, startPoint);
    });

    test('copyWith', () {
      const HeatmapGradientColor gradientColor1 =
          HeatmapGradientColor(Colors.red, 0.0);

      const Color color = Colors.blue;
      const double startPoint = 0.5;
      final HeatmapGradientColor gradientColor2 = gradientColor1.copyWith(
        colorParam: color,
        startPointParam: startPoint,
      );

      expect(gradientColor2.color, color);
      expect(gradientColor2.startPoint, startPoint);
    });

    test('clone', () {
      const HeatmapGradientColor gradientColor1 =
          HeatmapGradientColor(Colors.red, 0.0);

      final HeatmapGradientColor gradientColor2 = gradientColor1.clone();
      expect(gradientColor2, gradientColor1);
    });

    test('==', () {
      const HeatmapGradientColor gradientColor1 =
          HeatmapGradientColor(Colors.red, 0.0);
      const HeatmapGradientColor gradientColor2 =
          HeatmapGradientColor(Colors.red, 0.0);
      const HeatmapGradientColor gradientColor3 =
          HeatmapGradientColor(Colors.blue, 0.0);

      expect(gradientColor1, gradientColor2);
      expect(gradientColor1, isNot(gradientColor3));
    });

    test('hashCode', () {
      const HeatmapGradientColor gradientColor =
          HeatmapGradientColor(Colors.red, 0.0);

      expect(
        gradientColor.hashCode,
        Object.hash(gradientColor.color, gradientColor.startPoint),
      );
    });

    test('toString', () {
      const HeatmapGradientColor gradientColor =
          HeatmapGradientColor(Colors.red, 0.0);

      expect(
        gradientColor.toString(),
        'HeatmapGradientColor(${gradientColor.color}, ${gradientColor.startPoint})',
      );
    });
  });
}
