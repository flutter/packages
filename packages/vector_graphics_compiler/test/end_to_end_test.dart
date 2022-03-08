import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import 'test_svg_strings.dart';

class TestBytesLoader extends BytesLoader {
  TestBytesLoader(this.data);

  final ByteData data;

  @override
  Future<ByteData> loadBytes() async {
    return data;
  }
}

const List<String> kTestAssets = <String>[
  ghostscriptTiger,
];

void main() {
  testWidgets('Can endcode and decode simple SVGs with no errors',
      (WidgetTester tester) async {
    for (final String svg in kTestAssets) {
      final Uint8List bytes = await encodeSVG(svg, 'test.svg');

      await tester.pumpWidget(VectorGraphic(
          bytesLoader: TestBytesLoader(bytes.buffer.asByteData())));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    }
  });
}
