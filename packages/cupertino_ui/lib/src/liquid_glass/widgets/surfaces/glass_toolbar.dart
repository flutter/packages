import 'package:flutter/cupertino.dart';
import '../../src/renderer/liquid_glass_renderer.dart';
import '../../src/widgets/surfaces/vertical_bar_reservation.dart';
import '../../theme/glass_theme_helpers.dart';
import '../../theme/glass_theme.dart';
import '../../types/glass_quality.dart';
import '../interactive/glass_button_group.dart';
import '../shared/adaptive_glass.dart';
import '../shared/adaptive_liquid_glass_layer.dart';
import 'glass_vertical_bar.dart';

/// A glass morphism toolbar following Apple's iOS 26 design patterns.
///
/// [GlassToolbar] provides a sophisticated bottom toolbar for actions,
/// utilizing the liquid glass material. It is typically used at the bottom
/// of the screen to present a set of actions relevant to the current context.
///
/// Unlike [GlassTabBar.bottom] which is for navigation, [GlassToolbar] is for
/// actions (e.g., "Edit", "Share", "Delete").
///
/// ## Key Features
///
/// - **Liquid Glass Material**: Translucent, blurring background that floats
///   over content.
/// - **Flexible Layout**: Supports any children, typically [GlassButton]s.
/// - **Customizable**: Control height, alignment, and glass settings.
/// - **iOS 26 Compliance**: Matches the visual style of system toolbars.
///
/// ## Usage
///
/// ### Basic Usage
/// ```dart
/// Scaffold(
///   body: Container(), // Your content
///   bottomNavigationBar: GlassToolbar(
///     children: [
///       GlassButton.icon(
///         icon: CupertinoIcons.share,
///         onTap: () {},
///         label: 'Share',
///       ),
///       const Spacer(), // Use Spacer for layout control
///       GlassButton.icon(
///         icon: CupertinoIcons.add,
///         onTap: () {},
///         label: 'Add',
///       ),
///     ],
///   ),
/// )
/// ```
///
/// ### Custom Alignment
/// ```dart
/// GlassToolbar(
///   alignment: MainAxisAlignment.spaceAround,
///   children: [
///     // ... buttons
///   ],
/// )
/// ```
class GlassToolbar extends StatelessWidget {
  /// Creates a glass toolbar.
  const GlassToolbar({
    required this.children,
    super.key,
    this.height = 44.0, // Standard iOS toolbar height (usually + safe area)
    this.alignment = MainAxisAlignment.spaceBetween,
    this.settings,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.quality,
    this.backgroundColor,
  });

  /// The action buttons to display in the toolbar.
  ///
  /// Typically [GlassButton]s or [IconButton]s.
  /// Use [Spacer] widgets to control spacing between items if [alignment]
  /// is set to [MainAxisAlignment.spaceBetween] (the default).
  final List<Widget> children;

  /// Height of the toolbar content area.
  ///
  /// Does not include safe area insets (bottom padding).
  /// Defaults to 44.0, which is the standard iOS toolbar height.
  final double height;

  /// How the children should be placed along the horizontal axis.
  ///
  /// Defaults to [MainAxisAlignment.spaceBetween].
  final MainAxisAlignment alignment;

  /// Glass effect settings.
  ///
  /// If null, uses optimized defaults for toolbars.
  final LiquidGlassSettings? settings;

  /// Padding around the content.
  ///
  /// Defaults to symmetric(horizontal: 16, vertical: 8).
  final EdgeInsetsGeometry padding;

  /// Rendering quality for the glass effect.
  ///
  /// If null, inherits from parent [InheritedLiquidGlass] or defaults to
  /// [GlassQuality.premium].
  final GlassQuality? quality;

  /// Optional background color override.
  ///
  /// If provided, this color is mixed with the glass effect.
  /// If null, a default iOS-style translucent tint is used.
  final Color? backgroundColor;

  static const _defaultSettings = LiquidGlassSettings(
    thickness: 25,
    blur: 20, // High blur for toolbar material
    chromaticAberration: 0.2,
    lightIntensity: 0.35,
    refractiveIndex: 1.5,
    saturation: 1.2,
    glassColor: Color(0x1AFFFFFF), // white10
  );

  @override
  Widget build(BuildContext context) {
    final verticalBar = GlassVerticalBar.maybeOf(context);
    if (verticalBar != null) return _buildVertical(verticalBar);

    final effectiveQuality = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: quality,
      fallback: GlassQuality.premium,
    );

    // Standard iOS toolbar glass settings with high blur
    final effectiveSettings = settings ?? _defaultSettings;

    // Background color blending
    // iOS toolbars often have a very subtle tint
    final effectiveBackgroundColor =
        backgroundColor ?? CupertinoColors.systemGrey.withValues(alpha: 0.08);

    final dividerColor = GlassTheme.brightnessOf(context) == Brightness.light
        ? CupertinoColors.black.withValues(alpha: 0.12)
        : CupertinoColors.white.withValues(alpha: 0.12);

    return AdaptiveLiquidGlassLayer(
      settings: effectiveSettings,
      quality: effectiveQuality,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: dividerColor, // Subtle top divider
              width: 0.5,
            ),
          ),
        ),
        child: Stack(
          children: [
            // Glass Background Layer
            Positioned.fill(
              child: AdaptiveGlass.grouped(
                // Toolbar is typically a full-width rectangle
                shape: const LiquidRoundedRectangle(borderRadius: 0),
                quality: effectiveQuality,
                child: Container(color: effectiveBackgroundColor),
              ),
            ),

            // Content Layer
            SafeArea(
              top: false,
              child: SizedBox(
                height: height,
                child: Padding(
                  padding: padding,
                  child: Row(
                    mainAxisAlignment: alignment,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: children,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The toolbar in iPhone Duo's vertical bar strip.
  ///
  /// Natively the bottom-bar items leave the bottom edge and stack at the
  /// bottom of the strip, first item on top, ending
  /// [GlassVerticalBarData.bottom] above the screen edge. They float
  /// there as the controls they are, so the full-width bar behind them goes,
  /// and the flexible space that spreads them along a horizontal bar collapses
  /// to the strip's ordinary gap. A child that lays out along an axis of its
  /// own — [GlassButtonGroup] — should follow [GlassVerticalBar.maybeOf] to
  /// run vertically here.
  Widget _buildVertical(GlassVerticalBarData bar) {
    final outerInset = bar.width -
        GlassVerticalBarMetrics.inset -
        GlassVerticalBarMetrics.controlExtent;
    final trailingStrip = bar.edge == GlassVerticalBarEdge.trailing;
    return Align(
      alignment: trailingStrip
          ? AlignmentDirectional.bottomEnd
          : AlignmentDirectional.bottomStart,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          bottom: bar.bottom,
          start: trailingStrip ? 0 : outerInset,
          end: trailingStrip ? outerInset : 0,
        ),
        child: VerticalBarBottomReservation(
          child: SizedBox(
            width: GlassVerticalBarMetrics.controlExtent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: GlassVerticalBarMetrics.spacing,
              children: [
                for (final child in children)
                  if (child is! Spacer && child is! Flexible) child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
