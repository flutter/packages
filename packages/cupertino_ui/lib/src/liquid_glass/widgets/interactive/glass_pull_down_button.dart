import 'package:flutter/cupertino.dart';

import '../../types/glass_quality.dart';
import '../overlays/glass_menu.dart';
import '../overlays/glass_menu_item.dart';
import 'glass_button.dart';
import '../../theme/glass_theme_helpers.dart';
import '../../src/engine/liquid_shape.dart';

/// A toolbar button that opens a liquid glass pull-down menu.
///
/// This widget combines [GlassButton] and [GlassMenu] to create a standard
/// "pull-down" interaction pattern commonly used in toolbars and navigation bars.
class GlassPullDownButton extends StatelessWidget {
  /// Creates a glass pull-down button.
  const GlassPullDownButton({
    required this.items,
    Widget? icon,
    this.label,
    this.semanticLabel,
    super.key,
    this.buttonWidth = 44,
    this.buttonHeight = 44,
    this.buttonShape,
    this.menuWidth = 200,
    this.menuAlignment,
    this.quality,
    this.onSelected,
    this.enableContinuousSwipe = true,
    this.continuousSwipeSlop = 10.0,
  }) : icon = icon ?? const Icon(CupertinoIcons.ellipsis_circle);

  /// The shape of the trigger button.
  ///
  /// If null, defaults to [LiquidOval].
  final LiquidShape? buttonShape;

  /// The icon widget to display on the button.
  final Widget icon;

  /// Optional label to display next to the icon.
  final String? label;

  /// VoiceOver / TalkBack label for icon-only variants.
  ///
  /// Ignored when [label] is non-null (the visible text already serves as the
  /// accessibility label). When the button shows only an icon and [label] is
  /// null, the default announcement is an empty string — use [semanticLabel]
  /// to give it a meaningful name:
  ///
  /// ```dart
  /// GlassPullDownButton(
  ///   icon: Icon(CupertinoIcons.ellipsis_circle),
  ///   semanticLabel: 'More options',
  ///   items: [...],
  /// )
  /// ```
  final String? semanticLabel;

  /// The list of items to display in the menu.
  ///
  /// Accepts [GlassMenuItem] and [GlassMenuDivider] widgets, matching the
  /// [GlassMenu.items] contract directly. [GlassMenuDivider] items are passed
  /// through as-is; only [GlassMenuItem] instances are wrapped by [onSelected].
  final List<Widget> items;

  /// Width of the trigger button.
  final double buttonWidth;

  /// Height of the trigger button.
  final double buttonHeight;

  /// Width of the expanded menu.
  final double menuWidth;

  /// Controls where the menu expands relative to the trigger button.
  ///
  /// Defaults to [GlassMenuAlignment.none], which auto-detects the best
  /// alignment based on the trigger's position on screen.
  final GlassMenuAlignment? menuAlignment;

  /// Quality of the glass effect.
  final GlassQuality? quality;

  /// Callback when a menu item is selected.
  ///
  /// This is called in addition to the individual [GlassMenuItem.onTap] callback.
  final ValueChanged<String>? onSelected;

  /// Whether to enable iOS-style continuous swipe-to-select.
  ///
  /// When true, pressing down on the button opens the menu immediately and
  /// allows the user to slide to an item and release to activate it in a
  /// single continuous gesture without lifting their finger.
  ///
  /// Defaults to `true`.
  final bool enableContinuousSwipe;

  /// The movement slop in logical pixels required to arm continuous swipe.
  ///
  /// If the pointer is released within this distance of the initial touch-down,
  /// the gesture is treated as a tap and the menu remains open without
  /// selecting an item.
  ///
  /// Defaults to 10.0.
  final double continuousSwipeSlop;

  @override
  Widget build(BuildContext context) {
    // Inherit quality from parent layer if not explicitly set
    final effectiveQuality = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: quality,
    );

    final effectiveTextColor =
        CupertinoTheme.of(context).textTheme.textStyle.color ??
            CupertinoColors.label;

    return GlassMenu(
      menuWidth: menuWidth,
      menuAlignment: menuAlignment,
      quality: effectiveQuality,
      enableContinuousSwipe: enableContinuousSwipe,
      continuousSwipeSlop: continuousSwipeSlop,
      triggerBuilder: (context, toggleMenu) {
        if (label != null && label!.isNotEmpty) {
          return GlassButton.custom(
            onTap: toggleMenu,
            width: buttonWidth,
            height: buttonHeight,
            shape: buttonShape ?? const LiquidOval(),
            quality: effectiveQuality,
            useOwnLayer: effectiveQuality == GlassQuality.premium,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconTheme(
                  data: IconThemeData(size: 20, color: effectiveTextColor),
                  child: icon,
                ),
                const SizedBox(width: 8),
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: effectiveTextColor,
                  ),
                ),
              ],
            ),
          );
        }

        return GlassButton(
          onTap: toggleMenu,
          icon: icon,
          label: semanticLabel ?? label ?? '',
          width: buttonWidth,
          height: buttonHeight,
          shape: buttonShape ?? const LiquidOval(),
          quality: effectiveQuality,
          useOwnLayer: effectiveQuality == GlassQuality.premium,
        );
      },
      items: items.map((item) {
        // Wrap GlassMenuItem taps to fire the onSelected callback.
        // GlassMenuDivider and other non-GlassMenuItem widgets are passed through.
        if (onSelected != null && item is GlassMenuItem) {
          return GlassMenuItem(
            title: item.title,
            icon: item.icon,
            isDestructive: item.isDestructive,
            subtitle: item.subtitle,
            enabled: item.enabled,
            onTap: () {
              item.onTap.call();
              onSelected!(item.title);
            },
            trailing: item.trailing,
          );
        }
        return item;
      }).toList(),
    );
  }
}
