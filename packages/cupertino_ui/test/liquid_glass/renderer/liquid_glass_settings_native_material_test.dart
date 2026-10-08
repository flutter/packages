// Tests for the iOS 27 material settings on LiquidGlassSettings — frost,
// frostOpacity, frostClamp, frostWeight, blurWeight, rimShade, rimShadeEnds,
// rimLight, bodyShade and lensModel: defaults that leave rendering stock, copyWith,
// lerp, equality, preservation through copyWithPinch and a theme override,
// the matching GlassThemeSettings overrides, and the ios27Light / ios27Dark
// presets.

import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/src/engine/liquid_glass_settings.dart';
import 'package:liquid_glass_widgets/theme/glass_theme_settings.dart';

void main() {
  const tuned = LiquidGlassSettings(
    frost: 14,
    frostOpacity: 0.73,
    frostClamp: 0.4,
    frostWeight: 2,
    blurWeight: 0.8,
    rimShade: 1,
    rimShadeEnds: 0.1,
    rimLight: 1.15,
    bodyShade: 0.28,
    lensModel: GlassLensModel.paraxial,
  );

  void expectTuned(LiquidGlassSettings s) {
    expect(s.frost, 14);
    expect(s.frostOpacity, 0.73);
    expect(s.frostClamp, 0.4);
    expect(s.frostWeight, 2);
    expect(s.blurWeight, 0.8);
    expect(s.rimShade, 1);
    expect(s.rimShadeEnds, 0.1);
    expect(s.rimLight, 1.15);
    expect(s.bodyShade, 0.28);
    expect(s.lensModel, GlassLensModel.paraxial);
  }

  group('LiquidGlassSettings iOS 27 material', () {
    test('defaults leave the existing rendering untouched', () {
      const s = LiquidGlassSettings();
      expect(s.frost, 0);
      expect(s.frostOpacity, 1);
      expect(s.frostClamp, 0);
      expect(s.frostWeight, 1);
      expect(s.blurWeight, 1);
      expect(s.rimShade, 0);
      expect(s.rimShadeEnds, 0.2);
      expect(s.rimLight, 0);
      expect(s.bodyShade, 0);
      expect(s.lensModel, GlassLensModel.spherical);
    });

    test('effective values scale with visibility', () {
      final s = tuned.copyWith(visibility: 0.5);
      expect(s.effectiveFrost, 7);
      expect(s.effectiveRimShade, 0.5);
      expect(s.effectiveRimLight, closeTo(0.575, 1e-10));
      expect(s.effectiveBodyShade, closeTo(0.14, 1e-10));
    });

    group('copyWith', () {
      test('no-arg copyWith preserves every field', () {
        expectTuned(tuned.copyWith());
      });

      test('copyWith of another field preserves them', () {
        expectTuned(tuned.copyWith(blur: 9));
      });

      test('copyWith replaces each field', () {
        final s = const LiquidGlassSettings().copyWith(
          frost: 14,
          frostOpacity: 0.73,
          frostClamp: 0.4,
          frostWeight: 2,
          blurWeight: 0.8,
          rimShade: 1,
          rimShadeEnds: 0.1,
          rimLight: 1.15,
          bodyShade: 0.28,
          lensModel: GlassLensModel.paraxial,
        );
        expectTuned(s);
      });
    });

    group('lerp', () {
      const a = LiquidGlassSettings();

      test('t=0 → a, t=1 → b', () {
        expect(LiquidGlassSettings.lerp(a, tuned, 0), equals(a));
        expectTuned(LiquidGlassSettings.lerp(a, tuned, 1));
      });

      test('t=0.5 interpolates the numbers', () {
        final s = LiquidGlassSettings.lerp(a, tuned, 0.5);
        expect(s.frost, closeTo(7, 1e-10));
        expect(s.frostOpacity, closeTo(0.865, 1e-10));
        expect(s.frostClamp, closeTo(0.2, 1e-10));
        expect(s.frostWeight, closeTo(1.5, 1e-10));
        expect(s.blurWeight, closeTo(0.9, 1e-10));
        expect(s.rimShade, closeTo(0.5, 1e-10));
        expect(s.rimShadeEnds, closeTo(0.15, 1e-10));
        expect(s.rimLight, closeTo(0.575, 1e-10));
        expect(s.bodyShade, closeTo(0.14, 1e-10));
      });

      test('lensModel switches at the midpoint', () {
        expect(LiquidGlassSettings.lerp(a, tuned, 0.49).lensModel,
            GlassLensModel.spherical);
        expect(LiquidGlassSettings.lerp(a, tuned, 0.5).lensModel,
            GlassLensModel.paraxial);
      });
    });

    group('equality', () {
      test('each field takes part in == and hashCode', () {
        final variants = [
          tuned.copyWith(frost: 13),
          tuned.copyWith(frostOpacity: 0.7),
          tuned.copyWith(frostClamp: -0.4),
          tuned.copyWith(frostWeight: 0.5),
          tuned.copyWith(blurWeight: 2.5),
          tuned.copyWith(rimShade: 0.45),
          tuned.copyWith(rimShadeEnds: 0),
          tuned.copyWith(rimLight: 1),
          tuned.copyWith(bodyShade: 0),
          tuned.copyWith(lensModel: GlassLensModel.spherical),
        ];
        for (final v in variants) {
          expect(v, isNot(equals(tuned)));
        }
        expect(tuned.copyWith(), equals(tuned));
        expect(tuned.copyWith().hashCode, tuned.hashCode);
      });
    });

    test('copyWithPinch preserves every field', () {
      expectTuned(tuned.copyWithPinch(0.6));
    });

    test('a theme override preserves every field of its base', () {
      expectTuned(const GlassThemeSettings(blur: 3).applyTo(tuned));
    });
  });

  group('GlassThemeSettings iOS 27 material', () {
    const theme = GlassThemeSettings(
      frost: 14,
      frostOpacity: 0.73,
      frostClamp: 0.4,
      frostWeight: 2,
      blurWeight: 0.8,
      rimShade: 1,
      rimShadeEnds: 0.1,
      rimLight: 1.15,
      bodyShade: 0.28,
      lensModel: GlassLensModel.paraxial,
    );

    test('applyTo overrides each field', () {
      expectTuned(theme.applyTo(const LiquidGlassSettings()));
    });

    test('copyWith preserves and replaces each field', () {
      expectTuned(theme.copyWith(blur: 3).applyTo(const LiquidGlassSettings()));
      final s = const GlassThemeSettings().copyWith(
        frost: 14,
        frostOpacity: 0.73,
        frostClamp: 0.4,
        frostWeight: 2,
        blurWeight: 0.8,
        rimShade: 1,
        rimShadeEnds: 0.1,
        rimLight: 1.15,
        bodyShade: 0.28,
        lensModel: GlassLensModel.paraxial,
      );
      expect(s, equals(theme));
    });

    test('lerp interpolates the numbers and switches lensModel at the midpoint',
        () {
      const a = GlassThemeSettings(
        frost: 0,
        frostOpacity: 1,
        frostClamp: 0,
        frostWeight: 1,
        blurWeight: 1,
        rimShade: 0,
        rimShadeEnds: 0.2,
        rimLight: 0,
        bodyShade: 0,
        lensModel: GlassLensModel.spherical,
      );
      final s = GlassThemeSettings.lerp(a, theme, 0.5)!;
      expect(s.frost, closeTo(7, 1e-10));
      expect(s.frostOpacity, closeTo(0.865, 1e-10));
      expect(s.frostClamp, closeTo(0.2, 1e-10));
      expect(s.frostWeight, closeTo(1.5, 1e-10));
      expect(s.blurWeight, closeTo(0.9, 1e-10));
      expect(s.rimShade, closeTo(0.5, 1e-10));
      expect(s.rimShadeEnds, closeTo(0.15, 1e-10));
      expect(s.rimLight, closeTo(0.575, 1e-10));
      expect(s.bodyShade, closeTo(0.14, 1e-10));
      expect(s.lensModel, GlassLensModel.paraxial);
      expect(GlassThemeSettings.lerp(a, theme, 0.49)!.lensModel,
          GlassLensModel.spherical);
    });

    test('each field takes part in == and hashCode', () {
      final variants = [
        theme.copyWith(frost: 13),
        theme.copyWith(frostOpacity: 0.7),
        theme.copyWith(frostClamp: -0.4),
        theme.copyWith(frostWeight: 0.5),
        theme.copyWith(blurWeight: 2.5),
        theme.copyWith(rimShade: 0.45),
        theme.copyWith(rimShadeEnds: 0),
        theme.copyWith(rimLight: 1),
        theme.copyWith(bodyShade: 0),
        theme.copyWith(lensModel: GlassLensModel.spherical),
      ];
      for (final v in variants) {
        expect(v, isNot(equals(theme)));
      }
      expect(theme.copyWith(), equals(theme));
      expect(theme.copyWith().hashCode, theme.hashCode);
    });
  });

  group('iOS 27 presets', () {
    test('light holds dark detail from going darker than the cloud', () {
      const s = LiquidGlassSettings.ios27Light;
      expect(s.frost, greaterThan(0));
      expect(s.frostClamp, greaterThan(0));
      expect(s.frostWeight, greaterThan(1));
      expect(s.rimShade, greaterThan(0));
      expect(s.lensModel, GlassLensModel.paraxial);
    });

    test('dark holds light detail from going lighter than the cloud', () {
      const s = LiquidGlassSettings.ios27Dark;
      expect(s.frost, greaterThan(0));
      expect(s.frostClamp, lessThan(0));
      expect(s.frostWeight, lessThan(1));
      expect(s.rimShade, greaterThan(0));
      expect(s.bodyShade, greaterThan(0));
      expect(s.lensModel, GlassLensModel.paraxial);
    });
  });
}
