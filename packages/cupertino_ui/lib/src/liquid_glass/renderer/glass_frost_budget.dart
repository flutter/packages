import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../engine/liquid_glass_settings.dart';

/// Tells the premium glass in its subtree whether it may draw its frost.
///
/// The iOS 27 frost ([LiquidGlassSettings.frost]) costs a backdrop pass of
/// its own per surface, a second one for [LiquidGlassSettings.frostWeight],
/// and the widest texture reads in the render shader. [GlassAdaptiveScope]
/// with `frostStep` switches it off here before it gives up premium, so a
/// device that can't afford the frost keeps the premium lens, rim and
/// highlight. Glass without a frost is not affected.
///
/// A switched-off frost is stood in for by the regular blur, at a quarter of
/// the frost's sigma (see [apply]), so the surface stays frosted rather than
/// turning clear.
class GlassFrostBudget extends InheritedWidget {
  /// Allows or forbids the frost for premium glass in [child].
  const GlassFrostBudget({
    required this.frostEnabled,
    required super.child,
    super.key,
  });

  /// Whether premium glass below may draw its frost.
  final bool frostEnabled;

  /// The blur sigma, per unit of frost sigma, that stands in for a frost that
  /// is switched off.
  static const double blurPerFrost = 0.25;

  /// Whether the nearest [GlassFrostBudget] allows the frost; `true` without
  /// one.
  static bool frostEnabledOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<GlassFrostBudget>()
          ?.frostEnabled ??
      true;

  /// [settings] as premium glass under [context] should draw them: unchanged
  /// while the frost is allowed, otherwise without a frost and with at least
  /// [blurPerFrost] times its sigma as a regular blur.
  static LiquidGlassSettings apply(
    BuildContext context,
    LiquidGlassSettings settings,
  ) {
    if (settings.frost <= 0 || frostEnabledOf(context)) return settings;
    return settings.copyWith(
      frost: 0,
      blur: math.max(settings.blur, settings.frost * blurPerFrost),
    );
  }

  @override
  bool updateShouldNotify(GlassFrostBudget oldWidget) =>
      frostEnabled != oldWidget.frostEnabled;
}
