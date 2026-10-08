import 'package:flutter/widgets.dart';

import '../../../widgets/surfaces/glass_vertical_bar.dart';

/// Where a menu or popover opens from a trigger in iPhone Duo's vertical bar
/// strip, or null for a trigger anywhere else.
///
/// Natively a popover from a strip item opens to the item's leading side,
/// towards the content: it lies over the item with their outer edges aligned,
/// centred on it vertically, and runs across the content from there, where a
/// bar along the top or bottom edge hangs it from the trigger instead.
///
/// The result is in the terms of a menu's own alignment: the point of the
/// menu laid over the same point of the trigger.
///
/// [trigger] is the trigger's global rect.
Alignment? verticalBarPresentationAlignment(
  BuildContext context,
  Rect trigger,
) {
  final bar = GlassVerticalBar.maybeOf(context);
  final size = MediaQuery.maybeSizeOf(context);
  if (bar == null || size == null) return null;
  final stripOnRight = (bar.edge == GlassVerticalBarEdge.trailing) ==
      (Directionality.of(context) == TextDirection.ltr);
  final inStrip = stripOnRight
      ? trigger.left >= size.width - bar.width
      : trigger.right <= bar.width;
  if (!inStrip) return null;
  return stripOnRight ? Alignment.centerRight : Alignment.centerLeft;
}
