import 'package:flutter/cupertino.dart';
import '../../src/renderer/liquid_glass_renderer.dart';

import '../../theme/glass_theme.dart';
import '../../types/glass_button_style.dart';
import '../../types/glass_quality.dart';
import '../containers/glass_container.dart';
import '../overlays/glass_menu.dart';
import 'glass_button.dart';
import '../../theme/glass_theme_helpers.dart';
import '../shared/glass_focus_region.dart';
import '../shared/glass_interaction_state_mixin.dart';

// =============================================================================
// GlassButtonGroupItem — lightweight data model
// =============================================================================

/// A lightweight data class representing a single item in a [GlassButtonGroup].
///
/// Unlike [GlassButton], a [GlassButtonGroupItem] carries no widget state — no
/// animation controllers, no stretch physics, no glow overlays. The parent
/// [GlassButtonGroup] provides the glass surface and renders each item as a
/// simple icon with a press-dim highlight.
///
/// ## Basic tap item
///
/// ```dart
/// GlassButtonGroup.icons(
///   items: [
///     GlassButtonGroupItem(icon: Icon(CupertinoIcons.bold), onTap: () {}),
///     GlassButtonGroupItem(icon: Icon(CupertinoIcons.italic), onTap: () {}),
///     GlassButtonGroupItem(icon: Icon(CupertinoIcons.underline), onTap: () {}),
///   ],
/// )
/// ```
///
/// ## Menu item (iOS 26 UIBarButtonItem.menu equivalent)
///
/// Use [GlassButtonGroupItem.menu] to make an item open a [GlassMenu] pull-down
/// when tapped. This mirrors `UIBarButtonItem.menu` within a `UIBarButtonItemGroup`.
///
/// ```dart
/// GlassButtonGroup.icons(
///   items: [
///     GlassButtonGroupItem(icon: Icon(CupertinoIcons.chart_bar), onTap: () {}),
///     GlassButtonGroupItem.menu(
///       icon: Icon(CupertinoIcons.ellipsis),
///       menuItems: [
///         GlassMenuItem(title: 'Copy', onTap: () {}),
///         GlassMenuDivider(),
///         GlassMenuItem(title: 'Delete', isDestructive: true, onTap: () {}),
///       ],
///     ),
///   ],
/// )
/// ```
class GlassButtonGroupItem {
  // No-op used by GlassButtonGroupItem.menu so onTap is always non-null.
  static void _noOp() {}

  /// Creates a group item with an icon and tap callback.
  const GlassButtonGroupItem({
    required this.icon,
    required this.onTap,
    this.label,
    this.enabled = true,
  })  : menuItems = null,
        menuAlignment = null,
        menuWidth = 200,
        menuHeight = null;

  /// Creates a group item that opens a [GlassMenu] pull-down when tapped.
  ///
  /// This is the Flutter equivalent of `UIBarButtonItem.menu` inside a
  /// `UIBarButtonItemGroup` — the standard iOS 26 pattern for toolbar
  /// buttons that reveal a list of actions.
  ///
  /// [menuItems] accepts both [GlassMenuItem] and [GlassMenuDivider] widgets,
  /// matching the [GlassMenu.items] contract directly.
  ///
  /// [menuAlignment] controls where the menu expands relative to the trigger.
  /// Defaults to auto-detection based on screen position.
  ///
  /// [menuWidth] is the width of the expanded menu panel. Defaults to 200.
  ///
  /// [menuHeight] is an optional fixed height for the expanded menu panel.
  const GlassButtonGroupItem.menu({
    required this.icon,
    required List<Widget> this.menuItems,
    this.menuAlignment,
    this.menuWidth = 200,
    this.menuHeight,
    this.label,
  })  : onTap = _noOp,
        enabled = true;

  /// The icon widget to display.
  ///
  /// Typically an [Icon] or [CupertinoIcons] icon widget. The parent [GlassButtonGroup]
  /// wraps this in an [IconTheme] that sets size and color based on the
  /// current brightness.
  final Widget icon;

  /// Called when the item is tapped.
  ///
  /// Not used when [menuItems] is non-null — the tap opens the menu instead.
  final VoidCallback onTap;

  /// Optional semantic label for accessibility.
  ///
  /// If provided, wraps the item in [Semantics] with `button: true`.
  final String? label;

  /// Whether the item is interactive.
  ///
  /// When false, the item renders at 50% opacity and ignores taps.
  final bool enabled;

