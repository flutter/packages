// ignore_for_file: require_trailing_commas
// Unit tests for the theme variant interpolation used by the content-aware
// brightness cross-fade:
//   - GlassThemeSettings.lerp (smooth lerp / midpoint switch / null rules)
//   - GlassGlowColors.lerp
//   - GlassThemeVariant.lerp (delegation, quality + borderRadius rules)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  group('GlassThemeSettings.lerp', () {
    test('identical instances short-circuit', () {
      const a = GlassThemeSettings(thickness: 10);
      expect(GlassThemeSettings.lerp(a, a, 0.3), same(a));
      expect(GlassThemeSettings.lerp(null, null, 0.3), isNull);
    });

    test('one side null switches at the midpoint', () {
      const b = GlassThemeSettings(thickness: 10);
      expect(GlassThemeSettings.lerp(null, b, 0.49), isNull);
      expect(GlassThemeSettings.lerp(null, b, 0.5), same(b));
      expect(GlassThemeSettings.lerp(b, null, 0.49), same(b));
      expect(GlassThemeSettings.lerp(b, null, 0.5), isNull);
    });

    test('both-non-null fields interpolate smoothly', () {
      const a = GlassThemeSettings(
        visibility: 0.0,
        glassColor: Color(0xFF000000),
        thickness: 10.0,
        blur: 2.0,
        chromaticAberration: 0.0,
        lightAngle: 0.0,
        lightIntensity: 0.5,
        ambientStrength: 0.0,
        refractiveIndex: 1.0,
        saturation: 1.0,
        specularSharpness: GlassSpecularSharpness.soft,
      );
      const b = GlassThemeSettings(
        visibility: 1.0,
        glassColor: Color(0xFFFFFFFF),
        thickness: 30.0,
        blur: 6.0,
        chromaticAberration: 1.0,
        lightAngle: 2.0,
        lightIntensity: 1.0,
        ambientStrength: 0.4,
        refractiveIndex: 2.0,
        saturation: 2.0,
        specularSharpness: GlassSpecularSharpness.sharp,
      );
      final mid = GlassThemeSettings.lerp(a, b, 0.5)!;
      expect(mid.visibility, closeTo(0.5, 1e-9));
      expect(mid.thickness, closeTo(20.0, 1e-9));
      expect(mid.blur, closeTo(4.0, 1e-9));
      expect(mid.chromaticAberration, closeTo(0.5, 1e-9));
      expect(mid.lightAngle, closeTo(1.0, 1e-9));
      expect(mid.lightIntensity, closeTo(0.75, 1e-9));
      expect(mid.ambientStrength, closeTo(0.2, 1e-9));
      expect(mid.refractiveIndex, closeTo(1.5, 1e-9));
      expect(mid.saturation, closeTo(1.5, 1e-9));
      expect(mid.glassColor, Color.lerp(a.glassColor, b.glassColor, 0.5));
      // Discrete enum: midpoint switch.
      expect(mid.specularSharpness, GlassSpecularSharpness.sharp);
      expect(
        GlassThemeSettings.lerp(a, b, 0.49)!.specularSharpness,
        GlassSpecularSharpness.soft,
      );
    });

    test('one-sided null fields switch at the midpoint, not through zero', () {
      const a = GlassThemeSettings(thickness: 30.0);
      const b = GlassThemeSettings(blur: 6.0);
      final early = GlassThemeSettings.lerp(a, b, 0.25)!;
      expect(early.thickness, 30.0);
      expect(early.blur, isNull);
      expect(early.glassColor, isNull);
      final late_ = GlassThemeSettings.lerp(a, b, 0.75)!;
      expect(late_.thickness, isNull);
      expect(late_.blur, 6.0);
    });

    test('one-sided null color switches at the midpoint', () {
      const a = GlassThemeSettings(glassColor: Color(0xFF112233));
      const b = GlassThemeSettings();
      expect(GlassThemeSettings.lerp(a, b, 0.2)!.glassColor, a.glassColor);
      expect(GlassThemeSettings.lerp(a, b, 0.8)!.glassColor, isNull);
    });

    test('endpoints reproduce the inputs', () {
      const a = GlassThemeSettings(thickness: 12.0, blur: 5.0);
      const b = GlassThemeSettings(thickness: 10.0, blur: 4.0);
      final at0 = GlassThemeSettings.lerp(a, b, 0.0)!;
      final at1 = GlassThemeSettings.lerp(a, b, 1.0)!;
      expect(at0, a);
      expect(at1, b);
    });
  });

  group('GlassGlowColors.lerp', () {
    test('identical instances short-circuit', () {
      const a = GlassGlowColors.fallback;
      expect(GlassGlowColors.lerp(a, a, 0.4), same(a));
      expect(GlassGlowColors.lerp(null, null, 0.4), isNull);
    });

    test('one side null switches at the midpoint', () {
      const b = GlassGlowColors.fallback;
      expect(GlassGlowColors.lerp(null, b, 0.4), isNull);
      expect(GlassGlowColors.lerp(null, b, 0.6), same(b));
      expect(GlassGlowColors.lerp(b, null, 0.4), same(b));
      expect(GlassGlowColors.lerp(b, null, 0.6), isNull);
    });

    test('color fields lerp when set on both sides', () {
      const a = GlassGlowColors(
        primary: Color(0xFF000000),
        secondary: Color(0xFF000000),
        success: Color(0xFF000000),
        warning: Color(0xFF000000),
        danger: Color(0xFF000000),
        info: Color(0xFF000000),
        glowBlurRadius: 0.0,
        glowSpreadRadius: 0.0,
        glowOpacity: 0.0,
      );
      const b = GlassGlowColors(
        primary: Color(0xFFFFFFFF),
        secondary: Color(0xFFFFFFFF),
        success: Color(0xFFFFFFFF),
        warning: Color(0xFFFFFFFF),
        danger: Color(0xFFFFFFFF),
        info: Color(0xFFFFFFFF),
        glowBlurRadius: 8.0,
        glowSpreadRadius: 2.0,
        glowOpacity: 1.0,
      );
      final mid = GlassGlowColors.lerp(a, b, 0.5)!;
      final expected =
          Color.lerp(const Color(0xFF000000), const Color(0xFFFFFFFF), 0.5);
      expect(mid.primary, expected);
      expect(mid.secondary, expected);
      expect(mid.success, expected);
      expect(mid.warning, expected);
      expect(mid.danger, expected);
      expect(mid.info, expected);
      expect(mid.glowBlurRadius, closeTo(4.0, 1e-9));
      expect(mid.glowSpreadRadius, closeTo(1.0, 1e-9));
      expect(mid.glowOpacity, closeTo(0.5, 1e-9));
    });

    test('runtime-resolved (null) primary switches at the midpoint', () {
      // GlassGlowColors.fallback has primary == null ("resolve at runtime").
      const a = GlassGlowColors.fallback;
      const b = GlassGlowColors(primary: Color(0xFF123456));
      expect(GlassGlowColors.lerp(a, b, 0.3)!.primary, isNull);
      expect(GlassGlowColors.lerp(a, b, 0.7)!.primary, const Color(0xFF123456));
      // Scalars still interpolate even when colors switch discretely.
      expect(GlassGlowColors.lerp(a, b, 0.3)!.glowBlurRadius,
          closeTo(0.7 * a.glowBlurRadius + 0.3 * b.glowBlurRadius, 1e-9));
    });
  });

  group('GlassThemeVariant.lerp', () {
    test('identical instances short-circuit', () {
      const a = GlassThemeVariant.light;
      expect(GlassThemeVariant.lerp(a, a, 0.4), same(a));
    });

    test('delegates settings and glowColors, switches quality at midpoint', () {
      const a = GlassThemeVariant(
        settings: GlassThemeSettings(thickness: 12.0),
        quality: GlassQuality.standard,
        glowColors: GlassGlowColors(glowOpacity: 0.0),
        borderRadius: 10.0,
      );
      const b = GlassThemeVariant(
        settings: GlassThemeSettings(thickness: 10.0),
        quality: GlassQuality.premium,
        glowColors: GlassGlowColors(glowOpacity: 1.0),
        borderRadius: 30.0,
      );
      final early = GlassThemeVariant.lerp(a, b, 0.25);
      expect(early.settings!.thickness, closeTo(11.5, 1e-9));
      expect(early.quality, GlassQuality.standard);
      expect(early.glowColors!.glowOpacity, closeTo(0.25, 1e-9));
      expect(early.borderRadius, closeTo(15.0, 1e-9));
      final late_ = GlassThemeVariant.lerp(a, b, 0.75);
      expect(late_.quality, GlassQuality.premium);
      expect(late_.borderRadius, closeTo(25.0, 1e-9));
    });

    test('one-sided borderRadius switches at the midpoint', () {
      const a = GlassThemeVariant(borderRadius: 12.0);
      const b = GlassThemeVariant();
      expect(GlassThemeVariant.lerp(a, b, 0.2).borderRadius, 12.0);
      expect(GlassThemeVariant.lerp(a, b, 0.8).borderRadius, isNull);
    });

    test('lerping the built-in light and dark variants is well-formed', () {
      final mid = GlassThemeVariant.lerp(
          GlassThemeVariant.light, GlassThemeVariant.dark, 0.5);
      expect(mid.settings!.thickness, closeTo(11.0, 1e-9));
      expect(mid.settings!.blur, closeTo(4.5, 1e-9));
      expect(mid.quality, isNull);
      expect(mid.glowColors, isNotNull);
      // Endpoints reproduce the variants' settings exactly.
      expect(
        GlassThemeVariant.lerp(
                GlassThemeVariant.light, GlassThemeVariant.dark, 0.0)
            .settings,
        GlassThemeVariant.light.settings,
      );
      expect(
        GlassThemeVariant.lerp(
                GlassThemeVariant.light, GlassThemeVariant.dark, 1.0)
            .settings,
        GlassThemeVariant.dark.settings,
      );
    });
  });
}
