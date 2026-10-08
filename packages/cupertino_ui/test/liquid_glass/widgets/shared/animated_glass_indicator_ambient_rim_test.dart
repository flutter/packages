// AnimatedGlassIndicator: LiquidGlassSettings.ambientRim forwarding.
//
// A caller-provided ambientRim (> 0) must reach the GlassEffect; when unset
// (0), the indicator falls back to its per-path floors (standard/minimal
// 0.08, premium 0.1).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/widgets/shared/glass_effect.dart';

import '../../shared/test_helpers.dart';

Widget _wrap(Widget indicator) => createTestApp(
      child: SizedBox(
        width: 400,
        height: 80,
        child: Stack(children: [indicator]),
      ),
    );

AnimatedGlassIndicator _make({
  LiquidGlassSettings? settings,
  GlassQuality quality = GlassQuality.standard,
}) =>
    AnimatedGlassIndicator(
      velocity: 0.0,
      itemCount: 3,
      alignment: Alignment.center,
      thickness: 0.5, // > 0.01 → glass pass mounts
      quality: quality,
      indicatorColor: Colors.blue,
      isBackgroundIndicator: false,
      borderRadius: 20.0,
      settings: settings,
      pinchStrength: 0.4,
      expansion: const EdgeInsets.all(8.0),
      paintBackground: true,
      paintGlass: true,
      innerBlur: 0.0,
    );

double _effectAmbientRim(WidgetTester tester) =>
    tester.widget<GlassEffect>(find.byType(GlassEffect)).ambientRim;

void main() {
  group('AnimatedGlassIndicator — ambientRim forwarding', () {
    testWidgets('explicit ambientRim reaches GlassEffect (standard)',
        (tester) async {
      await tester.pumpWidget(_wrap(_make(
        settings: const LiquidGlassSettings(ambientRim: 0.3),
      )));
      await tester.pump();
      expect(_effectAmbientRim(tester), 0.3);
    });

    testWidgets('explicit ambientRim reaches GlassEffect (premium)',
        (tester) async {
      await tester.pumpWidget(_wrap(_make(
        settings: const LiquidGlassSettings(ambientRim: 4.0),
        quality: GlassQuality.premium,
      )));
      await tester.pump();
      expect(_effectAmbientRim(tester), 4.0);
    });

    testWidgets('unset ambientRim falls back to the standard-path floor 0.08',
        (tester) async {
      await tester.pumpWidget(_wrap(_make(
        settings: const LiquidGlassSettings(blur: 2), // ambientRim stays 0
      )));
      await tester.pump();
      expect(_effectAmbientRim(tester), 0.08);
    });

    testWidgets('unset ambientRim falls back to the premium floor 0.1',
        (tester) async {
      await tester.pumpWidget(_wrap(_make(
        quality: GlassQuality.premium,
      )));
      await tester.pump();
      expect(_effectAmbientRim(tester), 0.1);
    });

    testWidgets('minimal quality uses the standard-path floor 0.08',
        (tester) async {
      await tester.pumpWidget(_wrap(_make(
        quality: GlassQuality.minimal,
      )));
      await tester.pump();
      expect(_effectAmbientRim(tester), 0.08);
    });
  });
}
