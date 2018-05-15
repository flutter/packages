import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'src/vector_painter.dart';

enum PaintLocation { Foreground, Background }

/// Handles rendering [Drawable]s to a canvas.
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

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<DrawableRoot>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<DrawableRoot> snapShot) {
        if (snapShot.hasError) {
          return new ErrorWidget(snapShot.error);
        } else if (snapShot.hasData) {
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
        return const LimitedBox();
      },
    );
  }
}
