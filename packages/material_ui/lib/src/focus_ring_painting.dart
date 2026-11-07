// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'ink_well.dart';
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'color_scheme.dart';
import 'focus_ring_theme.dart';
import 'theme.dart';

// md.sys.state.focus-indicator.thickness
const double _kDefaultFocusRingWidth = 3.0;

/// The resolved colors and width of the keyboard focus ring, used by Material
/// widgets that paint their own focus visuals.
///
/// This is not exported. [InkResponse] and the toggleable and slider painters
/// use it so that every widget draws the same ring from the same
/// [FocusRingThemeData].
@immutable
class FocusRingStyle {
  /// Creates a resolved focus ring style.
  const FocusRingStyle({required this.color, this.innerColor, required this.width});

  /// Resolves the focus ring for `context`, or returns null when
  /// [FocusRingThemeData.visible] is not true.
  static FocusRingStyle? maybeOf(BuildContext context) {
    final FocusRingThemeData data = FocusRingTheme.of(context);
    if (!(data.visible ?? false)) {
      return null;
    }
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return FocusRingStyle(
      color: data.color ?? colorScheme.secondary,
      innerColor: data.innerColor ?? colorScheme.onSecondary,
      width: data.width ?? _kDefaultFocusRingWidth,
    );
  }

  /// The color of the ring.
  final Color color;

  /// The color of the band drawn just inside the ring, or null for none.
  final Color? innerColor;

  /// The width of the ring, and of the inner band.
  final double width;

  /// Paints the ring, and the inner band when there is one.
  ///
  /// `offset` is the distance from the shape's edge to the ring's inner edge,
  /// like the CSS `outline-offset` property; positive values are outside the
  /// shape. `strokeShape` strokes the shape grown by the given delta on every
  /// side, with the given paint.
  void paint(
    Canvas canvas,
    double offset,
    void Function(Canvas canvas, double delta, Paint paint) strokeShape,
  ) {
    // The ring spans from `offset` to `offset + width` outside the shape's
    // edge, so its stroke is centered half a width further out.
    final double delta = offset + width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final Color? inner = innerColor;
    if (inner != null && inner.a > 0) {
      // The inner band sits directly inside the ring, one width closer to the
      // shape.
      strokeShape(canvas, delta - width, paint..color = inner);
    }
    strokeShape(canvas, delta, paint..color = color);
  }

  /// Paints the ring around a rounded rectangle.
  void paintRRect(Canvas canvas, RRect shape, double offset) {
    paint(canvas, offset, (Canvas canvas, double delta, Paint paint) {
      if (shape.width + 2 * delta > 0 && shape.height + 2 * delta > 0) {
        canvas.drawRRect(inflateRRect(shape, delta), paint);
      }
    });
  }

  /// Paints the ring around a circle.
  void paintCircle(Canvas canvas, Offset center, double radius, double offset) {
    paint(canvas, offset, (Canvas canvas, double delta, Paint paint) {
      if (radius + delta > 0) {
        canvas.drawCircle(center, radius + delta, paint);
      }
    });
  }

  /// Grows or shrinks a rounded rectangle by `delta` on every side, keeping a
  /// ring concentric with the shape. Square corners stay square.
  static RRect inflateRRect(RRect rrect, double delta) {
    Radius grow(Radius radius) {
      if (radius == Radius.zero) {
        return Radius.zero;
      }
      return Radius.elliptical(math.max(0, radius.x + delta), math.max(0, radius.y + delta));
    }

    return RRect.fromLTRBAndCorners(
      rrect.left - delta,
      rrect.top - delta,
      rrect.right + delta,
      rrect.bottom + delta,
      topLeft: grow(rrect.tlRadius),
      topRight: grow(rrect.trRadius),
      bottomLeft: grow(rrect.blRadius),
      bottomRight: grow(rrect.brRadius),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is FocusRingStyle &&
        other.color == color &&
        other.innerColor == innerColor &&
        other.width == width;
  }

  @override
  int get hashCode => Object.hash(color, innerColor, width);
}
