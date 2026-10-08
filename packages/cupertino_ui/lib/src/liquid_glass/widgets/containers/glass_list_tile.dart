import 'package:flutter/cupertino.dart';

import '../../src/renderer/liquid_glass_renderer.dart';
import '../../theme/glass_theme.dart';
import '../../types/glass_quality.dart';
import 'glass_container.dart';
import '../shared/glass_focus_region.dart';
import '../shared/glass_interaction_state_mixin.dart';

/// A glass-aesthetic list tile following iOS 26 grouped row design.
///
/// [GlassListTile] is the glass design system's equivalent of Flutter's
/// [ListTile] — a clean, stateless item with no knowledge of its position.
///
/// Divider rendering is the responsibility of the parent container:
/// [GlassGroupedSection] automatically injects [GlassDivider]s between tiles.
/// For standalone column layouts, compose [GlassDivider] explicitly, as you
/// would with Flutter's built-in [ListTile] + [Divider] pattern.
///
/// ## Usage inside [GlassGroupedSection] (recommended):
///
/// ```dart
/// GlassGroupedSection(
///   header: const Text('NETWORK'),
///   children: [
///     GlassListTile(
///       leading: Icon(CupertinoIcons.wifi, color: CupertinoColors.white),
///       title: Text('Wi-Fi'),
///       trailing: GlassListTile.chevron,
///     ),
///     GlassListTile(
///       leading: Icon(CupertinoIcons.bluetooth, color: CupertinoColors.white),
///       title: Text('Bluetooth'),
///       trailing: GlassListTile.chevron,
///     ),
///   ],
/// )
/// ```
///
/// ## Standalone tile (own glass layer):
///
/// ```dart
/// GlassListTile.standalone(
///   leading: Icon(CupertinoIcons.star_fill, color: Colors.yellow),
///   title: Text('Featured'),
///   onTap: () { },
/// )
/// ```
class GlassListTile extends StatefulWidget {
  /// Creates a glass list tile for use inside a [GlassCard],
  /// [GlassGroupedSection], or other glass container.
  /// Does not create its own glass layer.
  const GlassListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.leadingIconColor,
    this.titleStyle,
    this.subtitleStyle,
  })  : _useOwnLayer = false,
        _settings = null,
        _quality = null;

  /// Creates a standalone glass list tile that manages its own glass layer.
  ///
  /// Use when the tile is not inside a [GlassCard] or [GlassContainer].
  const GlassListTile.standalone({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.leadingIconColor,
    this.titleStyle,
    this.subtitleStyle,
    LiquidGlassSettings? settings,
    GlassQuality? quality,
  })  : _useOwnLayer = true,
        _settings = settings,
        _quality = quality;

  // ===========================================================================
  // Content Properties
  // ===========================================================================

  /// Widget displayed at the start (left) of the tile.
  ///
  /// Typically an [Icon] or [CircleAvatar]. Constrained to 24×24 by default.
  final Widget? leading;

  /// Primary content. Typically a [Text] widget.
  final Widget title;

  /// Optional secondary content displayed under [title].
  final Widget? subtitle;

  /// Widget displayed at the end (right) of the tile.
  ///
  /// Use [GlassListTile.chevron] for iOS-style navigation disclosure arrows.
  final Widget? trailing;

  // ===========================================================================
  // Interaction Properties
  // ===========================================================================

  /// Called when the user taps the tile.
  final VoidCallback? onTap;

  /// Called when the user long-presses the tile.
  final VoidCallback? onLongPress;

  // ===========================================================================
  // Styling Properties
  // ===========================================================================

  /// Padding inside the tile around the content row.
  ///
  /// Defaults to 16px horizontal, 12px vertical — matching iOS table row insets.
  final EdgeInsetsGeometry contentPadding;

  /// Tint applied to [leading] icon colour.
  ///
  /// If null, the icon uses its own colour or the theme's icon colour.
  final Color? leadingIconColor;

  /// Text style for [title].
  ///
  /// Defaults to white bold text matching glass surfaces.
  final TextStyle? titleStyle;

  /// Text style for [subtitle].
  ///
  /// Defaults to white with reduced opacity.
  final TextStyle? subtitleStyle;

  // ===========================================================================
  // Glass Layer Properties (standalone only)
  // ===========================================================================

  final bool _useOwnLayer;
  final LiquidGlassSettings? _settings;
  final GlassQuality? _quality;

  // ===========================================================================
  // Convenience Constants
  // ===========================================================================

  /// A standard iOS-style disclosure chevron for use as [trailing].
  static Widget get chevron => const Icon(
        CupertinoIcons.chevron_forward,
        color: CupertinoColors.systemGrey,
        size: 20,
      );

  /// A standard iOS-style detail disclosure (circle with 'i') for [trailing].
  static Widget get infoButton => const Icon(
        CupertinoIcons.info,
        color: CupertinoColors.systemGrey,
        size: 20,
      );

  @override
  State<GlassListTile> createState() => _GlassListTileState();
}

