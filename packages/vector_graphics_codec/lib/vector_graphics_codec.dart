import 'dart:typed_data';
import 'dart:convert';

/// The [VectorGraphicsCodec] provides support for both encoding and
/// decoding the vector_graphics binary format.
class VectorGraphicsCodec {
  /// Create a new [VectorGraphicsCodec].
  ///
  /// The codec is stateless and the const constructor should be preferred.
  const VectorGraphicsCodec();

  /// The maximum supported value for an id.
  ///
  /// The codec does not support encoding more than this many paths, paints,
  /// or shaders in a single buffer.
  ///
  /// Vertices are written inline and not subject to this constraint.
  static const int kMaxId = 65535;

  static const int _pathTag = 27;
  static const int _fillPaintTag = 28;
  static const int _strokePaintTag = 29;
  static const int _drawPathTag = 30;
  static const int _drawVerticesTag = 31;
  static const int _moveToTag = 32;
  static const int _lineToTag = 33;
  static const int _cubicToTag = 34;
  static const int _closeTag = 35;
  static const int _finishPathTag = 36;
  static const int _saveLayerTag = 37;
  static const int _restoreTag = 38;
  static const int _linearGradientTag = 39;
  static const int _radialGradientTag = 40;
  static const int _sizeTag = 41;
  static const int _clipPathTag = 42;
  static const int _maskTag = 43;
  static const int _drawTextTag = 44;
  static const int _textConfigTag = 45;

  static const int _version = 1;
  static const int _magicNumber = 0x00882d62;

  /// Decode the vector_graphics binary.
  ///
  /// Without a provided [VectorGraphicsCodecListener], this method will only
  /// validate the basic structure of an object. decoders that wish to construct
  /// a dart:ui Picture object should implement [VectorGraphicsCodecListener].
  ///
  /// Throws a [StateError] If the message is invalid.
  void decode(ByteData data, VectorGraphicsCodecListener? listener) {
    final _ReadBuffer buffer = _ReadBuffer(data);
    if (data.lengthInBytes < 5) {
      throw StateError(
          'The provided data was not a vector_graphics binary asset.');
    }
    final int magicNumber = buffer.getUint32();
    if (magicNumber != _magicNumber) {
      throw StateError(
          'The provided data was not a vector_graphics binary asset.');
    }
    final int version = buffer.getUint8();
    if (version != _version) {
      throw StateError(
          'The provided data does not match the currently supported version.');
    }
    while (buffer.hasRemaining) {
      final int type = buffer.getUint8();
      switch (type) {
        case _linearGradientTag:
          _readLinearGradient(buffer, listener);
          continue;
        case _radialGradientTag:
          _readRadialGradient(buffer, listener);
          continue;
        case _fillPaintTag:
          _readFillPaint(buffer, listener);
          continue;
        case _strokePaintTag:
          _readStrokePaint(buffer, listener);
          continue;
        case _pathTag:
          _readPath(buffer, listener);
          continue;
        case _drawPathTag:
          _readDrawPath(buffer, listener);
          continue;
        case _drawVerticesTag:
          _readDrawVertices(buffer, listener);
          continue;
        case _moveToTag:
          _readMoveTo(buffer, listener);
          continue;
        case _lineToTag:
          _readLineTo(buffer, listener);
          continue;
        case _cubicToTag:
          _readCubicTo(buffer, listener);
          continue;
        case _closeTag:
          _readClose(buffer, listener);
          continue;
        case _finishPathTag:
          listener?.onPathFinished();
          continue;
        case _restoreTag:
          listener?.onRestoreLayer();
          continue;
        case _saveLayerTag:
          _readSaveLayer(buffer, listener);
          continue;
        case _sizeTag:
          _readSize(buffer, listener);
          continue;
        case _clipPathTag:
          _readClipPath(buffer, listener);
          continue;
        case _maskTag:
          listener?.onMask();
          continue;
        case _textConfigTag:
          _readTextConfig(buffer, listener);
          continue;
        case _drawTextTag:
          _readDrawText(buffer, listener);
          continue;
        default:
          throw StateError('Unknown type tag $type');
      }
    }
  }

