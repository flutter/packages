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
    );

    expect(
      a.applyParent(b),
      Paint(
        blendMode: a.blendMode,
        fill: a.fill,
        stroke: b.stroke,
      ),
    );

    expect(
      b.applyParent(a),
      Paint(
        blendMode: b.blendMode,
        fill: a.fill,
        stroke: b.stroke,
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

  test('Paint toFlutterString', () {
    const Paint paint = Paint(
      blendMode: BlendMode.screen,
      stroke: Stroke(
          color: Color(0x87654321),
          width: 2.0,
          cap: StrokeCap.round,
          join: StrokeJoin.bevel,
          miterLimit: 10.0,
          shader: LinearGradient(
            from: Point(0, 0),
            to: Point(10, 10),
            colors: <Color>[Color.opaqueBlack, Color(0xFFABCDEF)],
            tileMode: TileMode.mirror,
            offsets: <double>[0.0, 1.0],
            transform: AffineMatrix.identity,
            unitMode: GradientUnitMode.userSpaceOnUse,
          )),
      fill: Fill(
        color: Color(0x12345678),
        shader: RadialGradient(
          center: Point(50, 50),
          radius: 10,
          colors: <Color>[Color(0xFFFFFFAA), Color(0xFFABCDEF)],
          tileMode: TileMode.clamp,
          transform: AffineMatrix.identity,
          focalPoint: Point(5, 50),
          offsets: <double>[.1, .9],
        ),
      ),
    );

    expect(
      paint.fill!.toFlutterPaintString(
        'shader1',
        'fillPaint',
        paint.blendMode,
      ),
      'final shader1 = Gradient.radial(\n'
      '  const Offset(50.0, 50.0),\n'
      '  10.0,\n'
      '  [Color(0xffffffaa), Color(0xffabcdef)],\n'
      '  [0.1, 0.9],\n'
      '  TileMode.clamp,\n'
      '  Float64List.fromList(<double>[1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0]),\n'
      '  const Offset(5.0, 50.0),\n'
      '  0.0,\n'
      ');\n'
      '\n'
      'final fillPaint = Paint()\n'
      '  ..blendMode = BlendMode.screen\n'
      '  ..color = Color(0x12345678)\n'
      '  ..shader = shader1;\n',
    );

    expect(
      paint.stroke!.toFlutterPaintString(
        'shader2',
        'strokePaint',
        paint.blendMode,
      ),
      'final shader2 = Gradient.linear(\n'
      '  const Offset(0.0, 0.0),\n'
      '  const Offset(10.0, 10.0),\n'
      '  [Color(0xff000000), Color(0xffabcdef)],\n'
      '  [0.0, 1.0],\n'
      '  TileMode.mirror,\n'
      '  Float64List.fromList([1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0]),\n'
      ');\n'
      '\n'
      'final strokePaint = Paint()\n'
      '  ..blendMode = BlendMode.screen\n'
      '  ..color = Color(0x87654321)\n'
      '  ..shader = shader2\n'
      '  ..strokeCap = StrokeCap.round\n'
      '  ..strokeJoin = StrokeJoin.bevel\n'
      '  ..strokeMiterLimit = 10.0\n'
      '  ..strokeWidth = 2.0\n'
      '  ..style = PaintingStyle.stroke;\n',
    );
  });

  test('LinearGradient can be converted to local coordinates', () {
    const LinearGradient gradient = LinearGradient(
      from: Point(0, 0),
      to: Point(1, 1),
      colors: <Color>[Color.opaqueBlack, Color(0xFFABCDEF)],
      tileMode: TileMode.mirror,
      offsets: <double>[0.0, 1.0],
      transform: AffineMatrix.identity,
    );

    final LinearGradient transformed = gradient.applyBounds(
        const Rect.fromLTWH(5, 5, 100, 100), AffineMatrix.identity);

    expect(transformed.from, const Point(5, 5));
    expect(transformed.to, const Point(105, 105));
  });

  test('LinearGradient applied bounds with userSpaceOnUse', () {
    const LinearGradient gradient = LinearGradient(
      from: Point(0, 0),
      to: Point(1, 1),
      colors: <Color>[Color.opaqueBlack, Color(0xFFABCDEF)],
      tileMode: TileMode.mirror,
      offsets: <double>[0.0, 1.0],
      transform: AffineMatrix.identity,
      unitMode: GradientUnitMode.userSpaceOnUse,
    );

    final LinearGradient transformed = gradient.applyBounds(
        const Rect.fromLTWH(5, 5, 100, 100), AffineMatrix.identity);

    expect(transformed.from, const Point(0, 0));
    expect(transformed.to, const Point(1, 1));
  });

  test('LinearGradient applied bounds with userSpaceOnUse and transformed', () {
    final LinearGradient gradient = LinearGradient(
      from: const Point(0, 0),
      to: const Point(1, 1),
      colors: const <Color>[Color.opaqueBlack, Color(0xFFABCDEF)],
      tileMode: TileMode.mirror,
      offsets: const <double>[0.0, 1.0],
      transform: AffineMatrix.identity.scaled(2),
      unitMode: GradientUnitMode.userSpaceOnUse,
    );

    final LinearGradient transformed = gradient.applyBounds(
        const Rect.fromLTWH(5, 5, 100, 100), AffineMatrix.identity);

    expect(transformed.from, const Point(0, 0));
    expect(transformed.to, const Point(2, 2));
  });

  test('RadialGradient can be converted to local coordinates', () {
    const RadialGradient gradient = RadialGradient(
      center: Point(0.5, 0.5),
      radius: 10,
      colors: <Color>[Color(0xFFFFFFAA), Color(0xFFABCDEF)],
      tileMode: TileMode.clamp,
      transform: AffineMatrix.identity,
      focalPoint: Point(0.6, 0.6),
      offsets: <double>[.1, .9],
    );

    final RadialGradient transformed = gradient.applyBounds(
        const Rect.fromLTWH(5, 5, 100, 100), AffineMatrix.identity);

    expect(transformed.center, const Point(55, 55));
    expect(transformed.focalPoint, const Point(65, 65));
  });

  test('RadialGradient applied bounds with userSpaceOnUse', () {
    const RadialGradient gradient = RadialGradient(
      center: Point(0.5, 0.5),
      radius: 10,
      colors: <Color>[Color(0xFFFFFFAA), Color(0xFFABCDEF)],
      tileMode: TileMode.clamp,
      transform: AffineMatrix.identity,
      focalPoint: Point(0.6, 0.6),
      offsets: <double>[.1, .9],
      unitMode: GradientUnitMode.userSpaceOnUse,
    );

    final RadialGradient transformed = gradient.applyBounds(
        const Rect.fromLTWH(5, 5, 100, 100), AffineMatrix.identity);

    expect(transformed.center, const Point(0.5, 0.5));
    expect(transformed.focalPoint, const Point(0.6, 0.6));
  });
}
