// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Version: 38.2.83

// dart format off
import 'cubic_struct.dart';

class TokenMotion {
  /// md.sys.motion.duration.extra-long1
  static const Duration durationExtraLong1 = Duration(milliseconds: 700);

  /// md.sys.motion.duration.extra-long2
  static const Duration durationExtraLong2 = Duration(milliseconds: 800);

  /// md.sys.motion.duration.extra-long3
  static const Duration durationExtraLong3 = Duration(milliseconds: 900);

  /// md.sys.motion.duration.extra-long4
  static const Duration durationExtraLong4 = Duration(milliseconds: 1000);

  /// md.sys.motion.duration.long1
  static const Duration durationLong1 = Duration(milliseconds: 450);

  /// md.sys.motion.duration.long2
  static const Duration durationLong2 = Duration(milliseconds: 500);

  /// md.sys.motion.duration.long3
  static const Duration durationLong3 = Duration(milliseconds: 550);

  /// md.sys.motion.duration.long4
  static const Duration durationLong4 = Duration(milliseconds: 600);

  /// md.sys.motion.duration.medium1
  static const Duration durationMedium1 = Duration(milliseconds: 250);

  /// md.sys.motion.duration.medium2
  static const Duration durationMedium2 = Duration(milliseconds: 300);

  /// md.sys.motion.duration.medium3
  static const Duration durationMedium3 = Duration(milliseconds: 350);

  /// md.sys.motion.duration.medium4
  static const Duration durationMedium4 = Duration(milliseconds: 400);

  /// md.sys.motion.duration.short1
  static const Duration durationShort1 = Duration(milliseconds: 50);

  /// md.sys.motion.duration.short2
  static const Duration durationShort2 = Duration(milliseconds: 100);

  /// md.sys.motion.duration.short3
  static const Duration durationShort3 = Duration(milliseconds: 150);

  /// md.sys.motion.duration.short4
  static const Duration durationShort4 = Duration(milliseconds: 200);

  /// md.sys.motion.easing.emphasized
  static const String easingEmphasized =
      'M 0,0 C 0.05, 0, 0.133333, 0.06, 0.166666, 0.4 C 0.208333, 0.82, 0.25, 1, 1, 1';

  /// md.sys.motion.easing.emphasized.accelerate
  static const CubicStruct easingEmphasizedAccelerate = CubicStruct(
    a: 0.30,
    b: 0.00,
    c: 0.80,
    d: 0.15,
  );

  /// md.sys.motion.easing.emphasized.decelerate
  static const CubicStruct easingEmphasizedDecelerate = CubicStruct(
    a: 0.05,
    b: 0.70,
    c: 0.10,
    d: 1.00,
  );

  /// md.sys.motion.easing.legacy
  static const CubicStruct easingLegacy = CubicStruct(
    a: 0.40,
    b: 0.00,
    c: 0.20,
    d: 1.00,
  );

  /// md.sys.motion.easing.legacy.accelerate
  static const CubicStruct easingLegacyAccelerate = CubicStruct(
    a: 0.40,
    b: 0.00,
    c: 1.00,
    d: 1.00,
  );

  /// md.sys.motion.easing.legacy.decelerate
  static const CubicStruct easingLegacyDecelerate = CubicStruct(
    a: 0.00,
    b: 0.00,
    c: 0.20,
    d: 1.00,
  );

  /// md.sys.motion.easing.linear
  static const CubicStruct easingLinear = CubicStruct(
    a: 0.00,
    b: 0.00,
    c: 1.00,
    d: 1.00,
  );

  /// md.sys.motion.easing.standard
  static const CubicStruct easingStandard = CubicStruct(
    a: 0.20,
    b: 0.00,
    c: 0.00,
    d: 1.00,
  );

  /// md.sys.motion.easing.standard.accelerate
  static const CubicStruct easingStandardAccelerate = CubicStruct(
    a: 0.30,
    b: 0.00,
    c: 1.00,
    d: 1.00,
  );

  /// md.sys.motion.easing.standard.decelerate
  static const CubicStruct easingStandardDecelerate = CubicStruct(
    a: 0.00,
    b: 0.00,
    c: 0.00,
    d: 1.00,
  );

  /// md.sys.motion.path
  static const String path = 'LINEAR';

  /// md.sys.motion.spring.default.effects.damping
  static const double springDefaultEffectsDamping = 1.00;

  /// md.sys.motion.spring.default.effects.stiffness
  static const double springDefaultEffectsStiffness = 1600.00;

  /// md.sys.motion.spring.default.spatial.damping
  static const double springDefaultSpatialDamping = 0.90;

  /// md.sys.motion.spring.default.spatial.stiffness
  static const double springDefaultSpatialStiffness = 700.00;

  /// md.sys.motion.spring.fast.effects.damping
  static const double springFastEffectsDamping = 1.00;

  /// md.sys.motion.spring.fast.effects.stiffness
  static const double springFastEffectsStiffness = 3800.00;

  /// md.sys.motion.spring.fast.spatial.damping
  static const double springFastSpatialDamping = 0.90;

  /// md.sys.motion.spring.fast.spatial.stiffness
  static const double springFastSpatialStiffness = 1400.00;

  /// md.sys.motion.spring.slow.effects.damping
  static const double springSlowEffectsDamping = 1.00;

  /// md.sys.motion.spring.slow.effects.stiffness
  static const double springSlowEffectsStiffness = 800.00;

  /// md.sys.motion.spring.slow.spatial.damping
  static const double springSlowSpatialDamping = 0.90;

  /// md.sys.motion.spring.slow.spatial.stiffness
  static const double springSlowSpatialStiffness = 300.00;
}
