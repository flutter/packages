import 'package:flutter/cupertino.dart';
import '../../theme/glass_theme.dart';

/// A glass-aesthetic separator for use between glass content sections.
///
/// [GlassDivider] renders a thin frosted hairline that matches iOS 26 separator
/// styling. It is functionally similar to [Divider] but visually cohesive with
/// the liquid glass design system.
///
/// ## Usage
///
/// ### Horizontal divider (default):
/// ```dart
/// GlassCard(
///   child: Column(
///     children: [
///       Text('Section A'),
///       GlassDivider(),
///       Text('Section B'),
///     ],
///   ),
/// )
/// ```
///
/// ### Vertical divider:
/// ```dart
/// Row(
///   children: [
///     Text('Left'),
///     GlassDivider.vertical(),
///     Text('Right'),
///   ],
/// )
/// ```
///
/// ### Custom thickness and indent:
/// ```dart
/// GlassDivider(
///   thickness: 0.5,
///   indent: 16,
///   endIndent: 16,
///   color: CupertinoColors.white.withOpacity(0.38),
/// )
/// ```
class GlassDivider extends StatelessWidget {
  /// Creates a horizontal glass divider.
  const GlassDivider({
    super.key,
    this.thickness = 0.5,
    this.indent = 0.0,
    this.endIndent = 0.0,
    this.color,
    this.height,
    this.axis = Axis.horizontal,
  });

  /// Creates a vertical glass divider.
  ///
  /// Equivalent to `GlassDivider(axis: Axis.vertical)`.
  const GlassDivider.vertical({
    super.key,
    this.thickness = 0.5,
    this.indent = 0.0,
    this.endIndent = 0.0,
    this.color,
    this.height,
  }) : axis = Axis.vertical;

  // ===========================================================================
  // Appearance Properties
  // ===========================================================================

  /// The thickness of the divider line.
  ///
  /// Defaults to 0.5 logical pixels — matching iOS 26's hairline separator.
  final double thickness;

  /// Empty space leading the divider on the left/top.
  ///
  /// Defaults to 0.
  final double indent;

  /// Empty space trailing the divider on the right/bottom.
  ///
  /// Defaults to 0.
  final double endIndent;

  /// The color of the divider.
  ///
  /// Defaults to `CupertinoColors.white.withValues(alpha: 0.25)` in dark contexts and
  /// `CupertinoColors.black.withValues(alpha: 0.12)` in light contexts — matching iOS
  /// separator colours.
  final Color? color;

  /// The total space occupied in the cross-axis direction.
  ///
  /// For a horizontal divider this is the height; for vertical, the width.
  /// Defaults to 1.0 (slightly more than [thickness] for touch-target padding).
  final double? height;

  /// The axis along which the divider runs.
  ///
  /// [Axis.horizontal] (default) — a full-width horizontal line.
  /// [Axis.vertical] — a full-height vertical line.
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    // Resolve colour: prefer explicit, fall back to theme-adaptive default.
    final brightness = GlassTheme.brightnessOf(context);
    final effectiveColor = color ??
        (brightness == Brightness.dark
            ? CupertinoColors.white.withValues(alpha: 0.20)
            : CupertinoColors.black.withValues(alpha: 0.10));

    final effectiveHeight = height ?? 1.0;

    // Decorative separators should be invisible to VoiceOver/TalkBack,
    // matching iOS behaviour where UITableView separators are not accessible.
    if (axis == Axis.vertical) {
      return ExcludeSemantics(
        child: SizedBox(
          width: effectiveHeight,
          child: Padding(
            padding: EdgeInsets.only(top: indent, bottom: endIndent),
            child: Center(
              // Replaces Material VerticalDivider — identical pixel output.
              child: Container(
                width: thickness,
                color: effectiveColor,
              ),
            ),
          ),
        ),
      );
    }

    return ExcludeSemantics(
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: indent, end: endIndent),
        // Replaces Material Divider — identical pixel output.
        child: SizedBox(
          height: effectiveHeight,
          child: Center(
            child: Container(
              height: thickness,
              color: effectiveColor,
            ),
          ),
        ),
      ),
    );
  }
}
