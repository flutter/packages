// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui' show DisplayFeature, DisplayFeatureType;

import 'package:flutter/widgets.dart';

import '../overlays/glass_modal_sheet.dart';
import 'glass_navigation_shell.dart';

/// Whether a [GlassNavigationShell] moves its bars into iPhone Duo's vertical
/// bar strip.
///
/// Mirrors UIKit's `UIViewController.preferredVerticalBarBehavior` and
/// SwiftUI's `toolbarVerticalBehavior(_:)`. Set on the shell rather than per
/// screen for the reason UIKit reads it from the container: `.disabled` only
/// takes effect natively when applied to the `NavigationStack`, never to the
/// page pushed into it.
enum GlassVerticalBarBehavior {
  /// Bars move into the strip wherever the device reserves one.
  ///
  /// On iPhone Duo that is the outer display in every orientation and the
  /// inner display in landscape; everywhere else nothing changes.
  automatic,

  /// Bars stay horizontal, even where the device reserves a strip.
  ///
  /// This only moves the package's bars. The strip itself is reserved by the
  /// system for as long as the app's view controller accepts it, so the
  /// content area still ends at the strip. To give the whole width back,
  /// override `preferredVerticalBarBehavior` to return `.disabled` in a
  /// `FlutterViewController` subclass: the status bar then returns to the top
  /// and `MediaQuery.viewPadding` becomes `(0, 82, 0, 34)`.
  disabled,
}

/// What gives way when iPhone Duo's vertical bar strip runs out of height for
/// both the tab bar and the pinned chrome.
///
/// Mirrors SwiftUI's `toolbarVerticalCompressionBehavior(_:)` and UIKit's
/// `verticalBarCompressionBehavior`. The tab bar gives way by collapsing to a
/// circle holding the selected tab, which expands again on a tap — the
/// minimized pill of [GlassTabBar.minimizable]. The pinned chrome gives way by
/// collapsing the groups that no longer fit into a ••• menu.
enum GlassVerticalBarCompression {
  /// The system decides, as natively: the pinned chrome overflows first, and
  /// the tab bar collapses on its own where the strip is shortest — the outer
  /// display in landscape.
  automatic,

  /// The tab bar always collapses, leaving the strip to the bar items.
  prefersBarItems,

  /// The tab bar never collapses; the bar items overflow instead.
  prefersTabBar,
}

/// Which side of the screen the vertical bar strip is on, relative to the
/// reading direction.
///
/// Mirrors SwiftUI's `toolbarVerticalEdge` and UIKit's
/// `UITraitCollection.verticalBarEdge`. The strip stays on the same *physical*
/// side whatever the layout direction, so a right-hand strip is [trailing] in
/// a left-to-right app and [leading] in a right-to-left one — exactly what
/// UIKit reports.
enum GlassVerticalBarEdge {
  /// The strip is on the side a line of text starts from.
  leading,

  /// The strip is on the side a line of text ends at.
  trailing,
}

/// Geometry of iPhone Duo's vertical bar strip.
///
/// Measured on the iOS 27.1 simulator (24A94401) from SwiftUI and UIKit bars
/// at rest; the package draws its strip chrome to these numbers so the two
/// read as the same system.
abstract final class GlassVerticalBarMetrics {
  /// Width of a control in the strip: the diameter of a lone item's circle,
  /// and the width of a capsule holding several.
  static const double controlExtent = 48.0;

  /// Height one item takes inside a capsule of several — a two-item capsule
  /// is 100pt tall. A lone item is a [controlExtent] circle instead.
  static const double itemExtent = 50.0;

  /// Distance from the strip's inner edge, the one facing the content, to its
  /// controls. The controls are therefore not centred in the strip: in the
  /// 84pt strip they sit 12pt from the content and 24pt from the screen edge.
  static const double inset = 12.0;

  /// Gap between two controls in the strip.
  static const double spacing = 12.0;

  /// Distance of the strip's controls from a screen edge with nothing else
  /// on it — the bottom, usually, and the top where the status bar is hidden
  /// — and of the horizontal title row from the top in every posture.
  static const double edgeMargin = 24.0;

  /// Height of the horizontal row that keeps the title, and any items that do
  /// not go vertical, at the top of the content area.
  static const double rowHeight = 48.0;