class _GlassListTileState extends State<GlassListTile>
    with GlassInteractionStateMixin {
  // Interaction state (isPressed, isFocused, pressedAndFocused)
  // is provided by GlassInteractionStateMixin.

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);

    if (widget._useOwnLayer) {
      return GlassContainer(
        shape: const LiquidRoundedSuperellipse(borderRadius: 12),
        settings: widget._settings,
        quality: widget._quality,
        padding: EdgeInsets.zero,
        child: content,
      );
    }

    return content;
  }

  Widget _buildContent(BuildContext context) {
    final dynamicLabelColor =
        CupertinoTheme.of(context).textTheme.textStyle.color ??
            CupertinoColors.label;

    final effectiveTitleStyle = widget.titleStyle ??
        TextStyle(
          color: dynamicLabelColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        );
    final effectiveSubtitleStyle = widget.subtitleStyle ??
        TextStyle(
          color: dynamicLabelColor.withValues(alpha: 0.65),
          fontSize: 13,
        );

    Widget row = Row(
      children: [
        if (widget.leading != null) ...[
          IconTheme(
            data: IconThemeData(
              color: widget.leadingIconColor ?? dynamicLabelColor,
              size: 22,
            ),
            child: SizedBox(width: 32, child: widget.leading),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              DefaultTextStyle(style: effectiveTitleStyle, child: widget.title),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 2),
                DefaultTextStyle(
                  style: effectiveSubtitleStyle,
                  child: widget.subtitle!,
                ),
              ],
            ],
          ),
        ),
        if (widget.trailing != null) ...[
          const SizedBox(width: 8),
          IconTheme(
            data: IconThemeData(
                color: dynamicLabelColor.withValues(alpha: 0.54), size: 20),
            child: widget.trailing!,
          ),
        ],
      ],
    );

    Widget tile = Padding(padding: widget.contentPadding, child: row);

    if (widget.onTap != null || widget.onLongPress != null) {
      tile = GlassFocusRegion(
        enabled: true,
        // No shape → background highlight pattern for list rows, not outset ring.
        isFocusedNotifier: isFocused,
        semanticLabel: null, // title widget provides its own text semantics
        isButton: true,
        onKeyboardActivate: widget.onTap,
        semanticOnTap: widget.onTap,
        semanticOnLongPress: widget.onLongPress,
        // Role, tap and long press all live on the region's node. A button
        // Semantics or detector semantics in here would conflict with it and
        // split the tile into two nodes, one of them unlabelled (#381).
        child: GestureDetector(
          excludeFromSemantics: true,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          onTapDown: (_) => isPressed.value = true,
          onTapUp: (_) => isPressed.value = false,
          onTapCancel: () => isPressed.value = false,
          behavior: HitTestBehavior.opaque,
          child: ListenableBuilder(
            listenable: pressedAndFocused,
            builder: (context, child) {
              final bool showHighlight = isPressed.value || isFocused.value;
              return AnimatedContainer(
                duration: isPressed.value
                    ? Duration.zero
                    : const Duration(milliseconds: 150),
                curve: Curves.easeOutCubic,
                color: showHighlight
                    ? (GlassTheme.brightnessOf(context) == Brightness.light
                        ? CupertinoColors.black.withValues(alpha: 0.08)
                        : CupertinoColors.white.withValues(alpha: 0.08))
                    : const Color(0x00000000),
                child: child,
              );
            },
            child: tile,
          ),
        ),
      );
    }

    return tile;
  }
}
