import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DrawableRoot can mergeStyle', () {
    const DrawableStyle styleA = DrawableStyle(
      groupOpacity: 0.5,
      pathFillType: PathFillType.evenOdd,
    );
    const DrawableStyle styleB = DrawableStyle(
      pathFillType: PathFillType.nonZero,
    );
    DrawableRoot root = DrawableRoot(
      '', // No id
      const DrawableViewport(Size(100, 100), Size(100, 100)),
      <Drawable>[],
      DrawableDefinitionServer(),
      styleA,
    );
    expect(root.style!.pathFillType, styleA.pathFillType);
    root = root.mergeStyle(styleB);
    expect(root.style!.pathFillType, styleB.pathFillType);
  });

  test('SvgPictureDecoder uses color filter properly', () async {
    final PictureInfo info = await svg.svgPictureStringDecoder(
      '''
<svg viewBox="0 0 100 100">
  <rect height="100" width="100" fill="blue" />
</svg>
''',
      false,
      const ColorFilter.mode(Color(0xFF00FF00), BlendMode.color),
      'test',
    );
    final Image image = await info.picture!.toImage(2, 2);
    final ByteData data = (await image.toByteData())!;

    const List<int> expected = <int>[
      0, 48, 0, 255, //
      0, 48, 0, 255,
      0, 48, 0, 255,
      0, 48, 0, 255,
    ];
    expect(data.buffer.asUint8List(), expected);
  });

  test('SvgPictureDecoder sets isComplexHint', () async {
    final PictureInfo info = await svg.svgPictureStringDecoder(
      '''
<svg viewBox="0 0 100 100">
  <rect height="100" width="100" fill="blue" />
</svg>
''',
      false,
      null,
      'test',
    );

    expect(info.createLayer().isComplexHint, true);
  });

  test('mergeAndBlend gets strokeWidth right', () async {
    final DrawableRoot root = await svg.fromSvgString(
      '''
<svg viewBox="0 0 44 78" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M5 10L20 20L 10 20Z" stroke="white" stroke-width="2" />
</svg>
''',
      'test',
    );

    final DrawablePaint strokePaintA =
        (root.children.first as DrawableShape).style.stroke!;
    final DrawableRoot mergedRoot = root.mergeStyle(
      const DrawableStyle(
        stroke: DrawablePaint(
          PaintingStyle.stroke,
          color: Color(0xFFABCDEF),
        ),
      ),
    );

    final DrawablePaint strokePaintB =
        (mergedRoot.children.first as DrawableShape).style.stroke!;
    expect(strokePaintA.strokeWidth, strokePaintB.strokeWidth);
  });

  test('restore canvas accordingly', () async {
    const String svgWithViewBox = '''
<svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="1 1 15 15">
  <path/>
</svg>
''';

    final PictureRecorder recorder = PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    canvas.save();

    final DrawableRoot svgRoot = await svg.fromSvgString(
      svgWithViewBox,
      'RestoreCanvasWithSvgViewBox',
    );

    svgRoot.scaleCanvasToViewBox(canvas, const Size.square(200));
    svgRoot.clipCanvasToViewBox(canvas);

    svgRoot.draw(canvas, svgRoot.viewport.viewBoxRect);

    expect(canvas.getSaveCount(), equals(2));

    recorder.endRecording();
  });
}
