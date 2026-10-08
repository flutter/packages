import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/src/renderer/glass_frost_budget.dart';

// The lightweight shader draws neither the iOS 27 frost nor its rim light, and
// the iOS 27 presets turn the iOS 26 highlight off, so on the standard path
// they came out flat and nearly clear. AdaptiveGlass stands the regular blur
// in for the frost and the highlight for the rim light there.

Future<LiquidGlassSettings> _lightweightSettings(
  WidgetTester tester,
  LiquidGlassSettings settings,
  GlassQuality quality,
) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: LiquidGlassWidgets.wrap(
        child: SizedBox(
          width: 200,
          height: 100,
          child: AdaptiveGlass(
            shape: const LiquidRoundedRectangle(borderRadius: 20),
            settings: settings,
            quality: quality,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    ),
  ));
  return tester
      .widget<LightweightLiquidGlass>(find.byType(LightweightLiquidGlass))
      .settings!;
}

void main() {
  for (final quality in [GlassQuality.standard, GlassQuality.premium]) {
    // In flutter test the premium shader isn't available, so premium takes
    // the lightweight path too, the one a device without Impeller takes.
    testWidgets('ios27Light keeps a blur and a highlight (${quality.name})',
        (tester) async {
      final s = await _lightweightSettings(
        tester,
        LiquidGlassSettings.ios27Light,
        quality,
      );
      expect(
        s.blur,
        greaterThanOrEqualTo(
          LiquidGlassSettings.ios27Light.frost * GlassFrostBudget.blurPerFrost,
        ),
      );
      expect(s.lightIntensity, greaterThan(0));
    });
  }

  testWidgets('settings without the iOS 27 terms pass through', (tester) async {
    const plain = LiquidGlassSettings(blur: 5, lightIntensity: 0.4);
    final s = await _lightweightSettings(tester, plain, GlassQuality.standard);
    expect(s.blur, 5);
    expect(s.lightIntensity, 0.4);
  });
}
