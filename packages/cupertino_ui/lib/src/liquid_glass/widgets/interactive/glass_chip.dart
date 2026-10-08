import 'package:flutter/cupertino.dart';
import '../../src/renderer/liquid_glass_renderer.dart';

import '../../theme/glass_theme.dart';
import '../../theme/glass_theme_data.dart';
import '../../types/glass_quality.dart';
import 'glass_button.dart';

/// A glass morphism chip following Apple's iOS 26 design patterns.
///
/// [GlassChip] provides a compact, pill-shaped chip with glass effect, perfect
/// for tags, filters, selections, and dismissible elements. It composes
/// [GlassButton] internally for consistent interaction behavior.
///
/// ## Key Features
///
/// - **Pill-Shaped Glass**: Rounded chip with glass morphism effect
/// - **Optional Leading Icon**: Icon before the label
/// - **Optional Delete Button**: Dismissible variant with X button
/// - **Selected State**: Highlight state for filter chips
/// - **Press Effects**: Inherits squash/stretch and glow from GlassButton
/// - **Flexible Sizing**: Automatically sizes to content
///
/// ## Usage
///
/// ### Basic Chip
/// ```dart
/// GlassChip(
///   label: 'Technology',
///   onTap: () => print('Tapped'),
/// )
/// ```
///
/// ### With Leading Icon
/// ```dart
/// GlassChip(
///   label: 'Favorite',
///   icon: Icon(CupertinoIcons.heart_fill),
///   onTap: () => toggleFavorite(),
/// )
/// ```
///
/// ### Dismissible Chip
/// ```dart
/// GlassChip(
///   label: 'Selected Tag',
///   onDeleted: () => removeTag(),
/// )
/// ```
///
/// ### Selected State (Filter Chips)
/// ```dart
/// GlassChip(
///   label: 'Active',
///   selected: true,
///   selectedColor: Colors.blue,
///   onTap: () => toggleFilter(),
/// )
/// ```
///
/// ### Within LiquidGlassLayer (Grouped Mode)
/// ```dart
/// AdaptiveLiquidGlassLayer(
///   settings: LiquidGlassSettings(
///     thickness: 30,
///     blur: 3,
///   ),
///   child: Wrap(
///     spacing: 8,
///     children: [
///       GlassChip(label: 'Flutter', onTap: () {}),
///       GlassChip(label: 'Dart', onTap: () {}),
///       GlassChip(label: 'iOS', onTap: () {}),
///     ],
///   ),
/// )
/// ```
///
/// ### Standalone Mode
/// ```dart
/// GlassChip(
///   label: 'Technology',
///   useOwnLayer: true,
///   settings: LiquidGlassSettings(
///     thickness: 30,
///     blur: 8,
///   ),
/// )
/// ```
class GlassChip extends StatelessWidget {
  /// Creates a glass chip.
  const GlassChip({
    required this.label,
    super.key,
    this.icon,
    this.onTap,
    this.onDeleted,
    this.selected = false,
    this.selectedColor,
    Widget? deleteIcon,
    this.deleteIconSize = 16.0,
    this.iconSize = 16.0,
    this.iconColor,
    this.labelStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.spacing = 6.0,
    this.settings,
    this.useOwnLayer = false,
    this.quality,
    this.platformViewBackdrop = false,
    // GlassButton properties
    this.interactionScale = 1.03,
    this.stretch = 0.3,
    this.glowRadius = 0.8,
    this.anchorStretch = true,
    this.anchorStretchSettings = const AnchorStretchSettings(),
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.deleteSemanticLabel,
  }) : deleteIcon = deleteIcon ?? const Icon(CupertinoIcons.xmark_circle_fill);

  // ===========================================================================
  // Chip Properties
  // ===========================================================================

  /// The label text displayed in the chip.
  final String label;

  /// Externally provided focus node.
  final FocusNode? focusNode;

  /// Whether to request focus immediately.
  final bool autofocus;

  /// Semantic label for screen readers. Defaults to [label].
  final String? semanticLabel;

