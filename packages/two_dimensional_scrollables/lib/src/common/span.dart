// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Defines the leading and trailing padding values of a [Span].
class SpanPadding {
  /// Creates a padding configuration for a [Span].
  const SpanPadding({
    this.leading = 0.0,
    this.trailing = 0.0,
  });

  /// Creates padding where both the [leading] and [trailing] are `value`.
  const SpanPadding.all(double value)
      : leading = value,
        trailing = value;

  /// The leading amount of pixels to pad a [Span] by.
  ///
  /// If the [Span] is a row and the vertical [Axis] is not reversed, this
  /// offset will be applied above the row. If the vertical [Axis] is reversed,
  /// this will be applied below the row.
  ///
  /// If the [Span] is a column and the horizontal [Axis] is not reversed,
  /// this offset will be applied to the left the column. If the horizontal
  /// [Axis] is reversed, this will be applied to the right of the column.
  final double leading;

  /// The trailing amount of pixels to pad a [Span] by.
  ///
  /// If the [Span] is a row and the vertical [Axis] is not reversed, this
  /// offset will be applied below the row. If the vertical [Axis] is reversed,
  /// this will be applied above the row.
  ///
  /// If the [Span] is a column and the horizontal [Axis] is not reversed,
  /// this offset will be applied to the right the column. If the horizontal
  /// [Axis] is reversed, this will be applied to the left of the column.
  final double trailing;
}

/// Defines the extent, visual appearance, and gesture handling of a row or
/// column.
///
/// A span refers to either a column or a row.
class Span {
  /// Creates a [Span].
  ///
  /// The [extent] argument must be provided.
  const Span({
    required this.extent,
    SpanPadding? padding,
    this.recognizerFactories = const <Type, GestureRecognizerFactory>{},
    this.onEnter,
    this.onExit,
    this.cursor = MouseCursor.defer,
    this.backgroundDecoration,
    this.foregroundDecoration,
  }) : padding = padding ?? const SpanPadding();

  /// Create a clone of the current [Span] but with provided
  /// parameters overridden.
  Span copyWith({
    SpanExtent? extent,
    SpanPadding? padding,
    Map<Type, GestureRecognizerFactory>? recognizerFactories,
    PointerEnterEventListener? onEnter,
    PointerExitEventListener? onExit,
    MouseCursor? cursor,
    SpanDecoration? backgroundDecoration,
    SpanDecoration? foregroundDecoration,
  }) {
    return Span(
      extent: extent ?? this.extent,
      padding: padding ?? this.padding,
      recognizerFactories: recognizerFactories ?? this.recognizerFactories,
      onEnter: onEnter ?? this.onEnter,
      onExit: onExit ?? this.onExit,
      cursor: cursor ?? this.cursor,
      backgroundDecoration: backgroundDecoration ?? this.backgroundDecoration,
      foregroundDecoration: foregroundDecoration ?? this.foregroundDecoration,
    );
  }

  /// Defines the extent of the span.
  ///
  /// If the span represents a row, this is the height of the row. If it
  /// represents a column, this is the width of the column.
  final SpanExtent extent;

  /// Defines the leading and or trailing extent to pad the row or column by.
  ///
  /// Defaults to no padding.
  final SpanPadding padding;

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

  /// The [SpanDecoration] to paint behind the content of this span.
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
  final SpanDecoration? backgroundDecoration;

  /// The [SpanDecoration] to paint in front of the content of this span.
  ///
  /// After painting any [backgroundDecoration]s, and the content of the
  /// individual cells, the [foregroundDecoration] of the [TableView.mainAxis]
  /// are painted after the [foregroundDecoration]s of the other [Axis]
  ///
  /// The decorations of pinned rows and columns are painted separately from
  /// the decorations of unpinned rows and columns, with the unpinned rows and
  /// columns being painted first to account for overlap from pinned rows or
  /// columns.
  final SpanDecoration? foregroundDecoration;
}

