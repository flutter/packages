import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/listener.dart';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

const VectorGraphicsCodec codec = VectorGraphicsCodec();

void main() {
  test('Can decode a message without a stroke and vertices', () {
    final buffer = VectorGraphicsBuffer();
    final FlutterVectorGraphicsListener listener =
        FlutterVectorGraphicsListener();
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

    expect(listener.toPicture, returnsNormally);
  });

  test('Can decode a message with a fill and path', () {
    final buffer = VectorGraphicsBuffer();
    final FlutterVectorGraphicsListener listener =
        FlutterVectorGraphicsListener();
    final int paintId = codec.writeFill(buffer, 23, 0);
    final int pathId = codec.writeStartPath(buffer, 0);
    codec.writeMoveTo(buffer, 1, 2);
    codec.writeLineTo(buffer, 2, 3);
    codec.writeClose(buffer);
    codec.writeFinishPath(buffer);
    codec.writeDrawPath(buffer, pathId, paintId);

    codec.decode(buffer.done(), listener);

    expect(listener.toPicture, returnsNormally);
  });

  test('Asserts if toPicture is called more than once', () {
    final FlutterVectorGraphicsListener listener =
        FlutterVectorGraphicsListener();
    listener.toPicture();

    expect(listener.toPicture, throwsAssertionError);
  });
}
