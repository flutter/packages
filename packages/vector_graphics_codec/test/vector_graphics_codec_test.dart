import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

const codec = VectorGraphicsCodec();
const magicHeader = [98, 45, 136, 0, 1, 0, 0, 0];

void bufferContains(VectorGraphicsBuffer buffer, List<int> expectedBytes) {
  final Uint8List data = buffer.done().buffer.asUint8List();
  expect(data, equals(expectedBytes));
}

void main() {
  test('Messages begin with a magic number and version', () {
    final buffer = VectorGraphicsBuffer();

    bufferContains(buffer, [98, 45, 136, 0, 1]);
  });

  test('Messages without any contents cannot be decoded', () {
    expect(
        () => codec.decode(Uint8List(0).buffer.asByteData(), null),
        throwsA(isA<StateError>().having(
            (se) => se.message,
            'message',
            contains(
                'The provided data was not a vector_graphics binary asset.'))));
  });

  test('Messages without a magic number cannot be decoded', () {
    expect(
        () => codec.decode(Uint8List(6).buffer.asByteData(), null),
        throwsA(isA<StateError>().having(
            (se) => se.message,
            'message',
            contains(
                'The provided data was not a vector_graphics binary asset.'))));
  });

  test('Messages without an incompatible version cannot be decoded', () {
    final Uint8List bytes = Uint8List(6);
    bytes[0] = 98;
    bytes[1] = 45;
    bytes[2] = 136;
    bytes[3] = 0;
    bytes[4] = 6; // version 6.

    expect(
        () => codec.decode(bytes.buffer.asByteData(), null),
        throwsA(isA<StateError>().having(
            (se) => se.message,
            'message',
            contains(
                'he provided data does not match the currently supported version.'))));
  });

  test('Basic message encode and decode with filled path', () {
    final buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();
    final int paintId = codec.writeFill(buffer, 23, 0);
    final int pathId = codec.writeStartPath(buffer, 0);
    codec.writeMoveTo(buffer, 1, 2);
    codec.writeLineTo(buffer, 2, 3);
    codec.writeClose(buffer);
    codec.writeFinishPath(buffer);
    codec.writeDrawPath(buffer, pathId, paintId);

    codec.decode(buffer.done(), listener);

    expect(listener.commands, [
      OnPaintObject(
        color: 23,
        strokeCap: null,
        strokeJoin: null,
        blendMode: 0,
        strokeMiterLimit: null,
        strokeWidth: null,
        paintStyle: 0,
        id: paintId,
      ),
      OnPathStart(pathId, 0),
      const OnPathMoveTo(1, 2),
      const OnPathLineTo(2, 3),
      const OnPathClose(),
      OnDrawPath(pathId, paintId),
    ]);
  });

  test('Basic message encode and decode with stroked vertex', () {
    final buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();
    final int paintId = codec.writeStroke(buffer, 44, 1, 2, 3, 4.0, 6.0);
    codec.writeDrawVertices(
        buffer,
        Float32List.fromList([
          0.0,
          2.0,
          3.0,
          4.0,
          2.0,
          4.0,
        ]),
        null,
        paintId);

    codec.decode(buffer.done(), listener);

    expect(listener.commands, [
      OnPaintObject(
        color: 44,
        strokeCap: 1,
        strokeJoin: 2,
        blendMode: 3,
        strokeMiterLimit: 4.0,
        strokeWidth: 6.0,
        paintStyle: 1,
        id: paintId,
      ),
      OnDrawVertices([
        0.0,
        2.0,
        3.0,
        4.0,
        2.0,
        4.0,
      ], null, paintId),
    ]);
  });
}

class TestListener extends VectorGraphicsCodecListener {
  final List<Object> commands = <Object>[];

  @override
  void onDrawPath(int pathId, int? paintId) {
    commands.add(OnDrawPath(pathId, paintId));
  }

  @override
  void onDrawVertices(Float32List vertices, Uint16List? indices, int? paintId) {
    commands.add(OnDrawVertices(vertices, indices, paintId));
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
  }) {
    commands.add(
      OnPaintObject(
          color: color,
          strokeCap: strokeCap,
          strokeJoin: strokeJoin,
          blendMode: blendMode,
          strokeMiterLimit: strokeMiterLimit,
          strokeWidth: strokeWidth,
          paintStyle: paintStyle,
          id: id),
    );
  }

  @override
  void onPathClose() {
    commands.add(const OnPathClose());
  }

  @override
  void onPathCubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    commands.add(OnPathCubicTo(x1, y1, x2, y2, x3, y3));
  }

  @override
  void onPathFinished() {
    commands.add(const OnPathFinished());
  }

  @override
  void onPathLineTo(double x, double y) {
    commands.add(OnPathLineTo(x, y));
  }

  @override
  void onPathMoveTo(double x, double y) {
    commands.add(OnPathMoveTo(x, y));
  }

  @override
  void onPathStart(int id, int fillType) {
    commands.add(OnPathStart(id, fillType));
  }
}