/// Delegate passed to [SpanExtent.calculateExtent] from the
/// [RenderTableViewport] during layout.
///
/// Provides access to metrics from the [TableView] that a [SpanExtent] may
/// need to calculate its extent.
///
/// Extents will not be computed for every frame unless the delegate has been
/// updated. Otherwise, after the extents are computed during the first layout
/// passed, they are cached and reused in subsequent frames.
class SpanExtentDelegate {
  /// Creates a [SpanExtentDelegate].
  ///
  /// Usually, only [TableView]s need to create instances of this class.
  const SpanExtentDelegate({
    required this.viewportExtent,
    required this.precedingExtent,
  });

  /// The size of the viewport in the axis-direction of the span.
  ///
  /// If the [SpanExtent] calculates the extent of a row, this is the
  /// height of the viewport. If it calculates the extent of a column, this
  /// is the width of the viewport.
  final double viewportExtent;

  /// The scroll extent that has already been used up by previous spans.
  ///
  /// If the [SpanExtent] calculates the extent of a row, this is the
  /// sum of all row extents prior to this row. If it calculates the extent
  /// of a column, this is the sum of all previous columns.
  final double precedingExtent;
}

/// Defines the extent of a [Span].
///
/// If the span is a row, its extent is the height of the row. If the span is
/// a column, it's the width of that column.
abstract class SpanExtent {
  /// Creates a [SpanExtent].
  const SpanExtent();

  /// Calculates the actual extent of the span in pixels.
  ///
  /// To assist with the calculation, span metrics obtained from the provided
  /// [SpanExtentDelegate] may be used.
  double calculateExtent(SpanExtentDelegate delegate);
}

/// A span extent with a fixed [pixels] value.
class FixedSpanExtent extends SpanExtent {
  /// Creates a [FixedSpanExtent].
  ///
  /// The provided [pixels] value must be equal to or greater then zero.
  const FixedSpanExtent(this.pixels) : assert(pixels >= 0.0);

  /// The extent of the span in pixels.
  final double pixels;

  @override
  double calculateExtent(SpanExtentDelegate delegate) => pixels;
}

/// Specified the span extent as a fraction of the viewport extent.
///
/// For example, a column with a 1.0 as [fraction] will be as wide as the
/// viewport.
class FractionalSpanExtent extends SpanExtent {
  /// Creates a [FractionalSpanExtent].
  ///
  /// The provided [fraction] value must be equal to or greater than zero.
  const FractionalSpanExtent(
    this.fraction,
  ) : assert(fraction >= 0.0);

  /// The fraction of the [SpanExtentDelegate.viewportExtent] that the
  /// span should occupy.
  ///
  /// The provided [fraction] value must be equal to or greater than zero.
  final double fraction;

  @override
  double calculateExtent(SpanExtentDelegate delegate) =>
      delegate.viewportExtent * fraction;
}

/// Specifies that the span should occupy the remaining space in the viewport.
///
/// If the previous [Span]s can already fill out the viewport, this will
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
/// const MaxSpanExtent(FixedSpanExtent(200.0), RemainingSpanExtent());
/// ```
class RemainingSpanExtent extends SpanExtent {
  /// Creates a [RemainingSpanExtent].
  const RemainingSpanExtent();

  @override
  double calculateExtent(SpanExtentDelegate delegate) {
    return math.max(0.0, delegate.viewportExtent - delegate.precedingExtent);
  }
}

/// Signature for a function that combines the result of two
/// [SpanExtent.calculateExtent] invocations.
///
/// Used by [CombiningSpanExtent];
typedef SpanExtentCombiner = double Function(double, double);

/// Runs the result of two [SpanExtent]s through a `combiner` function
/// to determine the ultimate pixel extent of a span.
class CombiningSpanExtent extends SpanExtent {
  /// Creates a [CombiningSpanExtent];
  const CombiningSpanExtent(this._extent1, this._extent2, this._combiner);

  final SpanExtent _extent1;
  final SpanExtent _extent2;
  final SpanExtentCombiner _combiner;

