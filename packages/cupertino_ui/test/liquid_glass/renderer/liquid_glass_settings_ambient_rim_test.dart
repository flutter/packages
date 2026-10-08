// Tests for LiquidGlassSettings.ambientRim (full-perimeter rim on the
// moving indicator): constructor default, copyWith, lerp, equality, and
// preservation through copyWithPinch.

import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/src/engine/liquid_glass_settings.dart';

void main() {
  group('LiquidGlassSettings.ambientRim', () {
    test('defaults to 0 (exact stock rendering)', () {
      expect(const LiquidGlassSettings().ambientRim, 0);
    });

    test('constructor sets the value', () {
      expect(const LiquidGlassSettings(ambientRim: 4.0).ambientRim, 4.0);
    });

    group('copyWith', () {
      const base = LiquidGlassSettings(ambientRim: 2.0);

      test('no-arg copyWith preserves ambientRim', () {
        expect(base.copyWith().ambientRim, 2.0);
      });

      test('copyWith replaces ambientRim', () {
        expect(base.copyWith(ambientRim: 6.0).ambientRim, 6.0);
      });

      test('copyWith of another field preserves ambientRim', () {
        expect(base.copyWith(blur: 9).ambientRim, 2.0);
      });
    });

    group('lerp', () {
      const a = LiquidGlassSettings(ambientRim: 0.0);
      const b = LiquidGlassSettings(ambientRim: 4.0);

      test('t=0 → a', () {
        expect(LiquidGlassSettings.lerp(a, b, 0.0).ambientRim, 0.0);
      });

      test('t=1 → b', () {
        expect(LiquidGlassSettings.lerp(a, b, 1.0).ambientRim, 4.0);
      });

      test('t=0.5 interpolates', () {
        expect(LiquidGlassSettings.lerp(a, b, 0.5).ambientRim,
            closeTo(2.0, 1e-10));
      });
    });

    group('equality', () {
      test('settings differing only in ambientRim are unequal', () {
        expect(
          const LiquidGlassSettings(ambientRim: 1.0),
          isNot(equals(const LiquidGlassSettings(ambientRim: 2.0))),
        );
      });

      test('same ambientRim compares equal', () {
        expect(
          const LiquidGlassSettings(ambientRim: 3.0),
          equals(const LiquidGlassSettings(ambientRim: 3.0)),
        );
      });
    });

    test('copyWithPinch preserves ambientRim', () {
      const s = LiquidGlassSettings(ambientRim: 5.0);
      expect(s.copyWithPinch(0.6).ambientRim, 5.0);
    });
  });
}
