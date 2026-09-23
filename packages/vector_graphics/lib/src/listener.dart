// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart'
    show
        ImageInfo,
        ImageStreamCompleter,
        ImageStreamListener,
        OneFrameImageStreamCompleter,
        imageCache;
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'filters/filter_context.dart';
import 'filters/filter_executor.dart';
import 'loader.dart';
import 'vector_image.dart';

const VectorGraphicsCodec _codec = VectorGraphicsCodec();

Canvas _recordingCanvas(PictureRecorder recorder) {
  final canvas = Canvas(recorder);
  if (kIsWeb) {
    // CanvasKit can discard a single-draw picture when replayed with a
    // transform. An explicit clip to the existing recording extent prevents
    // that optimization without clipping SVG overflow to the viewport.
    canvas.clipRect(Rect.largest);
  }
  return canvas;
}

/// The decoded result of a vector graphics asset.
class PictureInfo {
  /// Construct a new [PictureInfo].
  PictureInfo._(
    this.picture,
    this.size, {
    this.hasFilters = false,
    this.requiresRasterResolution = false,
    this.filterRasterScale = 1,
  });

  /// A picture generated from a vector graphics image.
  final Picture picture;

  /// Whether this picture or an embedded vector contains SVG filter effects.
  final bool hasFilters;

  /// Whether this picture contains filter textures tied to decode resolution.
  final bool requiresRasterResolution;

  /// Samples per SVG unit requested for this decode, before local transforms.
  final double filterRasterScale;

  /// The target size of the picture.
  ///
  /// This information should be used to scale and position
  /// the picture based on the available space and alignment.
  final Size size;
}

/// Internal testing only.
@visibleForTesting
Locale? get debugLastLocale => _debugLastLocale;
Locale? _debugLastLocale;

/// Internal testing only.
@visibleForTesting
TextDirection? get debugLastTextDirection => _debugLastTextDirection;
TextDirection? _debugLastTextDirection;

/// Internal testing only.
@visibleForTesting
Iterable<Future<void>> get debugGetPendingDecodeTasks =>
    _pendingDecodes.values.map((Completer<void> e) => e.future);
final Map<Object, Completer<void>> _pendingDecodes = <Object, Completer<void>>{};

/// Decode a vector graphics binary asset into a [Picture].
///
/// Throws a [StateError] if the data is invalid.
Future<PictureInfo> decodeVectorGraphics(
  ByteData data, {
  required Locale? locale,
  required TextDirection? textDirection,
  required bool clipViewbox,
  required BytesLoader loader,
  double filterRasterScale = 1,
  VectorGraphicsErrorListener? onError,
}) => _decodeVectorGraphics(
  data,
  locale: locale,
  textDirection: textDirection,
  clipViewbox: clipViewbox,
  loader: loader,
  filterRasterScale: filterRasterScale,
  onError: onError,
  budget: _DecodeBudget(),
  imageDepth: 0,
);

Future<PictureInfo> _decodeVectorGraphics(
  ByteData data, {
  required Locale? locale,
  required TextDirection? textDirection,
  required bool clipViewbox,
  required BytesLoader loader,
  required double filterRasterScale,
  required _DecodeBudget budget,
  required int imageDepth,
  VectorGraphicsErrorListener? onError,
}) {
  // Concurrent resolutions of one loader are independent decode tasks.
  final pendingKey = Object();
  try {
    if (imageDepth > 16) {
      throw StateError('Nested vector images exceed the depth limit of 16');
    }
    // We might be in a test that's using a fake async zone. Make sure that any
    // real async work gets scheduled in the root zone so that it will not get
    // blocked by microtasks in the fake async zone, but do not unnecessarily
    // create zones outside of tests.
    var useZone = false;
    assert(() {
      _debugLastTextDirection = textDirection;
      _debugLastLocale = locale;
      useZone =
          Zone.current != Zone.root &&
          Zone.current.scheduleMicrotask != Zone.root.scheduleMicrotask;
      return true;
    }());

    @pragma('vm:prefer-inline')
    Future<PictureInfo> render() {
      final listener =
          FlutterVectorGraphicsListener(
              id: loader.hashCode,
              locale: locale,
              textDirection: textDirection,
              clipViewbox: clipViewbox,
              onError: onError,
              filterRasterScale: filterRasterScale,
            )
            .._budget = budget
            .._imageDepth = imageDepth
            .._limitImageResources =
                imageDepth > 0 || (data.lengthInBytes > 4 && data.getUint8(4) == 2);
      try {
        DecodeResponse response = _codec.decode(data, listener);
        if (response.complete) {
          return SynchronousFuture<PictureInfo>(listener.toPicture());
        }
        assert(() {
          _pendingDecodes.putIfAbsent(pendingKey, Completer<void>.new);
          return true;
        }());
        return listener
            .waitForImageDecode()
            .then((_) {
              response = _codec.decode(data, listener, response: response);
              assert(response.complete);
              assert(() {
                _pendingDecodes.remove(pendingKey)?.complete();
                return true;
              }());
              return listener.toPicture();
            })
            .catchError((Object error, StackTrace stack) {
              assert(() {
                _pendingDecodes.remove(pendingKey)?.complete();
                return true;
              }());
              listener.abort();
              Error.throwWithStackTrace(VectorGraphicsDecodeException._(loader, error), stack);
            });
      } catch (_) {
        listener.abort();
        rethrow;
      }
    }

    Future<PictureInfo> process() => render();

    if (!kDebugMode || !useZone) {
      return process();
    }

    return Zone.current
        .fork(
          specification: ZoneSpecification(
            scheduleMicrotask: (Zone self, ZoneDelegate parent, Zone zone, void Function() f) {
              Zone.root.scheduleMicrotask(f);
            },
            createTimer:
                (Zone self, ZoneDelegate parent, Zone zone, Duration duration, void Function() f) {
                  return Zone.root.createTimer(duration, f);
                },
            createPeriodicTimer:
                (
                  Zone self,
                  ZoneDelegate parent,
                  Zone zone,
                  Duration period,
                  void Function(Timer timer) f,
                ) {
                  return Zone.root.createPeriodicTimer(period, f);
                },
          ),
        )
        .run<Future<PictureInfo>>(process);
  } catch (e) {
    _pendingDecodes.remove(pendingKey)?.complete();
    throw VectorGraphicsDecodeException._(loader, e);
  }
}

