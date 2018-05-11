import 'dart:typed_data';
import 'dart:ui';

import 'package:path_drawing/path_drawing.dart';
import 'package:flutter/widgets.dart' hide TextStyle;
import 'package:meta/meta.dart';

typedef Paint PaintServer(Rect bounds);

/// Base interface for vector drawing.
@immutable
abstract class Drawable {
  /// Whether this [Drawable] would be visible if [draw]n.
  bool get isVisible;

  /// Draws the contents or children of this [Drawable] to the `canvas`, using
  /// the `parentPaint` to optionally override the child's paint.
  void draw(Canvas canvas, [DrawableStyle parentStyle]);
}

@immutable
class DrawableStyle {
  final Paint stroke;
  final CircularIntervalList dashArray;
  final DashOffset dashOffset;
  final Paint fill;
  final Float64List transform;
  final TextStyle textStyle;
  final PathFillType pathFillType;
  final double groupOpacity;

  const DrawableStyle(
      {this.stroke,
      this.dashArray,
      this.dashOffset,
      this.fill,
      this.transform,
      this.textStyle,
      this.pathFillType,
      this.groupOpacity});

  /// Creates a new [DrawableStyle] if `other` is not null, filling in any null properties on
  /// this with the properties from other.
  ///
  /// If `other` is null, returns this.
  DrawableStyle mergeAndBlend(DrawableStyle other) {
    if (other == null) return this;

    final DrawableStyle ret = new DrawableStyle(
      fill: this.fill ?? other.fill,
      stroke: this.stroke ?? other.stroke,
      dashArray: this.dashArray ?? other.dashArray,
      dashOffset: this.dashOffset ?? other.dashOffset,
      transform: this.transform ?? other.transform,
      textStyle: this.textStyle ?? other.textStyle,
      pathFillType: this.pathFillType ?? other.pathFillType,
      groupOpacity: mergeOpacity(this.groupOpacity, other.groupOpacity),
    );

    if (ret.fill != null) {
      // print(
      //     'before ${ret.fill.color} ${ret.groupOpacity} ${ret.fill.color.opacity} ${mergeOpacity(ret.fill.color.opacity, ret.groupOpacity)}');
      ret.fill.color = ret.fill.color.withOpacity(ret.fill.color.opacity == 1.0
          ? ret.groupOpacity ?? 1.0
          : mergeOpacity(ret.groupOpacity, ret.fill.color.opacity));
    }
    if (ret.stroke != null) {
      ret.stroke.color = ret.stroke.color.withOpacity(
          ret.stroke.color.opacity == 1.0
              ? ret.groupOpacity ?? 1.0
              : mergeOpacity(ret.groupOpacity, ret.stroke.color.opacity));
    }

    return ret;
  }

  static double mergeOpacity(double back, double front) {
    if (back == null) {
      return front;
    } else if (front == null) {
      return back;
    }
    return (front + back) / 2.0;
    //return back + (1.0 - back) * front;
  }
}

class DrawableText implements Drawable {
  final Offset offset;
  final DrawableStyle style;
  final Paragraph _paragraph;

  DrawableText(text, this.offset, this.style)
      : assert(text != null && text != ''),
        _paragraph = _buildParagraph(text, style);

  static Paragraph _buildParagraph(String text, DrawableStyle style) {
    final ParagraphBuilder pb = new ParagraphBuilder(new ParagraphStyle())
      ..pushStyle(style.textStyle)
      ..addText(text);

    return pb.build()..layout(new ParagraphConstraints(width: double.infinity));
  }

  @override
  bool get isVisible => _paragraph.width > 0.0;

  @override
  draw(Canvas canvas, [DrawableStyle parentStyle]) {
    canvas.drawParagraph(_paragraph, offset);
  }
}

/// The root element of a drawable.
class DrawableRoot implements Drawable {
  /// The expected coordinates used by child paths for drawing.
  final Rect viewBox;

  /// The actual child or group to draw.
  final List<Drawable> children;

