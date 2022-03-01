import 'dart:typed_data';
import 'package:typed_data/typed_buffers.dart' show Uint8Buffer;

/// The [VectorGraphicsCodec] provides support for both encoding and
/// decoding the vector_graphics binary format.
class VectorGraphicsCodec {
  /// Create a new [VectorGraphicsCodec].
  ///
  /// The codec is stateless and the const constructor should be preferred.
  const VectorGraphicsCodec();

  static const int _pathTag = 27;
  static const int _fillPaintTag = 28;
  static const int _strokePaintTag = 29;
  static const int _drawPathTag = 30;
  static const int _drawVerticesTag = 31;
  static const int _moveToTag = 32;
  static const int _lineToTag = 33;
  static const int _arcToTag = 34;
  static const int _closeTag = 35;

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
      throw StateError('The provided data was not a vector_graphics binary asset.');
    }
    final int magicNumber = buffer.getUint32();
    if (magicNumber != _magicNumber) {
      throw StateError('The provided data was not a vector_graphics binary asset.');
    }
    final int version = buffer.getUint8();
    if (version != _version) {
      throw StateError('The provided data does not match the currently supported version.');
    }
    while (buffer.hasRemaining) {
      final int type = buffer.getUint8();
      switch (type) {
        case _fillPaintTag:
          return _readFillPaint(buffer, listener);
        case _strokePaintTag:
          return _readStrokePaint(buffer, listener);
        case _pathTag:
          return _readPath(buffer, listener);
        case _drawPathTag:
          return _readDrawPath(buffer, listener);
        case _drawVerticesTag:
          return _readDrawVertices(buffer, listener);
        case _moveToTag:
          return _readMoveTo(buffer, listener);
        case _lineToTag:
          return _readLineTo(buffer, listener);
        case _arcToTag:
          return _readArcTo(buffer, listener);
        case _closeTag:
          return _readClose(buffer, listener);
        default:
          throw StateError('Unknown type tag $type');
      }
    }
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
    buffer._putInt32(pathId);
    buffer._putInt32(paintId);
  }

  /// Encode a draw vertices command in the current buffer.
  ///
  /// The [indices ] are the index buffer used and is optional.
  void writeDrawVertices(
    VectorGraphicsBuffer buffer,
    Float32List vertices,
    Uint16List? indices,
    int? paintId,
  ) {
    if (buffer._decodePhase.index > _DecodePhase.commands.index) {
      throw StateError('Commands must be encoded together.');
    }
    buffer._decodePhase = _DecodePhase.commands;
    // Type Tag
    // Vertex Length
    // Vertex Buffer
    // Index Length
    // Index Buffer (If non zero)
    // Paint Id.
    buffer._putUint8(_drawVerticesTag);
    buffer._putInt32(vertices.length);
    buffer._putFloat32List(vertices);
    if (indices  != null) {
      buffer._putInt32(indices.length);
      buffer._putUint16List(indices );
    } else {
      buffer._putUint32(0);
    }
    buffer._putInt32(paintId ?? -1);
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
  /// To write a paint used for a stroke command, see [writePaintStroke].
  int writePaintFill(
    VectorGraphicsBuffer buffer,
    int color,
    int blendMode,
  ) {
    if (buffer._decodePhase.index > _DecodePhase.paints.index) {
      throw StateError('Paints must be encoded together.');
    }
    buffer._decodePhase = _DecodePhase.paints;
    final int paintId = buffer._nextPaintId++;
    buffer._putUint8(_strokePaintTag);
    buffer._putUint32(color);
    buffer._putUint8(blendMode);
    buffer._putInt32(paintId);
    return paintId;
  }

  /// Encode a paint object in the current buffer, returning the identifier
  /// assigned to it.
  ///
  /// [color] is the 32-bit ARBG color representation used by Flutter
  /// internally. The [strokeCap], [strokeJoin], [blendMode], [style]
  /// fields should be the index of the corresponding enumeration.
  ///
  /// This method is only used to write the paint used for fill commands.
  /// To write a paint used for a stroke command, see [writePaintStroke].
  int writePaintStroke(
    VectorGraphicsBuffer buffer,
    int color,
    int strokeCap,
    int strokeJoin,
    int blendMode,
    double strokeMiterLimit,
    double strokeWidth,
  ) {
    if (buffer._decodePhase.index > _DecodePhase.paints.index) {
      throw StateError('Paints must be encoded together.');
    }
    buffer._decodePhase = _DecodePhase.paints;
    final int paintId = buffer._nextPaintId++;
    buffer._putUint8(_strokePaintTag);
    buffer._putUint32(color);
    buffer._putUint8(strokeCap);
    buffer._putUint8(strokeJoin);
    buffer._putUint8(blendMode);
    buffer._putFloat64(strokeMiterLimit);
    buffer._putFloat64(strokeWidth);
    buffer._putInt32(paintId);
    return paintId;
  }

  void _readFillPaint(_ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final int color = buffer.getUint32();
    final int blendMode = buffer.getUint8();
    final int id = buffer.getInt32();

    listener?.onPaintObject(
      color,
      null,
      null,
      blendMode,
      null,
      null,
      0, // Fill
      id,
    );
  }

  void _readStrokePaint(_ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final int color = buffer.getUint32();
    final int strokeCap = buffer.getUint8();
    final int strokeJoin = buffer.getUint8();
    final int blendMode = buffer.getUint8();
    final double strokeMiterLimit = buffer.getFloat64();
    final double strokeWidth = buffer.getFloat64();
    final int id = buffer.getInt32();

    listener?.onPaintObject(
      color,
      strokeCap,
      strokeJoin,
      blendMode,
      strokeMiterLimit,
      strokeWidth,
      1, // Stroke
      id,
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
    if (buffer._decodePhase.index > _DecodePhase.paths.index) {
      throw StateError('Paths must be encoded together');
    }
    buffer._decodePhase = _DecodePhase.paths;
    buffer._currentPathId = buffer._nextPathId++;
    buffer._putUint8(_pathTag);
    buffer._putUint8(fillType);
    buffer._putInt32(buffer._currentPathId);
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
    buffer._putFloat64(x);
    buffer._putFloat64(y);
  }

  /// Write a line to command to the global coordinate ([x], [y]).
  ///
  /// Throws a [StateError] if there is not an active path.
  void writeLineTo(VectorGraphicsBuffer buffer, double x, double y) {
    if (buffer._currentPathId == -1) {
      throw StateError('There is no active Path.');
    }
    buffer._putUint8(_lineToTag);
    buffer._putFloat64(x);
    buffer._putFloat64(y);
  }

  /// Write an arc to command to the global coordinate ([x1], [y1]) with control
  /// points CP1 ([x2], [y2]) and CP2 ([x3], [y3]).
  ///
  /// Throws a [StateError] if there is not an active path.
  void writeArcTo(VectorGraphicsBuffer buffer, double x1, double y1, double x2, double y2, double x3, double y3) {
    if (buffer._currentPathId == -1) {
      throw StateError('There is no active Path.');
    }
    buffer._putUint8(_arcToTag);
    buffer._putFloat64(x1);
    buffer._putFloat64(y1);
    buffer._putFloat64(x2);
    buffer._putFloat64(y2);
    buffer._putFloat64(x3);
    buffer._putFloat64(y3);
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
    buffer._currentPathId = -1;
  }

  void _readPath(_ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final int fillType = buffer.getUint8();
    final int id = buffer.getInt32();
    listener?.onPathStart(id, fillType);
  }

  void _readMoveTo(_ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final double x = buffer.getFloat64();
    final double y = buffer.getFloat64();
    listener?.onPathMoveTo(x, y);
  }

  void _readLineTo(_ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final double x = buffer.getFloat64();
    final double y = buffer.getFloat64();
    listener?.onPathLineTo(x, y);
  }

  void _readArcTo(_ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final double x1 = buffer.getFloat64();
    final double y1 = buffer.getFloat64();
    final double x2 = buffer.getFloat64();
    final double y2 = buffer.getFloat64();
    final double x3 = buffer.getFloat64();
    final double y3 = buffer.getFloat64();
    listener?.onPathArcTo(x1, y1, x2, y2, x3, y3);
  }

  void _readClose(_ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    listener?.onPathClose();
  }

  void _readDrawPath(_ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final int pathId = buffer.getInt32();
    final int paintId = buffer.getInt32();
    listener?.onDrawPath(pathId, paintId);
  }

  void _readDrawVertices(_ReadBuffer buffer, VectorGraphicsCodecListener? listener) {
    final int paintId = buffer.getInt32();
    final int verticesLength = buffer.getInt32();
    final Float32List vertices = buffer.getFloat32List(verticesLength);
    final int indexLength = buffer.getInt32();
    Uint16List? indices;
    if (indexLength != 0) {
      indices = buffer.getUint16List(indexLength);
    }
    listener?.onDrawVertices(vertices, indices, paintId);
  }
}

/// Implement this listener class to support decoding of vector_graphics binary
/// assets.
abstract class VectorGraphicsCodecListener {
  /// A paint object has been decoded.
  ///
  /// If the paint object is for a fill, then [strokeCap], [strokeJoin],
  /// [strokeMiterLimit], and [strokeWidget] will be `null`.
  void onPaintObject(
    int color,
    int? strokeCap,
    int? strokeJoin,
    int blendMode,
    double? strokeMiterLimit,
    double? strokeWidth,
    int paintStyle,
    int id,
  );

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
  void onPathArcTo(
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
}

enum _DecodePhase {
  paints,
  paths,
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
      : _buffer = Uint8Buffer(),
        _isDone = false,
        _eightBytes = ByteData(8) {
    _eightBytesAsList = _eightBytes.buffer.asUint8List();
    // Begin message with the magic number and current version.
    _putUint32(VectorGraphicsCodec._magicNumber);
    _putUint8(VectorGraphicsCodec._version);
  }

  Uint8Buffer _buffer;
  bool _isDone;
  final ByteData _eightBytes;
  late Uint8List _eightBytesAsList;
  static final Uint8List _zeroBuffer =
      Uint8List.fromList(<int>[0, 0, 0, 0, 0, 0, 0, 0]);

  /// The next paint id to be used.
  int _nextPaintId = 0;

  /// The next path id to be used.
  int _nextPathId = 0;

  /// The current id of the path being built, or `-1` if there is no
  /// active path.
  int _currentPathId = -1;

  /// The current decoding phase.
  ///
  /// Objects must be written in the correct order, the same as the
  /// enum order.
  _DecodePhase _decodePhase = _DecodePhase.paints;

  /// Write a Uint8 into the buffer.
  void _putUint8(int byte) {
    assert(!_isDone);
    _buffer.add(byte);
  }

  /// Write a Uint32 into the buffer.
  void _putUint32(int value, {Endian? endian}) {
    assert(!_isDone);
    _eightBytes.setUint32(0, value, endian ?? Endian.host);
    _buffer.addAll(_eightBytesAsList, 0, 4);
  }

  /// Write an Int32 into the buffer.
  void _putInt32(int value, {Endian? endian}) {
    assert(!_isDone);
    _eightBytes.setInt32(0, value, endian ?? Endian.host);
    _buffer.addAll(_eightBytesAsList, 0, 4);
  }

  /// Write an Float64 into the buffer.
  void _putFloat64(double value, {Endian? endian}) {
    assert(!_isDone);
    _alignTo(8);
    _eightBytes.setFloat64(0, value, endian ?? Endian.host);
    _buffer.addAll(_eightBytesAsList);
  }

  void _putUint16List(Uint16List list) {
    assert(!_isDone);
    _alignTo(2);
    _buffer.addAll(list);
  }

  /// Write all the values from a [Float32List] into the buffer.
  void _putFloat32List(Float32List list) {
    assert(!_isDone);
    _alignTo(4);
    _buffer
        .addAll(list.buffer.asUint8List(list.offsetInBytes, 4 * list.length));
  }

  void _alignTo(int alignment) {
    assert(!_isDone);
    final int mod = _buffer.length % alignment;
    if (mod != 0) {
      _buffer.addAll(_zeroBuffer, 0, alignment - mod);
    }
  }

  /// Finalize and return the written [ByteData].
  ByteData done() {
    if (_isDone) {
      throw StateError(
          'done() must not be called more than once on the same VectorGraphicsBuffer.');
    }
    final ByteData result = _buffer.buffer.asByteData(0, _buffer.lengthInBytes);
    _buffer = Uint8Buffer();
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