  /// When non-null, tapping this item opens a [GlassMenu] pull-down.
  ///
  /// Accepts [GlassMenuItem] and [GlassMenuDivider] widgets. Set via
  /// [GlassButtonGroupItem.menu].
  final List<Widget>? menuItems;

  /// Controls where the menu expands relative to the trigger button.
  ///
  /// Defaults to auto-detection. Set via [GlassButtonGroupItem.menu].
  final GlassMenuAlignment? menuAlignment;

  /// Width of the expanded menu panel in logical pixels.
  ///
  /// Defaults to 200. Set via [GlassButtonGroupItem.menu].
  final double menuWidth;

  /// Optional fixed height for the expanded menu panel in logical pixels.
  final double? menuHeight;
}

// =============================================================================
// GlassButtonGroup
// =============================================================================

/// A container that groups multiple buttons in a single glass pill.
///
/// ## Two usage modes
///
/// ### 1. Lightweight items (recommended)
///
/// Use [GlassButtonGroup.icons] with [GlassButtonGroupItem] data objects. Each item
/// is rendered as a minimal icon with tap handling — no animation controllers
/// or glass shaders per item. The group provides the glass surface.
///
/// ```dart
/// GlassButtonGroup.icons(
///   items: [
///     GlassButtonGroupItem(icon: Icon(CupertinoIcons.text_alignleft), onTap: () {}),
///     GlassButtonGroupItem(icon: Icon(CupertinoIcons.trash), onTap: () {}),
///     GlassButtonGroupItem(icon: Icon(CupertinoIcons.add), onTap: () {}),
///   ],
/// )
/// ```
///
/// ### 2. Full widget children
///
/// Use the default constructor with [GlassButton] children for full control
/// over each button's style, stretch, and glow.
///
/// ```dart
/// GlassButtonGroup(
///   children: [
///     GlassButton(icon: Icon(CupertinoIcons.bold), style: GlassButtonStyle.transparent, onTap: () {}),
///     GlassButton(icon: Icon(CupertinoIcons.italic), style: GlassButtonStyle.transparent, onTap: () {}),
///   ],
/// )
/// ```
class GlassButtonGroup extends StatelessWidget {
  /// Creates a group of glass buttons from widget children.
  ///
  /// Children should be [GlassButton]s with [GlassButtonStyle.transparent].
  /// For a lighter-weight alternative, use [GlassButtonGroup.icons].
  const GlassButtonGroup({
    required this.children,
    super.key,
    this.direction = Axis.horizontal,
    this.settings,
    this.quality,
    this.borderRadius = 16.0,
    this.borderColor,
    this.useOwnLayer = false,
    this.showDividers = true,
    this.iconSize = 22.0,
    this.itemPadding = const EdgeInsets.all(12),
    this.platformViewBackdrop = false,
  }) : items = null;

  /// Creates a group of glass buttons from lightweight [GlassButtonGroupItem]s.
  ///
  /// Each item is rendered as a simple icon with press-dim feedback — no
  /// animation controllers, stretch physics, or glow overlays. The group
  /// provides the glass surface.
  ///
  /// Defaults to `showDividers: false` and `borderRadius: 22.0` for the
  /// unified pill look shown in iOS 26 toolbar groups.
  const GlassButtonGroup.icons({
    required List<GlassButtonGroupItem> this.items,
    super.key,
    this.direction = Axis.horizontal,
    this.settings,
    this.quality,
    this.borderRadius = 22.0,
    this.borderColor,
    this.useOwnLayer = false,
    this.showDividers = false,
    this.iconSize = 22.0,
    this.itemPadding = const EdgeInsets.all(12),
    this.platformViewBackdrop = false,
  }) : children = const [];

  /// The buttons to display in the group (widget children mode).
  ///
  /// Ideally, these should be [GlassButton]s with [GlassButtonStyle.transparent].
  /// Empty when using [GlassButtonGroup.icons].
  final List<Widget> children;

  /// Lightweight item data for icon-based groups.
  ///
  /// When non-null, [children] is ignored and items are rendered internally
  /// as lightweight icons with press-dim feedback.
  final List<GlassButtonGroupItem>? items;

  /// Direction to arrange buttons (horizontal or vertical).
  final Axis direction;

  /// Custom glass settings.
  final LiquidGlassSettings? settings;

  /// Quality of glass effect.
  final GlassQuality? quality;

  /// Border radius of the group container.
  final double borderRadius;

  /// Color of the dividers between buttons.
  ///
  /// Defaults to a semi-transparent black or white depending on brightness.
  final Color? borderColor;

  /// Whether to create its own glass layer.
  final bool useOwnLayer;

