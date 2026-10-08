import 'package:flutter/widgets.dart';

// =============================================================================
// Masking Quality
// =============================================================================

/// Rendering quality for the liquid glass masking effect in [GlassTabBar].
///
/// Controls the complexity of the masking effect that creates the "magic lens"
/// appearance where selected tab content appears to glow through the glass indicator.
enum MaskingQuality {
  /// No masking effect, simple icon color change (fastest).
  ///
  /// Uses the traditional approach where tabs simply change color when selected.
  /// No dual-layer rendering or clipping. Best performance, but less visual polish.
  ///
  /// **Recommended for:**
  /// - Apps targeting older devices (iPhone X or older)
  /// - Maximum performance requirements
  /// - 7+ tabs
  off,

  /// Full jelly physics clip path with dual-layer rendering (best quality, default).
  ///
  /// Creates a "magic lens" effect where selected tabs appear to glow through
  /// the glass indicator as it moves. Content is magnified and the clip path
  /// follows the jelly physics for perfect synchronization.
  ///
  /// **Recommended for:**
  /// - Modern devices (iPhone 12+, Pixel 5+)
  /// - 3-5 tabs (typical use case)
  /// - Premium/polished apps
  /// - When visual quality is a priority
  ///
  /// **Performance:** Renders tabs twice with ClipPath operations. Maintains
  /// 60fps on modern devices with typical 3-5 tab configurations.
  high,
}

// =============================================================================
// Search Morph Alignment
// =============================================================================

/// Controls how the tab pill is anchored **horizontally** during the morph
/// animation in a searchable tab bar.
///
/// This only affects the tab pill's position. The search pill position is
/// always computed from the trailing edge.
enum GlassTabPillAnchor {
  /// The tab pill is pinned to the **leading (left) edge** — the right edge
  /// retracts as the pill collapses. This is the default and matches the
  /// classic iOS News / Safari behaviour.
  start,

  /// The tab pill scales **from its centre** — both edges collapse inward
  /// symmetrically as the pill morphs into the collapsed search state, and
  /// expand outward symmetrically when search closes.
  ///
  /// Use this when you want a more balanced, symmetrical animation. Note that
  /// while searching, the search pill will be slightly narrower than in
  /// [start] mode because it starts after the centred collapsed tab pill.
  center,
}

// =============================================================================
// Jelly Clipper
// =============================================================================

/// Clipper that matches the shape and physics of the jelly indicator.
class JellyClipper extends CustomClipper<Path> {
  /// Creates a new [JellyClipper].
  JellyClipper({
    required this.itemCount,
    required this.alignment,
    required this.thickness,
    required this.expansion,
    required this.transform,
    required this.borderRadius,
    this.inverse = false,
  });

  /// The number of items.
  final int itemCount;

  /// The alignment of the clipper.
  final Alignment alignment;

  /// The thickness of the jelly effect.
  final double thickness;

  /// The expansion insets.
  final EdgeInsets expansion;

  /// The transform matrix.
  final Matrix4 transform;

  /// The border radius.
  final double borderRadius;

  /// Whether the clipper is inverted.
  final bool inverse;

  /// Threshold for clip recalculation optimization.
  ///
  /// When changes in alignment or thickness are below this threshold,
  /// the cached clip path is reused instead of recalculating.
  /// This is below human perception threshold (sub-pixel).
  static const double _recalcThreshold = 0.001;

  @override
  Path getClip(Size size) {
    final tabWidth = size.width / itemCount;
    final availableWidth = size.width - tabWidth;

    // Map alignment (-1 to 1) to horizontal offset.
    final rawLeft = (alignment.x + 1) / 2 * availableWidth;

    // Overdrag guard: when the user rubber-bands past the first or last tab
    // (alignment.x outside [-1, 1]), the raw offset would slide the clip
    // window off the edge tab's icon entirely. Instead, clamp the leading edge
    // to the bar boundary and let the trailing edge extend into overflow — the
    // outer glass shape (AdaptiveGlass / _barShape) trims the overflow — so
    // the icon stays fully visible and the pill reads as pressing elastically
    // against the wall rather than vanishing off the edge (#328).
    final left = rawLeft.clamp(double.negativeInfinity, availableWidth);
    final right = (rawLeft + tabWidth).clamp(tabWidth, double.infinity);

    final baseRect = Rect.fromLTRB(left, 0, right, size.height);

    final paddedRect = Rect.fromLTRB(
      baseRect.left + 4.0,
      baseRect.top + 4.0,
      baseRect.right - 4.0,
      baseRect.bottom - 4.0,
    );

    // Apply expansion based on thickness (drag state)
    final inflatedRect = Rect.fromLTRB(
      paddedRect.left - (expansion.left * thickness),
      paddedRect.top - (expansion.top * thickness),
      paddedRect.right + (expansion.right * thickness),
      paddedRect.bottom + (expansion.bottom * thickness),
    );

    // Clamp radius to avoid invalid RRect paths on Impeller.
    final maxRadius = (inflatedRect.shortestSide / 2) - 0.1;
    final safeRadius = borderRadius > maxRadius ? maxRadius : borderRadius;

    // Create rounded rect path
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        inflatedRect,
        Radius.circular(safeRadius > 0 ? safeRadius : 0),
      ));

    // Apply jelly physics transform around the center
    final center = inflatedRect.center;
    final centeredTransform = Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0.0, 1.0)
      ..multiply(transform)
      ..translateByDouble(-center.dx, -center.dy, 0.0, 1.0);

    final indicatorPath = path.transform(centeredTransform.storage);

    if (inverse) {
      return Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addPath(indicatorPath, Offset.zero);
    }

    return indicatorPath;
  }

  @override
  bool shouldReclip(JellyClipper oldClipper) {
    if (itemCount == oldClipper.itemCount &&
        inverse == oldClipper.inverse &&
        borderRadius == oldClipper.borderRadius &&
        expansion == oldClipper.expansion &&
        transform == oldClipper.transform &&
        (alignment.x - oldClipper.alignment.x).abs() < _recalcThreshold &&
        (thickness - oldClipper.thickness).abs() < _recalcThreshold) {
      return false;
    }

    return itemCount != oldClipper.itemCount ||
        alignment != oldClipper.alignment ||
        thickness != oldClipper.thickness ||
        expansion != oldClipper.expansion ||
        transform != oldClipper.transform ||
        borderRadius != oldClipper.borderRadius ||
        inverse != oldClipper.inverse;
  }
}
