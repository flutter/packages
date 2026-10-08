import 'package:flutter/cupertino.dart';
import '../../src/renderer/liquid_glass_renderer.dart';
import '../../types/glass_quality.dart';
import 'glass_card.dart';
import 'glass_divider.dart';
import 'glass_list_tile.dart';

/// A convenience wrapper that groups [GlassListTile]s inside a [GlassCard].
///
/// [GlassGroupedSection] automatically injects [GlassDivider]s between tiles,
/// with smart leading-indent detection — 56px when the preceding tile has a
/// [GlassListTile.leading] widget, 16px otherwise.
///
/// ## iOS 26 pattern
///
/// In iOS 26, Settings-style screens group related rows inside
/// `UITableView` grouped sections. [GlassGroupedSection] provides the
/// glass equivalent of that pattern.
///
/// ## Usage
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
///     GlassListTile(
///       leading: Icon(CupertinoIcons.antenna_radiowaves_left_right,
///           color: CupertinoColors.white),
///       title: Text('VPN'),
///       trailing: GlassListTile.chevron,
///     ),
///   ],
/// )
/// ```
///
/// ## Children
///
/// [GlassGroupedSection] is designed to contain [GlassListTile] rows and
/// standard Flutter content. Do not place interactive glass controls
/// (`GlassSegmentedControl`, `GlassSlider`, `GlassSwitch`, `GlassButton`)
/// as direct children — this is a glass-in-glass anti-pattern that degrades
/// refraction and can clip indicator animations. See [GlassContainer] for
/// the full explanation.

class GlassGroupedSection extends StatelessWidget {
  /// Creates a grouped section of glass list tiles.
  const GlassGroupedSection({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.margin,
    this.shape,
    this.settings,
    this.useOwnLayer = false,
    this.quality,
  });

  /// The list tiles to display inside the section.
  ///
  /// Typically [GlassListTile] widgets. [GlassGroupedSection] automatically
  /// injects [GlassDivider]s between adjacent tiles — no manual divider or
  /// position tracking needed.
  final List<Widget> children;

  /// Optional header displayed above the glass card.
  ///
  /// Typically a [Text] widget with section title styling (uppercase, small
  /// font, muted colour) matching iOS grouped table section headers.
  final Widget? header;

  /// Optional footer displayed below the glass card.
  ///
  /// Typically a [Text] widget with explanatory text matching iOS grouped
  /// table section footers.
  final Widget? footer;

  /// Empty space to surround the section card.
  ///
  /// Defaults to `EdgeInsets.symmetric(horizontal: 16, vertical: 6)` matching
  /// iOS grouped table section insets.
  final EdgeInsetsGeometry? margin;

  /// Shape of the glass card.
  ///
  /// If null, uses [GlassCard]'s default shape.
  final LiquidShape? shape;

  /// Glass effect settings.
  ///
  /// If null, inherits from the parent layer or theme.
  final LiquidGlassSettings? settings;

  /// Whether to create its own glass layer.
  ///
  /// Defaults to false (grouped mode).
  final bool useOwnLayer;

  /// Rendering quality.
  final GlassQuality? quality;

  Widget _buildHeader(BuildContext context) {
    if (header == null) return const SizedBox.shrink();
    return Padding(
      padding:
          const EdgeInsetsDirectional.only(start: 16.0, end: 16.0, bottom: 6.0),
      child: DefaultTextStyle(
        style: TextStyle(
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
        ),
        child: header!,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    if (footer == null) return const SizedBox.shrink();
    return Padding(
      padding:
          const EdgeInsetsDirectional.only(start: 16.0, end: 16.0, top: 6.0),
      child: DefaultTextStyle(
        style: TextStyle(
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        child: footer!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveMargin =
        margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6);

    // Interleave GlassDividers between adjacent children. The divider indent
    // is derived from the preceding tile's leading widget — 56px with a leading
    // icon (32px icon + 12px gap + 12px content start inset) or 16px otherwise.
    // If the user manually placed a GlassDivider in children, we don't insert
    // automatic dividers around it to prevent double-dividers.
    final processedChildren = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      processedChildren.add(children[i]);

      final isLastChild = i == children.length - 1;
      if (!isLastChild) {
        final currentChild = children[i];
        final nextChild = children[i + 1];

        // Skip auto-divider if the current child is a divider, or if the next
        // child is a divider. This prevents doubling them up.
        if (currentChild is GlassDivider || nextChild is GlassDivider) continue;

        // Compute indent based on whether the current tile has a leading widget.
        final double indent =
            (currentChild is GlassListTile && currentChild.leading != null)
                ? 56.0
                : 16.0;
        processedChildren.add(GlassDivider(indent: indent));
      }
    }

    final card = GlassCard(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      shape: shape ?? const LiquidRoundedSuperellipse(borderRadius: 12),
      settings: settings,
      useOwnLayer: useOwnLayer,
      quality: quality,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: processedChildren,
      ),
    );

    Widget section = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context),
        card,
        _buildFooter(context),
      ],
    );

    if (effectiveMargin != EdgeInsets.zero) {
      section = Padding(
        padding: effectiveMargin,
        child: section,
      );
    }

    return section;
  }
}