  /// Whether to show dividers between buttons.
  ///
  /// Defaults to `true` for the [GlassButtonGroup] constructor,
  /// `false` for [GlassButtonGroup.icons].
  final bool showDividers;

  /// The icon size used for items in [GlassButtonGroup.icons] mode.
  ///
  /// Defaults to 22.0.
  final double iconSize;

  /// Padding around each item in [GlassButtonGroup.icons] mode.
  ///
  /// Defaults to `EdgeInsets.all(12)`.
  final EdgeInsetsGeometry itemPadding;

  /// Forces the BackdropFilter fallback render path so premium glass
  /// renders cleanly over an iOS PlatformView.
  ///
  /// The premium shader pipeline cannot sample PlatformView pixels (e.g.
  /// a Mapbox `MapWidget`), so over one it would render the group as a
  /// solid slab. When true, the group falls back to Flutter's
  /// BackdropFilter — which *can* sample PlatformViews on Impeller — so
  /// `quality: GlassQuality.premium` can be used over a PlatformView
  /// without the slab artifact. Forwarded to the underlying
  /// [GlassButton.custom] (items mode) / [GlassContainer] (children mode).
  /// Defaults to false.
  final bool platformViewBackdrop;

  @override
  Widget build(BuildContext context) {
    final effectiveQuality = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: quality,
    );

    // Resolve icon color from brightness.
    final iconColor = CupertinoColors.label.resolveFrom(context);

    // ---------------------------------------------------------------------------
    // Items mode: use a GlassButton.custom as the parent shell.
    //
    // This gives the whole pill stretch, glow, saturation, and shadow for free
    // via existing GlassButton infrastructure — one AnimationController for the
    // entire group instead of one per icon. Individual items handle their own
    // tap targets with lightweight GestureDetectors.
    //
    // When any item has menuItems, the ENTIRE pill becomes the GlassMenu trigger
    // so the whole shape morphs into the menu on tap — matching the iOS 26
    // GlassEffectContainer morph pattern. Only the first menu item is used as
    // the menu trigger; subsequent menu items are treated as plain tap items.
    // ---------------------------------------------------------------------------
    if (items != null) {
      final shape = LiquidRoundedRectangle(borderRadius: borderRadius);
      final menuItemIndex = items!.indexWhere((item) => item.menuItems != null);

      // Helper that builds the pill shell — reused in both branches.
      Widget buildPill({
        VoidCallback? menuToggle,
      }) {
        return GlassButton.custom(
          onTap: () {}, // Items handle their own taps
          shape: shape,
          settings: settings,
          useOwnLayer: useOwnLayer,
          quality: effectiveQuality,
          platformViewBackdrop: platformViewBackdrop,
          canRequestFocus:
              false, // The outer pill doesn't take focus, individual items do.
          excludeFromSemantics:
              true, // Hide the outer pill from semantics so inner items don't merge into it
          width: null, // Size to content
          height: null, // Size to content
          // Reduce stretch for grouped buttons — full stretch looks too dramatic
          // on a wide pill. This matches iOS 26 toolbar feel.
          stretch: 0.15,
          child: IntrinsicHeight(
            child: Flex(
              direction: direction,
              mainAxisSize: MainAxisSize.min,
              children: _buildItemWidgets(
                iconColor,
                menuToggle: menuToggle,
                menuItemIndex: menuItemIndex,
              ),
            ),
          ),
        );
      }

      if (menuItemIndex >= 0) {
        final menuItem = items![menuItemIndex];
        // Wrap the ENTIRE pill in GlassMenu so the whole shape morphs.
        return GlassMenu(
          menuAlignment: menuItem.menuAlignment,
          menuWidth: menuItem.menuWidth,
          menuHeight: menuItem.menuHeight,
          items: menuItem.menuItems!,
          triggerBuilder: (context, toggleMenu) =>
              buildPill(menuToggle: toggleMenu),
        );
      }

      return buildPill();
    }

    // ---------------------------------------------------------------------------
    // Children mode: use GlassContainer for full widget flexibility.
    // ---------------------------------------------------------------------------
    final effectiveBorderColor = borderColor ??
        (GlassTheme.brightnessOf(context) == Brightness.light
            ? CupertinoColors.black.withValues(alpha: 0.12)
            : CupertinoColors.white.withValues(alpha: 0.12));

