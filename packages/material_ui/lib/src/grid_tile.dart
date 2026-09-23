// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'grid_tile_bar.dart';
library;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A tile in a Material Design grid list.
///
/// A grid list is a [GridView] of tiles in a vertical and horizontal
/// array. Each tile typically contains some visually rich content (e.g., an
/// image) together with a [GridTileBar] in either a [header] or a [footer].
///
/// See also:
///
///  * [GridView], which is a scrollable grid of tiles.
///  * [GridTileBar], which is typically used in either the [header] or
///    [footer].
///  * <https://material.io/design/components/image-lists.html>
class GridTile extends StatelessWidget {
  /// Creates a grid tile.
  ///
  /// Must have a child. Does not typically have both a header and a footer.
  const GridTile({super.key, this.header, this.footer, required this.child});

  /// The widget to show over the top of this grid tile.
  ///
  /// Typically a [GridTileBar].
  final Widget? header;

  /// The widget to show over the bottom of this grid tile.
  ///
  /// Typically a [GridTileBar].
  final Widget? footer;

  /// The widget that fills the tile.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (header == null && footer == null) {
      return child;
    }

    // The child is not positioned so that the Stack can size itself to it
    // along an unbounded axis (e.g. in a horizontally scrolling ListView),
    // where a Stack of only positioned children would try to be infinitely
    // large. Along bounded axes, the child still fills the available space.
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        _FillBoundedAxes(child: child),
        if (header != null) Positioned(top: 0.0, left: 0.0, right: 0.0, child: header!),
        if (footer != null) Positioned(left: 0.0, bottom: 0.0, right: 0.0, child: footer!),
      ],
    );
  }
}

/// Makes its child as big as the incoming constraints allow along every
/// bounded axis, and lets the child pick its own size along unbounded axes.
class _FillBoundedAxes extends SingleChildRenderObjectWidget {
  const _FillBoundedAxes({required Widget super.child});

  @override
  _RenderFillBoundedAxes createRenderObject(BuildContext context) => _RenderFillBoundedAxes();
}

class _RenderFillBoundedAxes extends RenderProxyBox {
  static BoxConstraints _fillBoundedAxes(BoxConstraints constraints) {
    return constraints.copyWith(
      minWidth: constraints.hasBoundedWidth ? constraints.maxWidth : constraints.minWidth,
      minHeight: constraints.hasBoundedHeight ? constraints.maxHeight : constraints.minHeight,
    );
  }

  // The tile used to report zero intrinsic sizes because its child was
  // positioned, which the Stack ignores for intrinsics. Keep doing so.
  @override
  double computeMinIntrinsicWidth(double height) => 0.0;

  @override
  double computeMaxIntrinsicWidth(double height) => 0.0;

  @override
  double computeMinIntrinsicHeight(double width) => 0.0;

  @override
  double computeMaxIntrinsicHeight(double width) => 0.0;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final BoxConstraints childConstraints = _fillBoundedAxes(constraints);
    return constraints.constrain(
      child?.getDryLayout(childConstraints) ?? childConstraints.smallest,
    );
  }

  @override
  void performLayout() {
    final BoxConstraints childConstraints = _fillBoundedAxes(constraints);
    final RenderBox? child = this.child;
    if (child == null) {
      size = constraints.constrain(childConstraints.smallest);
      return;
    }
    child.layout(childConstraints, parentUsesSize: true);
    size = constraints.constrain(child.size);
  }
}
