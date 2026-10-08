import 'package:flutter/widgets.dart';
import '../../src/renderer/liquid_glass_renderer.dart';
import '../../liquid_glass_setup.dart';
import '../../types/glass_quality.dart';

/// A custom inherited widget that provides [LiquidGlassSettings] to descendants.
///
/// This is used by [AdaptiveLiquidGlassLayer] to ensure that settings are
/// passed down to children even when the underlying renderer is using a
/// fallback implementation (like `LightweightLiquidGlass` on Skia/Web) that
/// might not have its own inherited widget provider exposed.
class InheritedLiquidGlass extends InheritedWidget {
  /// Creates an inherited widget that holds [LiquidGlassSettings].
  const InheritedLiquidGlass({
    required this.settings,
    this.quality = GlassQuality.standard,
    this.isBlurProvidedByAncestor = false,
    this.avoidsRefraction = false,
    required super.child,
    super.key,
  });

  /// The glass settings to share with the subtree.
  final LiquidGlassSettings settings;

  /// The rendering quality to share with the subtree.
  final GlassQuality quality;

  /// Whether a parent layer is already providing the backdrop blur.
  /// Used for performance optimization to avoid redundant BackdropFilters.
  final bool isBlurProvidedByAncestor;

  /// Whether children should avoid high-fidelity refraction.
  /// Set to true by containers like GlassCard to prevent refraction artifacts
  /// when glass is nested within glass.
  final bool avoidsRefraction;

  /// Retrieves the nearest [LiquidGlassSettings] from the ancestor tree.
  ///
  /// This checks for [InheritedLiquidGlass] first. If not found, it attempts
  /// to look up `LiquidGlassSettings.of(context)` from the renderer package
  /// to maintain compatibility with standard `LiquidGlassLayer` usage.
  static LiquidGlassSettings? of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<InheritedLiquidGlass>();
    if (inherited != null) {
      return inherited.settings;
    }

    // Fallback to the renderer's provider if available
    try {
      return LiquidGlassSettings.of(context);
    } catch (_) {
      // LiquidGlassSettings.of() might throw or return default if not found,
      // dependent on implementation. We return null if we can't find it.
      return null;
    }
  }

  /// Retrieves the [LiquidGlassSettings] from the ancestor tree, falling back to
  /// [LiquidGlassWidgets.globalSettings] or a default instance if none is found.
  static LiquidGlassSettings ofOrDefault(BuildContext context) {
    return of(context) ??
        LiquidGlassWidgets.globalSettings ??
        const LiquidGlassSettings();
  }

  @override
  bool updateShouldNotify(InheritedLiquidGlass oldWidget) {
    return settings != oldWidget.settings ||
        quality != oldWidget.quality ||
        isBlurProvidedByAncestor != oldWidget.isBlurProvidedByAncestor ||
        avoidsRefraction != oldWidget.avoidsRefraction;
  }
}
