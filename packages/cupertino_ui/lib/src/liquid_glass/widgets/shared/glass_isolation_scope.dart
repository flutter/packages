import 'package:flutter/widgets.dart';

import '../../types/glass_quality.dart';

/// An [InheritedWidget] that tells descendant glass widgets whether to use
/// their own independent glass rendering layer or share the nearest ancestor's.
///
/// This is a zero-cost scope marker — it doesn't create any glass rendering
/// context, shader, or compositing layer. It simply provides a signal that
/// descendant [AdaptiveGlass] widgets check to decide whether to use
/// `useOwnLayer: true`.
///
/// ## Two roles
///
/// 1. **Quality hint** (`defaultQuality`) — tells descendants to default to a
///    given quality without explicit params. Zero cost (InheritedWidget lookup).
///
/// 2. **Layer isolation** (`isolated: true`) — forces descendants to create
///    their own glass layer via `useOwnLayer: true`. Useful when glass surfaces
///    from different z-layers would otherwise share a blend group incorrectly.
///    Adds GPU cost (separate backdrop capture per layer).
///
/// ## How GlassScaffold uses this
///
/// [GlassScaffold] wraps app bar and bottom bar in
/// `GlassIsolationScope(isolated: true, defaultQuality: premium)`.
/// This provides the quality hint so buttons default to premium, and forces
/// all glass surfaces in the bar to create their own layer by default.
/// This prevents Z-order tearing where grouped glass backgrounds paint
/// behind the scrolling body text but foregrounds paint on top.
///
/// ```
/// GlassScaffold → GlassPage → AdaptiveLiquidGlassLayer (page blend group)
///   → body cards → join page blend group (grouped)
///   → GlassIsolationScope(isolated: true, defaultQuality: premium) ← bar
///     → GlassButton in app bar → uses own layer ✅
///     → GlassTabBar.searchable (provides its own isolated: false scope)
///       → BottomBarExtraBtn → joins bottom bar blend group ✅
/// ```
///
/// For advanced scenarios where isolation is NOT needed (e.g. built-in bottom
/// bars that provide their own layer), the child widget can simply override
/// the scope by providing its own `GlassIsolationScope(isolated: false)`.
class GlassIsolationScope extends InheritedWidget {
  /// Creates a glass isolation scope.
  ///
  /// When [isolated] is `true` (default), descendant glass widgets render
  /// with their own independent layer. When `false`, they participate in the
  /// nearest ancestor [AdaptiveLiquidGlassLayer]'s grouped rendering.
  ///
  /// [defaultQuality] provides a quality hint for descendants that don't
  /// specify an explicit quality. This is separate from [isolated] — a scope
  /// can be de-isolated (for grouping) while still providing a premium
  /// quality default.
  const GlassIsolationScope({
    super.key,
    this.isolated = true,
    this.defaultQuality,
    required super.child,
  });

  /// Whether descendants should be isolated from ancestor glass layers.
  final bool isolated;

  /// Default quality hint for descendants that don't specify explicit quality.
  ///
  /// When set, [GlassThemeHelpers.resolveQuality] uses this as the fallback
  /// instead of [GlassQuality.standard]. This allows bar surfaces to default
  /// all their children to premium quality without requiring explicit
  /// `quality: GlassQuality.premium` on each widget.
  ///
  /// [GlassAdaptiveScope] ceiling still caps this on low-end devices.
  final GlassQuality? defaultQuality;

  /// Returns `true` if the given [context] is inside an active
  /// [GlassIsolationScope] with `isolated: true`.
  ///
  /// Used by [AdaptiveGlass] to decide whether to force `useOwnLayer: true`.
  static bool isIsolated(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<GlassIsolationScope>();
    return scope?.isolated ?? false;
  }

  /// Returns the [defaultQuality] from the nearest [GlassIsolationScope],
  /// or `null` if none is set.
  static GlassQuality? defaultQualityOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<GlassIsolationScope>();
    return scope?.defaultQuality;
  }

  @override
  bool updateShouldNotify(GlassIsolationScope oldWidget) =>
      isolated != oldWidget.isolated ||
      defaultQuality != oldWidget.defaultQuality;
}