  /// Encode the dimensions of the vector graphic.
  ///
  /// This should be the first attribute encoded.
  void writeSize(
    VectorGraphicsBuffer buffer,
    double width,
    double height,
  ) {
    if (buffer._decodePhase.index != _CurrentSection.size.index) {
      throw StateError('Size already written');
    }
    buffer._decodePhase = _CurrentSection.shaders;
    buffer._putUint8(_sizeTag);
    buffer._putFloat32(width);
    buffer._putFloat32(height);
  }

  /// Encode a draw path command in the current buffer.
  ///
  /// Requires that [pathId] and [paintId] to already be encoded.
  void writeDrawPath(
    VectorGraphicsBuffer buffer,
    int pathId,
    int paintId,
  ) {
    buffer._putUint8(_drawPathTag);
    buffer._putUint16(pathId);
    buffer._putUint16(paintId);
  }

  /// Encode a draw vertices command in the current buffer.
  ///
  /// The [indices] are the index buffer used and is optional.
  void writeDrawVertices(
    VectorGraphicsBuffer buffer,
    Float32List vertices,
    Uint16List? indices,
    int? paintId,
  ) {
    if (buffer._decodePhase.index > _CurrentSection.commands.index) {
      throw StateError('Commands must be encoded together.');
    }
    buffer._decodePhase = _CurrentSection.commands;
    // Type Tag
    // Vertex Length
    // Vertex Buffer
    // Index Length
    // Index Buffer (If non zero)
    // Paint Id.
    buffer._putUint8(_drawVerticesTag);
    buffer._putUint16(paintId ?? kMaxId);
    buffer._putUint16(vertices.length);
    buffer._putFloat32List(vertices);
    if (indices != null) {
      buffer._putUint16(indices.length);
      buffer._putUint16List(indices);
    } else {
      buffer._putUint16(0);
    }
  }

  /// Encode a paint object used for a fill in the current buffer, returning
  /// the identifier assigned to it.
  ///
  ///
  /// [color] is the 32-bit ARBG color representation used by Flutter
  /// internally. The [blendMode] fields should be the index of the
  /// corresponding enumeration.
  ///
  /// This method is only used to write the paint used for fill commands.
  /// To write a paint used for a stroke command, see [writeStroke].
  int writeFill(
    VectorGraphicsBuffer buffer,
    int color,
    int blendMode, [
    int? shaderId,
  ]) {
    if (buffer._decodePhase.index > _CurrentSection.paints.index) {
      throw StateError('Paints must be encoded together.');
    }
    buffer._decodePhase = _CurrentSection.paints;
    final int paintId = buffer._nextPaintId++;
    assert(paintId < kMaxId);
    buffer._putUint8(_fillPaintTag);
    buffer._putUint32(color);
    buffer._putUint8(blendMode);
    buffer._putUint16(paintId);
    buffer._putUint16(shaderId ?? kMaxId);
    return paintId;
  }

  /// Write a linear gradient into the current buffer.
  int writeLinearGradient(
    VectorGraphicsBuffer buffer, {
    required double fromX,
    required double fromY,
    required double toX,
    required double toY,
    required Int32List colors,
    required Float32List? offsets,
    required int tileMode,
  }) {
    if (buffer._decodePhase.index > _CurrentSection.shaders.index) {
      throw StateError('Shaders must be encoded together.');
    }
    buffer._decodePhase = _CurrentSection.shaders;
    final int shaderId = buffer._nextShaderId++;
    assert(shaderId < kMaxId);
    buffer._putUint8(_linearGradientTag);
    buffer._putUint16(shaderId);
    buffer._putFloat32(fromX);
    buffer._putFloat32(fromY);
    buffer._putFloat32(toX);
    buffer._putFloat32(toY);
    buffer._putUint16(colors.length);
    buffer._putInt32List(colors);
    if (offsets == null) {
      buffer._putUint16(0);
    } else {
      buffer._putUint16(offsets.length);
      buffer._putFloat32List(offsets);
    }
    buffer._putUint8(tileMode);
    return shaderId;
  }

