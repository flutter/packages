// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

const VectorGraphicsCodec codec = VectorGraphicsCodec();
final Float64List mat4 = Float64List.fromList(
    <double>[2, 0, 0, 0, 0, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);

void bufferContains(VectorGraphicsBuffer buffer, List<int> expectedBytes) {
  final Uint8List data = buffer.done().buffer.asUint8List();
  expect(data, equals(expectedBytes));
}

void main() {
  test('Messages begin with a magic number and version', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();

    bufferContains(buffer, <int>[98, 45, 136, 0, 1]);
  });

  test('Messages without any contents cannot be decoded', () {
    expect(
        () => codec.decode(Uint8List(0).buffer.asByteData(), null),
        throwsA(isA<StateError>().having(
            (StateError se) => se.message,
            'message',
            contains(
                'The provided data was not a vector_graphics binary asset.'))));
  });

  test('Messages without a magic number cannot be decoded', () {
    expect(
        () => codec.decode(Uint8List(6).buffer.asByteData(), null),
        throwsA(isA<StateError>().having(
            (StateError se) => se.message,
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
            (StateError se) => se.message,
            'message',
            contains(
                'he provided data does not match the currently supported version.'))));
  });

  test('Basic message encode and decode with filled path', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();
    final int paintId = codec.writeFill(buffer, 23, 0);
    final int pathId = codec.writePath(
      buffer,
      Uint8List.fromList(<int>[
        ControlPointTypes.moveTo,
        ControlPointTypes.lineTo,
        ControlPointTypes.close
      ]),
      Float32List.fromList(<double>[1, 2, 2, 3]),
      0,
    );
    codec.writeDrawPath(buffer, pathId, paintId, null);

    codec.decode(buffer.done(), listener);

    expect(listener.commands, <Object>[
      OnPaintObject(
        color: 23,
        strokeCap: null,
        strokeJoin: null,
        blendMode: 0,
        strokeMiterLimit: null,
        strokeWidth: null,
        paintStyle: 0,
        id: paintId,
        shaderId: null,
      ),
      OnPathStart(pathId, 0),
      const OnPathMoveTo(1, 2),
      const OnPathLineTo(2, 3),
      const OnPathClose(),
      const OnPathFinished(),
      OnDrawPath(pathId, paintId, null),
    ]);
  });

  test('Basic message encode and decode with shaded path', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();
    final int shaderId = codec.writeLinearGradient(
      buffer,
      fromX: 0,
      fromY: 0,
      toX: 1,
      toY: 1,
      colors: Int32List.fromList(<int>[0, 1]),
      offsets: Float32List.fromList(<double>[0, 1]),
      tileMode: 1,
    );
    final int fillId = codec.writeFill(buffer, 23, 0, shaderId);
    final int strokeId =
        codec.writeStroke(buffer, 44, 1, 2, 3, 4.0, 6.0, shaderId);
    final int pathId = codec.writePath(
      buffer,
      Uint8List.fromList(<int>[
        ControlPointTypes.moveTo,
        ControlPointTypes.lineTo,
        ControlPointTypes.close
      ]),
      Float32List.fromList(<double>[1, 2, 2, 3]),
      0,
    );
    codec.writeDrawPath(buffer, pathId, fillId, null);
    codec.writeDrawPath(buffer, pathId, strokeId, null);

    codec.decode(buffer.done(), listener);

    expect(listener.commands, <Object>[
      OnLinearGradient(
        fromX: 0,
        fromY: 0,
        toX: 1,
        toY: 1,
        colors: Int32List.fromList(<int>[0, 1]),
        offsets: Float32List.fromList(<double>[0, 1]),
        tileMode: 1,
        id: shaderId,
      ),
      OnPaintObject(
        color: 23,
        strokeCap: null,
        strokeJoin: null,
        blendMode: 0,
        strokeMiterLimit: null,
        strokeWidth: null,
        paintStyle: 0,
        id: fillId,
        shaderId: shaderId,
      ),
      OnPaintObject(
        color: 44,
        strokeCap: 1,
        strokeJoin: 2,
        blendMode: 3,
        strokeMiterLimit: 4.0,
        strokeWidth: 6.0,
        paintStyle: 1,
        id: strokeId,
        shaderId: shaderId,
      ),
      OnPathStart(pathId, 0),
      const OnPathMoveTo(1, 2),
      const OnPathLineTo(2, 3),
      const OnPathClose(),
      const OnPathFinished(),
      OnDrawPath(pathId, fillId, null),
      OnDrawPath(pathId, strokeId, null),
    ]);
  });

  test('Basic message encode and decode with stroked vertex', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();
    final int paintId = codec.writeStroke(buffer, 44, 1, 2, 3, 4.0, 6.0);
    codec.writeDrawVertices(
        buffer,
        Float32List.fromList(<double>[
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

    expect(listener.commands, <Object>[
      OnPaintObject(
        color: 44,
        strokeCap: 1,
        strokeJoin: 2,
        blendMode: 3,
        strokeMiterLimit: 4.0,
        strokeWidth: 6.0,
        paintStyle: 1,
        id: paintId,
        shaderId: null,
      ),
      OnDrawVertices(const <double>[
        0.0,
        2.0,
        3.0,
        4.0,
        2.0,
        4.0,
      ], null, paintId),
    ]);
  });

  test('Basic message encode and decode with stroked vertex and indexes', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();
    final int paintId = codec.writeStroke(buffer, 44, 1, 2, 3, 4.0, 6.0);
    codec.writeDrawVertices(
      buffer,
      Float32List.fromList(<double>[
        0.0,
        2.0,
        3.0,
        4.0,
        2.0,
        4.0,
      ]),
      Uint16List.fromList(<int>[
        0,
        1,
        2,
        3,
        4,
        5,
      ]),
      paintId,
    );

    codec.decode(buffer.done(), listener);

    expect(listener.commands, <Object>[
      OnPaintObject(
        color: 44,
        strokeCap: 1,
        strokeJoin: 2,
        blendMode: 3,
        strokeMiterLimit: 4.0,
        strokeWidth: 6.0,
        paintStyle: 1,
        id: paintId,
        shaderId: null,
      ),
      OnDrawVertices(const <double>[
        0.0,
        2.0,
        3.0,
        4.0,
        2.0,
        4.0,
      ], const <int>[
        0,
        1,
        2,
        3,
        4,
        5,
      ], paintId),
    ]);
  });

  test('Can encode opacity/save/restore layers', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();
    final int paintId = codec.writeFill(buffer, 0xAA000000, 0);

    codec.writeSaveLayer(buffer, paintId);
    codec.writeRestoreLayer(buffer);
    codec.decode(buffer.done(), listener);

    expect(listener.commands, <Object>[
      OnPaintObject(
        color: 0xAA000000,
        strokeCap: null,
        strokeJoin: null,
        blendMode: 0,
        strokeMiterLimit: null,
        strokeWidth: null,
        paintStyle: 0,
        id: paintId,
        shaderId: null,
      ),
      OnSaveLayer(paintId),
      const OnRestoreLayer(),
    ]);
  });

  test('Can encode a radial gradient', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();

    final int shaderId = codec.writeRadialGradient(
      buffer,
      centerX: 2.0,
      centerY: 3.0,
      radius: 5.0,
      focalX: 1.0,
      focalY: 1.0,
      colors: Int32List.fromList(<int>[0xFFAABBAA]),
      offsets: Float32List.fromList(<double>[2.2, 1.2]),
      tileMode: 0,
      transform: mat4,
    );

    codec.decode(buffer.done(), listener);

    expect(listener.commands, <OnRadialGradient>[
      OnRadialGradient(
        centerX: 2.0,
        centerY: 3.0,
        radius: 5.0,
        focalX: 1.0,
        focalY: 1.0,
        colors: Int32List.fromList(<int>[0xFFAABBAA]),
        offsets: Float32List.fromList(<double>[2.2, 1.2]),
        transform: mat4,
        tileMode: 0,
        id: shaderId,
      ),
    ]);
  });

  test('Can encode a radial gradient (no matrix)', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();

    final int shaderId = codec.writeRadialGradient(
      buffer,
      centerX: 2.0,
      centerY: 3.0,
      radius: 5.0,
      focalX: 1.0,
      focalY: 1.0,
      colors: Int32List.fromList(<int>[0xFFAABBAA]),
      offsets: Float32List.fromList(<double>[2.2, 1.2]),
      tileMode: 0,
      transform: null,
    );

    codec.decode(buffer.done(), listener);

    expect(listener.commands, <OnRadialGradient>[
      OnRadialGradient(
        centerX: 2.0,
        centerY: 3.0,
        radius: 5.0,
        focalX: 1.0,
        focalY: 1.0,
        colors: Int32List.fromList(<int>[0xFFAABBAA]),
        offsets: Float32List.fromList(<double>[2.2, 1.2]),
        transform: null,
        tileMode: 0,
        id: shaderId,
      ),
    ]);
  });

  test('Can encode a linear gradient', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();

    final int shaderId = codec.writeLinearGradient(
      buffer,
      fromX: 2.0,
      fromY: 3.0,
      toX: 1.0,
      toY: 1.0,
      colors: Int32List.fromList(<int>[0xFFAABBAA]),
      offsets: Float32List.fromList(<double>[2.2, 1.2]),
      tileMode: 0,
    );

    codec.decode(buffer.done(), listener);

    expect(listener.commands, <OnLinearGradient>[
      OnLinearGradient(
        fromX: 2.0,
        fromY: 3.0,
        toX: 1.0,
        toY: 1.0,
        colors: Int32List.fromList(<int>[0xFFAABBAA]),
        offsets: Float32List.fromList(<double>[2.2, 1.2]),
        tileMode: 0,
        id: shaderId,
      ),
    ]);
  });

  test('Can encode clips', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();
    final int pathId = codec.writePath(
      buffer,
      Uint8List.fromList(<int>[
        ControlPointTypes.lineTo,
        ControlPointTypes.lineTo,
        ControlPointTypes.lineTo,
        ControlPointTypes.close,
      ]),
      Float32List.fromList(<double>[0, 10, 20, 10, 20, 0]),
      0,
    );

    codec.writeClipPath(buffer, pathId);
    codec.writeRestoreLayer(buffer);
    codec.decode(buffer.done(), listener);

    expect(listener.commands, <Object>[
      OnPathStart(pathId, 0),
      const OnPathLineTo(0, 10),
      const OnPathLineTo(20, 10),
      const OnPathLineTo(20, 0),
      const OnPathClose(),
      const OnPathFinished(),
      OnClipPath(pathId),
      const OnRestoreLayer(),
    ]);
  });

  test('Can encode masks', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();
    codec.writeMask(buffer);
    codec.decode(buffer.done(), listener);
    expect(listener.commands, <OnMask>[const OnMask()]);
  });

  test('Encodes a size', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();

    codec.writeSize(buffer, 20, 30);
    codec.decode(buffer.done(), listener);

    expect(listener.commands, <OnSize>[const OnSize(20, 30)]);
  });

  test('Only supports a single size', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();

    codec.writeSize(buffer, 20, 30);
    expect(() => codec.writeSize(buffer, 1, 1), throwsStateError);
  });

  test('Encodes text', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();

    final int paintId = codec.writeFill(buffer, 0xFFAABBAA, 0);
    final int textId = codec.writeTextConfig(
      buffer: buffer,
      text: 'Hello',
      fontFamily: 'Roboto',
      xAnchorMultiplier: 0,
      fontWeight: 0,
      fontSize: 16,
      decoration: 0,
      decorationStyle: 0,
      decorationColor: 0,
    );
    codec.writeDrawText(buffer, textId, paintId, null, null);
    codec.decode(buffer.done(), listener);

    expect(listener.commands, <Object>[
      OnPaintObject(
        color: 0xFFAABBAA,
        strokeCap: null,
        strokeJoin: null,
        blendMode: 0,
        strokeMiterLimit: null,
        strokeWidth: null,
        paintStyle: 0,
        id: paintId,
        shaderId: null,
      ),
      OnTextConfig('Hello', 0, 16, 'Roboto', 0, 0, 0, 0, textId),
      OnDrawText(textId, paintId, null, null),
    ]);
  });

  test('Encodes text with null font family', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();

    final int paintId = codec.writeFill(buffer, 0xFFAABBAA, 0);
    final int textId = codec.writeTextConfig(
      buffer: buffer,
      text: 'Hello',
      fontFamily: null,
      xAnchorMultiplier: 0,
      fontWeight: 0,
      fontSize: 16,
      decoration: 0,
      decorationStyle: 0,
      decorationColor: 0,
    );
    codec.writeDrawText(buffer, textId, paintId, null, null);
    codec.decode(buffer.done(), listener);

    expect(listener.commands, <Object>[
      OnPaintObject(
        color: 0xFFAABBAA,
        strokeCap: null,
        strokeJoin: null,
        blendMode: 0,
        strokeMiterLimit: null,
        strokeWidth: null,
        paintStyle: 0,
        id: paintId,
        shaderId: null,
      ),
      OnTextConfig('Hello', 0, 16, null, 0, 0, 0, 0, textId),
      OnDrawText(textId, paintId, null, null),
    ]);
  });

  test('Encodes empty text', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();

    final int paintId = codec.writeFill(buffer, 0xFFAABBAA, 0);
    final int textId = codec.writeTextConfig(
      buffer: buffer,
      text: '',
      fontFamily: null,
      xAnchorMultiplier: 0,
      fontWeight: 0,
      fontSize: 16,
      decoration: 0,
      decorationStyle: 0,
      decorationColor: 0,
    );
    codec.writeDrawText(buffer, textId, paintId, null, null);
    codec.decode(buffer.done(), listener);

    expect(listener.commands, <Object>[
      OnPaintObject(
        color: 0xFFAABBAA,
        strokeCap: null,
        strokeJoin: null,
        blendMode: 0,
        strokeMiterLimit: null,
        strokeWidth: null,
        paintStyle: 0,
        id: paintId,
        shaderId: null,
      ),
      OnTextConfig('', 0, 16, null, 0, 0, 0, 0, textId),
      OnDrawText(textId, paintId, null, null),
    ]);
  });

  test('Encodes text position', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();

    codec.writeTextPosition(buffer, 1, 2, 3, 4, true, mat4);

    codec.decode(buffer.done(), listener);

    expect(listener.commands, <Object>[
      OnTextPosition(
        id: 0,
        x: 1,
        y: 2,
        dx: 3,
        dy: 4,
        reset: true,
        transform: mat4,
      ),
    ]);
  });

  test('Encodes image data without transform', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();

    final int id =
        codec.writeImage(buffer, 0, Uint8List.fromList(<int>[0, 1, 3, 4, 5]));
    codec.writeDrawImage(buffer, id, 1, 2, 100, 100, null);
    final ByteData data = buffer.done();
    final DecodeResponse response = codec.decode(data, listener);

    expect(response.complete, false);
    expect(listener.commands, <OnImage>[
      OnImage(id, 0, const <int>[0, 1, 3, 4, 5]),
    ]);

    final DecodeResponse nextResponse =
        codec.decode(data, listener, response: response);

    expect(nextResponse.complete, true);
    expect(listener.commands, <Object>[
      OnImage(id, 0, const <int>[0, 1, 3, 4, 5]),
      OnDrawImage(id, 1, 2, 100, 100, null),
    ]);
  });

  test('Encodes image data with transform', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();

    final int id =
        codec.writeImage(buffer, 0, Uint8List.fromList(<int>[0, 1, 3, 4, 5]));
    codec.writeDrawImage(buffer, id, 1, 2, 100, 100, mat4);
    final ByteData data = buffer.done();
    final DecodeResponse response = codec.decode(data, listener);

    expect(response.complete, false);
    expect(listener.commands, <OnImage>[
      OnImage(id, 0, const <int>[0, 1, 3, 4, 5]),
    ]);

    final DecodeResponse nextResponse =
        codec.decode(data, listener, response: response);

    expect(nextResponse.complete, true);
    expect(listener.commands, <Object>[
      OnImage(id, 0, const <int>[0, 1, 3, 4, 5]),
      OnDrawImage(id, 1, 2, 100, 100, mat4),
    ]);
  });

  test('Encodes image data with various formats', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();

    for (final int format in ImageFormatTypes.values) {
      expect(
        codec.writeImage(
            buffer, format, Uint8List.fromList(<int>[0, 1, 3, 4, 5])),
        greaterThan(-1),
      );
    }
  });

  test('Basic message encode and decode with shaded path and image', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();

    final int imageId =
        codec.writeImage(buffer, 0, Uint8List.fromList(<int>[0, 1, 3, 4, 5]));
    final int shaderId = codec.writeLinearGradient(
      buffer,
      fromX: 0,
      fromY: 0,
      toX: 1,
      toY: 1,
      colors: Int32List.fromList(<int>[0, 1]),
      offsets: Float32List.fromList(<double>[0, 1]),
      tileMode: 1,
    );
    final int fillId = codec.writeFill(buffer, 23, 0, shaderId);
    final int strokeId =
        codec.writeStroke(buffer, 44, 1, 2, 3, 4.0, 6.0, shaderId);
    final int pathId = codec.writePath(
      buffer,
      Uint8List.fromList(<int>[
        ControlPointTypes.moveTo,
        ControlPointTypes.lineTo,
        ControlPointTypes.close
      ]),
      Float32List.fromList(<double>[1, 2, 2, 3]),
      0,
    );
    codec.writeDrawPath(buffer, pathId, fillId, null);
    codec.writeDrawPath(buffer, pathId, strokeId, null);
    codec.writeDrawImage(buffer, imageId, 1, 2, 100, 100, null);

    final ByteData data = buffer.done();

    DecodeResponse response = codec.decode(data, listener);

    expect(response.complete, false);
    expect(listener.commands, <Object>[
      OnImage(
        imageId,
        0,
        const <int>[0, 1, 3, 4, 5],
      ),
      OnLinearGradient(
        fromX: 0,
        fromY: 0,
        toX: 1,
        toY: 1,
        colors: Int32List.fromList(<int>[0, 1]),
        offsets: Float32List.fromList(<double>[0, 1]),
        tileMode: 1,
        id: shaderId,
      ),
      OnPaintObject(
        color: 23,
        strokeCap: null,
        strokeJoin: null,
        blendMode: 0,
        strokeMiterLimit: null,
        strokeWidth: null,
        paintStyle: 0,
        id: fillId,
        shaderId: shaderId,
      ),
      OnPaintObject(
        color: 44,
        strokeCap: 1,
        strokeJoin: 2,
        blendMode: 3,
        strokeMiterLimit: 4.0,
        strokeWidth: 6.0,
        paintStyle: 1,
        id: strokeId,
        shaderId: shaderId,
      ),
      OnPathStart(pathId, 0),
      const OnPathMoveTo(1, 2),
      const OnPathLineTo(2, 3),
      const OnPathClose(),
      const OnPathFinished(),
    ]);

    response = codec.decode(data, listener, response: response);

    expect(response.complete, true);
    expect(listener.commands, <Object>[
      OnImage(
        imageId,
        0,
        const <int>[0, 1, 3, 4, 5],
      ),
      OnLinearGradient(
        fromX: 0,
        fromY: 0,
        toX: 1,
        toY: 1,
        colors: Int32List.fromList(<int>[0, 1]),
        offsets: Float32List.fromList(<double>[0, 1]),
        tileMode: 1,
        id: shaderId,
      ),
      OnPaintObject(
        color: 23,
        strokeCap: null,
        strokeJoin: null,
        blendMode: 0,
        strokeMiterLimit: null,
        strokeWidth: null,
        paintStyle: 0,
        id: fillId,
        shaderId: shaderId,
      ),
      OnPaintObject(
        color: 44,
        strokeCap: 1,
        strokeJoin: 2,
        blendMode: 3,
        strokeMiterLimit: 4.0,
        strokeWidth: 6.0,
        paintStyle: 1,
        id: strokeId,
        shaderId: shaderId,
      ),
      OnPathStart(pathId, 0),
      const OnPathMoveTo(1, 2),
      const OnPathLineTo(2, 3),
      const OnPathClose(),
      const OnPathFinished(),
      OnDrawPath(pathId, fillId, null),
      OnDrawPath(pathId, strokeId, null),
      OnDrawImage(imageId, 1, 2, 100, 100, null),
    ]);
  });

  test('Basic message encode and decode with half precision path', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final TestListener listener = TestListener();

    final int fillId = codec.writeFill(buffer, 23, 0);
    final int strokeId = codec.writeStroke(buffer, 44, 1, 2, 3, 4.0, 6.0);
    final int pathId = codec.writePath(
      buffer,
      Uint8List.fromList(<int>[
        ControlPointTypes.moveTo,
        ControlPointTypes.lineTo,
        ControlPointTypes.lineTo,
        ControlPointTypes.close
      ]),
      Float32List.fromList(<double>[1.25, 24.5, 200.10, -32.4, -10000, 2500.2]),
      0,
      half: true,
    );
    codec.writeDrawPath(buffer, pathId, fillId, null);
    codec.writeDrawPath(buffer, pathId, strokeId, null);

    final ByteData data = buffer.done();

    final DecodeResponse response = codec.decode(data, listener);

    expect(response.complete, true);
    expect(listener.commands, <Object>[
      OnPaintObject(
        color: 23,
        strokeCap: null,
        strokeJoin: null,
        blendMode: 0,
        strokeMiterLimit: null,
        strokeWidth: null,
        paintStyle: 0,
        id: fillId,
        shaderId: null,
      ),
      OnPaintObject(
        color: 44,
        strokeCap: 1,
        strokeJoin: 2,
        blendMode: 3,
        strokeMiterLimit: 4.0,
        strokeWidth: 6.0,
        paintStyle: 1,
        id: strokeId,
        shaderId: null,
      ),
      OnPathStart(pathId, 0),
      const OnPathMoveTo(1.25, 24.5),
      const OnPathLineTo(200.125, -32.40625),
      const OnPathLineTo(-10000, 2500.0),
      const OnPathClose(),
      const OnPathFinished(),
      const OnDrawPath(0, 0, null),
      const OnDrawPath(0, 1, null),
    ]);
  });
}

