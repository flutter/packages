import 'package:flutter/widgets.dart';

import '../../interactive/glass_button.dart';
import '../../overlays/glass_menu.dart' show GlassMenuAlignment;

// =============================================================================
// Extra Button Configuration
// =============================================================================

/// Where a [GlassTabBarExtraButton] appears relative to the search pill
/// in a searchable tab bar.
///
/// Has no effect in non-searchable bottom tabs, where
/// [GlassExtraButtonPlacement] controls left/right placement instead.
enum GlassExtraButtonPosition {
  /// Place the button **before** the search pill — between the tab pill and
  /// the search pill. This is the default and matches the classic iOS
  /// "compose" button position seen in Mail and Messages.
  beforeSearch,

  /// Place the button **after** the search pill — pinned to the trailing
  /// (right) edge of the bar. Use this when you want a persistent action
  /// button that stays visible at the far right even while search is expanded.
  /// The search pill's spring calculations automatically reserve the required
  /// space so no RenderFlex overflow occurs during transitions.
  afterSearch,
}

/// Where a [GlassTabBarExtraButton] appears in a non-searchable
/// [GlassTabBar.bottom].
///
/// Defaults to [GlassExtraButtonPlacement.right], matching the original
/// bottom-bar layout.
enum GlassExtraButtonPlacement {
  /// Place the button on the physical left side of the bar, before the tabs.
  left,

  /// Place the button on the physical right side of the bar, after the tabs.
  right,
}

/// Configuration for the extra button in [GlassTabBar].
///
/// The extra button is rendered as a [GlassButton] and typically used for
/// primary actions like creating new content.
class GlassTabBarExtraButton {
  static void _noOp() {}

  /// Creates an extra button configuration.
  const GlassTabBarExtraButton({
    required this.icon,
    required this.onTap,
    required this.label,
    this.iconColor,
    this.size = 64,
    this.placement = GlassExtraButtonPlacement.right,
    this.position = GlassExtraButtonPosition.beforeSearch,
    this.collapseOnSearchFocus = true,
    this.enabled = true,
  })  : menuItems = null,
        menuAlignment = null,
        menuWidth = 200,
        menuHeight = null;

  /// Opens a [GlassMenu] pull-down when the extra button is tapped.
  ///
  /// The button morphs into the menu — the same liquid-spring behavior
  /// as [GlassButtonGroupItem.menu] and [GlassBarItem.menu]. Equivalent to
  /// a `UIBarButtonItem(image:menu:)` placed in a toolbar or tab bar.
  ///
  /// [menuItems] accepts [GlassMenuItem] and [GlassMenuDivider] widgets —
  /// the same contract as [GlassMenu.items].
  ///
  /// [menuAlignment] defaults to auto-detection, which for a bottom-of-screen
  /// button always expands upward.
  const GlassTabBarExtraButton.menu({
    required this.icon,
    required List<Widget> this.menuItems,
    required this.label,
    this.iconColor,
    this.size = 64,
    this.placement = GlassExtraButtonPlacement.right,
    this.position = GlassExtraButtonPosition.beforeSearch,
    this.collapseOnSearchFocus = true,
    this.enabled = true,
    this.menuAlignment,
    this.menuWidth = 200,
    this.menuHeight,
  }) : onTap = _noOp;

  /// Icon widget displayed in the button.
  final Widget icon;

  /// Callback when the button is tapped.
  final VoidCallback onTap;

  /// Accessibility label for the button.
  final String label;

  /// Color used for the button's icon.
  final Color? iconColor;

  /// Width and height of the button.
  ///
  /// Defaults to 64 to match the default bar height.
  final double size;

  /// Where this button is placed in [GlassTabBar.bottom].
  ///
  /// Defaults to [GlassExtraButtonPlacement.right], which preserves the
  /// original bottom-bar behavior. Set to [GlassExtraButtonPlacement.left] to
  /// place the action before the tab pill.
  ///
  /// Has no effect in searchable tab bars, where [position] controls
  /// placement relative to the search pill.
  final GlassExtraButtonPlacement placement;

  /// Where this button is placed relative to the search pill in a
  /// searchable tab bar.
  ///
  /// - [GlassExtraButtonPosition.beforeSearch] (default) — between the tab pill
  ///   and the search pill. Classic iOS pattern (Mail compose button).
  /// - [GlassExtraButtonPosition.afterSearch] — pinned to the right edge, after
  ///   the search pill. The search pill's spring calculations automatically
  ///   reserve space so no RenderFlex overflow occurs during transitions.
  final GlassExtraButtonPosition position;

  /// Whether this button collapses (hides + frees layout space) when the
  /// search field is focused (i.e. the keyboard is visible).
  ///
  /// When `true` (default), the button fades out and its horizontal layout
  /// space spring-animates to zero on keyboard appearance, giving the search
  /// input the full available width — matching native iOS system apps
  /// (Weather, App Store, Apple News).
  ///
  /// When `false`, the button remains fully visible and tappable alongside
  /// the search input. Use this for buttons with contextual relevance during
  /// active search (e.g. a "Filter" action that applies to search results).
  final bool collapseOnSearchFocus;

  /// Whether the button is interactive.
  ///
  /// When false, the button does not respond to taps. Defaults to true.
  final bool enabled;

  /// When non-null, tapping this button opens a [GlassMenu] pull-down.
  ///
  /// Accepts [GlassMenuItem] and [GlassMenuDivider] widgets. Set via
  /// [GlassTabBarExtraButton.menu].
  final List<Widget>? menuItems;

  /// Controls where the menu expands relative to the trigger button.
  ///
  /// Defaults to auto-detection (upward for bottom-bar placement). Set via
  /// [GlassTabBarExtraButton.menu].
  final GlassMenuAlignment? menuAlignment;

  /// Width of the expanded menu panel in logical pixels.
  ///
  /// Defaults to 200. Set via [GlassTabBarExtraButton.menu].
  final double menuWidth;

  /// Optional fixed height of the expanded menu panel in logical pixels.
  final double? menuHeight;

  /// Whether this button opens a menu rather than firing a tap callback.
  bool get isMenu => menuItems != null;
}