  /// Screen reader label of the delete button.
  ///
  /// The delete button is always its own button node, so it can be reached
  /// apart from the chip; this names it. Defaults to "Remove" followed by
  /// [semanticLabel] (or [label]), e.g. "Remove Flutter".
  final String? deleteSemanticLabel;

  /// Optional leading icon widget.
  final Widget? icon;

  /// Called when the chip is tapped.
  ///
  /// If both [onTap] and [onDeleted] are null, the chip will be
  /// non-interactive.
  final VoidCallback? onTap;

  /// Called when the delete button is tapped.
  ///
  /// When provided, a delete button (X icon) will be shown on the right side.
  /// The chip becomes dismissible.
  final VoidCallback? onDeleted;

  /// Whether the chip is in selected state.
  ///
  /// When true, the chip will be highlighted with [selectedColor].
  /// Useful for filter chips.
  ///
  /// Defaults to false.
  final bool selected;

  /// Color used when the chip is selected.
  ///
  /// If null and [selected] is true, defaults to white with 30% opacity.
  final Color? selectedColor;

  /// Widget used for the delete button.
  ///
  /// Defaults to [Icon(CupertinoIcons.xmark_circle_fill)].
  final Widget deleteIcon;

  /// Size of the delete icon.
  ///
  /// Defaults to 16.0.
  final double deleteIconSize;

  // ===========================================================================
  // Style Properties
  // ===========================================================================

  /// Size of the leading icon.
  ///
  /// Defaults to 16.0.
  final double iconSize;

  /// Color of the leading icon.
  ///
  /// If null, defaults to white with 90% opacity.
  final Color? iconColor;

  /// Style for the label text.
  ///
  /// If null, defaults to 14px white text with 90% opacity.
  final TextStyle? labelStyle;

  /// Padding inside the chip.
  ///
  /// Defaults to 12px horizontal, 8px vertical.
  final EdgeInsetsGeometry padding;

  /// Spacing between icon and label, and label and delete button.
  ///
  /// Defaults to 6.0.
  final double spacing;

  // ===========================================================================
  // Glass Effect Properties
  // ===========================================================================

  /// Glass effect settings (only used when [useOwnLayer] is true).
  final LiquidGlassSettings? settings;

  /// Whether to create its own layer or use grouped glass.
  ///
  /// Defaults to false (grouped mode).
  final bool useOwnLayer;

  /// Rendering quality for the glass effect.
  ///
  /// If null, inherits from parent [InheritedLiquidGlass] or defaults to
  /// [GlassQuality.standard], which uses backdrop filter rendering.
  /// This works reliably in all contexts, including scrollable lists.
  ///
  /// Use [GlassQuality.premium] for shader-based glass in static layouts only.
  final GlassQuality? quality;

  /// Render the backdrop through a live [BackdropFilter] instead of the
  /// shader's captured backdrop.
  ///
  /// Set this when the chip floats over a platform view (a map, a camera
  /// preview, a video). The premium and standard shaders read their backdrop
  /// from a capture, which cannot see a platform view, so over one they
  /// render inert. [GlassButton] already exposes this; without it here a chip
  /// has no correct rendering path above a platform view.
  final bool platformViewBackdrop;

  // ===========================================================================
  // Interaction Properties (from GlassButton)
  // ===========================================================================

  /// Scale factor when pressed.
  ///
  /// Values > 1.0 grow the chip, < 1.0 shrink it.
  /// Defaults to 1.03 (3% growth, subtle for chips).
  final double interactionScale;

  /// Stretch intensity during animation (0-1).
  ///
  /// Defaults to 0.3 (subtle stretch for chips).
  final double stretch;

  /// Glow radius multiplier.
  ///
  /// Defaults to 0.8 (subtle glow for chips).
  final double glowRadius;

  /// Whether to anchor the chip in place while stretching toward the finger.
  ///
  /// Defaults to `true`. See [GlassButton.anchorStretch].
  final bool anchorStretch;