class TestListener extends VectorGraphicsCodecListener {
  final List<Object> commands = <Object>[];

  @override
  void onDrawPath(int pathId, int? paintId, int? patternId) {
    commands.add(OnDrawPath(pathId, paintId, patternId));
  }

  @override
  void onDrawVertices(Float32List vertices, Uint16List? indices, int? paintId) {
    commands.add(OnDrawVertices(vertices, indices, paintId));
  }

  @override
  void onTextPosition(int textPositionId, double? x, double? y, double? dx,
      double? dy, bool reset, Float64List? transform) {
    commands.add(OnTextPosition(
      id: textPositionId,
      x: x,
      y: y,
      dx: dx,
      dy: dy,
      reset: reset,
      transform: transform,
    ));
  }

  @override
  void onUpdateTextPosition(int textPositionId) {
    commands.add(OnUpdateTextPosition(textPositionId));
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
    commands.add(
      OnPaintObject(
        color: color,
        strokeCap: strokeCap,
        strokeJoin: strokeJoin,
        blendMode: blendMode,
        strokeMiterLimit: strokeMiterLimit,
        strokeWidth: strokeWidth,
        paintStyle: paintStyle,
        id: id,
        shaderId: shaderId,
      ),
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

  @override
  void onRestoreLayer() {
    commands.add(const OnRestoreLayer());
  }

  @override
  void onMask() {
    commands.add(const OnMask());
  }

  @override
  void onSaveLayer(int id) {
    commands.add(OnSaveLayer(id));
  }

  @override
  void onClipPath(int pathId) {
    commands.add(OnClipPath(pathId));
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
    commands.add(
      OnRadialGradient(
        centerX: centerX,
        centerY: centerY,
        radius: radius,
        focalX: focalX,
        focalY: focalY,
        colors: colors,
        offsets: offsets,
        transform: transform,
        tileMode: tileMode,
        id: id,
      ),
    );
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
    commands.add(OnLinearGradient(
      fromX: fromX,
      fromY: fromY,
      toX: toX,
      toY: toY,
      colors: colors,
      offsets: offsets,
      tileMode: tileMode,
      id: id,
    ));
  }

  @override
  void onSize(double width, double height) {
    commands.add(OnSize(width, height));
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
    commands.add(OnTextConfig(
      text,
      xAnchorMultiplier,
      fontSize,
      fontFamily,
      fontWeight,
      decoration,
      decorationStyle,
      decorationColor,
      id,
    ));
  }

  @override
  void onDrawText(int textId, int? fillId, int? strokeId, int? patternId) {
    commands.add(OnDrawText(textId, fillId, strokeId, patternId));
  }

  @override
  void onImage(
    int imageId,
    int format,
    Uint8List data, {
    VectorGraphicsErrorListener? onError,
  }) {
    commands.add(OnImage(
      imageId,
      format,
      data,
      onError: onError,
    ));
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
    commands.add(OnDrawImage(imageId, x, y, width, height, transform));
  }

  @override
  void onPatternStart(int patternId, double x, double y, double width,
      double height, Float64List transform) {
    commands.add(OnPatternStart(patternId, x, y, width, height, transform));
  }
}

@immutable
@immutable
class OnTextPosition {
  const OnTextPosition({
    required this.id,
    this.x,
    this.y,
    this.dx,
    this.dy,
    required this.reset,
    required this.transform,
  });

  final int id;
  final double? x;
  final double? y;
  final double? dx;
  final double? dy;
  final bool reset;
  final Float64List? transform;

  @override
  int get hashCode => Object.hash(
        id,
        x,
        y,
        dx,
        dy,
        reset,
        Object.hashAll(transform ?? <Object?>[]),
      );

  @override
  bool operator ==(Object other) {
    return other is OnTextPosition &&
        other.id == id &&
        other.x == x &&
        other.y == y &&
        other.dx == dx &&
        other.dy == dy &&
        _listEquals(other.transform, transform);
  }
}

@immutable
class OnMask {
  const OnMask();
}

@immutable
@immutable
class OnLinearGradient {
  const OnLinearGradient({
    required this.fromX,
    required this.fromY,
    required this.toX,
    required this.toY,
    required this.colors,
    required this.offsets,
    required this.tileMode,
    required this.id,
  });

  final double fromX;
  final double fromY;
  final double toX;
  final double toY;
  final Int32List colors;
  final Float32List? offsets;
  final int tileMode;
  final int id;

  @override
  int get hashCode => Object.hash(
        fromX,
        fromY,
        toX,
        toY,
        Object.hashAll(colors),
        Object.hashAll(offsets ?? <Object?>[]),
        tileMode,
        id,
      );

  @override
  bool operator ==(Object other) {
    return other is OnLinearGradient &&
        other.fromX == fromX &&
        other.fromY == fromY &&
        other.toX == toX &&
        other.toY == toY &&
        _listEquals(other.colors, colors) &&
        _listEquals(other.offsets, offsets) &&
        other.tileMode == tileMode &&
        other.id == id;
  }

  @override
  String toString() {
    return 'OnLinearGradient('
        'fromX: $fromX, '
        'toX: $toX, '
        'fromY: $fromY, '
        'toY: $toY, '
        'colors: Int32List.fromList($colors), '
        'offsets: Float32List.fromList($offsets), '
        'tileMode: $tileMode, '
        'id: $id)';
  }
}

@immutable
class OnRadialGradient {
  const OnRadialGradient({
    required this.centerX,
    required this.centerY,
    required this.radius,
    required this.focalX,
    required this.focalY,
    required this.colors,
    required this.offsets,
    required this.transform,
    required this.tileMode,
    required this.id,
  });

  final double centerX;
  final double centerY;
  final double radius;
  final double? focalX;
  final double? focalY;
  final Int32List colors;
  final Float32List? offsets;
  final Float64List? transform;
  final int tileMode;
  final int id;

  @override
  int get hashCode => Object.hash(
        centerX,
        centerY,
        radius,
        focalX,
        focalY,
        Object.hashAll(colors),
        Object.hashAll(offsets ?? <Object?>[]),
        Object.hashAll(transform ?? <Object?>[]),
        tileMode,
        id,
      );

  @override
  bool operator ==(Object other) {
    return other is OnRadialGradient &&
        other.centerX == centerX &&
        other.centerY == centerY &&
        other.radius == radius &&
        other.focalX == focalX &&
        other.focalX == focalY &&
        _listEquals(other.colors, colors) &&
        _listEquals(other.offsets, offsets) &&
        _listEquals(other.transform, transform) &&
        other.tileMode == tileMode &&
        other.id == id;
  }
}

@immutable
class OnSaveLayer {
  const OnSaveLayer(this.id);

  final int id;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is OnSaveLayer && other.id == id;
}

@immutable
class OnClipPath {
  const OnClipPath(this.id);

  final int id;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is OnClipPath && other.id == id;
}

@immutable
class OnRestoreLayer {
  const OnRestoreLayer();
}

@immutable
class OnDrawPath {
  const OnDrawPath(this.pathId, this.paintId, this.patternId);

  final int pathId;
  final int? paintId;
  final int? patternId;

  @override
  int get hashCode => Object.hash(pathId, paintId, patternId);

  @override
  bool operator ==(Object other) =>
      other is OnDrawPath &&
      other.pathId == pathId &&
      other.paintId == paintId &&
      other.patternId == patternId;

  @override
  String toString() => 'OnDrawPath($pathId, $paintId, $patternId)';
}

@immutable
class OnDrawVertices {
  const OnDrawVertices(this.vertices, this.indices, this.paintId);

  final List<double> vertices;
  final List<int>? indices;
  final int? paintId;

  @override
  int get hashCode => Object.hash(Object.hashAll(vertices),
      Object.hashAll(indices ?? <Object?>[]), paintId);

  @override
  bool operator ==(Object other) =>
      other is OnDrawVertices &&
      _listEquals(vertices, other.vertices) &&
      _listEquals(indices, other.indices) &&
      other.paintId == paintId;

  @override
  String toString() => 'OnDrawVertices($vertices, $indices, $paintId)';
}

@immutable
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
    required this.shaderId,
  });

  final int color;
  final int? strokeCap;
  final int? strokeJoin;
  final int blendMode;
  final double? strokeMiterLimit;
  final double? strokeWidth;
  final int paintStyle;
  final int id;
  final int? shaderId;

  @override
  int get hashCode => Object.hash(color, strokeCap, strokeJoin, blendMode,
      strokeMiterLimit, strokeWidth, paintStyle, id, shaderId);

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
      other.id == id &&
      other.shaderId == shaderId;

  @override
  String toString() =>
      'OnPaintObject(color: $color, strokeCap: $strokeCap, strokeJoin: $strokeJoin, '
      'blendMode: $blendMode, strokeMiterLimit: $strokeMiterLimit, strokeWidth: $strokeWidth, '
      'paintStyle: $paintStyle, id: $id, shaderId: $shaderId)';
}

