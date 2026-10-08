import 'package:flutter/widgets.dart';
import '../src/renderer/liquid_glass_renderer.dart';

/// Theme-level configuration for glass widget interaction physics.
///
/// Controls how glass buttons and chips respond to touch — the jelly-like
/// squash & stretch, press scaling, and drag resistance that replicate
/// iOS 26 button behaviour.
///
/// This class lives on [GlassThemeData] (not per-brightness [GlassThemeVariant])
/// because interaction physics don't change between light and dark mode.
///
/// ## Resolution order
///
/// Each interactive glass widget resolves its interaction parameters as:
///
/// **explicit widget parameter > theme > hardcoded default**
///
/// This matches Flutter's standard pattern (like [TextStyle] resolution).
///
/// ## Usage
///
/// ### Set globally via theme:
/// ```dart
/// GlassTheme(
///   data: GlassThemeData(
///     interaction: GlassInteractionSettings(
///       stretch: 0.2,        // subtler stretch globally
///       interactionScale: 1.15, // less inflation on press
///     ),
///   ),
///   child: child!,
/// )
/// ```
///
/// ### Disable stretch app-wide:
/// ```dart
/// GlassTheme(
///   data: GlassThemeData(
///     interaction: GlassInteractionSettings(
///       stretch: 0.0,  // no drag-following, keeps press-scale
///     ),
///   ),
///   child: child!,
/// )
/// ```
///
/// ### Per-button override still works:
/// ```dart
/// GlassButton(
///   stretch: 0.8,  // overrides the theme's 0.2
///   icon: Icon(CupertinoIcons.play),
///   onTap: () {},
/// )
/// ```
@immutable
class GlassInteractionSettings {
  /// Creates interaction settings for glass widgets.
  ///
  /// All values are optional. When null, the widget's own hardcoded default
  /// is used (preserving backward compatibility). When set, the value acts
  /// as a theme-level default that individual widgets can override.
  const GlassInteractionSettings({
    this.stretch,
    this.interactionScale,
    this.resistance,
    this.anchorStretch,
    this.anchorStretchSettings,
  });

  /// Default interaction settings — all null, meaning each widget uses
  /// its own hardcoded default.
  static const GlassInteractionSettings defaults = GlassInteractionSettings();

  /// The factor to multiply the drag offset by to determine the stretch
  /// amount in pixels.
  ///
  /// - `0.0` = no drag-following (keeps press-scale effect)
  /// - `0.5` (widget default) = balanced natural stretch
  /// - `1.0` = matches drag offset exactly (usually too much)
  ///
  /// When `null`, each widget uses its own default (typically `0.5`).
  final double? stretch;

  /// The scale factor applied when the user presses the widget.
  ///
  /// - `1.0` = no scaling
  /// - `1.15` = a fixed 15% grow on press
  /// - `1.3` = a fixed 30% grow on press
  ///
  /// When `null`, each widget uses its own default — [GlassButton] sizes the
  /// press as iOS 26 does, growing its longest side by ~17 pt (1.3× for a
  /// 56 pt circle, 1.13× for a 132 pt pill); chips, sheets and menus use
  /// small fixed factors.
  final double? interactionScale;

  /// The resistance factor applied to the drag offset.
  ///
  /// Higher values make the drag feel heavier/stickier. Uses non-linear
  /// damping that increases with distance from rest.
  ///
  /// When `null`, each widget uses its own default (typically `0.01`).
  final double? resistance;

  /// Whether the stretch anchors the widget in place.
  ///
  /// - `true` (widget default): Widget stays fixed, elongates toward finger
  ///   (iOS 26 button behaviour)
  /// - `false`: Widget follows the finger (jelly-follow mode)
  ///
  /// When `null`, each widget uses its own default (typically `true`).
  final bool? anchorStretch;

  /// Fine-tuning for the anchor stretch effect.
  ///
  /// Controls intensity, squash, translation damping, and bounciness.
  ///
  /// When `null`, [GlassButton] uses a native tremor default — very gentle
  /// (intensity 0.1, squash 0.1, no bounce), matching the ≤5% elongation
  /// measured on iOS 26 glass. Other widgets fall back to their own defaults.
  final AnchorStretchSettings? anchorStretchSettings;

  /// Creates a copy with overridden values.
  GlassInteractionSettings copyWith({
    double? stretch,
    double? interactionScale,
    double? resistance,
    bool? anchorStretch,
    AnchorStretchSettings? anchorStretchSettings,
  }) {
    return GlassInteractionSettings(
      stretch: stretch ?? this.stretch,
      interactionScale: interactionScale ?? this.interactionScale,
      resistance: resistance ?? this.resistance,
      anchorStretch: anchorStretch ?? this.anchorStretch,
      anchorStretchSettings:
          anchorStretchSettings ?? this.anchorStretchSettings,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlassInteractionSettings &&
          runtimeType == other.runtimeType &&
          stretch == other.stretch &&
          interactionScale == other.interactionScale &&
          resistance == other.resistance &&
          anchorStretch == other.anchorStretch &&
          anchorStretchSettings == other.anchorStretchSettings;

  @override
  int get hashCode => Object.hash(
        stretch,
        interactionScale,
        resistance,
        anchorStretch,
        anchorStretchSettings,
      );
}
