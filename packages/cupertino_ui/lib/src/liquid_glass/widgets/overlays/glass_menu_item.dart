import 'package:flutter/cupertino.dart';
import '../shared/glass_focus_region.dart';
import '../shared/glass_interaction_state_mixin.dart';

/// A menu item for use within a [GlassMenu].
///
/// [GlassMenuItem] provides a standard layout for menu options, including
/// support for icons, labels, and "destructive" styling. It handles its own
/// hover and tap interactions with liquid glass effects.
class GlassMenuItem extends StatefulWidget {
  /// Creates a glass menu item.
  const GlassMenuItem({
    required this.title,
    required this.onTap,
    super.key,
    this.icon,
    this.isDestructive = false,
    this.trailing,
    this.height = 44.0,
    this.subtitle,
    this.isPressed,
    this.isSelected = false,
    this.enabled = true,
    this.titleStyle,
    this.subtitleStyle,
    this.iconColor,
    this.iconSize = 20.0,
    this.maxLines = 1,
    this.enablePressScale = true,
    this.closeDelay,
  });

  /// The primary text of the item.
  final String title;

  /// The icon widget displayed before the title.
  final Widget? icon;

  /// Optional subtitle text displayed below the title.
  final String? subtitle;

  /// Callback when the item is tapped.
  final VoidCallback onTap;

  /// Whether this is a destructive action (e.g., Delete).
  ///
  /// Renders with red text and distinct hover effect.
  final bool isDestructive;

  /// A widget to display after the title (e.g., shortcut key).
  final Widget? trailing;

  /// Height of the item.
  ///
  /// Defaults to 44.0 (standard iOS touch target).
  final double height;

  /// External override for the pressed state.
  final bool? isPressed;

  /// Whether the item is currently selected (e.g. by a sliding pill).
  final bool isSelected;

  /// Whether the item should handle its own interactions.
  final bool enabled;

  /// Custom text style for the title.
  final TextStyle? titleStyle;

  /// Custom text style for the subtitle.
  final TextStyle? subtitleStyle;

  /// Custom color for the icon.
  final Color? iconColor;

  /// Custom size for the icon.
  final double iconSize;

  /// Maximum number of lines for the title text.
  ///
  /// Defaults to 1. Set to 2 for longer labels like "Set Up Name & Photo".
  final int maxLines;

  /// Whether to apply the subtle scale-down animation on press.
  ///
  /// When `true` (default), the item shrinks to 0.98× on touch-down, matching
  /// the standard iOS press feedback. Set to `false` on fill-rate-limited
  /// devices to eliminate the per-frame GPU cost of animating a
  /// [Transform.scale] over the glass layer.
  ///
  /// Defaults to `true`.
  final bool enablePressScale;

  /// How long to wait after [onTap] fires before the menu begins closing.
  ///
  /// Defaults to `null` (close immediately). Set to a short duration such as
  /// `Duration(milliseconds: 320)` when the item hosts an animated [trailing]
  /// widget (e.g. a [GlassSwitch]) whose state transition should be visible
  /// before the menu morphs away.
  final Duration? closeDelay;

  @override
  State<GlassMenuItem> createState() => _GlassMenuItemState();
}

/// A separator line for use within a [GlassMenu].
class GlassMenuDivider extends StatelessWidget {
  /// The height of the divider area (line + spacing).
  final double height;

  /// Custom color for the divider line.
  final Color? color;

  /// Horizontal padding for the divider line.
  final double indent;

  /// Creates a glass menu divider.
  const GlassMenuDivider({
    super.key,
    this.height = 12.0,
    this.color,
    this.indent = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    // Resolve from theme's label color, falling back to text color at 15%
    final defaultLineColor =
        (theme.textTheme.tabLabelTextStyle.color ?? CupertinoColors.label)
            .withValues(alpha: 0.45);
    return SizedBox(
      height: height,
      child: Center(
        child: Container(
          height: 0.5,
          margin: EdgeInsets.symmetric(horizontal: indent),
          color: color ?? defaultLineColor,
        ),
      ),
    );
  }
}

/// A non-interactive label or content item for use within a [GlassMenu].
///
/// Use this for headers, section labels, or purely decorative content.
/// It does not respond to hover/press and is ignored by the selection pill.
class GlassMenuLabel extends StatelessWidget {
  /// The label text. If provided, renders stylized uppercase text.
  final String? title;

  /// The custom widget to display. Use this if [title] is null.
  final Widget? child;

  /// The height of the item.
  ///
  /// Defaults to 30.0 (aligned with author's fix to prevent pill-position drift).
  final double height;

  /// Override for the default caption text style. Only used if [title] is provided.
  final TextStyle? style;

  /// Horizontal padding for the content. Only used if [child] is provided.
  final double horizontalPadding;

  /// Optional alignment for the content. Defaults to [Alignment.centerLeft] if
  /// [title] is provided, or null (filling parent constraints) if [child] is provided.
  final AlignmentGeometry? alignment;

