import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'picture_stream.dart';

@immutable
class RawPicture extends LeafRenderObjectWidget {
  const RawPicture(
    this.picture, {
    Key key,
    this.matchTextDirection = false,
    this.textDirection,
  }) : super(key: key);

  final PictureInfo picture;
  final bool matchTextDirection;
  final TextDirection textDirection;

  @override
  RenderPicture createRenderObject(BuildContext context) {
    // TODO: implement createRenderObject
    return new RenderPicture(
        picture: picture,
        matchTextDirection: matchTextDirection,
        textDirection: textDirection);
  }

  @override
  void updateRenderObject(BuildContext context, RenderPicture renderObject) {
    renderObject
      ..picture = picture
      ..matchTextDirection = matchTextDirection
      ..textDirection = textDirection;
  }
}

class RenderPicture extends RenderBox {
  RenderPicture({
    PictureInfo picture,
    bool matchTextDirection: false,
    TextDirection textDirection,
  })  : _picture = picture,
        _matchTextDirection = matchTextDirection,
        _textDirection = textDirection;

  /// Whether to paint the image in the direction of the [TextDirection].
  ///
  /// If this is true, then in [TextDirection.ltr] contexts, the image will be
  /// drawn with its origin in the top left (the "normal" painting direction for
  /// images); and in [TextDirection.rtl] contexts, the image will be drawn with
  /// a scaling factor of -1 in the horizontal direction so that the origin is
  /// in the top right.
  ///
  /// This is occasionally used with images in right-to-left environments, for
  /// images that were designed for left-to-right locales. Be careful, when
  /// using this, to not flip images with integral shadows, text, or other
  /// effects that will look incorrect when flipped.
  ///
  /// If this is set to true, [textDirection] must not be null.
  bool get matchTextDirection => _matchTextDirection;
  bool _matchTextDirection;
  set matchTextDirection(bool value) {
    assert(value != null);
    if (value == _matchTextDirection) {
      return;
    }
    _matchTextDirection = value;
    markNeedsPaint();
  }

  bool get _flipHorizontally =>
      _matchTextDirection && _textDirection == TextDirection.rtl;

  /// The text direction with which to resolve [alignment].
  ///
  /// This may be changed to null, but only after the [alignment] and
  /// [matchTextDirection] properties have been changed to values that do not
  /// depend on the direction.
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) {
      return;
    }
    _textDirection = value;
    markNeedsPaint();
  }

  PictureInfo _picture;
  PictureInfo get picture => _picture;
  set picture(PictureInfo val) {
    if (val == picture) {
      return;
    }
    _picture = val;
    markNeedsPaint();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.smallest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (picture == null || size == null || size == Size.zero) {
      return;
    }
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);
    if (_flipHorizontally) {
      final double dx = -(offset.dx + size.width / 2.0);
      context.canvas.translate(-dx, 0.0);
      context.canvas.scale(-1.0, 1.0);
    }

    // this is sometimes useful for debugging, will remove
    // context.canvas.drawRect(
    //     Offset.zero & size,
    //     new Paint()
    //       ..color = const Color(0xFFFA0000)
    //       ..style = PaintingStyle.stroke);

    scaleCanvasToViewBox(context.canvas, size, picture.viewBox);
    context.canvas.clipRect(picture.viewBox);
    context.canvas.drawPicture(picture.picture);
    context.canvas.restore();
  }
}

void scaleCanvasToViewBox(Canvas canvas, Size desiredSize, Rect viewBox) {
  final double xscale = desiredSize.width / viewBox.size.width;
  final double yscale = desiredSize.height / viewBox.size.height;

  if (xscale == yscale) {
    canvas.scale(xscale, yscale);
  } else if (xscale < yscale) {
    final double xtranslate = (viewBox.size.width - viewBox.size.height) / 2;
    canvas.scale(xscale, xscale);
    canvas.translate(0.0, xtranslate);
  } else {
    final double ytranslate = (viewBox.size.height - viewBox.size.width) / 2;
    canvas.scale(yscale, yscale);
    canvas.translate(ytranslate, 0.0);
  }
}
