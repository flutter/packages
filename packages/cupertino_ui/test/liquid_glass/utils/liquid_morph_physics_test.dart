import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:liquid_glass_widgets/utils/liquid_morph_physics.dart';

// ─── Helpers ───────────────────────────────────────────────────────────────

/// Standard geometry used across most tests.
const double _finalDx = 80.0;
const double _finalDy = 160.0;
const double _hOffset = 8.0;
const double _vOffset = 4.0;

LiquidMorphState _compute(
  double rawValue, {
  double finalDx = _finalDx,
  double finalDy = _finalDy,
  double horizontalOffset = _hOffset,
  double verticalOffset = _vOffset,
}) =>
    LiquidMorphPhysics.compute(
      rawValue: rawValue,
      finalDx: finalDx,
      finalDy: finalDy,
      horizontalOffset: horizontalOffset,
      verticalOffset: verticalOffset,
    );

void main() {
  // ── Resting state ─────────────────────────────────────────────────────────

  group('LiquidMorphPhysics — resting state (rawValue = 0.0)', () {
    late LiquidMorphState s;
    setUp(() => s = _compute(0.0));

    test('pathT is 0.0 at rest', () => expect(s.pathT, equals(0.0)));
    test('sizeT is 0.0 at rest', () => expect(s.sizeT, equals(0.0)));
    test('currentDx is 0.0 at rest', () => expect(s.currentDx, equals(0.0)));
    test('currentDy is 0.0 at rest', () => expect(s.currentDy, equals(0.0)));
    test('pushDx is 0.0 at rest (no close undershoot)', () {
      expect(s.pushDx, equals(0.0));
    });
    test('pushDy is 0.0 at rest (no close undershoot)', () {
      expect(s.pushDy, equals(0.0));
    });
    test('anchorScale is 1.0 at rest', () {
      expect(s.anchorScale, equals(1.0));
    });
    test('containerScale is 1.0 at rest', () {
      expect(s.containerScale, equals(1.0));
    });
    test('blend is 0.0 at rest (no separation)', () {
      expect(s.blend, equals(0.0));
    });
    test('phase is idle at rest', () {
      expect(s.phase, equals(MorphPhase.idle));
    });
  });

  // ── Fully settled state ───────────────────────────────────────────────────

  group('LiquidMorphPhysics — fully settled (rawValue = 1.0)', () {
    late LiquidMorphState s;
    setUp(() => s = _compute(1.0));

    test('anchorScale is 0.0 when fully open', () {
      expect(s.anchorScale, equals(0.0));
    });
    test('containerScale is 1.0 in normal travel range', () {
      expect(s.containerScale, equals(1.0));
    });
    test('currentDx equals finalDx * pathT', () {
      expect(s.currentDx, closeTo(_finalDx * s.pathT, 0.001));
    });
    test('phase is settled at rawValue = 1.0', () {
      expect(s.phase, equals(MorphPhase.settled));
    });
    test('pushDx is 0 when rawValue >= 0 (no close undershoot)', () {
      expect(s.pushDx, equals(0.0));
    });
  });

  // ── Phase transitions ─────────────────────────────────────────────────────

  group('LiquidMorphPhysics — phase state machine', () {
    test('0.001 → detaching', () {
      expect(_compute(0.001).phase, equals(MorphPhase.detaching));
    });
    test('0.1 → detaching', () {
      expect(_compute(0.1).phase, equals(MorphPhase.detaching));
    });
    test('0.4 → travelling', () {
      expect(_compute(0.4).phase, equals(MorphPhase.travelling));
    });
    test('0.6 → travelling', () {
      expect(_compute(0.6).phase, equals(MorphPhase.travelling));
    });
    test('0.8 → arriving', () {
      expect(_compute(0.8).phase, equals(MorphPhase.arriving));
    });
    test('0.99 → arriving (just below settled threshold)', () {
      expect(_compute(0.99).phase, equals(MorphPhase.arriving));
    });
    test('1.0 → settled', () {
      expect(_compute(1.0).phase, equals(MorphPhase.settled));
    });
    test('negative rawValue → detaching (close bounce)', () {
      expect(_compute(-0.1).phase, equals(MorphPhase.detaching));
    });
  });

  // ── Close undershoot (rawValue < 0) ───────────────────────────────────────

  group('LiquidMorphPhysics — close undershoot (rawValue < 0)', () {
    const undershoot = -0.2;
    late LiquidMorphState s;
    setUp(() => s = _compute(undershoot));

    test('containerScale drops below 1.0 during close undershoot', () {
      // 1.0 + (-0.2 * 0.55) = 0.89
      expect(s.containerScale, lessThan(1.0));
      expect(s.containerScale, closeTo(1.0 + undershoot * 0.55, 0.001));
    });

    test('pushDx is non-zero during close undershoot', () {
      // pushDx = (finalDx + horizontalOffset) * rawValue
      final expected = (_finalDx + _hOffset) * undershoot;
      expect(s.pushDx, closeTo(expected, 0.001));
    });

    test('pushDy is non-zero during close undershoot', () {
      final expected = (_finalDy + _vOffset) * undershoot;
      expect(s.pushDy, closeTo(expected, 0.001));
    });

    test('pathT includes closeUndershoot additive term', () {
      // clampedValue = 0 → backOutCurve(0) = 0, closeUndershoot = -0.2
      // pathT = 0 + (-0.2) = -0.2
      expect(s.pathT, closeTo(-0.2, 0.001));
    });

    test('sizeT includes closeUndershoot additive term', () {
      // clampedValue = 0 → linearToEaseOut(0) = 0, closeUndershoot = -0.2
      // sizeT = 0 + (-0.2) = -0.2
      expect(s.sizeT, closeTo(-0.2, 0.001));
    });

    test('containerScale clamps correctly for extreme undershoot', () {
      // rawValue = -1.0 → scale = 1.0 + (-1.0 * 0.55) = 0.45
      final extreme = _compute(-1.0);
      expect(extreme.containerScale, closeTo(0.45, 0.001));
    });
  });

  // ── Open overshoot (rawValue > 1) ─────────────────────────────────────────

  group('LiquidMorphPhysics — open overshoot (rawValue > 1)', () {
    const overshoot = 1.05;
    late LiquidMorphState s;
    setUp(() => s = _compute(overshoot));

    test('containerScale slightly above 1.0 during open overshoot', () {
      // 1.0 + (0.05 * 0.10) = 1.005
      expect(s.containerScale, greaterThan(1.0));
      expect(s.containerScale, closeTo(1.0 + (overshoot - 1.0) * 0.10, 0.001));
    });

    test('pushDx is 0 during open overshoot (positive rawValue)', () {
      expect(s.pushDx, equals(0.0));
    });

    test('pushDy is 0 during open overshoot', () {
      expect(s.pushDy, equals(0.0));
    });

    test('phase is settled for overshoot (rawValue >= 1)', () {
      expect(s.phase, equals(MorphPhase.settled));
    });
  });

  // ── Anchor scale ──────────────────────────────────────────────────────────

  group('LiquidMorphPhysics — anchorScale', () {
    test('is 1.0 at rawValue = 0.0 (trigger fully visible)', () {
      expect(_compute(0.0).anchorScale, equals(1.0));
    });

    test('is 0.5 at rawValue = 0.2 (halfway through 40% ease)', () {
      // (1 - 0.2/0.4).clamp(0,1) = 0.5
      expect(_compute(0.2).anchorScale, closeTo(0.5, 0.001));
    });

    test('is 0.0 at rawValue = 0.4 (fully detached)', () {
      expect(_compute(0.4).anchorScale, closeTo(0.0, 0.001));
    });

    test('stays 0.0 for rawValue > 0.4', () {
      expect(_compute(0.6).anchorScale, equals(0.0));
      expect(_compute(1.0).anchorScale, equals(0.0));
    });

    test('grows back toward 1.0 as rawValue returns to 0 on close', () {
      final atClose = _compute(0.2);
      expect(atClose.anchorScale, closeTo(0.5, 0.001));
    });
  });

  // ── Blob B displacement ───────────────────────────────────────────────────

  group('LiquidMorphPhysics — Blob B displacement', () {
    test('currentDx = finalDx * pathT', () {
      final s = _compute(0.5);
      expect(s.currentDx, closeTo(_finalDx * s.pathT, 0.001));
    });

    test('currentDy = finalDy * pathT', () {
      final s = _compute(0.5);
      expect(s.currentDy, closeTo(_finalDy * s.pathT, 0.001));
    });

    test('finalDx = 0 → currentDx always 0 regardless of rawValue', () {
      for (final v in [0.0, 0.3, 0.7, 1.0]) {
        expect(
          _compute(v, finalDx: 0.0, finalDy: _finalDy).currentDx,
          equals(0.0),
          reason: 'rawValue=$v',
        );
      }
    });
  });

  // ── Blend (metaball merge intensity) ─────────────────────────────────────

  group('LiquidMorphPhysics — blend', () {
    test('blend is 0.0 at rest', () {
      expect(_compute(0.0).blend, equals(0.0));
    });

    test('blend is near-zero when fully settled (pathT ≈ sizeT ≈ 1.0)', () {
      expect(_compute(1.0).blend, lessThan(2.0));
    });

    test('blend is non-zero during mid-travel (separation between curves)', () {
      final s = _compute(0.5);
      expect(s.blend, greaterThan(0.0));
    });

    test('blend is clamped to a maximum of 28.0', () {
      for (int i = 0; i <= 100; i++) {
        final raw = i / 100.0;
        expect(
          _compute(raw).blend,
          lessThanOrEqualTo(28.0),
          reason: 'rawValue=$raw exceeded max blend',
        );
      }
    });

    test('blend is always non-negative (open path)', () {
      // Only tests the open path; the closing proximity blend is covered
      // separately in the 'closing trajectory' group below.
      for (final v in [-0.3, 0.0, 0.25, 0.5, 0.75, 1.0, 1.1]) {
        expect(
          _compute(v).blend,
          greaterThanOrEqualTo(0.0),
          reason: 'rawValue=$v produced negative blend (open path)',
        );
      }
    });
  });

  // ── Spring constants (public contract) ───────────────────────────────────

  group('LiquidMorphPhysics — spring constants', () {
    test('openSpring has stiffness 120', () {
      expect(LiquidMorphPhysics.openSpring.stiffness, equals(120.0));
    });

    test('openSpring has damping 16', () {
      expect(LiquidMorphPhysics.openSpring.damping, equals(16.0));
    });

    test('closeSpring has snappy profile (higher stiffness for fast dismiss)',
        () {
      expect(LiquidMorphPhysics.closeSpring.stiffness, equals(200.0));
      expect(LiquidMorphPhysics.closeSpring.damping, equals(21.0));
    });

    test('closeVelocityHint is negative (drives spring toward 0 with momentum)',
        () {
      expect(LiquidMorphPhysics.closeVelocityHint, lessThan(0.0));
    });
  });

  // ── Geometry scaling ──────────────────────────────────────────────────────

  group('LiquidMorphPhysics — geometry scaling', () {
    test('doubling finalDx doubles currentDx at same rawValue', () {
      const v = 0.6;
      final s1 = _compute(v, finalDx: 100.0, finalDy: 0.0);
      final s2 = _compute(v, finalDx: 200.0, finalDy: 0.0);
      expect(s2.currentDx, closeTo(s1.currentDx * 2.0, 0.01));
    });

    test('doubling finalDy doubles currentDy at same rawValue', () {
      const v = 0.6;
      final s1 = _compute(v, finalDx: 0.0, finalDy: 100.0);
      final s2 = _compute(v, finalDx: 0.0, finalDy: 200.0);
      expect(s2.currentDy, closeTo(s1.currentDy * 2.0, 0.01));
    });

    test('horizontalOffset only affects pushDx (not currentDx)', () {
      const v = -0.1;
      final s1 = _compute(
        v,
        finalDx: 100.0,
        finalDy: 0.0,
        horizontalOffset: 0.0,
      );
      final s2 = _compute(
        v,
        finalDx: 100.0,
        finalDy: 0.0,
        horizontalOffset: 20.0,
      );
      // currentDx comes from finalDx * pathT — offset does NOT affect it.
      expect(s1.currentDx, closeTo(s2.currentDx, 0.001));
      // pushDx IS affected by horizontalOffset.
      expect(s2.pushDx, isNot(closeTo(s1.pushDx, 0.001)));
    });
  });

  // ── Monotonicity / smoothness smoke-test ──────────────────────────────────

  group('LiquidMorphPhysics — animation smoothness', () {
    test('sizeT increases monotonically from 0 to 1 during open', () {
      double prev = -1.0;
      for (int i = 0; i <= 100; i++) {
        final raw = i / 100.0;
        final cur = _compute(raw).sizeT;
        expect(cur, greaterThanOrEqualTo(prev),
            reason: 'sizeT not monotonic at rawValue=$raw');
        prev = cur;
      }
    });

    test('anchorScale decreases monotonically from 1.0 to 0.0 over [0, 0.4]',
        () {
      double prev = 1.1;
      for (int i = 0; i <= 40; i++) {
        final raw = i / 100.0; // 0.00 → 0.40
        final cur = _compute(raw).anchorScale;
        expect(cur, lessThanOrEqualTo(prev),
            reason:
                'anchorScale not monotonically decreasing at rawValue=$raw');
        prev = cur;
      }
    });

    test('containerScale is exactly 1.0 throughout normal travel [0, 1]', () {
      for (int i = 0; i <= 100; i++) {
        final raw = i / 100.0;
        expect(
          _compute(raw).containerScale,
          equals(1.0),
          reason: 'containerScale ≠ 1.0 at rawValue=$raw',
        );
      }
    });
  });

  // ── Adaptive-mode helpers ──────────────────────────────────────────────────

  group('LiquidMorphPhysics.computeScaleDelta', () {
    test('returns 1.0 for identical square sizes', () {
      expect(
        LiquidMorphPhysics.computeScaleDelta(
          sourceSize: const Size(48, 48),
          targetSize: const Size(48, 48),
        ),
        closeTo(1.0, 1e-9),
      );
    });

    test('returns correct ratio for compose-button → full-sheet', () {
      // source: 48×48 = 2304 px²,  target: 393×852 = 334 836 px²
      // ratio = √(334836 / 2304) ≈ 12.05
      final delta = LiquidMorphPhysics.computeScaleDelta(
        sourceSize: const Size(48, 48),
        targetSize: const Size(393, 852),
      );
      expect(delta, greaterThan(10.0));
      expect(delta, lessThan(15.0));
    });

    test('returns 1.0 for zero-area source (morphFromZero guard)', () {
      expect(
        LiquidMorphPhysics.computeScaleDelta(
          sourceSize: const Size(0, 0),
          targetSize: const Size(200, 300),
        ),
        equals(1.0),
      );
    });
  });

  group('LiquidMorphPhysics.computeAdaptiveBackOutAmplitude', () {
    test('returns 2.5 when |finalDy| <= 100 px', () {
      expect(
        LiquidMorphPhysics.computeAdaptiveBackOutAmplitude(finalDy: 80.0),
        closeTo(2.5, 1e-9),
      );
    });

    test('is attenuated for large vertical travel (|finalDy| = 388 px)', () {
      final amp = LiquidMorphPhysics.computeAdaptiveBackOutAmplitude(
        finalDy: -388.0,
      );
      // Expected ≈ 2.5 * 100/388 ≈ 0.644 → clamped to min 0.7
      expect(amp, closeTo(0.7, 1e-6));
    });

    test('never falls below the minimum amplitude (0.7)', () {
      // Extreme travel distance that would otherwise go below min.
      final amp = LiquidMorphPhysics.computeAdaptiveBackOutAmplitude(
        finalDy: -10000.0,
      );
      expect(amp, greaterThanOrEqualTo(0.7));
    });

    test('never exceeds the base amplitude (2.5)', () {
      final amp = LiquidMorphPhysics.computeAdaptiveBackOutAmplitude(
        finalDy: -10.0, // very small
      );
      expect(amp, lessThanOrEqualTo(2.5));
    });
  });

  group('LiquidMorphPhysics.computeBlendAttenuation', () {
    test('returns 1.0 for scaleDelta <= 3.0 (full blend)', () {
      expect(LiquidMorphPhysics.computeBlendAttenuation(1.0), equals(1.0));
      expect(LiquidMorphPhysics.computeBlendAttenuation(3.0), equals(1.0));
    });

    test('is attenuated for scaleDelta > 3.0', () {
      final att = LiquidMorphPhysics.computeBlendAttenuation(12.0);
      expect(att, closeTo(3.0 / 12.0, 1e-9)); // 0.25
      expect(att, lessThan(1.0));
    });

    test('never falls below 0.2', () {
      final att = LiquidMorphPhysics.computeBlendAttenuation(1000.0);
      expect(att, greaterThanOrEqualTo(0.2));
    });
  });

  group('LiquidMorphPhysics — adaptive mode (scaleDelta = 12.0)', () {
    // Simulate a compose-button (48×48) → full-sheet (393×852) morph.
    const scaleDelta = 12.0;
    // finalDy = sheet_center.y - trigger_center.y (upward → negative)
    const finalDy = -388.0;
    const finalDx = 0.0;

    LiquidMorphState computeAdaptive(double rawValue) =>
        LiquidMorphPhysics.compute(
          rawValue: rawValue,
          finalDx: finalDx,
          finalDy: finalDy,
          scaleDelta: scaleDelta,
        );

    test('sizeT stays compact (< 0.40) through first 35% of open', () {
      for (int i = 0; i <= 35; i++) {
        final raw = i / 100.0;
        final s = computeAdaptive(raw);
        expect(
          s.sizeT,
          lessThan(0.40),
          reason: 'sizeT not compact at rawValue=$raw (adaptive off?)',
        );
      }
    });

    test('sizeT reaches exactly 1.0 at rawValue = 1.0', () {
      expect(computeAdaptive(1.0).sizeT, closeTo(1.0, 1e-9));
    });

    test('sizeT is 0.0 at rawValue = 0.0', () {
      expect(computeAdaptive(0.0).sizeT, equals(0.0));
    });

    test('sizeT is monotonically increasing on [0, 1]', () {
      double prev = -1.0;
      for (int i = 0; i <= 100; i++) {
        final raw = i / 100.0;
        final cur = computeAdaptive(raw).sizeT;
        expect(cur, greaterThanOrEqualTo(prev),
            reason: 'sizeT not monotonic at rawValue=$raw (adaptive)');
        prev = cur;
      }
    });

    test('close undershoot pushDy magnitude is bounded (< 20 px)', () {
      // rawValue = -0.15 simulates peak close bounce.
      // With full travel (388 px), unbounded push would be ~58 px.
      // Bounded push must be < 20 px.
      final s = LiquidMorphPhysics.compute(
        rawValue: -0.15,
        finalDx: finalDx,
        finalDy: finalDy,
        scaleDelta: scaleDelta,
      );
      expect(
        s.pushDy.abs(),
        lessThan(20.0),
        reason:
            'pushDy=${s.pushDy} exceeds 20 px threshold — trigger will jolt',
      );
    });

    test('close undershoot pushDy is still non-zero (bounce is visible)', () {
      final s = LiquidMorphPhysics.compute(
        rawValue: -0.15,
        finalDx: finalDx,
        finalDy: finalDy,
        scaleDelta: scaleDelta,
      );
      expect(s.pushDy.abs(), greaterThan(0.0));
    });

    test('blend is attenuated for large-scale morph', () {
      // At mid-travel the blend should still be > 0 but reduced from the
      // un-attenuated value that would saturate the SDF viewport.
      final s = computeAdaptive(0.5);
      final fullBlend = LiquidMorphPhysics.compute(
        rawValue: 0.5,
        finalDx: finalDx,
        finalDy: finalDy,
        scaleDelta: 1.0, // no attenuation
      ).blend;
      expect(s.blend, lessThanOrEqualTo(fullBlend));
    });
  });

  // ── Closing trajectory (isClosing = true) ──────────────────────────────────

  group('LiquidMorphPhysics — closing trajectory (isClosing = true)', () {
    test(
        'pathT never exceeds 1.0 on close (no reverse launch in wrong direction)',
        () {
      for (int i = 0; i <= 100; i++) {
        final raw = i / 100.0;
        final s = LiquidMorphPhysics.compute(
          rawValue: raw,
          finalDx: _finalDx,
          finalDy: _finalDy,
          isClosing: true,
        );
        expect(s.pathT, lessThanOrEqualTo(1.0),
            reason: 'pathT exceeded 1.0 at rawValue=$raw on close');
      }
    });

    test('pathT decreases monotonically from 1.0 to 0.0 on close', () {
      double prev = -0.1;
      for (int i = 0; i <= 100; i++) {
        final raw = i / 100.0;
        final s = LiquidMorphPhysics.compute(
          rawValue: raw,
          finalDx: _finalDx,
          finalDy: _finalDy,
          isClosing: true,
        );
        expect(s.pathT, greaterThanOrEqualTo(prev),
            reason: 'pathT not monotonic at rawValue=$raw on close');
        prev = s.pathT;
      }
    });

    test('sizeT decreases monotonically from 1.0 to 0.0 on close', () {
      double prev = -0.1;
      for (int i = 0; i <= 100; i++) {
        final raw = i / 100.0;
        final s = LiquidMorphPhysics.compute(
          rawValue: raw,
          finalDx: _finalDx,
          finalDy: _finalDy,
          isClosing: true,
        );
        expect(s.sizeT, greaterThanOrEqualTo(prev),
            reason: 'sizeT not monotonic at rawValue=$raw on close');
        prev = s.sizeT;
      }
    });

    test('pathT and sizeT include closeUndershoot when rawValue < 0.0', () {
      const undershoot = -0.15;
      final s = LiquidMorphPhysics.compute(
        rawValue: undershoot,
        finalDx: _finalDx,
        finalDy: _finalDy,
        isClosing: true,
      );
      expect(s.pathT, closeTo(undershoot, 1e-9));
      expect(s.sizeT, closeTo(undershoot, 1e-9));
    });
  });

  // ── Closing blend proximity ramp ─────────────────────────────────────────
  //
  // Verifies the new _closeProximityThreshold-based blend that makes the SDF
  // metaball bridge re-form as the droplet returns to the trigger on close.

  group('LiquidMorphPhysics — closing blend proximity ramp', () {
    LiquidMorphState closeCompute(double raw) => LiquidMorphPhysics.compute(
          rawValue: raw,
          finalDx: _finalDx,
          finalDy: _finalDy,
          isClosing: true,
        );

    test('blend is 0.0 at start of close (clampedValue = 1.0)', () {
      // At the very top of the closing arc the droplet is far from the
      // trigger; no bridge should be visible.
      expect(closeCompute(1.0).blend, equals(0.0));
    });

    test('blend is 0.0 while clampedValue >= closeProximityThreshold (0.6)',
        () {
      // Bridge must not appear while the droplet is still in mid-travel.
      for (final v in [1.0, 0.9, 0.8, 0.7, 0.6]) {
        expect(
          closeCompute(v).blend,
          equals(0.0),
          reason:
              'Expected blend=0 at clampedValue=$v (above proximity threshold)',
        );
      }
    });

    test('blend grows as clampedValue falls below 0.6 on close', () {
      // easeOut: bridge snaps on quickly once inside the threshold.
      final blendAt55 = closeCompute(0.55).blend;
      final blendAt30 = closeCompute(0.30).blend;
      expect(blendAt55, greaterThan(0.0),
          reason: 'Expected blend > 0 at clampedValue=0.55');
      expect(blendAt30, greaterThan(blendAt55),
          reason: 'Expected blend to grow as clampedValue decreases toward 0');
    });

    test('blend reaches maximum (28.0) near clampedValue = 0.0 on close', () {
      // At landing the bridge should be at full strength.
      expect(closeCompute(0.0).blend, closeTo(28.0, 0.5));
    });

    test('blend is always clamped to [0, 28] on entire close trajectory', () {
      for (int i = 0; i <= 100; i++) {
        final raw = i / 100.0;
        final b = closeCompute(raw).blend;
        expect(b, greaterThanOrEqualTo(0.0),
            reason: 'Negative blend at rawValue=$raw on close');
        expect(b, lessThanOrEqualTo(28.0),
            reason: 'Blend exceeds max at rawValue=$raw on close');
      }
    });

    test('blend is non-negative during close undershoot (rawValue < 0)', () {
      // The close undershoot (spring bounces past 0) must never produce
      // a negative blend value.
      for (final v in [-0.05, -0.1, -0.15, -0.2]) {
        expect(
          closeCompute(v).blend,
          greaterThanOrEqualTo(0.0),
          reason: 'Negative blend at rawValue=$v during undershoot',
        );
      }
    });
  });
}
