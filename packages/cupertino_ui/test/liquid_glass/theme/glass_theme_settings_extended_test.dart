import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Extended unit tests for [GlassThemeSettings].
/// The basic applyTo / copyWith / equality tests live in
/// glass_theme_settings_test.dart — this file covers every individual field
/// and edge cases not covered there.
void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // applyTo — each field individually
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassThemeSettings.applyTo — each field overrides independently', () {
    const base = LiquidGlassSettings(
      visibility: 0.9,
      glassColor: Color(0x10FFFFFF),
      thickness: 10.0,
      blur: 4.0,
      chromaticAberration: 0.1,
      lightAngle: 1.0,
      lightIntensity: 0.4,
      ambientStrength: 0.15,
      refractiveIndex: 1.1,
      saturation: 1.3,
      specularSharpness: GlassSpecularSharpness.soft,
    );

    test('visibility override', () {
      final merged = const GlassThemeSettings(visibility: 0.5).applyTo(base);
      expect(merged.visibility, 0.5);
      expect(merged.thickness, base.thickness);
    });

    test('glassColor override', () {
      final merged = const GlassThemeSettings(
        glassColor: Color(0xFF0000FF),
      ).applyTo(base);
      expect(merged.glassColor, const Color(0xFF0000FF));
      expect(merged.blur, base.blur);
    });

    test('thickness override', () {
      final merged = const GlassThemeSettings(thickness: 99.0).applyTo(base);
      expect(merged.thickness, 99.0);
      expect(merged.blur, base.blur);
    });

    test('blur override', () {
      final merged = const GlassThemeSettings(blur: 20.0).applyTo(base);
      expect(merged.blur, 20.0);
      expect(merged.thickness, base.thickness);
    });

    test('chromaticAberration override', () {
      final merged =
          const GlassThemeSettings(chromaticAberration: 3.0).applyTo(base);
      expect(merged.chromaticAberration, 3.0);
      expect(merged.blur, base.blur);
    });

    test('lightAngle override', () {
      final merged = const GlassThemeSettings(lightAngle: 2.5).applyTo(base);
      expect(merged.lightAngle, 2.5);
    });

    test('lightIntensity override', () {
      final merged =
          const GlassThemeSettings(lightIntensity: 0.8).applyTo(base);
      expect(merged.lightIntensity, 0.8);
    });

    test('ambientStrength override', () {
      final merged =
          const GlassThemeSettings(ambientStrength: 0.7).applyTo(base);
      expect(merged.ambientStrength, 0.7);
    });

    test('refractiveIndex override', () {
      final merged =
          const GlassThemeSettings(refractiveIndex: 1.5).applyTo(base);
      expect(merged.refractiveIndex, 1.5);
    });

    test('saturation override', () {
      final merged = const GlassThemeSettings(saturation: 2.0).applyTo(base);
      expect(merged.saturation, 2.0);
    });

    test('specularSharpness override', () {
      final merged = const GlassThemeSettings(
        specularSharpness: GlassSpecularSharpness.sharp,
      ).applyTo(base);
      expect(merged.specularSharpness, GlassSpecularSharpness.sharp);
    });

    test('fresnelStrength override', () {
      final merged =
          const GlassThemeSettings(fresnelStrength: 0.45).applyTo(base);
      expect(merged.fresnelStrength, 0.45);
      expect(merged.blur, base.blur);
    });

    test('edgeAbsorption override', () {
      final merged = const GlassThemeSettings(
        edgeAbsorption: 0.25,
      ).applyTo(base);
      expect(merged.edgeAbsorption, 0.25);
      expect(merged.blur, base.blur);
    });
  });

  group('GlassThemeSettings.applyTo — all fields override simultaneously', () {
    test('all fields replaced', () {
      const base = LiquidGlassSettings();
      const override = GlassThemeSettings(
        visibility: 0.3,
        glassColor: Color(0xFF123456),
        thickness: 77.0,
        blur: 9.0,
        chromaticAberration: 2.0,
        lightAngle: 3.0,
        lightIntensity: 1.5,
        ambientStrength: 0.9,
        fresnelStrength: 0.85,
        refractiveIndex: 1.6,
        saturation: 1.8,
        specularSharpness: GlassSpecularSharpness.medium,
        edgeAbsorption: 0.3,
      );
      final merged = override.applyTo(base);

      expect(merged.visibility, 0.3);
      expect(merged.glassColor, const Color(0xFF123456));
      expect(merged.thickness, 77.0);
      expect(merged.blur, 9.0);
      expect(merged.chromaticAberration, 2.0);
      expect(merged.lightAngle, 3.0);
      expect(merged.lightIntensity, 1.5);
      expect(merged.ambientStrength, 0.9);
      expect(merged.fresnelStrength, 0.85);
      expect(merged.refractiveIndex, 1.6);
      expect(merged.saturation, 1.8);
      expect(merged.specularSharpness, GlassSpecularSharpness.medium);
      expect(merged.edgeAbsorption, 0.3);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // copyWith — each field individually
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassThemeSettings.copyWith', () {
    const original = GlassThemeSettings(
      visibility: 0.8,
      glassColor: Color(0x20FFFFFF),
      thickness: 30.0,
      blur: 5.0,
      chromaticAberration: 0.4,
      lightAngle: 1.2,
      lightIntensity: 0.6,
      ambientStrength: 0.3,
      refractiveIndex: 1.4,
      saturation: 1.5,
      specularSharpness: GlassSpecularSharpness.soft,
    );

    test('copy with no changes equals original', () {
      expect(original.copyWith(), equals(original));
    });

    test('copyWith visibility', () {
      final copy = original.copyWith(visibility: 0.1);
      expect(copy.visibility, 0.1);
      expect(copy.thickness, original.thickness);
    });

    test('copyWith glassColor', () {
      final copy = original.copyWith(glassColor: const Color(0xFF000000));
      expect(copy.glassColor, const Color(0xFF000000));
      expect(copy.blur, original.blur);
    });

    test('copyWith thickness', () {
      final copy = original.copyWith(thickness: 55.0);
      expect(copy.thickness, 55.0);
      expect(copy.blur, original.blur);
    });

    test('copyWith blur', () {
      final copy = original.copyWith(blur: 12.0);
      expect(copy.blur, 12.0);
      expect(copy.thickness, original.thickness);
    });

    test('copyWith chromaticAberration', () {
      final copy = original.copyWith(chromaticAberration: 1.0);
      expect(copy.chromaticAberration, 1.0);
    });

    test('copyWith lightAngle', () {
      final copy = original.copyWith(lightAngle: 2.0);
      expect(copy.lightAngle, 2.0);
    });

    test('copyWith lightIntensity', () {
      final copy = original.copyWith(lightIntensity: 0.9);
      expect(copy.lightIntensity, 0.9);
    });

    test('copyWith ambientStrength', () {
      final copy = original.copyWith(ambientStrength: 0.5);
      expect(copy.ambientStrength, 0.5);
    });

    test('copyWith fresnelStrength', () {
      final copy = original.copyWith(fresnelStrength: 0.45);
      expect(copy.fresnelStrength, 0.45);
    });

    test('copyWith refractiveIndex', () {
      final copy = original.copyWith(refractiveIndex: 1.7);
      expect(copy.refractiveIndex, 1.7);
    });

    test('copyWith saturation', () {
      final copy = original.copyWith(saturation: 2.0);
      expect(copy.saturation, 2.0);
    });

    test('copyWith specularSharpness', () {
      final copy = original.copyWith(
        specularSharpness: GlassSpecularSharpness.sharp,
      );
      expect(copy.specularSharpness, GlassSpecularSharpness.sharp);
    });

    test('copyWith edgeAbsorption', () {
      final copy = original.copyWith(edgeAbsorption: 0.35);
      expect(copy.edgeAbsorption, 0.35);
    });

    test('copyWith multiple fields', () {
      final copy = original.copyWith(thickness: 100.0, blur: 10.0);
      expect(copy.thickness, 100.0);
      expect(copy.blur, 10.0);
      expect(copy.refractiveIndex, original.refractiveIndex);
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // Equality and hashCode
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassThemeSettings equality and hashCode', () {
    test('identical instances are equal', () {
      const a = GlassThemeSettings(thickness: 30.0, blur: 5.0);
      const b = GlassThemeSettings(thickness: 30.0, blur: 5.0);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('empty instances are equal', () {
      const a = GlassThemeSettings();
      const b = GlassThemeSettings();
      expect(a, equals(b));
    });

    test('differing in any field are not equal', () {
      const base =
          GlassThemeSettings(thickness: 30.0, blur: 5.0, saturation: 1.2);
      expect(base, isNot(equals(base.copyWith(thickness: 31.0))));
      expect(base, isNot(equals(base.copyWith(blur: 6.0))));
      expect(base, isNot(equals(base.copyWith(saturation: 1.3))));
      expect(base, isNot(equals(base.copyWith(visibility: 0.5))));
      expect(base, isNot(equals(base.copyWith(lightIntensity: 0.9))));
    });

    test('hashCode differs when fields differ', () {
      const a = GlassThemeSettings(thickness: 10.0);
      const b = GlassThemeSettings(thickness: 20.0);
      // Hash collisions are theoretically possible but extremely unlikely here.
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // toString
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassThemeSettings.toString', () {
    test('includes field names', () {
      const s = GlassThemeSettings(thickness: 42.0, blur: 7.0);
      final str = s.toString();
      expect(str, contains('thickness'));
      expect(str, contains('blur'));
    });

    test('includes type name', () {
      const s = GlassThemeSettings();
      expect(s.toString(), contains('GlassThemeSettings'));
    });
  });
}
