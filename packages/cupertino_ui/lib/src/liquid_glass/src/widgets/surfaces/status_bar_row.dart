// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' show DisplayFeature, DisplayFeatureType;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../widgets/surfaces/glass_vertical_bar.dart';
import 'vertical_bar_regions.dart';

/// The status bar's row, which a pinned horizontal bar shares on iPhone Duo's
/// inner display held upright.
///
/// There the status cluster is a corner, 134×82pt at the top-right, rather
/// than a strip across the top, and natively the bar moves up beside it: its
/// controls at y 24–72, from [GlassVerticalBarMetrics.titleInset] at the far
/// side to [GlassVerticalBarMetrics.rowInset] short of the cluster — the
/// strip's title row, without the strip. The content keeps the 82pt inset.
///
/// Flutter reports only that inset, so the cluster is read from
/// [MediaQueryData.displayFeatures] and from the regions the package reads
/// from UIKit itself until Flutter reports them on iOS (flutter/flutter#193025)
/// — [VerticalBarRegions], which the shell adds to the media query of its
/// routes but not to that of its own chrome.
@immutable
class StatusBarRow {
  const StatusBarRow._({required this.left, required this.right});

  /// Distance from the screen's left edge to the start of the row.
  final double left;

  /// Distance from the screen's right edge to the end of the row.
  final double right;

  /// Distance from the top of the screen to the row.
  double get top => GlassVerticalBarMetrics.edgeMargin;

  /// Height of the row.
  double get height => GlassVerticalBarMetrics.rowHeight;

  /// Distance from the top of the screen to the bottom of the row.
  double get bottom => top + height;

  /// The row below [context], or null where the bar keeps its own row under
  /// the status bar — everywhere but iPhone Duo's inner display held upright,
  /// and in its vertical bar strip, which has its own title row.
  static StatusBarRow? of(BuildContext context) {
    if (GlassVerticalBar.maybeOf(context) != null) return null;
    return resolve(
      size: MediaQuery.sizeOf(context),
      viewPadding: MediaQuery.viewPaddingOf(context),
      displayFeatures: [
        ...MediaQuery.displayFeaturesOf(context),
        ...VerticalBarRegions.instance.value,
      ],
      platform: defaultTargetPlatform,
    );
  }

  /// The row for a screen of [size], or null where there is no status cluster
  /// to share it with.
  ///
  /// The cluster is the cutout as tall as the top inset that reaches one side
  /// of the screen. A Dynamic Island stops short of the inset and of both
  /// sides, and the strip's own cluster leaves no top inset, so neither
  /// counts.
  @visibleForTesting
  static StatusBarRow? resolve({
    required Size size,
    required EdgeInsets viewPadding,
    required List<DisplayFeature> displayFeatures,
    required TargetPlatform platform,
  }) {
    if (platform != TargetPlatform.iOS || viewPadding.top <= 0) return null;
    for (final feature in displayFeatures) {
      final bounds = feature.bounds;
      if (feature.type != DisplayFeatureType.cutout ||
          bounds.top > 0 ||
          (bounds.bottom - viewPadding.top).abs() > 1) {
        continue;
      }
      final atLeft = bounds.left <= 1;
      final atRight = bounds.right >= size.width - 1;
      if (atLeft == atRight) continue;
      return StatusBarRow._(
        left: atLeft
            ? bounds.right + GlassVerticalBarMetrics.rowInset
            : GlassVerticalBarMetrics.titleInset,
        right: atRight
            ? size.width - bounds.left + GlassVerticalBarMetrics.rowInset
            : GlassVerticalBarMetrics.titleInset,
      );
    }
    return null;
  }
}
