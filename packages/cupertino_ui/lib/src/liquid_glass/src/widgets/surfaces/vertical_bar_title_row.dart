import 'package:flutter/widgets.dart';

import '../../../widgets/surfaces/glass_large_title.dart';
import '../../../widgets/surfaces/glass_vertical_bar.dart';

/// Makes part of the navigation bar in iPhone Duo's vertical bar strip follow
/// a [GlassLargeTitle].
///
/// Natively a large title in the strip layout sits in the title row at the top
/// of the content, and the row is part of the navigation bar the content
/// scrolls under: as the content scrolls, the bar's height shrinks from
/// [contentTop] to [GlassVerticalBarMetrics.edgeMargin], taking the row — the
/// title and the items that stay horizontal beside it — with it. No inline
/// title replaces it. While the title's search is open the navigation bar
/// hides altogether, the strip's items included.
///
/// [child] follows both where [collapses], and only the search where it does
/// not — the strip's own column stays put as the content scrolls.
class VerticalBarTitleRow extends StatelessWidget {
  /// Makes [child] follow [controller], or returns it unchanged where there is
  /// no large title.
  const VerticalBarTitleRow({
    super.key,
    required this.controller,
    this.collapses = true,
    required this.child,
  });

  /// Distance from the top of the screen to the content below a large title:
  /// the title row, and 10pt beneath it.
  static const double contentTop = GlassVerticalBarMetrics.edgeMargin +
      GlassVerticalBarMetrics.rowHeight +
      10.0;

  /// How far the content scrolls before the title row is gone.
  static const double collapseExtent =
      contentTop - GlassVerticalBarMetrics.edgeMargin;

  /// Size of a large title in the row.
  ///
  /// Natively the row keeps the title's large weight but sets it at 28pt,
  /// where a navigation bar's large title is 34pt, so it fits the row's
  /// [GlassVerticalBarMetrics.rowHeight].
  static const double largeTitleFontSize = 28.0;

  /// Whether the screen has UIKit's regular horizontal size class, which
  /// changes how search lays out in the strip layout.
  ///
  /// Flutter does not surface size classes. On iPhone Duo the inner display,
  /// 951pt across in landscape, is regular, and the outer display, 678pt at
  /// most, is compact; this splits the two.
  static bool regularWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 800;

  /// The large title to follow, or null for none.
  final GlassLargeTitleController? controller;

  /// Whether [child] scrolls away with the title row.
  final bool collapses;

  /// The part of the bar that follows the title.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    if (controller == null) return child;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final progress = collapses ? controller.collapseProgress : 0.0;
        final hidden = controller.isSearchPresented;
        return IgnorePointer(
          ignoring: hidden || progress == 1.0,
          child: AnimatedOpacity(
            opacity: hidden ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Transform.translate(
              offset: Offset(0, -progress * collapseExtent),
              // The large title's own fade, so the row is gone by the time
              // it reaches the top of the screen.
              child: Opacity(
                opacity: Curves.easeIn.transform(1.0 - progress),
                child: child,
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }
}
