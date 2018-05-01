import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'src/vector_painter.dart';

enum PaintLocation { Foreground, Background }

/// Handles rendering [Drawables] to a canvas.
class VectorDrawableImage extends StatelessWidget {
  final Size size;
  final Future<DrawableRoot> future;
  final bool clipToViewBox;
  final PaintLocation paintLocation;

  const VectorDrawableImage(this.future, this.size,
      {this.clipToViewBox = true,
      Key key,
      this.paintLocation = PaintLocation.Background})
      : super(key: key);

  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: future,
      builder: ((context, snapShot) {
        if (snapShot.hasData) {
          final CustomPainter painter =
              new VectorPainter(snapShot.data, clipToViewBox: clipToViewBox);
          return new RepaintBoundary.wrap(
              CustomPaint(
                painter:
                    paintLocation == PaintLocation.Background ? painter : null,
                foregroundPainter:
                    paintLocation == PaintLocation.Foreground ? painter : null,
                size: size,
                isComplex: true,
                willChange: false,
              ),
              0);
        }
        return new LimitedBox();
      }),
    );
  }
}
