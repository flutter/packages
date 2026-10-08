// ignore_for_file: require_trailing_commas
// Behavior tests for the content-aware brightness system:
//   - GlassContentAwareScope.computeVerdict (WCAG contrast vote, sticky
//     ties, dual-threshold hysteresis, transparent-pixel substitution)
//   - end-to-end capture pipeline (scope + content + consumer) over dark,
//     light, medium and mixed content
//   - the animated cross-fade and the MediaQuery / CupertinoTheme /
//     GlassTheme overrides seen by the consumer subtree
//   - brightnessOverride bypassing the sampler
//   - scroll-aware throttle lifecycle (start / periodic / end / idle)

import 'dart:typed_data';

import 'package:flutter/cupertino.dart' show CupertinoTheme;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Builds a width×1 RGBA image where each pixel is [color] with [alpha].
Uint8List _rowOf(int width, Color color, {int alpha = 255}) {
  final bytes = Uint8List(width * 4);
  final r = ((color.r * 255).round()) & 0xFF;
  final g = ((color.g * 255).round()) & 0xFF;
  final b = ((color.b * 255).round()) & 0xFF;
  for (var x = 0; x < width; x++) {
    bytes[x * 4] = r;
    bytes[x * 4 + 1] = g;
    bytes[x * 4 + 2] = b;
    bytes[x * 4 + 3] = alpha;
  }
  return bytes;
}

List<Rect> _cells(int count) => <Rect>[
      for (var i = 0; i < count; i++) Rect.fromLTWH(i.toDouble(), 0, 1, 1),
    ];

/// Runs one deterministic sample to completion.
///
/// Captures (`toImage`) only complete while the real event loop runs, i.e.
/// inside [WidgetTester.runAsync]. A sample may already be in flight from
/// the registration post-frame callback and would hold the single-flight
/// latch, so let it finish first, then run a fresh sample over the current
/// content.
Future<void> _settleSample(
  WidgetTester tester,
  GlassContentAwareScopeState scope,
) {
  return tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await scope.sampleNow();
  });
}

Brightness _verdict(
  Uint8List rgba,
  int width, {
  Brightness current = Brightness.light,
  double lightToDark = 0.6,
  double darkToLight = 0.6,
  Color background = const Color(0xFFFFFFFF),
  List<Rect>? cells,
}) {
  return GlassContentAwareScope.computeVerdict(
    rgba: rgba,
    width: width,
    height: 1,
    cellRects: cells ?? _cells(width),
    current: current,
    lightToDarkThreshold: lightToDark,
    darkToLightThreshold: darkToLight,
    background: background,
  );
}