  @override
  double calculateExtent(SpanExtentDelegate delegate) {
    return _combiner(
      _extent1.calculateExtent(delegate),
      _extent2.calculateExtent(delegate),
    );
  }
}

/// Returns the larger pixel extent of the two provided [SpanExtent].
class MaxSpanExtent extends CombiningSpanExtent {
  /// Creates a [MaxSpanExtent].
  const MaxSpanExtent(
    SpanExtent extent1,
    SpanExtent extent2,
  ) : super(extent1, extent2, math.max);
}

/// Returns the smaller pixel extent of the two provided [SpanExtent].
class MinSpanExtent extends CombiningSpanExtent {
  /// Creates a [MinSpanExtent].
  const MinSpanExtent(
    SpanExtent extent1,
    SpanExtent extent2,
  ) : super(extent1, extent2, math.min);
}

/// A decoration for a [Span].
///
/// When decorating merged cells in the [TableView], a merged cell will take its
/// decoration from the leading cell of the merged span.
class SpanDecoration {
  /// Creates a [SpanDecoration].
  const SpanDecoration({
    this.border,
    this.color,
    this.borderRadius,
    this.consumeSpanPadding = true,
  });

  /// The border drawn around the span.
  final SpanBorder? border;

  /// The radius by which the leading and trailing ends of a row or
  /// column will be rounded.
  ///
  /// Applies to the [border] and [color] of the given [Span].
  final BorderRadius? borderRadius;

  /// The color to fill the bounds of the span with.
  final Color? color;

  /// Whether or not the decoration should extend to fill the space created by
  /// the [SpanPadding].
  ///
  /// Defaults to true, meaning if a [Span] is a row, the decoration will
  /// apply to the full [SpanExtent], including the
  /// [SpanPadding.leading] and [SpanPadding.trailing] for the row.
  /// This same row decoration will consume any padding from the column spans so
  /// as to decorate the row as one continuous span.
  ///
  /// {@tool snippet}
  /// This example illustrates how [consumeSpanPadding] affects
  /// [SpanDecoration.color]. By default, the color of the decoration
  /// consumes the padding, coloring the row fully by including the padding
  /// around the row. When [consumeSpanPadding] is false, the padded area of
  /// the row is not decorated.
  ///
  /// ```dart
  /// TableView.builder(
  ///   rowCount: 4,
  ///   columnCount: 4,
  ///   columnBuilder: (int index) => TableSpan(
  ///     extent: const FixedTableSpanExtent(150.0),
  ///     padding: const TableSpanPadding(trailing: 10),
  ///   ),
  ///   rowBuilder: (int index) => TableSpan(
  ///     extent: const FixedTableSpanExtent(150.0),
  ///     padding: TableSpanPadding(leading: 10, trailing: 10),
  ///     backgroundDecoration: TableSpanDecoration(
  ///       color: index.isOdd ? Colors.blue : Colors.green,
  ///       // The background color will not be applied to the padded area.
  ///       consumeSpanPadding: false,
  ///     ),
  ///   ),
  ///   cellBuilder: (_, TableVicinity vicinity) {
  ///     return Container(
  ///       height: 150,
  ///       width: 150,
  ///       child: const Center(child: FlutterLogo()),
  ///     );
  ///   },
  /// );
  /// ```
  /// {@end-tool}
  final bool consumeSpanPadding;

  /// Called to draw the decoration around a span.
  ///
  /// The provided [SpanDecorationPaintDetails] describes the bounds and
  /// orientation of the span that are currently visible inside the viewport.
  /// The extent of the actual span may be larger.
  ///
  /// If a span contains pinned parts, [paint] is invoked separately for the
  /// pinned and unpinned parts. For example: If a row contains a pinned column,
  /// paint is called with the [SpanDecorationPaintDetails.rect] for the
  /// cell representing the pinned column and separately with another
  /// [SpanDecorationPaintDetails.rect] containing all the other unpinned
  /// cells.
  void paint(SpanDecorationPaintDetails details) {
    if (color != null) {
      final Paint paint = Paint()
        ..color = color!
        ..isAntiAlias = borderRadius != null;
      if (borderRadius == null || borderRadius == BorderRadius.zero) {
        details.canvas.drawRect(details.rect, paint);
      } else {
        details.canvas.drawRRect(
          borderRadius!.toRRect(details.rect),
          paint,
        );
      }
    }
    if (border != null) {
      border!.paint(details, borderRadius);
    }
  }
}

