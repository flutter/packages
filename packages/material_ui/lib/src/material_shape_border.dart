// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'material_shapes.dart';
library;

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
  /// Creates a [MaterialShapeBorder].
  const MaterialShapeBorder({required this.shape, super.side, this.squash = 0})
    : assert(squash >= 0 && squash <= 1, 'squash has to be in range [0, 1]');

  /// The shape this border represents.
  ///
  /// The polygon is assumed to fit inside the (0, 0) -> (1, 1) unit square,
  /// as the border scales it to the bounding rectangle of the widget it is
  /// applied to. Shapes from [MaterialShapes] already satisfy this. For an
  /// arbitrary polygon, use [RoundedPolygon.normalized].
  final RoundedPolygon shape;

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

  // The number 5 was chosen without any real science behind it. It is small
  // enough that the cached morphs fit comfortably in memory, and large enough
  // for the few pairs of shapes a screen animates between at once.
  static const int _morphCacheSize = 5;

  /// Caches the mapping between pairs of shapes to speed up [lerpFrom] and
  /// [lerpTo].
  static final _morphCache = _FifoCache<_MorphCacheKey, Morph>(_morphCacheSize);

  /// Returns the [Morph] between [start] and [end], reusing a cached one when
  /// possible.
  ///
  /// Creating a [Morph] matches up the curves of both shapes, which is much
  /// more expensive than evaluating it at a progress value. A transition asks
  /// for the same pair of shapes on every frame, so the result is worth
  /// keeping.
  static Morph _morphBetween(RoundedPolygon start, RoundedPolygon end) {
    return _morphCache.putIfAbsent(_MorphCacheKey(start, end), () => Morph(start, end));
  }

  /// Whether [border] is a [MaterialShapeBorder] or the result of lerping
  /// between two of them.
  static bool _canLerpWith(OutlinedBorder border) {
    return border is MaterialShapeBorder || border is _MorphingShapeBorder;
  }

  /// Interpolates from [a] to [b] at [t], or returns `null` if the two borders
  /// have no morph in common.
  ///
  /// Both borders must satisfy [_canLerpWith].
  ///
  /// The [lerpFrom] and [lerpTo] of both border classes delegate here so that
  /// they always give the same answer. [ShapeBorder.lerp] tries them in both
  /// directions, so a pair accepted by one but declined by another would
  /// animate backwards or never reach the snapping fallback.
  static OutlinedBorder? _lerp(OutlinedBorder a, OutlinedBorder b, double t) {
    final BorderSide side = BorderSide.lerp(a.side, b.side, t);
    final double squash = ui.lerpDouble(_squashOf(a), _squashOf(b), t)!.clamp(0.0, 1.0);

    if (a is MaterialShapeBorder && b is MaterialShapeBorder) {
      if (a.shape == b.shape) {
        return MaterialShapeBorder(shape: b.shape, side: side, squash: squash);
      }

      return _MorphingShapeBorder(
        start: a.shape,
        end: b.shape,
        progress: t,
        side: side,
        squash: squash,
      );
    }

    // One or both sides came from an earlier lerp, as happens when an implicit
    // animation is interrupted. Such a border can only be interpolated along
    // the morph it came from, so both sides must sit on that same morph.
    final morphing = (a is _MorphingShapeBorder ? a : b) as _MorphingShapeBorder;
    final RoundedPolygon start = morphing.start;
    final RoundedPolygon end = morphing.end;

    final double? from = _progressAlong(a, start, end);
    final double? to = _progressAlong(b, start, end);

    if (from == null || to == null) {
      return null;
    }

    return _MorphingShapeBorder(
      start: start,
      end: end,
      progress: ui.lerpDouble(from, to, t)!,
      side: side,
      squash: squash,
    );
  }

  static double _squashOf(OutlinedBorder border) {
    return switch (border) {
      MaterialShapeBorder(:final double squash) ||
      _MorphingShapeBorder(:final double squash) => squash,
      _ => throw ArgumentError.value(border, 'border', 'Cannot be lerped as a material shape'),
    };
  }

  /// How far along the morph from [start] to [end] [border] sits, or null if it
  /// is not on that morph.
  ///
  /// Shapes are compared by value, so a border rebuilt with an equal but newly
  /// constructed shape still resumes its morph instead of snapping.
  static double? _progressAlong(OutlinedBorder border, RoundedPolygon start, RoundedPolygon end) {
    if (border is _MorphingShapeBorder) {
      if (border.start == start && border.end == end) {
        return border.progress;
      }

      if (border.start == end && border.end == start) {
        return 1.0 - border.progress;
      }

      return null;
    }

    final RoundedPolygon shape = (border as MaterialShapeBorder).shape;

    if (shape == start) {
      return 0;
    }

    if (shape == end) {
      return 1;
    }

    return null;
  }

  @override
  ShapeBorder scale(double t) {
    return MaterialShapeBorder(shape: shape, side: side.scale(t), squash: squash);
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (t == 0) {
      return a;
    }

    if (t == 1.0) {
      return this;
    }

    if (a is OutlinedBorder && _canLerpWith(a)) {
      return _lerp(a, this, t);
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

    if (b is OutlinedBorder && _canLerpWith(b)) {
      return _lerp(this, b, t);
    }

    return super.lerpTo(b, t);
  }

  @override
  MaterialShapeBorder copyWith({RoundedPolygon? shape, BorderSide? side, double? squash}) {
    return MaterialShapeBorder(
      shape: shape ?? this.shape,
      side: side ?? this.side,
      squash: squash ?? this.squash,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _pathFromRect(shape.cubics, squash, rect.deflate(side.strokeInset));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _pathFromRect(shape.cubics, squash, rect.inflate(side.strokeOutset));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    _paintSide(canvas, rect, side, shape.cubics, squash);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is MaterialShapeBorder &&
        other.shape == shape &&
        other.side == side &&
        other.squash == squash;
  }

  @override
  int get hashCode => Object.hash(shape, side, squash);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'MaterialShapeBorder')}'
        '(shape: $shape, side: $side, squash: $squash)';
  }
}