  /// Write a radial gradient into the current buffer.
  ///
  /// [focalX] and [focalY] must be either both `null` or both `non-null`.
  int writeRadialGradient(
    VectorGraphicsBuffer buffer, {
    required double centerX,
    required double centerY,
    required double radius,
    required double? focalX,
    required double? focalY,
    required Int32List colors,
    required Float32List? offsets,
    required Float64List? transform,
    required int tileMode,
  }) {
    assert((focalX == null && focalY == null) ||
        (focalX != null && focalY != null));
    assert(transform == null || transform.length == 16);
    if (buffer._decodePhase.index > _CurrentSection.shaders.index) {
      throw StateError('Shaders must be encoded together.');
    }
    buffer._decodePhase = _CurrentSection.shaders;
    final int shaderId = buffer._nextShaderId++;
    assert(shaderId < kMaxId);
    buffer._putUint8(_radialGradientTag);
    buffer._putUint16(shaderId);
    buffer._putFloat32(centerX);
    buffer._putFloat32(centerY);
    buffer._putFloat32(radius);

    if (focalX != null) {
      buffer._putUint8(1);
      buffer._putFloat32(focalX);
      buffer._putFloat32(focalY!);
    } else {
      buffer._putUint8(0);
    }
    buffer._putUint16(colors.length);
    buffer._putInt32List(colors);
    if (offsets != null) {
      buffer._putUint16(offsets.length);
      buffer._putFloat32List(offsets);
    } else {
      buffer._putUint16(0);
    }
    if (transform != null) {
      buffer._putUint8(transform.length);
      buffer._putFloat64List(transform);
    } else {
      buffer._putUint8(0);
    }
    buffer._putUint8(tileMode);
    return shaderId;
  }

  /// Encode a paint object in the current buffer, returning the identifier
  /// assigned to it.
  ///
  /// [color] is the 32-bit ARBG color representation used by Flutter
  /// internally. The [strokeCap], [strokeJoin], [blendMode], [style]
  /// fields should be the index of the corresponding enumeration.
  ///
  /// This method is only used to write the paint used for fill commands.
  /// To write a paint used for a stroke command, see [writeStroke].
  int writeStroke(
    VectorGraphicsBuffer buffer,
    int color,
    int strokeCap,
    int strokeJoin,
    int blendMode,
    double strokeMiterLimit,
    double strokeWidth, [
    int? shaderId,
  ]) {
    if (buffer._decodePhase.index > _CurrentSection.paints.index) {
      throw StateError('Paints must be encoded together.');
    }
    buffer._decodePhase = _CurrentSection.paints;
    final int paintId = buffer._nextPaintId++;
    assert(paintId < kMaxId);
    buffer._putUint8(_strokePaintTag);
    buffer._putUint32(color);
    buffer._putUint8(strokeCap);
    buffer._putUint8(strokeJoin);
    buffer._putUint8(blendMode);
    buffer._putFloat32(strokeMiterLimit);
    buffer._putFloat32(strokeWidth);
    buffer._putUint16(paintId);
    buffer._putUint16(shaderId ?? kMaxId);
    return paintId;
  }

  void _readLinearGradient(
    _ReadBuffer buffer,
    VectorGraphicsCodecListener? listener,
  ) {
    final int id = buffer.getUint16();
    final double fromX = buffer.getFloat32();
    final double fromY = buffer.getFloat32();
    final double toX = buffer.getFloat32();
    final double toY = buffer.getFloat32();
    final int colorLength = buffer.getUint16();
    final Int32List colors = buffer.getInt32List(colorLength);
    final int offsetLength = buffer.getUint16();
    final Float32List offsets = buffer.getFloat32List(offsetLength);
    final int tileMode = buffer.getUint8();
    listener?.onLinearGradient(
      fromX,
      fromY,
      toX,
      toY,
      colors,
      offsets,
      tileMode,
      id,
    );
  }

