// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
  final strip = _stripOf(context, trigger);
  if (strip == null) return null;
  return strip.onRight ? Alignment.centerRight : Alignment.centerLeft;
}

/// The highest a menu or popover from a trigger in iPhone Duo's vertical bar
/// strip may reach, or null for a trigger anywhere else.
///
/// Natively nothing opened out of the strip covers the status cluster at its
/// top: a menu taller than the room above its item stops level with the
/// strip's first control, [GlassVerticalBarData.top], and scrolls.
///
/// [trigger] is the trigger's global rect.
double? verticalBarPresentationTop(BuildContext context, Rect trigger) =>
    _stripOf(context, trigger)?.bar.top;

/// The strip [trigger] sits in, and whether it is on the right, or null for a
/// trigger outside it.
({GlassVerticalBarData bar, bool onRight})? _stripOf(
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
  return (bar: bar, onRight: stripOnRight);
}
