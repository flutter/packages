// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../common/span.dart';

// Note: TableSpan and TreeSpan may branch out with unique features in
// the future, so keeping the TableSpan* classes feels more future-safe than
// removing them. Plus, it is not breaking.

/// Defines the leading and trailing padding values of a [TableSpan].
typedef TableSpanPadding = SpanPadding;

/// Defines the extent, visual appearance, and gesture handling of a row or
/// column in a [TableView].
///
/// A span refers to either a column or a row in a table.
typedef TableSpan = Span;

/// Delegate passed to [TableSpanExtent.calculateExtent] from the
/// [RenderTableViewport] during layout.
///
/// Provides access to metrics from the [TableView] that a [TableSpanExtent] may
/// need to calculate its extent.
///
/// Extents will not be computed for every frame unless the delegate has been
/// updated. Otherwise, after the extents are computed during the first layout
/// passed, they are cached and reused in subsequent frames.
typedef TableSpanExtentDelegate = SpanExtentDelegate;

/// Defines the extent of a [TableSpan].
///
/// If the span is a row, its extent is the height of the row. If the span is
/// a column, it's the width of that column.
typedef TableSpanExtent = SpanExtent;

/// A span extent with a fixed [pixels] value.
typedef FixedTableSpanExtent = FixedSpanExtent;

/// Specified the span extent as a fraction of the viewport extent.
///
/// For example, a column with a 1.0 as [fraction] will be as wide as the
/// viewport.
typedef FractionalTableSpanExtent = FractionalSpanExtent;

/// Specifies that the span should occupy the remaining space in the viewport.
///
/// If the previous [TableSpan]s can already fill out the viewport, this will
/// evaluate the span's extent to zero. If the previous spans cannot fill out the
/// viewport, this span's extent will be whatever space is left to fill out the
/// viewport.
///
/// To avoid that the span's extent evaluates to zero, consider combining this
/// extent with another extent. The following example will make sure that the
/// span's extent is at least 200 pixels, but if there's more than that available
/// in the viewport, it will fill all that space:
///
/// ```dart
/// const MaxTableSpanExtent(FixedTableSpanExtent(200.0), RemainingTableSpanExtent());
/// ```
typedef RemainingTableSpanExtent = RemainingSpanExtent;

/// Signature for a function that combines the result of two
/// [TableSpanExtent.calculateExtent] invocations.
///
/// Used by [CombiningTableSpanExtent];
typedef TableSpanExtentCombiner = SpanExtentCombiner;

/// Runs the result of two [TableSpanExtent]s through a `combiner` function
/// to determine the ultimate pixel extent of a span.
typedef CombiningTableSpanExtent = CombiningSpanExtent;

/// Returns the larger pixel extent of the two provided [TableSpanExtent].
typedef MaxTableSpanExtent = MaxSpanExtent;

/// Returns the smaller pixel extent of the two provided [TableSpanExtent].
typedef MinTableSpanExtent = MinSpanExtent;

/// A decoration for a [TableSpan].
///
/// When decorating merged cells in the [TableView], a merged cell will take its
/// decoration from the leading cell of the merged span.
typedef TableSpanDecoration = SpanDecoration;

/// Describes the border for a [TableSpan].
typedef TableSpanBorder = SpanBorder;

/// Provides the details of a given [TableSpanDecoration] for painting.
///
/// Created during paint by the [RenderTableViewport] for the
/// [TableSpan.foregroundDecoration] and [TableSpan.backgroundDecoration].
typedef TableSpanDecorationPaintDetails = SpanDecorationPaintDetails;