  void _readRadialGradient(
    _ReadBuffer buffer,
    VectorGraphicsCodecListener? listener,
  ) {
    final int id = buffer.getUint16();
    final double centerX = buffer.getFloat32();
    final double centerY = buffer.getFloat32();
    final double radius = buffer.getFloat32();
    final int hasFocal = buffer.getUint8();
    double? focalX;
    double? focalY;
    if (hasFocal == 1) {
      focalX = buffer.getFloat32();
      focalY = buffer.getFloat32();
    }
    final int colorsLength = buffer.getUint16();
    final Int32List colors = buffer.getInt32List(colorsLength);
    final int offsetsLength = buffer.getUint16();
    final Float32List offsets = buffer.getFloat32List(offsetsLength);
    final int transformLength = buffer.getUint8();
    final Float64List? transform =
        transformLength != 0 ? buffer.getFloat64List(transformLength) : null;
    final int tileMode = buffer.getUint8();
    listener?.onRadialGradient(
      centerX,
      centerY,
      radius,
      focalX,
      focalY,
      colors,
      offsets,
      transform,
      tileMode,
      id,
    );
  }

  void _readFillPaint(
      _ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final int color = buffer.getUint32();
    final int blendMode = buffer.getUint8();
    final int id = buffer.getUint16();
    final int shaderId = buffer.getUint16();

    listener?.onPaintObject(
      color: color,
      strokeCap: null,
      strokeJoin: null,
      blendMode: blendMode,
      strokeMiterLimit: null,
      strokeWidth: null,
      paintStyle: 0, // Fill
      id: id,
      shaderId: shaderId == kMaxId ? null : shaderId,
    );
  }

  void _readStrokePaint(
      _ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final int color = buffer.getUint32();
    final int strokeCap = buffer.getUint8();
    final int strokeJoin = buffer.getUint8();
    final int blendMode = buffer.getUint8();
    final double strokeMiterLimit = buffer.getFloat32();
    final double strokeWidth = buffer.getFloat32();
    final int id = buffer.getUint16();
    final int shaderId = buffer.getUint16();

    listener?.onPaintObject(
      color: color,
      strokeCap: strokeCap,
      strokeJoin: strokeJoin,
      blendMode: blendMode,
      strokeMiterLimit: strokeMiterLimit,
      strokeWidth: strokeWidth,
      paintStyle: 1, // Stroke
      id: id,
      shaderId: shaderId == kMaxId ? null : shaderId,
    );
  }

  /// Begin writing a new path to the [buffer], returing the identifier
  /// assigned to it.
  ///
  /// The [fillType] argument is either `1` for a fill or `0` for a stroke.
  ///
  /// Throws a [StateError] if there is already an active path.
  int writeStartPath(VectorGraphicsBuffer buffer, int fillType) {
    if (buffer._currentPathId != -1) {
      throw StateError('There is already an active Path.');
    }
    if (buffer._decodePhase.index > _CurrentSection.paths.index) {
      throw StateError('Paths must be encoded together');
    }
    buffer._decodePhase = _CurrentSection.paths;
    buffer._currentPathId = buffer._nextPathId++;
    assert(buffer._nextPathId < kMaxId);
    buffer._putUint8(_pathTag);
    buffer._putUint8(fillType);
    buffer._putUint16(buffer._currentPathId);
    return buffer._currentPathId;
  }

  /// Write a move to command to the global coordinate ([x], [y]).
  ///
  /// Throws a [StateError] if there is not an active path.
  void writeMoveTo(VectorGraphicsBuffer buffer, double x, double y) {
    if (buffer._currentPathId == -1) {
      throw StateError('There is no active Path.');
    }
    buffer._putUint8(_moveToTag);
    buffer._putFloat32(x);
    buffer._putFloat32(y);
  }

  /// Write a line to command to the global coordinate ([x], [y]).
  ///
  /// Throws a [StateError] if there is not an active path.
  void writeLineTo(VectorGraphicsBuffer buffer, double x, double y) {
    if (buffer._currentPathId == -1) {
      throw StateError('There is no active Path.');
    }
    buffer._putUint8(_lineToTag);
    buffer._putFloat32(x);
    buffer._putFloat32(y);
  }

  /// Write an arc to command to the global coordinate ([x1], [y1]) with control
  /// points CP1 ([x2], [y2]) and CP2 ([x3], [y3]).
  ///
  /// Throws a [StateError] if there is not an active path.
  void writeCubicTo(VectorGraphicsBuffer buffer, double x1, double y1,
      double x2, double y2, double x3, double y3) {
    if (buffer._currentPathId == -1) {
      throw StateError('There is no active Path.');
    }
    buffer._putUint8(_cubicToTag);
    buffer._putFloat32(x1);
    buffer._putFloat32(y1);
    buffer._putFloat32(x2);
    buffer._putFloat32(y2);
    buffer._putFloat32(x3);
    buffer._putFloat32(y3);
  }

