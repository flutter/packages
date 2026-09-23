// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

/// A picture and the finite region in which its pixels are defined.
class FilterImage {
  /// Creates a filter intermediate. Its context owns the picture.
  const FilterImage(this.picture, this.region);

  /// Commands representing this intermediate.
  final Picture picture;

  /// The default primitive domain. Recorded intermediate pixels outside it are
  /// transparent; original SourceGraphic/SourceAlpha retain pixels for offset.
  final Rect region;
}

/// A cumulative allocation budget shared by all filter invocations in a decode.
class FilterRasterBudget {
  /// Creates a budget, in pixels, for retained intermediate textures.
  FilterRasterBudget({this.maxPixels = 16 * 1024 * 1024});

  /// Maximum number of intermediate pixels across the decoded picture.
  final int maxPixels;
  int _used = 0;

  /// Reserves pixels before allocation, including nested filter invocations.
  void reserve(int pixels) {
    if (pixels < 0 || _used + pixels > maxPixels) {
      throw StateError('SVG filter exceeds the $maxPixels pixel intermediate budget');
    }
    _used += pixels;
  }
}

/// Rendering state shared by the primitives of one filter invocation.
class FilterContext {
  /// Creates an isolated context; ownership of [source] transfers to it.
  FilterContext(
    this.definition,
    Picture source,
    this.objectBounds,
    this.viewport, {
    this.rasterScale = 1,
  }) {
    try {
      if (!rasterScale.isFinite || rasterScale <= 0) {
        throw ArgumentError.value(rasterScale, 'rasterScale', 'must be finite and positive');
      }
      // Keep the source picture intact; like browsers, offset can bring pixels
      // from outside the filter region into its clipped output.
      sourceGraphic = FilterImage(source, region);
    } catch (_) {
      source.dispose();
      rethrow;
    }
    _owned.add(source);
    previous = sourceGraphic;
  }

  /// The filter and its presentation attributes.
  final VectorFilter definition;

  /// The unfiltered geometry bounds, excluding stroke.
  final Rect objectBounds;

  /// The SVG viewport in the filter's coordinate system.
  final Size viewport;

  /// Samples per local SVG unit for operations requiring texture access.
  final double rasterScale;

  /// Whether executing this filter created intermediate raster images.
  bool get requiresRasterResolution => false;

  bool _disposed = false;

  /// The original source graphic.
  late final FilterImage sourceGraphic;

  /// The previous primitive's result (initially the source graphic).
  late FilterImage previous;
  final Map<String, FilterImage> _results = <String, FilterImage>{};
  final List<Picture> _owned = <Picture>[];
  FilterImage? _sourceAlpha;

  /// Whether primitive lengths are fractions of the geometry bounds.
  bool get usesObjectUnits => _units('primitiveUnits', 'userSpaceOnUse') == 'objectBoundingBox';

  String _units(String name, String fallback) {
    final String value = definition.attributes[name] ?? fallback;
    if (value != 'userSpaceOnUse' && value != 'objectBoundingBox') {
      throw FormatException('Invalid $name: $value');
    }
    return value;
  }

  /// The finite output region of the filter.
  late final Rect region = _region();

  Rect _region() {
    final objectUnits = _units('filterUnits', 'objectBoundingBox') == 'objectBoundingBox';
    final Map<String, String> a = definition.attributes;
    final double x = length(
      a['x'] ?? '-10%',
      horizontal: true,
      objectUnits: objectUnits,
      position: true,
    );
    final double y = length(
      a['y'] ?? '-10%',
      horizontal: false,
      objectUnits: objectUnits,
      position: true,
    );
    final double w = length(a['width'] ?? '120%', horizontal: true, objectUnits: objectUnits);
    final double h = length(a['height'] ?? '120%', horizontal: false, objectUnits: objectUnits);
    if (w < 0 || h < 0) {
      throw const FormatException('Filter dimensions must not be negative');
    }
    return Rect.fromLTWH(x, y, w, h);
  }

  /// Resolves a finite SVG length in the chosen coordinate system.
  double length(
    String value, {
    required bool horizontal,
    bool? objectUnits,
    bool position = false,
  }) {
    value = value.trim();
    final bool relative = objectUnits ?? usesObjectUnits;
    final bool percent = value.endsWith('%');
    double result = parseSvgLength(value, percentageRef: 1);
    if (relative) {
      result *= horizontal ? objectBounds.width : objectBounds.height;
      if (position) {
        result += horizontal ? objectBounds.left : objectBounds.top;
      }
    } else if (percent) {
      result *= horizontal ? viewport.width : viewport.height;
    }
    return result;
  }

