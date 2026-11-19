// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:cupertino_ui/src/liquid_glass/widgets/effects/progressive_blur.dart'
    show ProgressiveBlur, ProgressiveBlurDirection, progressiveBlurUniforms;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart' show BackdropFilterLayer;
import 'package:flutter_test/flutter_test.dart';

/// Tests for [ProgressiveBlur].
///
/// On the default test backend `isShaderFilterSupported` is false, so the
/// widget takes its uniform-blur fallback; with `--enable-impeller` it takes the
/// shader path. `setUpAll` preloads the shader, so that holds for every widget
/// test regardless of order (on the default backend preload does nothing). Both
/// paths composite a single [BackdropFilterLayer], so most tests assert on
/// layers: a backdrop filter when blurring, none at `maxSigma <= 0`, no special
/// ancestor required, and an idempotent, non-throwing [ProgressiveBlur.preload].
/// The "rendering path" group checks which path ran, and each of its tests runs
/// on only one kind of backend.
///
/// The shader path's arithmetic is reachable through [progressiveBlurUniforms],
/// which is where the region rectangle is decided — see the group at the
/// bottom.
void main() {
  int backdropLayers(WidgetTester tester) => tester.layers.whereType<BackdropFilterLayer>().length;

  setUpAll(ProgressiveBlur.preload);

  Widget host(Widget child) => CupertinoApp(
    home: Stack(
      children: <Widget>[
        const Positioned.fill(child: ColoredBox(color: CupertinoColors.systemBlue)),
        Positioned(top: 0, left: 0, right: 0, height: 96, child: child),
      ],
    ),
  );

  testWidgets('renders a backdrop filter when blurring', (tester) async {
    await tester.pumpWidget(host(const ProgressiveBlur(maxSigma: 20)));
    await tester.pump();

    expect(find.byType(ProgressiveBlur), findsOneWidget);
    // Either the shader filter or the uniform fallback: both composite a
    // single backdrop filter layer inside a ClipRect.
    expect(backdropLayers(tester), 1);
    expect(find.byType(ClipRect), findsWidgets);
  });

  testWidgets('maxSigma <= 0 is a passthrough (no backdrop filter)', (tester) async {
    await tester.pumpWidget(host(const ProgressiveBlur(maxSigma: 0)));
    await tester.pump();

    expect(find.byType(ProgressiveBlur), findsOneWidget);
    expect(backdropLayers(tester), 0);
  });

  testWidgets('dropping maxSigma to 0 removes the backdrop filter', (tester) async {
    await tester.pumpWidget(host(const ProgressiveBlur(maxSigma: 20)));
    await tester.pump();
    expect(backdropLayers(tester), 1);

    await tester.pumpWidget(host(const ProgressiveBlur(maxSigma: 0)));
    await tester.pump();
    expect(backdropLayers(tester), 0);
  });

  testWidgets('needs no special ancestor', (tester) async {
    // Deliberately mounted bare: no app, no theme.
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(width: 300, height: 96, child: ProgressiveBlur(maxSigma: 16)),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(ProgressiveBlur), findsOneWidget);
    expect(backdropLayers(tester), 1);
    if (ui.ImageFilter.isShaderFilterSupported) {
      // The shader path ran (no fallback BackdropFilter widget). It reads the
      // device pixel ratio from the MediaQuery that every View provides.
      expect(find.byType(BackdropFilter), findsNothing);
    }
  });

  testWidgets('honours the direction without throwing', (tester) async {
    for (final ProgressiveBlurDirection dir in ProgressiveBlurDirection.values) {
      await tester.pumpWidget(host(ProgressiveBlur(direction: dir)));
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
    // All four edges are exposed.
    expect(ProgressiveBlurDirection.values, hasLength(4));
  });

  test('preload is idempotent and never throws', () async {
    await ProgressiveBlur.preload();
    await ProgressiveBlur.preload();
  });

  test(
    'the shader is declared in the pubspec and loads',
    () async {
      // The package's own tests see its assets under the bare key.
      final ui.FragmentProgram program = await ui.FragmentProgram.fromAsset(
        'lib/src/third_party/progressive_blur/progressive_blur.frag',
      );
      final ui.FragmentShader shader = program.fragmentShader();
      addTearDown(shader.dispose);
    },
    skip: kIsWeb, // [intended] Web tests don't bundle compiled shaders.
  );

  testWidgets('negative maxSigma is also a passthrough', (tester) async {
    await tester.pumpWidget(host(const ProgressiveBlur(maxSigma: -5)));
    await tester.pump();
    expect(backdropLayers(tester), 0);
  });

  testWidgets('custom falloff parameter renders without error', (tester) async {
    await tester.pumpWidget(host(const ProgressiveBlur(maxSigma: 20, falloff: 2.5)));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(backdropLayers(tester), 1);
  });

  testWidgets('widget can be removed from tree without error', (tester) async {
    await tester.pumpWidget(host(const ProgressiveBlur(maxSigma: 20)));
    await tester.pump();
    expect(find.byType(ProgressiveBlur), findsOneWidget);

    // Replace with an empty container — triggers dispose().
    await tester.pumpWidget(host(const SizedBox.shrink()));
    await tester.pump();
    expect(find.byType(ProgressiveBlur), findsNothing);
    expect(tester.takeException(), isNull);
  });

  group('rendering path', () {
    final bool shaderFilters = ui.ImageFilter.isShaderFilterSupported;

    testWidgets(
      'uses the shader filter once the program has loaded',
      (tester) async {
        await tester.runAsync(ProgressiveBlur.preload);
        await tester.pumpWidget(host(const ProgressiveBlur(maxSigma: 20)));
        await tester.pump();

        // The shader path paints its own backdrop layer, not a BackdropFilter
        // widget, and composes a horizontal and a vertical shader pass.
        expect(find.byType(BackdropFilter), findsNothing);
        final List<BackdropFilterLayer> layers = tester.layers
            .whereType<BackdropFilterLayer>()
            .toList();
        expect(layers, hasLength(1));
        expect(layers.single.filter.toString(), contains('ImageFilter.compose'));
      },
      skip: !shaderFilters, // [intended] Needs shader image filters: run with --enable-impeller.
    );

    testWidgets(
      'falls back to a uniform BackdropFilter without shader filters',
      (tester) async {
        await tester.runAsync(ProgressiveBlur.preload);
        await tester.pumpWidget(host(const ProgressiveBlur(maxSigma: 20)));
        await tester.pump();

        expect(find.byType(BackdropFilter), findsOneWidget);
        expect(backdropLayers(tester), 1);
      },
      skip: shaderFilters, // [intended] The fallback only runs without shader image filters.
    );
  });

  test('asserts on invalid falloff and NaN or positive-infinite maxSigma', () {
    expect(() => ProgressiveBlur(falloff: 0), throwsAssertionError);
    expect(() => ProgressiveBlur(falloff: -1), throwsAssertionError);
    expect(() => ProgressiveBlur(falloff: double.infinity), throwsAssertionError);
    expect(() => ProgressiveBlur(maxSigma: double.nan), throwsAssertionError);
    expect(() => ProgressiveBlur(maxSigma: double.infinity), throwsAssertionError);
    // Negative values, including negative infinity, are a passthrough.
    expect(
      const ProgressiveBlur(maxSigma: double.negativeInfinity).maxSigma,
      double.negativeInfinity,
    );
  });

  test('ProgressiveBlurDirection has exactly 4 values', () {
    expect(ProgressiveBlurDirection.values, hasLength(4));
    expect(ProgressiveBlurDirection.values, [
      ProgressiveBlurDirection.topToBottom,
      ProgressiveBlurDirection.bottomToTop,
      ProgressiveBlurDirection.leftToRight,
      ProgressiveBlurDirection.rightToLeft,
    ]);
  });

  group('progressiveBlurUniforms', () {
    // The uniforms, by float index: 2 sigma, 3 falloff, 4 direction, 5 axis,
    // 6/7 region origin, 8/9 region size. This list starts at float 2, so
    // subtract 2 from each.
    List<double> uniforms({
      Offset origin = Offset.zero,
      Size size = const Size(100, 40),
      double devicePixelRatio = 1,
      double maxSigma = 12,
      double falloff = 1,
      ProgressiveBlurDirection direction = ProgressiveBlurDirection.topToBottom,
      double axis = 0,
    }) => progressiveBlurUniforms(
      origin: origin,
      size: size,
      devicePixelRatio: devicePixelRatio,
      maxSigma: maxSigma,
      falloff: falloff,
      direction: direction,
      axis: axis,
    );

    test('carries the region origin through, in device pixels', () {
      // The regression: the origin used to be hard-coded to (0, 0), so the
      // gradient was normalised over the wrong rectangle anywhere but the
      // top-left of the backdrop layer.
      final List<double> u = uniforms(origin: const Offset(24, 180), devicePixelRatio: 3);
      expect(u[4], 72); // float 6 — origin x
      expect(u[5], 540); // float 7 — origin y
    });

    test('a top-left blur still reports a zero origin', () {
      final List<double> u = uniforms(devicePixelRatio: 3);
      expect(u[4], 0);
      expect(u[5], 0);
    });

    test('region size is the widget size in device pixels', () {
      final List<double> u = uniforms(size: const Size(200, 50), devicePixelRatio: 2);
      expect(u[6], 400); // float 8 — region width
      expect(u[7], 100); // float 9 — region height
    });

    test('sigma scales with the device pixel ratio, falloff does not', () {
      final List<double> u = uniforms(maxSigma: 10, falloff: 2.5, devicePixelRatio: 3);
      expect(u[0], 30); // float 2 — sigma
      expect(u[1], 2.5); // float 3 — falloff
    });

    test('direction and axis are passed as declared', () {
      final List<double> u = uniforms(direction: ProgressiveBlurDirection.values.last, axis: 1);
      expect(u[2], (ProgressiveBlurDirection.values.length - 1).toDouble());
      expect(u[3], 1);
    });

    test('emits exactly the eight uniforms the program declares', () {
      expect(uniforms().length, 8);
    });
  });
}