/// A border partway along the [Morph] between two [MaterialShapeBorder]s.
///
/// This is what lerping two [MaterialShapeBorder]s with different shapes
/// returns. It keeps the morph it sits on, which is what lets an interrupted
/// transition resume along the same morph instead of snapping.
class _MorphingShapeBorder extends OutlinedBorder {
  _MorphingShapeBorder({
    required this.start,
    required this.end,
    required this.progress,
    required this.squash,
    super.side,
  });

  /// The shape the morph starts at, where [progress] is zero.
  final RoundedPolygon start;

  /// The shape the morph ends at, where [progress] is one.
  final RoundedPolygon end;

  /// How far along the morph from [start] to [end] this border sits.
  final double progress;

  /// See [MaterialShapeBorder.squash].
  final double squash;

  late final List<CubicBezier> _cubics = MaterialShapeBorder._morphBetween(
    start,
    end,
  ).toCubics(progress);

  @override
  ShapeBorder scale(double t) {
    return copyWith(side: side.scale(t));
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (t == 0) {
      return a;
    }

    if (t == 1.0) {
      return this;
    }

    if (a is OutlinedBorder && MaterialShapeBorder._canLerpWith(a)) {
      return MaterialShapeBorder._lerp(a, this, t);
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

    if (b is OutlinedBorder && MaterialShapeBorder._canLerpWith(b)) {
      return MaterialShapeBorder._lerp(this, b, t);
    }

    return super.lerpTo(b, t);
  }

  @override
  _MorphingShapeBorder copyWith({BorderSide? side, double? squash}) {
    return _MorphingShapeBorder(
      start: start,
      end: end,
      progress: progress,
      side: side ?? this.side,
      squash: squash ?? this.squash,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _pathFromRect(_cubics, squash, rect.deflate(side.strokeInset));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _pathFromRect(_cubics, squash, rect.inflate(side.strokeOutset));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    _paintSide(canvas, rect, side, _cubics, squash);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is _MorphingShapeBorder &&
        other.start == start &&
        other.end == end &&
        other.progress == progress &&
        other.side == side &&
        other.squash == squash;
  }

  @override
  int get hashCode => Object.hash(start, end, progress, side, squash);

  @override
  String toString() {
    return 'MaterialShapeBorder(side: $side, squash: $squash, '
        '${(progress * 100).toStringAsFixed(1)}% of the way from $start to $end)';
  }
}

/// Returns the path of [cubics], which fit in the unit square, fitted to
/// [rect] as described by [MaterialShapeBorder.squash].
Path _pathFromRect(List<CubicBezier> cubics, double squash, Rect rect) {
  // The rect can collapse to a negative size when it is deflated by a stroke
  // width larger than the rect itself. Scaling by the resulting negative
  // dimensions would reflect the shape across the axes, so return an empty
  // path instead.
  if (rect.isEmpty || rect.width <= 0 || rect.height <= 0) {
    return Path();
  }

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
    ..translateByDouble(actualRect.left, actualRect.top, 0, 1)
    ..scaleByDouble(scale.dx, scale.dy, 1, 1);

  return pathFromCubics(cubics).transform(matrix.storage);
}

/// Strokes [side] along the path of [cubics] fitted to [rect].
void _paintSide(
  Canvas canvas,
  Rect rect,
  BorderSide side,
  List<CubicBezier> cubics,
  double squash,
) {
  switch (side.style) {
    case BorderStyle.none:
      return;

    case BorderStyle.solid:
      final Rect adjustedRect = rect.inflate(side.strokeOffset / 2);
      final Path path = _pathFromRect(cubics, squash, adjustedRect);
      canvas.drawPath(path, side.toPaint());
  }
}

/// The pair of shapes a cached [Morph] was built from.
///
/// Keys compare by value. This is cheap because [RoundedPolygon.hashCode] is
/// computed once and cached, and its `==` short-circuits on identical instances.
@immutable
class _MorphCacheKey {
  const _MorphCacheKey(this.start, this.end);

  final RoundedPolygon start;

  final RoundedPolygon end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  bool operator ==(Object other) {
    return other is _MorphCacheKey && other.start == start && other.end == end;
  }
}

/// Cache of objects of limited size that uses the first in first out eviction
/// strategy (a.k.a least recently inserted).
///
/// The key that was inserted before all other keys is evicted first, i.e. the
/// one inserted least recently.
class _FifoCache<K, V> {
  _FifoCache(this._maximumSize) : assert(_maximumSize > 0);

  /// In Dart the map literal uses a linked hash-map implementation, whose keys
  /// are stored such that [Map.keys] returns them in the order they were
  /// inserted.
  final Map<K, V> _cache = <K, V>{};

  /// Maximum number of entries to store in the cache.
  ///
  /// Once this many entries have been cached, the entry inserted least recently
  /// is evicted when adding a new entry.
  final int _maximumSize;

  /// Returns the previously cached value for the given key, if available;
  /// if not, calls the given callback to obtain it first.
  V putIfAbsent(K key, V Function() loader) {
    final V? result = _cache[key];

    if (result != null) {
      return result;
    }

    if (_cache.length == _maximumSize) {
      _cache.remove(_cache.keys.first);
    }

    return _cache[key] = loader();
  }
}