/// Pattern configuration to be used when creating ImageShader.
class _PatternConfig {
  /// Constructs a [_PatternConfig].
  _PatternConfig(this._patternId, this._width, this._height, this._transform);

  /// This id will match any path or text element that has a non-null patternId.
  /// This number will also be used to map path and text elements to the
  /// correct [ImageShader].
  final int _patternId;

  /// This is the width of the pattern's viewbox in px.
  /// Values must be > = 1.
  final double _width;

  /// The is the height of the pattern's viewbox in px.
  /// Values must be > = 1.
  final double _height;

  /// This is the transform of the pattern that has been created from the children,
  /// of the original [ResolvedPatternNode].
  final Float64List _transform;
}

/// Pattern state that holds information about how to construct the pattern.
class _PatternState {
  /// The canvas that the element should draw to for a given [PatternConfig].
  Canvas? canvas;

  /// The image shader created by the pattern.
  ImageShader? shader;

  /// The recorder that will capture the newly created canvas.
  PictureRecorder? recorder;

  Canvas? parent;
  _PatternConfig? parentPattern;
  int filterDepth = 0;
}

// A mask must retain both luminance and its original alpha. Recording once lets
// us replay those two factors without rasterizing the vector mask to a fixed grid.
class _MaskFrame {
  _MaskFrame(this.parent, this.filterDepth) {
    canvas = _recordingCanvas(recorder);
  }
  final Canvas parent;
  final int filterDepth;
  final PictureRecorder recorder = PictureRecorder();
  late final Canvas canvas;
}

/// Used by [FlutterVectorGraphicsListener] for testing purposes.
@visibleForTesting
abstract class PictureFactory {
  /// Allows const subclasses.
  const PictureFactory();

  /// Create a picture recorder.
  PictureRecorder createPictureRecorder();

  /// Create a canvas from the recorder.
  Canvas createCanvas(PictureRecorder recorder);
}

class _DefaultPictureFactory implements PictureFactory {
  const _DefaultPictureFactory();

  @override
  Canvas createCanvas(PictureRecorder recorder) => _recordingCanvas(recorder);

  @override
  PictureRecorder createPictureRecorder() => PictureRecorder();
}

/// A listener implementation for the vector graphics codec that converts the
/// format into a [Picture].
class FlutterVectorGraphicsListener extends VectorGraphicsCodecListener {
  /// Create a new [FlutterVectorGraphicsListener].
  ///
  /// The [locale] and [textDirection] are used to configure any text created
  /// by the vector_graphic.
  factory FlutterVectorGraphicsListener({
    int id = 0,
    Locale? locale,
    TextDirection? textDirection,
    bool clipViewbox = true,
    double filterRasterScale = 1,
    @visibleForTesting PictureFactory pictureFactory = const _DefaultPictureFactory(),
    VectorGraphicsErrorListener? onError,
  }) {
    if (!filterRasterScale.isFinite || filterRasterScale <= 0) {
      throw ArgumentError.value(
        filterRasterScale,
        'filterRasterScale',
        'must be finite and positive',
      );
    }
    final PictureRecorder recorder = pictureFactory.createPictureRecorder();
    return FlutterVectorGraphicsListener._(
      id,
      pictureFactory,
      recorder,
      pictureFactory.createCanvas(recorder),
      locale,
      textDirection,
      clipViewbox,
      onError: onError,
      filterRasterScale: filterRasterScale,
    );
  }

  FlutterVectorGraphicsListener._(
    this._id,
    this._pictureFactory,
    this._recorder,
    this._canvas,
    this._locale,
    this._textDirection,
    this._clipViewbox, {
    this.onError,
    double filterRasterScale = 1,
  }) : _filterRasterScale = filterRasterScale;

  final int _id;

  final PictureFactory _pictureFactory;