  /// Fine-tuning for the anchor stretch effect.
  ///
  /// See [AnchorStretchSettings] for details.
  final AnchorStretchSettings anchorStretchSettings;

  static const _chipShape = LiquidRoundedRectangle(borderRadius: 100);

  @override
  Widget build(BuildContext context) {
    final isDark = GlassTheme.brightnessOf(context) == Brightness.dark;
    final baseColor = isDark ? CupertinoColors.white : CupertinoColors.black;
    final defaultContentColor = baseColor.withValues(alpha: 0.9);
    final defaultSelectedColor =
        baseColor.withValues(alpha: isDark ? 0.3 : 0.1);
    final defaultGlowUnselected =
        baseColor.withValues(alpha: isDark ? 0.2 : 0.05);

    final effectiveIconColor = iconColor ?? defaultContentColor;
    final effectiveLabelStyle = labelStyle ??
        TextStyle(
          fontSize: 14,
          color: defaultContentColor,
          fontWeight: FontWeight.w500,
        );

    // Build chip content
    final chipContent = Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Leading icon
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(
                color: effectiveIconColor,
                size: iconSize,
              ),
              child: icon!,
            ),
            SizedBox(width: spacing),
          ],

          // Label. The chip is named here rather than through
          // GlassButton.label: an explicit button label replaces ALL of its
          // content's semantics, which would also hide the delete button.
          Text(
            label,
            semanticsLabel: semanticLabel ?? label,
            style: effectiveLabelStyle,
          ),

          // Delete button
          if (onDeleted != null) ...[
            SizedBox(width: spacing),
            // A node of its own: without it the delete tap merged into the
            // chip's text node, so activating the chip's name could delete it.
            Semantics(
              container: true,
              button: true,
              label: deleteSemanticLabel ?? 'Remove ${semanticLabel ?? label}',
              child: GestureDetector(
                onTap: onDeleted,
                child: IconTheme(
                  data: IconThemeData(
                    color: effectiveIconColor,
                    size: deleteIconSize,
                  ),
                  child: deleteIcon,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    // Determine if chip should be interactive
    final isInteractive = onTap != null || onDeleted != null;

    // Apply selected state color overlay
    final contentWithSelection = selected
        ? Container(
            decoration: BoxDecoration(
              color: selectedColor ?? defaultSelectedColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: chipContent,
          )
        : chipContent;

    // Resolve interaction settings: explicit widget param > theme > chip default
    final themeInteraction = GlassThemeData.of(context).interaction;

    final effectiveInteractionScale = interactionScale != 1.03
        ? interactionScale
        : themeInteraction.interactionScale ?? interactionScale;
    final effectiveStretch =
        stretch != 0.3 ? stretch : themeInteraction.stretch ?? stretch;
    final effectiveAnchorStretch = anchorStretch != true
        ? anchorStretch
        : themeInteraction.anchorStretch ?? anchorStretch;
    final effectiveAnchorStretchSettings =
        !identical(anchorStretchSettings, const AnchorStretchSettings())
            ? anchorStretchSettings
            : themeInteraction.anchorStretchSettings ?? anchorStretchSettings;

    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: GlassButton.custom(
          onTap: onTap ?? (onDeleted != null ? () {} : () {}),
          shape: _chipShape,
          settings: settings,
          useOwnLayer: useOwnLayer,
          quality: quality ?? GlassQuality.standard,
          platformViewBackdrop: platformViewBackdrop,
          interactionScale: effectiveInteractionScale,
          stretch: effectiveStretch,
          glowRadius: glowRadius,
          glowColor: selected
              ? (selectedColor ?? defaultSelectedColor)
              : defaultGlowUnselected,
          enabled: isInteractive,
          anchorStretch: effectiveAnchorStretch,
          anchorStretchSettings: effectiveAnchorStretchSettings,
          focusNode: focusNode,
          autofocus: autofocus,
          // No `label:` — the Text above names the chip (see comment there).
          width: double.infinity, // Expand to intrinsic width
          height: double.infinity, // Expand to intrinsic height
          child: contentWithSelection,
        ),
      ),
    );
  }
}
