import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'picture_stream.dart';

/// A widget that displays a [dart:ui.Picture] directly.
@immutable
class RawPicture extends LeafRenderObjectWidget {
  /// Creates a new [RawPicture] object.
  const RawPicture(
    this.picture, {
    Key? key,
    this.matchTextDirection = false,
    this.allowDrawingOutsideViewBox = false,
    this.useLegacyPaint = true,
  }) : super(key: key);

  /// Whether to use a less efficient, but completely visually compatible,
  /// method of painting the picture.
  ///
  /// This flag is intended to assist clients with migration to the layer based
  /// painting method. Once all known clients have been migrated, it will be
  /// deprecated and become a no-op.
  final bool useLegacyPaint;

  /// The picture to paint.
  final PictureInfo? picture;

  /// Whether this picture should match the ambient [TextDirection] or not.
  final bool matchTextDirection;

  /// Whether to allow this picture to draw outside of its specified
  /// [PictureInfo.viewport]. Caution should be used here, as this may lead to
  /// greater memory usage than intended.
  final bool allowDrawingOutsideViewBox;

  @override
  RenderPicture createRenderObject(BuildContext context) {
    return RenderPicture(
      picture: picture,
      matchTextDirection: matchTextDirection,
      textDirection: matchTextDirection ? Directionality.of(context) : null,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      useLegacyPaint: useLegacyPaint,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderPicture renderObject) {
    assert(renderObject.useLegacyPaint == useLegacyPaint);
    renderObject
      ..picture = picture
      ..matchTextDirection = matchTextDirection
      ..allowDrawingOutsideViewBox = allowDrawingOutsideViewBox
      ..textDirection = matchTextDirection ? Directionality.of(context) : null;
  }
}

/// A picture in the render tree.
///
/// The render picture will draw based on its parents dimensions maintaining
/// its aspect ratio.
///
/// If `matchTextDirection` is true, the picture will be flipped horizontally in
/// [TextDirection.rtl] contexts.  If `allowDrawingOutsideViewBox` is true, the
/// picture will be allowed to draw beyond the constraints of its viewbox; this
/// flag should be used with care, as it may result in unexpected effects or
/// additional memory usage.
class RenderPicture extends RenderBox {
  /// Creates a new [RenderPicture].
  RenderPicture({
    PictureInfo? picture,
    bool matchTextDirection = false,
    TextDirection? textDirection,
    bool? allowDrawingOutsideViewBox,
    this.useLegacyPaint = true,
  })  : _matchTextDirection = matchTextDirection,
        _textDirection = textDirection,
        _allowDrawingOutsideViewBox = allowDrawingOutsideViewBox {
    this.picture = picture;
  }

  /// Whether to use a less efficient, but completely visually compatible,
  /// method of painting the picture.
  ///
  /// This flag is intended to assist clients with migration to the layer based
  /// painting method. Once all known clients have been migrated, it will be
  /// deprecated and become a no-op.
  final bool useLegacyPaint;

  /// Optional color to use to draw a thin rectangle around the canvas.
  ///
  /// Only applied if asserts are enabled (e.g. debug mode).
  static Color? debugRectColor;

  /// Whether to paint the picture in the direction of the [TextDirection].
  ///
  /// If this is true, then in [TextDirection.ltr] contexts, the picture will be
  /// drawn with its origin in the top left (the "normal" painting direction for
  /// pictures); and in [TextDirection.rtl] contexts, the picture will be drawn with
  /// a scaling factor of -1 in the horizontal direction so that the origin is
  /// in the top right.
  ///
  /// This is occasionally used with pictures in right-to-left environments, for
  /// pictures that were designed for left-to-right locales. Be careful, when
  /// using this, to not flip pictures with integral shadows, text, or other
  /// effects that will look incorrect when flipped.
  ///
  /// If this is set to true, [textDirection] must not be null.
  bool get matchTextDirection => _matchTextDirection;
  bool _matchTextDirection;
  set matchTextDirection(bool value) {
    assert(value != null); // ignore: unnecessary_null_comparison
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
  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection == value) {
      return;
    }
    _textDirection = value;
    markNeedsPaint();
  }

  /// The information about the picture to draw.
  PictureInfo? get picture => _picture;
  PictureInfo? _picture;
  set picture(PictureInfo? val) {
    if (val == picture) {
      return;
    }
    _picture = val;
    _pictureHandle.layer = _picture?.createLayer();
    assert(() {
      if (_pictureHandle.layer != null) {
        assert(_pictureHandle.layer!.isComplexHint);
        assert(!_pictureHandle.layer!.willChangeHint);
      }
      return true;
    }());
    markNeedsPaint();
  }