@immutable
class OnPathClose {
  const OnPathClose();

  @override
  int get hashCode => 44221;

  @override
  bool operator ==(Object other) => other is OnPathClose;

  @override
  String toString() => 'OnPathClose';
}

@immutable
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

@immutable
class OnPathFinished {
  const OnPathFinished();

  @override
  int get hashCode => 1223;

  @override
  bool operator ==(Object other) => other is OnPathFinished;

  @override
  String toString() => 'OnPathFinished';
}

@immutable
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

@immutable
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

@immutable
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

@immutable
class OnSize {
  const OnSize(this.width, this.height);

  final double width;
  final double height;

  @override
  int get hashCode => Object.hash(width, height);

  @override
  bool operator ==(Object other) =>
      other is OnSize && other.width == width && other.height == height;

  @override
  String toString() => 'OnSize($width, $height)';
}

@immutable
class OnTextConfig {
  const OnTextConfig(
    this.text,
    this.xAnchorMultiplier,
    this.fontSize,
    this.fontFamily,
    this.fontWeight,
    this.decoration,
    this.decorationStyle,
    this.decorationColor,
    this.id,
  );

  final String text;
  final double xAnchorMultiplier;
  final double fontSize;
  final String? fontFamily;
  final int fontWeight;
  final int decoration;
  final int decorationStyle;
  final int decorationColor;
  final int id;

