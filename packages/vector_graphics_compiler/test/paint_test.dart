import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import 'package:test/test.dart';

void main() {
  test('Color tests', () {
    expect(
      const Color.fromRGBO(10, 15, 20, .1),
      const Color.fromARGB(25, 10, 15, 20),
    );

    expect(
      const Color.fromARGB(255, 10, 15, 20).withOpacity(.1),
      const Color.fromARGB(25, 10, 15, 20),
    );

    const Color testColor = Color(0xFFABCDEF);
    expect(testColor.r, 0xAB);
    expect(testColor.g, 0xCD);
    expect(testColor.b, 0xEF);
  });

  test('Paint defaults', () {
    const defaultPaint = Paint();
    expect(defaultPaint.blendMode, BlendMode.srcOver);
    expect(defaultPaint.color, Color.opaqueBlack);
    expect(defaultPaint.shader, null);
    expect(defaultPaint.strokeCap, StrokeCap.butt);
    expect(defaultPaint.strokeJoin, StrokeJoin.miter);
    expect(defaultPaint.strokeMiterLimit, 4);
    expect(defaultPaint.strokeWidth, 0);
    expect(defaultPaint.style, PaintingStyle.fill);
  });
}