  final Locale? _locale;
  final TextDirection? _textDirection;
  final bool _clipViewbox;
  final double _filterRasterScale;
  _DecodeBudget _budget = _DecodeBudget();
  int _imageDepth = 0;
  bool _limitImageResources = false;

  final PictureRecorder _recorder;
  Canvas _canvas;
  final List<_FilterFrame> _filterFrames = <_FilterFrame>[];
  final List<_MaskFrame> _maskFrames = <_MaskFrame>[];

  /// This variable will receive the Signature for the error
  final VectorGraphicsErrorListener? onError;

  final List<Paint> _paints = <Paint>[];
  final List<Path> _paths = <Path>[];
  final List<Shader> _shaders = <Shader>[];
  final List<_TextConfig> _textConfig = <_TextConfig>[];
  final List<_TextPosition> _textPositions = <_TextPosition>[];
  final List<Future<void>> _pendingImages = <Future<void>>[];
  final Map<int, VectorImage> _images = <int, VectorImage>{};
  final Map<int, _PatternState> _patterns = <int, _PatternState>{};
  Path? _currentPath;
  Size _size = Size.zero;
  bool _done = false;
  bool _hasFilters = false;
  bool _requiresRasterResolution = false;

  double? _accumulatedTextPositionX;
  double _textPositionY = 0;
  Float64List? _textTransform;

  // Pending text draws within the current SVG anchored chunk. Per the SVG
  // spec, `text-anchor` applies to the chunk as a whole, so we cannot
  // commit a paragraph to the canvas until we know the full chunk width.
  final List<_PendingTextDraw> _pendingChunk = <_PendingTextDraw>[];
  // The user-space x at which the current chunk begins (i.e. the value of
  // `_accumulatedTextPositionX` at the time the first paragraph in the
  // chunk was queued). Null when no chunk is open.
  double? _chunkOriginX;
  // The text-anchor multiplier of the first paragraph in the chunk; used
  // to position the chunk as a whole.
  double _chunkAnchorMultiplier = 0;
  // Cumulative pen-advance within the current chunk so far.
  double _chunkAdvance = 0;

  _PatternConfig? _currentPattern;

  static final Paint _emptyPaint = Paint();
  static final Paint _dstInPaint = Paint()..blendMode = BlendMode.dstIn;
  static final Paint _grayscalePaint = Paint()
    ..colorFilter = const ColorFilter.matrix(<double>[
      0, 0, 0, 0, 0, //
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
    ]); //convert to grayscale (https://www.w3.org/Graphics/Color/sRGB) and use them as transparency

  @override
  void onBeginFilter(VectorFilter filter, Float64List transform, double width, double height) {
    _hasFilters = true;
    _flushPendingTextChunk();
    final frame = _FilterFrame(filter, transform, Size(width, height), _canvas);
    _filterFrames.add(frame);
    _canvas = frame.canvas;
    _canvas.transform(frame.inverse);
  }

  @override
  void onEndFilter() {
    if (_filterFrames.isEmpty) {
      throw const FormatException('Unbalanced SVG filter command');
    }
    _flushPendingTextChunk();
    final _FilterFrame frame = _filterFrames.removeLast();
    _canvas = frame.parent;
    final Picture source = frame.recorder.endRecording();
    if (frame.singular) {
      source.dispose();
      return;
    }
    final Float64List t = frame.transform;
    final double transformScale = math.max(
      math.sqrt(t[0] * t[0] + t[1] * t[1]),
      math.sqrt(t[4] * t[4] + t[5] * t[5]),
    );
    final context = FilterContext(
      frame.filter,
      source,
      frame.bounds ?? Rect.zero,
      frame.viewport,
      rasterScale: _filterRasterScale * transformScale,
    );
    try {
      final FilterImage result = executeFilter(context);
      _requiresRasterResolution |= context.requiresRasterResolution;
      _canvas.save();
      _canvas.transform(frame.transform);
      _canvas.drawPicture(result.picture);
      _canvas.restore();
      _includeFilterBounds(frame.bounds ?? Rect.zero, frame.transform);
    } finally {
      context.dispose();
    }
  }

  void _includeFilterBounds(Rect bounds, [Float64List? transform]) {
    if (_filterFrames.isEmpty) {
      return;
    }
    final path = Path()..addRect(bounds);
    final Path transformed = transform == null ? path : path.transform(transform);
    _includeFilterPath(transformed);
  }

  void _includeFilterPath(Path path) {
    if (_filterFrames.isEmpty) {
      return;
    }
    if (_maskFrames.isNotEmpty && _maskFrames.last.filterDepth == _filterFrames.length) {
      // A mask changes coverage, not the filtered object's geometry bounds.
      return;
    }
    if (_currentPattern != null &&
        _patterns[_currentPattern!._patternId]!.filterDepth == _filterFrames.length) {
      return;
    }
    final Rect bounds = path.transform(_canvas.getTransform()).getBounds();
    final _FilterFrame frame = _filterFrames.last;
    frame.bounds = frame.bounds?.expandToInclude(bounds) ?? bounds;
  }