/// Describes the border for a [Span].
class SpanBorder {
  /// Creates a [SpanBorder].
  const SpanBorder({
    this.trailing = BorderSide.none,
    this.leading = BorderSide.none,
  });

  /// The border to draw on the trailing side of the span, based on the
  /// [AxisDirection].
  ///
  /// The trailing side of a row is the bottom when [Axis.vertical] is
  /// [AxisDirection.down], the trailing side of a column
  /// is its right side when the [Axis.horizontal] is [AxisDirection.right].
  final BorderSide trailing;

  /// The border to draw on the leading side of the span.
  ///
  /// The leading side of a row is the top when [Axis.vertical] is
  /// [AxisDirection.down], the leading side of a column
  /// is its left side when the [Axis.horizontal] is [AxisDirection.right].
  final BorderSide leading;

  /// Called to draw the border around a span.
  ///
  /// If the span represents a row, `axisDirection` will be [AxisDirection.left]
  /// or [AxisDirection.right]. For columns, the `axisDirection` will be
  /// [AxisDirection.down] or [AxisDirection.up].
  ///
  /// The provided [SpanDecorationPaintDetails] describes the bounds and
  /// orientation of the span that are currently visible inside the viewport.
  /// The extent of the actual span may be larger.
  ///
  /// If a span contains pinned parts, [paint] is invoked separately for the
  /// pinned and unpinned parts. For example: If a row contains a pinned column,
  /// paint is called with the [SpanDecorationPaintDetails.rect] for the
  /// cell representing the pinned column and separately with another
  /// [SpanDecorationPaintDetails.rect] containing all the other unpinned
  /// cells.
  void paint(
    SpanDecorationPaintDetails details,
    BorderRadius? borderRadius,
  ) {
    final AxisDirection axisDirection = details.axisDirection;
    switch (axisDirectionToAxis(axisDirection)) {
      case Axis.horizontal:
        final Border border = Border(
          top: axisDirection == AxisDirection.right ? leading : trailing,
          bottom: axisDirection == AxisDirection.right ? trailing : leading,
        );
        border.paint(
          details.canvas,
          details.rect,
          borderRadius: borderRadius,
        );
      case Axis.vertical:
        final Border border = Border(
          left: axisDirection == AxisDirection.down ? leading : trailing,
          right: axisDirection == AxisDirection.down ? trailing : leading,
        );
        border.paint(
          details.canvas,
          details.rect,
          borderRadius: borderRadius,
        );
    }
  }
}

/// Provides the details of a given [SpanDecoration] for painting.
///
/// Created during paint by the [RenderTableViewport] for the
/// [Span.foregroundDecoration] and [Span.backgroundDecoration].
class SpanDecorationPaintDetails {
  /// Creates the details needed to paint a [SpanDecoration].
  ///
  /// The [canvas], [rect], and [axisDirection] must be provided.
  SpanDecorationPaintDetails({
    required this.canvas,
    required this.rect,
    required this.axisDirection,
  });

  /// The [Canvas] that the [SpanDecoration] will be painted to.
  final Canvas canvas;

  /// A [Rect] representing the visible area of a row or column in the
  /// [TableView], as represented by a [Span].
  ///
  /// This Rect contains all of the visible children in a given row or column,
  /// which is the area the [SpanDecoration] will be applied to.
  final Rect rect;

  /// The [AxisDirection] of the [Axis] of the [Span].
  ///
  /// When [AxisDirection.down] or [AxisDirection.up], which would be
  /// [Axis.vertical], a column is being painted. When [AxisDirection.left] or
  /// [AxisDirection.right], which would be [Axis.horizontal], a row is being
  /// painted.
  final AxisDirection axisDirection;
}
