// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

/// A picture and the finite region in which its pixels are defined.
class FilterImage {
  /// Creates a filter intermediate. Its context owns the picture.
  const FilterImage(this.picture, this.region, {this.replayCost = 1, this.solidColor});

  /// Commands representing this intermediate.
  final Picture picture;

  /// The default primitive domain. Recorded intermediate pixels outside it are
  /// transparent; original SourceGraphic/SourceAlpha retain pixels for offset.
  final Rect region;

  /// Number of leaf pictures replayed by this intermediate, including reuse.
  final int replayCost;

  /// Infinite solid paint input, evaluated against the consuming canvas clip.
  ///
  /// Keeping this declarative avoids an unbounded drawColor picture's culling
  /// behavior on CanvasKit. Ordinary clipped intermediates leave this null.
  final Color? solidColor;
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
    Rect? sourceBounds,
    int sourceReplayCost = 1,
    FilterRasterBudget? rasterBudget,
  }) : _sourceBounds = sourceBounds ?? objectBounds,
       _rasterBudget = rasterBudget ?? FilterRasterBudget() {
    try {
      if (!rasterScale.isFinite || rasterScale <= 0) {
        throw ArgumentError.value(rasterScale, 'rasterScale', 'must be finite and positive');
      }
      // Keep the source picture intact; like browsers, offset can bring pixels
      // from outside the filter region into its clipped output.
      sourceGraphic = FilterImage(source, region, replayCost: sourceReplayCost);
    } catch (_) {
      source.dispose();
      rethrow;
    }
    _owned.add(source);
    previous = sourceGraphic;
  }

  /// Maximum expanded picture replays before materializing an intermediate.
  ///
  /// Native blend layers are expensive even when each leaf is a small picture.
  /// This also bounds the work required to materialize a branching graph.
  static const int maxPictureReplays = 16;

  /// The filter and its presentation attributes.
  final VectorFilter definition;

  /// The unfiltered geometry bounds, excluding stroke.
  final Rect objectBounds;

  /// The SVG viewport in the filter's coordinate system.
  final Size viewport;

  /// Samples per local SVG unit for operations requiring texture access.
  final double rasterScale;

  /// Whether executing this filter created intermediate raster images.
  bool get requiresRasterResolution => _requiresRasterResolution;
  bool _requiresRasterResolution = false;

  final FilterRasterBudget _rasterBudget;
  final Rect _sourceBounds;
  final Map<Canvas, int> _recordingCosts = <Canvas, int>{};
  bool _disposed = false;

  /// The original source graphic.
  late final FilterImage sourceGraphic;

  /// The previous primitive's result (initially the source graphic).
  late FilterImage previous;
  final Map<String, FilterImage> _results = <String, FilterImage>{};
  final List<Picture> _owned = <Picture>[];
  final List<Image> _images = <Image>[];
  final Map<(FilterImage, Rect, int, int), Image> _samples =
      <(FilterImage, Rect, int, int), Image>{};
  FilterImage? _sourceAlpha;
  FilterImage? _fillPaint;
  FilterImage? _strokePaint;

  /// Validates a sampling domain and computes its bounded texture dimensions.
  Size sampleSize(Rect domain, {double? scale, Size? pixelSize}) {
    if (!domain.isFinite || domain.isEmpty) {
      throw ArgumentError.value(domain, 'domain', 'must be finite and nonempty');
    }
    final double effectiveScale = scale ?? rasterScale;
    if (!effectiveScale.isFinite || effectiveScale <= 0) {
      throw ArgumentError.value(effectiveScale, 'scale', 'must be finite and positive');
    }
    if (pixelSize != null &&
        (!pixelSize.width.isFinite ||
            !pixelSize.height.isFinite ||
            pixelSize.width <= 0 ||
            pixelSize.height <= 0)) {
      throw ArgumentError.value(pixelSize, 'pixelSize', 'must be finite and positive');
    }
    double scaledWidth = pixelSize == null
        ? domain.width * effectiveScale
        : domain.width / pixelSize.width;
    double scaledHeight = pixelSize == null
        ? domain.height * effectiveScale
        : domain.height / pixelSize.height;
    if (pixelSize != null) {
      // A rectangle formed from N grid steps can divide back to N + epsilon.
      // Ceil would then add a pixel and move every sample center. Snap only
      // round-off at an integer (less than one ten-billionth of a pixel).
      double snap(double value) {
        if (!value.isFinite) {
          return value;
        }
        final double rounded = value.roundToDouble();
        return (value - rounded).abs() <= 1e-10 ? rounded : value;
      }

      scaledWidth = snap(scaledWidth);
      scaledHeight = snap(scaledHeight);
    }
    // Bound allocation before converting untrusted SVG dimensions to integers.
    if (!scaledWidth.isFinite ||
        !scaledHeight.isFinite ||
        scaledWidth > 8192 ||
        scaledHeight > 8192) {
      throw StateError('SVG filter texture exceeds 8192 pixels per dimension');
    }
    final int width = scaledWidth < 1 ? 1 : scaledWidth.ceil();
    final int height = scaledHeight < 1 ? 1 : scaledHeight.ceil();
    return Size(width.toDouble(), height.toDouble());
  }

  /// Rasterizes a finite input domain, retaining ownership of the image handle.
  Image sample(FilterImage input, Rect domain, {double? scale, Size? pixelSize}) {
    _checkActive();
    _requiresRasterResolution = true;
    final Size size = sampleSize(domain, scale: scale, pixelSize: pixelSize);
    final int width = size.width.toInt();
    final int height = size.height.toInt();
    final key = (input, domain, width, height);
    final Image? cached = _samples[key];
    if (cached != null) {
      return cached;
    }
    _rasterBudget.reserve(width * height);
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder)
      ..scale(width / domain.width, height / domain.height)
      ..translate(-domain.left, -domain.top)
      ..clipRect(domain, doAntiAlias: false);
    _draw(canvas, input);
    final Picture picture = recorder.endRecording();
    try {
      final Image image = picture.toImageSync(width, height);
      _images.add(image);
      _samples[key] = image;
      return image;
    } finally {
      picture.dispose();
    }
  }

  /// Aligns output bounds to the input grid without moving its sample centers.
  static Rect alignToGrid(Rect bounds, Rect domain, Size step) => Rect.fromLTRB(
    domain.left + ((bounds.left - domain.left) / step.width).floor() * step.width,
    domain.top + ((bounds.top - domain.top) / step.height).floor() * step.height,
    domain.left + ((bounds.right - domain.left) / step.width).ceil() * step.width,
    domain.top + ((bounds.bottom - domain.top) / step.height).ceil() * step.height,
  );

  /// Materializes an effect, preserving a reusable sample at this resolution.
  FilterImage raster(FilterImage input, Rect bounds, {Size? pixelSize}) {
    final Image image = sample(input, bounds, pixelSize: pixelSize);
    final FilterImage result = record(bounds, (Canvas canvas) {
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        bounds,
        Paint()..filterQuality = FilterQuality.low,
      );
    });
    _samples[(result, bounds, image.width, image.height)] = image;
    return result;
  }

  /// Whether this primitive computes RGB channels in linear light.
  bool linearColor(VectorFilter primitive) {
    final String value =
        primitive.attributes['color-interpolation-filters'] ??
        definition.attributes['color-interpolation-filters'] ??
        'linearRGB';
    if (value == 'sRGB' || value == 'auto') {
      return false;
    }
    if (value != 'linearRGB') {
      throw FormatException('Invalid color-interpolation-filters: $value');
    }
    return true;
  }

  /// Converts sRGB input to the operation's space and its output back to sRGB.
  ImageFilter inColorSpace(VectorFilter primitive, ImageFilter operation) {
    if (!linearColor(primitive)) {
      return operation;
    }
    return ImageFilter.compose(
      outer: const ColorFilter.linearToSrgbGamma(),
      inner: ImageFilter.compose(outer: operation, inner: const ColorFilter.srgbToLinearGamma()),
    );
  }

  /// Records compositing in the chosen working color space.
  FilterImage recordColor(VectorFilter primitive, Rect bounds, void Function(Canvas, bool) paint) {
    final bool linear = linearColor(primitive);
    return record(bounds, (Canvas canvas) {
      if (linear) {
        canvas.saveLayer(bounds, Paint()..colorFilter = const ColorFilter.linearToSrgbGamma());
      }
      paint(canvas, linear);
      if (linear) {
        canvas.restore();
      }
    });
  }

  /// Draws a single sRGB input into a compositing layer's working color space.
  void drawInput(
    Canvas canvas,
    FilterImage input,
    bool linear, {
    BlendMode mode = BlendMode.srcOver,
    Rect? domain,
  }) {
    final paint = Paint()..blendMode = mode;
    if (linear) {
      paint.colorFilter = const ColorFilter.srgbToLinearGamma();
    }
    canvas.saveLayer(domain ?? region, paint);
    draw(canvas, input);
    canvas.restore();
  }

  /// Draws an intermediate while accounting for repeated picture playback.
  void draw(Canvas canvas, FilterImage input) {
    _recordingCosts[canvas] = (_recordingCosts[canvas] ?? 0) + input.replayCost;
    _draw(canvas, input);
  }

  void _draw(Canvas canvas, FilterImage input) {
    final Color? color = input.solidColor;
    if (color != null) {
      canvas.drawPaint(Paint()..color = color);
    } else {
      canvas.drawPicture(input.picture);
    }
  }

  /// Extends original inputs to include the source pixels needed by a kernel.
  /// Intermediate images keep the clipping established by their primitive.
  Rect inputDomain(FilterImage input, Rect requested) {
    if (identical(input, _fillPaint) || identical(input, _strokePaint)) {
      // Solid paints have infinite extent, including beyond the filter region.
      return input.region.expandToInclude(requested);
    }
    if (!isSource(input)) {
      return input.region;
    }
    final Rect extra = requested.intersect(_sourceBounds);
    return extra.isEmpty ? input.region : input.region.expandToInclude(extra);
  }

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
        draw(canvas, sourceGraphic);
        canvas.restore();
      }, clip: false);
    }
    if (name == 'FillPaint') {
      return _fillPaint ??= _solidPaintInput(name, 'vector-fill-paint');
    }
    if (name == 'StrokePaint') {
      return _strokePaint ??= _solidPaintInput(name, 'vector-stroke-paint');
    }
    if (name == 'BackgroundImage' || name == 'BackgroundAlpha') {
      // The active PictureRecorder cannot expose the already painted backdrop.
      throw UnsupportedError('SVG filter input $name is not implemented');
    }
    // SVG treats unknown and forward result references as omitted inputs.
    return _results[name] ?? previous;
  }

  FilterImage _solidPaintInput(String name, String key) {
    final String? value = definition.attributes[key];
    if (value == null || value == 'unsupported') {
      throw UnsupportedError('SVG filter input $name requires a solid paint');
    }
    if (value == 'none') {
      return record(region, (Canvas canvas) {}, clip: false);
    }
    if (!RegExp(r'^\d{1,10}$').hasMatch(value)) {
      throw FormatException('Invalid SVG filter $name color');
    }
    final int encoded = int.parse(value);
    if (encoded > 0xffffffff) {
      throw FormatException('Invalid SVG filter $name color');
    }
    final FilterImage input = record(region, (Canvas canvas) {}, clip: false);
    return FilterImage(input.picture, input.region, solidColor: Color(encoded));
  }

  /// Whether [image] is an original input, before primitive-region clipping.
  bool isSource(FilterImage image) =>
      identical(image, sourceGraphic) ||
      identical(image, _sourceAlpha) ||
      identical(image, _fillPaint) ||
      identical(image, _strokePaint);

  /// Records an intermediate and tracks its lifetime.
  ///
  /// Only original inputs may disable [clip]: pixels outside the filter region
  /// can be moved into it by a later primitive, including for SourceAlpha.
  FilterImage record(Rect bounds, void Function(Canvas) paint, {bool clip = true}) {
    _checkActive();
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    _recordingCosts[canvas] = 0;
    if (clip) {
      canvas.clipRect(bounds, doAntiAlias: false);
    }
    try {
      if (!bounds.isEmpty) {
        paint(canvas);
      }
    } catch (_) {
      _recordingCosts.remove(canvas);
      recorder.endRecording().dispose();
      rethrow;
    }
    final Picture picture = recorder.endRecording();
    _owned.add(picture);
    final int cost = _recordingCosts.remove(canvas)!;
    final result = FilterImage(picture, bounds, replayCost: cost == 0 ? 1 : cost);
    // Bound the expanded graph rather than just its number of SVG primitives.
    // Linear vector chains retain their resolution-independent pictures.
    return clip && !bounds.isEmpty && cost > maxPictureReplays ? raster(result, bounds) : result;
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
    // Nonpositive dimensions disable this primitive, including generators.
    return Rect.fromLTWH(x, y, math.max(0, w), math.max(0, h));
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
    for (final Image image in _images) {
      image.dispose();
    }
    _images.clear();
    _samples.clear();
  }

  void _checkActive() {
    if (_disposed) {
      throw StateError('Filter context has been disposed');
    }
  }
}