  @override
  int get hashCode => Object.hash(
        text,
        xAnchorMultiplier,
        fontSize,
        fontFamily,
        fontWeight,
        decoration,
        decorationStyle,
        decorationColor,
        id,
      );

  @override
  bool operator ==(Object other) =>
      other is OnTextConfig &&
      other.text == text &&
      other.xAnchorMultiplier == xAnchorMultiplier &&
      other.fontSize == fontSize &&
      other.fontFamily == fontFamily &&
      other.fontWeight == fontWeight &&
      other.decoration == decoration &&
      other.decorationStyle == decorationStyle &&
      other.decorationColor == decorationColor &&
      other.id == id;

  @override
  String toString() =>
      'OnTextConfig($text, $fontSize, $fontFamily, $fontWeight, $decoration, $decorationStyle, $decorationColor, $id)';
}

@immutable
class OnDrawText {
  const OnDrawText(this.textId, this.fillId, this.strokeId, this.patternId);

  final int textId;
  final int? fillId;
  final int? strokeId;
  final int? patternId;

  @override
  int get hashCode => Object.hash(textId, fillId, strokeId, patternId);

  @override
  bool operator ==(Object other) =>
      other is OnDrawText &&
      other.textId == textId &&
      other.fillId == fillId &&
      other.strokeId == strokeId &&
      other.patternId == patternId;

