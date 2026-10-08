import 'package:flutter/cupertino.dart';
import '../../utils/accessibility_config.dart' as glass_config;

// ---------------------------------------------------------------------------
// GlassAccessibilityScope — IP1
//
// Propagates system accessibility preferences to all glass widgets in the
// subtree. Respects:
//
//   • Reduce Motion  — MediaQuery.disableAnimationsOf(context)
//     When true, jelly/spring animations collapse to instant snaps.
//     Affects: GlassSegmentedControl, GlassTabBar, GlassSwitch,
//              GlassSlider — every widget that uses GlassSpring internally.
//
//   • Reduce Transparency — MediaQuery.highContrastOf(context)
//     Flutter does not expose UIAccessibility.isReduceTransparencyEnabled
//     directly. highContrast is the closest platform signal available.
//     When true, AdaptiveGlass replaces the glass shader with a solid frosted
//     surface (a plain BackdropFilter blur + opaque tinted panel), eliminating
//     all refraction, specular, and chromatic aberration.
//
// ## Default behaviour — no setup required
//
// GlassAccessibilityScope is NOT required. [GlassAccessibilityData.of] falls
// back to reading [MediaQuery] directly when no scope is in the tree, so
// system Reduce Motion and Reduce Transparency are always respected. Every
// glass widget in this package does the right thing out of the box.
//
// ## Why add GlassAccessibilityScope at all?
//
// 1. Performance: a single InheritedWidget propagates the data once through
//    the subtree; without it every [GlassAccessibilityData.of] call does its
//    own [MediaQuery] lookup (cheap, but duplicated).
//
// 2. Overrides: useful in tests and showcase UIs to force a specific state
//    without changing the OS setting.
//
// ## Optional usage
//
// Place once near the root, inside MaterialApp.builder so that MediaQuery is
// available:
//
// ```dart
// MaterialApp(
//   builder: (context, child) => GlassAccessibilityScope(
//     child: GlassTheme(data: ..., child: child!),
//   ),
// )
// ```
//
// Access anywhere below:
// ```dart
// final scope = GlassAccessibilityData.of(context);
// if (scope.reduceMotion) { /* skip animation */ }
// ```
//
// ## Overriding
//
// Pass explicit values to override the system defaults — useful in tests or
// showcase UIs where you want to demo the fallback appearance:
//
// ```dart
// GlassAccessibilityScope(
//   reduceTransparency: true, // force frosted fallback
//   child: ...,
// )
// ```
// ---------------------------------------------------------------------------

bool _systemReduceMotion(BuildContext context) {
  final features = View.of(context).platformDispatcher.accessibilityFeatures;
  return MediaQuery.disableAnimationsOf(context) || features.reduceMotion;
}

/// Accessibility state for the liquid glass widget tree.
///
/// Obtain with [GlassAccessibilityData.of] or [GlassAccessibilityData.maybeOf].
@immutable
class GlassAccessibilityData {
  /// Creates a new [GlassAccessibilityData].
  const GlassAccessibilityData({
    required this.reduceMotion,
    required this.reduceTransparency,
  });

  /// When true, animated glass physics (jelly springs) should be disabled.
  ///
  /// Corresponds to iOS "Reduce Motion" / Android "Remove animations".
  /// Sourced from [MediaQuery.disableAnimationsOf].
  final bool reduceMotion;

  /// When true, the glass shader should degrade to a plain frosted surface.
  ///
  /// Sourced from [MediaQuery.highContrastOf] as the closest available
  /// Flutter proxy for iOS "Reduce Transparency".
  final bool reduceTransparency;

  /// The no-accessibility-restriction default used when no scope is in tree.
  static const GlassAccessibilityData defaults = GlassAccessibilityData(
    reduceMotion: false,
    reduceTransparency: false,
  );

  /// Returns the nearest [GlassAccessibilityData] in the widget tree.
  ///
  /// Priority order:
  /// 1. An explicit [GlassAccessibilityScope] in the widget tree (always wins).
  /// 2. System `MediaQuery` flags, **if**
  ///    `LiquidGlassWidgets.respectSystemAccessibility` is `true` (the default).
  /// 3. [GlassAccessibilityData.defaults] (no restrictions) when accessibility
  ///    is disabled globally via
  ///    `LiquidGlassWidgets.wrap(respectSystemAccessibility: false)`.
  static GlassAccessibilityData of(BuildContext context) {
    // 1. Prefer an explicit scope — allows overrides and avoids duplicate
    // MediaQuery lookups in subtrees that do add the scope.
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_InheritedGlassAccessibility>();
    if (inherited != null) return inherited.data;

    // 2. If the global flag is off, skip MediaQuery entirely.
    if (!glass_config.respectSystemAccessibility) {
      return GlassAccessibilityData.defaults;
    }

    // 3. Read system flags so accessibility is respected with no dev setup.
    return GlassAccessibilityData(
      reduceMotion: _systemReduceMotion(context),
      reduceTransparency: MediaQuery.highContrastOf(context),
    );
  }

  /// Returns the nearest [GlassAccessibilityData], or null if not found.
  static GlassAccessibilityData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedGlassAccessibility>()
        ?.data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlassAccessibilityData &&
          runtimeType == other.runtimeType &&
          reduceMotion == other.reduceMotion &&
          reduceTransparency == other.reduceTransparency;

  @override
  int get hashCode => Object.hash(reduceMotion, reduceTransparency);

  @override
  String toString() => 'GlassAccessibilityData(reduceMotion: $reduceMotion, '
      'reduceTransparency: $reduceTransparency)';
}

/// Reads system accessibility preferences and makes them available to all
/// glass widgets below it in the widget tree.
///
/// See the file-level documentation for full usage details.
class GlassAccessibilityScope extends StatelessWidget {
  /// Creates a [GlassAccessibilityScope].
  ///
  /// [reduceMotion] and [reduceTransparency] are optional overrides.
  /// When null (the default), the scope reads the values from [MediaQuery].
  const GlassAccessibilityScope({
    required this.child,
    this.reduceMotion,
    this.reduceTransparency,
    super.key,
  });

  /// Override for the reduce-motion preference.
  ///
  /// When null, the value is sourced from [MediaQuery.disableAnimationsOf].
  final bool? reduceMotion;

  /// Override for the reduce-transparency preference.
  ///
  /// When null, the value is sourced from [MediaQuery.highContrastOf].
  final bool? reduceTransparency;

  /// The widget subtree that will have access to the glass accessibility data.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final data = GlassAccessibilityData(
      reduceMotion: reduceMotion ?? _systemReduceMotion(context),
      reduceTransparency:
          reduceTransparency ?? MediaQuery.highContrastOf(context),
    );

    return _InheritedGlassAccessibility(
      data: data,
      child: child,
    );
  }
}

/// Internal InheritedWidget that carries [GlassAccessibilityData] down the tree.
class _InheritedGlassAccessibility extends InheritedWidget {
  const _InheritedGlassAccessibility({
    required this.data,
    required super.child,
  });

  final GlassAccessibilityData data;

  @override
  bool updateShouldNotify(_InheritedGlassAccessibility oldWidget) =>
      data != oldWidget.data;
}
