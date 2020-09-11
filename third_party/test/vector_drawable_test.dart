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
    expect(root.style.pathFillType, styleA.pathFillType);
    root = root.mergeStyle(styleB);
    expect(root.style.pathFillType, styleB.pathFillType);
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
    final Image image = await info.picture.toImage(2, 2);
    final ByteData data = await image.toByteData();

    const List<int> expected = <int>[
      0, 48, 0, 255, //
      0, 48, 0, 255,
      0, 48, 0, 255,
      0, 48, 0, 255,
    ];
    expect(data.buffer.asUint8List(), expected);
  });
}
