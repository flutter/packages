import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/constants/glass_defaults.dart';

void main() {
  // ──────────────────────────────────────────────────────────────────────────
  // GlassDefaults — Glass Effect Properties
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassDefaults — glass effect properties', () {
    test('thickness is 30.0', () {
      expect(GlassDefaults.thickness, 30.0);
    });

    test('blur is 3.0', () {
      expect(GlassDefaults.blur, 3.0);
    });

    test('lightIntensity is 2.0', () {
      expect(GlassDefaults.lightIntensity, 2.0);
    });

    test('chromaticAberration is 0.5', () {
      expect(GlassDefaults.chromaticAberration, 0.5);
    });

    test('refractiveIndex is 1.15', () {
      expect(GlassDefaults.refractiveIndex, 1.15);
    });

    test('lightAngle is 0.75 * π (135° — iOS 26 upper-left)', () {
      // Use a generous epsilon because the constant is computed as
      // 0.75 * 3.14159265358979 (not dart:math's pi) intentionally.
      expect(GlassDefaults.lightAngle, closeTo(0.75 * math.pi, 1e-4));
    });

    test('lightAngle is in the upper-left quadrant (π/2 < angle ≤ π)', () {
      expect(GlassDefaults.lightAngle, greaterThan(math.pi / 2));
      expect(GlassDefaults.lightAngle, lessThanOrEqualTo(math.pi));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GlassDefaults — Border Radius
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassDefaults — border radius', () {
    test('borderRadius is 16.0', () {
      expect(GlassDefaults.borderRadius, 16.0);
    });

    test('borderRadiusSmall is 8.0', () {
      expect(GlassDefaults.borderRadiusSmall, 8.0);
    });

    test('borderRadiusLarge is 20.0', () {
      expect(GlassDefaults.borderRadiusLarge, 20.0);
    });

    test('borderRadiusSmall < borderRadius < borderRadiusLarge', () {
      expect(GlassDefaults.borderRadiusSmall,
          lessThan(GlassDefaults.borderRadius));
      expect(GlassDefaults.borderRadius,
          lessThan(GlassDefaults.borderRadiusLarge));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GlassDefaults — Padding
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassDefaults — padding', () {
    test('paddingCard is EdgeInsets.all(16)', () {
      expect(GlassDefaults.paddingCard, const EdgeInsets.all(16.0));
    });

    test('paddingPanel is EdgeInsets.all(24)', () {
      expect(GlassDefaults.paddingPanel, const EdgeInsets.all(24.0));
    });

    test('paddingInput is symmetric(horizontal:16, vertical:12)', () {
      expect(GlassDefaults.paddingInput,
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0));
    });

    test('paddingCompact is EdgeInsets.all(8)', () {
      expect(GlassDefaults.paddingCompact, const EdgeInsets.all(8.0));
    });

    test('paddingMinimal is EdgeInsets.all(4)', () {
      expect(GlassDefaults.paddingMinimal, const EdgeInsets.all(4.0));
    });

    test('padding sizes are ordered: minimal < compact < card < panel', () {
      expect(GlassDefaults.paddingMinimal.top,
          lessThan(GlassDefaults.paddingCompact.top));
      expect(GlassDefaults.paddingCompact.top,
          lessThan(GlassDefaults.paddingCard.top));
      expect(GlassDefaults.paddingCard.top,
          lessThan(GlassDefaults.paddingPanel.top));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GlassDefaults — Dimensions
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassDefaults — dimensions', () {
    test('heightControl is 32.0', () {
      expect(GlassDefaults.heightControl, 32.0);
    });

    test('heightButton is 48.0', () {
      expect(GlassDefaults.heightButton, 48.0);
    });

    test('heightInput is 48.0', () {
      expect(GlassDefaults.heightInput, 48.0);
    });

    test('heightControl < heightButton', () {
      expect(GlassDefaults.heightControl, lessThan(GlassDefaults.heightButton));
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // GlassDefaults — Animation Durations
  // ──────────────────────────────────────────────────────────────────────────

  group('GlassDefaults — animation durations', () {
    test('animationDuration is 200ms', () {
      expect(
          GlassDefaults.animationDuration, const Duration(milliseconds: 200));
    });

    test('animationDurationFast is 100ms', () {
      expect(GlassDefaults.animationDurationFast,
          const Duration(milliseconds: 100));
    });

    test('animationDurationSlow is 300ms', () {
      expect(GlassDefaults.animationDurationSlow,
          const Duration(milliseconds: 300));
    });

    test('fast < standard < slow', () {
      expect(GlassDefaults.animationDurationFast,
          lessThan(GlassDefaults.animationDuration));
      expect(GlassDefaults.animationDuration,
          lessThan(GlassDefaults.animationDurationSlow));
    });
  });
}
