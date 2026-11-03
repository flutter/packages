// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/cubic_struct.dart';
import '../data/motion.dart';
import 'template.dart';

class MotionTemplateM3 extends TokenTemplateM3 {
  const MotionTemplateM3();

  @override
  String get name => 'Motion';

  @override
  String get parentFilePath => 'motion.dart';

  @override
  String get className => '';

  String _durationTokenString(String tokenName, Duration tokenValue) {
    final int milliseconds = tokenValue.inMilliseconds;
    return '''
  /// The $tokenName duration (${milliseconds}ms) in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#c009dec6-f29b-4503-b9f0-482af14a8bbd)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  static const Duration $tokenName = Duration(milliseconds: $milliseconds);
''';
  }

  String _easingCurveTokenString(String tokenName, CubicStruct tokenValue) =>
      '''
  /// The $tokenName easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  static const Curve $tokenName = Cubic(${tokenValue.a}, ${tokenValue.b}, ${tokenValue.c}, ${tokenValue.d});
''';

  @override
  String generateContents(String className) =>
      '''
/// The set of durations in the Material specification.
///
/// See also:
///
/// * [M3 guidelines: Duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#c009dec6-f29b-4503-b9f0-482af14a8bbd)
/// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
abstract final class Durations {
${_durationTokenString('short1', TokenMotion.durationShort1)}
${_durationTokenString('short2', TokenMotion.durationShort2)}
${_durationTokenString('short3', TokenMotion.durationShort3)}
${_durationTokenString('short4', TokenMotion.durationShort4)}
${_durationTokenString('medium1', TokenMotion.durationMedium1)}
${_durationTokenString('medium2', TokenMotion.durationMedium2)}
${_durationTokenString('medium3', TokenMotion.durationMedium3)}
${_durationTokenString('medium4', TokenMotion.durationMedium4)}
${_durationTokenString('long1', TokenMotion.durationLong1)}
${_durationTokenString('long2', TokenMotion.durationLong2)}
${_durationTokenString('long3', TokenMotion.durationLong3)}
${_durationTokenString('long4', TokenMotion.durationLong4)}
${_durationTokenString('extralong1', TokenMotion.durationExtraLong1)}
${_durationTokenString('extralong2', TokenMotion.durationExtraLong2)}
${_durationTokenString('extralong3', TokenMotion.durationExtraLong3)}
${_durationTokenString('extralong4', TokenMotion.durationExtraLong4).trimRight()}
}

// TODO(guidezpl): Improve with description and assets, b/289870605

/// The set of easing curves in the Material specification.
///
/// See also:
///
/// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
/// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
/// * [Curves], for a collection of non-Material animation easing curves.
abstract final class Easing {
${_easingCurveTokenString('emphasizedAccelerate', TokenMotion.easingEmphasizedAccelerate)}
${_easingCurveTokenString('emphasizedDecelerate', TokenMotion.easingEmphasizedDecelerate)}
${_easingCurveTokenString('linear', TokenMotion.easingLinear)}
${_easingCurveTokenString('standard', TokenMotion.easingStandard)}
${_easingCurveTokenString('standardAccelerate', TokenMotion.easingStandardAccelerate)}
${_easingCurveTokenString('standardDecelerate', TokenMotion.easingStandardDecelerate)}
${_easingCurveTokenString('legacyDecelerate', TokenMotion.easingLegacyDecelerate)}
${_easingCurveTokenString('legacyAccelerate', TokenMotion.easingLegacyAccelerate)}
${_easingCurveTokenString('legacy', TokenMotion.easingLegacy).trimRight()}
}
''';
}