  /// Distance from the screen edge away from the strip to the horizontal row:
  /// to the title in a left-to-right app with the strip on the right, and to
  /// the items that stay horizontal in a right-to-left one.
  static const double titleInset = 20.0;

  /// Width of the strip, from the screen edge to the content.
  ///
  /// UIKit reports it as the lateral inset where it reserves the strip. Where
  /// it leaves the strip to the app, as for the left-hand app in Split View,
  /// it reports only the edge, and the strip is this wide, as natively.
  static const double stripWidth = 84.0;

  /// Gap between the strip and the horizontal row.
  ///
  /// Natively the row runs almost against the strip, where a horizontal bar
  /// would inset it by its full margin. Like [titleInset] it is physical: in a
  /// right-to-left app the title, not the items, ends against the strip.
  static const double rowInset = 2.0;

  /// Distance from the strip's inner edge to where its background starts
  /// under Reduce Transparency.
  ///
  /// The strip is otherwise clear. With Reduce Transparency on it gets an
  /// opaque background, which natively starts 5pt into the strip — 7pt short
  /// of its controls — behind a hairline divider.
  static const double backgroundInset = 5.0;
}

/// The vertical bar strip a [GlassNavigationShell] resolved for the current
/// screen.
@immutable
class GlassVerticalBarData {
  /// Creates the description of a strip.
  const GlassVerticalBarData({
    required this.edge,
    required this.width,
    required this.top,
    this.bottom = GlassVerticalBarMetrics.edgeMargin,
    this.collapsesTabBar = false,
    this.rowTop = GlassVerticalBarMetrics.edgeMargin,
    this.titleInset = GlassVerticalBarMetrics.titleInset,
    this.systemInset = true,
  });

  /// The side of the screen the strip is on.
  final GlassVerticalBarEdge edge;

  /// Width of the strip, from the screen edge to the start of the content.
  ///
  /// 84pt on iPhone Duo. Equal to the lateral `MediaQuery.viewPadding` on the
  /// strip's side, which is where it is read from.
  final double width;

  /// Distance from the top of the screen to the strip's first control.
  ///
  /// Everything above it belongs to the status bar, which the system moves
  /// into the strip with the bars. See [GlassVerticalBar.resolve] for where
  /// the value comes from.
  final double top;

  /// Distance from the bottom of the screen to the strip's last control.
  ///
  /// [GlassVerticalBarMetrics.edgeMargin] wherever the strip's bottom end is
  /// clear, and more where the camera sits there. See
  /// [GlassVerticalBar.resolve].
  final double bottom;

  /// Whether a tab bar in the strip collapses to its selected tab.
  ///
  /// Resolved from the shell's [GlassVerticalBarCompression] and the posture.
  final bool collapsesTabBar;

  /// Distance from the top to the horizontal row that keeps the title.
  ///
  /// [GlassVerticalBarMetrics.edgeMargin] on a screen, below the status bar
  /// where it keeps a top inset. A modal sheet's own strip measures it from
  /// the sheet's top edge, 16pt down.
  final double rowTop;

  /// Distance from the edge away from the strip to the horizontal row.
  ///
  /// [GlassVerticalBarMetrics.titleInset] on a screen. A modal sheet's own
  /// strip measures it from the sheet's edge, 16pt in.
  final double titleInset;

  /// Whether the system already keeps the content clear of the strip,
  /// through the view's insets.
  ///
  /// False for the left-hand app in Split View: UIKit names the strip's edge
  /// there but leaves its space to the app, and [GlassNavigationShell] insets
  /// the content itself.
  final bool systemInset;

  @override
  bool operator ==(Object other) =>
      other is GlassVerticalBarData &&
      other.systemInset == systemInset &&
      other.edge == edge &&
      other.width == width &&
      other.top == top &&
      other.bottom == bottom &&
      other.collapsesTabBar == collapsesTabBar &&
      other.rowTop == rowTop &&
      other.titleInset == titleInset;

  @override
  int get hashCode => Object.hash(edge, width, top, bottom, collapsesTabBar,
      rowTop, titleInset, systemInset);

  @override
  String toString() => 'GlassVerticalBarData(${edge.name}, width: $width, '
      'top: $top, bottom: $bottom, collapsesTabBar: $collapsesTabBar, '
      'rowTop: $rowTop, titleInset: $titleInset, systemInset: $systemInset)';
}

