// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

import 'loader.dart';

const VectorGraphicsCodec _codec = VectorGraphicsCodec();

/// The deocded result of a vector graphics asset.
class PictureInfo {
  /// Construct a new [PictureInfo].
  PictureInfo._(this.picture, this.size);

  /// A picture generated from a vector graphics image.
  final ui.Picture picture;

  /// The target size of the picture.
  ///
  /// This information should be used to scale and position
  /// the picture based on the available space and alignment.
  final ui.Size size;
}

/// Internal testing only.
@visibleForTesting
Locale? get debugLastLocale => _debugLastLocale;
Locale? _debugLastLocale;

/// Internal testing only.
@visibleForTesting
TextDirection? get debugLastTextDirection => _debugLastTextDirection;
TextDirection? _debugLastTextDirection;

/// Decode a vector graphics binary asset into a [ui.Picture].
///
/// Throws a [StateError] if the data is invalid.
Future<PictureInfo> decodeVectorGraphics(
  ByteData data, {
  required Locale? locale,
  required TextDirection? textDirection,
  required BytesLoader loader,
}) async {
  try {
    assert(() {
      _debugLastTextDirection = textDirection;
      _debugLastLocale = locale;
      return true;
    }());
    final FlutterVectorGraphicsListener listener =
        FlutterVectorGraphicsListener(
      locale: locale,
      textDirection: textDirection,
    );
    DecodeResponse response = _codec.decode(data, listener);
    if (response.complete) {
      return listener.toPicture();
    }
    await listener.waitForImageDecode();
    response = _codec.decode(data, listener, response: response);
    assert(response.complete);

    return listener.toPicture();
  } catch (e) {
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
  ui.Canvas? canvas;

  /// The image shader created by the pattern.
  ui.ImageShader? shader;

  /// The recorder that will capture the newly created canvas.
  ui.PictureRecorder? recorder;
}

/// A listener implementation for the vector graphics codec that converts the
/// format into a [ui.Picture].
class FlutterVectorGraphicsListener extends VectorGraphicsCodecListener {
  /// Create a new [FlutterVectorGraphicsListener].
  ///
  /// The [locale] and [textDirection] are used to configure any text created
  /// by the vector_graphic.
  factory FlutterVectorGraphicsListener({
    Locale? locale,
    TextDirection? textDirection,
  }) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    return FlutterVectorGraphicsListener._(
      canvas,
      recorder,
      locale,
      textDirection,
    );
  }

  FlutterVectorGraphicsListener._(
    this._canvas,
    this._recorder,
    this._locale,
    this._textDirection,
  );

  final Locale? _locale;
  final TextDirection? _textDirection;

  final ui.PictureRecorder _recorder;
  final ui.Canvas _canvas;

  final List<ui.Paint> _paints = <ui.Paint>[];
  final List<ui.Path> _paths = <ui.Path>[];
  final List<ui.Shader> _shaders = <ui.Shader>[];
  final List<_TextConfig> _textConfig = <_TextConfig>[];
  final List<Future<ui.Image>> _pendingImages = <Future<ui.Image>>[];
  final Map<int, ui.Image> _images = <int, ui.Image>{};
  final Map<int, _PatternState> _patterns = <int, _PatternState>{};
  ui.Path? _currentPath;
  ui.Size _size = ui.Size.zero;
  bool _done = false;

  _PatternConfig? _currentPattern;

  static final ui.Paint _emptyPaint = ui.Paint();
  static final ui.Paint _grayscaleDstInPaint = ui.Paint()
    ..blendMode = ui.BlendMode.dstIn
    ..colorFilter = const ui.ColorFilter.matrix(<double>[
      0, 0, 0, 0, 0, //
      0, 0, 0, 0, 0,
      0, 0, 0, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
    ]); //convert to grayscale (https://www.w3.org/Graphics/Color/sRGB) and use them as transparency

  /// Convert the vector graphics asset this listener decoded into a [ui.Picture].
  ///
  /// This method can only be called once for a given listener instance.
  PictureInfo toPicture() {
    assert(!_done);
    _done = true;
    try {
      return PictureInfo._(_recorder.endRecording(), _size);
    } finally {
      for (final ui.Image image in _images.values) {
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
  void onDrawPath(int pathId, int? paintId, int? patternId) async {
    final ui.Path path = _paths[pathId];
    ui.Paint? paint;
    if (paintId != null) {
      paint = _paints[paintId];
    }
    if (patternId != null) {
      if (paintId != null) {
        paint!.shader = _patterns[patternId]!.shader;
      } else {
        final ui.Paint newPaint = ui.Paint();
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
    final ui.Vertices vertexData = ui.Vertices.raw(
      ui.VertexMode.triangles,
      vertices,
      indices: indices,
    );
    ui.Paint? paint;
    if (paintId != null) {
      paint = _paints[paintId];
    }
    _canvas.drawVertices(
      vertexData,
      ui.BlendMode.srcOver,
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
    final ui.Paint paint = ui.Paint()..color = ui.Color(color);
    if (blendMode != 0) {
      paint.blendMode = ui.BlendMode.values[blendMode];
    }

    if (shaderId != null) {
      paint.shader = _shaders[shaderId];
    }

    if (paintStyle == 1) {
      paint.style = ui.PaintingStyle.stroke;
      if (strokeCap != null && strokeCap != 0) {
        paint.strokeCap = ui.StrokeCap.values[strokeCap];
      }
      if (strokeJoin != null && strokeJoin != 0) {
        paint.strokeJoin = ui.StrokeJoin.values[strokeJoin];
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

    final ui.Path path = ui.Path();
    path.fillType = ui.PathFillType.values[fillType];
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
    _patterns[patternId]!.recorder = ui.PictureRecorder();
    final ui.Canvas newCanvas = ui.Canvas(_patterns[patternId]!.recorder!);
    newCanvas.clipRect(ui.Offset(x, y) & ui.Size(width, height));
    _patterns[patternId]!.canvas = newCanvas;
  }

  /// Creates ImageShader for active pattern.
  void onPatternFinished(_PatternConfig? currentPattern,
      ui.PictureRecorder? patternRecorder, ui.Canvas canvas) {
    final FlutterVectorGraphicsListener patternListener =
        FlutterVectorGraphicsListener._(
            canvas, patternRecorder!, _locale, _textDirection);

    patternListener._size =
        ui.Size(currentPattern!._width, currentPattern._height);

    final PictureInfo pictureInfo = patternListener.toPicture();
    _currentPattern = null;
    final ui.Image image = pictureInfo.picture.toImageSync(
        currentPattern._width.round(), currentPattern._height.round());

    final ui.ImageShader pattern = ui.ImageShader(
      image,
      ui.TileMode.repeated,
      ui.TileMode.repeated,
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

    final ui.Offset from = ui.Offset(fromX, fromY);
    final ui.Offset to = ui.Offset(toX, toY);
    final List<ui.Color> colorValues = <ui.Color>[
      for (int i = 0; i < colors.length; i++) ui.Color(colors[i])
    ];
    final ui.Gradient gradient = ui.Gradient.linear(
      from,
      to,
      colorValues,
      offsets,
      ui.TileMode.values[tileMode],
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

    final ui.Offset center = ui.Offset(centerX, centerY);
    final ui.Offset? focal = focalX == null ? null : ui.Offset(focalX, focalY!);
    final List<ui.Color> colorValues = <ui.Color>[
      for (int i = 0; i < colors.length; i++) ui.Color(colors[i])
    ];
    final bool hasFocal = focal != center && focal != null;
    final ui.Gradient gradient = ui.Gradient.radial(
      center,
      radius,
      colorValues,
      offsets,
      ui.TileMode.values[tileMode],
      transform,
      hasFocal ? focal : null,
    );
    _shaders.add(gradient);
  }

  @override
  void onSize(double width, double height) {
    _canvas.clipRect(ui.Offset.zero & ui.Size(width, height));
    _size = ui.Size(width, height);
  }

  @override
  void onTextConfig(
    String text,
    String? fontFamily,
    double x,
    double y,
    int fontWeight,
    double fontSize,
    Float64List? transform,
    int id,
  ) {
    _textConfig.add(_TextConfig(
      text,
      fontFamily,
      x,
      y,
      ui.FontWeight.values[fontWeight],
      fontSize,
      transform,
    ));
  }

  @override
  void onDrawText(int textId, int paintId, int? patternId) async {
    final ui.Paint paint = _paints[paintId];
    if (patternId != null) {
      paint.shader = _patterns[patternId]!.shader;
    }
    final _TextConfig textConfig = _textConfig[textId];
    final ui.ParagraphBuilder builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textDirection: _textDirection,
      ),
    );
    builder.pushStyle(ui.TextStyle(
      locale: _locale,
      foreground: paint,
      fontWeight: textConfig.fontWeight,
      fontSize: textConfig.fontSize,
      fontFamily: textConfig.fontFamily,
    ));
    builder.addText(textConfig.text);

    final ui.Paragraph paragraph = builder.build();
    paragraph.layout(const ui.ParagraphConstraints(
      width: double.infinity,
    ));

    if (textConfig.transform != null) {
      _canvas.save();
      _canvas.transform(textConfig.transform!);
    }
    _canvas.drawParagraph(
      paragraph,
      ui.Offset(textConfig.dx, textConfig.dy - paragraph.alphabeticBaseline),
    );
    paragraph.dispose();
    if (textConfig.transform != null) {
      _canvas.restore();
    }
  }

  @override
  void onImage(int imageId, int format, Uint8List data) {
    assert(format == 0); // Only PNG is supported.
    _pendingImages.add(ui.ImmutableBuffer.fromUint8List(data)
        .then((ui.ImmutableBuffer buffer) async {
      final ui.ImageDescriptor descriptor =
          await ui.ImageDescriptor.encoded(buffer);
      final ui.Codec codec = await descriptor.instantiateCodec();
      final ui.FrameInfo info = await codec.getNextFrame();
      final ui.Image image = info.image;
      buffer.dispose();
      descriptor.dispose();
      codec.dispose();
      _images[imageId] = image;
      return image;
    }));
  }

  @override
  void onDrawImage(int imageId, double x, double y, double width, double height,
      Float64List? transform) {
    final ui.Image image = _images[imageId]!;
    if (transform != null) {
      _canvas.save();
      _canvas.transform(transform);
    }
    paintImage(
      canvas: _canvas,
      rect: ui.Rect.fromLTWH(x, y, width, height),
      image: image,
    );
    if (transform != null) {
      _canvas.restore();
    }
  }
}

class _TextConfig {
  const _TextConfig(
    this.text,
    this.fontFamily,
    this.dx,
    this.dy,
    this.fontWeight,
    this.fontSize,
    this.transform,
  );

  final String text;
  final String? fontFamily;
  final double fontSize;
  final double dx;
  final double dy;
  final ui.FontWeight fontWeight;
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