void main() {
  group('computeVerdict — contrast vote', () {
    test('dark content flips a light control dark', () {
      final rgba = _rowOf(6, const Color(0xFF000000));
      expect(_verdict(rgba, 6), Brightness.dark);
    });

    test('light content flips a dark control light', () {
      final rgba = _rowOf(6, const Color(0xFFFFFFFF));
      expect(_verdict(rgba, 6, current: Brightness.dark), Brightness.light);
    });

    test('medium content keeps the control light (WCAG vote flips late)', () {
      // Mid-gray (#808080) has WCAG luminance ≈ 0.22 — above the ≈ 0.18
      // contrast crossover, so dark glyphs still read better and the
      // control stays light. This is the vote-not-threshold property.
      final rgba = _rowOf(6, const Color(0xFF808080));
      expect(_verdict(rgba, 6), Brightness.light);
      expect(_verdict(rgba, 6, current: Brightness.dark), Brightness.light);
    });

    test('empty cell list keeps the current appearance', () {
      final rgba = _rowOf(6, const Color(0xFF000000));
      expect(_verdict(rgba, 6, cells: const <Rect>[]), Brightness.light);
      expect(
        _verdict(rgba, 6, cells: const <Rect>[], current: Brightness.dark),
        Brightness.dark,
      );
    });

    test('degenerate image keeps the current appearance', () {
      expect(
        GlassContentAwareScope.computeVerdict(
          rgba: Uint8List(0),
          width: 0,
          height: 0,
          cellRects: _cells(1),
          current: Brightness.dark,
          lightToDarkThreshold: 0.6,
          darkToLightThreshold: 0.6,
          background: const Color(0xFFFFFFFF),
        ),
        Brightness.dark,
      );
    });
  });

  group('computeVerdict — transparent-pixel substitution', () {
    test('unpainted pixels read as a light background', () {
      final rgba = _rowOf(6, const Color(0xFF000000), alpha: 0);
      expect(
        _verdict(rgba, 6,
            current: Brightness.dark, background: const Color(0xFFFFFFFF)),
        Brightness.light,
      );
    });

    test('unpainted pixels read as a dark background', () {
      final rgba = _rowOf(6, const Color(0xFFFFFFFF), alpha: 0);
      expect(
        _verdict(rgba, 6, background: const Color(0xFF000000)),
        Brightness.dark,
      );
    });
  });

  group('computeVerdict — sticky ties and hysteresis', () {
    test('a 50/50 split keeps the current appearance in both directions', () {
      // 3 black + 3 white pixels — a tie under any threshold > 0.5.
      final rgba = Uint8List.fromList([
        ..._rowOf(3, const Color(0xFF000000)),
        ..._rowOf(3, const Color(0xFFFFFFFF)),
      ]);
      expect(_verdict(rgba, 6), Brightness.light);
      expect(_verdict(rgba, 6, current: Brightness.dark), Brightness.dark);
    });

    test('a strict majority below the threshold does not flip', () {
      // 4 of 6 dark votes = 0.67 — flips at 0.6 but not at 0.7. The same
      // content therefore keeps whichever appearance is current when the
      // threshold is raised: dual-threshold hysteresis.
      final rgba = Uint8List.fromList([
        ..._rowOf(4, const Color(0xFF000000)),
        ..._rowOf(2, const Color(0xFFFFFFFF)),
      ]);
      expect(_verdict(rgba, 6, lightToDark: 0.6), Brightness.dark);
      expect(_verdict(rgba, 6, lightToDark: 0.7), Brightness.light);
    });

    test('asymmetric thresholds gate each direction independently', () {
      // 4 of 6 light votes = 0.67.
      final lightish = Uint8List.fromList([
        ..._rowOf(4, const Color(0xFFFFFFFF)),
        ..._rowOf(2, const Color(0xFF000000)),
      ]);
      expect(
        _verdict(lightish, 6, current: Brightness.dark, darkToLight: 0.6),
        Brightness.light,
      );
      expect(
        _verdict(lightish, 6, current: Brightness.dark, darkToLight: 0.7),
        Brightness.dark,
      );
    });
  });

  group('end-to-end sampling pipeline', () {
    Widget pipeline({
      required Widget content,
      ValueChanged<Brightness>? onBrightnessChanged,
      GlassBrightnessWidgetBuilder? builder,
      Duration sampleInterval = const Duration(milliseconds: 180),
    }) {
      return MaterialApp(
        home: GlassContentAwareScope(
          sampleInterval: sampleInterval,
          child: Stack(
            children: [
              Positioned.fill(
                child: GlassContentAwareContent(child: content),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 80,
                child: GlassContentAwareBrightness(
                  onBrightnessChanged: onBrightnessChanged,
                  builder: builder ??
                      (context, brightness, darkAmount) =>
                          const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    testWidgets('dark content flips the control dark and cross-fades',
        (tester) async {
      final flips = <Brightness>[];
      Brightness? builtBrightness;
      double? builtDarkAmount;
      Brightness? innerPlatformBrightness;
      Brightness? innerCupertinoBrightness;

      await tester.pumpWidget(pipeline(
        content: const ColoredBox(color: Color(0xFF000000)),
        onBrightnessChanged: flips.add,
        builder: (context, brightness, darkAmount) {
          builtBrightness = brightness;
          builtDarkAmount = darkAmount;
          innerPlatformBrightness = MediaQuery.platformBrightnessOf(context);
          innerCupertinoBrightness = CupertinoTheme.of(context).brightness;
          return const SizedBox.expand();
        },
      ));
      expect(builtBrightness, Brightness.light);
      expect(builtDarkAmount, 0.0);
      expect(innerPlatformBrightness, Brightness.light);

      final scopeState = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));
      await _settleSample(tester, scopeState);
      await tester.pump();

      // Verdict committed immediately; the visual fade is in flight.
      expect(flips, [Brightness.dark]);
      expect(builtBrightness, Brightness.dark);

      // Mid-fade: darkAmount strictly between the endpoints.
      await tester.pump(const Duration(milliseconds: 100));
      expect(builtDarkAmount, greaterThan(0.0));
      expect(builtDarkAmount, lessThan(1.0));
      // Past the midpoint the discrete ambient flips dark.
      expect(innerPlatformBrightness, Brightness.dark);
      expect(innerCupertinoBrightness, Brightness.dark);

      await tester.pump(const Duration(milliseconds: 150));
      expect(builtDarkAmount, 1.0);

      // A second sample over the same content does not re-fire.
      await _settleSample(tester, scopeState);
      await tester.pump();
      expect(flips, [Brightness.dark]);
    });

    testWidgets('light content keeps the control light — no flip events',
        (tester) async {
      final flips = <Brightness>[];
      await tester.pumpWidget(pipeline(
        content: const ColoredBox(color: Color(0xFFFFFFFF)),
        onBrightnessChanged: flips.add,
      ));
      final scopeState = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));
      await _settleSample(tester, scopeState);
      await tester.pump();
      expect(flips, isEmpty);
    });

    testWidgets('half-and-half content is sticky in both directions',
        (tester) async {
      final flips = <Brightness>[];
      await tester.pumpWidget(pipeline(
        content: const Row(children: [
          Expanded(child: ColoredBox(color: Color(0xFF000000))),
          Expanded(child: ColoredBox(color: Color(0xFFFFFFFF))),
        ]),
        onBrightnessChanged: flips.add,
      ));
      final scopeState = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));
      await _settleSample(tester, scopeState);
      await tester.pump();
      expect(flips, isEmpty);
    });

    testWidgets('lerped GlassTheme is served to the consumer subtree',
        (tester) async {
      GlassThemeData? innerTheme;
      await tester.pumpWidget(pipeline(
        content: const ColoredBox(color: Color(0xFF000000)),
        builder: (context, brightness, darkAmount) {
          innerTheme = GlassThemeData.of(context);
          return const SizedBox.expand();
        },
      ));
      final scopeState = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));

      // At rest (light), both slots of the synthetic data hold the light
      // variant, so variant resolution is brightness-independent.
      expect(innerTheme!.light, GlassThemeVariant.light);
      expect(innerTheme!.dark, GlassThemeVariant.light);

      await _settleSample(tester, scopeState);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // Mid-fade: thickness sits strictly between dark (10) and light (12).
      final midThickness = innerTheme!.light.settings!.thickness!;
      expect(midThickness, lessThan(12.0));
      expect(midThickness, greaterThan(10.0));

      await tester.pump(const Duration(milliseconds: 150));
      expect(innerTheme!.light, GlassThemeVariant.dark);
      expect(innerTheme!.dark, GlassThemeVariant.dark);
    });

    testWidgets('scroll notifications drive the sampler lifecycle',
        (tester) async {
      final flips = <Brightness>[];
      await tester.pumpWidget(MaterialApp(
        home: GlassContentAwareScope(
          child: Stack(
            children: [
              Positioned.fill(
                child: GlassContentAwareContent(
                  child: ListView(
                    children: [
                      Container(height: 600, color: const Color(0xFFFFFFFF)),
                      Container(height: 2000, color: const Color(0xFF000000)),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 80,
                child: GlassContentAwareBrightness(
                  onBrightnessChanged: flips.add,
                  builder: (context, brightness, darkAmount) =>
                      const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      ));
      final scopeState = tester.state<GlassContentAwareScopeState>(
          find.byType(GlassContentAwareScope));

      // Idle: no periodic sampler.
      expect(scopeState.isScrollSamplingActive, isFalse);

      // A drag starts the periodic sampler...
      final gesture = await tester.startGesture(const Offset(200, 300));
      await gesture.moveBy(const Offset(0, -50));
      await tester.pump();
      expect(scopeState.isScrollSamplingActive, isTrue);

      // ...and releasing ends scrolling, returning the sampler to idle.
      await gesture.up();
      await tester.pumpAndSettle();
      expect(scopeState.isScrollSamplingActive, isFalse);

      // The scrolled-down content is now dark behind the control; a manual
      // settle-sample (the trailing sample's payload) flips it.
      await tester.drag(find.byType(ListView), const Offset(0, -1200));
      await tester.pumpAndSettle();
      await _settleSample(tester, scopeState);
      await tester.pump();
      expect(flips, [Brightness.dark]);
      await tester.pumpAndSettle();
    });
  });

  group('GlassContentAwareBrightness — brightnessOverride', () {
    testWidgets('follows the listenable and bypasses the scope',
        (tester) async {
      final override = ValueNotifier<Brightness>(Brightness.light);
      addTearDown(override.dispose);
      final flips = <Brightness>[];
      Brightness? builtBrightness;
      double? builtDarkAmount;

      await tester.pumpWidget(MaterialApp(
        home: GlassContentAwareScope(
          child: GlassContentAwareBrightness(
            brightnessOverride: override,
            onBrightnessChanged: flips.add,
            builder: (context, brightness, darkAmount) {
              builtBrightness = brightness;
              builtDarkAmount = darkAmount;
              return const SizedBox.expand();
            },
          ),
        ),
      ));
      expect(builtBrightness, Brightness.light);

      override.value = Brightness.dark;
      await tester.pump();
      expect(flips, [Brightness.dark]);
      expect(builtBrightness, Brightness.dark);
      await tester.pump(const Duration(milliseconds: 250));
      expect(builtDarkAmount, 1.0);

      override.value = Brightness.light;
      await tester.pump();
      expect(flips, [Brightness.dark, Brightness.light]);
      await tester.pump(const Duration(milliseconds: 250));
      expect(builtDarkAmount, 0.0);
    });

    testWidgets('an initially-dark override starts dark with no animation',
        (tester) async {
      final override = ValueNotifier<Brightness>(Brightness.dark);
      addTearDown(override.dispose);
      final flips = <Brightness>[];
      double? builtDarkAmount;
      await tester.pumpWidget(MaterialApp(
        home: GlassContentAwareBrightness(
          brightnessOverride: override,
          onBrightnessChanged: flips.add,
          builder: (context, brightness, darkAmount) {
            builtDarkAmount = darkAmount;
            return const SizedBox.expand();
          },
        ),
      ));
      expect(builtDarkAmount, 1.0);
      expect(flips, isEmpty);
    });
  });

  group('GlassContentAwareBrightness — no scope, no override', () {
    testWidgets('follows the ambient platform brightness', (tester) async {
      Brightness? builtBrightness;
      double? builtDarkAmount;
      Widget app(Brightness platform) => MediaQuery(
            data: MediaQueryData(platformBrightness: platform),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: GlassContentAwareBrightness(
                builder: (context, brightness, darkAmount) {
                  builtBrightness = brightness;
                  builtDarkAmount = darkAmount;
                  return const SizedBox.expand();
                },
              ),
            ),
          );

      await tester.pumpWidget(app(Brightness.dark));
      expect(builtBrightness, Brightness.dark);
      expect(builtDarkAmount, 1.0);

      // Ambient flip re-anchors the verdict (animated).
      await tester.pumpWidget(app(Brightness.light));
      await tester.pump(const Duration(milliseconds: 250));
      expect(builtBrightness, Brightness.light);
      expect(builtDarkAmount, 0.0);
    });
  });
}