/// Tells the bars below a [GlassNavigationShell] whether to lay out
/// vertically, and where.
///
/// On iPhone Duo an app built against the iOS 27.1 SDK gets vertical bars:
/// always on the outer display, and on the inner display in landscape. The
/// back button, bar items and tab bar leave the top and bottom edges and stack
/// in a fixed-width strip beside the status bar. UIKit only moves bars that a
/// container owns, and a `FlutterViewController` owns none — but the strip is
/// reserved all the same, so the shell stands in for the container and
/// publishes the strip here for the package's bars to follow.
///
/// Installed by [GlassNavigationShell], and again by a [GlassModalSheet] for
/// its content: the sheet's own strip where the sheet covers the screen's,
/// and null where its bar stays horizontal. Read it to fit a bar the package
/// does not draw:
///
/// ```dart
/// final edge = GlassVerticalBar.edgeOf(context); // null: bars are horizontal
/// ```
class GlassVerticalBar extends InheritedWidget {
  /// Publishes [data] to the subtree.
  const GlassVerticalBar({
    super.key,
    required this.data,
    required super.child,
  });

  /// Keeps the bars in [child] horizontal under a strip.
  ///
  /// For a column the strip does not belong to. Natively a
  /// `UISplitViewController` gives the strip to the column against it, and the
  /// column beside it keeps a horizontal tab bar and navigation bar; wrap that
  /// column in this.
  ///
  /// A [GlassPinnedBarChrome] or [GlassAppBar.pinned] inside it stays out of
  /// the [GlassNavigationShell] while the shell has a strip, and draws its
  /// chrome in-route: the shell pins chrome against the window, not against
  /// the column.
  const GlassVerticalBar.disabled({super.key, required super.child})
      : data = null;

  /// The strip, or null where bars are horizontal.
  final GlassVerticalBarData? data;

  /// The strip bars below [context] should use, or null where they are
  /// horizontal — on every device but iPhone Duo, in inner portrait, with no
  /// [GlassNavigationShell] above, with [GlassVerticalBarBehavior.disabled],
  /// or under [GlassVerticalBar.disabled].
  static GlassVerticalBarData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GlassVerticalBar>()?.data;

  /// The side of the screen the strip is on, or null where bars are
  /// horizontal.
  static GlassVerticalBarEdge? edgeOf(BuildContext context) =>
      maybeOf(context)?.edge;