class OnDrawPath {
  const OnDrawPath(this.pathId, this.paintId);

  final int pathId;
  final int? paintId;

  @override
  int get hashCode => Object.hash(pathId, paintId);

  @override
  bool operator ==(Object other) =>
      other is OnDrawPath && other.pathId == pathId && other.paintId == paintId;

  @override
  String toString() => 'OnDrawPath($pathId, $paintId)';
}

class OnDrawVertices {
  const OnDrawVertices(this.vertices, this.indices, this.paintId);

  final List<double> vertices;
  final List<int>? indices;
  final int? paintId;

  @override
  int get hashCode => Object.hash(
      Object.hashAll(vertices), Object.hashAll(indices ?? []), paintId);

  @override
  bool operator ==(Object other) =>
      other is OnDrawVertices &&
      _listEquals(vertices, other.vertices) &&
      _listEquals(indices, other.indices) &&
      other.paintId == paintId;

  @override
  String toString() => 'OnDrawVertices($vertices, $indices, $paintId)';
}

class OnPaintObject {
  const OnPaintObject({
    required this.color,
    required this.strokeCap,
    required this.strokeJoin,
    required this.blendMode,
    required this.strokeMiterLimit,
    required this.strokeWidth,
    required this.paintStyle,
    required this.id,
  });

  final int color;
  final int? strokeCap;
  final int? strokeJoin;
  final int blendMode;
  final double? strokeMiterLimit;
  final double? strokeWidth;
  final int paintStyle;
  final int id;

  @override
  int get hashCode => Object.hash(color, strokeCap, strokeJoin, blendMode,
      strokeMiterLimit, strokeWidth, paintStyle, id);

  @override
  bool operator ==(Object other) =>
      other is OnPaintObject &&
      other.color == color &&
      other.strokeCap == strokeCap &&
      other.strokeJoin == strokeJoin &&
      other.blendMode == blendMode &&
      other.strokeMiterLimit == strokeMiterLimit &&
      other.strokeWidth == strokeWidth &&
      other.paintStyle == paintStyle &&
      other.id == id;

  @override
  String toString() =>
      'OnPaintObject($color, $strokeCap, $strokeJoin, $blendMode, $strokeMiterLimit, $strokeWidth, $paintStyle, $id)';
}

class OnPathClose {
  const OnPathClose();

  @override
  int get hashCode => 44221;

  @override
  bool operator ==(Object other) => other is OnPathClose;

  @override
  String toString() => 'OnPathClose';
}

class OnPathCubicTo {
  const OnPathCubicTo(this.x1, this.y1, this.x2, this.y2, this.x3, this.y3);

  final double x1;
  final double x2;
  final double x3;
  final double y1;
  final double y2;
  final double y3;

  @override
  int get hashCode => Object.hash(x1, y1, x2, y2, x3, y3);

  @override
  bool operator ==(Object other) =>
      other is OnPathCubicTo &&
      other.x1 == x1 &&
      other.y1 == y1 &&
      other.x2 == x2 &&
      other.y2 == y2 &&
      other.x3 == x3 &&
      other.y3 == y3;

  @override
  String toString() => 'OnPathCubicTo($x1, $y1, $x2, $y2, $x3, $y3)';
}

class OnPathFinished {
  const OnPathFinished();

  @override
  int get hashCode => 1223;

  @override
  bool operator ==(Object other) => other is OnPathFinished;

  @override
  String toString() => 'OnPathFinished';
}

class OnPathLineTo {
  const OnPathLineTo(this.x, this.y);

  final double x;
  final double y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  bool operator ==(Object other) =>
      other is OnPathLineTo && other.x == x && other.y == y;

  @override
  String toString() => 'OnPathLineTo($x, $y)';
}

class OnPathMoveTo {
  const OnPathMoveTo(this.x, this.y);

  final double x;
  final double y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  bool operator ==(Object other) =>
      other is OnPathMoveTo && other.x == x && other.y == y;

  @override
  String toString() => 'OnPathMoveTo($x, $y)';
}

class OnPathStart {
  const OnPathStart(this.id, this.fillType);

  final int id;
  final int fillType;

  @override
  int get hashCode => Object.hash(id, fillType);

  @override
  bool operator ==(Object other) =>
      other is OnPathStart && other.id == id && other.fillType == fillType;

  @override
  String toString() => 'OnPathStart($id, $fillType)';
}

bool _listEquals<E>(List<E>? left, List<E>? right) {
  if (left == null && right == null) {
    return true;
  }
  if (left == null || right == null) {
    return false;
  }
  if (left.length != right.length) {
    return false;
  }
  for (int i = 0; i < left.length; i++) {
    if (left[i] != right[i]) {
      return false;
    }
  }
  return true;
}
