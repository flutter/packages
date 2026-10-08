import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  group('GlassThemeSettings', () {
    test('applyTo preserves base settings when override is empty', () {
      const base = LiquidGlassSettings(
        thickness: 10.0,
        blur: 15.0,
        glassColor: Color(0x33FFFFFF),
        lightIntensity: 0.5,
        ambientStrength: 0.2,
      );

      const themeOverride = GlassThemeSettings();
      final merged = themeOverride.applyTo(base);

      expect(merged.thickness, equals(base.thickness));
      expect(merged.blur, equals(base.blur));
      expect(merged.glassColor, equals(base.glassColor));
      expect(merged.lightIntensity, equals(base.lightIntensity));
      expect(merged.ambientStrength, equals(base.ambientStrength));
    });

    test('applyTo overwrites only non-null fields from override', () {
      const base = LiquidGlassSettings(
        thickness: 10.0,
        blur: 15.0,
        glassColor: Color(0x33FFFFFF),
        refractiveIndex: 1.1,
      );

      // Only override thickness and glassColor
      const themeOverride = GlassThemeSettings(
        thickness: 50.0,
        glassColor: Color(0x88FF0000),
      );

      final merged = themeOverride.applyTo(base);

      // Overwritten fields
      expect(merged.thickness, equals(50.0));
      expect(merged.glassColor, equals(const Color(0x88FF0000)));

      // Preserved fields
      expect(merged.blur, equals(15.0));
      expect(merged.refractiveIndex, equals(1.1));
    });

    test('applyTo correctly applies explicit zero values', () {
      const base = LiquidGlassSettings(
        thickness: 20.0,
        blur: 15.0,
        ambientStrength: 10.0,
      );

      const themeOverride = GlassThemeSettings(
        thickness: 0.0, // explicitly zero
        ambientStrength: 0.0, // explicitly zero
      );

      final merged = themeOverride.applyTo(base);

      expect(merged.thickness, equals(0.0));
      expect(merged.ambientStrength, equals(0.0));
      expect(merged.blur, equals(15.0)); // preserved
    });

    test('copyWith only updates specified fields', () {
      const initial = GlassThemeSettings(
        thickness: 30.0,
        blur: 10.0,
      );

      final updated = initial.copyWith(thickness: 50.0);

      expect(updated.thickness, equals(50.0));
      expect(updated.blur, equals(10.0));
    });

    test('equality checks all fields', () {
      const settingsA = GlassThemeSettings(thickness: 30.0, blur: 10.0);
      const settingsB = GlassThemeSettings(thickness: 30.0, blur: 10.0);
      const settingsC = GlassThemeSettings(thickness: 30.0, blur: 15.0);
      const settingsD = GlassThemeSettings(thickness: 30.0);

      expect(settingsA, equals(settingsB));
      expect(settingsA, isNot(equals(settingsC)));
      expect(settingsA, isNot(equals(settingsD)));

      expect(settingsA.hashCode, equals(settingsB.hashCode));
      expect(settingsA.hashCode, isNot(equals(settingsC.hashCode)));
    });
  });
}
