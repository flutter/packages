import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import 'package:test/test.dart';

void main() {
  test('Point tests',  () {
    expect(Point.zero.x, 0);
    expect(Point.zero.y, 0);

    expect(const Point(5, 5) / 2, const Point(2.5, 2.5));
    expect(const Point(5, 5) * 2, const Point(10, 10));
  });

  test('Rect tests', () {
    expect(Rect.zero.left, 0);
    expect(Rect.zero.top, 0);
    expect(Rect.zero.right, 0);
    expect(Rect.zero.bottom, 0);

    expect(
      const Rect.fromLTRB(1, 2, 3, 4).expanded(const Rect.fromLTRB(0, 0, 10, 10)),
      const Rect.fromLTRB(0, 0, 10 ,10),
    );

    expect(
      const Rect.fromCircle(10, 10, 5),
      const Rect.fromLTWH(5, 5, 10, 10),
    );
  });
}
