// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/painting.dart';

import '../common/span.dart';

/// Defines the leading and trailing padding values of a [TreeRow].
typedef TreeRowPadding = SpanPadding;

/// Defines the extent, visual appearance, and gesture handling of a row in a
/// [TreeView].
typedef TreeRow = Span;

/// Delegate passed to [TreeSpanExtent.calculateExtent] from the
/// [RenderTreeViewport] during layout.
///
/// Provides access to metrics from the [TreeView] that a [TreeRowExtent] may
/// need to calculate its extent.
///
/// Extents will not be computed for every frame unless the delegate has been
/// updated. Otherwise, after the extents are computed during the first layout
/// pass, they are cached and reused in subsequent frames.
typedef TreeRowExtentDelegate = SpanExtentDelegate;

/// Defines the extent, or height, of a [TreeRow].
typedef TreeRowExtent = SpanExtent;

/// A [TreeRow] with a fixed [pixels] height.
typedef FixedTreeRowExtent = FixedSpanExtent;

/// Specified the [TreeRow] height as a fraction of the viewport extent.
///
/// For example, a row with a 1.0 as [fraction] will be as tall as the
/// viewport.
typedef FractionalTreeRowExtent = FractionalSpanExtent;

/// Specifies that the row should occupy the remaining space in the viewport.
///
/// If the previous [TreeRow]s can already fill out the viewport, this will
/// evaluate the row's height to zero. If the previous rows cannot fill out the
/// viewport, this row's extent will be whatever space is left to fill out the
/// viewport.
///
/// To avoid that the row's extent evaluates to zero, consider combining this
/// extent with another extent. The following example will make sure that the
/// span's extent is at least 200 pixels, but if there's more than that available
/// in the viewport, it will fill all that space:
///
/// ```dart
/// const MaxTreeRowExtent(FixedTreeRowExtent(200.0), RemainingTreeRowExtent());
/// ```
typedef RemainingTreeRowExtent = RemainingSpanExtent;

/// Signature for a function that combines the result of two
/// [TreeRowExtent.calculateExtent] invocations.
///
/// Used by [CombiningTreeRowExtent];
typedef TreeRowExtentCombiner = SpanExtentCombiner;

/// Runs the result of two [TreeRowExtent]s through a `combiner` function
/// to determine the ultimate pixel height of a tree row.
typedef CombiningTreeRowExtent = CombiningSpanExtent;

/// Returns the larger pixel extent of the two provided [TreeRowExtent].
typedef MaxTreeRowExtent = MaxSpanExtent;

/// Returns the smaller pixel extent of the two provided [TreeRowExtent].
typedef MinTreeRowExtent = MinSpanExtent;

/// A decoration for a [TreeRow].
typedef TreeRowDecoration = SpanDecoration;

/// Describes the border for a [TreeRow].
class TreeRowBorder extends SpanBorder {
  /// Creates a [TreeRowBorder].
  const TreeRowBorder({
    BorderSide top = BorderSide.none,
    BorderSide bottom = BorderSide.none,
    this.left = BorderSide.none,
    this.right = BorderSide.none,
  }) : super(leading: top, trailing: bottom);

  /// Creates a [TreeRowBorder] with the provided [BorderSide] applied to all
  /// sides.
  const TreeRowBorder.all(BorderSide side)
      : left = side,
        right = side,
        super(leading: side, trailing: side);

  /// The border to paint on the top, or leading edge of the [TreeRow].
  BorderSide get top => leading;

  /// The border to paint on the top, or leading edge of the [TreeRow].
  BorderSide get bottom => trailing;

  /// The border to draw on the left side of the [TreeRow].
  final BorderSide left;

  /// The border to draw on the right side of the [TreeRow].
  final BorderSide right;

  @override
  void paint(
    SpanDecorationPaintDetails details,
    BorderRadius? borderRadius,
  ) {
    final Border border = Border(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
    );
    border.paint(
      details.canvas,
      details.rect,
      borderRadius: borderRadius,
    );
  }
}

/// Provides the details of a given [TreeRowDecoration] for painting.
///
/// Created during paint by the [RenderTreeViewport] for the
/// [TreeRow.foregroundDecoration] and [TreeRow.backgroundDecoration].
typedef TreeRowDecorationPaintDetails = SpanDecorationPaintDetails;
