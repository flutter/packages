// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'src/fp16.dart' as fp16;

// TODO(stuartmorgan): Fix the lack of documentation, and remove this. See
//  https://github.com/flutter/flutter/issues/157616
// ignore_for_file: public_member_api_docs

/// enumeration of the types of control points accepted by [VectorGraphicsCodec.writePath].
abstract class ControlPointTypes {
  const ControlPointTypes._();

  static const int moveTo = 0;
  static const int lineTo = 1;
  static const int cubicTo = 2;
  static const int close = 3;
}

// See definitions in dart:ui's TextDecoration.

/// The mask used to clear text decorations.
const int kNoTextDecorationMask = 0x0;

/// The mask for an underline text decoration.
const int kUnderlineMask = 0x1;

/// The mask constant for an overline text decoration.
const int kOverlineMask = 0x2;

/// The mask constant for a line through or strike text decoration.
const int kLineThroughMask = 0x4;

/// The signature for an error callback if an error occurs during image
/// decoding.
///
/// See [VectorGraphicsCodecListener.onImage].
typedef VectorGraphicsErrorListener = void Function(
  Object error,
  StackTrace? stackTrace,
);

/// Enumeration of the types of image data accepted by [VectorGraphicsCodec.writeImage].
///
// Must match ImageFormat from vector_graphics_compiler.
abstract class ImageFormatTypes {
  /// PNG format.
  ///
  /// A loss-less compression format for images. This format is well suited for
  /// images with hard edges, such as screenshots or sprites, and images with
  /// text. Transparency is supported. The PNG format supports images up to
  /// 2,147,483,647 pixels in either dimension, though in practice available
  /// memory provides a more immediate limitation on maximum image size.
  ///
  /// PNG images normally use the `.png` file extension and the `image/png` MIME
  /// type.
  ///
  /// See also:
  ///
  ///  * <https://en.wikipedia.org/wiki/Portable_Network_Graphics>, the Wikipedia page on PNG.
  ///  * <https://tools.ietf.org/rfc/rfc2083.txt>, the PNG standard.
  static const int png = 0;

  /// A JPEG format image.
  ///
  /// This library does not support JPEG 2000.
  static const int jpeg = 1;

  /// A WebP format image.
  static const int webp = 2;

  /// A Graphics Interchange Format image.
  static const int gif = 3;

  /// A Windows Bitmap format image.
  static const int bmp = 4;

  static const List<int> values = <int>[png, jpeg, webp, gif, bmp];
}

class DecodeResponse {
  // TODO(stuartmorgan): Fix this use of a private type in public API (likely
  //  the constructor should be private).
  // ignore: library_private_types_in_public_api
  const DecodeResponse(this.complete, this._buffer);