  /// Convert the vector graphics asset this listener decoded into a [Picture].
  ///
  /// This method can only be called once for a given listener instance.
  PictureInfo toPicture() {
    assert(!_done);
    if (_filterFrames.isNotEmpty) {
      throw const FormatException('Unclosed SVG filter command');
    }
    if (_maskFrames.isNotEmpty) {
      throw const FormatException('Unclosed SVG mask command');
    }
    if (_currentPattern != null) {
      throw const FormatException('Unclosed SVG pattern command');
    }
    _done = true;
    _flushPendingTextChunk();
    try {
      return PictureInfo._(
        _recorder.endRecording(),
        _size,
        hasFilters: _hasFilters,
        requiresRasterResolution: _requiresRasterResolution,
        filterRasterScale: _filterRasterScale,
      );
    } finally {
      _disposeResources();
    }
  }

  /// Discards a failed decode, including any still-open nested filter pictures.
  void abort() {
    _done = true;
    // A later resource can fail synchronously while earlier decodes are pending.
    for (final Future<void> pending in _pendingImages) {
      unawaited(pending.catchError((Object error) {}));
    }
    for (final _FilterFrame frame in _filterFrames) {
      if (frame.recorder.isRecording) {
        frame.recorder.endRecording().dispose();
      }
    }
    _filterFrames.clear();
    for (final _MaskFrame frame in _maskFrames) {
      if (frame.recorder.isRecording) {
        frame.recorder.endRecording().dispose();
      }
    }
    _maskFrames.clear();
    if (_recorder.isRecording) {
      _recorder.endRecording().dispose();
    }
    _disposeResources();
  }

  void _disposeResources() {
    for (final VectorImage image in _images.values) {
      image.dispose();
    }
    _images.clear();
    for (final _PatternState pattern in _patterns.values) {
      if (pattern.recorder?.isRecording ?? false) {
        pattern.recorder!.endRecording().dispose();
      }
      pattern.shader?.dispose();
    }
    _patterns.clear();
  }

  /// Wait for all pending images to load.
  Future<void> waitForImageDecode() {
    assert(_pendingImages.isNotEmpty);
    return Future.wait(_pendingImages);
  }

  @override
  void onPathGeometry(int pathId) => _includeFilterPath(_paths[pathId]);

  @override
  Future<void> onDrawPath(int pathId, int? paintId, int? patternId) async {
    final Path path = _paths[pathId];
    _includeFilterPath(path);
    Paint? paint;
    if (paintId != null) {
      paint = _paints[paintId];
    }
    if (patternId != null) {
      if (paintId != null) {
        paint!.shader = _patterns[patternId]!.shader;
      } else {
        final newPaint = Paint();
        newPaint.shader = _patterns[patternId]!.shader;
        paint = newPaint;
      }
    }
    _canvas.drawPath(path, paint ?? _emptyPaint);
  }

  @override
  void onDrawVertices(Float32List vertices, Uint16List? indices, int? paintId) {
    final vertexData = Vertices.raw(VertexMode.triangles, vertices, indices: indices);
    Paint? paint;
    if (paintId != null) {
      paint = _paints[paintId];
    }
    _canvas.drawVertices(vertexData, BlendMode.srcOver, paint ?? _emptyPaint);
    vertexData.dispose();
  }

  @override
  void onPaintObject({
    required int color,
    required int? strokeCap,
    required int? strokeJoin,
    required int blendMode,
    required double? strokeMiterLimit,
    required double? strokeWidth,
    required int paintStyle,
    required int id,
    required int? shaderId,
  }) {
    assert(_paints.length == id, 'Expect ID to be ${_paints.length}');
    final paint = Paint()..color = Color(color);
    if (blendMode != 0) {
      paint.blendMode = BlendMode.values[blendMode];
    }

    if (shaderId != null) {
      paint.shader = _shaders[shaderId];
    }

    if (paintStyle == 1) {
      paint.style = PaintingStyle.stroke;
      if (strokeCap != null && strokeCap != 0) {
        paint.strokeCap = StrokeCap.values[strokeCap];
      }
      if (strokeJoin != null && strokeJoin != 0) {
        paint.strokeJoin = StrokeJoin.values[strokeJoin];
      }
      if (strokeMiterLimit != null && strokeMiterLimit != 4.0) {
        paint.strokeMiterLimit = strokeMiterLimit;
      }
      // SVG's default stroke width is 1.0. Flutter's default is 0.0.
      if (strokeWidth != null && strokeWidth != 0.0) {
        paint.strokeWidth = strokeWidth;
      }
    }
    _paints.add(paint);
  }

  @override
  void onPathClose() {
    _currentPath!.close();
  }

  @override
  void onPathCubicTo(double x1, double y1, double x2, double y2, double x3, double y3) {
    _currentPath!.cubicTo(x1, y1, x2, y2, x3, y3);
  }

  @override
  void onPathFinished() {
    _currentPath = null;
  }

  @override
  void onPathLineTo(double x, double y) {
    _currentPath!.lineTo(x, y);
  }

  @override
  void onPathMoveTo(double x, double y) {
    _currentPath!.moveTo(x, y);
  }