  /// Whether to allow the rendering of this picture to exceed the
  /// [PictureInfo.viewport] bounds.
  ///
  /// Caution should be used around setting this parameter to true, as it
  /// may result in greater memory usage during rasterization.
  bool? get allowDrawingOutsideViewBox => _allowDrawingOutsideViewBox;
  bool? _allowDrawingOutsideViewBox;
  set allowDrawingOutsideViewBox(bool? val) {
    if (val == _allowDrawingOutsideViewBox) {
      return;
    }

    _allowDrawingOutsideViewBox = val;
    markNeedsPaint();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.smallest;
  }

  @override
  bool get isRepaintBoundary => !useLegacyPaint;

  final LayerHandle<TransformLayer> _transformHandle =
      LayerHandle<TransformLayer>();

  final LayerHandle<ClipRectLayer> _clipHandle = LayerHandle<ClipRectLayer>();

  final LayerHandle<PictureLayer> _pictureHandle = LayerHandle<PictureLayer>();

  void _addPicture(PaintingContext context, Offset offset) {
    assert(picture != null);
    assert(_pictureHandle.layer != null);
    if (allowDrawingOutsideViewBox != true) {
      final Rect viewportRect = Offset.zero & _picture!.viewport.size;
      _clipHandle.layer = context.pushClipRect(
        needsCompositing,
        offset,
        viewportRect,
        (PaintingContext context, Offset offset) {
          context.addLayer(_pictureHandle.layer!);
        },
        oldLayer: _clipHandle.layer,
      );
    } else {
      _clipHandle.layer = null;
      context.addLayer(_pictureHandle.layer!);
    }
  }

  @override
  void dispose() {
    _transformHandle.layer = null;
    _pictureHandle.layer = null;
    _clipHandle.layer = null;
    super.dispose();
  }

  void _legacyPaintif(PaintingContext context, Offset offset) {
    if (picture == null || picture!.picture == null || size == Size.zero) {
      return;
    }
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);
    if (_flipHorizontally) {
      context.canvas.translate(size.width, 0.0);
      context.canvas.scale(-1.0, 1.0);
    }

    // this is sometimes useful for debugging, e.g. to draw
    // a thin red border around the drawing.
    assert(() {
      if (RenderPicture.debugRectColor != null &&
          RenderPicture.debugRectColor!.alpha > 0) {
        context.canvas.drawRect(
            Offset.zero & size,
            Paint()
              ..color = debugRectColor!
              ..style = PaintingStyle.stroke);
      }
      return true;
    }());
    final Matrix4 transform = Matrix4.identity();
    if (scaleCanvasToViewBox(
      transform,
      size,
      _picture!.viewport,
      _picture!.size,
    )) {
      context.canvas.transform(transform.storage);
    }
    final Rect viewportRect = Offset.zero & _picture!.viewport.size;
    if (allowDrawingOutsideViewBox != true) {
      context.canvas.clipRect(viewportRect);
    }
    context.canvas.drawPicture(picture!.picture!);
    context.canvas.restore();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (useLegacyPaint) {
      _legacyPaintif(context, offset);
      return;
    }

    if (picture == null || size == Size.zero) {
      return;
    }

    bool needsTransform = false;
    final Matrix4 transform = Matrix4.identity();

    if (_flipHorizontally) {
      needsTransform = true;
      transform
        ..translate(size.width, 0.0)
        ..scale(-1.0, 1.0);
    }

    if (scaleCanvasToViewBox(
      transform,
      size,
      _picture!.viewport,
      _picture!.size,
    )) {
      needsTransform = true;
    }

    if (needsTransform) {
      _transformHandle.layer = context.pushTransform(
        needsCompositing,
        offset,
        transform,
        _addPicture,
        oldLayer: _transformHandle.layer,
      );
    } else {
      _transformHandle.layer = null;
      _addPicture(context, offset);
    }

    // this is sometimes useful for debugging, e.g. to draw
    // a thin red border around the drawing.
    assert(() {
      if (RenderPicture.debugRectColor != null &&
          RenderPicture.debugRectColor!.alpha > 0) {
        context.canvas.drawRect(
            Offset.zero & size,
            Paint()
              ..color = debugRectColor!
              ..style = PaintingStyle.stroke);
      }
      return true;
    }());
  }
}

/// Scales a matrix to the given [viewBox] based on the [desiredSize]
/// of the widget.
///
/// Returns true if the supplied matrix was modified.
bool scaleCanvasToViewBox(
  Matrix4 matrix,
  Size desiredSize,
  Rect viewBox,
  Size pictureSize,
) {
  if (desiredSize == viewBox.size) {
    return false;
  }
  final double scale = math.min(
    desiredSize.width / viewBox.width,
    desiredSize.height / viewBox.height,
  );
  final Size scaledHalfViewBoxSize = viewBox.size * scale / 2.0;
  final Size halfDesiredSize = desiredSize / 2.0;
  final Offset shift = Offset(
    halfDesiredSize.width - scaledHalfViewBoxSize.width,
    halfDesiredSize.height - scaledHalfViewBoxSize.height,
  );
  matrix
    ..translate(shift.dx, shift.dy)
    ..scale(scale, scale);
  return true;
}
