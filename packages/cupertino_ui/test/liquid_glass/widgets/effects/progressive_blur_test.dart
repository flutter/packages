import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Tests for [ProgressiveBlur].
///
/// The real graduated blur is a GPU fragment shader, which the headless test
/// backend does not compile — so `isShaderFilterSupported` is false here and the
/// widget takes its documented **uniform-blur fallback** (`ClipRect` >
/// `BackdropFilter`). These tests therefore assert the backend-independent
/// contract: passthrough at `maxSigma <= 0`, a backdrop filter when blurring,
/// no glass ancestor required, and an idempotent, non-throwing [preload].
///
/// The shader path's arithmetic is reachable through [progressiveBlurUniforms],
/// which is where the region rectangle is decided — see the group at the
/// bottom.
void main() {
  Widget host(Widget child) => MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              const Positioned.fill(child: ColoredBox(color: Colors.blue)),
              Positioned(top: 0, left: 0, right: 0, height: 96, child: child),
            ],
          ),
        ),
      );

  testWidgets('renders a backdrop filter when blurring', (tester) async {
    await tester.pumpWidget(host(const ProgressiveBlur(maxSigma: 20)));
    await tester.pump();

    expect(find.byType(ProgressiveBlur), findsOneWidget);
    // Either the shader filter or the uniform fallback — both draw through a
    // single BackdropFilter inside a ClipRect.
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.byType(ClipRect), findsWidgets);
  });

  testWidgets('maxSigma <= 0 is a passthrough (no backdrop filter)',
      (tester) async {
    await tester.pumpWidget(host(const ProgressiveBlur(maxSigma: 0)));
    await tester.pump();

    expect(find.byType(ProgressiveBlur), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('dropping maxSigma to 0 removes the backdrop filter',
      (tester) async {
    await tester.pumpWidget(host(const ProgressiveBlur(maxSigma: 20)));
    await tester.pump();
    expect(find.byType(BackdropFilter), findsOneWidget);

    await tester.pumpWidget(host(const ProgressiveBlur(maxSigma: 0)));
    await tester.pump();
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('needs no LiquidGlassLayer / glass ancestor', (tester) async {
    // Deliberately mounted bare — no wrap(), no LiquidGlassLayer.
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 300,
          height: 96,
          child: ProgressiveBlur(maxSigma: 16),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(ProgressiveBlur), findsOneWidget);
  });

  testWidgets('honours the direction without throwing', (tester) async {
    for (final dir in ProgressiveBlurDirection.values) {
      await tester
          .pumpWidget(host(ProgressiveBlur(maxSigma: 18, direction: dir)));
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
    // All four edges are exposed.
    expect(ProgressiveBlurDirection.values, hasLength(4));
  });

  test('preload is idempotent and never throws', () async {
    // Safe to await repeatedly; in tests the shader isn't bundled, so this
    // exercises the graceful-degradation branch and must still complete.
    await ProgressiveBlur.preload();
    await ProgressiveBlur.preload();
  });

  testWidgets('negative maxSigma is also a passthrough', (tester) async {
    await tester.pumpWidget(host(const ProgressiveBlur(maxSigma: -5)));
    await tester.pump();
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('custom falloff parameter renders without error', (tester) async {
    await tester.pumpWidget(
      host(const ProgressiveBlur(maxSigma: 20, falloff: 2.5)),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(BackdropFilter), findsOneWidget);
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
    }) =>
        progressiveBlurUniforms(
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
      final u = uniforms(origin: const Offset(24, 180), devicePixelRatio: 3);
      expect(u[4], 72); // float 6 — origin x
      expect(u[5], 540); // float 7 — origin y
    });

    test('a top-left blur still reports a zero origin', () {
      final u = uniforms(devicePixelRatio: 3);
      expect(u[4], 0);
      expect(u[5], 0);
    });

    test('region size is the widget size in device pixels', () {
      final u = uniforms(size: const Size(200, 50), devicePixelRatio: 2);
      expect(u[6], 400); // float 8 — region width
      expect(u[7], 100); // float 9 — region height
    });

    test('sigma scales with the device pixel ratio, falloff does not', () {
      final u = uniforms(maxSigma: 10, falloff: 2.5, devicePixelRatio: 3);
      expect(u[0], 30); // float 2 — sigma
      expect(u[1], 2.5); // float 3 — falloff
    });

    test('direction and axis are passed as declared', () {
      final u = uniforms(
        direction: ProgressiveBlurDirection.values.last,
        axis: 1,
      );
      expect(u[2], (ProgressiveBlurDirection.values.length - 1).toDouble());
      expect(u[3], 1);
    });

    test('emits exactly the eight uniforms the program declares', () {
      expect(uniforms().length, 8);
    });
  });
}