  final bool complete;
  final _ReadBuffer? _buffer;
}

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
  static const int _saveLayerTag = 37;
  static const int _restoreTag = 38;
  static const int _linearGradientTag = 39;
  static const int _radialGradientTag = 40;
  static const int _sizeTag = 41;
  static const int _clipPathTag = 42;
  static const int _maskTag = 43;
  static const int _drawTextTag = 44;
  static const int _textConfigTag = 45;
  static const int _imageConfigTag = 46;
  static const int _drawImageTag = 47;
  static const int _beginCommandsTag = 48;
  static const int _patternTag = 49;
  static const int _textPositionTag = 50;
  static const int _updateTextPositionTag = 51;
  static const int _pathTagHalfPrecision = 52;

  static const int _version = 1;
  static const int _magicNumber = 0x00882d62;

  /// Decode the vector_graphics binary.
  ///
  /// Without a provided [VectorGraphicsCodecListener], this method will only
  /// validate the basic structure of an object. decoders that wish to construct
  /// a dart:ui Picture object should implement [VectorGraphicsCodecListener].
  ///
  /// Throws a [StateError] If the message is invalid.
  DecodeResponse decode(ByteData data, VectorGraphicsCodecListener? listener,
      {DecodeResponse? response}) {
    final _ReadBuffer buffer;
    if (response == null) {
      buffer = _ReadBuffer(data);
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
    } else {
      buffer = response._buffer!;
    }

    bool readImage = false;
    while (buffer.hasRemaining) {
      final int type = buffer.getUint8();
      switch (type) {
        case _beginCommandsTag:
          if (readImage) {
            return DecodeResponse(false, buffer);
          }
          continue;
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
          _readPath(buffer, listener, half: false);
          continue;
        case _pathTagHalfPrecision:
          _readPath(buffer, listener, half: true);
          continue;
        case _drawPathTag:
          _readDrawPath(buffer, listener);
          continue;
        case _drawVerticesTag:
          _readDrawVertices(buffer, listener);
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
        case _imageConfigTag:
          readImage = true;
          _readImageConfig(buffer, listener);
          continue;
        case _drawImageTag:
          _readDrawImage(buffer, listener);
          continue;
        case _patternTag:
          _readPattern(buffer, listener);
          continue;
        case _textPositionTag:
          _readTextPosition(buffer, listener);
          continue;
        case _updateTextPositionTag:
          _readUpdateTextPosition(buffer, listener);
          continue;
        default:
          throw StateError('Unknown type tag $type');
      }
    }
    return const DecodeResponse(true, null);
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
    buffer._decodePhase = _CurrentSection.images;
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
    int? patternId,
  ) {
    buffer._checkPhase(_CurrentSection.commands);
    buffer._addCommandsTag();

    buffer._putUint8(_drawPathTag);
    buffer._putUint16(pathId);
    buffer._putUint16(paintId);
    buffer._putUint16(patternId ?? kMaxId);
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
    buffer._checkPhase(_CurrentSection.commands);
    buffer._addCommandsTag();

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
    buffer._checkPhase(_CurrentSection.paints);

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
    buffer._checkPhase(_CurrentSection.shaders);

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
    buffer._checkPhase(_CurrentSection.shaders);

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
    buffer._writeTransform(transform);
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
    buffer._checkPhase(_CurrentSection.paints);
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
    final Float64List? transform = buffer.getTransform();
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

  /// Saves a copy of the current transform and clip on the save stack, and then
  /// creates a new group which subsequent calls will become a part of. When the
  /// save stack is later popped, the group will be flattened into a layer and
  /// have the given `paint`'s [Paint.blendMode] applied.
  ///
  /// See also:
  ///   * [Canvas.saveLayer]
  void writeSaveLayer(VectorGraphicsBuffer buffer, int paint) {
    buffer._checkPhase(_CurrentSection.commands);
    buffer._addCommandsTag();

    buffer._putUint8(_saveLayerTag);
    buffer._putUint16(paint);
  }

  /// Pops the current save stack, if there is anything to pop.
  /// Otherwise, does nothing.
  ///
  /// See also:
  ///   * [Canvas.restore]
  void writeRestoreLayer(VectorGraphicsBuffer buffer) {
    buffer._checkPhase(_CurrentSection.commands);
    buffer._addCommandsTag();
    buffer._putUint8(_restoreTag);
  }

  /// Write the [text] contents given starting at [x], [y].
  int writeTextConfig({
    required VectorGraphicsBuffer buffer,
    required String text,
    required String? fontFamily,
    required double xAnchorMultiplier,
    required int fontWeight,
    required double fontSize,
    required int decoration,
    required int decorationStyle,
    required int decorationColor,
  }) {
    buffer._checkPhase(_CurrentSection.text);

    final int textId = buffer._nextTextId++;
    assert(textId < kMaxId);

    buffer._putUint8(_textConfigTag);
    buffer._putUint16(textId);
    buffer._putFloat32(xAnchorMultiplier);
    buffer._putFloat32(fontSize);
    buffer._putUint8(fontWeight);
    buffer._putUint8(decoration);
    buffer._putUint8(decorationStyle);
    buffer._putUint32(decorationColor);

    // font-family
    if (fontFamily != null) {
      // Newer versions of Dart will make this a Uint8List and not require the cast.
      // ignore: unnecessary_cast
      final Uint8List encoded = utf8.encode(fontFamily) as Uint8List;
      buffer._putUint16(encoded.length);
      buffer._putUint8List(encoded);
    } else {
      buffer._putUint16(0);
    }

    // text-value
    // Newer versions of Dart will make this a Uint8List and not require the cast.
    // ignore: unnecessary_cast
    final Uint8List encoded = utf8.encode(text) as Uint8List;
    buffer._putUint16(encoded.length);
    buffer._putUint8List(encoded);

    return textId;
  }

  void writeDrawText(
    VectorGraphicsBuffer buffer,
    int textId,
    int? fillId,
    int? strokeId,
    int? patternId,
  ) {
    assert(fillId != null || strokeId != null);
    buffer._checkPhase(_CurrentSection.commands);
    buffer._addCommandsTag();
    buffer._putUint8(_drawTextTag);
    buffer._putUint16(textId);
    buffer._putUint16(fillId ?? kMaxId);
    buffer._putUint16(strokeId ?? kMaxId);
    buffer._putUint16(patternId ?? kMaxId);
  }

  void writeTextPosition(
    VectorGraphicsBuffer buffer,
    double? x,
    double? y,
    double? dx,
    double? dy,
    bool reset,
    Float64List? transform,
  ) {
    buffer._checkPhase(_CurrentSection.textPositions);
    final int id = buffer._nextTextPositionId++;
    assert(id < kMaxId);

    buffer._putUint8(_textPositionTag);
    buffer._putUint16(id);

    buffer._putFloat32(x ?? double.nan);
    buffer._putFloat32(y ?? double.nan);
    buffer._putFloat32(dx ?? double.nan);
    buffer._putFloat32(dy ?? double.nan);
    buffer._putUint8(reset ? 1 : 0);
    buffer._writeTransform(transform);
  }

  void writeUpdateTextPosition(
      VectorGraphicsBuffer buffer, int textPositionId) {
    buffer._checkPhase(_CurrentSection.commands);
    buffer._addCommandsTag();
    buffer._putUint8(_updateTextPositionTag);
    buffer._putUint16(textPositionId);
  }

  void writeClipPath(VectorGraphicsBuffer buffer, int path) {
    buffer._checkPhase(_CurrentSection.commands);
    buffer._addCommandsTag();
    buffer._putUint8(_clipPathTag);
    buffer._putUint16(path);
  }

  void writeMask(VectorGraphicsBuffer buffer) {
    buffer._checkPhase(_CurrentSection.commands);
    buffer._addCommandsTag();
    buffer._putUint8(_maskTag);
  }

  int writePattern(
    VectorGraphicsBuffer buffer,
    double x,
    double y,
    double width,
    double height,
    Float64List transform,
  ) {
    buffer._checkPhase(_CurrentSection.commands);
    assert(buffer._nextPatternId < kMaxId);
    final int id = buffer._nextPatternId;
    buffer._nextPatternId += 1;
    buffer._putUint8(_patternTag);
    buffer._putUint16(id);
    buffer._putFloat32(x);
    buffer._putFloat32(y);
    buffer._putFloat32(width);
    buffer._putFloat32(height);
    buffer._writeTransform(transform);
    return id;
  }

  /// Write a new path to the [buffer], returing the identifier
  /// assigned to it.
  ///
  /// The [fillType] argument is either `1` for a fill or `0` for a stroke.
  ///
  /// [controlTypes] is a buffer of the types of control points in order.
  /// [controlPoints] is a buffer of the control points in order.
  ///
  /// If [half] is true, control points will be written to the buffer using
  /// half precision floating point values. This will reduce the binary
  /// size at the cost of reduced precision. This option defaults to `false`.
  int writePath(
    VectorGraphicsBuffer buffer,
    Uint8List controlTypes,
    Float32List controlPoints,
    int fillType, {
    bool half = false,
  }) {
    buffer._checkPhase(_CurrentSection.paths);
    assert(buffer._nextPathId < kMaxId);

    final int id = buffer._nextPathId;
    buffer._nextPathId += 1;

    buffer._putUint8(half ? _pathTagHalfPrecision : _pathTag);
    buffer._putUint8(fillType);
    buffer._putUint16(id);
    buffer._putUint32(controlTypes.length);
    buffer._putUint8List(controlTypes);
    buffer._putUint32(controlPoints.length);
    if (half) {
      buffer._putUint16List(_encodeToHalfPrecision(controlPoints));
    } else {
      buffer._putFloat32List(controlPoints);
    }
    return id;
  }

  Uint16List _encodeToHalfPrecision(Float32List list) {
    final Uint16List output = Uint16List(list.length);
    final ByteData buffer = ByteData(8);
    for (int i = 0; i < list.length; i++) {
      buffer.setFloat32(0, list[i]);
      fp16.toHalf(buffer);
      output[i] = buffer.getInt16(0);
    }
    return output;
  }

  Float32List _decodeFromHalfPrecision(Uint16List list) {
    final Float32List output = Float32List(list.length);
    final ByteData buffer = ByteData(8);
    for (int i = 0; i < list.length; i++) {
      buffer.setUint16(0, list[i]);
      output[i] = fp16.toDouble(buffer);
    }
    return output;
  }

  /// Write an image to the [buffer], returning the identifier
  /// assigned to it.
  ///
  /// The [data] argument should be the image data encoded according
  /// to the [format] argument. Currently only PNG is supported.
  int writeImage(
    VectorGraphicsBuffer buffer,
    int format,
    Uint8List data,
  ) {
    buffer._checkPhase(_CurrentSection.images);
    assert(buffer._nextImageId < kMaxId);
    assert(ImageFormatTypes.values.contains(format));

    final int id = buffer._nextImageId;
    buffer._nextImageId += 1;

    buffer._putUint8(_imageConfigTag);
    buffer._putUint16(id);
    buffer._putUint8(format);
    buffer._putUint32(data.length);
    buffer._putUint8List(data);
    return id;
  }

  void writeDrawImage(
    VectorGraphicsBuffer buffer,
    int imageId,
    double x,
    double y,
    double width,
    double height,
    Float64List? transform,
  ) {
    buffer._checkPhase(_CurrentSection.commands);
    buffer._addCommandsTag();
    assert(width > 0 && height > 0);

    buffer._putUint8(_drawImageTag);
    buffer._putUint16(imageId);
    buffer._putFloat32(x);
    buffer._putFloat32(y);
    buffer._putFloat32(width);
    buffer._putFloat32(height);
    buffer._writeTransform(transform);
  }

  void _readPath(
    _ReadBuffer buffer,
    VectorGraphicsCodecListener? listener, {
    required bool half,
  }) {
    final int fillType = buffer.getUint8();
    final int id = buffer.getUint16();
    final int tagLength = buffer.getUint32();
    final Uint8List tags = buffer.getUint8List(tagLength);
    final int pointLength = buffer.getUint32();
    final Float32List points;
    if (half) {
      points = _decodeFromHalfPrecision(buffer.getUint16List(pointLength));
    } else {
      points = buffer.getFloat32List(pointLength);
    }
    listener?.onPathStart(id, fillType);
    for (int i = 0, j = 0; i < tagLength; i += 1) {
      switch (tags[i]) {
        case ControlPointTypes.moveTo:
          listener?.onPathMoveTo(points[j], points[j + 1]);
          j += 2;
          continue;
        case ControlPointTypes.lineTo:
          listener?.onPathLineTo(points[j], points[j + 1]);
          j += 2;
          continue;
        case ControlPointTypes.cubicTo:
          listener?.onPathCubicTo(
            points[j],
            points[j + 1],
            points[j + 2],
            points[j + 3],
            points[j + 4],
            points[j + 5],
          );
          j += 6;
          continue;
        case ControlPointTypes.close:
          listener?.onPathClose();
          continue;
        default:
          assert(false);
      }
    }
    listener?.onPathFinished();
  }

  void _readDrawPath(
    _ReadBuffer buffer,
    VectorGraphicsCodecListener? listener,
  ) {
    final int pathId = buffer.getUint16();
    final int paintId = buffer.getUint16();
    int? patternId = buffer.getUint16();
    if (patternId == kMaxId) {
      patternId = null;
    }
    listener?.onDrawPath(pathId, paintId, patternId);
  }

  void _readDrawVertices(
    _ReadBuffer buffer,
    VectorGraphicsCodecListener? listener,
  ) {
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

  void _readTextPosition(
      _ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final int id = buffer.getUint16();
    final double x = buffer.getFloat32();
    final double y = buffer.getFloat32();
    final double dx = buffer.getFloat32();
    final double dy = buffer.getFloat32();

    final bool reset = buffer.getUint8() != 0;
    final Float64List? transform = buffer.getTransform();

    listener?.onTextPosition(
      id,
      x.isNaN ? null : x,
      y.isNaN ? null : y,
      dx.isNaN ? null : dx,
      dy.isNaN ? null : dy,
      reset,
      transform,
    );
  }

  void _readUpdateTextPosition(
    _ReadBuffer buffer,
    VectorGraphicsCodecListener? listener,
  ) {
    final int textPositionId = buffer.getUint16();
    listener?.onUpdateTextPosition(textPositionId);
  }

  void _readTextConfig(
    _ReadBuffer buffer,
    VectorGraphicsCodecListener? listener,
  ) {
    final int id = buffer.getUint16();
    final double xAnchorMultiplier = buffer.getFloat32();
    final double fontSize = buffer.getFloat32();
    final int fontWeight = buffer.getUint8();
    final int decoration = buffer.getUint8();
    final int decorationStyle = buffer.getUint8();
    final int decorationColor = buffer.getUint32();
    String? fontFamily;
    final int fontFamilyLength = buffer.getUint16();
    if (fontFamilyLength > 0) {
      fontFamily = utf8.decode(buffer.getUint8List(fontFamilyLength));
    }
    final int textLength = buffer.getUint16();
    final String text = utf8.decode(buffer.getUint8List(textLength));

    listener?.onTextConfig(
      text,
      fontFamily,
      xAnchorMultiplier,
      fontWeight,
      fontSize,
      decoration,
      decorationStyle,
      decorationColor,
      id,
    );
  }

  void _readDrawText(
    _ReadBuffer buffer,
    VectorGraphicsCodecListener? listener,
  ) {
    final int textId = buffer.getUint16();
    int? fillId = buffer.getUint16();
    if (fillId == kMaxId) {
      fillId = null;
    }
    int? strokeId = buffer.getUint16();
    if (strokeId == kMaxId) {
      strokeId = null;
    }
    assert(fillId != null || strokeId != null);
    int? patternId = buffer.getUint16();
    if (patternId == kMaxId) {
      patternId = null;
    }
    listener?.onDrawText(textId, fillId, strokeId, patternId);
  }

  void _readImageConfig(
      _ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final int id = buffer.getUint16();
    final int format = buffer.getUint8();
    final int dataLength = buffer.getUint32();
    final Uint8List data = buffer.getUint8List(dataLength);
    listener?.onImage(id, format, data);
  }

  void _readDrawImage(
      _ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final int id = buffer.getUint16();
    final double x = buffer.getFloat32();
    final double y = buffer.getFloat32();
    final double width = buffer.getFloat32();
    final double height = buffer.getFloat32();
    final Float64List? transformLength = buffer.getTransform();

    listener?.onDrawImage(id, x, y, width, height, transformLength);
  }

  void _readPattern(_ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final int patternId = buffer.getUint16();
    final double x = buffer.getFloat32();
    final double y = buffer.getFloat32();
    final double width = buffer.getFloat32();
    final double height = buffer.getFloat32();
    final Float64List? transform = buffer.getTransform();
    listener?.onPatternStart(patternId, x, y, width, height, transform!);
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
    int? patternId,
  );

  /// Draw the vertices with the given [vertices] and optionally index buffer
  /// [indices].
  ///
  /// If the [paintId] is `null`, a default empty paint should be used instead.
  void onDrawVertices(Float32List vertices, Uint16List? indices, int? paintId);

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
    double xAnchorMultiplier,
    int fontWeight,
    double fontSize,
    int decoration,
    int decorationStyle,
    int decorationColor,
    int id,
  );

  /// A text block has been decoded.
  void onDrawText(
    int textId,
    int? fillId,
    int? strokeId,
    int? patternId,
  );

  /// An encoded image has been decoded.
  ///
  /// The format is one of the values in [ImageFormatTypes].
  ///
  /// If the [onError] callback is not null, it must be called if an error
  /// occurs while attempting to decode the image [data].
  void onImage(
    int imageId,
    int format,
    Uint8List data, {
    VectorGraphicsErrorListener? onError,
  });

  /// An image should be drawn at the provided location.
  void onDrawImage(
    int imageId,
    double x,
    double y,
    double width,
    double height,
    Float64List? transform,
  );

  /// A pattern has been decoded.
  ///
  /// All subsequent pattern commands will refer to this pattern, until
  /// [onPatternFinished] is invoked.
  void onPatternStart(int patternId, double x, double y, double width,
      double height, Float64List transform);

  /// Record a new text position.
  void onTextPosition(
    int textPositionId,
    double? x,
    double? y,
    double? dx,
    double? dy,
    bool reset,
    Float64List? transform,
  );

  /// An instruction to update the current text position.
  void onUpdateTextPosition(int textPositionId);
}