  /// Write a close command to the current path.
  ///
  /// Throws a [StateError] if there is not an active path.
  void writeClose(VectorGraphicsBuffer buffer) {
    if (buffer._currentPathId == -1) {
      throw StateError('There is no active Path.');
    }
    buffer._putUint8(_closeTag);
  }

  /// Finishes building the current path
  ///
  /// Throws a [StateError] if there is not an active path.
  void writeFinishPath(VectorGraphicsBuffer buffer) {
    if (buffer._currentPathId == -1) {
      throw StateError('There is no active Path.');
    }
    buffer._putUint8(_finishPathTag);
    buffer._currentPathId = -1;
  }

  /// Saves a copy of the current transform and clip on the save stack, and then
  /// creates a new group which subsequent calls will become a part of. When the
  /// save stack is later popped, the group will be flattened into a layer and
  /// have the given `paint`'s [Paint.blendMode] applied.
  ///
  /// See also:
  ///   * [Canvas.saveLayer]
  void writeSaveLayer(VectorGraphicsBuffer buffer, int paint) {
    buffer._putUint8(_saveLayerTag);
    buffer._putUint16(paint);
  }

  /// Pops the current save stack, if there is anything to pop.
  /// Otherwise, does nothing.
  ///
  /// See also:
  ///   * [Canvas.restore]
  void writeRestoreLayer(VectorGraphicsBuffer buffer) {
    buffer._putUint8(_restoreTag);
  }

  /// Write the [text] contents given starting at [x], [y].
  ///
  /// [x], [y] are the coordinates of the starting point of the text baseline.
  int writeTextConfig({
    required VectorGraphicsBuffer buffer,
    required String text,
    required String? fontFamily,
    required double x,
    required double y,
    required int fontWeight,
    required double fontSize,
  }) {
    if (buffer._decodePhase.index > _CurrentSection.text.index) {
      throw StateError('Text config must be encoded together.');
    }
    buffer._decodePhase = _CurrentSection.text;
    final int textId = buffer._nextTextId++;
    assert(textId < kMaxId);

    buffer._putUint8(_textConfigTag);
    buffer._putUint16(textId);
    buffer._putFloat32(x);
    buffer._putFloat32(y);
    buffer._putFloat32(fontSize);
    buffer._putUint8(fontWeight);

    // font-family
    if (fontFamily != null) {
      final Uint8List encoded = utf8.encode(fontFamily) as Uint8List;
      buffer._putUint16(encoded.length);
      buffer._putUint8List(encoded);
    } else {
      buffer._putUint16(0);
    }

    // text-value
    final Uint8List encoded = utf8.encode(text) as Uint8List;
    buffer._putUint16(encoded.length);
    buffer._putUint8List(encoded);

    return textId;
  }

  void writeDrawText(
    VectorGraphicsBuffer buffer,
    int textId,
    int paintId,
  ) {
    buffer._putUint8(_drawTextTag);
    buffer._putUint16(textId);
    buffer._putUint16(paintId);
  }

  void writeClipPath(VectorGraphicsBuffer buffer, int path) {
    buffer._putUint8(_clipPathTag);
    buffer._putUint16(path);
  }

  void writeMask(VectorGraphicsBuffer buffer) {
    buffer._putUint8(_maskTag);
  }

  void _readPath(_ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final int fillType = buffer.getUint8();
    final int id = buffer.getUint16();
    listener?.onPathStart(id, fillType);
  }

  void _readMoveTo(_ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final double x = buffer.getFloat32();
    final double y = buffer.getFloat32();
    listener?.onPathMoveTo(x, y);
  }

  void _readLineTo(_ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final double x = buffer.getFloat32();
    final double y = buffer.getFloat32();
    listener?.onPathLineTo(x, y);
  }

  void _readCubicTo(_ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final double x1 = buffer.getFloat32();
    final double y1 = buffer.getFloat32();
    final double x2 = buffer.getFloat32();
    final double y2 = buffer.getFloat32();
    final double x3 = buffer.getFloat32();
    final double y3 = buffer.getFloat32();
    listener?.onPathCubicTo(x1, y1, x2, y2, x3, y3);
  }

