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
  /// Creates a [MaterialShapeBorder].
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

  // The number 5 was chosen without any real science or research behind it. It
  // just seemed like a number that's not too big (a handful of morphs fits in
  // memory comfortably) and not too small (few screens animate between more
  // than 5 distinct pairs of shapes at once).
  static const int _morphCacheSize = 5;

  /// Caches the mapping between pairs of shapes to speed up [lerpFrom] and
  /// [lerpTo].
  static final _morphCache = _FifoCache<_MorphCacheKey, Morph>(_morphCacheSize);

  /// Returns the [Morph] between [start] and [end], reusing a previously
  /// computed one when it is still cached.
  ///
  /// A [Morph] matches the curves of its two shapes at construction time, which
  /// is far more expensive than evaluating it at a progress value, and the
  /// mapping it produces depends only on those two shapes. A transition asks
  /// for the same pair on every frame, so computing the mapping once and
  /// keeping it is what makes lerping affordable.
  static Morph _morphBetween(RoundedPolygon start, RoundedPolygon end) {
    return _morphCache.putIfAbsent(_MorphCacheKey(start, end), () => Morph(start, end));
  }

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
        cubics: _morphBetween(aShape, shape).asCubics(t),
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
        cubics: _morphBetween(shape, bShape).asCubics(t),
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

    return pathFromCubics(_cubics).transform(matrix.storage);
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
        listEquals(other._cubics, _cubics) &&
        other.side == side &&
        other.squash == squash;
  }

  @override
  int get hashCode => Object.hash(shape, Object.hashAll(_cubics), side, squash);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'MaterialShapeBorder')}'
        '(side: $side, squash: $squash)';
  }
}

/// The pair of shapes a cached [Morph] was built from.
///
/// Keys compare by identity rather than by value. [RoundedPolygon.hashCode]
/// walks every coordinate of every feature, which would cost a sizeable
/// fraction of the work the cache saves, on every lookup rather than only on a
/// miss. A pair that misses is simply rebuilt, so identity only ever costs a
/// cache hit.
@immutable
class _MorphCacheKey {
  const _MorphCacheKey(this.start, this.end);

  final RoundedPolygon start;

  final RoundedPolygon end;

  @override
  int get hashCode => Object.hash(identityHashCode(start), identityHashCode(end));

  @override
  bool operator ==(Object other) {
    return other is _MorphCacheKey && identical(other.start, start) && identical(other.end, end);
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
