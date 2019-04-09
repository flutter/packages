import 'dart:ui' show Size, PathFillType;

import 'package:flutter_svg/src/vector_drawable.dart';
import 'package:test/test.dart';

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
      const DrawableViewport(Size(100, 100), Size(100, 100)),
      <Drawable>[],
      DrawableDefinitionServer(),
      styleA,
    );
    expect(root.style.pathFillType, styleA.pathFillType);
    root = root.mergeStyle(styleB);
    expect(root.style.pathFillType, styleB.pathFillType);
  });
}
