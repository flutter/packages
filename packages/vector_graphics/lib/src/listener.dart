// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
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
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'loader.dart';

const VectorGraphicsCodec _codec = VectorGraphicsCodec();

/// The deocded result of a vector graphics asset.
class PictureInfo {
  /// Construct a new [PictureInfo].
  PictureInfo._(this.picture, this.size);

  /// A picture generated from a vector graphics image.
  final Picture picture;

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
final Map<BytesLoader, Completer<void>> _pendingDecodes =
    <BytesLoader, Completer<void>>{};

/// Decode a vector graphics binary asset into a [Picture].
///
/// Throws a [StateError] if the data is invalid.
Future<PictureInfo> decodeVectorGraphics(
  ByteData data, {
  required Locale? locale,
  required TextDirection? textDirection,
  required bool clipViewbox,
  required BytesLoader loader,
  VectorGraphicsErrorListener? onError,
}) {
  try {
    // We might be in a test that's using a fake async zone. Make sure that any
    // real async work gets scheduled in the root zone so that it will not get
    // blocked by microtasks in the fake async zone, but do not unnecessarily
    // create zones outside of tests.
    bool useZone = false;
    assert(() {
      _debugLastTextDirection = textDirection;
      _debugLastLocale = locale;
      useZone = Zone.current != Zone.root &&
          Zone.current.scheduleMicrotask != Zone.root.scheduleMicrotask;
      return true;
    }());

    @pragma('vm:prefer-inline')
    Future<PictureInfo> process() {
      final FlutterVectorGraphicsListener listener =
          FlutterVectorGraphicsListener(
        id: loader.hashCode,
        locale: locale,
        textDirection: textDirection,
        clipViewbox: clipViewbox,
        onError: onError,
      );
      DecodeResponse response = _codec.decode(data, listener);
      if (response.complete) {
        return SynchronousFuture<PictureInfo>(listener.toPicture());
      }
      assert(() {
        _pendingDecodes[loader] = Completer<void>();
        return true;
      }());
      return listener.waitForImageDecode().then((_) {
        response = _codec.decode(data, listener, response: response);
        assert(response.complete);
        assert(() {
          _pendingDecodes.remove(loader)?.complete();
          return true;
        }());
        return listener.toPicture();
      });
    }

    if (!kDebugMode || !useZone) {
      return process();
    }

    return Zone.current
        .fork(
          specification: ZoneSpecification(
            scheduleMicrotask:
                (Zone self, ZoneDelegate parent, Zone zone, void Function() f) {
              Zone.root.scheduleMicrotask(f);
            },
            createTimer: (Zone self, ZoneDelegate parent, Zone zone,
                Duration duration, void Function() f) {
              return Zone.root.createTimer(duration, f);
            },
            createPeriodicTimer: (Zone self, ZoneDelegate parent, Zone zone,
                Duration period, void Function(Timer timer) f) {
              return Zone.root.createPeriodicTimer(period, f);
            },
          ),
        )
        .run<Future<PictureInfo>>(process);
  } catch (e, s) {
    _pendingDecodes.remove(loader)?.completeError(e, s);
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
  Canvas createCanvas(PictureRecorder recorder) => Canvas(recorder);

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
    @visibleForTesting
    PictureFactory pictureFactory = const _DefaultPictureFactory(),
    VectorGraphicsErrorListener? onError,
  }) {
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
  });

  final int _id;

  final PictureFactory _pictureFactory;

  final Locale? _locale;
  final TextDirection? _textDirection;
  final bool _clipViewbox;

  final PictureRecorder _recorder;
  final Canvas _canvas;

  /// This variable will receive the Signature for the error
  final VectorGraphicsErrorListener? onError;

  final List<Paint> _paints = <Paint>[];
  final List<Path> _paths = <Path>[];
  final List<Shader> _shaders = <Shader>[];
  final List<_TextConfig> _textConfig = <_TextConfig>[];
  final List<_TextPosition> _textPositions = <_TextPosition>[];
  final List<Future<void>> _pendingImages = <Future<void>>[];
  final Map<int, Image> _images = <int, Image>{};
  final Map<int, _PatternState> _patterns = <int, _PatternState>{};
  Path? _currentPath;
  Size _size = Size.zero;
  bool _done = false;

  double? _accumulatedTextPositionX;
  double _textPositionY = 0;
  Float64List? _textTransform;

  _PatternConfig? _currentPattern;

  static final Paint _emptyPaint = Paint();
  static final Paint _grayscaleDstInPaint = Paint()
    ..blendMode = BlendMode.dstIn
    ..colorFilter = const ColorFilter.matrix(<double>[
      0, 0, 0, 0, 0, //
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
    ]); //convert to grayscale (https://www.w3.org/Graphics/Color/sRGB) and use them as transparency

  /// Convert the vector graphics asset this listener decoded into a [Picture].
  ///
  /// This method can only be called once for a given listener instance.
  PictureInfo toPicture() {
    assert(!_done);
    _done = true;
    try {
      return PictureInfo._(_recorder.endRecording(), _size);
    } finally {
      for (final Image image in _images.values) {
        image.dispose();
      }
      _images.clear();
      for (final _PatternState pattern in _patterns.values) {
        pattern.shader?.dispose();
      }
      _patterns.clear();
    }
  }

  /// Wait for all pending images to load.
  Future<void> waitForImageDecode() {
    assert(_pendingImages.isNotEmpty);
    return Future.wait(_pendingImages);
  }

  @override
  Future<void> onDrawPath(int pathId, int? paintId, int? patternId) async {
    final Path path = _paths[pathId];
    Paint? paint;
    if (paintId != null) {
      paint = _paints[paintId];
    }
    if (patternId != null) {
      if (paintId != null) {
        paint!.shader = _patterns[patternId]!.shader;
      } else {
        final Paint newPaint = Paint();
        newPaint.shader = _patterns[patternId]!.shader;
        paint = newPaint;
      }
    }
    if (_currentPattern != null) {
      _patterns[_currentPattern!._patternId]!
          .canvas!
          .drawPath(path, paint ?? _emptyPaint);
    } else {
      _canvas.drawPath(path, paint ?? _emptyPaint);
    }
  }

  @override
  void onDrawVertices(Float32List vertices, Uint16List? indices, int? paintId) {
    final Vertices vertexData = Vertices.raw(
      VertexMode.triangles,
      vertices,
      indices: indices,
    );
    Paint? paint;
    if (paintId != null) {
      paint = _paints[paintId];
    }
    _canvas.drawVertices(
      vertexData,
      BlendMode.srcOver,
      paint ?? _emptyPaint,
    );
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
    final Paint paint = Paint()..color = Color(color);
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
  void onPathCubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
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

    final Path path = Path();
    path.fillType = PathFillType.values[fillType];
    _paths.add(path);
    _currentPath = path;
  }

  @override
  void onRestoreLayer() {
    if (_currentPattern != null) {
      final int patternId = _currentPattern!._patternId;
      onPatternFinished(_currentPattern, _patterns[patternId]!.recorder,
          _patterns[patternId]!.canvas!);
    } else {
      _canvas.restore();
    }
  }

  @override
  void onSaveLayer(int paintId) {
    _canvas.saveLayer(null, _paints[paintId]);
  }

  @override
  void onMask() {
    _canvas.saveLayer(null, _grayscaleDstInPaint);
  }

  @override
  void onClipPath(int pathId) {
    _canvas.save();
    _canvas.clipPath(_paths[pathId]);
  }

  @override
  void onPatternStart(int patternId, double x, double y, double width,
      double height, Float64List transform) {
    assert(_currentPattern == null);
    _currentPattern = _PatternConfig(patternId, width, height, transform);
    final PictureRecorder recorder = _pictureFactory.createPictureRecorder();
    final Canvas newCanvas = _pictureFactory.createCanvas(recorder);
    newCanvas.clipRect(Offset(x, y) & Size(width, height));
    _patterns[patternId] = _PatternState()
      ..recorder = recorder
      ..canvas = newCanvas;
  }

  /// Creates ImageShader for active pattern.
  // TODO(stuartmorgan): Fix this violation, which predates enabling the lint
  //  to catch it.
  // ignore: library_private_types_in_public_api
  void onPatternFinished(_PatternConfig? currentPattern,
      PictureRecorder? patternRecorder, Canvas canvas) {
    final FlutterVectorGraphicsListener patternListener =
        FlutterVectorGraphicsListener._(
      0,
      _pictureFactory,
      patternRecorder!,
      canvas,
      _locale,
      _textDirection,
      _clipViewbox,
    );

    patternListener._size =
        Size(currentPattern!._width, currentPattern._height);

    final PictureInfo pictureInfo = patternListener.toPicture();
    _currentPattern = null;
    final Image image = pictureInfo.picture.toImageSync(
        currentPattern._width.round(), currentPattern._height.round());

    final ImageShader pattern = ImageShader(
      image,
      TileMode.repeated,
      TileMode.repeated,
      currentPattern._transform,
    );

    _patterns[currentPattern._patternId]!.shader = pattern;
    image.dispose(); // kept alive by the shader.
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

    final Offset from = Offset(fromX, fromY);
    final Offset to = Offset(toX, toY);
    final List<Color> colorValues = <Color>[
      for (int i = 0; i < colors.length; i++) Color(colors[i])
    ];
    final Gradient gradient = Gradient.linear(
      from,
      to,
      colorValues,
      offsets,
      TileMode.values[tileMode],
    );
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

    final Offset center = Offset(centerX, centerY);
    final Offset? focal = focalX == null ? null : Offset(focalX, focalY!);
    final List<Color> colorValues = <Color>[
      for (int i = 0; i < colors.length; i++) Color(colors[i])
    ];
    final bool hasFocal = focal != center && focal != null;
    final Gradient gradient = Gradient.radial(
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
    final List<TextDecoration> decorations = <TextDecoration>[];
    if (decoration & kUnderlineMask != 0) {
      decorations.add(TextDecoration.underline);
    }
    if (decoration & kOverlineMask != 0) {
      decorations.add(TextDecoration.overline);
    }
    if (decoration & kLineThroughMask != 0) {
      decorations.add(TextDecoration.lineThrough);
    }

    _textConfig.add(_TextConfig(
      text,
      fontFamily,
      xAnchorMultiplier,
      FontWeight.values[fontWeight],
      fontSize,
      TextDecoration.combine(decorations),
      TextDecorationStyle.values[decorationStyle],
      Color(decorationColor),
    ));
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
      _accumulatedTextPositionX =
          (_accumulatedTextPositionX ?? 0) + position.dx!;
    }
    if (position.dy != null) {
      _textPositionY = _textPositionY + position.dy!;
    }

    _textTransform = position.transform;
  }

  @override
  Future<void> onDrawText(
    int textId,
    int? fillId,
    int? strokeId,
    int? patternId,
  ) async {
    final _TextConfig textConfig = _textConfig[textId];
    final double dx = _accumulatedTextPositionX ?? 0;
    final double dy = _textPositionY;
    double paragraphWidth = 0;

    void draw(int paintId) {
      final Paint paint = _paints[paintId];
      if (patternId != null) {
        paint.shader = _patterns[patternId]!.shader;
      }
      final ParagraphBuilder builder = ParagraphBuilder(ParagraphStyle(
        textDirection: _textDirection,
      ));
      builder.pushStyle(TextStyle(
        locale: _locale,
        foreground: paint,
        fontWeight: textConfig.fontWeight,
        fontSize: textConfig.fontSize,
        fontFamily: textConfig.fontFamily,
        decoration: textConfig.decoration,
        decorationStyle: textConfig.decorationStyle,
        decorationColor: textConfig.decorationColor,
      ));

      builder.addText(textConfig.text);

      final Paragraph paragraph = builder.build();
      paragraph.layout(const ParagraphConstraints(
        width: double.infinity,
      ));
      paragraphWidth = paragraph.maxIntrinsicWidth;

      if (_textTransform != null) {
        _canvas.save();
        _canvas.transform(_textTransform!);
      }
      _canvas.drawParagraph(
        paragraph,
        Offset(
          dx - paragraph.maxIntrinsicWidth * textConfig.xAnchorMultiplier,
          dy - paragraph.alphabeticBaseline,
        ),
      );
      paragraph.dispose();
      if (_textTransform != null) {
        _canvas.restore();
      }
    }

    if (fillId != null) {
      draw(fillId);
    }
    if (strokeId != null) {
      draw(strokeId);
    }
    _accumulatedTextPositionX = dx + paragraphWidth;
  }

  int _createImageKey(int imageId, int format) {
    return Object.hash(_id, imageId, format);
  }

  @override
  void onImage(
    int imageId,
    int format,
    Uint8List data, {
    VectorGraphicsErrorListener? onError,
  }) {
    final Completer<void> completer = Completer<void>();
    _pendingImages.add(completer.future);
    final ImageStreamCompleter? cacheCompleter =
        imageCache.putIfAbsent(_createImageKey(imageId, format), () {
      return OneFrameImageStreamCompleter(ImmutableBuffer.fromUint8List(data)
          .then((ImmutableBuffer buffer) async {
        try {
          final ImageDescriptor descriptor =
              await ImageDescriptor.encoded(buffer);
          final Codec codec = await descriptor.instantiateCodec();
          final FrameInfo info = await codec.getNextFrame();
          final Image image = info.image;
          descriptor.dispose();
          codec.dispose();
          return ImageInfo(image: image);
        } finally {
          buffer.dispose();
        }
      }));
    });
    // an error occurred.
    if (cacheCompleter == null) {
      completer.completeError('Failed to load image');
      return;
    }
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo image, bool synchronousCall) {
        cacheCompleter.removeListener(listener);
        _images[imageId] = image.image;
        completer.complete();
      },
      onError: (Object exception, StackTrace? stackTrace) {
        if (!completer.isCompleted) {
          completer.complete();
        }
        cacheCompleter.removeListener(listener);
        if (onError != null) {
          onError(exception, stackTrace);
        } else {
          FlutterError.reportError(FlutterErrorDetails(
            context: ErrorDescription('Failed to load image'),
            library: 'image resource service',
            exception: exception,
            stack: stackTrace,
            silent: true,
          ));
        }
      },
    );
    cacheCompleter.addListener(listener);
  }

  @override
  void onDrawImage(int imageId, double x, double y, double width, double height,
      Float64List? transform) {
    final Image image = _images[imageId]!;
    if (transform != null) {
      _canvas.save();
      _canvas.transform(transform);
    }
    _canvas.drawImageRect(
      image,
      Rect.fromLTRB(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(x, y, width, height),
      Paint(),
    );
    if (transform != null) {
      _canvas.restore();
    }
  }
}

class _TextPosition {
  const _TextPosition(
    this.x,
    this.y,
    this.dx,
    this.dy,
    this.reset,
    this.transform,
  );

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
