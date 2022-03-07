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

  test('Paint applyParent', () {
    const Paint a = Paint(
      blendMode: BlendMode.srcOver,
      fill: Fill(color: Color(0xABCDEF00)),
    );
    const Paint b = Paint(
      blendMode: BlendMode.darken,
      stroke: Stroke(color: Color(0xABCDEF00)),
      pathFillType: PathFillType.evenOdd,
    );

    expect(
      a.applyParent(b),
      Paint(
        blendMode: a.blendMode,
        fill: a.fill,
        stroke: b.stroke,
        pathFillType: b.pathFillType,
      ),
    );

    expect(
      b.applyParent(a),
      Paint(
        blendMode: b.blendMode,
        fill: a.fill,
        stroke: b.stroke,
        pathFillType: b.pathFillType,
      ),
    );
  });

  test('Fill applyParent', () {
    const Fill a = Fill(color: Color(0x12345678));
    const Fill b = Fill();
    const Fill c = Fill(color: Color(0x87654321));
    expect(a.applyParent(b).color, a.color);
    expect(b.applyParent(a).color, b.color);
    expect(a.applyParent(c).color, a.color);
    expect(c.applyParent(a).color, c.color);
  });

  test('Stroke applyParent', () {
    const Stroke a = Stroke(color: Color(0x12345678));
    const Stroke b = Stroke();
    const Stroke c = Stroke(cap: StrokeCap.round);
    expect(a.applyParent(b).color, a.color);
    expect(a.applyParent(b).cap, b.cap);

    expect(b.applyParent(a).color, b.color);
    expect(b.applyParent(a).cap, b.cap);

    expect(a.applyParent(c).color, a.color);
    expect(c.applyParent(a).color, a.color);
  });

  test('Paint.isEmpty', () {
    expect(const Paint().isEmpty, true);
    expect(Paint.empty.isEmpty, true);
  });
}