  void _readClose(_ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    listener?.onPathClose();
  }

  void _readDrawPath(
      _ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final int pathId = buffer.getUint16();
    final int paintId = buffer.getUint16();
    listener?.onDrawPath(pathId, paintId);
  }

  void _readDrawVertices(
      _ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final int paintId = buffer.getUint16();
    final int verticesLength = buffer.getUint16();
    final Float32List vertices = buffer.getFloat32List(verticesLength);
    final int indexLength = buffer.getUint16();
    Uint16List? indices;
    if (indexLength != 0) {
      indices = buffer.getUint16List(indexLength);
    }
    listener?.onDrawVertices(
        vertices, indices, paintId != kMaxId ? paintId : null);
  }

  void _readSaveLayer(
    _ReadBuffer buffer,
    VectorGraphicsCodecListener? listener,
  ) {
    final int paintId = buffer.getUint16();
    listener?.onSaveLayer(paintId);
  }

  void _readClipPath(
    _ReadBuffer buffer,
    VectorGraphicsCodecListener? listener,
  ) {
    final int pathId = buffer.getUint16();
    listener?.onClipPath(pathId);
  }

  void _readSize(_ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final double width = buffer.getFloat32();
    final double height = buffer.getFloat32();
    listener?.onSize(width, height);
  }

  void _readTextConfig(
    _ReadBuffer buffer,
    VectorGraphicsCodecListener? listener,
  ) {
    final int id = buffer.getUint16();
    final double dx = buffer.getFloat32();
    final double dy = buffer.getFloat32();
    final double fontSize = buffer.getFloat32();
    final int fontWeight = buffer.getUint8();
    String? fontFamily;
    final int fontFamilyLength = buffer.getUint16();
    if (fontFamilyLength > 0) {
      fontFamily = utf8.decode(buffer.getUint8List(fontFamilyLength));
    }
    final int textLength = buffer.getUint16();
    final String text = utf8.decode(buffer.getUint8List(textLength));

    listener?.onTextConfig(text, fontFamily, dx, dy, fontWeight, fontSize, id);
  }

  void _readDrawText(
      _ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final int textId = buffer.getUint16();
    final int paintId = buffer.getUint16();
    listener?.onDrawText(textId, paintId);
  }
}

/// Implement this listener class to support decoding of vector_graphics binary
/// assets.
abstract class VectorGraphicsCodecListener {
  /// The size of the vector graphic has been decoded.
  void onSize(
    double width,
    double height,
  );

  /// A paint object has been decoded.
  ///
  /// If the paint object is for a fill, then [strokeCap], [strokeJoin],
  /// [strokeMiterLimit], and [strokeWidget] will be `null`.
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
  });

  /// A path object is being created, with the given [id] and [fillType].
  ///
  /// All subsequent path commands will refer to this path, until
  /// [onPathFinished] is invoked.
  void onPathStart(int id, int fillType);

  /// A path object should move to (x, y).
  void onPathMoveTo(double x, double y);

  /// A path object should line to (x, y).
  void onPathLineTo(double x, double y);

  /// A path object will draw a cubic to (x1, y1), with control point 1 as
  /// (x2, y2) and control point 2 as (x3, y3).
  void onPathCubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3);

  /// The current path has been closed.
  void onPathClose();

  /// The current path is completed.
  void onPathFinished();

  /// Draw the given [pathId] with the given [paintId].
  ///
  /// If the [paintId] is `null`, a default empty paint should be used instead.
  void onDrawPath(
    int pathId,
    int? paintId,
  );

  /// Draw the vertices with the given [vertices] and optionally index buffer
  /// [indices].
  ///
  /// If the [paintId] is `null`, a default empty paint should be used instead.
  void onDrawVertices(
    Float32List vertices,
    Uint16List? indices,
    int? paintId,
  );

  /// Save a new layer with the given [paintId].
  void onSaveLayer(int paintId);

  /// Apply the specified paths as clips to the current canvas.
  void onClipPath(int pathId);

  /// Restore the save stack.
  void onRestoreLayer();

  /// Prepare to draw a new mask, until the next [onRestoreLayer] command.
  void onMask();

  /// A radial gradient shader has been parsed.
  ///
  /// [focalX] and [focalY] are either both `null` or `non-null`.
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
  );

  /// A linear gradient shader has been parsed.
  void onLinearGradient(
    double fromX,
    double fromY,
    double toX,
    double toY,
    Int32List colors,
    Float32List? offsets,
    int tileMode,
    int id,
  );

  /// A text configuration block has been decoded.
  void onTextConfig(
    String text,
    String? fontFamily,
    double x,
    double y,
    int fontWeight,
    double fontSize,
    int id,
  );

  /// A text block has been decoded.
  void onDrawText(
    int textId,
    int paintId,
  );
}