enum _CurrentSection {
  size,
  images,
  shaders,
  paints,
  paths,
  textPositions,
  text,
  commands,
}

/// Write-only buffer for incrementally building a [ByteData] instance.
///
/// A [VectorGraphicsBuffer] instance can be used only once. Attempts to reuse will result
/// in [StateError]s being thrown.
///
/// The byte order used is [Endian.little] throughout.
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

  /// The next text position id to be used.
  int _nextTextPositionId = 0;

  /// The next image id to be used.
  int _nextImageId = 0;

  /// The next pattern id to be used.
  int _nextPatternId = 0;

  bool _addedCommandTag = false;

  /// The current decoding phase.
  ///
  /// Objects must be written in the correct order, the same as the
  /// enum order.
  _CurrentSection _decodePhase = _CurrentSection.size;

  /// Add a commands tag section if it is not already present.
  void _addCommandsTag() {
    if (_addedCommandTag) {
      return;
    }
    _putUint8(VectorGraphicsCodec._beginCommandsTag);
    _addedCommandTag = true;
  }

  void _checkPhase(_CurrentSection expected) {
    if (_decodePhase.index > expected.index) {
      final String name = expected.name;
      throw StateError('${name[0].toUpperCase()}${name.substring(1)} '
          'must be encoded together (current phase is ${_decodePhase.name}).');
    }
    _decodePhase = expected;
  }

  void _writeTransform(Float64List? transform) {
    if (transform != null) {
      _putUint8(transform.length);
      _putFloat64List(transform);
    } else {
      _putUint8(0);
    }
  }

  /// Write a Uint8 into the buffer.
  void _putUint8(int byte) {
    assert(!_isDone);
    _buffer.add(byte);
  }

  void _putUint16(int value) {
    assert(!_isDone);
    _eightBytes.setUint16(0, value, Endian.little);
    _buffer.addAll(_eightBytesAsList.take(2));
  }

  /// Write a Uint32 into the buffer.
  void _putUint32(int value) {
    assert(!_isDone);
    _eightBytes.setUint32(0, value, Endian.little);
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
  void _putFloat32(double value) {
    assert(!_isDone);
    _eightBytes.setFloat32(0, value, Endian.little);
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
/// The byte order used is [Endian.little] throughout.
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
  int getUint16() {
    final int value = data.getUint16(_position, Endian.little);
    _position += 2;
    return value;
  }

  /// Reads a Uint32 from the buffer.
  int getUint32() {
    final int value = data.getUint32(_position, Endian.little);
    _position += 4;
    return value;
  }

  /// Reads an Int32 from the buffer.
  int getInt32() {
    final int value = data.getInt32(_position, Endian.little);
    _position += 4;
    return value;
  }

  /// Reads an Int64 from the buffer.
  int getInt64() {
    final int value = data.getInt64(_position, Endian.little);
    _position += 8;
    return value;
  }

  /// Reads a Float32 from the buffer.
  double getFloat32() {
    final double value = data.getFloat32(_position, Endian.little);
    _position += 4;
    return value;
  }

  /// Reads a Float64 from the buffer.
  double getFloat64() {
    _alignTo(8);
    final double value = data.getFloat64(_position, Endian.little);
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
    if (mod != 0) {
      _position += alignment - mod;
    }
  }

  Float64List? getTransform() {
    final int transformLength = getUint8();
    if (transformLength > 0) {
      assert(transformLength == 16);
      return getFloat64List(transformLength);
    }
    return null;
  }
}
