import 'package:flutter/cupertino.dart';

import '../../../widgets/surfaces/glass_large_title.dart';
import '../../../widgets/surfaces/glass_vertical_bar.dart';
import 'vertical_bar_title_row.dart';

/// The opaque background iPhone Duo's vertical bar strip gets under Reduce
/// Transparency.
///
/// The strip and the title row are otherwise clear. With Reduce Transparency
/// on, natively, both turn opaque: the strip from
/// [GlassVerticalBarMetrics.backgroundInset] inside its inner edge, and the
/// title row across the content down to where the content starts, 10pt below
/// the row, each behind a hairline where it meets the content. The row is only drawn with
/// [titleRow], and follows [controller]'s large title as it scrolls away.
///
/// Flutter does not surface Reduce Transparency yet (flutter/flutter#190318);
/// [GlassAccessibilityData.reduceTransparency] approximates it.
class VerticalBarBackground extends StatelessWidget {
  /// Creates the background for [bar].
  const VerticalBarBackground({
    super.key,
    required this.bar,
    this.titleRow = false,
    this.controller,
  });

  /// The strip to draw behind.
  final GlassVerticalBarData bar;

  /// Whether the title row at the top of the content is drawn too.
  final bool titleRow;

  /// The large title the title row scrolls away with, if any.
  final GlassLargeTitleController? controller;

  /// The hairline between the background and the content: (230, 230, 230) as
  /// measured in light mode.
  static const CupertinoDynamicColor hairlineColor =
      CupertinoDynamicColor.withBrightness(
    color: Color(0xFFE6E6E6),
    darkColor: Color(0xFF262626),
  );

  /// Thickness of the hairline: one physical pixel.
  static double hairlineWidth(BuildContext context) =>
      1.0 / MediaQuery.devicePixelRatioOf(context);

  @override
  Widget build(BuildContext context) {
    final fill = CupertinoColors.systemBackground.resolveFrom(context);
    final hairline = BorderSide(
      color: hairlineColor.resolveFrom(context),
      width: hairlineWidth(context),
    );
    final stripWidth = bar.width - GlassVerticalBarMetrics.backgroundInset;
    // Physical, as the strip is: its inner edge faces the content on either
    // side, whatever the reading direction.
    final stripOnRight = (bar.edge == GlassVerticalBarEdge.trailing) ==
        (Directionality.of(context) == TextDirection.ltr);

    final controller = this.controller;
    Widget row(double collapse) => DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            border: Border(bottom: hairline),
          ),
          child: SizedBox(
            height: bar.rowTop +
                VerticalBarTitleRow.contentTop -
                GlassVerticalBarMetrics.edgeMargin -
                collapse * VerticalBarTitleRow.collapseExtent,
          ),
        );

    return IgnorePointer(
      child: Stack(
        children: [
          if (titleRow)
            Positioned(
              top: 0,
              left: stripOnRight ? 0 : stripWidth,
              right: stripOnRight ? stripWidth : 0,
              child: controller == null
                  ? row(0.0)
                  : ListenableBuilder(
                      listenable: controller,
                      builder: (context, _) => row(
                        controller.isSearchPresented
                            ? 1.0
                            : controller.collapseProgress,
                      ),
                    ),
            ),
          Positioned(
            top: 0,
            bottom: 0,
            left: stripOnRight ? null : 0,
            right: stripOnRight ? 0 : null,
            width: stripWidth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: fill,
                border: stripOnRight
                    ? Border(left: hairline)
                    : Border(right: hairline),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