  @override
  void onPathStart(int id, int fillType) {
    assert(_currentPath == null);
    assert(_paths.length == id, 'Expected Id to be $id');

    final path = Path();
    path.fillType = PathFillType.values[fillType];
    _paths.add(path);
    _currentPath = path;
  }

  @override
  void onRestoreLayer() {
    _flushPendingTextChunk();
    if (_currentPattern != null &&
        identical(_canvas, _patterns[_currentPattern!._patternId]!.canvas) &&
        _canvas.getSaveCount() == 1) {
      final int patternId = _currentPattern!._patternId;
      onPatternFinished(
        _currentPattern,
        _patterns[patternId]!.recorder,
        _patterns[patternId]!.canvas!,
      );
    } else if (_maskFrames.isNotEmpty &&
        identical(_canvas, _maskFrames.last.canvas) &&
        _canvas.getSaveCount() == 1) {
      final _MaskFrame frame = _maskFrames.removeLast();
      final Picture mask = frame.recorder.endRecording();
      _canvas = frame.parent;
      try {
        _canvas.saveLayer(null, _dstInPaint);
        _canvas.saveLayer(null, _grayscalePaint);
        _canvas.drawPicture(mask);
        _canvas.restore();
        // ColorFilter.matrix operates on straight RGB; multiply its luminance
        // alpha by the original mask alpha in a second native compositing pass.
        _canvas.saveLayer(null, _dstInPaint);
        _canvas.drawPicture(mask);
        _canvas.restore();
        _canvas.restore();
      } finally {
        mask.dispose();
      }
    } else {
      _canvas.restore();
    }
  }

  @override
  void onSaveLayer(int paintId) {
    _flushPendingTextChunk();
    _canvas.saveLayer(null, _paints[paintId]);
  }

  @override
  void onMask() {
    _flushPendingTextChunk();
    final frame = _MaskFrame(_canvas, _filterFrames.length);
    _maskFrames.add(frame);
    _canvas = frame.canvas;
  }

  @override
  void onClipPath(int pathId) {
    _flushPendingTextChunk();
    _canvas.save();
    _canvas.clipPath(_paths[pathId]);
  }

  @override
  void onPatternStart(
    int patternId,
    double x,
    double y,
    double width,
    double height,
    Float64List transform,
  ) {
    _flushPendingTextChunk();
    if (!width.isFinite || !height.isFinite || width <= 0 || height <= 0) {
      throw const FormatException('Pattern dimensions must be finite and positive');
    }
    final _PatternState? previous = _patterns[patternId];
    if (previous?.recorder?.isRecording ?? false) {
      throw const FormatException('Recursive pattern recording');
    }
    previous?.shader?.dispose();
    final PictureRecorder recorder = _pictureFactory.createPictureRecorder();
    final Canvas newCanvas = _pictureFactory.createCanvas(recorder);
    newCanvas.clipRect(Offset(x, y) & Size(width, height));
    _patterns[patternId] = _PatternState()
      ..recorder = recorder
      ..canvas = newCanvas
      ..parent = _canvas
      ..parentPattern = _currentPattern
      ..filterDepth = _filterFrames.length;
    _currentPattern = _PatternConfig(patternId, width, height, transform);
    _canvas = newCanvas;
  }

  /// Creates ImageShader for active pattern.
  void onPatternFinished(
    // TODO(stuartmorgan): Fix this violation, which predates enabling the lint
    //  to catch it.
    // ignore: library_private_types_in_public_api
    _PatternConfig? currentPattern,
    PictureRecorder? patternRecorder,
    Canvas canvas,
  ) {
    final _PatternState state = _patterns[currentPattern!._patternId]!;
    assert(identical(state.canvas, canvas));
    final Picture picture = patternRecorder!.endRecording();
    _currentPattern = state.parentPattern;
    _canvas = state.parent!;
    try {
      final int width = math.max(1, currentPattern._width.round());
      final int height = math.max(1, currentPattern._height.round());
      _budget.reserveRaster(width, height);
      final Image image = picture.toImageSync(width, height);
      try {
        state.shader = ImageShader(
          image,
          TileMode.repeated,
          TileMode.repeated,
          currentPattern._transform,
        );
      } finally {
        image.dispose(); // retained by the shader.
      }
    } finally {
      picture.dispose();
    }
  }

  @override
  void onLinearGradient(
    double fromX,
    double fromY,
    double toX,
    double toY,
    Int32List colors,
    Float32List? offsets,
    int tileMode,
    int id,
  ) {
    assert(_shaders.length == id);

    final from = Offset(fromX, fromY);
    final to = Offset(toX, toY);
    final colorValues = <Color>[for (int i = 0; i < colors.length; i++) Color(colors[i])];
    final gradient = Gradient.linear(from, to, colorValues, offsets, TileMode.values[tileMode]);
    _shaders.add(gradient);
  }

