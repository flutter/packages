import 'package:flutter/widgets.dart';

/// Defines the visual placement state of a [GlassTabBar] bottom accessory.
///
/// This mirrors iOS 26's `TabViewBottomAccessoryPlacement` exactly, providing
/// the state machine needed for an accessory (like a mini-player) to adapt
/// its layout when the tab bar minimizes.
enum GlassTabBarAccessoryPlacement {
  /// The tab bar is in its normal, full-height state. The accessory should
  /// render as a full row sitting above the glass pill.
  expanded,

  /// The tab bar has been minimized (e.g. via scroll). The accessory should
  /// collapse into a compact horizontal strip that fits inside the minimized
  /// bar's footprint.
  inline,
}

/// Resolves the placement an accessory should actually render at.
///
/// An [explicit] value always wins. When it is null the placement follows the
/// bar: a minimized [GlassTabBar.minimizable] pulls its accessory [inline],
/// matching how iOS 26 animates a `tabViewBottomAccessory` down into the bar
/// as it minimizes.
///
/// Only the minimizable placement auto-resolves. `GlassTabBar.searchable`
/// keeps its accessory [expanded] while the search field is open — a search
/// bar expanding is not the bar minimizing, and auto-collapsing on search was
/// removed deliberately in 0.x because it hid the mini-player behind the
/// search capsule.
///
/// This is the single authoritative resolution, and both callers must use it:
/// [GlassTabBar.preferredSize], which tells the scaffold how tall the bar is,
/// and the searchable layout engine, which renders it. If those two ever
/// disagree the scaffold's body inset desyncs from what is actually drawn.
GlassTabBarAccessoryPlacement resolveAccessoryPlacement({
  required GlassTabBarAccessoryPlacement? explicit,
  required bool minimized,
  required bool isMinimizablePlacement,
}) {
  if (explicit != null) return explicit;
  return isMinimizablePlacement && minimized
      ? GlassTabBarAccessoryPlacement.inline
      : GlassTabBarAccessoryPlacement.expanded;
}

/// Provides the current [GlassTabBarAccessoryPlacement] to the widget tree.
///
/// This is the Flutter equivalent of SwiftUI's
/// `@Environment(\.tabViewBottomAccessoryPlacement)`.
///
/// Read it inside your accessory widget to adapt your layout:
/// ```dart
/// final placement = GlassTabBarAccessoryPlacementScope.of(context);
/// return switch (placement) {
///   GlassTabBarAccessoryPlacement.expanded => FullPlayer(),
///   GlassTabBarAccessoryPlacement.inline => CompactPlayer(),
/// };
/// ```
class GlassTabBarAccessoryPlacementScope extends InheritedWidget {
  /// Creates a scope that provides the placement state to descendants.
  const GlassTabBarAccessoryPlacementScope({
    required this.placement,
    required super.child,
    super.key,
  });

  /// The current placement state.
  final GlassTabBarAccessoryPlacement placement;

  /// Retrieves the closest [GlassTabBarAccessoryPlacement] from the tree.
  ///
  /// Defaults to [GlassTabBarAccessoryPlacement.expanded] if no scope is found.
  static GlassTabBarAccessoryPlacement of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<
        GlassTabBarAccessoryPlacementScope>();
    return scope?.placement ?? GlassTabBarAccessoryPlacement.expanded;
  }

  @override
  bool updateShouldNotify(GlassTabBarAccessoryPlacementScope oldWidget) {
    return placement != oldWidget.placement;
  }
}