  /// The strip the system has reserved, read from the view's insets.
  ///
  /// iPhone Duo reports its strip only as a lateral inset, which carries the
  /// strip's full width on its side. Nothing else insets exactly one side: a
  /// regular iPhone in landscape insets both equally (`(62, 0, 62, 20)` on
  /// iPhone 17), and an iPad neither, so a single lateral inset is required
  /// rather than a particular width.
  ///
  /// The side is the system's to choose, so it is never assumed. A full-screen
  /// app has the strip on the right, and the status bar moves into it, leaving
  /// a zero top inset. In Split View each app has it on its outer edge, the
  /// left for the app on the left, and the status bar stays along the top of
  /// the window.
  ///
  /// [viewPadding] rather than `padding`, so the strip stays put while the
  /// keyboard is up, and it has to be read above any [SafeArea], which removes
  /// `viewPadding` along with `padding` for its subtree. The insets are
  /// physical, so the strip keeps its side under RTL, where it becomes the
  /// [GlassVerticalBarEdge.leading] edge.
  ///
  /// [GlassVerticalBarData.top] and [GlassVerticalBarData.bottom] are what
  /// the insets do not carry: where the status cluster and the camera end.
  /// UIKit reports both as occlusion regions, which move — the cluster grows
  /// with live activities and goes with the status bar — and they are read
  /// from [displayFeatures]: the controls start below the cutouts that
  /// overlap the top half of the strip and end above those in the bottom
  /// half, and keep [GlassVerticalBarMetrics.edgeMargin] clear of an end with
  /// none. Flutter does not report them on iOS yet (flutter/flutter#193025),
  /// so [GlassNavigationShell] adds the regions the package reads from UIKit
  /// itself.
  ///
  /// Until a region is reported they come from a table keyed on the screen
  /// size, measured on the 27.1 simulator: 170pt on the outer display, 120pt
  /// on the inner display in landscape, and in outer landscape, which hides
  /// the status bar, 82pt clear of the camera — at the top when the strip is
  /// on the left, at the bottom when it is on the right.
  ///
  /// Where the status bar keeps a top inset, as in Split View, the strip and
  /// the title row start [GlassVerticalBarMetrics.edgeMargin] below it.
  ///
  /// [compression] resolves [GlassVerticalBarData.collapsesTabBar]; under
  /// [GlassVerticalBarCompression.automatic] the tab bar collapses in outer
  /// landscape, the one posture too short for it and the chrome together.
  static GlassVerticalBarData? resolve({
    required EdgeInsets viewPadding,
    required Size size,
    required TargetPlatform platform,
    required TextDirection textDirection,
    List<DisplayFeature> displayFeatures = const <DisplayFeature>[],
    GlassVerticalBarEdge? systemEdge,
    GlassVerticalBarCompression compression =
        GlassVerticalBarCompression.automatic,
  }) {
    if (platform != TargetPlatform.iOS) return null;
    var left = viewPadding.left > 0;
    final right = viewPadding.right > 0;
    // Without an inset on one side only, the strip is the app's to keep, on
    // the edge UIKit names, if it names one.
    final systemInset = left != right;
    if (!systemInset) {
      if (systemEdge == null) return null;
      left = (systemEdge == GlassVerticalBarEdge.leading) ==
          (textDirection == TextDirection.ltr);
    }
    final onStart = left == (textDirection == TextDirection.ltr);

    final stripWidth = !systemInset
        ? GlassVerticalBarMetrics.stripWidth
        : left
            ? viewPadding.left
            : viewPadding.right;
    final strip = left
        ? Rect.fromLTWH(0, 0, stripWidth, size.height)
        : Rect.fromLTWH(size.width - stripWidth, 0, stripWidth, size.height);

    final width = size.width.round();
    final height = size.height.round();
    // A window that keeps its status bar along the top, as in Split View.
    final statusBarOnTop = viewPadding.top > 0;
    // Inner display, landscape: the status cluster sits in the strip above
    // the controls, shorter than on the outer display.
    final innerLandscape = width == 951 && height == 669;
    // Landscape on the outer display hides the status bar entirely.
    final outerLandscape = !statusBarOnTop && !innerLandscape && width > height;

    // The camera's end of the strip in outer landscape.
    const cameraClearance = 82.0;
    final belowStatusBar = viewPadding.top + GlassVerticalBarMetrics.edgeMargin;

    double? top;
    double? bottom;
    for (final feature in displayFeatures) {
      final bounds = feature.bounds;
      if (feature.type != DisplayFeatureType.cutout ||
          !bounds.overlaps(strip)) {
        continue;
      }
      if (bounds.center.dy < size.height / 2) {
        top =
            math.max(top ?? GlassVerticalBarMetrics.edgeMargin, bounds.bottom);
      } else {
        bottom = math.max(bottom ?? GlassVerticalBarMetrics.edgeMargin,
            size.height - bounds.top);
      }
    }
    if (statusBarOnTop) {
      top = math.max(top ?? 0, belowStatusBar);
    } else if (top == null && bottom == null && systemInset) {
      // Where the system keeps the strip, its status cluster and camera sit
      // at its ends; a strip the app keeps has neither.
      top = innerLandscape
          ? 120.0
          : outerLandscape
              ? (left ? cameraClearance : null)
              : 170.0;
      bottom = outerLandscape && right ? cameraClearance : null;
    }

    return GlassVerticalBarData(
      edge: onStart
          ? GlassVerticalBarEdge.leading
          : GlassVerticalBarEdge.trailing,
      width: stripWidth,
      top: top ?? GlassVerticalBarMetrics.edgeMargin,
      bottom: bottom ?? GlassVerticalBarMetrics.edgeMargin,
      rowTop: belowStatusBar,
      systemInset: systemInset,
      collapsesTabBar: switch (compression) {
        GlassVerticalBarCompression.automatic => outerLandscape,
        GlassVerticalBarCompression.prefersBarItems => true,
        GlassVerticalBarCompression.prefersTabBar => false,
      },
    );
  }

  @override
  bool updateShouldNotify(GlassVerticalBar oldWidget) => data != oldWidget.data;
}