  @override
  void onRadialGradient(
    double centerX,
    double centerY,
    double radius,
    double? focalX,
    double? focalY,
    Int32List colors,
    Float32List? offsets,
    Float64List? transform,
    int tileMode,
    int id,
  ) {
    assert(_shaders.length == id);

    final center = Offset(centerX, centerY);
    final Offset? focal = focalX == null ? null : Offset(focalX, focalY!);
    final colorValues = <Color>[for (int i = 0; i < colors.length; i++) Color(colors[i])];
    final bool hasFocal = focal != center && focal != null;
    final gradient = Gradient.radial(
      center,
      radius,
      colorValues,
      offsets,
      TileMode.values[tileMode],
      transform,
      hasFocal ? focal : null,
    );
    _shaders.add(gradient);
  }

  @override
  void onSize(double width, double height) {
    if (_clipViewbox) {
      _canvas.clipRect(Offset.zero & Size(width, height));
    }
    _size = Size(width, height);
  }

  @override
  void onTextConfig(
    String text,
    String? fontFamily,
    double xAnchorMultiplier,
    int fontWeight,
    double fontSize,
    int decoration,
    int decorationStyle,
    int decorationColor,
    int id,
  ) {
    final decorations = <TextDecoration>[];
    if (decoration & kUnderlineMask != 0) {
      decorations.add(TextDecoration.underline);
    }
    if (decoration & kOverlineMask != 0) {
      decorations.add(TextDecoration.overline);
    }
    if (decoration & kLineThroughMask != 0) {
      decorations.add(TextDecoration.lineThrough);
    }

    _textConfig.add(
      _TextConfig(
        text,
        fontFamily,
        xAnchorMultiplier,
        FontWeight.values[fontWeight],
        fontSize,
        TextDecoration.combine(decorations),
        TextDecorationStyle.values[decorationStyle],
        Color(decorationColor),
      ),
    );
  }

  @override
  void onTextPosition(
    int textPositionId,
    double? x,
    double? y,
    double? dx,
    double? dy,
    bool reset,
    Float64List? transform,
  ) {
    _textPositions.add(_TextPosition(x, y, dx, dy, reset, transform));
  }

  @override
  void onUpdateTextPosition(int textPositionId) {
    final _TextPosition position = _textPositions[textPositionId];
    // Per the SVG spec, a new anchored chunk begins only when the element
    // establishes an explicit absolute position (i.e. an `x` or `y` on a
    // <text> or <tspan>). Relative `dx`/`dy` move the pen but do NOT
    // start a new chunk; neither does the bare per-tspan TextPosition the
    // parser emits when the tspan has no x/y of its own. `reset` (set on
    // <text> elements) likewise starts a fresh chunk.
    if (position.reset || position.x != null || position.y != null) {
      _flushPendingTextChunk();
    }
    if (position.reset) {
      _accumulatedTextPositionX = 0;
      _textPositionY = 0;
    }

    if (position.x != null) {
      _accumulatedTextPositionX = position.x;
    }
    if (position.y != null) {
      _textPositionY = position.y ?? _textPositionY;
    }

    if (position.dx != null) {
      _accumulatedTextPositionX = (_accumulatedTextPositionX ?? 0) + position.dx!;
    }
    if (position.dy != null) {
      _textPositionY = _textPositionY + position.dy!;
    }

    _textTransform = position.transform;
  }

  @override
  Future<void> onDrawText(int textId, int? fillId, int? strokeId, int? patternId) async {
    final _TextConfig textConfig = _textConfig[textId];
    final double dx = _accumulatedTextPositionX ?? 0;
    final double dy = _textPositionY;

    // A change in text-anchor on a continuing chunk also starts a new
    // anchored chunk per the SVG spec.
    if (_pendingChunk.isNotEmpty && textConfig.xAnchorMultiplier != _chunkAnchorMultiplier) {
      _flushPendingTextChunk();
    }

    if (_pendingChunk.isEmpty) {
      _chunkOriginX = dx;
      _chunkAnchorMultiplier = textConfig.xAnchorMultiplier;
      _chunkAdvance = 0;
    } else {
      // Continuing the chunk: take the live pen position so any in-chunk
      // relative `dx="..."` movements applied via onUpdateTextPosition
      // since the last segment are accounted for in the segment's offset
      // within the chunk.
      _chunkAdvance = dx - _chunkOriginX!;
    }
    Paragraph buildParagraph(int? paintId) {
      final Paint paint = paintId == null ? _emptyPaint : _paints[paintId];
      if (patternId != null) {
        paint.shader = _patterns[patternId]!.shader;
      }
      final builder = ParagraphBuilder(ParagraphStyle(textDirection: _textDirection));
      builder.pushStyle(
        TextStyle(
          locale: _locale,
          foreground: paint,
          fontWeight: textConfig.fontWeight,
          fontSize: textConfig.fontSize,
          fontFamily: textConfig.fontFamily,
          decoration: textConfig.decoration,
          decorationStyle: textConfig.decorationStyle,
          decorationColor: textConfig.decorationColor,
        ),
      );
      builder.addText(textConfig.text);
      final Paragraph paragraph = builder.build();
      paragraph.layout(const ParagraphConstraints(width: double.infinity));
      return paragraph;
    }

    double paragraphWidth = 0;
    if (fillId == null && strokeId == null) {
      final Paragraph p = buildParagraph(null);
      paragraphWidth = p.maxIntrinsicWidth;
      _pendingChunk.add(_PendingTextDraw(p, _chunkAdvance, dy, _textTransform, paint: false));
    }
    if (fillId != null) {
      final Paragraph p = buildParagraph(fillId);
      paragraphWidth = p.maxIntrinsicWidth;
      _pendingChunk.add(_PendingTextDraw(p, _chunkAdvance, dy, _textTransform));
    }
    if (strokeId != null) {
      final Paragraph p = buildParagraph(strokeId);
      paragraphWidth = p.maxIntrinsicWidth;
      _pendingChunk.add(_PendingTextDraw(p, _chunkAdvance, dy, _textTransform));
    }

    _chunkAdvance += paragraphWidth;
    _accumulatedTextPositionX = dx + paragraphWidth;
  }

