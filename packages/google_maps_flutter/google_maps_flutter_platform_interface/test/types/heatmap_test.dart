// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$HeatmapRadius', () {
    test('fromPixels', () {
      const radius = HeatmapRadius.fromPixels(10);
      expect(radius.radius, 10);
    });

    test('==', () {
      const radius1 = HeatmapRadius.fromPixels(10);
      const radius2 = HeatmapRadius.fromPixels(10);
      const radius3 = HeatmapRadius.fromPixels(20);
      expect(radius1, radius2);
      expect(radius1, isNot(radius3));
    });

    test('hashCode', () {
      const radius = 10;
      const heatmapRadius = HeatmapRadius.fromPixels(radius);
      expect(heatmapRadius.hashCode, radius.hashCode);
    });
  });

  group('$Heatmap', () {
    test('constructor defaults', () {
      const id = HeatmapId('heatmap');
      const data = <WeightedLatLng>[WeightedLatLng(LatLng(1, 1))];
      const radius = HeatmapRadius.fromPixels(10);
      const heatmap = Heatmap(heatmapId: id, data: data, radius: radius);

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
      const id = HeatmapId('heatmap');
      const data = <WeightedLatLng>[WeightedLatLng(LatLng(1, 1))];
      const gradient = HeatmapGradient(<HeatmapGradientColor>[
        HeatmapGradientColor(Colors.red, 0.0),
      ]);
      const maxIntensity = 1.0;
      const opacity = 0.5;
      const radius = HeatmapRadius.fromPixels(10);
      const minimumZoomIntensity = 1;
      const maximumZoomIntensity = 20;
      const heatmap = Heatmap(
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
      const heatmap1 = Heatmap(
        heatmapId: HeatmapId('heatmap'),
        data: <WeightedLatLng>[],
        radius: HeatmapRadius.fromPixels(10),
      );

      const data = <WeightedLatLng>[WeightedLatLng(LatLng(1, 1))];
      const gradient = HeatmapGradient(<HeatmapGradientColor>[
        HeatmapGradientColor(Colors.red, 0.0),
      ]);
      const maxIntensity = 1.0;
      const opacity = 0.5;
      const radius = HeatmapRadius.fromPixels(20);
      const minimumZoomIntensity = 1;
      const maximumZoomIntensity = 20;

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
      const heatmap1 = Heatmap(
        heatmapId: HeatmapId('heatmap'),
        data: <WeightedLatLng>[],
        radius: HeatmapRadius.fromPixels(10),
      );

      final Heatmap heatmap2 = heatmap1.clone();

      expect(heatmap2, heatmap1);
    });

    test('==', () {
      const id = HeatmapId('heatmap');
      const data = <WeightedLatLng>[WeightedLatLng(LatLng(1, 1))];
      const radius = HeatmapRadius.fromPixels(10);
      const heatmap1 = Heatmap(heatmapId: id, data: data, radius: radius);
      const heatmap2 = Heatmap(heatmapId: id, data: data, radius: radius);
      const heatmap3 = Heatmap(
        heatmapId: id,
        data: data,
        radius: HeatmapRadius.fromPixels(20),
      );

      expect(heatmap1, heatmap2);
      expect(heatmap1, isNot(heatmap3));
    });

    test('hashCode', () {
      const id = HeatmapId('heatmap');
      const heatmap = Heatmap(
        heatmapId: id,
        data: <WeightedLatLng>[],
        radius: HeatmapRadius.fromPixels(10),
      );

      expect(heatmap.hashCode, id.hashCode);
    });
  });

  group('$WeightedLatLng', () {
    test('constructor defaults', () {
      const point = LatLng(1, 1);
      const wll = WeightedLatLng(point);

      expect(wll.point, point);
      expect(wll.weight, 1.0);
    });

    test('construct with values', () {
      const point = LatLng(1, 1);
      const weight = 2.0;
      const wll = WeightedLatLng(point, weight: weight);

      expect(wll.point, point);
      expect(wll.weight, weight);
    });

    test('toJson', () {
      const point = LatLng(1, 1);
      const weight = 2.0;
      const wll = WeightedLatLng(point, weight: weight);

      expect(wll.toJson(), <Object>[
        <double>[point.latitude, point.longitude],
        weight,
      ]);
    });

    test('toString', () {
      const point = LatLng(1, 1);
      const weight = 2.0;
      const wll = WeightedLatLng(point, weight: weight);

      expect(wll.toString(), 'WeightedLatLng($point, $weight)');
    });

    test('==', () {
      const point = LatLng(1, 1);
      const weight = 2.0;
      const wll1 = WeightedLatLng(point, weight: weight);
      const wll2 = WeightedLatLng(point, weight: weight);
      const wll3 = WeightedLatLng(point, weight: 3.0);

      expect(wll1, wll2);
      expect(wll1, isNot(wll3));
    });

    test('hashCode', () {
      const point = LatLng(1, 1);
      const weight = 2.0;
      const wll = WeightedLatLng(point, weight: weight);

      expect(wll.hashCode, Object.hash(point, weight));
    });
  });

  group('$HeatmapGradient', () {
    test('constructor defaults', () {
      const colors = <HeatmapGradientColor>[
        HeatmapGradientColor(Colors.red, 0.0),
      ];
      const gradient = HeatmapGradient(colors);

      expect(gradient.colors, colors);
      expect(gradient.colorMapSize, 256);
    });

    test('construct with values', () {
      const colors = <HeatmapGradientColor>[
        HeatmapGradientColor(Colors.red, 0.0),
      ];
      const colorMapSize = 512;
      const gradient = HeatmapGradient(colors, colorMapSize: colorMapSize);

      expect(gradient.colors, colors);
      expect(gradient.colorMapSize, colorMapSize);
    });

    test('copyWith', () {
      const gradient1 = HeatmapGradient(<HeatmapGradientColor>[
        HeatmapGradientColor(Colors.red, 0.0),
      ]);

      const colors = <HeatmapGradientColor>[
        HeatmapGradientColor(Colors.blue, 0.0),
      ];
      const colorMapSize = 512;
      final HeatmapGradient gradient2 = gradient1.copyWith(
        colorsParam: colors,
        colorMapSizeParam: colorMapSize,
      );

      expect(gradient2.colors, colors);
      expect(gradient2.colorMapSize, colorMapSize);
    });

    test('clone', () {
      const gradient1 = HeatmapGradient(<HeatmapGradientColor>[
        HeatmapGradientColor(Colors.red, 0.0),
      ], colorMapSize: 512);

      final HeatmapGradient gradient2 = gradient1.clone();
      expect(gradient2, gradient1);
    });

    test('toJson', () {
      const colors = <HeatmapGradientColor>[
        HeatmapGradientColor(Colors.red, 0.0),
      ];
      const colorMapSize = 512;
      const gradient = HeatmapGradient(colors, colorMapSize: colorMapSize);

      expect(gradient.toJson(), <String, Object?>{
        'colors': colors
            .map((HeatmapGradientColor e) => e.color.toARGB32())
            .toList(),
        'startPoints': colors
            .map((HeatmapGradientColor e) => e.startPoint)
            .toList(),
        'colorMapSize': colorMapSize,
      });
    });

    test('==', () {
      const colors = <HeatmapGradientColor>[
        HeatmapGradientColor(Colors.red, 0.0),
      ];
      const gradient1 = HeatmapGradient(colors);
      const gradient2 = HeatmapGradient(colors);
      const gradient3 = HeatmapGradient(<HeatmapGradientColor>[
        HeatmapGradientColor(Colors.blue, 0.0),
      ], colorMapSize: 512);

      expect(gradient1, gradient2);
      expect(gradient1, isNot(gradient3));
    });

    test('hashCode', () {
      const colors = <HeatmapGradientColor>[
        HeatmapGradientColor(Colors.red, 0.0),
      ];
      const colorMapSize = 512;
      const gradient = HeatmapGradient(colors, colorMapSize: colorMapSize);

      expect(gradient.hashCode, Object.hash(colors, colorMapSize));
    });
  });

  group('$HeatmapGradientColor', () {
    test('construct with values', () {
      const Color color = Colors.red;
      const startPoint = 0.0;
      const gradientColor = HeatmapGradientColor(color, startPoint);

      expect(gradientColor.color, color);
      expect(gradientColor.startPoint, startPoint);
    });

    test('copyWith', () {
      const gradientColor1 = HeatmapGradientColor(Colors.red, 0.0);

      const Color color = Colors.blue;
      const startPoint = 0.5;
      final HeatmapGradientColor gradientColor2 = gradientColor1.copyWith(
        colorParam: color,
        startPointParam: startPoint,
      );

      expect(gradientColor2.color, color);
      expect(gradientColor2.startPoint, startPoint);
    });

    test('clone', () {
      const gradientColor1 = HeatmapGradientColor(Colors.red, 0.0);

      final HeatmapGradientColor gradientColor2 = gradientColor1.clone();
      expect(gradientColor2, gradientColor1);
    });

    test('==', () {
      const gradientColor1 = HeatmapGradientColor(Colors.red, 0.0);
      const gradientColor2 = HeatmapGradientColor(Colors.red, 0.0);
      const gradientColor3 = HeatmapGradientColor(Colors.blue, 0.0);

      expect(gradientColor1, gradientColor2);
      expect(gradientColor1, isNot(gradientColor3));
    });

    test('hashCode', () {
      const gradientColor = HeatmapGradientColor(Colors.red, 0.0);

      expect(
        gradientColor.hashCode,
        Object.hash(gradientColor.color, gradientColor.startPoint),
      );
    });

    test('toString', () {
      const gradientColor = HeatmapGradientColor(Colors.red, 0.0);

      expect(
        gradientColor.toString(),
        'HeatmapGradientColor(${gradientColor.color}, ${gradientColor.startPoint})',
      );
    });
  });
}