  final Map<String, PaintServer> paintServers;

  final DrawableStyle style;

  const DrawableRoot(
      this.viewBox, this.children, this.paintServers, this.style);

  /// Scales the `canvas` so that the drawing units in this [Drawable]
  /// will scale to the `desiredSize`.
  ///
  /// If the `viewBox` dimensions are not 1:1 with `desiredSize`, will scale to
  /// the smaller dimension and translate to center the image along the larger
  /// dimension.
  void scaleToViewBox(Canvas canvas, Size desiredSize) {
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

  /// Clips the canvas to a rect corresponding to the `viewBox`.
  void clipToViewBox(Canvas canvas) {
    canvas.clipRect(viewBox.translate(viewBox.left, viewBox.top));
  }

  @override
  bool get isVisible =>
      children.isNotEmpty == true && viewBox != null && !viewBox.isEmpty;

  @override
  void draw(Canvas canvas, [DrawableStyle parentStyle]) {
    children.forEach((child) =>
        child.draw(canvas, style?.mergeAndBlend(parentStyle) ?? parentStyle));
  }
}

/// Represents an element that is not rendered and has no chidlren.
class DrawableNoop implements Drawable {
  final String name;
  const DrawableNoop(this.name);

  @override
  bool get isVisible => false;

  @override
  void draw(Canvas canvas, [DrawableStyle parentStyle]) {}
}

/// Represents a group of drawing elements that may share a common `transform`, `stroke`, or `fill`.
class DrawableGroup implements Drawable {
  final List<Drawable> children;
  final DrawableStyle style;

  const DrawableGroup(this.children, this.style);

  @override
  bool get isVisible => children != null && children.length > 0;

  @override
  void draw(Canvas canvas, [DrawableStyle parentStyle]) {
    if (style?.transform != null) {
      canvas.save();
      canvas.transform(style?.transform);
    }
    children.forEach((child) {
      child.draw(canvas, style?.mergeAndBlend(parentStyle) ?? parentStyle);
    });
    if (style?.transform != null) {
      canvas.restore();
    }
  }
}

/// Represents a drawing element that will be rendered to the canvas.
class DrawableShape implements Drawable {
  final DrawableStyle style;
  final Path path;

  Rect get bounds => path?.getBounds();

  const DrawableShape(this.path, this.style) : assert(path != null);

  @override
  bool get isVisible =>
      !bounds.isEmpty && (style?.stroke != null || style?.fill != null);

  @override
  void draw(Canvas canvas, [DrawableStyle parentStyle]) {
    final DrawableStyle localStyle = style.mergeAndBlend(parentStyle);
    path.fillType = localStyle.pathFillType ?? PathFillType.nonZero;

    if (localStyle?.fill != null) {
      canvas.drawPath(path, localStyle.fill);
    }

    if (localStyle?.stroke != null) {
      if (localStyle.dashArray != null) {
        canvas.drawPath(
            dashPath(path,
                dashArray: localStyle.dashArray,
                dashOffset: localStyle.dashOffset),
            localStyle.stroke);
      } else {
        canvas.drawPath(path, localStyle.stroke);
      }
    }
  }
}

/// A [CustomPainter] that can render a [DrawableRoot] to a [Canvas].
class VectorPainter extends CustomPainter {
  final DrawableRoot drawable;
  final bool _clipToViewBox;

  VectorPainter(this.drawable, {bool clipToViewBox = true})
      : _clipToViewBox = clipToViewBox;

  @override
  void paint(Canvas canvas, Size size) {
    Rect p;
    p.hashCode;
    if (drawable == null ||
        drawable.viewBox == null ||
        drawable.viewBox.size.width == 0) return;

    drawable.scaleToViewBox(canvas, size);
    if (_clipToViewBox) {
      drawable.clipToViewBox(canvas);
    }

    drawable.draw(canvas);
  }

  @override
  bool shouldRepaint(VectorPainter oldPainter) => true;
}