  /// Converts a primitive's numeric parameter to user-space distance.
  double primitiveNumber(String value, {required bool horizontal}) {
    final double result = number(value);
    return usesObjectUnits
        ? result * (horizontal ? objectBounds.width : objectBounds.height)
        : result;
  }

  /// Reads a finite number, rejecting NaN and infinity in SVG input.
  static double number(String value) {
    final double? result = double.tryParse(value.trim());
    if (result == null || !result.isFinite) {
      throw FormatException('Invalid filter number: $value');
    }
    return result;
  }

  /// Reads comma/whitespace-separated SVG numbers.
  static List<double> numbers(String value) => value.trim().isEmpty
      ? <double>[]
      : value.trim().split(RegExp(r'[\s,]+')).map(number).toList();

  /// Resolves an input at the point of use, before publishing the next result.
  FilterImage input(String? name) {
    if (name == null || name.isEmpty) {
      return previous;
    }
    if (name == 'SourceGraphic') {
      return sourceGraphic;
    }
    if (name == 'SourceAlpha') {
      return _sourceAlpha ??= record(region, (Canvas canvas) {
        canvas.saveLayer(
          null,
          Paint()
            ..colorFilter = const ColorFilter.matrix(<double>[
              0,
              0,
              0,
              0,
              0,
              0,
              0,
              0,
              0,
              0,
              0,
              0,
              0,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ]),
        );
        canvas.drawPicture(sourceGraphic.picture);
        canvas.restore();
      }, clip: false);
    }
    if (<String>{'BackgroundImage', 'BackgroundAlpha', 'FillPaint', 'StrokePaint'}.contains(name)) {
      throw UnsupportedError('SVG filter input $name is not implemented');
    }
    // SVG treats unknown and forward result references as omitted inputs.
    return _results[name] ?? previous;
  }

  /// Whether [image] is an original input, before primitive-region clipping.
  bool isSource(FilterImage image) =>
      identical(image, sourceGraphic) || identical(image, _sourceAlpha);

  /// Records an intermediate and tracks its lifetime.
  ///
  /// Only original inputs may disable [clip]: pixels outside the filter region
  /// can be moved into it by a later primitive, including for SourceAlpha.
  FilterImage record(Rect bounds, void Function(Canvas) paint, {bool clip = true}) {
    _checkActive();
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    if (clip) {
      canvas.clipRect(bounds, doAntiAlias: false);
    }
    try {
      if (!bounds.isEmpty) {
        paint(canvas);
      }
    } catch (_) {
      recorder.endRecording().dispose();
      rethrow;
    }
    final Picture picture = recorder.endRecording();
    _owned.add(picture);
    return FilterImage(picture, bounds);
  }

  /// The subregion limits each primitive before it is used by another one.
  Rect subregion(VectorFilter primitive, Rect defaultRegion) =>
      primitiveRegion(primitive, defaultRegion).intersect(region);

  /// The requested primitive rectangle before clipping to the filter region.
  Rect primitiveRegion(VectorFilter primitive, Rect defaultRegion) {
    final Map<String, String> a = primitive.attributes;
    final double x = a['x'] == null
        ? defaultRegion.left
        : length(a['x']!, horizontal: true, position: true);
    final double y = a['y'] == null
        ? defaultRegion.top
        : length(a['y']!, horizontal: false, position: true);
    final double w = a['width'] == null
        ? defaultRegion.width
        : length(a['width']!, horizontal: true);
    final double h = a['height'] == null
        ? defaultRegion.height
        : length(a['height']!, horizontal: false);
    if (w < 0 || h < 0) {
      throw const FormatException('Primitive dimensions must not be negative');
    }
    return Rect.fromLTWH(x, y, w, h);
  }

  /// Publishes a primitive's output for subsequent references.
  void publish(VectorFilter primitive, FilterImage image) {
    previous = image;
    final String? name = primitive.attributes['result'];
    if (name != null && name.isNotEmpty) {
      _results[name] = image;
    }
  }

  /// Releases intermediate handles after the final draw has been recorded.
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    for (final Picture picture in _owned) {
      picture.dispose();
    }
    _owned.clear();
  }

  void _checkActive() {
    if (_disposed) {
      throw StateError('Filter context has been disposed');
    }
  }
}