    return GlassContainer(
      useOwnLayer: useOwnLayer,
      quality: effectiveQuality,
      settings: settings,
      platformViewBackdrop: platformViewBackdrop,
      shape: LiquidRoundedRectangle(borderRadius: borderRadius),
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Flex(
          direction: direction,
          mainAxisSize: MainAxisSize.min,
          children: _buildChildrenWithDividers(effectiveBorderColor),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Items mode — lightweight icons with press-dim highlight
  // ---------------------------------------------------------------------------

  List<Widget> _buildItemWidgets(
    Color iconColor, {
    VoidCallback? menuToggle,
    int? menuItemIndex,
  }) {
    final itemList = items!;
    final List<Widget> widgets = [];

    for (int i = 0; i < itemList.length; i++) {
      if (showDividers && i > 0) {
        widgets.add(
          direction == Axis.horizontal
              ? Container(width: 1, color: iconColor.withValues(alpha: 0.12))
              : Container(height: 1, color: iconColor.withValues(alpha: 0.12)),
        );
      }

      final item = itemList[i];
      // Menu item slot: route its tap to toggleMenu so the whole pill morphs.
      final isMenuTrigger = menuToggle != null && i == menuItemIndex;
      widgets.add(
        _GlassGroupItemWidget(
          item: item,
          iconColor: iconColor,
          iconSize: iconSize,
          padding: itemPadding,
          onTapOverride: isMenuTrigger ? menuToggle : null,
        ),
      );
    }
    return widgets;
  }

  // ---------------------------------------------------------------------------
  // Children mode — full widget children with optional dividers
  // ---------------------------------------------------------------------------

  List<Widget> _buildChildrenWithDividers(Color resolvedBorderColor) {
    if (!showDividers) {
      return children;
    }

    final List<Widget> result = [];
    for (int i = 0; i < children.length; i++) {
      if (i > 0) {
        result.add(
          direction == Axis.horizontal
              ? Container(width: 1, color: resolvedBorderColor)
              : Container(height: 1, color: resolvedBorderColor),
        );
      }
      result.add(children[i]);
    }
    return result;
  }
}

// =============================================================================
// _GlassGroupItemWidget — lightweight per-item tap target
// =============================================================================

/// Renders a single [GlassButtonGroupItem] as a minimal tap target.
///
/// The parent [GlassButton.custom] provides all visual press feedback
/// (stretch, glow, saturation). This widget only handles individual tap
/// routing and accessibility semantics.
class _GlassGroupItemWidget extends StatefulWidget {
  const _GlassGroupItemWidget({
    required this.item,
    required this.iconColor,
    required this.iconSize,
    required this.padding,
    this.onTapOverride,
  });

  final GlassButtonGroupItem item;
  final Color iconColor;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  /// When non-null, replaces [GlassButtonGroupItem.onTap] as the tap handler.
  ///
  /// Used for menu-trigger items to call the enclosing [GlassMenu]'s
  /// toggleMenu callback so the whole pill morphs rather than the slot.
  final VoidCallback? onTapOverride;

  @override
  State<_GlassGroupItemWidget> createState() => _GlassGroupItemWidgetState();
}

class _GlassGroupItemWidgetState extends State<_GlassGroupItemWidget>
    with GlassInteractionStateMixin {
  // isHovered is provided by GlassInteractionStateMixin.

  @override
  Widget build(BuildContext context) {
    return GlassFocusRegion(
      enabled: widget.item.enabled,
      isButton: true,
      semanticLabel: widget.item.label,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      isHoveredNotifier: isHovered,
      onKeyboardActivate: widget.item.enabled
          ? (widget.onTapOverride ?? widget.item.onTap)
          : null,
      semanticOnTap: widget.item.enabled
          ? (widget.onTapOverride ?? widget.item.onTap)
          : null,
      child: GestureDetector(
        onTap: widget.item.enabled
            ? (widget.onTapOverride ?? widget.item.onTap)
            : null,
        behavior: HitTestBehavior.opaque,
        // Semantics (label, role, tap) live on the GlassFocusRegion node.
        excludeFromSemantics: true,
        child: ValueListenableBuilder<bool>(
          valueListenable: isHovered,
          builder: (context, isHov, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              // 10% white overlay on hover — matches GlassMenuItem's hover
              // response exactly, giving consistent feedback across all
              // "item inside a container" widgets.
              color: (isHov && widget.item.enabled)
                  ? const Color(0x1AFFFFFF)
                  : const Color(0x00000000),
              child: Opacity(
                opacity: widget.item.enabled ? 1.0 : 0.5,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: widget.padding,
            child: IconTheme(
              data: IconThemeData(
                color: widget.iconColor,
                size: widget.iconSize,
              ),
              child: widget.item.icon,
            ),
          ),
        ),
      ),
    );
  }
}