  void _flushPendingTextChunk() {
    if (_pendingChunk.isEmpty) {
      return;
    }
    final double originX = _chunkOriginX ?? 0;
    final double anchorOffset = _chunkAdvance * _chunkAnchorMultiplier;
    for (final _PendingTextDraw draw in _pendingChunk) {
      final Paragraph paragraph = draw.paragraph;
      if (draw.transform != null) {
        _canvas.save();
        _canvas.transform(draw.transform!);
      }
      _includeFilterBounds(
        Rect.fromLTWH(
          originX + draw.offsetWithinChunk - anchorOffset,
          draw.dy - paragraph.alphabeticBaseline,
          paragraph.maxIntrinsicWidth,
          paragraph.height,
        ),
      );
      if (draw.paint) {
        _canvas.drawParagraph(
          paragraph,
          Offset(
            originX + draw.offsetWithinChunk - anchorOffset,
            draw.dy - paragraph.alphabeticBaseline,
          ),
        );
      }
      paragraph.dispose();
      if (draw.transform != null) {
        _canvas.restore();
      }
    }
    _pendingChunk.clear();
    _chunkOriginX = null;
    _chunkAnchorMultiplier = 0;
    _chunkAdvance = 0;
  }

  int _createImageKey(int imageId, int format) {
    return Object.hash(_id, imageId, format);
  }

  @override
  void onImage(int imageId, int format, Uint8List data, {VectorGraphicsErrorListener? onError}) {
    if (_limitImageResources || format == ImageFormatTypes.vector) {
      _budget.reserveImage(data.length);
    }
    if (format == ImageFormatTypes.vector) {
      final Future<void> pending =
          _decodeVectorGraphics(
            data.buffer.asByteData(data.offsetInBytes, data.lengthInBytes),
            locale: _locale,
            textDirection: _textDirection,
            clipViewbox: false,
            loader: _EmbeddedVectorLoader(data),
            filterRasterScale: _filterRasterScale,
            budget: _budget,
            imageDepth: _imageDepth + 1,
            onError: onError ?? this.onError,
          ).then((PictureInfo info) {
            if (_done) {
              info.picture.dispose();
            } else {
              _hasFilters |= info.hasFilters;
              _requiresRasterResolution |= info.requiresRasterResolution;
              _images[imageId] = VectorImage.vector(info.picture, info.size);
            }
          });
      _pendingImages.add(pending);
      return;
    }
    var reservedPixels = false;
    final completer = Completer<void>();
    _pendingImages.add(completer.future);
    final ImageStreamCompleter? cacheCompleter = imageCache.putIfAbsent(
      _createImageKey(imageId, format),
      () {
        return OneFrameImageStreamCompleter(
          ImmutableBuffer.fromUint8List(data).then((ImmutableBuffer buffer) async {
            try {
              final ImageDescriptor descriptor = await ImageDescriptor.encoded(buffer);
              try {
                // Encoded ImageDescriptor dimensions are unavailable on web.
                // There the listener below reserves the decoded dimensions;
                // native backends can reject oversized images before decoding.
                if (_limitImageResources && !kIsWeb) {
                  _budget.reserveRaster(descriptor.width, descriptor.height);
                  reservedPixels = true;
                }
                final Codec codec = await descriptor.instantiateCodec();
                try {
                  return ImageInfo(image: (await codec.getNextFrame()).image);
                } finally {
                  codec.dispose();
                }
              } finally {
                descriptor.dispose();
              }
            } finally {
              buffer.dispose();
            }
          }),
        );
      },
    );
    // an error occurred.
    if (cacheCompleter == null) {
      completer.completeError('Failed to load image');
      return;
    }
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo image, bool synchronousCall) {
        cacheCompleter.removeListener(listener);
        if (_done) {
          image.image.dispose();
        } else {
          try {
            if (_limitImageResources && !reservedPixels) {
              _budget.reserveRaster(image.image.width, image.image.height);
            }
            _images[imageId] = VectorImage.raster(image.image);
          } catch (error, stack) {
            image.image.dispose();
            completer.completeError(error, stack);
            return;
          }
        }
        completer.complete();
      },
      onError: (Object exception, StackTrace? stackTrace) {
        cacheCompleter.removeListener(listener);
        if (_limitImageResources && exception is StateError) {
          completer.completeError(exception, stackTrace);
          return;
        }
        if (!completer.isCompleted) {
          completer.complete();
        }
        final VectorGraphicsErrorListener? errorListener = onError ?? this.onError;
        if (errorListener != null) {
          errorListener(exception, stackTrace);
        } else if (format != ImageFormatTypes.filterRaster) {
          FlutterError.reportError(
            FlutterErrorDetails(
              context: ErrorDescription('Failed to load image'),
              library: 'image resource service',
              exception: exception,
              stack: stackTrace,
              silent: true,
            ),
          );
        }
      },
    );
    cacheCompleter.addListener(listener);
  }

  @override
  void onDrawImage(
    int imageId,
    double x,
    double y,
    double width,
    double height,
    Float64List? transform,
  ) {
    final VectorImage? image = _images[imageId];
    assert(image != null, 'Invalid imageId: $imageId. Image not found in _images.');
    if (image == null) {
      return;
    }
    if (transform != null) {
      _canvas.save();
      _canvas.transform(transform);
    }
    _includeFilterBounds(Rect.fromLTWH(x, y, width, height));
    image.draw(_canvas, Rect.fromLTWH(x, y, width, height));
    if (transform != null) {
      _canvas.restore();
    }
  }
}

