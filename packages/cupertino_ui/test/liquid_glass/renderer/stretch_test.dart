import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/src/renderer/liquid_glass_self_scale_scope.dart';
import 'package:liquid_glass_widgets/src/engine/stretch.dart';

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // OffsetResistanceExtension.withResistance
  // ──────────────────────────────────────────────────────────────────────────

  group('OffsetResistanceExtension.withResistance', () {
    test('zero resistance returns same offset', () {
      const offset = Offset(10, 20);
      expect(offset.withResistance(0), offset);
    });

    test('zero-magnitude offset returns Offset.zero', () {
      expect(Offset.zero.withResistance(0.5), Offset.zero);
    });

    test('positive resistance reduces magnitude', () {
      const offset = Offset(100, 0);
      final resisted = offset.withResistance(0.1);
      expect(resisted.dx, lessThan(100));
      expect(resisted.dy, closeTo(0, 1e-10));
    });

    test('preserves direction for horizontal offset', () {
      const offset = Offset(50, 0);
      final resisted = offset.withResistance(0.05);
      expect(resisted.dx, greaterThan(0));
      expect(resisted.dy, closeTo(0, 1e-10));
    });

    test('preserves direction for vertical offset', () {
      const offset = Offset(0, 50);
      final resisted = offset.withResistance(0.05);
      expect(resisted.dx, closeTo(0, 1e-10));
      expect(resisted.dy, greaterThan(0));
    });

    test('preserves direction for diagonal offset', () {
      const offset = Offset(30, 40); // magnitude 50
      final resisted = offset.withResistance(0.1);
      // Direction should be preserved: dy/dx ratio same
      expect(resisted.dy / resisted.dx, closeTo(4 / 3, 1e-6));
    });

    test('higher resistance results in smaller magnitude', () {
      const offset = Offset(100, 0);
      final lowResist = offset.withResistance(0.01);
      final highResist = offset.withResistance(0.5);
      expect(highResist.dx, lessThan(lowResist.dx));
    });

    test('negative offset preserves negative direction', () {
      const offset = Offset(-60, 0);
      final resisted = offset.withResistance(0.1);
      expect(resisted.dx, lessThan(0));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // RenderRawLiquidStretch.getScale
  // ──────────────────────────────────────────────────────────────────────────

  group('RenderRawLiquidStretch.getScale', () {
    late RenderRawLiquidStretch render;

    setUp(() {
      render = RenderRawLiquidStretch(stretchPixels: Offset.zero);
    });

    test('returns (1, 1) for empty size', () {
      final scale = render.getScale(
        stretchPixels: const Offset(10, 0),
        size: Size.zero,
      );
      expect(scale, const Offset(1, 1));
    });

    test('horizontal stretch increases scaleX', () {
      final scale = render.getScale(
        stretchPixels: const Offset(20, 0),
        size: const Size(100, 100),
      );
      expect(scale.dx, greaterThan(1.0));
    });

    test('vertical stretch increases scaleY', () {
      final scale = render.getScale(
        stretchPixels: const Offset(0, 20),
        size: const Size(100, 100),
      );
      expect(scale.dy, greaterThan(1.0));
    });

    test('zero stretch returns near (1, 1)', () {
      final scale = render.getScale(
        stretchPixels: Offset.zero,
        size: const Size(100, 100),
      );
      // Volume correction: targetVolume=1+0*0.5=1, currentVolume=1*1=1 →
      // correction=1 → scale is approximately (1, 1)
      expect(scale.dx, closeTo(1.0, 0.01));
      expect(scale.dy, closeTo(1.0, 0.01));
    });

    test('larger stretch gives larger scale values', () {
      final small = render.getScale(
        stretchPixels: const Offset(5, 0),
        size: const Size(100, 100),
      );
      final large = render.getScale(
        stretchPixels: const Offset(30, 0),
        size: const Size(100, 100),
      );
      expect(large.dx, greaterThan(small.dx));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // LiquidStretch widget
  // ──────────────────────────────────────────────────────────────────────────

  group('LiquidStretch', () {
    test('defaults are correct', () {
      const widget = LiquidStretch(child: SizedBox.shrink());
      expect(widget.interactionScale, 1.05);
      expect(widget.stretch, 0.5);
      expect(widget.resistance, 0.01);
      expect(widget.hitTestBehavior, HitTestBehavior.opaque);
    });

    testWidgets('passes through to child when stretch=0 and scale=1.0',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LiquidStretch(
            stretch: 0,
            interactionScale: 1.0,
            child: Text('no stretch'),
          ),
        ),
      );
      expect(find.text('no stretch'), findsOneWidget);
    });

    testWidgets('renders GlassDragBuilder when stretch > 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LiquidStretch(
            stretch: 0.5,
            child: SizedBox(width: 100, height: 50),
          ),
        ),
      );
      expect(find.byType(LiquidStretch), findsOneWidget);
    });

    testWidgets('carries an ancestor self-scale declaration through',
        (tester) async {
      late bool seen;
      await tester.pumpWidget(
        MaterialApp(
          home: LiquidGlassSelfScaleScope(
            selfScaled: true,
            child: LiquidStretch(
              interactionScale: 1.01,
              child: Builder(
                builder: (context) {
                  seen = LiquidGlassSelfScaleScope.of(context);
                  return const SizedBox(width: 56, height: 56);
                },
              ),
            ),
          ),
        ),
      );
      expect(seen, isTrue,
          reason: 'a swiped sheet\'s declaration must reach the glass below '
              'the press scale, which resolves only the nearest scope (#229)');
    });

    // The press scale follows a native 56 pt glass circle measured at 120 fps:
    // up to its scale in ~150 ms with a small overshoot, settled by ~280 ms;
    // back down through a ~6 % undershoot at ~170 ms and a ~3 % rebound,
    // settled by ~550 ms. Sized by pressGrowth as a button is: 30 px on
    // 100 pt is the reference circle's 1.3×.
    group('press scale spring', () {
      /// The uniform scale the stretch applies to its child.
      double scaleOf(WidgetTester tester) => tester
          .renderObject<RenderBox>(find.byType(SizedBox))
          .getTransformTo(tester.renderObject(find.byType(LiquidStretch)))
          .entry(0, 0);

      Future<List<double>> sample(
        WidgetTester tester, {
        required int untilMs,
      }) async {
        final samples = <double>[];
        for (var ms = 0; ms < untilMs; ms += 10) {
          await tester.pump(const Duration(milliseconds: 10));
          samples.add(scaleOf(tester));
        }
        return samples;
      }

      Future<TestGesture> press(
        WidgetTester tester, {
        double? pressGrowth,
        double interactionScale = 1.0,
      }) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: LiquidStretch(
                interactionScale: interactionScale,
                pressGrowth: pressGrowth,
                stretch: 0,
                child: const SizedBox(width: 100, height: 100),
              ),
            ),
          ),
        );
        final gesture =
            await tester.startGesture(tester.getCenter(find.byType(SizedBox)));
        await tester.pump();
        return gesture;
      }

      testWidgets('inflates quickly with a small overshoot', (tester) async {
        await press(tester, pressGrowth: 30);
        final s = await sample(tester, untilMs: 600);
        // Index i is the value 10·(i+1) ms after touch-down.
        expect(s[14], greaterThan(1.28), reason: 'at 150 ms');
        final peak = s.reduce((a, b) => a > b ? a : b);
        expect(peak, inInclusiveRange(1.302, 1.33), reason: 'overshoot');
        for (var i = 31; i < s.length; i++) {
          expect(s[i], closeTo(1.3, 0.01),
              reason: 'settled at ${10 * (i + 1)} ms');
        }
      });

      testWidgets('release undershoots, rebounds and settles', (tester) async {
        final gesture = await press(tester, pressGrowth: 30);
        await sample(tester, untilMs: 600);
        await gesture.up();
        await tester.pump();
        final s = await sample(tester, untilMs: 800);
        final low = s.reduce((a, b) => a < b ? a : b);
        expect(low, inInclusiveRange(0.94, 0.985), reason: 'undershoot');
        expect(s.indexOf(low), lessThan(22),
            reason: 'undershoot before 220 ms');
        final rebound =
            s.sublist(s.indexOf(low)).reduce((a, b) => a > b ? a : b);
        expect(rebound, greaterThan(1.0), reason: 'rebound past rest');
        for (var i = 59; i < s.length; i++) {
          expect(s[i], closeTo(1.0, 0.01),
              reason: 'settled at ${10 * (i + 1)} ms');
        }
      });

      testWidgets('a fixed factor keeps the critically damped spring',
          (tester) async {
        final gesture = await press(tester, interactionScale: 1.3);
        final pressed = await sample(tester, untilMs: 600);
        expect(pressed.reduce((a, b) => a > b ? a : b), lessThan(1.301),
            reason: 'no overshoot');
        expect(pressed.last, closeTo(1.3, 0.01));
        await gesture.up();
        await tester.pump();
        final released = await sample(tester, untilMs: 800);
        expect(released.reduce((a, b) => a < b ? a : b), greaterThan(0.999),
            reason: 'no undershoot');
        expect(released.last, closeTo(1.0, 0.01));
      });
    });
  });

  group('LiquidStretch.pressGrowth', () {
    Future<TestGesture> press(WidgetTester tester, Size size) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: LiquidStretch(
              pressGrowth: 17,
              stretch: 0,
              child: SizedBox(width: size.width, height: size.height),
            ),
          ),
        ),
      );
      final gesture =
          await tester.startGesture(tester.getCenter(find.byType(SizedBox)));
      await tester.pump();
      return gesture;
    }

    /// The uniform scale RawLiquidStretch applies to its child.
    double scaleOf(WidgetTester tester) {
      final child = tester.renderObject<RenderBox>(find.byType(SizedBox));
      final stretch =
          tester.renderObject<RenderBox>(find.byType(RawLiquidStretch));
      return child.getTransformTo(stretch).entry(0, 0);
    }

    testWidgets('grows the longest side by pressGrowth', (tester) async {
      await press(tester, const Size(132, 44));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(scaleOf(tester), closeTo(1 + 17 / 132, 0.001));
    });

    testWidgets('a circle inflates more than a pill', (tester) async {
      await press(tester, const Size(56, 56));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(scaleOf(tester), closeTo(1 + 17 / 56, 0.001));
    });

    testWidgets('declares itself self-scaled only while below rest',
        (tester) async {
      final gesture = await press(tester, const Size(56, 56));
      bool selfScaled() => tester
          .widget<LiquidGlassSelfScaleScope>(
              find.byType(LiquidGlassSelfScaleScope))
          .selfScaled;

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(selfScaled(), isFalse, reason: 'inflated, not shrunk');

      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 170));
      expect(scaleOf(tester), lessThan(1.0), reason: 'undershoot');
      expect(selfScaled(), isTrue, reason: 'the undershoot is a self-scale');

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(scaleOf(tester), closeTo(1.0, 0.001));
      expect(selfScaled(), isFalse,
          reason:
              'at rest: selfScaled=false; no push-back scope active either, '
              'so _hasScale returns false — no UV freeze, no jitter');
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // RawLiquidStretch widget
  // ──────────────────────────────────────────────────────────────────────────

  group('RawLiquidStretch', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RawLiquidStretch(
            stretchPixels: Offset.zero,
            child: Text('stretch child'),
          ),
        ),
      );
      expect(find.text('stretch child'), findsOneWidget);
    });

    testWidgets('renders with non-zero stretch', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RawLiquidStretch(
            stretchPixels: Offset(10, 5),
            child: SizedBox(width: 80, height: 40, child: Text('stretched')),
          ),
        ),
      );
      expect(find.text('stretched'), findsOneWidget);
    });

    testWidgets('updates stretchPixels without error', (tester) async {
      var pixels = Offset.zero;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Column(
              children: [
                RawLiquidStretch(
                  stretchPixels: pixels,
                  child: const SizedBox(width: 80, height: 40),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => pixels = const Offset(15, 0)),
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Update'));
      await tester.pump();

      expect(find.byType(RawLiquidStretch), findsOneWidget);
    });
  });
}
