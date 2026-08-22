// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'package:vector_math/vector_math_64.dart' show Matrix4;

import 'shapes/cubic.dart';
import 'shapes/morph.dart';
import 'shapes/rounded_polygon.dart';

/// A border that fits a material-shaped border within the rectangle of the
/// widget it is applied to.
///
/// Typically used with a [ShapeDecoration] to draw a material-shaped border.
class MaterialShapeBorder extends OutlinedBorder {
  MaterialShapeBorder({required RoundedPolygon this.shape, super.side, this.squash = 0})
    : _cubics = shape.cubics,
      assert(squash >= 0 && squash <= 1, 'squash has to be in range [0, 1]');

  const MaterialShapeBorder._fromCubics({required this._cubics, super.side, this.squash = 0})
    : shape = null,
      assert(squash >= 0 && squash <= 1, 'squash has to be in range [0, 1]');

  /// The shape this border represents.
  ///
  /// This value could be `null` if border is the result of lerp.
  final RoundedPolygon? shape;

  /// How much of the aspect ratio of the attached widget to take on.
  ///
  /// If [squash] is non-zero, the border will match the aspect ratio of the
  /// bounding box of the widget that it is attached to, which can give a
  /// squashed appearance.
  ///
  /// The [squash] parameter lets you control how much of that aspect ratio this
  /// border takes on.
  ///
  /// A value of zero means that the border will be drawn with a square aspect
  /// ratio at the size of the shortest side of the bounding rectangle, ignoring
  /// the aspect ratio of the widget, and a value of one means it will be drawn
  /// with the aspect ratio of the widget. The value of [squash] has no effect
  /// if the widget is square to begin with.
  ///
  /// Defaults to zero, and must be between zero and one, inclusive.
  final double squash;

  final List<CubicBezier> _cubics;

  @override
  ShapeBorder scale(double t) {
    final RoundedPolygon? shape = this.shape;

    if (shape != null) {
      return MaterialShapeBorder(shape: shape, side: side.scale(t), squash: squash);
    }

    return MaterialShapeBorder._fromCubics(cubics: _cubics, side: side.scale(t), squash: squash);
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (t == 0) {
      return a;
    }

    if (t == 1.0) {
      return this;
    }

    if (a is MaterialShapeBorder) {
      final RoundedPolygon? aShape = a.shape;
      final RoundedPolygon? shape = this.shape;

      if (aShape == null || shape == null) {
        throw StateError(
          'Lerping requires both MaterialShapeBorders to have non-null shapes. '
          'This border is likely the result of a previous lerp and cannot be '
          'used for further interpolation.',
        );
      }

      return MaterialShapeBorder._fromCubics(
        cubics: Morph(aShape, shape).asCubics(t),
        side: BorderSide.lerp(a.side, side, t),
        squash: ui.lerpDouble(a.squash, squash, t)!,
      );
    }

    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (t == 0) {
      return this;
    }

    if (t == 1.0) {
      return b;
    }

    if (b is MaterialShapeBorder) {
      final RoundedPolygon? bShape = b.shape;
      final RoundedPolygon? shape = this.shape;

      if (bShape == null || shape == null) {
        throw StateError(
          'Lerping requires both MaterialShapeBorders to have non-null shapes. '
          'This border is likely the result of a previous lerp and cannot be '
          'used for further interpolation.',
        );
      }

      return MaterialShapeBorder._fromCubics(
        cubics: Morph(shape, bShape).asCubics(t),
        side: BorderSide.lerp(side, b.side, t),
        squash: ui.lerpDouble(squash, b.squash, t)!,
      );
    }

    return super.lerpTo(b, t);
  }

  @override
  MaterialShapeBorder copyWith({RoundedPolygon? shape, BorderSide? side, double? squash}) {
    if (shape != null) {
      return MaterialShapeBorder(
        shape: shape,
        side: side ?? this.side,
        squash: squash ?? this.squash,
      );
    }

    final RoundedPolygon? oldShape = this.shape;

    if (oldShape != null) {
      return MaterialShapeBorder(
        shape: oldShape,
        side: side ?? this.side,
        squash: squash ?? this.squash,
      );
    }

    return MaterialShapeBorder._fromCubics(
      cubics: _cubics,
      side: side ?? this.side,
      squash: squash ?? this.squash,
    );
  }

  Path _getPathFromRect(Rect rect) {
    var scale = Offset(rect.width, rect.height);

    if (rect.shortestSide == rect.width) {
      scale = Offset(scale.dx, squash * scale.dy + (1 - squash) * scale.dx);
    } else {
      scale = Offset(squash * scale.dx + (1 - squash) * scale.dy, scale.dy);
    }

    final Rect actualRect =
        Offset(rect.left + (rect.width - scale.dx) / 2, rect.top + (rect.height - scale.dy) / 2) &
        Size(scale.dx, scale.dy);

    final matrix = Matrix4.identity()
      ..translate(actualRect.left, actualRect.top)
      ..scale(scale.dx, scale.dy);

    return pathFromCubics(
      path: Path(),
      startAngle: 0,
      repeatPath: false,
      closePath: true,
      cubics: _cubics,
      rotationPivotX: 0,
      rotationPivotY: 0,
    ).transform(matrix.storage);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final Rect adjustedRect = rect.deflate(side.strokeInset);
    return _getPathFromRect(adjustedRect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final Rect adjustedRect = rect.inflate(side.strokeOutset);
    return _getPathFromRect(adjustedRect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    switch (side.style) {
      case BorderStyle.none:
        return;

      case BorderStyle.solid:
        final Rect adjustedRect = rect.inflate(side.strokeOffset / 2);
        final Path path = _getPathFromRect(adjustedRect);
        canvas.drawPath(path, side.toPaint());
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is MaterialShapeBorder &&
        other.shape == shape &&
        other._cubics == _cubics &&
        other.side == side &&
        other.squash == squash;
  }

  @override
  int get hashCode => Object.hash(shape, _cubics, squash, side.hashCode);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'MaterialShapeBorder')}'
        '(side: $side, squash: $squash)';
  }
}
