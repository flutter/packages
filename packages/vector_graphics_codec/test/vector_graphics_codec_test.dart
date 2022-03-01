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

    bufferContains(buffer, [98, 45, 136, 0, 1, 0, 0, 0]);
  });

  test('Messages without any contents cannot be decoded', () {
    expect(() => codec.decode(Uint8List(0).buffer.asByteData(), null), throwsA(isA<StateError>()
      .having((se) => se.message, 'message', contains('The provided data was not a vector_graphics binary asset.'))
    ));
  });

  test('Messages without a magic number cannot be decoded', () {
    expect(() => codec.decode(Uint8List(6).buffer.asByteData(), null), throwsA(isA<StateError>()
      .having((se) => se.message, 'message', contains('The provided data was not a vector_graphics binary asset.'))
    ));
  });

  test('Messages without an incompatible version cannot be decoded', () {
    final Uint8List bytes = Uint8List(6);
    bytes[0] = 98;
    bytes[1] = 45;
    bytes[2] = 136;
    bytes[3] = 0;
    bytes[4] = 6; // version 6.

    expect(() => codec.decode(bytes.buffer.asByteData(), null), throwsA(isA<StateError>()
      .having((se) => se.message, 'message', contains('he provided data does not match the currently supported version.'))
    ));
  });
}
