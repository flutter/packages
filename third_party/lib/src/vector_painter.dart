import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'vector_drawable.dart';

/// A [CustomPainter] that can render a [DrawableRoot] to a [Canvas].
class VectorPainter extends CustomPainter {
  final DrawableRoot drawable;

  VectorPainter(this.drawable);

  @override
  void paint(Canvas canvas, Size size) {
    if (drawable == null) {
      return;
    }

    drawable.scaleCanvasToViewBox(canvas, size);
    drawable.clipCanvasToViewBox(canvas);
    drawable.draw(canvas);
  }

  // TODO: implement semanticsBuilder

  @override
  bool shouldRepaint(VectorPainter oldDelegate) => true;
}