class _TextPosition {
  const _TextPosition(this.x, this.y, this.dx, this.dy, this.reset, this.transform);

  final double? x;
  final double? y;
  final double? dx;
  final double? dy;
  final bool reset;
  final Float64List? transform;
}

class _TextConfig {
  const _TextConfig(
    this.text,
    this.fontFamily,
    this.xAnchorMultiplier,
    this.fontWeight,
    this.fontSize,
    this.decoration,
    this.decorationStyle,
    this.decorationColor,
  );

  final String text;
  final String? fontFamily;
  final double fontSize;
  final double xAnchorMultiplier;
  final FontWeight fontWeight;
  final TextDecoration decoration;
  final TextDecorationStyle decorationStyle;
  final Color decorationColor;
}

class _PendingTextDraw {
  _PendingTextDraw(
    this.paragraph,
    this.offsetWithinChunk,
    this.dy,
    this.transform, {
    this.paint = true,
  });

  final bool paint;

  final Paragraph paragraph;
  final double offsetWithinChunk;
  final double dy;
  final Float64List? transform;
}

/// An exception thrown if decoding fails.
///
/// The [originalException] is a detailed exception about what failed in
/// decoding. The [source] contains the object that was used to load the bytes.
class VectorGraphicsDecodeException implements Exception {
  const VectorGraphicsDecodeException._(this.source, this.originalException);

  /// The object used to load the bytes for this
  final BytesLoader source;

  /// The original exception thrown by the decoder, for example a [StateError]
  /// indicating what specifically went wrong.
  final Object originalException;

  @override
  String toString() =>
      'VectorGraphicsDecodeException: Failed to decode vector graphic from $source.\n\nAdditional error: $originalException';
}

class _FilterFrame {
  _FilterFrame(this.filter, this.transform, this.viewport, this.parent) {
    canvas = _recordingCanvas(recorder);
    final double a = transform[0];
    final double b = transform[1];
    final double c = transform[4];
    final double d = transform[5];
    final double e = transform[12];
    final double f = transform[13];
    final double determinant = a * d - b * c;
    if (!determinant.isFinite) {
      throw const FormatException('Nonfinite SVG filter transform');
    }
    singular = determinant == 0;
    if (singular) {
      inverse = Float64List.fromList(<double>[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);
      return;
    }
    inverse = Float64List.fromList(<double>[
      d / determinant,
      -b / determinant,
      0,
      0,
      -c / determinant,
      a / determinant,
      0,
      0,
      0,
      0,
      1,
      0,
      (c * f - d * e) / determinant,
      (b * e - a * f) / determinant,
      0,
      1,
    ]);
  }

  final VectorFilter filter;
  final Float64List transform;
  final Size viewport;
  final Canvas parent;
  final PictureRecorder recorder = PictureRecorder();
  late final Canvas canvas;
  late final Float64List inverse;
  late final bool singular;
  Rect? bounds;
}

class _DecodeBudget {
  final FilterRasterBudget raster = FilterRasterBudget();
  int _images = 0;
  int _bytes = 0;

  void reserveImage(int bytes) {
    if (++_images > 256 || (_bytes += bytes) > 32 * 1024 * 1024) {
      throw StateError('Vector image resources exceed 256 images or 32 MiB');
    }
  }

  void reserveRaster(int width, int height) {
    if (width > 8192 || height > 8192) {
      throw StateError('Vector image resource exceeds 8192 pixels per dimension');
    }
    raster.reserve(width * height);
  }
}

class _EmbeddedVectorLoader extends BytesLoader {
  const _EmbeddedVectorLoader(this.bytes);
  final Uint8List bytes;

  @override
  Future<ByteData> loadBytes(BuildContext? context) => SynchronousFuture<ByteData>(
    bytes.buffer.asByteData(bytes.offsetInBytes, bytes.lengthInBytes),
  );

  @override
  String toString() => 'Embedded vector image (${bytes.length} bytes)';
}