  @override
  String toString() => 'OnDrawText($textId, $fillId, $strokeId, $patternId)';
}

@immutable
class OnImage {
  const OnImage(this.id, this.format, this.data, {this.onError});

  final int id;
  final int format;
  final List<int> data;
  final VectorGraphicsErrorListener? onError;

  @override
  int get hashCode => Object.hash(id, format, data, onError);

  @override
  bool operator ==(Object other) =>
      other is OnImage &&
      other.id == id &&
      other.format == format &&
      other.onError == onError &&
      _listEquals(other.data, data);

  @override
  String toString() => 'OnImage($id, $format, data:${data.length} bytes)';
}

@immutable
class OnDrawImage {
  const OnDrawImage(
      this.id, this.x, this.y, this.width, this.height, this.transform);

  final int id;
  final double x;
  final double y;
  final double width;
  final double height;
  final Float64List? transform;

  @override
  int get hashCode => Object.hash(
      id, x, y, width, height, Object.hashAll(transform ?? const <Object?>[]));

  @override
  bool operator ==(Object other) {
    return other is OnDrawImage &&
        other.id == id &&
        other.x == x &&
        other.y == y &&
        other.width == width &&
        other.height == height &&
        _listEquals(other.transform, transform);
  }

  @override
  String toString() => 'OnDrawImage($id, $x, $y, $width, $height, $transform)';
}

@immutable
class OnPatternStart {
  const OnPatternStart(
      this.patternId, this.x, this.y, this.width, this.height, this.transform);

  final int patternId;
  final double x;
  final double y;
  final double width;
  final double height;
  final Float64List transform;

  @override
  int get hashCode =>
      Object.hash(patternId, x, y, width, height, Object.hashAll(transform));

  @override
  bool operator ==(Object other) =>
      other is OnPatternStart &&
      other.patternId == patternId &&
      other.x == x &&
      other.y == y &&
      other.width == width &&
      other.height == height &&
      _listEquals(other.transform, transform);

  @override
  String toString() =>
      'OnPatternStart($patternId, $x, $y, $width, $height, $transform)';
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

@immutable
class OnUpdateTextPosition {
  const OnUpdateTextPosition(this.id);

  final int id;

  @override
  int get hashCode => id;

  @override
  bool operator ==(Object other) =>
      other is OnUpdateTextPosition && other.id == id;
}
