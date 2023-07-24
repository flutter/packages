// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'table.dart';

/// Defines the extent, visual appearance, and gesture handling of a row or
/// column in a [TableView].
///
/// A span refers to either a column or a row in a table.
class TableSpan {
  /// Creates a [TableSpan].
  ///
  /// The [extent] argument must be provided.
  const TableSpan({
    required this.extent,
    this.recognizerFactories = const <Type, GestureRecognizerFactory>{},
    this.onEnter,
    this.onExit,
    this.cursor = MouseCursor.defer,
    this.backgroundDecoration,
    this.foregroundDecoration,
  });

  /// Defines the extent of the span.
  ///
  /// If the span represents a row, this is the height of the row. If it
  /// represents a column, this is the width of the column.
  final TableSpanExtent extent;

  /// Factory for creating [GestureRecognizer]s that want to compete for
  /// gestures within the [extent] of the span.
  ///
  /// If this span represents a row, a factory for a [TapGestureRecognizer]
  /// could for example be provided here to recognize taps within the bounds
  /// of the row.
  ///
  /// The content of a cell takes precedence in handling pointer events. Next,
  /// the recognizers defined for the [TableView.mainAxis], followed by the
  /// other [Axis].
  final Map<Type, GestureRecognizerFactory> recognizerFactories;

  /// Triggers when a mouse pointer, with or without buttons pressed, has
  /// entered the region encompassing the row or column described by this span.
  ///
  /// This callback is triggered when the pointer has started to be contained by
  /// the region, either due to a pointer event, or due to the movement or
  /// appearance of the region. This method is always matched by a later
  /// [onExit] call.
  final PointerEnterEventListener? onEnter;

  /// Triggered when a mouse pointer, with or without buttons pressed, has
  /// exited the region encompassing the row or column described by this span.
  ///
  /// This callback is triggered when the pointer has stopped being contained
  /// by the region, either due to a pointer event, or due to the movement or
  /// disappearance of the region. This method always matches an earlier
  /// [onEnter] call.
  final PointerExitEventListener? onExit;

  /// Mouse cursor to show when the mouse hovers over this span.
  ///
  /// Defaults to [MouseCursor.defer].
  final MouseCursor cursor;

  /// The [TableSpanDecoration] to paint behind the content of this span.
  ///
  /// The [backgroundDecoration]s of the [TableView.mainAxis] are painted after
  /// the [backgroundDecoration]s of the other [Axis]. On top of that,
  /// the content of the individual cells in this span are painted, followed by
  /// any specified [foregroundDecoration].
  ///
  /// The decorations of pinned rows and columns are painted separately from
  /// the decorations of unpinned rows and columns, with the unpinned rows and
  /// columns being painted first to account for overlap from pinned rows or
  /// columns.
  final TableSpanDecoration? backgroundDecoration;

  /// The [TableSpanDecoration] to paint in front of the content of this span.
  ///
  /// After painting any [backgroundDecoration]s, and the content of the
  /// individual cells, the [foregroundDecoration] of the [TableView.mainAxis]
  /// are painted after the [foregroundDecoration]s of the other [Axis]
  ///
  /// The decorations of pinned rows and columns are painted separately from
  /// the decorations of unpinned rows and columns, with the unpinned rows and
  /// columns being painted first to account for overlap from pinned rows or
  /// columns.
  final TableSpanDecoration? foregroundDecoration;
}

/// Delegate passed to [TableSpanExtent.calculateExtent].
///
/// Provides access to metrics from the [TableView] that a [TableSpanExtent] may
/// need to calculate its extent.
class TableSpanExtentDelegate {
  /// Creates a [TableSpanExtentDelegate].
  ///
  /// Usually, only [TableView]s need to create instances of this class.
  const TableSpanExtentDelegate({
    required this.viewportExtent,
    required this.precedingExtent,
  });

  /// The size of the viewport in the axis-direction of the span.
  ///
  /// If the [TableSpanExtent] calculates the extent of a row, this is the
  /// height of the viewport. If it calculates the extent of a column, this
  /// is the width of the viewport.
  final double viewportExtent;

  /// The scroll extent that has already been used up by previous spans.
  ///
  /// If the [TableSpanExtent] calculates the extent of a row, this is the
  /// sum of all row extents prior to this row. If it calculates the extent
  /// of a column, this is the sum of all previous columns.
  final double precedingExtent;
}

/// Defines the extent of a [TableSpan].
///
/// If the span is a row, its extent is the height of the row. If the span is
/// a column, it's the width of that column.
abstract class TableSpanExtent {
  /// Creates a [TableSpanExtent].
  const TableSpanExtent();

  /// Calculates the actual extent of the span in pixels.
  ///
  /// To assist with the calculation, table metrics obtained from the provided
  /// [TableSpanExtentDelegate] may be used.
  double calculateExtent(TableSpanExtentDelegate delegate);
}

/// A span extent with a fixed [pixels] value.
class FixedTableSpanExtent extends TableSpanExtent {
  /// Creates a [FixedTableSpanExtent].
  ///
  /// The provided [pixels] value must be equal to or greater then zero.
  const FixedTableSpanExtent(this.pixels) : assert(pixels >= 0.0);

  /// The extent of the span in pixels.
  final double pixels;

  @override
  double calculateExtent(TableSpanExtentDelegate delegate) => pixels;
}

/// Specified the span extent as a fraction of the viewport extent.
///
/// For example, a column with a 1.0 as [fraction] will be as wide as the
/// viewport.
class FractionalTableSpanExtent extends TableSpanExtent {
  /// Creates a [FractionalTableSpanExtent].
  ///
  /// The provided [fraction] value must be equal to or grater then zero.
  const FractionalTableSpanExtent(
    this.fraction,
  ) : assert(fraction >= 0.0 && fraction <= 1.0);