enum _CurrentSection {
  size,
  shaders,
  paints,
  paths,
  text,
  commands,
}

/// Write-only buffer for incrementally building a [ByteData] instance.
///
/// A [VectorGraphicsBuffer] instance can be used only once. Attempts to reuse will result
/// in [StateError]s being thrown.
///
/// The byte order used is [Endian.host] throughout.
class VectorGraphicsBuffer {
  /// Creates an interface for incrementally building a [ByteData] instance.
  VectorGraphicsBuffer()
      : _buffer = <int>[],
        _isDone = false,
        _eightBytes = ByteData(8) {
    _eightBytesAsList = _eightBytes.buffer.asUint8List();
    // Begin message with the magic number and current version.
    _putUint32(VectorGraphicsCodec._magicNumber);
    _putUint8(VectorGraphicsCodec._version);
  }

  List<int> _buffer;
  bool _isDone;
  final ByteData _eightBytes;
  late Uint8List _eightBytesAsList;
  static final Uint8List _zeroBuffer = Uint8List(8);

  /// The next paint id to be used.
  int _nextPaintId = 0;

  /// The next path id to be used.
  int _nextPathId = 0;

  /// The next shader id to be used.
  int _nextShaderId = 0;

  /// The next text id to be used.
  int _nextTextId = 0;

  /// The current id of the path being built, or `-1` if there is no
  /// active path.
  int _currentPathId = -1;

  /// The current decoding phase.
  ///
  /// Objects must be written in the correct order, the same as the
  /// enum order.
  _CurrentSection _decodePhase = _CurrentSection.size;

  /// Write a Uint8 into the buffer.
  void _putUint8(int byte) {
    assert(!_isDone);
    _buffer.add(byte);
  }

  void _putUint16(int value, {Endian? endian}) {
    assert(!_isDone);
    _eightBytes.setUint16(0, value, endian ?? Endian.host);
    _buffer.addAll(_eightBytesAsList.take(2));
  }

  /// Write a Uint32 into the buffer.
  void _putUint32(int value, {Endian? endian}) {
    assert(!_isDone);
    _eightBytes.setUint32(0, value, endian ?? Endian.host);
    _buffer.addAll(_eightBytesAsList.take(4));
  }

  /// Write an Int32List into the buffer.
  void _putInt32List(Int32List list) {
    assert(!_isDone);
    _alignTo(4);
    _buffer
        .addAll(list.buffer.asUint8List(list.offsetInBytes, 4 * list.length));
  }

  /// Write an Float32 into the buffer.
  void _putFloat32(double value, {Endian? endian}) {
    assert(!_isDone);
    _alignTo(4);
    _eightBytes.setFloat32(0, value, endian ?? Endian.host);
    _buffer.addAll(_eightBytesAsList.take(4));
  }

  void _putUint8List(Uint8List list) {
    assert(!_isDone);
    _buffer.addAll(list.buffer.asUint8List(list.offsetInBytes, list.length));
  }

  void _putUint16List(Uint16List list) {
    assert(!_isDone);
    _alignTo(2);
    _buffer
        .addAll(list.buffer.asUint8List(list.offsetInBytes, 2 * list.length));
  }

  /// Write all the values from a [Float32List] into the buffer.
  void _putFloat32List(Float32List list) {
    assert(!_isDone);
    _alignTo(4);
    _buffer
        .addAll(list.buffer.asUint8List(list.offsetInBytes, 4 * list.length));
  }

