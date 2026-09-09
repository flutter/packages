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
      _lerpStart = null,
      _lerpEnd = null,
      _lerpProgress = null,
      assert(squash >= 0 && squash <= 1, 'squash has to be in range [0, 1]');

  const MaterialShapeBorder._fromCubics({
    required this._cubics,
    required RoundedPolygon this._lerpStart,
    required RoundedPolygon this._lerpEnd,
    required double this._lerpProgress,
    super.side,
    this.squash = 0,
  }) : shape = null,
       assert(squash >= 0 && squash <= 1, 'squash has to be in range [0, 1]');

  /// The shape this border represents.
  ///
  /// This value is `null` if the border is the result of a lerp, which stores
  /// its morph instead.
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

  // The morph this border was lerped from, and how far along it the geometry
  // sits. All three are null when [shape] is set and non-null otherwise, which
  // is what lets an interrupted transition resume along the same morph.
  final RoundedPolygon? _lerpStart;
  final RoundedPolygon? _lerpEnd;
  final double? _lerpProgress;

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

  /// Interpolates from [a] to [b] at [t], or returns `null` if the two borders
  /// have no morph in common.
  ///
  /// Both [lerpFrom] and [lerpTo] delegate here so that they always give the
  /// same answer. [ShapeBorder.lerp] tries them in both directions, so a pair
  /// accepted by one but declined by another would animate backwards or never
  /// reach the snapping fallback.
  static MaterialShapeBorder? _lerp(MaterialShapeBorder a, MaterialShapeBorder b, double t) {
    final RoundedPolygon? aShape = a.shape;
    final RoundedPolygon? bShape = b.shape;

    final RoundedPolygon start;
    final RoundedPolygon end;
    final double progress;

    if (aShape != null && bShape != null) {
      start = aShape;
      end = bShape;
      progress = t;
    } else {
      // One or both sides came from an earlier lerp, as happens when an
      // implicit animation is interrupted. Such a border can only be
      // interpolated along the morph it came from, so both sides must sit on
      // that same morph.
      final lerped = aShape == null ? a : b;
      start = lerped._lerpStart!;
      end = lerped._lerpEnd!;

      final double? from = a._progressAlong(start, end);
      final double? to = b._progressAlong(start, end);

      if (from == null || to == null) {
        return null;
      }

      progress = ui.lerpDouble(from, to, t)!;
    }

    return MaterialShapeBorder._fromCubics(
      cubics: _morphBetween(start, end).toCubics(progress),
      lerpStart: start,
      lerpEnd: end,
      lerpProgress: progress,
      side: BorderSide.lerp(a.side, b.side, t),
      squash: ui.lerpDouble(a.squash, b.squash, t)!,
    );
  }

  /// How far along the morph from [start] to [end] this border sits, or null if
  /// it is not on that morph.
  ///
  /// Shapes are compared by value, so a border rebuilt with an equal but newly
  /// constructed shape still resumes its morph instead of snapping.
  /// [_MorphCacheKey] makes the opposite trade, since hashing a polygon is
  /// expensive.
  double? _progressAlong(RoundedPolygon start, RoundedPolygon end) {
    final RoundedPolygon? shape = this.shape;

    if (shape == null) {
      return _lerpStart == start && _lerpEnd == end ? _lerpProgress : null;
    }

    if (shape == start) {
      return 0;
    }

    if (shape == end) {
      return 1;
    }

    return null;
  }

  /// Returns a copy of this lerp result with a different [side] or [squash].
  ///
  /// The geometry and the morph carry over unchanged, so the copy can still be
  /// lerped. Only valid when [shape] is null.
  MaterialShapeBorder _lerpResultWith({BorderSide? side, double? squash}) {
    assert(shape == null);

    return MaterialShapeBorder._fromCubics(
      cubics: _cubics,
      lerpStart: _lerpStart!,
      lerpEnd: _lerpEnd!,
      lerpProgress: _lerpProgress!,
      side: side ?? this.side,
      squash: squash ?? this.squash,
    );
  }

  @override
  ShapeBorder scale(double t) {
    final RoundedPolygon? shape = this.shape;

    if (shape != null) {
      return MaterialShapeBorder(shape: shape, side: side.scale(t), squash: squash);
    }

    return _lerpResultWith(side: side.scale(t));
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

    if (b is MaterialShapeBorder) {
      return _lerp(this, b, t);
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

    return _lerpResultWith(side: side, squash: squash);
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
      ..translateByDouble(actualRect.left, actualRect.top, 0, 1)
      ..scaleByDouble(scale.dx, scale.dy, 1, 1);

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
        other._lerpStart == _lerpStart &&
        other._lerpEnd == _lerpEnd &&
        other._lerpProgress == _lerpProgress &&
        other.side == side &&
        other.squash == squash;
  }

  @override
  int get hashCode => Object.hash(
    shape,
    Object.hashAll(_cubics),
    _lerpStart,
    _lerpEnd,
    _lerpProgress,
    side,
    squash,
  );

  @override
  String toString() {
    return '${objectRuntimeType(this, 'MaterialShapeBorder')}'
        '(side: $side, squash: $squash)';
  }
}

/// The pair of shapes a cached [Morph] was built from.
///
/// Keys compare by identity rather than by value, because
/// [RoundedPolygon.hashCode] walks every coordinate of every feature and would
/// cost a sizeable fraction of what the cache saves. A pair that misses is
/// simply rebuilt.
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