  /// The fraction of the [TableSpanExtentDelegate.viewportExtent] that the
  /// span should occupy.
  final double fraction;

  @override
  double calculateExtent(TableSpanExtentDelegate delegate) =>
      delegate.viewportExtent * fraction;
}

/// Specifies that the span should occupy the remaining space in the viewport.
///
/// If the previous span can already fill out the viewport, this will evaluate
/// the span's extent to zero. If the previous span cannot fill out the viewport,
/// this span's extent will be whatever space is left to fill out the viewport.
///
/// To avoid that the span's extent evaluates to zero, consider combining this
/// extent with another extent. The following example will make sure that the
/// span's extent is at least 200 pixels, but if there's more than that available
/// in the viewport, it will fill all that space.:
///
/// ```dart
/// const MaxTableSpanExtent(FixedTableSpanExtent(200.0), RemainingTableSpanExtent());
/// ```
class RemainingTableSpanExtent extends TableSpanExtent {
  /// Creates a [RemainingTableSpanExtent].
  const RemainingTableSpanExtent();

  @override
  double calculateExtent(TableSpanExtentDelegate delegate) {
    return math.max(0.0, delegate.viewportExtent - delegate.precedingExtent);
  }
}

/// Signature for a function that combines the result of two
/// [TableSpanExtent.calculateExtent] invocations.
///
/// Used by [CombiningTableSpanExtent];
typedef TableSpanExtentCombiner = double Function(double, double);

/// Runs the result of two [TableSpanExtent]s through a `combiner` function
/// to determine the ultimate pixel extent of a span.
class CombiningTableSpanExtent extends TableSpanExtent {
  /// Creates a [CombiningTableSpanExtent];
  const CombiningTableSpanExtent(this._extent1, this._extent2, this._combiner);

  final TableSpanExtent _extent1;
  final TableSpanExtent _extent2;
  final TableSpanExtentCombiner _combiner;

  @override
  double calculateExtent(TableSpanExtentDelegate delegate) {
    return _combiner(
      _extent1.calculateExtent(delegate),
      _extent2.calculateExtent(delegate),
    );
  }
}

/// Returns the larger pixel extent of the two provided [TableSpanExtent].
class MaxTableSpanExtent extends CombiningTableSpanExtent {
  /// Creates a [MaxTableSpanExtent].
  const MaxTableSpanExtent(
    TableSpanExtent extent1,
    TableSpanExtent extent2,
  ) : super(extent1, extent2, math.max);
}

/// Returns the smaller pixel extent of the two provided [TableSpanExtent].
class MinTableSpanExtent extends CombiningTableSpanExtent {
  /// Creates a [MinTableSpanExtent].
  const MinTableSpanExtent(
    TableSpanExtent extent1,
    TableSpanExtent extent2,
  ) : super(extent1, extent2, math.min);
}

/// A decoration for a [TableSpan].
class TableSpanDecoration {
  /// Creates a [TableSpanDecoration].
  const TableSpanDecoration({this.border, this.color});

  /// The border drawn around the span.
  final TableSpanBorder? border;

  /// The color to fill the bounds of the span with.
  final Color? color;

  /// Called to draw the decoration around a span.
  ///
  /// If the span represents a row, `axis` will be [Axis.horizontal]. For
  /// columns, [Axis.vertical] is used.
  ///
  /// The provided `rect` describes the bounds of the span that are currently
  /// visible inside the viewport of the table. The extent of the actual span
  /// may be larger.
  ///
  /// If a span contains pinned parts, [paint] is invoked separately for the pinned
  /// and unpinned parts. For example: If a row contains a pinned column,
  /// paint is called with the `rect` for the cell representing the pinned
  /// column and separately with a `rect` containing all the other unpinned
  /// cells.
  void paint(Canvas canvas, Rect rect, Axis axis) {
    if (color != null) {
      canvas.drawRect(
        rect,
        Paint()
          ..color = color!
          ..isAntiAlias = false,
      );
    }
    if (border != null) {
      border!.paint(canvas, rect, axis);
    }
  }
}

/// Describes the border for a [TableSpan].
class TableSpanBorder {
  /// Creates a [TableSpanBorder].
  const TableSpanBorder({
    this.trailing = BorderSide.none,
    this.leading = BorderSide.none,
  });

  /// The border to draw on the trailing side of the span.
  ///
  /// The trailing side of a row is the bottom, the trailing side of a column
  /// is its right side.
  final BorderSide trailing;

  /// The border to draw on the leading side of the span.
  ///
  /// The leading side of a row is the top, the trailing side of a column
  /// is its left side.
  final BorderSide leading;

  /// Called to draw the border around a span.
  ///
  /// If the span represents a row, `axis` will be [Axis.horizontal]. For
  /// columns, [Axis.vertical] is used.
  ///
  /// The provided `rect` describes the bounds of the span that are currently
  /// visible inside the viewport of the table. The extent of the actual span
  /// may be larger.
  ///
  /// If a span contains pinned parts, [paint] is invoked separately for the pinned
  /// and unpinned parts. For example: If a row contains a pinned column,
  /// paint is called with the `rect` for the cell representing the pinned
  /// column and separately with a `rect` containing all the other unpinned
  /// cells.
  void paint(Canvas canvas, Rect rect, Axis axis) {
    switch (axis) {
      case Axis.horizontal:
        paintBorder(canvas, rect, top: leading, bottom: trailing);
        break;
      case Axis.vertical:
        paintBorder(canvas, rect, left: leading, right: trailing);
        break;
    }
  }
}