  void _putFloat64List(Float64List list) {
    assert(!_isDone);
    _alignTo(8);
    _buffer
        .addAll(list.buffer.asUint8List(list.offsetInBytes, 8 * list.length));
  }

  void _alignTo(int alignment) {
    assert(!_isDone);
    final int mod = _buffer.length % alignment;
    if (mod != 0) {
      _buffer.addAll(_zeroBuffer.take(alignment - mod));
    }
  }

  /// Finalize and return the written [ByteData].
  ByteData done() {
    if (_isDone) {
      throw StateError(
          'done() must not be called more than once on the same VectorGraphicsBuffer.');
    }
    final ByteData result = Uint8List.fromList(_buffer).buffer.asByteData();
    _buffer = <int>[];
    _isDone = true;
    return result;
  }
}

/// Read-only buffer for reading sequentially from a [ByteData] instance.
///
/// The byte order used is [Endian.host] throughout.
class _ReadBuffer {
  /// Creates a [_ReadBuffer] for reading from the specified [data].
  _ReadBuffer(this.data);

  /// The underlying data being read.
  final ByteData data;

  /// The position to read next.
  int _position = 0;

  /// Whether the buffer has data remaining to read.
  bool get hasRemaining => _position < data.lengthInBytes;

  /// Reads a Uint8 from the buffer.
  int getUint8() {
    return data.getUint8(_position++);
  }

  /// Reads a Uint16 from the buffer.
  int getUint16({Endian? endian}) {
    final int value = data.getUint16(_position, endian ?? Endian.host);
    _position += 2;
    return value;
  }

  /// Reads a Uint32 from the buffer.
  int getUint32({Endian? endian}) {
    final int value = data.getUint32(_position, endian ?? Endian.host);
    _position += 4;
    return value;
  }

  /// Reads an Int32 from the buffer.
  int getInt32({Endian? endian}) {
    final int value = data.getInt32(_position, endian ?? Endian.host);
    _position += 4;
    return value;
  }

  /// Reads an Int64 from the buffer.
  int getInt64({Endian? endian}) {
    final int value = data.getInt64(_position, endian ?? Endian.host);
    _position += 8;
    return value;
  }

  /// Reads a Float32 from the buffer.
  double getFloat32({Endian? endian}) {
    _alignTo(4);
    final double value = data.getFloat32(_position, endian ?? Endian.host);
    _position += 4;
    return value;
  }

  /// Reads a Float64 from the buffer.
  double getFloat64({Endian? endian}) {
    _alignTo(8);
    final double value = data.getFloat64(_position, endian ?? Endian.host);
    _position += 8;
    return value;
  }

  /// Reads the given number of Uint8s from the buffer.
  Uint8List getUint8List(int length) {
    final Uint8List list =
        data.buffer.asUint8List(data.offsetInBytes + _position, length);
    _position += length;
    return list;
  }

  Uint16List getUint16List(int length) {
    _alignTo(2);
    final Uint16List list =
        data.buffer.asUint16List(data.offsetInBytes + _position, length);
    _position += 2 * length;
    return list;
  }

  /// Reads the given number of Int32s from the buffer.
  Int32List getInt32List(int length) {
    _alignTo(4);
    final Int32List list =
        data.buffer.asInt32List(data.offsetInBytes + _position, length);
    _position += 4 * length;
    return list;
  }

  /// Reads the given number of Int64s from the buffer.
  Int64List getInt64List(int length) {
    _alignTo(8);
    final Int64List list =
        data.buffer.asInt64List(data.offsetInBytes + _position, length);
    _position += 8 * length;
    return list;
  }

  /// Reads the given number of Float32s from the buffer
  Float32List getFloat32List(int length) {
    _alignTo(4);
    final Float32List list =
        data.buffer.asFloat32List(data.offsetInBytes + _position, length);
    _position += 4 * length;
    return list;
  }

  /// Reads the given number of Float64s from the buffer.
  Float64List getFloat64List(int length) {
    _alignTo(8);
    final Float64List list =
        data.buffer.asFloat64List(data.offsetInBytes + _position, length);
    _position += 8 * length;
    return list;
  }

  void _alignTo(int alignment) {
    final int mod = _position % alignment;
    if (mod != 0) _position += alignment - mod;
  }
}