  /// Creates a glass menu label.
  const GlassMenuLabel({
    this.title,
    this.child,
    this.style,
    this.height = 30.0,
    this.horizontalPadding = 16.0,
    this.alignment,
    super.key,
  }) : assert(title != null || child != null,
            'Either title or child must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    // Use the theme's secondary label color for muted captions
    final defaultLabelColor = (theme.textTheme.tabLabelTextStyle.color ??
            CupertinoColors.secondaryLabel)
        .withValues(alpha: 0.45);
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      alignment: alignment ?? (title != null ? Alignment.centerLeft : null),
      child: child ??
          Text(
            title!.toUpperCase(),
            style: style ??
                TextStyle(
                  color: defaultLabelColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
          ),
    );
  }
}

class _GlassMenuItemState extends State<GlassMenuItem>
    with GlassInteractionStateMixin {
  // Interaction state (isPressed, isFocused, isHovered, allInteraction)
  // is provided by GlassInteractionStateMixin.

  void _handleKeyboardActivate() {
    if (!mounted || !widget.enabled) return;
    isPressed.value = true;
    widget.onTap();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) isPressed.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Resolve foreground color from the current CupertinoTheme.
    // This automatically supports Light Mode, Dark Mode, and custom themes.
    final theme = CupertinoTheme.of(context);
    final defaultForeground =
        theme.textTheme.textStyle.color ?? CupertinoColors.label;

    // Determine the base color of the item (inheritance logic)
    // Priority: iconColor > titleStyle.color > destructiveRed > theme foreground
    final Color baseColor = widget.iconColor ??
        widget.titleStyle?.color ??
        (widget.isDestructive
            ? CupertinoColors.destructiveRed
            : defaultForeground);

    // Apply specific opacities based on original design specs:
    // Icon: 100% (enabled), 50% (disabled)
    // Text: 90% (static for enabled/disabled)
    final Color iconColor = widget.iconColor ??
        (widget.isDestructive
            ? CupertinoColors.destructiveRed
            : baseColor.withValues(alpha: widget.enabled ? 1.0 : 0.5));

    final Color textColor = widget.titleStyle?.color ??
        (widget.isDestructive
            ? CupertinoColors.destructiveRed
            : baseColor.withValues(alpha: 0.9));

    // Dynamic background for hover/press states
    // We use a subtle white overlay to "brighten" the glass
    final content = ListenableBuilder(
      listenable: allInteraction,
      builder: (context, _) {
        final bool isHov = isHovered.value;
        final bool isFoc = isFocused.value;
        final bool localPressed = isPressed.value;
        final bool effectivePressed =
            (widget.isPressed == true) || localPressed;
        final bool effectiveSelected = widget.isSelected;

        final Color backgroundColor = effectiveSelected
            ? const Color(0x00000000) // Parent renders the sliding pill
            : effectivePressed
                ? const Color(0x26FFFFFF) // Standalone press
                : (isHov || isFoc)
                    ? const Color(0x1AFFFFFF)
                    : const Color(0x00000000);

        // Scale effect on press (subtle squash like iOS buttons)
        final double scale =
            (widget.enablePressScale && effectivePressed) ? 0.98 : 1.0;

        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: widget.height),
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: (effectiveSelected || effectivePressed)
                  ? Duration.zero // Instant highlight on tap down
                  : const Duration(
                      milliseconds: 150), // Smooth fade out on release
              curve: Curves.easeOutCubic,
              constraints: BoxConstraints(minHeight: widget.height),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Opacity(
                opacity: widget.enabled ? 1.0 : 0.4,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final row = Row(
                      children: [
                        // Icon
                        if (widget.icon != null) ...[
                          IconTheme(
                            data: IconThemeData(
                              color: iconColor,
                              size: widget.iconSize,
                            ),
                            child: widget.icon!,
                          ),
                          const SizedBox(width: 12),
                        ],

                        // Text Content (Title & Subtitle)
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                maxLines: widget.maxLines,
                                overflow: TextOverflow.ellipsis,
                                style: widget.titleStyle ??
                                    TextStyle(
                                      color: textColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                    ),
                              ),
                              if (widget.subtitle != null)
                                Text(
                                  widget.subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: widget.subtitleStyle ??
                                      TextStyle(
                                        color: textColor.withValues(alpha: 0.6),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                ),
                            ],
                          ),
                        ),

                        // Trailing
                        if (widget.trailing != null) widget.trailing!,
                      ],
                    );

                    if (constraints.hasBoundedWidth) {
                      final double minRequired = (widget.icon != null
                              ? (widget.iconSize + 12.0)
                              : 0.0) +
                          (widget.trailing != null ? 24.0 : 0.0);
                      if (constraints.maxWidth < minRequired) {
                        return OverflowBox(
                          alignment: Alignment.centerLeft,
                          minWidth: minRequired,
                          maxWidth: minRequired,
                          child: row,
                        );
                      }
                    }

                    return row;
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    // Build the item content
    return GlassFocusRegion(
      enabled: widget.enabled,
      isButton: true,
      semanticLabel: widget.title,
      // The title label replaces the row's own text, so carry the subtitle
      // as the value: announced after the title, on the same node.
      semanticValue: widget.subtitle,
      isFocusedNotifier: isFocused,
      isHoveredNotifier: isHovered,
      onKeyboardActivate: _handleKeyboardActivate,
      semanticOnTap: widget.enabled ? widget.onTap : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: GestureDetector(
        onTapDown: widget.enabled ? (_) => isPressed.value = true : null,
        onTapUp: widget.enabled ? (_) => isPressed.value = false : null,
        onTapCancel: widget.enabled ? () => isPressed.value = false : null,
        onTap: widget.enabled ? widget.onTap : null,
        behavior: HitTestBehavior.opaque,
        // The tap lives on the GlassFocusRegion node with the label (via
        // semanticOnTap); a second one here landed on a separate, unnamed
        // node, as GlassButton documents.
        excludeFromSemantics: true,
        child: content,
      ),
    );
  }
}
